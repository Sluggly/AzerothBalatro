Warcraft.create_warcraft_joker({
    name = "Midnight",
    is_other = true,
    race = {"Beast", "Undead"},
    damage = {"Physical"},
    armor = {"Leather"},
    profession = {},
    combo = {"Attumen the Huntsman"},
    role = {"Tank"},
    rarity = 3,
    index = 1,
    config = { extra = { x_chips = 2, x_chips_per_level = 0.3, x_chips_per_ilvl = 0.2 } },
    loc_txt = {
        "{X:chips,C:white} X#1# {} Chips if played hand",
        "contains both a {C:attention}Face Card{}",
        "and a {C:attention}Non-Face Card{}.",
        "{C:inactive}(Summoned by Attumen){}"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.x_chips, card.ability.extra.x_chips_per_level, card.ability.extra.x_chips_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local has_face = false
            local has_non_face = false
            for _, v in ipairs(context.scoring_hand) do
                if v:is_face() then has_face = true
                else has_non_face = true end
            end
            if has_face and has_non_face then
                return {
                    x_chips = Warcraft.get_scaled_gain(card, card.ability.extra.x_chips, card.ability.extra.x_chips_per_level, card.ability.extra.x_chips_per_ilvl),
                    message = "Midnight!",
                    colour = G.C.DARK_EDITION,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Head of the Horseman",
    is_other = true,
    race = {"Undead"},
    damage = {"Fire"},
    armor = {"Plate"},
    profession = {},
    combo = {"Headless Horseman"},
    role = {"Tank"},
    rarity = 3,
    index = 2,
    config = { extra = { x_mult = 3, x_mult_per_level = 0.5, x_mult_per_ilvl = 0.3 } },
    loc_txt = {
        "Playing a {C:attention}Straight{} gives",
        "{X:mult,C:white} X#1# {} Mult and destroy this joker.",
        "When {C:red}destroyed{}, reattach to",
        "{C:attention}The Headless Horseman{}",
        "and give him {X:chips,C:white} X{}{X:mult,C:white} X{} bonuses.",
        "{C:inactive}(Summoned by The Headless Horseman){}"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl) }
    end,
    calculate = function(self, card, context)
        -- XMult on straights and Self-Destruct
        if context.joker_main then
            local hand = context.scoring_name
            if hand == "Straight" or hand == "Straight Flush" or hand == "Royal Flush" then
                
                -- Queue the destruction event
                G.E_MANAGER:add_event(Event({
                    func = function()
                        card:start_dissolve({remove_as_card = true})
                        return true
                    end
                }))
                
                return {
                    Xmult_mod = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
                    message = "PUMPKIN!",
                    colour = G.C.ORANGE,
                    card = card
                }
            end
        end

        -- Explicit destruction context from SMODS, perfect for catching standard/event destructions
        if context.joker_type_destroyed and context.card == card and not context.blueprint then
            G.E_MANAGER:add_event(Event({
                func = function()
                    -- Find The Headless Horseman with detached head
                    if G.jokers and G.jokers.cards then
                        for _, j in ipairs(G.jokers.cards) do
                            if j.ability and j.ability.name == "The Headless Horseman"
                            and j.ability.extra and j.ability.extra.head_detached then
                                -- Reattach
                                j.ability.extra.head_detached = false
                                j.ability.extra.discards_count = 0

                                -- Give bonus XChips and XMult
                                local x_chips_gain = Warcraft.get_scaled_gain(j, j.ability.extra.x_chips_gain, j.ability.extra.x_chips_gain_per_level, j.ability.extra.x_chips_gain_per_ilvl)
                                local x_mult_gain = Warcraft.get_scaled_gain(j, j.ability.extra.x_mult_gain, j.ability.extra.x_mult_gain_per_level, j.ability.extra.x_mult_gain_per_ilvl)
                                j.ability.extra.x_chips = j.ability.extra.x_chips + x_chips_gain
                                j.ability.extra.x_mult = j.ability.extra.x_mult + x_mult_gain

                                card_eval_status_text(j, 'extra', nil, nil, nil, {
                                    message = "Reattached!",
                                    colour = G.C.GREEN
                                })
                                j:juice_up()
                                break
                            end
                        end
                    end
                    return true
                end
            }))
        end
    end
})