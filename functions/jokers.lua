Warcraft = Warcraft or {}
Warcraft.JokerRaces = Warcraft.JokerRaces or {}

-- Function to Level up a Joker
function Warcraft.attempt_level_up(card)
    if not card.ability or not card.ability.extra or type(card.ability.extra) ~= "table" then return end
    if not card.ability.extra.level or not card.ability.extra.max_level then return end
    if card.ability.extra.level >= card.ability.extra.max_level then return end

    local current_round = G.GAME.round
    if card.ability.extra.last_blind_leveled == current_round then return end

    card.ability.extra.level = card.ability.extra.level + 1
    card.ability.extra.last_blind_leveled = current_round

    card_eval_status_text(card, 'extra', nil, nil, nil, {
        message = "Level Up!",
        colour = G.C.GREEN
    })
    Warcraft.sync_ui_elements(card)
    card:juice_up()
end

-- FACTORY : Create Warcraft Jokers
function Warcraft.create_warcraft_joker(args)
    local is_other = args.is_other or false

    local config = args.config or { extra = {} }

    config.extra.level = 1  
    config.extra.max_level = args.max_level or 10 
    config.extra.faction = args.faction or {"Neutral"}
    config.extra.race = args.race or {"Unknown"}
    config.extra.class = args.class or {"None"}
    config.extra.weapon = args.weapon or {"None"}
    config.extra.damage = args.damage or {"Physical"}
    config.extra.armor = args.armor or {"Unarmored"}
    config.extra.profession = args.profession or {"None"}
    config.extra.combo = args.combo or {"None"}
    config.extra.role = args.role or {"Melee DPS"}

    config.extra.last_blind_leveled = args.last_blind_leveled or 0
    config.extra.is_other = is_other
    config.extra.combo_fulfilled = false

    local first_race = type(args.race) == "table" and args.race[1] or args.race
    Warcraft.JokerRaces[args.name] = first_race

    local description_text = args.loc_txt or { "Effect not found." }
    table.insert(description_text, "{C:inactive}Level #11#/#12#{}")

    -- =======================================
    -- SET_ABILITY (Called on Card Creation)
    -- =======================================
    local original_set_ability = args.set_ability
    local new_set_ability = function(self, card, initial, delay_sprites)
        if original_set_ability then 
            original_set_ability(self, card, initial, delay_sprites) 
        end
        
        -- If this is a newly generated card, pick a single active combo partner!
        if initial and card.ability and card.ability.extra then
            local ex = card.ability.extra
            if ex.combo and #ex.combo > 0 and ex.combo[1] ~= "None" then
                -- Ensure we only pick once so it persists across save/loads
                if not ex.active_combo then
                    local seed = "j_combo_" .. tostring(math.random())
                    ex.active_combo = pseudorandom_element(ex.combo, pseudoseed(seed))
                end
            end
        end
    end

    -- =======================================
    -- LOC_VARS (Tooltips and Badges)
    -- =======================================
    local original_loc_vars = args.loc_vars
    local new_loc_vars = function(self, info_queue, card)
        local result = {}
        
        if original_loc_vars then
            result = original_loc_vars(self, info_queue, card)
        end

        local final_vars = {}
        
        if result.vars then
            final_vars = result.vars
        else
            final_vars = result
            result = { vars = final_vars }
        end

        local lvl = (card.ability.extra and card.ability.extra.level) or 1
        local max_lvl = (card.ability.extra and card.ability.extra.max_level) or 10

        final_vars[11] = lvl
        final_vars[12] = max_lvl

        if Warcraft.Badges and Warcraft.Badges.append_tooltips then
            Warcraft.Badges.append_tooltips(info_queue, card)
        end

        local ex = card.ability.extra

        -- =======================================
        -- BUILD MAIN_END NODES (Combos + Equipment)
        -- =======================================
        local main_end_nodes = {}

        -- 1. Combo UI Bubble (Only if not fulfilled!)
        if ex and not ex.combo_fulfilled and ex.active_combo then
            -- INJECT OUR CRASH-SAFE MULTI-BOX SEPARATOR!
            table.insert(main_end_nodes, { n = G.UIT.B, config = { h = 0, w = 0, warcraft_box_separator = true } })

            local c_name = ex.active_combo
            table.insert(main_end_nodes, {
                n = G.UIT.R, config = { align = "cm" }, nodes = {
                    { n = G.UIT.T, config = { text = "Combo: ", colour = G.C.PURPLE, scale = 0.32 } },
                    { n = G.UIT.T, config = { text = c_name, colour = Warcraft.get_joker_color(c_name), scale = 0.32 } }
                }
            })
        end

        -- 2. Equipment UI
        if Warcraft.Equipment and Warcraft.Equipment.generate_ui then
            local eq_ui = Warcraft.Equipment.generate_ui(card)
            if eq_ui and #eq_ui > 0 then
                -- INJECT OUR CRASH-SAFE MULTI-BOX SEPARATOR!
                table.insert(main_end_nodes, { n = G.UIT.B, config = { h = 0, w = 0, warcraft_box_separator = true } })
                
                for _, n in ipairs(eq_ui) do table.insert(main_end_nodes, n) end
            end
        end

        if #main_end_nodes > 0 then
            result.main_end = main_end_nodes
        end

        return result
    end

    local atlas_type = is_other and "other_jokers" or "jokers"
    local atlas_key, atlas_pos = Warcraft.Atlas.get_pos(atlas_type, args.index or 1)
    local generated_key = Warcraft.secure_key(args.name)

    -- =======================================
    -- CALCULATE
    -- =======================================
    local original_calculate = args.calculate
    local new_calculate = function(self, card, context)
        local is_gameplay_context = false
        if context.joker_main or context.individual or context.discard or context.after or context.before or context.repetition then
            is_gameplay_context = true
        end

        -- RESET FLAGS: At the very start of the scoring process
        if context.before and not context.blueprint then
            card.ability.triggered_this_hand = false
            card.ability.equip_triggered_this_hand = false
        end

        local ret = nil
        if original_calculate then
            ret = original_calculate(self, card, context)
        end

        -- =======================================
        -- COMBO FULFILLMENT CHECK
        -- =======================================
        if context.card_added and not context.blueprint and card.ability.extra then
            local ex = card.ability.extra
            if not ex.combo_fulfilled and ex.active_combo then
                local partner_joker = nil
                
                -- We only look for the active_combo partner now!
                local function is_combo_partner(target_name)
                    return target_name == ex.active_combo
                end
                
                if context.card == card then
                    -- Case 1: WE were just added. Scan the board for our active partner!
                    if G.jokers and G.jokers.cards then
                        for _, j in ipairs(G.jokers.cards) do
                            if j ~= card and is_combo_partner(j.ability.name) then 
                                partner_joker = j
                                break 
                            end
                        end
                    end
                else
                    -- Case 2: Another Joker was just added. Is it our active partner?
                    if context.card and context.card.ability then
                        if is_combo_partner(context.card.ability.name) then 
                            partner_joker = context.card 
                        end
                    end
                end
                
                if partner_joker then
                    ex.combo_fulfilled = true
                    
                    -- 1. Apply +3 Max Level Cap to BOTH Jokers
                    ex.max_level = (ex.max_level or 10) + 3
                    
                    if partner_joker.ability and type(partner_joker.ability.extra) == "table" then
                        partner_joker.ability.extra.max_level = (partner_joker.ability.extra.max_level or 10) + 3
                        -- Sync the partner's UI instantly
                        if Warcraft.sync_ui_elements then Warcraft.sync_ui_elements(partner_joker) end
                    end
                    
                    -- Sync our own UI instantly
                    if Warcraft.sync_ui_elements then Warcraft.sync_ui_elements(card) end
                    
                    -- 2. Spawn the spell safely
                    local dmg_list = type(ex.damage) == "table" and ex.damage or {ex.damage}
                    local spell_key = Warcraft.get_random_spell_for_damage(dmg_list, "combo_" .. G.GAME.round .. card.config.center.key)
                    
                    if spell_key and G.consumeables and #G.consumeables.cards < G.consumeables.config.card_limit then
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                local spell = create_card('Spell', G.consumeables, nil, nil, nil, nil, spell_key, 'combo_reward')
                                spell:add_to_deck()
                                G.consumeables:emplace(spell)
                                
                                card_eval_status_text(card, 'extra', nil, nil, nil, {
                                    message = "Combo! +3 Max Cap",
                                    colour = G.C.PURPLE
                                })
                                
                                -- Visually juice BOTH cards so the player sees the connection!
                                card:juice_up()
                                if partner_joker and partner_joker.juice_up then
                                    partner_joker:juice_up()
                                end
                                
                                return true
                            end
                        }))
                    end
                end
            end
        end

        -- JOKER TRIGGER MEMORY
        if ret and (ret.mult or ret.chips or ret.x_mult or ret.message or ret.dollars or ret.mult_mod or ret.chip_mod or ret.Xmult_mod or ret.repetitions) then
            card.ability.triggered_this_hand = true
        end

        -- RUN EQUIPMENT LOGIC
        local equip_ret = nil
        if is_gameplay_context and card.ability.wow_equipment then
            if not context.repetition then
                local item_def = Warcraft.Equipment.items[card.ability.wow_equipment.key]
                
                -- ONLY trigger if the Joker triggered AND the Equipment hasn't triggered yet this hand
                local equip_can_trigger = card.ability.triggered_this_hand and (item_def.per_card or not card.ability.equip_triggered_this_hand)

                if item_def and item_def.on_score and equip_can_trigger then
                    
                    local ilvl = card.ability.wow_equipment.ilvl or 1
                    local extra = card.ability.wow_equipment.extra or (item_def.config and item_def.config.extra) or {}
                    local stats = item_def.calculate_stats and item_def.calculate_stats(ilvl, extra) or {}
                    if type(stats) ~= "table" then stats = { stats } end

                    equip_ret = item_def.on_score(ilvl, context, card, stats, extra, ret)
                    
                    if equip_ret then
                        card.ability.equip_triggered_this_hand = true
                        SMODS.calculate_context({ equipment_trigger = true, equipment_source = card })
                    end
                end
            end
        end

        if equip_ret then
            ret = ret or {}
            if equip_ret.mult then ret.mult = (ret.mult or 0) + equip_ret.mult; equip_procd = true end
            if equip_ret.chips then ret.chips = (ret.chips or 0) + equip_ret.chips; equip_procd = true end
            if equip_ret.x_mult then ret.x_mult = (ret.x_mult or 0) + equip_ret.x_mult; equip_procd = true end
            if equip_ret.mult_mod then ret.mult_mod = (ret.mult_mod or 0) + equip_ret.mult_mod; equip_procd = true end
            if equip_ret.chip_mod then ret.chip_mod = (ret.chip_mod or 0) + equip_ret.chip_mod; equip_procd = true end
            if equip_ret.Xmult_mod then ret.Xmult_mod = (ret.Xmult_mod or 0) + equip_ret.Xmult_mod; equip_procd = true end
            if equip_ret.dollars then ret.dollars = (ret.dollars or 0) + equip_ret.dollars; equip_procd = true end
            if equip_ret.repetitions then ret.repetitions = (ret.repetitions or 0) + equip_ret.repetitions; equip_procd = true end
            
            if equip_ret.message then 
                ret.message = equip_ret.message 
                ret.colour = equip_ret.colour or G.C.GOLD
                equip_procd = true
            end
            
            if not ret.card then ret.card = card end
        end

        if ret then Warcraft.attempt_level_up(card) end
        if equip_ret then Warcraft.attempt_ilvl_up(card) end

        return ret
    end

    SMODS.Joker {
        key = args.key or generated_key,
        name = args.name,
        rarity = args.rarity or 1,
        cost = is_other and 0 or (args.cost or 4),
        atlas = atlas_key, 
        pos = args.pos or atlas_pos,
        unlocked = true,
        discovered = true,
        in_pool = function(self, pool_args)
            if is_other then return false end
            if args.in_pool then return args.in_pool(self, pool_args) end
            return true
        end,
        config = config,
        is_warcraft = true,
        blueprint_compat = args.blueprint_compat ~= false,
        add_to_deck = args.add_to_deck,
        remove_from_deck = args.remove_from_deck,
        set_ability = new_set_ability,
        loc_txt = { name = args.name, text = description_text },
        loc_vars = new_loc_vars,
        calculate = new_calculate
    }
end