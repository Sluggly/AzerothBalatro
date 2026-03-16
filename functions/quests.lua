Warcraft = Warcraft or {}
Warcraft.Quests = Warcraft.Quests or {}

SMODS.ConsumableType {
    key = "Quest",
    primary_colour = HEX("8B0000"),
    secondary_colour = HEX("4A0000"),
    loc_txt = { name = "Quest", collection = "Quests", undiscovered = { name = "Unknown Quest", text = { "???" } } },
    shop_rate = 1.0,
    default = 'c_war_orgrimmar'
}

-- Array containing all Quests Conditions
Warcraft.Quests.ConditionTypes = {}

local attributes = {
    { key = "race", ally = "ally_race", enemy = "enemy_race" },
    { key = "faction", ally = "ally_faction", enemy = "enemy_faction" },
    { key = "class", ally = "ally_class", enemy = "enemy_class" }
}

-- Helper function to safely check string vs table matching
local function attr_matches(attr_value, target_name)
    if not attr_value then return false end
    if type(attr_value) == "table" then
        for _, v in ipairs(attr_value) do
            if v == target_name then return true end
        end
        return false
    end
    return attr_value == target_name
end

-- Generate all Quests Conditions
for _, attr in ipairs(attributes) do
    -- Condition Have Count (Ally)
    Warcraft.Quests.ConditionTypes["have_count_" .. attr.key] = {
        id = "have_count_" .. attr.key,
        base_mech = "have_count",
        req_pool = attr.ally,
        attr_key = attr.key,
        gen_target = function() return pseudorandom("hc_"..attr.key) > 0.5 and 1 or 2 end,
        check = function(ex, jokers)
            local count = 0
            for _, j in ipairs(jokers) do
                if j.ability and j.ability.extra then
                    if attr_matches(j.ability.extra[attr.key], ex.target_name) then 
                        count = count + 1 
                    end
                end
            end
            return count >= ex.target_num
        end
    }

    -- Condition Sell Count (Enemy)
    Warcraft.Quests.ConditionTypes["sell_count_" .. attr.key] = {
        id = "sell_count_" .. attr.key,
        base_mech = "sell_count",
        req_pool = attr.enemy,
        attr_key = attr.key,
        gen_target = function() return pseudorandom("sc_"..attr.key) > 0.5 and 1 or 2 end,
        check = function(ex, jokers) 
            return (ex.progress or 0) >= ex.target_num 
        end
    }

    -- Condition Have Level (Ally)
    Warcraft.Quests.ConditionTypes["have_level_" .. attr.key] = {
        id = "have_level_" .. attr.key,
        base_mech = "have_level",
        req_pool = attr.ally,
        attr_key = attr.key,
        gen_target = function() return pseudorandom("hl_"..attr.key) > 0.5 and 5 or 3 end,
        check = function(ex, jokers)
            for _, j in ipairs(jokers) do
                if j.ability and j.ability.extra and attr_matches(j.ability.extra[attr.key], ex.target_name) then
                    if (j.ability.extra.level or 1) >= ex.target_num then return true end
                end
            end
            return false
        end
    }

    -- Condition Have Ilvl Equipment (Ally)
    Warcraft.Quests.ConditionTypes["have_ilvl_" .. attr.key] = {
        id = "have_ilvl_" .. attr.key,
        base_mech = "have_ilvl",
        req_pool = attr.ally,
        attr_key = attr.key,
        gen_target = function() return pseudorandom("hi_"..attr.key) > 0.5 and 10 or 5 end,
        check = function(ex, jokers)
            for _, j in ipairs(jokers) do
                if j.ability and j.ability.extra and attr_matches(j.ability.extra[attr.key], ex.target_name) then
                    local ilvl = j.ability.wow_equipment and j.ability.wow_equipment.ilvl or 0
                    if ilvl >= ex.target_num then return true end
                end
            end
            return false
        end
    }

    -- Condition Sell Level (Enemy)
    Warcraft.Quests.ConditionTypes["sell_level_" .. attr.key] = {
        id = "sell_level_" .. attr.key,
        base_mech = "sell_level",
        req_pool = attr.enemy,
        attr_key = attr.key,
        gen_target = function() return pseudorandom("sl_"..attr.key) > 0.5 and 4 or 3 end,
        check = function(ex, jokers) 
            return (ex.progress or 0) >= 1 
        end
    }
end

-- Function to track sold joker for Conditions
function Warcraft.Quests.on_joker_sold(sold_extra)
    if not G.consumeables then return end

    for _, card in ipairs(G.consumeables.cards) do
        if card.ability.set == "Quest" then
            local ex = card.ability.extra
            
            -- Does the sold joker match the required Race/Faction/Class
            if ex.attr_key and attr_matches(sold_extra[ex.attr_key], ex.target_name) then
                
                -- Handle Sell Count Condition
                if ex.base_mech == "sell_count" then
                    ex.progress = (ex.progress or 0) + 1
                    if ex.progress >= ex.target_num then card:juice_up() end
                
                -- Handle Sell Level Condition
                elseif ex.base_mech == "sell_level" then
                    if (sold_extra.level or 1) >= ex.target_num then
                        ex.progress = 1
                        card:juice_up()
                    end
                end
            end
        end
    end
end

-- Generate all Quests Rewards types
Warcraft.Quests.RewardTypes = {
    -- All Race/Class/Faction gain Level
    all_level = {
        id = "all_level",
        skip_target_check = true,
        gen_target = function() return pseudorandom("r_al") > 0.8 and 2 or 1 end,
        get_text = function(ex)
            return {"All Jokers gain ", "+"..ex.r_num, " Level", "", "."}
        end,
        apply = function(ex, jokers)
            for _, j in ipairs(jokers) do
                if j.ability and j.ability.extra then
                    j.ability.extra.level = (j.ability.extra.level or 1) + ex.r_num
                    -- Raise max_level so the gain isn't immediately capped
                    j.ability.extra.max_level = (j.ability.extra.max_level or 1) + ex.r_num
                    -- Also raise start_level if defined so level-up scaling stays correct
                    if j.ability.extra.start_level then
                        j.ability.extra.start_level = j.ability.extra.start_level + ex.r_num
                    end
                    j.ability.extra.bypass_level_cap = true
                    j:juice_up()
                end
            end
        end
    },

    all_ilvl = {
        id = "all_ilvl",
        skip_target_check = true,
        gen_target = function() return pseudorandom("r_ai") > 0.8 and 2 or 1 end,
        get_text = function(ex)
            return {"All equipped Jokers gain ", "+"..ex.r_num, " Ilvl", "", "."}
        end,
        apply = function(ex, jokers)
            for _, j in ipairs(jokers) do
                if j.ability and j.ability.wow_equipment then
                    j.ability.wow_equipment.ilvl = (j.ability.wow_equipment.ilvl or 1) + ex.r_num
                    j:juice_up()
                end
            end
        end
    },

    random_level = {
        id = "random_level",
        skip_target_check = true,
        gen_target = function() return pseudorandom("r_rl") > 0.5 and 3 or 2 end,
        get_text = function(ex)
            return {"A random Joker gains ", "+"..ex.r_num, " Level", "", "."}
        end,
        apply = function(ex, jokers)
            if #jokers > 0 then
                local chosen = pseudorandom_element(jokers, pseudoseed("rw_rl"))
                if chosen.ability and chosen.ability.extra then
                    chosen.ability.extra.level = (chosen.ability.extra.level or 1) + ex.r_num
                    chosen.ability.extra.max_level = (chosen.ability.extra.max_level or 1) + ex.r_num
                    if chosen.ability.extra.start_level then
                        chosen.ability.extra.start_level = chosen.ability.extra.start_level + ex.r_num
                    end
                    chosen.ability.extra.bypass_level_cap = true
                    chosen:juice_up()
                end
            end
        end
    },

    random_edition = {
        id = "random_edition",
        gen_target = function()
            local seed = "rw_ed_" .. (G.GAME and G.GAME.round or "init")
            return pseudorandom_element({"foil", "holo", "polychrome", "negative"}, pseudoseed(seed))
        end,
        get_text = function(ex)
            local ed_names = { foil = "Foil", holo = "Holographic", polychrome = "Polychrome", negative = "Negative" }
            local ed_name = ed_names[ex.r_num] or "Special"
            return {"Make a random ", ed_name, " ", ex.r_target, " Joker."}
        end,
        apply = function(ex, jokers)
            local valid = {}
            for _, j in ipairs(jokers) do
                if j.ability and j.ability.extra and attr_matches(j.ability.extra[ex.r_attr], ex.r_target) then
                    table.insert(valid, j)
                end
            end
            if #valid > 0 then
                local chosen = pseudorandom_element(valid, pseudoseed("rw_re_ap"))
                chosen:set_edition({[ex.r_num] = true}, true, true)
            end
        end
    },

    create_joker = {
        id = "create_joker",
        gen_target = function() return 1 end,
        get_text = function(ex)
            local cat = ex.r_attr or "race"
            local cat_display = cat:sub(1,1):upper() .. cat:sub(2)
            return {"Open a ", ex.r_target, " Joker Pack", "", "."}
        end,
        apply = function(ex, jokers)
            if #G.consumeables.cards >= G.consumeables.config.card_limit then return end

            G.E_MANAGER:add_event(Event({
                func = function()
                    -- Create the booster pack card
                    local pack = create_card("Booster", G.consumeables, nil, nil, nil, nil, "p_war_warcraft_faction_pack_1", "quest")
                    -- Store the filter on the pack so create_card can use it
                    pack.ability.extra.attr_key = ex.r_attr
                    pack.ability.extra.target = ex.r_target
                    pack:add_to_deck()
                    G.consumeables:emplace(pack)
                    pack:juice_up()
                    return true
                end
            }))
        end
    },

    money_per = {
        id = "money_per",
        skip_target_check = true,
        gen_target = function() return pseudorandom("r_mp") > 0.5 and 8 or 5 end,
        get_text = function(ex)
            local cat = ex.r_attr or "race"
            local cat_display = cat:sub(1,1):upper() .. cat:sub(2)
            return {"Gain ", "$"..ex.r_num, " per most common ", cat_display, " Joker."}
        end,
        apply = function(ex, jokers)
            local cat = ex.r_attr or "race"
            -- Count occurrences of each value in the selected category
            local counts = {}
            for _, j in ipairs(jokers) do
                if j.ability and j.ability.extra then
                    local val = j.ability.extra[cat]
                    local vals = type(val) == "table" and val or (val and {val} or {})
                    for _, v in ipairs(vals) do
                        counts[v] = (counts[v] or 0) + 1
                    end
                end
            end
            -- Find the highest count
            local best_count = 0
            for _, c in pairs(counts) do
                if c > best_count then best_count = c end
            end
            if best_count > 0 then
                ease_dollars(best_count * ex.r_num)
            end
        end
    },

    random_weapon = {
        id = "random_weapon",
        skip_target_check = true,
        gen_target = function()
            -- Collect all unique non-Fist weapon types from equipment definitions
            local seen = {}
            local weapons = {}
            for _, eq in pairs(Warcraft.Equipment.items) do
                if eq.req_weapon then
                    local wlist = type(eq.req_weapon) == "table" and eq.req_weapon or {eq.req_weapon}
                    for _, w in ipairs(wlist) do
                        if w ~= "Fist" and not seen[w] then
                            seen[w] = true
                            table.insert(weapons, w)
                        end
                    end
                end
            end
            if #weapons > 0 then
                return pseudorandom_element(weapons, pseudoseed("r_rw_" .. (G.GAME and G.GAME.round or "init")))
            end
            return "Sword"
        end,
        get_text = function(ex)
            return {"Spawn a random ", ex.r_num, " Equipment", "", "."}
        end,
        apply = function(ex, jokers)
            if #G.consumeables.cards >= G.consumeables.config.card_limit then return end
            local weapon_type = ex.r_num
            -- Find all equipment definitions that require this weapon type
            local valid_keys = {}
            for key, eq in pairs(Warcraft.Equipment.items) do
                if eq.req_weapon then
                    local wlist = type(eq.req_weapon) == "table" and eq.req_weapon or {eq.req_weapon}
                    for _, w in ipairs(wlist) do
                        if w == weapon_type then
                            table.insert(valid_keys, key)
                            break
                        end
                    end
                end
            end
            if #valid_keys > 0 then
                local chosen_key = pseudorandom_element(valid_keys, pseudoseed("rw_rw_ap"))
                local new_card = create_card('Equipment', G.consumeables, nil, nil, nil, nil, chosen_key, 'quest')
                new_card:add_to_deck()
                G.consumeables:emplace(new_card)
                new_card:juice_up()
            end
        end
    }
}

-- FACTORY : Create Quests
function Warcraft.create_quest(args)

    local safe_key = args.key or Warcraft.secure_key(args.name)

    local atlas_key, atlas_pos = Warcraft.Atlas.get_pos("quests", args.index or 1, true)

    SMODS.Consumable({
        set = "Quest",
        key = safe_key, 
        name = args.name,
        atlas = atlas_key, 
        pos = args.pos or atlas_pos,
        cost = args.cost or 3,
        unlocked = true,
        discovered = true,
        config = { extra = {} },
        
        loc_txt = {
            name = args.name,
            text = {
                "#1#{C:attention}#2#{}#3#{C:dark_edition}#4#{}#5#",
                "#6#{C:attention}#7#{}#8#{C:dark_edition}#9#{}#10#",
                "{C:inactive}#11##12#{}{C:attention}#13#{}{C:inactive}#14#{}",
                " ",
                "{C:money}Reward:{} #15#{C:attention}#16#{}#17#{C:dark_edition}#18#{}#19#"
            }
        },

        set_ability = function(self, card, initial, delay_sprites)
            card.sell_cost = 0
            card.sell_cost_label = 0

            if initial then
                local seed_suffix = G.GAME and G.GAME.round or "init"

                -- Combo Character
                if args.combo_character and #args.combo_character > 0 then
                    card.ability.extra.combo_character = pseudorandom_element(args.combo_character, pseudoseed("qc_combo_" .. seed_suffix))
                else
                    card.ability.extra.combo_character = "Unknown Hero"
                end

                -- Roll Condition
                local valid_conditions = {}
                for _, cond in pairs(Warcraft.Quests.ConditionTypes) do
                    if args[cond.req_pool] and #args[cond.req_pool] > 0 then
                        table.insert(valid_conditions, cond)
                    end
                end

                if #valid_conditions > 0 then
                    local chosen_cond = pseudorandom_element(valid_conditions, pseudoseed("qc_" .. seed_suffix))
                    local pool = args[chosen_cond.req_pool]
                    
                    card.ability.extra.q_type = chosen_cond.id
                    card.ability.extra.base_mech = chosen_cond.base_mech
                    card.ability.extra.attr_key = chosen_cond.attr_key
                    card.ability.extra.target_name = pseudorandom_element(pool, pseudoseed("qr_" .. seed_suffix))
                    card.ability.extra.target_num = chosen_cond.gen_target()
                    card.ability.extra.progress = 0
                end

                -- Roll Reward (using ally pool only)
                local valid_ally_attrs = {}
                if args.ally_race and #args.ally_race > 0 then table.insert(valid_ally_attrs, {key="race", pool=args.ally_race}) end
                if args.ally_faction and #args.ally_faction > 0 then table.insert(valid_ally_attrs, {key="faction", pool=args.ally_faction}) end
                if args.ally_class and #args.ally_class > 0 then table.insert(valid_ally_attrs, {key="class", pool=args.ally_class}) end

                if #valid_ally_attrs > 0 then
                    local chosen_attr = pseudorandom_element(valid_ally_attrs, pseudoseed("qrw_attr_" .. seed_suffix))
                    card.ability.extra.r_attr = chosen_attr.key
                    card.ability.extra.r_target = pseudorandom_element(chosen_attr.pool, pseudoseed("qrw_targ_" .. seed_suffix))
                    
                    local rw_keys = {"all_level", "all_ilvl", "random_level", "random_edition", "create_joker", "money_per", "random_weapon"}
                    local chosen_rw = pseudorandom_element(rw_keys, pseudoseed("qrw_type_" .. seed_suffix))
                    
                    card.ability.extra.r_type = chosen_rw
                    card.ability.extra.r_num = Warcraft.Quests.RewardTypes[chosen_rw].gen_target()
                end
            end
        end,

        loc_vars = function(self, info_queue, card)
            local ex = card.ability.extra
            if not ex.base_mech then return { vars = {}, key = self.key } end
            
            card.sell_cost = 0
            local combo = ex.combo_character or "Unknown Hero"
            
            -- Get dynamic reward text array
            local rw = {"?", "?", "?", "?", "?"}
            if ex.r_type and Warcraft.Quests.RewardTypes[ex.r_type] then
                rw = Warcraft.Quests.RewardTypes[ex.r_type].get_text(ex)
            end

            if ex.base_mech == "have_count" then
                return { vars = { "Have ", ex.target_num, " ", ex.target_name, " Jokers.", "", "", "", "", "", "", "(Or hold ", combo, ")", rw[1], rw[2], rw[3], rw[4], rw[5] }, key = self.key }
            elseif ex.base_mech == "sell_count" then
                return { vars = { "Sell ", ex.target_num, " ", ex.target_name, " Jokers.", "", "", "", "", "", "(Progress: "..(ex.progress or 0).."/"..ex.target_num.." OR ", "hold ", combo, ")", rw[1], rw[2], rw[3], rw[4], rw[5] }, key = self.key }
            elseif ex.base_mech == "have_level" then
                return { vars = { "Have a ", "", "", ex.target_name, " Joker", "at Level ", ex.target_num, " or higher.", "", "", "", "(Or hold ", combo, ")", rw[1], rw[2], rw[3], rw[4], rw[5] }, key = self.key }
            elseif ex.base_mech == "have_ilvl" then
                return { vars = { "Have Ilvl ", ex.target_num, " Equipment", "", "", "on a ", "", "", ex.target_name, " Joker.", "", "(Or hold ", combo, ")", rw[1], rw[2], rw[3], rw[4], rw[5] }, key = self.key }
            elseif ex.base_mech == "sell_level" then
                return { vars = { "Sell a ", "", "", ex.target_name, " Joker", "at Level ", ex.target_num, " or higher.", "", "", "(Progress: "..(ex.progress or 0).."/1 OR ", "hold ", combo, ")", rw[1], rw[2], rw[3], rw[4], rw[5] }, key = self.key }
            end
        end,

        can_use = function(self, card)
            if card.area == G.pack_cards then
                return #G.consumeables.cards < G.consumeables.config.card_limit
            end
            local ex = card.ability.extra
            local jokers = G.jokers and G.jokers.cards or {}
            
            -- Check if the Quest Condition is met
            local condition_met = false
            if ex.combo_character then
                for _, j in ipairs(jokers) do
                    if j.config and j.config.center and j.config.center.name == ex.combo_character then
                        condition_met = true
                        break
                    end
                end
            end

            if not condition_met then
                if not ex.q_type then return false end
                local cond = Warcraft.Quests.ConditionTypes[ex.q_type]
                if cond and cond.check(ex, jokers) then
                    condition_met = true
                end
            end

            if not condition_met then return false end

            -- Check if the Reward has a valid target

            if ex.r_type == "create_joker" then
                return #G.jokers.cards < G.jokers.config.card_limit
            end

            local rw_def = Warcraft.Quests.RewardTypes[ex.r_type]
            if rw_def and rw_def.skip_target_check then
                return true
            end

            for _, j in ipairs(jokers) do
                if j.ability and j.ability.extra and attr_matches(j.ability.extra[ex.r_attr], ex.r_target) then
                    return true
                end
            end
            return false
        end,

        use = function(self, card, area, copier)
            if area == G.pack_cards then
                local clone = copy_card(card, nil)
                clone.T.x = card.T.x
                clone.T.y = card.T.y
                clone:add_to_deck()
                G.consumeables:emplace(clone)
                card.states.visible = false
                return
            end
            local ex = card.ability.extra
            play_sound('coin1')
            
            if ex.r_type and Warcraft.Quests.RewardTypes[ex.r_type] then
                Warcraft.Quests.RewardTypes[ex.r_type].apply(ex, G.jokers and G.jokers.cards or {})
            end
        end
    })
end