Warcraft = Warcraft or {}
Warcraft.Mounts = {}
Warcraft.Mounts.items = {}

-- ============================================
-- MOUNT CONSUMABLE TYPE
-- ============================================
SMODS.ConsumableType({
    key              = "Mount",
    primary_colour   = { 0.55, 0.35, 0.08, 1 }, -- warm brown
    secondary_colour = { 0.95, 0.80, 0.30, 1 }, -- gold
    loc_txt = {
        name         = "Mount",
        collection   = "Mounts",
        undiscovered = {
            name = "Unknown Mount",
            text = { "A mysterious mount", "waiting to be claimed." },
        },
    },
    default_card_back = true,
    card_limit        = 2,
})

-- ============================================
-- HELPERS
-- ============================================
local function as_list(val)
    if not val then return {} end
    if type(val) == "table" then return val end
    return { val }
end

-- Convert a hex color string to a LÖVE-compatible {r,g,b} table (0-1 range)
local function hex_to_rgb(hex)
    local r = tonumber(hex:sub(1,2), 16) / 255
    local g = tonumber(hex:sub(3,4), 16) / 255
    local b = tonumber(hex:sub(5,6), 16) / 255
    return { r, g, b, 1 }
end

-- Return a Balatro hex color tag for a given category and value
-- Category keys match Warcraft.Constants.Colors sub-tables
local function badge_color_tag(category, value)
    local cat = Warcraft.Constants.Colors and Warcraft.Constants.Colors[category]
    if not cat then return "ffffffff" end
    -- Badge keys use underscores for spaces (e.g. "Night Elf" → "Night_Elf")
    local lookup_key = value:gsub(" ", "_")
    return cat[lookup_key] or cat[value] or "ffffffff"
end

-- Join a list of values into a single colored string of tokens
-- e.g. {"Fire","Frost"} → "{C:#FF6A00}Fire{} {C:#69CCF0}Frost{}"
local function colored_list(values, category)
    local parts = {}
    for _, v in ipairs(values) do
        local hex = badge_color_tag(category, v)
        table.insert(parts, "{C:#" .. hex .. "}" .. v .. "{}")
    end
    return table.concat(parts, " ")
end

-- ============================================
-- REQUIREMENT CHECKING
-- Returns: can_equip (bool), is_combo (bool)
-- ============================================
function Warcraft.Mounts.can_equip(mount_key, joker)
    local def = Warcraft.Mounts.items[mount_key]
    if not def then return false, false end
    if not (joker and joker.ability and type(joker.ability.extra) == "table") then
        return false, false
    end

    -- Joker must be at its level cap (applies to combo jokers too)
    local ex = joker.ability.extra
    local level     = ex.level     or 1
    local max_level = ex.max_level or 10
    if level < max_level then return false, false end

    -- Combo check (bypasses attribute requirements but not the level cap)
    local joker_name = joker.ability.name
    for _, combo_name in ipairs(def.combo or {}) do
        if combo_name == joker_name then
            return true, true
        end
    end

    -- If no requirements defined, any Warcraft joker qualifies
    local req = def.requirements or {}
    if next(req) == nil then
        return (joker.ability.extra.is_warcraft == true), false
    end

    -- Each requirement must be satisfied (OR within values, AND across attrs)
    local ex = joker.ability.extra
    for attr, required_vals in pairs(req) do
        local joker_vals = as_list(ex[attr])
        local satisfied = false
        for _, req_val in ipairs(as_list(required_vals)) do
            for _, j_val in ipairs(joker_vals) do
                if j_val == req_val then
                    satisfied = true
                    break
                end
            end
            if satisfied then break end
        end
        if not satisfied then return false, false end
    end

    return true, false
end

-- ============================================
-- APPLY MOUNT EFFECT
-- ============================================
function Warcraft.Mounts.apply(mount_key, joker, is_combo)
    local def = Warcraft.Mounts.items[mount_key]
    if not def or not (joker.ability and type(joker.ability.extra) == "table") then
        return
    end

    local ex = joker.ability.extra
    local cap_gain = def.level_cap_increase or 5

    -- Increase the level cap
    ex.max_level = (ex.max_level or 10) + cap_gain

    if is_combo then
        -- Combo bonus: +2 levels and +5 ilvl
        ex.level = math.min((ex.level or 1) + 2, ex.max_level)
        if joker.ability.wow_equipment then
            joker.ability.wow_equipment.ilvl = (joker.ability.wow_equipment.ilvl or 1) + 5
        end
        card_eval_status_text(joker, 'extra', nil, nil, nil, {
            message = "Combo Ride! +".. cap_gain .." Cap, +2 Lvl, +5 iLvl",
            colour  = G.C.GOLD,
        })
    else
        card_eval_status_text(joker, 'extra', nil, nil, nil, {
            message = "+" .. cap_gain .. " Level Cap!",
            colour  = G.C.GREEN,
        })
    end

    joker:juice_up()

    -- Refresh level text on the card
    if Warcraft.sync_ui_elements then
        Warcraft.sync_ui_elements(joker)
    end
end

-- ============================================
-- FACTORY: Create a Mount consumable
-- ============================================
function Warcraft.Mounts.create_mount(args)
    assert(args.name,  "Warcraft.Mounts.create_mount: 'name' is required")
    assert(args.index, "Warcraft.Mounts.create_mount: 'index' is required")

    local key        = args.key or Warcraft.secure_key(args.name)
    local atlas_key, atlas_pos = Warcraft.Atlas.get_pos("mounts", args.index)

    -- Register the definition (read by can_equip / apply)
    Warcraft.Mounts.items[key] = {
        name               = args.name,
        requirements       = args.requirements or {},
        combo              = args.combo or {},
        level_cap_increase = args.level_cap_increase or 5,
    }

    local def = Warcraft.Mounts.items[key] -- local reference for closures

    -- Build tooltip lines
    local req = def.requirements
    local combo    = def.combo or {}
    local cap      = def.level_cap_increase or 5
    -- Attribute display metadata: { key in req, display label, Constants.Colors category }
    local ATTR_META = {
        { key = "faction",    label = "Faction",    cat = "Faction"    },
        { key = "race",       label = "Race",       cat = "Race"       },
        { key = "class",      label = "Class",      cat = "Class"      },
        { key = "weapon",     label = "Weapon",     cat = "Weapon"     },
        { key = "damage",     label = "Damage",     cat = "Damage"     },
        { key = "armor",      label = "Armor",      cat = "Armor"      },
        { key = "role",       label = "Role",       cat = "Role"       },
        { key = "profession", label = "Profession", cat = "Profession" },
    }

    local desc_lines = {}

    -- Main effect line
    table.insert(desc_lines,
        "Increase the {C:green}Level Cap{} of")
    table.insert(desc_lines,
        "the selected Joker by {C:attention}#1#{}")

    -- Level cap requirement
    table.insert(desc_lines, " ")
    table.insert(desc_lines,
        "{C:red}Requires:{} Joker must be at")
    table.insert(desc_lines,
        "its {C:attention}Level Cap{}")

    -- Attribute requirements (one line each)
    local has_req = false
    for _, meta in ipairs(ATTR_META) do
        local vals = as_list(req[meta.key])
        if #vals > 0 then
            if not has_req then
                table.insert(desc_lines, " ")
                has_req = true
            end
            table.insert(desc_lines,
                "{C:inactive}" .. meta.label .. ":{} " ..
                colored_list(vals, meta.cat))
        end
    end

    -- Combo jokers (single line, gold)
    if #combo > 0 then
        table.insert(desc_lines, " ")
        table.insert(desc_lines,
            "{C:inactive}Combo:{} {C:attention}" ..
            table.concat(combo, "{}, {C:attention}") .. "{}")
    end

    local final_desc = (type(args.loc_txt) == "table") and args.loc_txt or desc_lines

    SMODS.Consumable({
        key        = key,
        set        = "Mount",
        name       = args.name,
        atlas      = atlas_key,
        pos        = atlas_pos,
        discovered = true,
        unlocked   = true,
        weight     = args.rarity or 1,

        loc_txt = {
            name = args.name,
            text = final_desc,
        },

        loc_vars = function(self, info_queue, card)
            return { vars = { def.level_cap_increase or 5 } }
        end,

        can_use = function(self, card)
            if not G.jokers then return false end
            for _, j in ipairs(G.jokers.cards) do
                if Warcraft.Mounts.can_equip(key, j) then return true end
            end
            return false
        end,

        use = function(self, card, area, copier)
            if not G.jokers then return end

            local target, is_combo = nil, false

            -- Prefer a highlighted joker
            for _, j in ipairs(G.jokers.cards) do
                if j.highlighted then
                    local can, combo = Warcraft.Mounts.can_equip(key, j)
                    if can then
                        target   = j
                        is_combo = combo
                        break
                    end
                end
            end

            -- Fallback: first eligible joker
            if not target then
                for _, j in ipairs(G.jokers.cards) do
                    local can, combo = Warcraft.Mounts.can_equip(key, j)
                    if can then
                        target   = j
                        is_combo = combo
                        break
                    end
                end
            end

            if target then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        Warcraft.Mounts.apply(key, target, is_combo)
                        return true
                    end
                }))
            end
        end
    })
end