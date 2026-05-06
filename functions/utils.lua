Warcraft = Warcraft or {}

function Warcraft.secure_key(name)
    return string.lower(name:gsub(" ", "_"):gsub("[^a-zA-Z0-9_]", ""))
end

function Warcraft.get_keys(dict)
    local res = {}
    for k, _ in pairs(dict) do table.insert(res, k) end
    return res
end

function Warcraft.is_straight_hand(name)
    if not name then return false end
    return name:find("Straight") or name == "Royal Flush"
end

function Warcraft.has_joker(name)
    for _, j in ipairs(G.jokers.cards) do
        if j.ability.name == name then
            return true
        end
    end
    return false
end

function Warcraft.has_active_joker(name)
    for _, j in ipairs(G.jokers.cards) do
        if j.ability.name == name and not j.debuff then
            return true
        end
    end
    return false
end

-- Generic attribute checker for BOTH Jokers and Playing Cards
function Warcraft.has_attribute(card, category, value)
    if not card or not card.ability or not card.ability.extra or type(card.ability.extra) ~= "table" then return false end
    local attr = card.ability.extra[category]
    if not attr then return false end
    
    local list = type(attr) == "table" and attr or { attr }
    for _, v in ipairs(list) do
        if v == value then return true end
    end
    return false
end

-- Specific Helpers routed through the generic checker
function Warcraft.is_race(card, race) return Warcraft.has_attribute(card, "race", race) end
function Warcraft.is_class(card, class) return Warcraft.has_attribute(card, "class", class) end
function Warcraft.is_faction(card, faction) return Warcraft.has_attribute(card, "faction", faction) end
function Warcraft.is_role(card, role) return Warcraft.has_attribute(card, "role", role) end
function Warcraft.is_damage(card, damage) return Warcraft.has_attribute(card, "damage", damage) end
function Warcraft.is_armor(card, armor) return Warcraft.has_attribute(card, "armor", armor) end
function Warcraft.is_profession(card, prof) return Warcraft.has_attribute(card, "profession", prof) end
function Warcraft.is_weapon(card, weapon) return Warcraft.has_attribute(card, "weapon", weapon) end

-- Helper: check if a joker has a specific race in the config
function Warcraft.is_race_by_config(extra, race)
    if not extra or not extra.race then return false end
    if type(extra.race) == "table" then
        for _, r in ipairs(extra.race) do
            if r == race then return true end
        end
    else
        return extra.race == race
    end
    return false
end

-- Helper: check if a joker is Demon race OR Legion faction (used by Archimonde/Malganis etc)
function Warcraft.is_demon_or_legion(joker)
    if not joker then return false end
    return Warcraft.is_race(joker, "Demon") or Warcraft.is_faction(joker, "Legion")
end

-- Helper : sort deck
function Warcraft.loken_sort_deck()
    if not G.deck or not G.deck.cards then return end
    -- Check if Loken is active
    local loken_active = false
    if G.jokers then
        for _, j in ipairs(G.jokers.cards) do
            if j.ability and j.ability.name == "Loken" then
                loken_active = true
                break
            end
        end
    end
    if not loken_active then return end

    -- Sealed cards go to end of array (= top of deck = drawn first)
    table.sort(G.deck.cards, function(a, b)
        local a_sealed = a.seal and true or false
        local b_sealed = b.seal and true or false
        if a_sealed ~= b_sealed then
            return not a_sealed -- unsealed sink to front, sealed float to end
        end
        return false
    end)
end

-- Get scaled value by using joker level and ilvl
function Warcraft.get_scaled_gain(card, base_gain, gain_per_level, gain_per_ilvl)
    local level = (card.ability.extra.level or 1) - 1
    local ilvl = card.ability.wow_equipment and (card.ability.wow_equipment.ilvl - 1) or 0
    return base_gain + (level * (gain_per_level or 0)) + (ilvl * (gain_per_ilvl or 0))
end

-- Leokk function to temporarily double all beasts levels
function Warcraft.leokk_apply(leokk_card, apply)
    if not G.jokers then return end
    for _, j in ipairs(G.jokers.cards) do
        if j ~= leokk_card and Warcraft.is_race(j, "Beast") and j.ability.extra and j.ability.extra.level then
            if apply then
                -- Store original level and double it
                if not j.ability.extra.leokk_original_level then
                    j.ability.extra.leokk_original_level = j.ability.extra.level
                    j.ability.extra.level = j.ability.extra.level * 2
                    if j.ability.extra.max_level and j.ability.extra.level > j.ability.extra.max_level then
                        j.ability.extra.max_level = j.ability.extra.level
                    end
                end
            else
                -- Restore original level
                if j.ability.extra.leokk_original_level then
                    j.ability.extra.level = j.ability.extra.leokk_original_level
                    j.ability.extra.leokk_original_level = nil
                end
            end
            j:juice_up()
        end
    end
end

-- ============================================
-- COMBO HELPERS
-- ============================================

function Warcraft.get_badge_color(val)
    local lookup = val:gsub(" ", "_")
    return G.C["WAR_" .. string.upper(lookup)] or G.C.UI.TEXT_DARK
end

-- Fetch a Joker's primary race color dynamically for UI tooltips
function Warcraft.get_joker_color(joker_name)
    for _, center in pairs(G.P_CENTERS) do
        if center.name == joker_name and center.set == "Joker" then
            if center.config and center.config.extra and center.config.extra.race then
                local race = center.config.extra.race
                local first_race = type(race) == "table" and race[1] or race
                if first_race then
                    local lookup = first_race:gsub(" ", "_")
                    return G.C["WAR_" .. string.upper(lookup)] or G.C.UI.TEXT_DARK
                end
            end
        end
    end
    return G.C.UI.TEXT_DARK
end

-- ============================================
-- ATTRIBUTE MODIFIERS
-- ============================================

-- Core function to modify an attribute, trigger UI syncs, and auto-assign missing related traits
function Warcraft.modify_attribute(card, category, value, is_random)
    if not card then return false end
    card.ability = card.ability or {}
    card.ability.extra = card.ability.extra or {}

    local final_value = value
    
    -- Handle random generation
    if is_random then
        local pool = Warcraft.get_keys(Warcraft.Constants.StickerPositions[category])
        if not pool or #pool == 0 then return false end
        -- Salt the seed with object ID/Type so multiple cloned cards don't roll the same
        local seed = "war_attr_" .. category .. (card.base and card.base.id or "x") .. (G.GAME and G.GAME.round or 1) .. tostring(math.random())
        final_value = pseudorandom_element(pool, pseudoseed(seed))
    end
    
    if not final_value then return false end

    -- Normalize to a table (e.g. {"Warrior"} instead of "Warrior") for consistency
    if type(final_value) ~= "table" then
        final_value = { final_value }
    end

    -- Apply the trait
    card.ability.extra[category] = final_value
    card.ability.extra.is_warcraft = true

    -- Auto-fill related attributes if we just set a Class
    if category == "class" and final_value[1] then
        local cls = final_value[1]
        local seed_suffix = (card.base and card.base.id or "y") .. (G.GAME and G.GAME.round or 1) .. tostring(math.random())
        
        -- Auto-assign Armor if missing
        if not card.ability.extra.armor and Warcraft.Constants.ClassToArmor[cls] then
            card.ability.extra.armor = { Warcraft.Constants.ClassToArmor[cls] }
        end
        
        -- Auto-assign Role if missing (Random from the class's valid roles)
        if not card.ability.extra.role and Warcraft.Constants.ClassToRole[cls] then
            local role = pseudorandom_element(Warcraft.Constants.ClassToRole[cls], pseudoseed("auto_role_" .. seed_suffix))
            card.ability.extra.role = { role }
        end
        
        -- Auto-assign Damage if missing (Random from the class's valid damage types)
        if not card.ability.extra.damage and Warcraft.Constants.ClassToDamage[cls] then
            local dmg = pseudorandom_element(Warcraft.Constants.ClassToDamage[cls], pseudoseed("auto_dmg_" .. seed_suffix))
            card.ability.extra.damage = { dmg }
        end
    end

    -- Trigger the sticker rendering update
    Warcraft.sync_ui_elements(card)
    return true
end

-- Specific Wrappers routed through the core modifier
function Warcraft.modify_race(card, value, is_random) return Warcraft.modify_attribute(card, "race", value, is_random) end
function Warcraft.modify_class(card, value, is_random) return Warcraft.modify_attribute(card, "class", value, is_random) end
function Warcraft.modify_faction(card, value, is_random) return Warcraft.modify_attribute(card, "faction", value, is_random) end
function Warcraft.modify_damage(card, value, is_random) return Warcraft.modify_attribute(card, "damage", value, is_random) end
function Warcraft.modify_armor(card, value, is_random) return Warcraft.modify_attribute(card, "armor", value, is_random) end
function Warcraft.modify_role(card, value, is_random) return Warcraft.modify_attribute(card, "role", value, is_random) end
function Warcraft.modify_weapon(card, value, is_random) return Warcraft.modify_attribute(card, "weapon", value, is_random) end
function Warcraft.modify_profession(card, value, is_random) return Warcraft.modify_attribute(card, "profession", value, is_random) end

-- ============================================
-- PLAYING CARD GENERATOR
-- ============================================

-- Unified function to assign configured random traits to a playing card
function Warcraft.assign_playing_card_traits(card)
    if not card or not card.base or not card.base.suit then return end
    if card.ability and card.ability.extra and card.ability.extra.is_warcraft then return end

    -- Fetch the config safely at runtime
    local conf = SMODS.Mods and SMODS.Mods["Warcraft"] and SMODS.Mods["Warcraft"].config
    if not conf or not conf.pc_start then return end

    -- ==========================================
    -- ORC VS HUMAN DECK OVERRIDE
    -- ==========================================
    if G.GAME and G.GAME.modifiers.war_orc_vs_human then
        if card:is_suit('Spades') or card:is_suit('Clubs') then
            Warcraft.modify_faction(card, "Alliance", false)
            Warcraft.modify_race(card, "Human", false)
            Warcraft.modify_class(card, "Warrior", false)
        else
            Warcraft.modify_faction(card, "Horde", false)
            Warcraft.modify_race(card, "Orc", false)
            Warcraft.modify_class(card, "Warrior", false)
        end
        card.ability.extra.level = 1
        return -- Exit early so we don't apply the normal randomized configs!
    end

    -- ==========================================
    -- REIGN OF CHAOS DECK OVERRIDE
    -- ==========================================
    if G.GAME and G.GAME.modifiers.war_reign_of_chaos then
        -- Salt the seed with ID, round, and random float to guarantee 
        -- cloned/multiple cards don't roll identical classes!
        local seed = "roc_cls_" .. (card.base.id or "x") .. (G.GAME.round or 1) .. tostring(math.random())
        
        if card:is_suit('Spades') then
            Warcraft.modify_faction(card, "Scourge", false)
            Warcraft.modify_race(card, "Undead", false)
            Warcraft.modify_class(card, pseudorandom(seed) > 0.5 and "Death Knight" or "Rogue", false)
            
        elseif card:is_suit('Clubs') then
            Warcraft.modify_faction(card, "Alliance", false)
            Warcraft.modify_race(card, "Human", false)
            Warcraft.modify_class(card, pseudorandom(seed) > 0.5 and "Warrior" or "Mage", false)
            
        elseif card:is_suit('Hearts') then
            Warcraft.modify_faction(card, "Alliance", false)
            Warcraft.modify_race(card, "Night Elf", false)
            Warcraft.modify_class(card, pseudorandom(seed) > 0.5 and "Druid" or "Hunter", false)
            
        elseif card:is_suit('Diamonds') then
            Warcraft.modify_faction(card, "Horde", false)
            Warcraft.modify_race(card, "Orc", false)
            Warcraft.modify_class(card, pseudorandom(seed) > 0.5 and "Warlock" or "Shaman", false)
        end
        
        card.ability.extra.level = 1
        return -- Exit early
    end

    -- ==========================================
    -- STANDARD CARD GENERATION (If no Deck Overrides)
    -- ==========================================
    local modified = false

    card.ability = card.ability or {}
    card.ability.extra = card.ability.extra or {}
    
    -- Check Class FIRST! If applied, it will automatically populate missing Role, Armor, and Damage.
    if conf.pc_start.class and not card.ability.extra.class then 
        Warcraft.modify_class(card, nil, true)
        modified = true 
    end
    
    if conf.pc_start.race and not card.ability.extra.race then 
        Warcraft.modify_race(card, nil, true)
        modified = true 
    end
    if conf.pc_start.faction and not card.ability.extra.faction then 
        Warcraft.modify_faction(card, nil, true)
        modified = true 
    end
    
    -- Because Class ran first, these three will safely bypass if the Class auto-filled them!
    if conf.pc_start.damage and not card.ability.extra.damage then 
        Warcraft.modify_damage(card, nil, true)
        modified = true 
    end
    if conf.pc_start.armor and not card.ability.extra.armor then 
        Warcraft.modify_armor(card, nil, true)
        modified = true 
    end
    if conf.pc_start.role and not card.ability.extra.role then 
        Warcraft.modify_role(card, nil, true)
        modified = true 
    end
    
    if modified and not card.ability.extra.level then
        card.ability.extra.level = 1
    end
end

-- ============================================
-- BOOSTER PACK CARD GENERATOR
-- ============================================
function Warcraft.apply_booster_card_traits(card)
    if not card or not card.base or not card.base.suit then return end
    
    -- 1. Ensure basic config traits are applied (in case set_base was bypassed)
    Warcraft.assign_playing_card_traits(card)
    
    local conf = SMODS.Mods and SMODS.Mods["Warcraft"] and SMODS.Mods["Warcraft"].config
    if not conf or not conf.pc_start then return end
    
    local modified = false
    -- Unique seed combining ID, round, and card coordinates so packs don't clone RNG
    local seed = "boost_80_" .. (card.base.id or "x") .. (G.GAME and G.GAME.round or 1) .. tostring(card.T.x)

    -- 2. Run 80% chance rolls for any missing attributes not strictly forced by config
    if not conf.pc_start.class and not card.ability.extra.class then
        if pseudorandom(seed .. "_cls") < 0.8 then 
            Warcraft.modify_class(card, nil, true)
            modified = true 
        end
    end
    if not conf.pc_start.race and not card.ability.extra.race then
        if pseudorandom(seed .. "_rac") < 0.8 then 
            Warcraft.modify_race(card, nil, true)
            modified = true 
        end
    end
    if not conf.pc_start.faction and not card.ability.extra.faction then
        if pseudorandom(seed .. "_fac") < 0.8 then 
            Warcraft.modify_faction(card, nil, true)
            modified = true 
        end
    end
    if not conf.pc_start.damage and not card.ability.extra.damage then
        if pseudorandom(seed .. "_dmg") < 0.8 then 
            Warcraft.modify_damage(card, nil, true)
            modified = true 
        end
    end
    if not conf.pc_start.armor and not card.ability.extra.armor then
        if pseudorandom(seed .. "_arm") < 0.8 then 
            Warcraft.modify_armor(card, nil, true)
            modified = true 
        end
    end
    if not conf.pc_start.role and not card.ability.extra.role then
        if pseudorandom(seed .. "_rol") < 0.8 then 
            Warcraft.modify_role(card, nil, true)
            modified = true 
        end
    end
    
    -- 3. Sync UI if we gave it anything new
    if modified and not card.ability.extra.level then
        card.ability.extra.is_warcraft = true
        card.ability.extra.level = card.ability.extra.level or 1
        Warcraft.sync_ui_elements(card)
    end
end