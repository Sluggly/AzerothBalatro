Warcraft = Warcraft or {}
Warcraft.JokerRaces = Warcraft.JokerRaces or {}

-- Function to Level up a Joker
function Warcraft.attempt_level_up(card)
    if not card.ability or not card.ability.extra then return end
    if not card.ability.extra.level or not card.ability.extra.max_level then return end
    
    if card.ability.extra.level >= card.ability.extra.max_level then return end

    local current_round = G.GAME.round
    
    if card.ability.extra.last_blind_leveled == current_round then
        return 
    end

    card.ability.extra.level = card.ability.extra.level + 1
    
    card.ability.extra.last_blind_leveled = current_round

    card_eval_status_text(card, 'extra', nil, nil, nil, {
        message = "Level Up!",
        colour = G.C.GREEN
    })
    card:juice_up()
end

-- FACTORY : Create Warcraft Jokers
function Warcraft.create_warcraft_joker(args)
    local config = args.config or { extra = {} }

    config.extra.level = 1  
    config.extra.max_level = args.max_level or 10 
    config.extra.faction = args.faction or "Neutral"
    config.extra.race = args.race or "Unknown"
    config.extra.class = args.class or "None"
    config.extra.difficulty = args.difficulty or "Normal"
    config.extra.weapon = args.weapon or {"None"}
    config.extra.last_blind_leveled = args.last_blind_leveled or 0

    local first_race = type(args.race) == "table" and args.race[1] or args.race
    Warcraft.JokerRaces[args.name] = first_race

    local description_text = args.loc_txt or { "Effect not found." }
    table.insert(description_text, "{C:inactive}Level #11#/#12#{}")

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

        if not result.main_end and Warcraft.Equipment and Warcraft.Equipment.generate_ui then
            result.main_end = Warcraft.Equipment.generate_ui(card)
        end

        result.vars = final_vars
        
        return result
    end

    local atlas_key, atlas_pos = Warcraft.Atlas.get_pos("jokers", args.index or 1, false)

    local generated_key = Warcraft.secure_key(args.name)

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

        -- JOKER TRIGGER MEMORY
        if ret and (ret.mult or ret.chips or ret.x_mult or ret.message or ret.dollars or ret.mult_mod or ret.chip_mod or ret.Xmult_mod or ret.repetitions) then
            card.ability.triggered_this_hand = true
        end

        -- RUN EQUIPMENT LOGIC
        local equip_ret = nil
        if is_gameplay_context and card.ability.wow_equipment then
            local item_def = Warcraft.Equipment.items[card.ability.wow_equipment.key]
            
            -- ONLY trigger if the Joker triggered AND the Equipment hasn't triggered yet this hand
            if item_def and item_def.on_score and card.ability.triggered_this_hand and not card.ability.equip_triggered_this_hand then
                
                local ilvl = card.ability.wow_equipment.ilvl or 1
                local extra = card.ability.wow_equipment.extra or (item_def.config and item_def.config.extra) or {}
                local stats = item_def.calculate_stats and item_def.calculate_stats(ilvl, extra) or {}
                if type(stats) ~= "table" then stats = { stats } end

                equip_ret = item_def.on_score(ilvl, context, card, stats, extra, ret)
                
                if equip_ret then card.ability.equip_triggered_this_hand = true end
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
        cost = args.cost or 4,
        atlas = atlas_key, 
        pos = args.pos or atlas_pos,
        unlocked = true,
        discovered = true,
        config = config,
        is_warcraft = true,
        blueprint_compat = args.blueprint_compat or true,
        add_to_deck = args.add_to_deck,
        remove_from_deck = args.remove_from_deck,

        loc_txt = { name = args.name, text = description_text },

        loc_vars = new_loc_vars,

        calculate = new_calculate
    }
end