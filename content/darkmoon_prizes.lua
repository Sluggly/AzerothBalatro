-- content/darkmoon_prizes.lua

SMODS.ConsumableType({
    key = "DarkmoonPrize",
    primary_colour = G.C.PURPLE,
    secondary_colour = G.C.GOLD,
    loc_txt = {
        name = "Darkmoon Prize",
        collection = "Darkmoon Prizes"
    },
    -- Prevent from spawning in shops or packs naturally
    no_pool_flag = true,
})

-- Prize 1: Level up a Joker
SMODS.Consumable({
    set = "DarkmoonPrize",
    key = "prize_level",
    name = "Darkmoon Prize: Level",
    loc_txt = {
        name = "Prize: Level Up",
        text = {
            "Give {C:attention}+2 Levels{}",
            "to a selected {C:attention}Joker{}"
        }
    },
    config = { extra = { levels = 2 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.levels } }
    end,
    can_use = function(self, card)
        return #G.jokers.cards > 0
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            func = function()
                -- Open joker selection
                G.FUNCS.use_card({config = {ref_table = card}})
                return true
            end
        }))
    end,
    select_target = function(self, card, target)
        if target and target.ability and target.ability.extra then
            local levels = card.ability.extra.levels
            target.ability.extra.level = (target.ability.extra.level or 1) + levels
            if target.ability.extra.max_level and target.ability.extra.level > target.ability.extra.max_level then
                target.ability.extra.max_level = target.ability.extra.level
            end
            card_eval_status_text(target, 'extra', nil, nil, nil, {
                message = "Level Up!",
                colour = G.C.PURPLE
            })
            target:juice_up()
        end
    end
})

-- Prize 2: ILvl up a Joker
SMODS.Consumable({
    set = "DarkmoonPrize",
    key = "prize_ilvl",
    name = "Darkmoon Prize: Ilvl",
    loc_txt = {
        name = "Prize: Item Level",
        text = {
            "Give {C:attention}+5 Ilvl{}",
            "to a selected {C:attention}Joker's Equipment{}"
        }
    },
    config = { extra = { ilvl = 5 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.ilvl } }
    end,
    can_use = function(self, card)
        for _, j in ipairs(G.jokers.cards) do
            if j.ability.wow_equipment then return true end
        end
        return false
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            func = function()
                G.FUNCS.use_card({config = {ref_table = card}})
                return true
            end
        }))
    end,
    select_target = function(self, card, target)
        if target and target.ability and target.ability.wow_equipment then
            target.ability.wow_equipment.ilvl = (target.ability.wow_equipment.ilvl or 0) + card.ability.extra.ilvl
            target.ability.wow_equipment.ilvl_gained_this_round = 0
            card_eval_status_text(target, 'extra', nil, nil, nil, {
                message = "+" .. card.ability.extra.ilvl .. " Ilvl!",
                colour = G.C.GOLD
            })
            target:juice_up()
        end
    end
})

-- Prize 3: Joker Slot
SMODS.Consumable({
    set = "DarkmoonPrize",
    key = "prize_joker_slot",
    name = "Darkmoon Prize: Collection",
    loc_txt = {
        name = "Prize: Collection",
        text = {
            "{C:green}1 in 2{} chance to",
            "permanently gain",
            "{C:attention}+1 Joker Slot{}"
        }
    },
    config = {},
    can_use = function(self, card)
        return true
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            func = function()
                if pseudorandom('dmf_joker_slot') < 0.5 then
                    G.jokers.config.card_limit = G.jokers.config.card_limit + 1
                    card_eval_status_text(card, 'extra', nil, nil, nil, {
                        message = "+1 Joker Slot!",
                        colour = G.C.PURPLE
                    })
                else
                    card_eval_status_text(card, 'extra', nil, nil, nil, {
                        message = "No Luck...",
                        colour = G.C.RED
                    })
                end
                return true
            end
        }))
    end
})

-- Prize 4: Hand Size
SMODS.Consumable({
    set = "DarkmoonPrize",
    key = "prize_hand_size",
    name = "Darkmoon Prize: Hands",
    loc_txt = {
        name = "Prize: Hand Size",
        text = {
            "{C:green}1 in 2{} chance to",
            "permanently gain",
            "{C:attention}+1 Hand Size{}"
        }
    },
    config = {},
    can_use = function(self, card)
        return true
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            func = function()
                if pseudorandom('dmf_hand_size') < 0.5 then
                    G.hand:change_size(1)
                    card_eval_status_text(card, 'extra', nil, nil, nil, {
                        message = "+1 Hand Size!",
                        colour = G.C.BLUE
                    })
                else
                    card_eval_status_text(card, 'extra', nil, nil, nil, {
                        message = "No Luck...",
                        colour = G.C.RED
                    })
                end
                return true
            end
        }))
    end
})

-- Prize 5: Hands per round
SMODS.Consumable({
    set = "DarkmoonPrize",
    key = "prize_hands",
    name = "Darkmoon Prize: Strategy",
    loc_txt = {
        name = "Prize: Strategy",
        text = {
            "{C:green}1 in 2{} chance to",
            "permanently gain",
            "{C:attention}+1 Hand{} per round"
        }
    },
    config = {},
    can_use = function(self, card)
        return true
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            func = function()
                if pseudorandom('dmf_hands') < 0.5 then
                    G.GAME.round_resets.hands = G.GAME.round_resets.hands + 1
                    G.GAME.current_round.hands_left = G.GAME.current_round.hands_left + 1
                    card_eval_status_text(card, 'extra', nil, nil, nil, {
                        message = "+1 Hand!",
                        colour = G.C.BLUE
                    })
                else
                    card_eval_status_text(card, 'extra', nil, nil, nil, {
                        message = "No Luck...",
                        colour = G.C.RED
                    })
                end
                return true
            end
        }))
    end
})

-- Prize 6: Discards per round
SMODS.Consumable({
    set = "DarkmoonPrize",
    key = "prize_discards",
    name = "Darkmoon Prize: Discard",
    loc_txt = {
        name = "Prize: Discard",
        text = {
            "{C:green}1 in 2{} chance to",
            "permanently gain",
            "{C:attention}+1 Discard{} per round"
        }
    },
    config = {},
    can_use = function(self, card)
        return true
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            func = function()
                if pseudorandom('dmf_discards') < 0.5 then
                    G.GAME.round_resets.discards = G.GAME.round_resets.discards + 1
                    G.GAME.current_round.discards_left = G.GAME.current_round.discards_left + 1
                    card_eval_status_text(card, 'extra', nil, nil, nil, {
                        message = "+1 Discard!",
                        colour = G.C.RED
                    })
                else
                    card_eval_status_text(card, 'extra', nil, nil, nil, {
                        message = "No Luck...",
                        colour = G.C.RED
                    })
                end
                return true
            end
        }))
    end
})