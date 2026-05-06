Warcraft = Warcraft or {}
Warcraft.Equipment = Warcraft.Equipment or {}
Warcraft.Equipment.items = {}
Warcraft.Equipment.keys = {}

SMODS.ConsumableType {
    key = "Equipment",
    primary_colour = HEX("FFD700"),
    secondary_colour = HEX("B8860B"),
    loc_txt = { name = "Equipment", collection = "Equipment", undiscovered = { name = "Unknown", text = { "???" } } },
    shop_rate = 1.0
}

-- Function to increase Equipment ilvl
function Warcraft.attempt_ilvl_up(card)
    if not card.ability or not card.ability.wow_equipment then return end

    local target = card.ability.wow_equipment

    local current_round = G.GAME.round
    if (target.last_round_ilvl_check or 0) ~= current_round then
        target.ilvl_gained_this_round = 0
        target.last_round_ilvl_check = current_round
    end

    if target.ilvl_gained_this_round >= 10 then return end

    target.ilvl = target.ilvl + 1
    target.ilvl_gained_this_round = target.ilvl_gained_this_round + 1

    card_eval_status_text(card, 'extra', nil, nil, nil, {
        message = "Item Up!",
        colour = G.C.GOLD
    })
    Warcraft.sync_ui_elements(card)
end

-- FACTORY: Create Equipment
function Warcraft.create_equipment(args)
    local prefix = string.lower(SMODS.current_mod.prefix or "war")
    local generated_key = Warcraft.secure_key(args.name)
    local full_key = "c_" .. prefix .. "_" .. generated_key

    local atlas_key, atlas_pos = Warcraft.Atlas.get_pos("equipments", args.index or 1, true)

    local combo_list = args.combo_joker or {}
    local class_list = args.req_class or {"Any"}
    local race_list = args.req_race or {}
    local weapon_list = args.req_weapon or {}
    local faction_list = args.req_faction or {}

    Warcraft.Equipment.items[full_key] = {
        name = args.name,
        name_colour = args.name_colour or G.C.GOLD,
        text_colour = args.text_colour or G.C.WHITE,
        loc_text = args.loc_text,
        on_score = args.on_score,
        calculate_stats = args.calculate_stats,
        get_ui_stats = args.get_ui_stats,
        config = args.config or { extra = {} },
        per_card = args.per_card or false,

        -- Restrictions
        req_level = args.req_level, 
        req_class = class_list,
        req_race = race_list,
        req_weapon = weapon_list,
        req_faction = faction_list,
        combo_joker = combo_list,
        combo_bonus = args.combo_bonus or 24
    }

    table.insert(Warcraft.Equipment.keys, full_key)

    local final_loc_text = {}
    
    -- Add the standard effect text
    local raw_text = args.loc_text or { "Effect not found" }
    for _, line in ipairs(raw_text) do
        table.insert(final_loc_text, line)
    end

    local dummy_extra = args.config and args.config.extra or {}
    local dummy_stats = args.calculate_stats(1, dummy_extra)
    local stat_count = (type(dummy_stats) == "table") and #dummy_stats or 1
    local ilvl_index = stat_count + 1
    
    -- Append the Ilvl text using the correct dynamic index
    table.insert(final_loc_text, "{C:attention}Ilvl #" .. ilvl_index .. "#{}")

    SMODS.Consumable {
        key = args.key or generated_key,
        set = "Equipment",
        name = args.name,
        atlas = atlas_key, 
        pos = args.pos or atlas_pos,
        weight = args.weight or 10,
        discovered = true,
        unlocked = true,
        config = args.config or { extra = {} },

        loc_txt = {
            name = args.name,
            text = final_loc_text
        },

        loc_vars = function(self, info_queue, card)
            local ilvl = 1
            local extra = self.config.extra or {}
            
            if card and card.ability then 
                ilvl = card.ability.ilvl or ilvl 
                extra = card.ability.extra or extra
            end
            
            local stats = args.calculate_stats(ilvl, extra)
            if type(stats) ~= "table" then stats = { stats } end
            table.insert(stats, ilvl)

            -- Helper: build a requirement row as direct UI nodes
            local function make_req_row(label, list)
                if not list or #list == 0 then return nil end
                if #list == 1 and list[1] == "Any" then return nil end

                local nodes = {
                    { n = G.UIT.T, config = {
                        text   = label .. ": ",
                        colour = G.C.UI.TEXT_INACTIVE,
                        scale  = 0.30
                    }}
                }

                for i, val in ipairs(list) do
                    table.insert(nodes, { n = G.UIT.T, config = {
                        text   = val,
                        colour = Warcraft.get_badge_color(val),
                        scale  = 0.30
                    }})
                    if i < #list then
                        table.insert(nodes, { n = G.UIT.T, config = {
                            text   = " | ",
                            colour = G.C.UI.TEXT_INACTIVE,
                            scale  = 0.30
                        }})
                    end
                end

                return { n = G.UIT.R, config = { align = "cm" }, nodes = nodes }
            end

            -- Helper: build the combo row with per-joker race colors
            local function make_combo_row(list)
                if not list or #list == 0 then return nil end

                local nodes = {
                    { n = G.UIT.T, config = {
                        text   = "Combo: ",
                        colour = G.C.PURPLE,
                        scale  = 0.30
                    }}
                }

                for i, joker_name in ipairs(list) do
                    table.insert(nodes, { n = G.UIT.T, config = {
                        text   = joker_name,
                        colour = Warcraft.get_joker_color(joker_name),
                        scale  = 0.30
                    }})
                    if i < #list then
                        table.insert(nodes, { n = G.UIT.T, config = {
                            text   = " | ",
                            colour = G.C.PURPLE,
                            scale  = 0.30
                        }})
                    end
                end

                return { n = G.UIT.R, config = { align = "cm" }, nodes = nodes }
            end

            -- Helper: get color based on level requirement value
            local function get_level_color(level)
                if level <= 4 then return G.C.BLUE
                elseif level <= 7 then return G.C.GREEN
                else return G.C.RED
                end
            end

            -- Helper: build the level requirement row
            local function make_level_row(level)
                if not level then return nil end
                return { n = G.UIT.R, config = { align = "cm" }, nodes = {
                    { n = G.UIT.T, config = { text = "Level ",    colour = G.C.GOLD,              scale = 0.30 }},
                    { n = G.UIT.T, config = { text = tostring(level), colour = get_level_color(level), scale = 0.30 }},
                    { n = G.UIT.T, config = { text = " Required", colour = G.C.GOLD,              scale = 0.30 }}
                }}
            end

            -- Build the requirement block as main_end UI nodes
            local req_nodes = {}
            table.insert(req_nodes, { n = G.UIT.B, config = { h = 0.05, w = 0.1 } })

            local combo_row   = make_combo_row(combo_list)
            local level_row   = make_level_row(args.req_level)
            local class_row   = make_req_row("Class",   class_list)
            local race_row    = make_req_row("Race",    race_list)
            local weapon_row  = make_req_row("Weapon",  weapon_list)
            local faction_row = make_req_row("Faction", faction_list)

            if combo_row   then table.insert(req_nodes, combo_row)   end
            if level_row   then table.insert(req_nodes, level_row)   end
            if class_row   then table.insert(req_nodes, class_row)   end
            if race_row    then table.insert(req_nodes, race_row)    end
            if weapon_row  then table.insert(req_nodes, weapon_row)  end
            if faction_row then table.insert(req_nodes, faction_row) end

            return {
                vars     = stats,
                main_end = #req_nodes > 1 and req_nodes or nil
            }
        end,

        can_use = function(self, card)
            if card.area == G.pack_cards then
                return #G.consumeables.cards < G.consumeables.config.card_limit
            end
            if G.jokers.highlighted and #G.jokers.highlighted == 1 then
                return Warcraft.Equipment.can_attach(G.jokers.highlighted[1], card.config.center.key)
            end
        end,

        use = function(self, card, area)
            if area == G.pack_cards then
                local clone = copy_card(card, nil)
                clone.T.x = card.T.x
                clone.T.y = card.T.y
                clone:add_to_deck()
                G.consumeables:emplace(clone)
                card.states.visible = false
                return
            end
            local target = G.jokers.highlighted[1]
            Warcraft.Equipment.attach(target, card.config.center.key, 1) 
        end,

        calculate_equipment = function(self, joker_card, context, joker_result)
            local eq = joker_card.ability.wow_equipment
            local ilvl = eq.ilvl or 1
            local extra = eq.extra or self.config.extra
            
            local stats = args.calculate_stats(ilvl, extra)
            if type(stats) ~= "table" then stats = { stats } end
            
            return args.on_score(ilvl, context, joker_card, stats, extra)
        end
    }
end

-- Function to attach Equipment to a Warcraft Joker
function Warcraft.Equipment.attach(joker, equipment_key, starting_ilvl)
    local item_def = Warcraft.Equipment.items[equipment_key]
    local actual_ilvl = starting_ilvl or 1
    local is_combo = false
    local joker_name = joker.ability.name

    -- Combo Check
    if item_def and item_def.combo_joker then
        for _, combo_name in ipairs(item_def.combo_joker) do
            if joker_name == combo_name then
                local bonus = item_def.combo_bonus or 25
                actual_ilvl = actual_ilvl + bonus
                is_combo = true
                break
            end
        end
    end

    local base_extra = item_def.config and item_def.config.extra or {}
    local extra_copy = {}
    for k, v in pairs(base_extra) do extra_copy[k] = v end

    -- Apply Data
    joker.ability.wow_equipment = {
        key = equipment_key,
        ilvl = actual_ilvl,
        ilvl_gained_this_round = 0,
        last_round_ilvl_check = 0,
        extra = extra_copy
    }

    -- Fire on_equip callback if the joker defines one
    if joker.config.center.on_equip then
        joker.config.center.on_equip(joker.config.center, joker)
    end

    joker.extra_cost = (joker.extra_cost or 0) + 5
    joker:set_cost()
    joker.sell_cost = (joker.sell_cost or 0) + 5
    joker:calculate_joker({first_hand_drawn = true})
    
    Warcraft.sync_ui_elements(joker)

    local msg = is_combo and "COMBO!" or "Equipped!"
    local col = is_combo and G.C.PURPLE or G.C.GOLD
    
    card_eval_status_text(joker, 'extra', nil, nil, nil, {message = msg, colour = col})
    
    if is_combo then 
        play_sound('tarot1') 
        joker:juice_up() 
    end
end

-- Function used to know if an Equipment can be attached to the selected Joker
function Warcraft.Equipment.can_attach(joker, equipment_key)
    if not joker then return false end
    if joker.ability.wow_equipment then return false end 
    
    local item_def = Warcraft.Equipment.items[equipment_key]
    if not item_def then return true end

    local joker_name = joker.ability.name

    -- Check if is Combo Joker (Bypasses all other checks)
    if item_def.combo_joker then
        for _, combo_name in ipairs(item_def.combo_joker) do
            if joker_name == combo_name then
                return true
            end
        end
    end

    -- Check Level Requirement (Must be met if present)
    if item_def.req_level then
        local current_level = (joker.ability.extra and joker.ability.extra.level) or 1
        if current_level < item_def.req_level then
            return false
        end
    end

    -- Check if Class/Race/Faction/Weapon requirement is met (Any of them is enough to pass)
    local req_met = false
    
    -- Check Class
    local joker_class = (joker.ability.extra and joker.ability.extra.class) or "None"
    local joker_class_list = type(joker_class) == "table" and joker_class or { joker_class }

    for _, jc in ipairs(joker_class_list) do
        for _, valid_class in ipairs(item_def.req_class) do
            if valid_class == "Any" or valid_class == jc then
                req_met = true
                break
            end
        end
        if req_met then break end
    end

    -- Check Race
    if not req_met and item_def.req_race and #item_def.req_race > 0 then
        local joker_race = (joker.ability.extra and joker.ability.extra.race) or "Unknown"
        if type(joker_race) == "table" then
            for _, jr in ipairs(joker_race) do
                for _, valid_race in ipairs(item_def.req_race) do
                    if valid_race == jr then
                        req_met = true
                        break
                    end
                end
                if req_met then break end
            end
        else
            for _, valid_race in ipairs(item_def.req_race) do
                if valid_race == joker_race then
                    req_met = true
                    break
                end
            end
        end
    end

    -- Check Weapon
    if not req_met and item_def.req_weapon and #item_def.req_weapon > 0 then
        local joker_weapon = (joker.ability.extra and joker.ability.extra.weapon) or {"None"}
        if type(joker_weapon) ~= "table" then joker_weapon = {joker_weapon} end
        
        for _, jw in ipairs(joker_weapon) do
            for _, valid_weapon in ipairs(item_def.req_weapon) do
                if valid_weapon == jw then
                    req_met = true
                    break
                end
            end
            if req_met then break end
        end
    end

    -- Check Faction
    if not req_met and item_def.req_faction and #item_def.req_faction > 0 then
        local joker_faction = (joker.ability.extra and joker.ability.extra.faction) or {"Neutral"}
        if type(joker_faction) ~= "table" then joker_faction = {joker_faction} end
        
        for _, jf in ipairs(joker_faction) do
            for _, valid_faction in ipairs(item_def.req_faction) do
                if valid_faction == jf then
                    req_met = true
                    break
                end
            end
            if req_met then break end
        end
    end

    return req_met
end

-- Function to merge Equipment text into Jokers tooltips
function Warcraft.Equipment.generate_ui(card)
    if not (card and card.ability and card.ability.wow_equipment) then return nil end

    local full_equip_key = card.ability.wow_equipment.key
    local item_def = Warcraft.Equipment.items[full_equip_key]
    if not item_def then return nil end

    local equip_ilvl = card.ability.wow_equipment.ilvl or 1
    local extra = card.ability.wow_equipment.extra or (item_def.config and item_def.config.extra) or {}

    -- Helper: resolve color that may be a string key ("attention"), uppercase key ("ATTENTION"),
    -- or an already-resolved RGBA table. Never returns nil.
    local function resolve_colour(col, fallback)
        if type(col) == "table" then return col end
        if type(col) == "string" then
            return G.C[col] or G.C[col:upper()] or fallback or G.C.WHITE
        end
        return fallback or G.C.WHITE
    end

    -- Helper: extract text from a parsed part.
    -- loc_parse_string uses 'string' (singular) for tagged segments
    -- and 'strings' (plural/table) for plain segments.
    local function get_text(part)
        if part.strings then
            local safe = {}
            for _, s in ipairs(part.strings) do
                if type(s) == "string" then
                    table.insert(safe, s)
                end
            end
            return table.concat(safe)
        elseif part.string then
            return part.string
        end
        return ""
    end

    -- Calculate stats at current ilvl
    local stats = {}
    if item_def.get_ui_stats then
        stats = item_def.get_ui_stats(equip_ilvl, extra, card.ability.wow_equipment)
    elseif item_def.calculate_stats then
        stats = item_def.calculate_stats(equip_ilvl, extra)
    end
    if type(stats) ~= "table" then stats = { stats } end

    local equip_name = item_def.name or "Unknown Item"

    -- Build header: item name + ilvl
    local ui_nodes = {
        { n = G.UIT.B, config = { h = 0.1, w = 0.1 } },
        { n = G.UIT.R, config = { align = "cm" }, nodes = {
            { n = G.UIT.T, config = {
                text   = equip_name,
                colour = resolve_colour(item_def.name_colour, G.C.GOLD),
                scale  = 0.35,
                shadow = true
            }}
        }},
        { n = G.UIT.B, config = { h = 0.03, w = 0.1 } },
        { n = G.UIT.R, config = { align = "cm" }, nodes = {
            { n = G.UIT.T, config = {
                text   = "Ilvl " .. equip_ilvl,
                colour = G.C.BLUE,
                scale  = 0.32
            }}
        }},
        { n = G.UIT.B, config = { h = 0.05, w = 0.1 } }
    }

    -- Parse and render each line of loc_text
    local base_text = item_def.loc_text or { "Effect not found" }

    for _, line in ipairs(base_text) do
        local formatted_line = line
        for i, stat in ipairs(stats) do
            formatted_line = formatted_line:gsub("#" .. i .. "#", tostring(stat))
        end

        local parsed_data = loc_parse_string(formatted_line)
        local line_nodes = {}

        local default_col = G.C.UI.TEXT_DARK
        local current_col = default_col

        for _, part in ipairs(parsed_data) do
            local text_str = get_text(part)

            if part.control and part.control.X then
                text_str = text_str:gsub("%s+", "")
            end

            if #text_str > 0 then
                -- Has visible text: update color only if explicitly tagged
                -- If no C present, keep current_col (handles split parts like "s" after "10")
                if part.control and part.control.C then
                    current_col = resolve_colour(part.control.C, default_col)
                end
            else
                -- No text: this is a pure control marker (closing {})
                -- Reset color back to default
                current_col = default_col
            end

            if #text_str > 0 then
                local text_scale = 0.32
                if part.control and part.control.s then
                    text_scale = tonumber(part.control.s) or 0.32
                end

                local t_node = {
                    n = G.UIT.T,
                    config = {
                        text   = text_str,
                        colour = current_col,
                        scale  = text_scale
                    }
                }

                if part.control and part.control.X then
                    t_node = {
                        n = G.UIT.C,
                        config = {
                            align   = "cm",
                            colour  = resolve_colour(part.control.X),
                            r       = 0.05,
                            padding = 0.05
                        },
                        nodes = { t_node }
                    }
                end

                table.insert(line_nodes, t_node)
            end
        end

        if #line_nodes > 0 then
            table.insert(ui_nodes, {
                n = G.UIT.R,
                config = { align = "cm" },
                nodes = line_nodes
            })
        end
    end

    return ui_nodes
end