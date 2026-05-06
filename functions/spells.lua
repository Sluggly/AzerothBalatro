Warcraft = Warcraft or {}
Warcraft.Spells = {}
Warcraft.Spells.items = {}

-- ============================================
-- SPELL CONSUMABLE TYPE
-- ============================================
SMODS.ConsumableType({
    key              = "Spell",
    primary_colour   = { 0.1, 0.7, 0.9, 1 }, -- Magical Cyan
    secondary_colour = { 0.6, 0.2, 0.8, 1 }, -- Arcane Purple
    loc_txt = {
        name         = "Spell",
        collection   = "Spells",
        undiscovered = { name = "Unknown Spell", text = { "A magical scroll", "waiting to be cast." } },
    },
    default_card_back = true,
    card_limit        = 2,
    shop_rate         = 1.0, -- Allows Spells to naturally appear in the shop
})

-- ============================================
-- HELPERS
-- ============================================
local function as_list(val)
    if not val then return {} end
    if type(val) == "table" then return val end
    return { val }
end

local function badge_color_tag(category, value)
    local cat = Warcraft.Constants and Warcraft.Constants.Colors and Warcraft.Constants.Colors[category]
    if not cat then return "ffffffff" end
    local lookup_key = value:gsub(" ", "_")
    return cat[lookup_key] or cat[value] or "ffffffff"
end

local function colored_list(values, category)
    local parts = {}
    for _, v in ipairs(values) do
        local hex = badge_color_tag(category, v)
        table.insert(parts, "{C:#" .. hex .. "}" .. v .. "{}")
    end
    return table.concat(parts, " or ")
end

-- ============================================
-- REQUIREMENT CHECKING
-- ============================================
function Warcraft.Spells.can_cast(spell_key)
    local def = Warcraft.Spells.items[spell_key]
    if not def then return false end
    
    local req_level = def.req_level or 1
    local req_damage = as_list(def.damage)

    -- If there's no requirement, it can be cast immediately
    if #req_damage == 0 and req_level <= 1 then return true end
    if not G.jokers then return false end

    -- Loop through Jokers to see if any meet the required Damage AND Level
    for _, j in ipairs(G.jokers.cards) do
        if j.ability and type(j.ability.extra) == "table" then
            local ex = j.ability.extra
            local lvl = ex.level or 1
            
            if lvl >= req_level then
                -- If no specific damage is required, just meeting the level is enough
                if #req_damage == 0 or Warcraft.is_damage(j, req_damage) then return true end
            end
        end
    end

    return false
end

-- ============================================
-- FACTORY: Create a Spell
-- ============================================
function Warcraft.Spells.create_spell(args)
    assert(args.name, "create_spell: 'name' is required")
    assert(args.index, "create_spell: 'index' is required")
    assert(args.on_cast, "create_spell: 'on_cast' function is required")

    local key = args.key or Warcraft.secure_key(args.name)
    local atlas_key, atlas_pos = Warcraft.Atlas.get_pos("spells", args.index)

    -- Register definition
    Warcraft.Spells.items[key] = {
        name = args.name,
        damage = args.damage or {},
        req_level = args.req_level or 1,
        target_type = args.target_type, -- "any_card", "joker", or "playing_card"
        on_cast = args.on_cast
    }

    local desc_lines = {}
    
    -- Effect description
    local raw_text = args.loc_text or { "Spell effect." }
    for _, line in ipairs(raw_text) do
        table.insert(desc_lines, line)
    end

    -- Dynamically generate the requirements tooltip
    local req_dmg = as_list(args.damage)
    if #req_dmg > 0 or (args.req_level and args.req_level > 1) then
        table.insert(desc_lines, " ")
        table.insert(desc_lines, "{C:red}Requires:{} Joker at {C:attention}Level " .. (args.req_level or 1) .. "{}")
        if #req_dmg > 0 then
            table.insert(desc_lines, "with " .. colored_list(req_dmg, "Damage") .. " damage")
        end
    end

    SMODS.Consumable({
        key        = key,
        set        = "Spell",
        name       = args.name,
        atlas      = atlas_key,
        pos        = atlas_pos,
        discovered = true,
        unlocked   = true,
        weight     = args.rarity or 1, -- Used by SMODS for rarity calculations!
        cost       = args.cost or 3,

        loc_txt = { name = args.name, text = desc_lines },
        loc_vars = args.loc_vars,

        -- Standard requirement check
        can_use = function(self, card)
            -- 1. Does the player meet the Level & Damage reqs to cast?
            if not Warcraft.Spells.can_cast(key) then return false end
            
            -- 2. Does the player have the right cards highlighted?
            local def = Warcraft.Spells.items[key]
            if def.target_type then
                local hj = G.jokers and #G.jokers.highlighted or 0
                local hh = G.hand and #G.hand.highlighted or 0
                
                if def.target_type == "any_card" then
                    return (hj + hh) == 1
                elseif def.target_type == "joker" then
                    return hj == 1 and hh == 0
                elseif def.target_type == "playing_card" then
                    return hh == 1 and hj == 0
                end
            end

            return true
        end,

        -- Effect execution
        use = function(self, card, area, copier)
            local def = Warcraft.Spells.items[key]
            if def and def.on_cast then
                def.on_cast(card, area, copier)
            end
        end
    })
end

-- Get a random spell that matches AT LEAST ONE of the Joker's damage types
function Warcraft.get_random_spell_for_damage(damage_list, seed)
    local valid_spells = {}
    local fallback_spells = {}
    
    if not Warcraft.Spells or not Warcraft.Spells.items then return nil end
    
    for k, spell in pairs(Warcraft.Spells.items) do
        table.insert(fallback_spells, k)
        if spell.damage and #spell.damage > 0 then
            for _, sd in ipairs(spell.damage) do
                for _, jd in ipairs(damage_list) do
                    if sd == jd then
                        table.insert(valid_spells, k)
                        break
                    end
                end
            end
        end
    end
    
    -- We MUST prepend "c_war_" so create_card can find the generated SMODS object!
    if #valid_spells > 0 then
        return "c_war_" .. pseudorandom_element(valid_spells, pseudoseed(seed))
    elseif #fallback_spells > 0 then
        return "c_war_" .. pseudorandom_element(fallback_spells, pseudoseed(seed .. "_fb"))
    end
    return nil
end