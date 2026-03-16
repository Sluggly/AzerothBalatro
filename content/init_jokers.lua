sendDebugMessage("Azeroth Balatro Mod : Generating all Jokers...")
Warcraft.create_warcraft_joker({
    name = "Archimonde",
    faction = {"Legion"},
    race = {"Demon", "Draenei"},
    class = {"Warlock"},
    weapon = {"Fist", "Hammer"},
    rarity = 3,
    cost = 8,
    index = 1,
    config = { extra = { x_mult = 1, x_mult_gain = 0.15 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "Gains {X:mult,C:white} X#2# {} Mult when a",
        "{C:red}Demon{} or {C:red}Legion{} Joker",
        "is {C:attention}acquired{} or {C:attention}sold{}"
    },
    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult, card.ability.extra.x_mult_gain }
    end,

    add_to_deck = function(self, card, from_debuff)
        if not G.jokers then return end
        local count = 0
        for _, j in ipairs(G.jokers.cards) do
            if j ~= card and Warcraft.is_demon_or_legion(j) then
                count = count + 1
            end
        end
        if count > 0 then
            card.ability.extra.x_mult = card.ability.extra.x_mult + (count * card.ability.extra.x_mult_gain)
            card_eval_status_text(card, 'extra', nil, nil, nil, {
                message = "Burning Legion!",
                colour = G.C.RED
            })
        end
    end,

    calculate = function(self, card, context)
        if context.playing_card_added and not context.blueprint then
            local added = context.card
            if added and added ~= card and Warcraft.is_demon_or_legion(added) then
                card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.x_mult_gain
                return { message = "Burning Legion!", colour = G.C.RED, card = card }
            end
        end

        if context.selling_card and not context.blueprint then
            local sold = context.card
            if sold and sold ~= card and Warcraft.is_demon_or_legion(sold) then
                card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.x_mult_gain
                return { message = "Burning Legion!", colour = G.C.RED, card = card }
            end
        end

        if context.joker_main then
            if card.ability.extra.x_mult > 1 then
                return { Xmult_mod = card.ability.extra.x_mult, colour = G.C.RED }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Ragnaros",
    race = {"Elemental"},
    class = {"Shaman"},
    weapon = {"Hammer"},
    rarity = 3,
    cost = 8,
    index = 2,
    
    loc_txt = {
        "When hand is played,",
        "destroy {C:attention}#1# random card{} in hand.",
        "If a card is destroyed, gain",
        "{C:mult}+#2#{} Mult for this hand"
    },

    config = { extra = { destroy = 1, mult = 8 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.destroy, card.ability.extra.mult }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            if G.hand and G.hand.cards and #G.hand.cards > 0 then
                local random_index = pseudorandom('ragnaros') * (#G.hand.cards)
                random_index = math.ceil(random_index)
                
                local target_card = G.hand.cards[random_index]
                
                if target_card and not target_card.shattered then
                    target_card:start_dissolve()
                    return {
                        message = "BY FIRE BE PURGED!",
                        mult_mod = 8,
                        colour = G.C.RED
                    }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Illidan Stormrage",
    faction = {"Alliance", "Legion"},
    race = {"Night Elf", "Demon"},
    class = {"Demon Hunter"},
    weapon = {"Glaives"},
    rarity = 1,
    cost = 5,
    index = 3,
    config = { extra = { x_mult = 1.5, x_mult_gain = 0.1 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "Gains {X:mult,C:white} X#2# {} Mult,",
        "a {C:attention}Level{} and {C:attention}Ilvl{}",
        "each time a {C:spectral}Spectral{} card is used"
    },
    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult, card.ability.extra.x_mult_gain }
    end,
    calculate = function(self, card, context)
        if context.using_consumeable and not context.blueprint then
            if context.consumeable.ability.set == "Spectral" then
                card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.x_mult_gain

                -- Level up (bypass cap)
                if card.ability.extra.level then
                    card.ability.extra.level = card.ability.extra.level + 1
                    if card.ability.extra.max_level and
                       card.ability.extra.level > card.ability.extra.max_level then
                        card.ability.extra.max_level = card.ability.extra.level
                    end
                end

                -- Ilvl up (bypass cap)
                if card.ability.wow_equipment then
                    local eq = card.ability.wow_equipment
                    eq.ilvl = (eq.ilvl or 1) + 1
                    eq.ilvl_gained_this_round = 0
                end

                return {
                    message = "You are not prepared!",
                    colour = G.C.PURPLE,
                    card = card
                }
            end
        end

        if context.joker_main then
            if card.ability.extra.x_mult > 1 then
                return {
                    Xmult_mod = card.ability.extra.x_mult,
                    colour = G.C.PURPLE
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Thrall",
    faction = {"Horde"},
    race = {"Orc"},
    class = {"Shaman"},
    weapon = {"Hammer","Axe"},
    rarity = 3,
    cost = 8,
    index = 4,
    
    loc_txt = {
        "If played hand contains",
        "{C:attention}#1# different suits{}:",
        "Give played cards a random",
        "{C:attention}Enhancement{} and {C:dark_edition}Edition{}",
        "{C:inactive}(If they don't have one){}"
    },

    config = { extra = { suits = 4 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.suits }
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local suits_found = {}
            local unique_count = 0
            
            if context.scoring_hand then
                for _, scoring_card in ipairs(context.scoring_hand) do
                    if scoring_card.base.suit and not suits_found[scoring_card.base.suit] then
                        suits_found[scoring_card.base.suit] = true
                        unique_count = unique_count + 1
                    end
                end
            end

            if unique_count >= 4 then
                local triggered = false
                
                for _, played_card in ipairs(context.full_hand) do
                    if played_card.config.center.set == 'Default' then
                        local enhancement = pseudorandom_element(G.P_CENTER_POOLS.Enhanced, pseudorandom('thrall_enhance'))
                        played_card:set_ability(G.P_CENTERS[enhancement.key])
                        triggered = true
                    end

                    if not played_card.edition then
                        local edition = poll_edition('thrall_edition', nil, true, true)
                        if edition then
                            played_card:set_edition(edition, true)
                            triggered = true
                        end
                    end
                end

                if triggered then
                    return {
                        message = "Elements Guide Me!",
                        colour = G.C.BLUE
                    }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Arthas Menethil",
    faction = {"Alliance","Scourge"},
    race = {"Human","Undead"},
    class = {"Paladin","Death Knight"},
    weapon = {"Sword","Hammer"},
    rarity = 2,
    cost = 6,
    index = 5,
    
    mult = 0,

    loc_txt = {
        "If played hand contains {C:attention}no Face Cards{}:",
        "Destroy all scored cards and",
        "gain {C:mult}+#1#{} Mult",
        "{C:inactive}(Currently {C:mult}+#2#{C:inactive} Mult){}"
    },

    config = { extra = { mult = 0, mult_gain = 3 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.mult_gain, card.ability.extra.mult }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local face_card_found = false
            if context.scoring_hand then
                for _, scoring_card in ipairs(context.scoring_hand) do
                    if scoring_card:is_face() then
                        face_card_found = true
                        break
                    end
                end
            end

            if not face_card_found then
                local cards_to_destroy = {}
                if context.scoring_hand then
                    for _, scoring_card in ipairs(context.scoring_hand) do
                        if not scoring_card.dissolving then
                            table.insert(cards_to_destroy, scoring_card)
                        end
                    end
                end

                if #cards_to_destroy > 0 then
                    card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain

                    G.E_MANAGER:add_event(Event({
                        func = function()
                            for _, sc in ipairs(cards_to_destroy) do
                                sc:start_dissolve({remove_as_card = true})
                            end
                            return true
                        end
                    }))

                    return {
                        message = "Purged!",
                        mult_mod = card.ability.extra.mult,
                        colour = G.C.RED,
                        card = card
                    }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Malfurion Stormrage",
    faction = {"Alliance"},
    race = {"Night Elf"},
    class = {"Druid"},
    weapon = {"Staff","Fist Weapons"},
    rarity = 3,
    cost = 8,
    index = 6,
    
    loc_txt = {
        "{C:attention}+#1#{} Hand Size, {C:blue}+#2#{} Hand,",
        "{C:red}+#3#{} Discard",
        "If played hand is a {C:attention}Flush{},",
        "increase sell value of",
        "{C:attention}leftmost Joker{} by {C:money}$#4#{}"
    },

    config = { extra = { h_size = 1, hand = 1, discard = 1, money = 2 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.h_size, card.ability.extra.hand, card.ability.extra.discard, card.ability.extra.money }
    end,

    add_to_deck = function(self, card, from_debuff)
        G.hand.config.card_limit = G.hand.config.card_limit + card.ability.extra.h_size
        G.GAME.round_resets.hands = G.GAME.round_resets.hands + card.ability.extra.hand
        G.GAME.round_resets.discards = G.GAME.round_resets.discards + card.ability.extra.discard
    end,

    remove_from_deck = function(self, card, from_debuff)
        G.hand.config.card_limit = G.hand.config.card_limit - card.ability.extra.h_size
        G.GAME.round_resets.hands = G.GAME.round_resets.hands - card.ability.extra.hand
        G.GAME.round_resets.discards = G.GAME.round_resets.discards - card.ability.extra.discard
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            if context.scoring_name == "Flush" then
                if G.jokers.cards[1] then
                    local target = G.jokers.cards[1]

                    target.ability.extra_value = (target.ability.extra_value or 0) + card.ability.extra.money
                    target:set_cost()
                    
                    card_eval_status_text(target, 'extra', nil, nil, nil, {message = "+$ Value", colour = G.C.MONEY})
                    
                    return {
                        message = "Wild Growth!",
                        colour = G.C.GREEN
                    }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Anduin Wrynn",
    faction = {"Alliance"},
    race = {"Human"},
    class = {"Priest"},
    weapon = {"Sword","Hammer"},
    rarity = 3,
    cost = 8,
    index = 7,
    
    loc_txt = {
        "{C:attention}Boss Blinds{} have no effect",
        "{C:red}-#1#{} Discards"
    },

    config = { extra = { discard = 2 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.discard }
    end,

    add_to_deck = function(self, card, from_debuff)
        G.GAME.round_resets.discards = G.GAME.round_resets.discards - card.ability.extra.discard
    end,

    remove_from_deck = function(self, card, from_debuff)
        G.GAME.round_resets.discards = G.GAME.round_resets.discards + card.ability.extra.discard
    end,

    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            if G.GAME.blind and G.GAME.blind.boss and not G.GAME.blind.disabled then
                G.GAME.blind:disable()
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Silenced!", colour = G.C.BLUE})
            end
        end
        
        if context.first_hand_drawn and not context.blueprint then
             if G.GAME.blind and G.GAME.blind.boss and not G.GAME.blind.disabled then
                G.GAME.blind:disable()
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Silenced!", colour = G.C.BLUE})
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Magtheridon",
    faction = {"Legion"},
    race = {"Demon"},
    class = {"Warrior"},
    weapon = {"Glaives","Polearm"},
    rarity = 3,
    cost = 8,
    index = 8,

    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "{C:red}$#2#{} when hand is played"
    },

    config = { extra = { x_mult = 4, money = -3 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult, card.ability.extra.money }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            ease_dollars(card.ability.extra.money)
            
            card_eval_status_text(card, 'extra', nil, nil, nil, {
                message = "-$", 
                colour = G.C.RED
            })

            return {
                message = "My Blood Is Yours!",
                Xmult_mod = card.ability.extra.x_mult,
                colour = G.C.MULT
            }
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Kel'Thuzad",
    faction = {"Scourge"},
    race = {"Human"},
    class = {"Mage","Warlock"},
    weapon = {"Staff"},
    rarity = 1,
    cost = 4,
    index = 9,
    config = { extra = { stone_count = 5 } },
    loc_txt = {
        "When a blind starts, add",
        "{C:attention}#1#{} temporary {C:attention}Stone Cards{}",
        "to your hand"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_stone
        return { card.ability.extra.stone_count }
    end,
    calculate = function(self, card, context)
        if context.start_of_round and not context.blueprint then
            G.E_MANAGER:add_event(Event({
                func = function()
                    for i = 1, card.ability.extra.stone_count do
                        local new_card = create_card('Base', G.hand, nil, nil, nil, nil, nil, 'kelthuzad')
                        new_card:set_ability(G.P_CENTERS.m_stone)
                        new_card.is_temporary = true
                        new_card:add_to_deck()
                        table.insert(G.playing_cards, new_card)
                        G.hand:emplace(new_card)
                        new_card:juice_up()
                    end
                    return true
                end
            }))
            return {
                message = "Rise, Minions!",
                colour = G.C.GREY,
                card = card
            }
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Anub'Arak",
    faction = {"Scourge"}, 
    race = {"Undead"},
    weapon = {"Fist"},
    rarity = 3,
    cost = 8,
    index = 10,

    loc_txt = {
        "Played {C:attention}Spades{} return to",
        "your deck after scoring"
    },

    calculate = function(self, card, context)
        if context.destroying_card and not context.blueprint then
            
            local card_to_save = context.destroying_card

            if card_to_save:is_suit("Spades") and not card_to_save.shattered then
                
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local new_card = copy_card(card_to_save, nil, nil, G.playing_card)
                        
                        new_card:add_to_deck()
                        table.insert(G.playing_cards, new_card)
                        
                        G.deck:emplace(new_card)
                        G.deck:shuffle('anub')
                        
                        return true
                    end
                }))

                return {
                    remove = true, 
                    message = "Burrow!",
                    colour = G.C.BLACK
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Kil'Jaeden",
    faction = {"Legion"},
    race = {"Demon"}, 
    class = {"Warlock"},
    weapon = {"Fist"},
    rarity = 1,
    cost = 8,
    index = 11,

    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "{C:red}Destroys the highest rank{}",
        "{C:red}card{} in played hand"
    },

    config = { extra = { x_mult = 3 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            
            local target_card = nil
            local max_rank = -1

            if context.full_hand then
                for _, played_card in ipairs(context.full_hand) do
                    if played_card:get_id() > max_rank and not played_card.shattered then
                        max_rank = played_card:get_id()
                        target_card = played_card
                    end
                end
            end

            if target_card then
                target_card.shattered = true
                target_card:start_dissolve()
                
                card_eval_status_text(target_card, 'extra', nil, nil, nil, {
                    message = "Consumed!", 
                    colour = G.C.RED
                })
            end

            return {
                message = "The Deceiver!",
                Xmult_mod = card.ability.extra.x_mult,
                colour = G.C.RED
            }
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Sylvanas Windrunner",
    faction = {"Horde"},
    race = {"Undead","Blood Elf"},
    class = {"Hunter"},
    weapon = {"Bow","Sword","Daggers"},
    rarity = 2,
    cost = 5,
    index = 12,

    loc_txt = {
        "If played hand contains a {C:attention}Face Card{}:",
        "{C:red}Destroy it{}, then create a",
        "{C:attention}Stone Card{} in your hand",
        "{C:inactive}(Max #1# per hand){}"
    },

    config = { extra = { max = 1 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.max }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            
            local target_card = nil
            
            if context.scoring_hand then
                for _, played_card in ipairs(context.scoring_hand) do
                    if played_card:is_face() and not played_card.shattered then
                        target_card = played_card
                        break
                    end
                end
            end

            if target_card then
                target_card.shattered = true
                target_card:start_dissolve()

                G.E_MANAGER:add_event(Event({
                    func = function()
                        local new_card = create_card('Base', G.hand, nil, nil, nil, nil, nil, nil)
                        
                        new_card:set_ability(G.P_CENTERS.m_stone)
                        
                        new_card:add_to_deck()
                        table.insert(G.playing_cards, new_card)
                        
                        G.hand:emplace(new_card)
                        new_card:juice_up()
                        
                        return true
                    end
                }))

                return {
                    message = "For the Forsaken!",
                    colour = G.C.PURPLE
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Khadgar",
    faction = {"Alliance"},
    race = {"Human"},
    class = {"Mage"},
    weapon = {"Staff"},
    rarity = 2,
    cost = 4,
    index = 13,
    config = { extra = {} },
    loc_txt = {
        "Each time a playing card is",
        "added to your deck,",
        "add an additional copy"
    },
    loc_vars = function(self, info_queue, card)
        return {}
    end,
    calculate = function(self, card, context)
        if context.playing_card_added and not context.blueprint then
            local added = context.card
            if added and not added.is_temporary then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local copy = copy_card(added)
                        copy:add_to_deck()
                        table.insert(G.playing_cards, copy)
                        G.deck:emplace(copy)
                        copy:juice_up()
                        return true
                    end
                }))
                return {
                    message = "Duplicate!",
                    colour = G.C.PURPLE,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Jaina Proudmoore",
    faction = {"Alliance"},
    race = {"Human"},
    class = {"Mage"},
    weapon = {"Staff"},
    rarity = 2,
    cost = 8,
    index = 14, 

    loc_txt = {
        "Played {C:attention}Glass Cards{} do not shatter.",
        "Played {C:clubs}Clubs{} give {C:chips}+#1#{} Chips",
        "and have a {C:green}#2# in #3#{} chance to",
        "become {C:attention}Glass Cards{}"
    },

    config = { extra = { chips = 20, base_chance = 1, max_chance = 4 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.chips, card.ability.extra.base_chance, card.ability.extra.max_chance }
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            if context.scoring_hand then
                for _, played_card in ipairs(context.scoring_hand) do
                    if played_card.config.center.key == 'm_glass' then
                        played_card.ability.original_glass_extra = played_card.ability.extra
                        played_card.ability.extra = 1000000
                    end
                end
            end
        end

        if context.after and not context.blueprint then
            if context.scoring_hand then
                for _, played_card in ipairs(context.scoring_hand) do
                    if played_card.config.center.key == 'm_glass' and played_card.ability.original_glass_extra then
                        played_card.ability.extra = played_card.ability.original_glass_extra
                        played_card.ability.original_glass_extra = nil
                    end
                end
            end
        end

        if context.individual and context.cardarea == G.play then
            if context.other_card:is_suit("Clubs") then
                local transformed = false
                
                if context.other_card.config.center.key ~= 'm_glass' then
                    if pseudorandom('jaina_frost') < (card.ability.extra.base_chance / card.ability.extra.max_chance) then
                        transformed = true
                        
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                context.other_card:set_ability(G.P_CENTERS.m_glass)
                                context.other_card:juice_up()
                                
                                context.other_card.ability.original_glass_extra = context.other_card.ability.extra
                                context.other_card.ability.extra = 1000000
                                return true
                            end
                        }))
                    end
                end

                return {
                    chips = card.ability.extra.chips,
                    card = context.other_card,
                    message = transformed and "Frozen!" or "Frost!",
                    colour = G.C.CHIPS
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Millhouse Manastorm",
    race = {"Gnome"},
    class = {"Mage"},
    weapon = {"Staff","Daggers"},
    rarity = 3,
    cost = 8,
    index = 15,

    loc_txt = {
        "Everything in the Shop costs {C:money}$#1#{}.",
        "You cannot gain {C:attention}Interest{}.",
        "You cannot {C:attention}Reroll{} the Shop."
    },

    config = { extra = { max_cost = 1 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.max_cost }
    end,

    add_to_deck = function(self, card, from_debuff)
        card.ability.extra_old_discount = G.GAME.discount_percent
        G.GAME.discount_percent = 100
        
        card.ability.extra_old_cap = G.GAME.interest_cap
        G.GAME.interest_cap = 0

        card.ability.extra_old_reroll = G.GAME.current_round.reroll_cost
        G.GAME.current_round.reroll_cost = 10000000
    end,

    remove_from_deck = function(self, card, from_debuff)
        if card.ability.extra_old_discount then
            G.GAME.discount_percent = card.ability.extra_old_discount
        else
            G.GAME.discount_percent = 0
        end

        if card.ability.extra_old_cap then
            G.GAME.interest_cap = card.ability.extra_old_cap
        else
            G.GAME.interest_cap = 5
        end

        G.GAME.current_round.reroll_cost = G.GAME.round_resets.reroll_cost or 5
    end,

    calculate = function(self, card, context)
        if context.setting_blind or context.reroll_shop or context.end_of_round then
            
            if G.shop_booster then
                for k, v in pairs(G.shop_booster.cards) do
                    v.cost = 0
                    v:set_cost()
                end
            end
            
            if G.shop_jokers then
                for k, v in pairs(G.shop_jokers.cards) do
                    v.cost = 0
                    v:set_cost()
                end
            end

            G.GAME.current_round.reroll_cost = 10000000
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Grom Hellscream",
    faction = {"Horde"},
    race = {"Orc"},
    class = {"Warrior"},
    weapon = {"Axe"},
    rarity = 2,
    cost = 7,
    index = 16,

    loc_txt = {
        "{C:mult}+#1#{} Mult for every",
        "{C:attention}Discard{} remaining"
    },

    config = { extra = { mult = 4 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.mult }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local discards = G.GAME.current_round.discards_left
            local mult_gain = discards * card.ability.extra.mult

            if mult_gain > 0 then
                return {
                    message = "For the Warsong!",
                    mult_mod = mult_gain,
                    colour = G.C.MULT
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Rexxar",
    faction = {"Horde"},
    race = {"Orc","Ogre"},
    class = {"Hunter"},
    weapon = {"Axe"},
    rarity = 1,
    cost = 8,
    index = 17,

    loc_txt = {
        "{C:mult}+#1#{} Mult for each",
        "{C:attention}Wild Card{} in your",
        "full deck"
    },

    config = { extra = { mult = 10 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.mult }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local wild_count = 0
            
            if G.playing_cards then
                for _, v in ipairs(G.playing_cards) do
                    if v.config.center.key == 'm_wild' then
                        wild_count = wild_count + 1
                    end
                end
            end

            local bonus_mult = wild_count * card.ability.extra.mult

            if bonus_mult > 0 then
                return {
                    message = "Hunt them down!",
                    mult_mod = bonus_mult,
                    colour = G.C.MULT
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Tyrande Whisperwind",
    faction = {"Alliance"},
    race = {"Night Elf"},
    class = {"Priest"},
    weapon = {"Bow","Glaives","Sword"},
    rarity = 2,
    cost = 8,
    index = 18, 

    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "Gains {X:mult,C:white} X#2# {} Mult when",
        "you use a {C:planet}Planet{} card",
        "or {C:tarot}The Moon{} card"
    },

    config = { extra = { x_mult = 1, x_mult_gain = 0.1 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult, card.ability.extra.x_mult_gain }
    end,

    calculate = function(self, card, context)
        
        if context.using_consumeable and not context.blueprint then
            local c_card = context.consumeable
            local triggered = false

            if c_card.ability.set == 'Planet' then
                triggered = true
            end

            if c_card.config.center.key == 'c_moon' then
                triggered = true
            end

            if triggered then
                card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.x_mult_gain
                
                return {
                    message = "Elune Guide Us!",
                    colour = G.C.PURPLE,
                    card = card
                }
            end
        end

        if context.joker_main then
            return {
                Xmult_mod = card.ability.extra.x_mult,
                message = "Starfall!",
                colour = G.C.PURPLE
            }
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Chen Stormstout",
    race = {"Pandaren"},
    class = {"Monk"}, 
    weapon = {"Staff", "Fist"},
    rarity = 1,
    cost = 3,
    index = 19, 

    loc_txt = {
        "If played hand contains",
        "exactly {C:attention}#1# cards{},",
        "retrigger each played",
        "card {C:attention}#2# times{}"
    },

    config = { extra = { number = 3, retriger = 2 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.number, card.ability.extra.retriger }
    end,

    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            
            if context.full_hand and #context.full_hand == card.ability.extra.number then
                
                return {
                    message = "Storm, Earth, Fire!",
                    repetitions = card.ability.extra.retriger,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Uther the Lightbringer",
    faction = {"Alliance"},
    race = {"Human"},
    class = {"Paladin"},
    weapon = {"Hammer"},
    rarity = 1,
    cost = 3,
    index = 20,
    config = { extra = { mult = 0, chips = 0, mult_gain = 5, chip_gain = 15 } },
    loc_txt = {
        "Scoring {C:attention}Stone Cards{} are destroyed",
        "and give {C:mult}+#1#{} permanent Mult",
        "Scoring {C:attention}Gold Cards{} give",
        "{C:chips}+#2#{} permanent Chips",
        "{C:inactive}(Currently {C:mult}+#3#{C:inactive} Mult",
        "{C:inactive}and {C:chips}+#4#{C:inactive} Chips){}"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_stone
        info_queue[#info_queue+1] = G.P_CENTERS.m_gold
        return {
            card.ability.extra.mult_gain,
            card.ability.extra.chip_gain,
            card.ability.extra.mult,
            card.ability.extra.chips
        }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            local scored_card = context.other_card

            -- Stone Card: destroy and gain mult
            if scored_card.config.center.key == 'm_stone' and not scored_card.dissolving then
                card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain
                G.E_MANAGER:add_event(Event({
                    func = function()
                        scored_card:start_dissolve({remove_as_card = true})
                        return true
                    end
                }))
                return {
                    message = "Holy Light!",
                    colour = G.C.YELLOW,
                    mult = card.ability.extra.mult,
                    card = card
                }
            end

            -- Gold Card: gain chips
            if scored_card.config.center.key == 'm_gold' then
                card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_gain
                return {
                    message = "Blessed!",
                    colour = G.C.GOLD,
                    chips = card.ability.extra.chips,
                    card = card
                }
            end
        end

        if context.joker_main then
            if card.ability.extra.mult > 0 or card.ability.extra.chips > 0 then
                return {
                    mult = card.ability.extra.mult,
                    chips = card.ability.extra.chips,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Tirion Fordring",
    faction = {"Alliance"},
    race = {"Human"},
    class = {"Paladin"},
    weapon = {"Sword","Hammer"},
    rarity = 2,
    cost = 7,
    index = 21,

    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "Gains {X:mult,C:white} X#2# {} Mult",
        "when you defeat a {C:attention}Blind{}"
    },

    config = { extra = { x_mult = 1.5, x_mult_gain = 0.2 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult, card.ability.extra.x_mult_gain }
    end,

    calculate = function(self, card, context)
        
        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            
            card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.x_mult_gain
            
            return {
                message = "Upgraded!",
                colour = G.C.YELLOW,
                card = card
            }
        end

        if context.joker_main then
            return {
                Xmult_mod = card.ability.extra.x_mult,
                message = "Ashbringer!",
                colour = G.C.YELLOW
            }
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Valeera Sanguinar",
    faction = {"Alliance"},
    race = {"Blood Elf"},
    class = {"Rogue"},
    weapon = {"Daggers"},
    rarity = 2,
    cost = 5,
    index = 22, 

    loc_txt = {
        "If {C:attention}last discard{} of round",
        "is exactly {C:attention}#1# card{},",
        "destroy it and gain {C:money}$#2#{}"
    },

    config = { extra = { number = 1, money = 5 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.number, card.ability.extra.money }
    end,

    calculate = function(self, card, context)
        if context.discard and not context.blueprint then
            
            if context.full_hand and #context.full_hand == card.ability.extra.number then

                if G.GAME.current_round.discards_left == 1 then
                    ease_dollars(card.ability.extra.money)
                    
                    return {
                        message = "Vanish!",
                        colour = G.C.MONEY,
                        remove = true,
                        card = card
                    }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Garona Halforcen",
    faction = {"Horde"}, 
    race = {"Orc", "Draenei" },
    class = {"Rogue"},
    weapon = {"Daggers"},
    rarity = 2,
    cost = 9,
    index = 23, 

    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult if played",
        "hand contains a {C:attention}King{}.",
        "Scored Kings are {C:red}destroyed{}"
    },

    config = { extra = { x_mult = 4 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult }
    end,

    calculate = function(self, card, context)
        
        if context.joker_main then
            local king_found = false
            
            if context.scoring_hand then
                for _, v in ipairs(context.scoring_hand) do
                    if v:get_id() == 13 then
                        king_found = true
                        break
                    end
                end
            end

            if king_found then
                return {
                    message = "Kingslayer!",
                    Xmult_mod = card.ability.extra.x_mult,
                    colour = G.C.MULT
                }
            end
        end

        if context.destroying_card and not context.blueprint then
            
            if context.destroying_card:get_id() == 13 then
                return {
                    remove = true,
                    message = "Slain!",
                    colour = G.C.RED
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Gul'dan",
    faction = {"Legion"},
    race = {"Orc"},
    class = {"Warlock"},
    weapon = {"Staff"},
    rarity = 3,
    cost = 8,
    index = 24, 

    loc_txt = {
        "{C:mult}+#1#{} Mult",
        "When hand is played, destroy",
        "a {C:attention}random card{} in your",
        "{C:attention}deck{} and gain {C:mult}+#2#{} Mult"
    },

    config = { extra = { mult = 0, mult_gain = 3 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.mult, card.ability.extra.mult_gain }
    end,

    calculate = function(self, card, context)
        
        if context.before and not context.blueprint then
            
            if G.deck.cards and #G.deck.cards > 0 then
                
                local random_index = math.ceil(pseudorandom('guldan') * #G.deck.cards)
                local target_card = G.deck.cards[random_index]

                if target_card then
                    target_card:start_dissolve()
                    
                    card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain

                    return {
                        message = "Sacrifice!",
                        colour = G.C.RED,
                        card = card
                    }
                end
            end
        end

        if context.joker_main then
            if card.ability.extra.mult > 0 then
                return {
                    mult_mod = card.ability.extra.mult,
                    message = "Darkness!",
                    colour = G.C.MULT
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Prophet Velen",
    faction = {"Alliance"},
    race = {"Draenei"},
    class = {"Priest"},
    weapon = {"Staff"},
    rarity = 3,
    cost = 8,
    index = 25,

    loc_txt = {
        "All cards are considered",
        "{C:attention}Face Cards{}"
    },

    add_to_deck = function(self, card, from_debuff)
        G.GAME.velen_active = true
    end,

    remove_from_deck = function(self, card, from_debuff)
        G.GAME.velen_active = false
    end
})

Warcraft.create_warcraft_joker({
    name = "Varian Wrynn",
    faction = {"Alliance"},
    race = {"Human"},
    class = {"Warrior"},
    weapon = {"Sword"},
    rarity = 2,
    cost = 10,
    index = 26, 

    loc_txt = {
        "When you play a",
        "{C:clubs}Club{} {C:attention}Face Card{},",
        "{C:green}#1#% chance{} to create a",
        "copy of it in your hand"
    },

    config = { extra = { chance = 50 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.chance }
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            
            if context.scoring_hand then
                for i, played_card in ipairs(context.scoring_hand) do
                    
                    if played_card:is_suit("Clubs") and played_card:is_face() and not played_card.shattered then
                        
                        if pseudorandom('varian') < (card.ability.extra.chance / 100.0) then
                            
                            card:juice_up()

                            G.E_MANAGER:add_event(Event({
                                func = function()
                                    local new_card = copy_card(played_card, nil, nil, G.playing_card)
                                    
                                    new_card:add_to_deck()
                                    table.insert(G.playing_cards, new_card)
                                    
                                    G.hand:emplace(new_card)
                                    new_card:juice_up()
                                    
                                    play_sound('card1')
                                    return true
                                end
                            }))

                            return {
                                message = "Split!",
                                colour = G.C.CLUBS,
                                card = card
                            }
                        end
                    end
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Hemet Nesingwary",
    faction = {"Alliance"},
    race = {"Dwarf"},
    class = {"Hunter"},
    weapon = {"Gun"},
    rarity = 2,
    cost = 5,
    index = 27, 
    config = { extra = { money = 7 } },
    loc_txt = {
        "Each time a {C:attention}Wild Card{}",
        "is discarded, gain {C:money}$#1#{}"
    },
    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.money }
    end,
    calculate = function(self, card, context)
        if context.discard and not context.blueprint then
            if context.other_card.config.center.key == 'm_wild' then
                ease_dollars(card.ability.extra.money)
                return {
                    message = "Bagged!",
                    colour = G.C.MONEY,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Muradin Bronzebeard",
    faction = {"Alliance"}, 
    race = {"Dwarf"},
    class = {"Warrior"},
    weapon = {"Axe","Hammer"},
    rarity = 2,
    cost = 11,
    index = 28, 

    loc_txt = {
        "Played {C:attention}Stone Cards{}",
        "give {X:mult,C:white} X#1# {} Mult",
        "when scored"
    },

    config = { extra = { x_mult = 1.5 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            
            if context.other_card.config.center.key == 'm_stone' then
                
                return {
                    x_mult = card.ability.extra.x_mult,
                    card = context.other_card,
                    message = "Avatar!",
                    colour = G.C.RED
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Medivh",
    race = {"Human"},
    class = {"Mage"},
    weapon = {"Staff"},
    rarity = 1,
    cost = 4,
    index = 29, 

    loc_txt = {
        "When you {C:attention}Skip a Blind{},",
        "create a {C:spectral}Spectral Tag{}"
    },

    calculate = function(self, card, context)
        if context.skip_blind and not context.blueprint then
            
            G.E_MANAGER:add_event(Event({
                func = function()
                    card_eval_status_text(card, 'extra', nil, nil, nil, {
                        message = "Portal Opened!",
                        colour = G.C.SPECTRAL
                    })
                    return true
                end
            }))

            G.E_MANAGER:add_event(Event({
                func = function()
                    add_tag(Tag('tag_ethereal'))
                    play_sound('generic1')
                    return true
                end
            }))
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Kayn Sunfury",
    race = {"Blood Elf"},
    class = {"Demon Hunter"},
    weapon = {"Glaives"},
    rarity = 1,
    cost = 2,
    index = 30, 

    loc_txt = {
        "{C:chips}+#1#{} Chips for every",
        "{C:attention}Enhanced Card{} in your",
        "full deck",
        "{C:inactive}(Currently {C:chips}+#2#{C:inactive} Chips){}"
    },

    config = { extra = { chips = 10 } },

    loc_vars = function(self, info_queue, card)
        local enhanced_count = 0
        if G.playing_cards then
            for _, v in ipairs(G.playing_cards) do
                if v.config.center ~= G.P_CENTERS.c_base then
                    enhanced_count = enhanced_count + 1
                end
            end
        end
        return { card.ability.extra.chips, enhanced_count * card.ability.extra.chips }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local enhanced_count = 0
            
            if G.playing_cards then
                for _, v in ipairs(G.playing_cards) do
                    if v.config.center ~= G.P_CENTERS.c_base then
                        enhanced_count = enhanced_count + 1
                    end
                end
            end

            local chips_bonus = enhanced_count * 10

            if chips_bonus > 0 then
                return {
                    message = "Illidari!",
                    chip_mod = chips_bonus,
                    colour = G.C.CHIPS
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Ner'zhul",
    faction = {"Scourge"}, 
    race = {"Orc"},
    class = {"Warlock"},
    weapon = {"Staff","Sword"},
    rarity = 2,
    cost = 10,
    index = 31, 

    loc_txt = {
        "When playing a",
        "{C:attention}Four of a Kind{} of {C:attention}Kings{},",
        "create a random",
        "{C:dark_edition}Negative{} {C:spectral}Spectral{} card"
    },

    calculate = function(self, card, context)
        
        if context.joker_main then
            
            if context.scoring_name == 'Four of a Kind' then
                
                local is_kings = false
                if context.scoring_hand and #context.scoring_hand > 0 then
                    for k, v in ipairs(context.scoring_hand) do
                        if v:get_id() == 13 then
                            is_kings = true
                            break
                        end
                    end
                end

                if is_kings then
                    
                    G.E_MANAGER:add_event(Event({
                        func = function() 
                            local new_card = create_card('Spectral', G.consumeables, nil, nil, nil, nil, nil, 'nerzhul')
                            
                            new_card:set_edition({negative = true}, true)
                            
                            new_card:add_to_deck()
                            G.consumeables:emplace(new_card)
                            
                            return true
                        end
                    }))

                    return {
                        message = "Frozen Throne!",
                        colour = G.C.SPECTRAL,
                        card = card
                    }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Taran Zhu",
    race = {"Pandaren"},
    class = {"Monk"},
    weapon = {"Staff","Sword","Fist"},
    rarity = 2,
    cost = 8,
    index = 32, 

    loc_txt = {
        "If played hand has {C:attention}no{}",
        "{C:attention}Enhancements{} or {C:dark_edition}Editions{},",
        "played cards permanently",
        "gain a {C:red}Red Seal{}"
    },

    calculate = function(self, card, context)
        
        if context.before and not context.blueprint then
            
            local hand_is_pure = true
            
            if context.full_hand then
                for _, played_card in ipairs(context.full_hand) do
                    if played_card.config.center ~= G.P_CENTERS.c_base then
                        hand_is_pure = false
                        break
                    end
                    
                    if played_card.edition then
                        hand_is_pure = false
                        break
                    end
                end
            end

            if hand_is_pure then
                local cards_modified = 0
                
                for _, played_card in ipairs(context.full_hand) do
                    if played_card:get_seal() ~= 'Red' then
                        played_card:set_seal('Red', nil, true)
                        cards_modified = cards_modified + 1
                    end
                end

                if cards_modified > 0 then
                    return {
                        message = "Disciplined!",
                        colour = G.C.RED,
                        card = card
                    }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Cenarius",
    faction = {"Alliance"},
    race = {"Night Elf"},
    class = {"Druid"},
    weapon = {"Polearm","Spear"},
    rarity = 1,
    cost = 3,
    index = 33,
    config = { extra = { mult = 3 } },
    loc_txt = {
        "Retrigger all played {C:attention}3s{}.",
        "Played {C:attention}3s{} give {C:mult}+#1#{} Mult",
        "When a blind is defeated,",
        "add a random {C:attention}3{} to your deck"
    },
    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.mult }
    end,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            if context.other_card:get_id() == 3 then
                return {
                    message = "Thorns!",
                    repetitions = 1,
                    card = card
                }
            end
        end

        if context.individual and context.cardarea == G.play then
            if context.other_card:get_id() == 3 then
                return {
                    mult = card.ability.extra.mult,
                    card = context.other_card
                }
            end
        end

        if context.end_of_round and not context.repetition and not context.individual and not context.blueprint then
            G.E_MANAGER:add_event(Event({
                func = function()
                    local suits = {"S", "H", "D", "C"}
                    local suit = pseudorandom_element(suits, pseudoseed('cenarius_' .. G.GAME.round))
                    local new_card = create_card('Base', G.deck, nil, nil, nil, nil, nil, 'cenarius')
                    new_card:set_base(G.P_CARDS[suit .. '_3'])
                    new_card:add_to_deck()
                    table.insert(G.playing_cards, new_card)
                    G.deck:emplace(new_card)
                    new_card:juice_up()
                    card_eval_status_text(card, 'extra', nil, nil, nil, {
                        message = "Ancient's Gift!",
                        colour = G.C.GREEN
                    })
                    return true
                end
            }))
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Queen Azshara",
    race = {"Naga"},
    class = {"Mage"},
    weapon = {"Staff"},
    rarity = 2,
    cost = 5,
    index = 34,

    loc_txt = {
        "Each {C:attention}Queen{} held in",
        "hand gives {X:mult,C:white} X1.5 {} Mult"
    },

    config = { extra = { x_mult = 1.5 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.hand and not context.end_of_round then
            
            if context.other_card:get_id() == 12 and not context.other_card.debuff then
                
                return {
                    x_mult = card.ability.extra.x_mult,
                    card = context.other_card,
                    message = "Perfection!",
                    colour = G.C.PURPLE
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Darion Mograine",
    faction = {"Scourge"},
    race = {"Undead"},
    class = {"Death Knight"},
    weapon = {"Sword"},
    rarity = 2,
    cost = 6,
    index = 35,

    loc_txt = {
        "Played cards that",
        "{C:attention}do not score{}",
        "become {C:attention}Stone Cards{}"
    },

    calculate = function(self, card, context)
        if context.after and not context.blueprint then
            
            local converted_cards = false
            
            if context.full_hand and context.scoring_hand then
                for _, played_card in ipairs(context.full_hand) do
                    
                    local is_scoring = false
                    for _, scoring_card in ipairs(context.scoring_hand) do
                        if played_card == scoring_card then
                            is_scoring = true
                            break
                        end
                    end

                    if not is_scoring and played_card.config.center.key ~= 'm_stone' and not played_card.shattered then
                        
                        played_card:set_ability(G.P_CENTERS.m_stone, nil, true)
                        played_card:juice_up()
                        converted_cards = true
                    end
                end
            end

            if converted_cards then
                return {
                    message = "Rise!",
                    colour = G.C.GREY,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Teron Gorefiend",
    faction = {"Scourge"},
    race = {"Undead"},
    class = {"Death Knight"},
    weapon = {"Staff","Hammer"},
    rarity = 1,
    cost = 4,
    index = 36,

    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "Gains {X:mult,C:white} X#2# {} Mult when",
        "a playing card is {C:red}destroyed{}"
    },

    config = { extra = { x_mult = 1, x_mult_gain = 0.25 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult, card.ability.extra.x_mult_gain }
    end,

    calculate = function(self, card, context)
        
        if context.remove_playing_cards and not context.blueprint then
            
            local destroyed_count = #context.removed
            
            if destroyed_count > 0 then
                card.ability.extra.x_mult = card.ability.extra.x_mult + (card.ability.extra.x_mult_gain * destroyed_count)
                
                return {
                    message = "Feast!",
                    colour = G.C.RED,
                    card = card
                }
            end
        end

        if context.joker_main then
            return {
                Xmult_mod = card.ability.extra.x_mult,
                message = "The Wheel Spins!",
                colour = G.C.RED
            }
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Alleria Windrunner",
    faction = {"Alliance"},
    race = {"Blood Elf"},
    class = {"Hunter"},
    weapon = {"Bow","Daggers","Sword"},
    rarity = 1,
    cost = 6,
    index = 37,

    loc_txt = {
        "Played cards have a",
        "{C:green}#1# in #2#{} chance to gain",
        "a {C:purple}Purple Seal{}"
    },

    config = { extra = { base_chance = 1, max_chance = 4 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.base_chance, card.ability.extra.max_chance }
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            
            local cards_infused = false
            
            if context.full_hand then
                for _, played_card in ipairs(context.full_hand) do
                    
                    if pseudorandom('alleria') < (card.ability.extra.base_chance / card.ability.extra.max_chance) then
                        
                        played_card:set_seal('Purple', nil, true)
                        
                        played_card:juice_up()
                        cards_infused = true
                    end
                end
            end

            if cards_infused then
                return {
                    message = "Void!",
                    colour = G.C.PURPLE,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Kael'thas Sunstrider",
    faction = {"Alliance","Legion"},
    race = {"Blood Elf"},
    class = {"Mage"},
    weapon = {"Sword","Staff"},
    rarity = 1,
    cost = 4,
    index = 38,

    loc_txt = {
        "Played {C:attention}Glass Cards{}",
        "give {X:mult,C:white} X#1# {} Mult",
        "when scored"
    },

    config = { extra = { x_mult = 2 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            
            if context.other_card.config.center.key == 'm_glass' then
                
                return {
                    x_mult = card.ability.extra.x_mult,
                    card = context.other_card,
                    message = "Al'ar!",
                    colour = G.C.RED
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Balnazzar",
    faction = {"Legion"},
    race = {"Demon"},
    class = {"Warlock"},
    weapon = {"Sword","Fist"},
    rarity = 1,
    cost = 5,
    index = 39,

    loc_txt = {
        "{C:attention}Jacks{} are considered",
        "{C:attention}Wild Cards{} and",
        "cannot be {C:attention}Debuffed{}"
    },

    calculate = function(self, card, context)
        if context.debuff_card and not context.blueprint then
            
            if context.debuff_card and context.debuff_card:get_id() == 11 then 
                return "prevent_debuff"
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Mal'Ganis",
    faction = {"Scourge","Legion"},
    race = {"Demon","Undead"},
    class = {"Warlock"}, 
    weapon = {"Sword","Fist"},
    rarity = 3,
    cost = 10,
    index = 40,
    config = { extra = { 
        chips = 0, mult = 0,
        chips_gain = 50, mult_gain = 5, gold_gain = 3
    }},
    loc_txt = {
        "When an {C:red}Enemy{} penalty would trigger,",
        "cancel it and gain",
        "{C:chips}+#3#{} Chips, {C:mult}+#4#{} Mult,",
        "and {C:money}$#5{}",
        "{C:inactive}(Currently {C:chips}+#1#{C:inactive} Chips,",
        "{C:inactive}{C:mult}+#2#{C:inactive} Mult){}"
    },
    loc_vars = function(self, info_queue, card)
        return { 
            card.ability.extra.chips, 
            card.ability.extra.mult,
            card.ability.extra.chips_gain,
            card.ability.extra.mult_gain,
            card.ability.extra.gold_gain
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            if card.ability.extra.chips > 0 or card.ability.extra.mult > 0 then
                return {
                    chips = card.ability.extra.chips,
                    mult = card.ability.extra.mult,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Akama",
    faction = {"Alliance"},
    race = {"Draenei"},
    class = { "Shaman", "Rogue" },
    weapon = {"Daggers"},
    rarity = 1,
    cost = 2,
    index = 41, 

    loc_txt = {
        "Played {C:attention}Red Cards{} give {C:mult}+#1#{} Mult,",
        "Played {C:attention}Black Cards{} give {C:chips}+#2#{} Chips",
        "{C:inactive}(Wild Cards give both){}"
    },

    config = { extra = { mult = 4, chips = 20 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.mult, card.ability.extra.chips }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            
            local other = context.other_card
            local is_red = other:is_suit("Hearts") or other:is_suit("Diamonds")
            local is_black = other:is_suit("Spades") or other:is_suit("Clubs")
            
            local ret = {
                card = other
            }
            local triggered = false

            if is_red then
                ret.mult = card.ability.extra.mult
                triggered = true
            end

            if is_black then
                ret.chips = card.ability.extra.chips
                triggered = true
            end

            if triggered then
                other:juice_up()
                
                ret.message = "Shadowmoon!"
                
                if is_red and is_black then
                    ret.colour = G.C.PURPLE
                elseif is_red then
                    ret.colour = G.C.MULT
                else
                    ret.colour = G.C.CHIPS
                end

                return ret
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Farseer Nobundo",
    faction = {"Alliance"},
    race = {"Draenei"},
    class = {"Shaman"},
    weapon = {"Hammer","Shield"},
    rarity = 2,
    cost = 8,
    index = 42, 

    loc_txt = {
        "Retrigger the {C:attention}first played card{}",
        "of each {C:attention}Suit{}",
        "{C:inactive}(Wild Cards count for all suits){}"
    },

    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            
            local other = context.other_card
            local hand = context.full_hand
            local reps = 0
            
            local suits = {'Spades', 'Hearts', 'Clubs', 'Diamonds'}
            
            for _, suit_to_check in ipairs(suits) do
                local first_match = nil
                for _, hand_card in ipairs(hand) do
                    if hand_card:is_suit(suit_to_check) then
                        first_match = hand_card
                        break
                    end
                end
                
                if first_match and first_match == other then
                    reps = reps + 1
                end
            end

            if reps > 0 then
                return {
                    message = "Elements!",
                    repetitions = reps,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Yrel",
    faction = {"Alliance"}, 
    race = {"Draenei"},
    class = {"Paladin"},
    weapon = {"Hammer","Shield"},
    rarity = 2,
    cost = 6,
    index = 43,

    loc_txt = {
        "Scoring {C:attention}Glass Cards{}",
        "permanently gain",
        "{C:chips}+#1#{} Chips"
    },

    config = { extra = { chips = 10 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.chips }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            
            if context.other_card.config.center.key == 'm_glass' then
                
                context.other_card.ability.perma_bonus = context.other_card.ability.perma_bonus or 0
                
                context.other_card.ability.perma_bonus = context.other_card.ability.perma_bonus + card.ability.extra.chips
                
                return {
                    extra = {message = "Upgraded!", colour = G.C.CHIPS},
                    colour = G.C.CHIPS,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Alexstrasza",
    faction = {"Horde","Alliance"},
    race = {"Dragon"},
    weapon = {"Staff","Fist"},
    rarity = 2,
    cost = 5,
    index = 44,

    loc_txt = {
        "Played {C:hearts}Hearts{} give",
        "{X:mult,C:white} X#1# {} Mult when scored.",
        "All {C:hearts}Hearts{} are considered",
        "{C:attention}Face Cards{}"
    },

    config = { extra = { x_mult = 1.5 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            
            if context.other_card:is_suit('Hearts') then
                return {
                    x_mult = card.ability.extra.x_mult,
                    card = context.other_card,
                    message = "Lifebinder!",
                    colour = G.C.RED
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Kalecgos",
    faction = {"Horde","Alliance"},
    race = {"Dragon"},
    class = {"Mage"},
    weapon = {"Staff","Fist"},
    rarity = 2,
    cost = 4,
    index = 45,
    config = { extra = {} },
    loc_txt = {
        "{C:tarot}Arcana Packs{} cost {C:money}$0{}",
        "An extra {C:tarot}Mega Arcana Pack{}",
        "appears in every {C:attention}Shop{}"
    },
    loc_vars = function(self, info_queue, card)
        return {}
    end,
    add_to_deck = function(self, card, from_debuff)
        -- Refresh shop costs when Kalecgos is acquired mid-shop
        if G.shop_booster then
            for _, c in ipairs(G.shop_booster.cards) do
                c:set_cost()
            end
        end
    end,
    remove_from_deck = function(self, card, from_debuff)
        -- Restore original costs when Kalecgos leaves
        if G.shop_booster then
            for _, c in ipairs(G.shop_booster.cards) do
                c:set_cost()
            end
        end
    end,
    calculate = function(self, card, context)
    end
})

Warcraft.create_warcraft_joker({
    name = "Malygos",
    race = {"Dragon"},
    class = {"Mage"},
    weapon = {"Staff","Fist"},
    rarity = 2,
    cost = 5,
    index = 46,

    loc_txt = {
        "{C:mult}+#1#{} Mult for every",
        "empty {C:attention}Consumable Slot{}",
        "{C:inactive}(Currently {C:mult}+#2#{C:inactive} Mult){}"
    },

    config = { extra = { mult = 20, } },

    loc_vars = function(self, info_queue, card)
        local empty_slots = G.consumeables.config.card_limit - #G.consumeables.cards
        if empty_slots < 0 then empty_slots = 0 end
        
        return { card.ability.extra.mult, empty_slots * card.ability.extra.mult }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            
            local empty_slots = G.consumeables.config.card_limit - #G.consumeables.cards
            if empty_slots < 0 then empty_slots = 0 end

            local mult_bonus = empty_slots * card.ability.extra.mult

            if mult_bonus > 0 then
                return {
                    message = "Mana Burn!",
                    mult_mod = mult_bonus,
                    colour = G.C.BLUE
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Neltharion",
    race = {"Dragon"},
    class = {"Warrior"},
    weapon = {"Hammer","Fist"},
    rarity = 2,
    cost = 8,
    index = 47,

    loc_txt = {
        "{C:chips}+#1#{} Chips",
        "{C:attention}-#2#{} Hand Size"
    },

    config = { extra = { chips = 300, h_size = 1 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.chips, card.ability.extra.h_size }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return {
                chip_mod = card.ability.extra.chips,
                message = "Cataclysm!",
                colour = G.C.CHIPS
            }
        end
    end,

    add_to_deck = function(self, card, from_debuff)
        G.hand.config.card_limit = G.hand.config.card_limit - card.ability.extra.h_size
    end,

    remove_from_deck = function(self, card, from_debuff)
        G.hand.config.card_limit = G.hand.config.card_limit + card.ability.extra.h_size
    end
})

Warcraft.create_warcraft_joker({
    name = "Nozdormu",
    faction = {"Horde","Alliance"},
    race = {"Dragon"},
    class = {"Mage"},
    weapon = {"Staff","Fist"},
    rarity = 1,
    cost = 8,
    index = 48,

    loc_txt = {
        "{C:blue}+#1#{} Hand and",
        "{C:red}+#2#{} Discard",
        "per round"
    },

    config = { extra = { hand = 1, discard = 1 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.hand, card.ability.extra.discard }
    end,

    add_to_deck = function(self, card, from_debuff)
        G.GAME.round_resets.hands = G.GAME.round_resets.hands + card.ability.extra.hand
        G.GAME.round_resets.discards = G.GAME.round_resets.discards + card.ability.extra.discard
        
        if G.GAME.current_round.hands_left then
            G.GAME.current_round.hands_left = G.GAME.current_round.hands_left + card.ability.extra.hand
            G.GAME.current_round.discards_left = G.GAME.current_round.discards_left + card.ability.extra.discard
        end
    end,

    remove_from_deck = function(self, card, from_debuff)
        G.GAME.round_resets.hands = G.GAME.round_resets.hands - card.ability.extra.hand
        G.GAME.round_resets.discards = G.GAME.round_resets.discards - card.ability.extra.discard
        
        if G.GAME.current_round.hands_left then
            G.GAME.current_round.hands_left = math.max(0, G.GAME.current_round.hands_left - card.ability.extra.hand)
            G.GAME.current_round.discards_left = math.max(0, G.GAME.current_round.discards_left - card.ability.extra.discard)
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Ysera",
    faction = {"Horde","Alliance"},
    race = {"Dragon"},
    class = {"Druid"},
    weapon = {"Staff", "Fist"},
    rarity = 1,
    cost = 4,
    index = 49,

    loc_txt = {
        "When you {C:attention}Skip a Blind{},",
        "create {C:attention}#1#{} random",
        "{C:tarot}Tarot{} cards"
    },

    config = { extra = { number = 2 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.number }
    end,

    calculate = function(self, card, context)
        
        if context.skip_blind then
            
            G.E_MANAGER:add_event(Event({
                func = function() 
                    for i = 1, card.ability.extra.number do
                        local card_type = 'Tarot'
                        local new_card = create_card(card_type, G.consumeables, nil, nil, nil, nil, nil, 'ysera')
                        new_card:add_to_deck()
                        G.consumeables:emplace(new_card)
                    end
                    
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Dream!", colour = G.C.PURPLE})
                    return true
                end
            }))
            
            return
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Onyxia",
    race = {"Dragon"},
    weapon = {"Fist"},
    rarity = 1,
    cost = 4,
    index = 50,

    loc_txt = {
        "When you play a {C:attention}Queen{},",
        "create a permanent {C:attention}2{}",
        "of a random suit in your deck"
    },

    calculate = function(self, card, context)
        
        if context.before and not context.blueprint then
            
            local queens_count = 0
            
            if context.full_hand then
                for _, played_card in ipairs(context.full_hand) do
                    if played_card:get_id() == 12 then 
                        queens_count = queens_count + 1
                    end
                end
            end

            if queens_count > 0 then
                G.E_MANAGER:add_event(Event({
                    func = function() 
                        for i = 1, queens_count do
                            local suit = pseudorandom_element({'S','H','D','C'}, pseudoseed('onyxia_'..i))
                            
                            local new_card = create_card('Base', G.deck, nil, nil, nil, nil, nil, 'onyxia')
                            new_card:set_base(G.P_CARDS[suit..'_2'])
                            new_card:add_to_deck()

                            -- Register into the master card list so it persists and gets dealt
                            table.insert(G.playing_cards, new_card)
                            G.deck:emplace(new_card)
                            
                            new_card:juice_up()
                        end
                        return true
                    end
                }))

                return {
                    message = "More Whelps!",
                    colour = G.C.ORANGE,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Chromie",
    faction = {"Horde","Alliance"},
    race = {"Dragon", "Gnome"},
    class = {"Mage"},
    weapon = {"Staff", "Fist"},
    rarity = 1,
    cost = 3,
    index = 51,
    config = { extra = { used_this_blind = false } },
    loc_txt = {
        "The {C:attention}first{} scored hand",
        "each blind is returned",
        "to your {C:attention}hand{} after scoring"
    },
    loc_vars = function(self, info_queue, card)
        return {}
    end,
    calculate = function(self, card, context)
        if context.start_of_round and not context.blueprint then
            card.ability.extra.used_this_blind = false
        end

        if context.after and not context.blueprint and not card.ability.extra.used_this_blind then
            card.ability.extra.used_this_blind = true

            local cards_to_return = {}
            for _, c in ipairs(context.scoring_hand) do
                table.insert(cards_to_return, c)
                G.play:remove_card(c)
            end

            G.E_MANAGER:add_event(Event({
                func = function()
                    for _, c in ipairs(cards_to_return) do
                        G.hand:emplace(c)
                        c:juice_up()
                    end
                    G.hand:sort()
                    return true
                end
            }))

            return {
                message = "Time Shift!",
                colour = G.C.ORANGE,
                card = card
            }
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Sapphiron",
    faction = {"Scourge"},
    race = {"Undead"},
    weapon = {"Fist"},
    rarity = 1,
    cost = 5,
    index = 52,

    loc_txt = {
        "Played {C:attention}Blue Seal{} cards",
        "become {C:attention}Glass Cards{},",
        "Played {C:attention}Glass Cards{} gain",
        "a {C:blue}Blue Seal{}"
    },

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            
            local changed = false
            
            for k, v in ipairs(context.full_hand) do
                local is_glass = (v.config.center.key == 'm_glass')
                local has_blue = (v:get_seal() == 'Blue')

                if has_blue and not is_glass then
                    v:set_ability(G.P_CENTERS.m_glass, nil, true)
                    v:juice_up()
                    changed = true
                    is_glass = true
                end

                if is_glass and not has_blue then
                    v:set_seal('Blue', nil, true)
                    v:juice_up()
                    changed = true
                end
            end

            if changed then
                return {
                    message = "Frost Aura!",
                    colour = G.C.CYAN,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Brann Bronzebeard",
    faction = {"Alliance"},
    race = {"Dwarf"},
    class = {"Hunter"},
    weapon = {"Bow","Axe","Hammer"},
    rarity = 1,
    cost = 4,
    index = 53,

    loc_txt = {
        "Retrigger the",
        "{C:attention}first scoring card{}",
        "{C:attention}#1#{} times"
    },

    config = { extra = { retrigger = 3 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.retrigger }
    end,

    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            
            if context.scoring_hand and context.scoring_hand[1] == context.other_card then
                return {
                    message = "Brann!",
                    repetitions = card.ability.extra.retrigger,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Magni Bronzebeard",
    faction = {"Alliance"},
    race = {"Dwarf"},
    class = {"Warrior"},
    weapon = {"Axe","Hammer"},
    rarity = 3,
    cost = 9,
    index = 54,

    loc_txt = {
        "Scoring {C:diamonds}Diamonds{} give",
        "{X:mult,C:white} X#1# {} Mult"
    },

    config = { extra = { x_mult = 1.5 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            
            if context.other_card:is_suit("Diamonds") then
                context.other_card:juice_up()
                return {
                    x_mult = card.ability.extra.x_mult,
                    card = context.other_card,
                    message = "Speaker!",
                    colour = G.C.ORANGE
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Moira Thaurissan",
    faction = {"Alliance"},
    race = {"Dwarf"},
    class = {"Priest"},
    weapon = {"Staff","Hammer"},
    rarity = 2,
    cost = 4,
    index = 55,

    loc_txt = {
        "If played hand contains a",
        "{C:attention}King{} and a {C:attention}Queen{},",
        "destroy the {C:attention}King{} and give the",
        "{C:attention}Queen{} {C:mult}+#1#{} Mult permanently"
    },

    config = { extra = { mult = 20 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.mult }
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            
            local kings = {}
            local queens = {}
            
            for _, v in ipairs(context.full_hand) do
                if v:get_id() == 13 and not v.debuff then table.insert(kings, v) end
                if v:get_id() == 12 and not v.debuff then table.insert(queens, v) end
            end

            if #kings > 0 and #queens > 0 then
                local king = kings[1]
                local queen = queens[1]

                queen.ability.perma_mult = (queen.ability.perma_mult or 0) + card.ability.extra.mult
                
                queen:juice_up()
                card_eval_status_text(queen, 'extra', nil, nil, nil, {message = "Upgrade!", colour = G.C.MULT})

                king:start_dissolve(nil, true)

                return {
                    message = "Coup d'etat!",
                    colour = G.C.RED,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Falstad Wildhammer",
    faction = {"Alliance"},
    race = {"Dwarf"},
    class = {"Warrior"},
    weapon = {"Hammer"},
    rarity = 2,
    cost = 6,
    index = 56,

    loc_txt = {
        "Played {C:attention}Wild Cards{}",
        "retrigger {C:attention}#1#{} time"
    },

    config = { extra = { retrigger = 1 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.retrigger }
    end,

    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            
            if context.other_card.config.center.key == 'm_wild' then
                return {
                    message = "Wildhammer!",
                    repetitions = card.ability.extra.retrigger,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Lor'themar Theron",
    faction = {"Horde"},
    race = {"Blood Elf"},
    class = {"Hunter"},
    weapon = {"Sword","Bow","Shield"},
    rarity = 1,
    cost = 6,
    index = 57,

    loc_txt = {
        "If you play exactly {C:attention}#1# card{},",
        "it permanently gains a",
        "{C:red}Red Seal{}"
    },

    config = { extra = { number = 1 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.number }
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            
            if #context.full_hand == card.ability.extra.number then
                local played_card = context.full_hand[1]

                if played_card:get_seal() ~= 'Red' then
                    
                    played_card:set_seal('Red', nil, true)
                    
                    played_card:juice_up()
                    
                    return {
                        message = "Ranger's Mark!",
                        colour = G.C.RED,
                        card = card
                    }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Lady Liadrin",
    faction = {"Horde"},
    race = {"Blood Elf"},
    class = {"Paladin"},
    weapon = {"Sword","Shield"},
    rarity = 2,
    cost = 5,
    index = 58,

    loc_txt = {
        "Played {C:hearts}Hearts{} give",
        "{X:mult,C:white} X#1# {} Mult when scored,",
        "but you lose {C:money}$#2#{}",
        "for each {C:hearts}Heart{} scored"
    },

    config = { extra = { x_mult = 2, money = 1 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult, card.ability.extra.money }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            
            if context.other_card:is_suit("Hearts") then
                
                ease_dollars(-card.ability.extra.money)
                
                return {
                    x_mult = card.ability.extra.x_mult,
                    card = context.other_card,
                    message = "Sacrifice!",
                    colour = G.C.RED
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Maiev Shadowsong",
    faction = {"Alliance"},
    race = {"Night Elf"},
    class = {"Rogue"},
    weapon = {"Glaives","Daggers"},
    rarity = 2,
    cost = 7,
    index = 59,
    config = { extra = { x_mult = 1, x_mult_gain = 0.25 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "Gains {X:mult,C:white} X#2# {} Mult each time",
        "an {C:red}Enemy{} is killed by its",
        "{C:attention}Kill Condition{}"
    },
    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult, card.ability.extra.x_mult_gain }
    end,
    calculate = function(self, card, context)
        -- Reset kill counter at the start of each hand
        if context.before and not context.blueprint then
            G.GAME.warcraft_kills_this_hand = 0
        end

        -- After scoring, reward kills that happened this hand
        if context.after and not context.blueprint then
            local kills = G.GAME.warcraft_kills_this_hand or 0
            if kills > 0 then
                card.ability.extra.x_mult = card.ability.extra.x_mult + (kills * card.ability.extra.x_mult_gain)
                G.GAME.warcraft_kills_this_hand = 0
                return {
                    message = "Caged!",
                    colour = G.C.PURPLE,
                    card = card
                }
            end
        end

        if context.joker_main then
            if card.ability.extra.x_mult > 1 then
                return {
                    x_mult = card.ability.extra.x_mult,
                    colour = G.C.PURPLE
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Lady Vashj",
    faction = {"Legion"},
    race = {"Naga"},
    class = {"Shaman"},
    weapon = {"Bow","Fist"},
    rarity = 1,
    cost = 4,
    index = 60,

    loc_txt = {
        "Retrigger the card in the",
        "{C:attention}exact center{} of the",
        "scoring hand",
        "{C:inactive}(Only works with odd number of cards){}"
    },

    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            
            local hand = context.scoring_hand
            local count = #hand

            if count % 2 == 1 then
                
                local center_idx = math.ceil(count / 2)
                
                if context.other_card == hand[center_idx] then
                    return {
                        message = "Medusa!",
                        repetitions = 1,
                        card = card
                    }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Zovaal",
    race = {"God"},
    weapon = {"Hammer"},
    rarity = 3,
    cost = 20,
    index = 61,

    loc_txt = {
        "Played {C:attention}Debuffed Cards{} score",
        "their Chips and give",
        "{X:mult,C:white} X#1# {} Mult"
    },

    config = { extra = { x_mult = 5 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult }
    end,

    calculate = function(self, card, context)
        
        if context.joker_main then
            
            local debuffed_count = 0
            local chips_restored = 0
            
            for _, played_card in ipairs(context.full_hand) do
                if played_card.debuff then
                    debuffed_count = debuffed_count + 1
                    
                    local card_chips = played_card.base.nominal
                    if played_card.ability.perma_bonus then
                        card_chips = card_chips + played_card.ability.perma_bonus
                    end
                    if played_card.config.center.key == 'm_stone' then
                         card_chips = card_chips + 50
                    end
                    
                    chips_restored = chips_restored + card_chips
                end
            end

            if debuffed_count > 0 then
                
                if chips_restored > 0 then
                    hand_chips = hand_chips + chips_restored
                end

                local total_x_mult = card.ability.extra.x_mult ^ debuffed_count

                return {
                    message = "Domination!",
                    x_mult = total_x_mult,
                    colour = G.C.DARK_EDITION,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Sire Denathrius",
    race = {"God"},
    class = {"Warrior"},
    weapon = {"Sword","Fist"},
    rarity = 3,
    cost = 10,
    index = 62,

    loc_txt = {
        "Played cards give",
        "{C:mult}+#1#{} Mult for every",
        "{C:money}$#2#{} you have",
        "{C:inactive}(Currently {C:mult}+#3#{C:inactive} Mult){}"
    },

    config = { extra = { mult = 1, money = 1 } },

    loc_vars = function(self, info_queue, card)
        local bonus = card.ability.extra.mult * math.max(0, G.GAME.dollars / card.ability.extra.money)
        return { card.ability.extra.mult, card.ability.extra.money, bonus }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then

            local bonus = card.ability.extra.mult * math.max(0, G.GAME.dollars / card.ability.extra.money)
            
            if bonus > 0 then
                return {
                    mult = bonus,
                    card = context.other_card,
                    message = "Confess!",
                    colour = G.C.RED
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Sargeras",
    faction = {"Legion"},
    race = {"Titan"},
    weapon = {"Sword"},
    rarity = 3,
    cost = 20,
    index = 63,

    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "When you play a hand,",
        "destroy the Joker to the {C:attention}right{}",
        "and gain {X:mult,C:white} X#2# {} Mult.",
        "If no Joker is to the right,",
        "{C:red}Debuff{} this Joker for the hand"
    },

    config = { extra = { x_mult = 1, gain = 0.5 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult, card.ability.extra.gain }
    end,

    calculate = function(self, card, context)
        
        if context.before and not context.blueprint then
            
            local my_pos = nil
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then my_pos = i; break end
            end

            if my_pos and G.jokers.cards[my_pos + 1] then
                local victim = G.jokers.cards[my_pos + 1]
                
                if not victim.ability.eternal and not victim.getting_sliced then
                    
                    victim.getting_sliced = true
                    victim:start_dissolve(nil, true)
                    
                    card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.gain
                    
                    return {
                        message = "Oblivion!",
                        colour = G.C.RED,
                        card = card
                    }
                else
                    return {
                        message = "Eternal...",
                        colour = G.C.RED,
                        card = card
                    }
                end
            else
                card.debuff = true
                return {
                    message = "Weakened!",
                    colour = G.C.RED,
                    card = card
                }
            end
        end

        if context.joker_main then
            return {
                x_mult = card.ability.extra.x_mult,
                colour = G.C.RED
            }
        end

        if context.after and card.debuff then
            card.debuff = false
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "C'Thun",
    race = {"God"},
    weapon = {"Fist"},
    rarity = 1,
    cost = 5,
    index = 64,

    loc_txt = {
        "{C:chips}+#1#{} Chips",
        "{C:inactive}(Gains {C:chips}+#2#{C:inactive} Chips every time",
        "a card with {C:attention}Odd Rank{}",
        "is scored){}"
    },

    config = { extra = { chips = 0, gain = 10 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.chips, card.ability.extra.gain }
    end,

    calculate = function(self, card, context)
        
        if context.individual and context.cardarea == G.play then
            
            local rank_id = context.other_card:get_id()
            
            local is_odd = (rank_id > 0 and rank_id % 2 == 1) or (rank_id == 14)

            if is_odd then
                card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.gain
                
                return {
                    message = "Ritual!",
                    colour = G.C.CHIPS,
                    card = card
                }
            end
        end

        if context.joker_main then
            if card.ability.extra.chips > 0 then
                return {
                    chip_mod = card.ability.extra.chips,
                    message = "C'Thun! C'Thun!",
                    colour = G.C.CHIPS
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Yogg-Saron",
    race = {"God"},
    weapon = {"Fist"},
    rarity = 3,
    cost = 8,
    index = 65,

    loc_txt = {
        "When you {C:attention}Skip a Blind{},",
        "create a random",
        "{C:attention}Legendary Equipment{} card",
        "{C:inactive}(Must have room){}"
    },

    calculate = function(self, card, context)
        
        if context.skip_blind then
            
            G.E_MANAGER:add_event(Event({
                func = function() 
                    if not Warcraft.Equipment.keys or #Warcraft.Equipment.keys == 0 then
                        card_eval_status_text(card, 'extra', nil, nil, nil, {message = "No Loot!", colour = G.C.RED})
                        return true
                    end
                    
                    if #G.consumeables.cards < G.consumeables.config.card_limit then
                        
                        local chosen_key = pseudorandom_element(Warcraft.Equipment.keys, pseudoseed('yogg'))
                        
                        local new_card = create_card('Equipment', G.consumeables, nil, nil, nil, nil, chosen_key, 'yogg')
                        
                        new_card:add_to_deck()
                        G.consumeables:emplace(new_card)
                        
                        card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Madness!", colour = G.C.PURPLE})
                    else
                        card_eval_status_text(card, 'extra', nil, nil, nil, {message = "No Room!", colour = G.C.RED})
                    end
                    return true
                end
            }))
            
            return
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Y'Shaarj",
    race = {"God"},
    weapon = {"Fist"},
    rarity = 3,
    cost = 8,
    index = 66,

    loc_txt = {
        "After drawing your {C:attention}opening hand{},",
        "order the remaining deck from",
        "{C:attention}Highest{} to {C:attention}Lowest{} Rank"
    },

    calculate = function(self, card, context)
        
        if context.first_hand_drawn then
            
            G.E_MANAGER:add_event(Event({
                func = function() 
                    
                    table.sort(G.deck.cards, function(a, b)
                        return a.base.id < b.base.id
                    end)
                    
                    G.deck:juice_up()
                    
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Unleashed!", colour = G.C.RED})
                    return true
                end
            }))
            
            return
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "N'Zoth",
    race = {"God"},
    weapon = {"Fist"},
    rarity = 2,
    cost = 5,
    index = 67,

    loc_txt = {
        "Scoring {C:attention}Stone Cards{}",
        "gain a random {C:attention}Seal{}",
        "{C:inactive}(Red, Blue, Gold, or Purple){}"
    },

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            
            if context.other_card.config.center.key == 'm_stone' then
                
                if not context.other_card.seal then
                    
                    local valid_seals = {}
                    for k, v in pairs(G.P_SEALS) do
                        table.insert(valid_seals, k)
                    end
                    
                    if #valid_seals > 0 then
                        local chosen_seal = pseudorandom_element(valid_seals, pseudoseed('nzoth'))
                        
                        context.other_card:set_seal(chosen_seal, true, true)
                        
                        return {
                            message = "Corrupted!",
                            colour = G.C.PURPLE,
                            card = card
                        }
                    end
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Aman'Thul",
    faction = {"Horde","Alliance"},
    race = {"Titan"},
    weapon = {"Staff"},
    rarity = 2,
    cost = 4,
    index = 68,

    loc_txt = {
        "Played {C:attention}Straights{} give",
        "{X:mult,C:white} X#1# {} Mult"
    },

    config = { extra = { x_mult = 3 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            
            local hand_name = context.scoring_name
            
            if hand_name == "Straight" or hand_name == "Straight Flush" or hand_name == "Royal Flush" then
                return {
                    message = "Order!",
                    x_mult = card.ability.extra.x_mult,
                    colour = G.C.BLUE
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Eonar",
    faction = {"Horde","Alliance"},
    race = {"Titan"},
    weapon = {"Staff"},
    rarity = 2,
    cost = 9,
    index = 69,

    loc_txt = {
        "When you play a {C:attention}Pair{}, create a",
        "new card added to your deck:",
        "{C:attention}Left Card{}: Rank & Edition",
        "{C:attention}Right Card{}: Suit, Enhancement, Seal"
    },

    calculate = function(self, card, context)
        
        if context.before and not context.blueprint then
            
            if context.scoring_name == "Pair" then
                
                local parent_A = context.scoring_hand[1]
                local parent_B = context.scoring_hand[2]

                G.E_MANAGER:add_event(Event({
                    func = function() 
                        local child = copy_card(parent_A, nil, nil, G.playing_card)
                        
                        child:change_suit(parent_B.base.suit)
                        
                        if parent_B.config.center.set == 'Enhanced' then
                            child:set_ability(G.P_CENTERS[parent_B.config.center.key])
                        else
                            child:set_ability(G.P_CENTERS.c_base)
                        end
                        
                        local seal_B = parent_B:get_seal()
                        if seal_B then
                            child:set_seal(seal_B, true, true)
                        else
                            child:set_seal(nil, true) 
                        end

                        child:add_to_deck()
                        G.deck.config.card_limit = G.deck.config.card_limit + 1
                        table.insert(G.playing_cards, child)
                        
                        G.hand:emplace(child)
                        child:juice_up()
                        
                        card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Life Created!", colour = G.C.GREEN})
                        return true
                    end
                }))

                return {
                    message = "Life-Bind!",
                    colour = G.C.GREEN,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Khaz'goroth",
    faction = {"Horde","Alliance"},
    race = {"Titan"},
    weapon = {"Hammer"},
    rarity = 2,
    cost = 7,
    index = 70,
    config = { extra = { steel_count = 3 } },
    loc_txt = {
        "Before scoring, add {C:attention}#1#{} temporary",
        "{C:attention}Steel Cards{} of random value",
        "between {C:attention}2{} and {C:attention}5{}",
        "to the scored hand"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_steel
        return { card.ability.extra.steel_count }
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            G.E_MANAGER:add_event(Event({
                func = function()
                    local suits = {"S", "H", "D", "C"}
                    local ranks = {"2", "3", "4", "5"}

                    for i = 1, card.ability.extra.steel_count do
                        local suit = pseudorandom_element(suits, pseudoseed('khaz_suit_' .. G.GAME.round .. '_' .. i))
                        local rank = pseudorandom_element(ranks, pseudoseed('khaz_rank_' .. G.GAME.round .. '_' .. i))
                        local card_key = suit .. "_" .. rank

                        local temp = create_card('Base', G.play, nil, nil, nil, nil, nil, 'khazgoroth')
                        temp:set_base(G.P_CARDS[card_key])
                        temp:set_ability(G.P_CENTERS.m_steel, nil, true)

                        -- Mark as temporary so we can clean it up after scoring
                        temp.is_temporary = true

                        temp:add_to_deck()
                        G.play:emplace(temp)
                        temp:juice_up()
                    end
                    return true
                end
            }))

            return {
                message = "Titanforge!",
                colour = G.C.ORANGE,
                card = card
            }
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Norgannon",
    faction = {"Horde","Alliance"},
    race = {"Titan"},
    class = {"Mage"},
    weapon = {"Staff"},
    rarity = 2,
    cost = 6,
    index = 71,

    loc_txt = {
        "Played cards with a {C:blue}Blue Seal{}",
        "give {X:mult,C:white} X#1# {} Mult",
        "when scored"
    },

    config = { extra = { x_mult = 1.5 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            
            if context.other_card:get_seal() == 'Blue' then
                return {
                    x_mult = card.ability.extra.x_mult,
                    card = context.other_card,
                    message = "Arcane Power!",
                    colour = G.C.BLUE
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Aggramar",
    faction = {"Horde","Alliance"},
    race = {"Titan"},
    class = {"Warrior"},
    weapon = {"Sword"},
    rarity = 1,
    cost = 2,
    index = 72,

    loc_txt = {
        "Held {C:attention}Steel Cards{}",
        "each give {C:mult}+#1#{} Mult"
    },

    config = { extra = { mult = 2 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.mult }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.hand then
            
            if context.other_card.config.center.key == 'm_steel' and not context.other_card.debuff then
                return {
                    message = "Defense!",
                    h_mult = card.ability.extra.mult,
                    card = context.other_card,
                    colour = G.C.RED 
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Golganneth",
    faction = {"Horde","Alliance"},
    race = {"Titan"},
    class = {"Shaman"},
    weapon = {"Hammer"},
    rarity = 1,
    cost = 3,
    index = 73,
    config = { extra = { chance = 10 } },
    loc_txt = {
        "{C:clubs}Club{} cards in played hand",
        "have a {C:green}#1# in 10{} chance to",
        "gain a random {C:attention}Edition{}"
    },
    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.chance / 10 }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            if context.other_card:is_suit("Clubs") then
                if pseudorandom('golganneth') < (card.ability.extra.chance / 100.0) then
                    local scored_card = context.other_card
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            local editions = {"foil", "holo", "polychrome"}
                            local chosen = pseudorandom_element(editions, pseudoseed('golganneth_ed_' .. G.GAME.round))
                            scored_card:set_edition({[chosen] = true}, true, true)
                            scored_card:juice_up()
                            return true
                        end
                    }))
                    return {
                        message = "Storm!",
                        colour = G.C.CHIPS,
                        card = card
                    }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Odyn",
    faction = {"Horde","Alliance"},
    race = {"Titan"},
    class = {"Warrior"},
    weapon = {"Sword","Spear","Polearm"},
    rarity = 1,
    cost = 5,
    index = 74,

    loc_txt = {
        "If you win a Blind in",
        "{C:attention}exactly #1# hand{},",
        "create a {C:attention}Double Tag{}"
    },

    config = { extra = { number = 1 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.number }
    end,

    calculate = function(self, card, context)
        
        if context.end_of_round and not context.repetition and not context.individual and not context.blueprint then
            
            if G.GAME.current_round.hands_played == card.ability.extra.number then
                
                G.E_MANAGER:add_event(Event({
                    func = function() 
                        add_tag(Tag('tag_double'))
                        play_sound('generic1', 0.9 + math.random()*0.1, 0.8)
                        play_sound('holo1', 1.2 + math.random()*0.1, 0.4)
                        return true
                    end
                }))

                return {
                    message = "Worthy!",
                    colour = G.C.GOLD,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Thorim",
    faction = {"Horde","Alliance"},
    race = {"Titan"},
    class = {"Warrior"},
    weapon = {"Hammer"},
    rarity = 1,
    cost = 4,
    index = 75,

    loc_txt = {
        "If you play a {C:attention}High Card{},",
        "upgrade the {C:attention}rank{} of",
        "the played card"
    },

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            if context.scoring_name == "High Card" then
                local played_card = context.scoring_hand[1]
                local rank_id = played_card:get_id()

                if rank_id < 14 then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            local suffixes = {"2","3","4","5","6","7","8","9","T","J","Q","K","A"}
                            local new_suffix = suffixes[rank_id] -- rank_id 2→index 2 gives "3", etc.
                            local new_key = string.sub(played_card.base.suit, 1, 1) .. "_" .. new_suffix

                            if G.P_CARDS[new_key] then
                                played_card:set_base(G.P_CARDS[new_key])
                                played_card:juice_up()
                            end
                            return true
                        end
                    }))
                    return {
                        message = "Runic Power!",
                        colour = G.C.ORANGE,
                        card = card
                    }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Tyr",
    faction = {"Horde","Alliance"},
    race = {"Titan"},
    class = {"Paladin"},
    weapon = {"Hammer"},
    rarity = 2,
    cost = 5,
    index = 76,

    loc_txt = {
        "Cards with Rank {C:attention}2, 3, or 4{}",
        "retrigger {C:attention}#1#{} additional times"
    },

    config = { extra = { retrigger = 2 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.retrigger }
    end,

    calculate = function(self, card, context)
        if context.cardarea == G.play and context.repetition and not context.repetition_only then
            
            local rank_id = context.other_card:get_id()
            
            if rank_id >= 2 and rank_id <= 4 then
                return {
                    message = "Justice!",
                    repetitions = card.ability.extra.retrigger,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Elune",
    faction = {"Alliance"},
    race = {"God"},
    class = {"Priest"},
    rarity = 3,
    cost = 9,
    index = 77,
    config = { extra = { x_chips = 1, x_mult = 1, x_gain = 0.2 } },
    loc_txt = {
        "{X:chips,C:white} X#1# {} Chips  {X:mult,C:white} X#2# {} Mult",
        "Gains {X:chips,C:white} X#3# {} Chips when a",
        "{C:attention}Night Elf{} Joker is acquired",
        "Gains {X:mult,C:white} X#3# {} Mult when a",
        "{C:attention}Night Elf{} Joker is sold"
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.x_chips,
            card.ability.extra.x_mult,
            card.ability.extra.x_gain
        }
    end,

    add_to_deck = function(self, card, from_debuff)
        if G.jokers then
            local count = 0
            for _, j in ipairs(G.jokers.cards) do
                if j ~= card and Warcraft.is_race(j, "Night Elf") then
                    count = count + 1
                end
            end
            if count > 0 then
                card.ability.extra.x_chips = card.ability.extra.x_chips + (count * card.ability.extra.x_gain)
            end
        end

        local sold = G.GAME.warcraft_night_elf_sold or 0
        if sold > 0 then
            card.ability.extra.x_mult = card.ability.extra.x_mult + (sold * card.ability.extra.x_gain)
        end

        if card.ability.extra.x_chips > 1 or card.ability.extra.x_mult > 1 then
            card_eval_status_text(card, 'extra', nil, nil, nil, {
                message = "Moon's Grace!",
                colour = G.C.PURPLE
            })
        end
    end,

    calculate = function(self, card, context)
        if context.playing_card_added and not context.blueprint then
            local added = context.card
            if added and added ~= card and Warcraft.is_race(added, "Night Elf") then
                card.ability.extra.x_chips = card.ability.extra.x_chips + card.ability.extra.x_gain
                return { message = "Moon's Grace!", colour = G.C.PURPLE, card = card }
            end
        end

        if context.selling_card and not context.blueprint then
            local sold = context.card
            if sold and sold ~= card and Warcraft.is_race(sold, "Night Elf") then
                card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.x_gain
                return { message = "Elune's Blessing!", colour = G.C.PURPLE, card = card }
            end
        end

        if context.joker_main then
            if card.ability.extra.x_chips > 1 or card.ability.extra.x_mult > 1 then
                return {
                    x_chips = card.ability.extra.x_chips,
                    Xmult_mod = card.ability.extra.x_mult,
                    colour = G.C.PURPLE
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Lilian Voss",
    faction = {"Horde"},
    race = {"Undead"},
    class = {"Rogue"},
    weapon = {"Daggers","Sword"},
    rarity = 1,
    cost = 3,
    index = 78,

    loc_txt = {
        "{C:mult}+#1#{} Mult",
        "{C:inactive}(Gains {C:mult}+#2#{C:inactive} Mult when",
        "any playing card is {C:attention}destroyed{}){}"
    },

    config = { extra = { mult = 5, gain = 5 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.mult, card.ability.extra.gain }
    end,

    calculate = function(self, card, context)
        
        if context.remove_playing_cards and not context.blueprint then
            
            local destroyed_count = #context.removed
            
            if destroyed_count > 0 then
                card.ability.extra.mult = card.ability.extra.mult + (card.ability.extra.gain * destroyed_count)
                
                return {
                    message = "Purge!",
                    colour = G.C.RED,
                    card = card
                }
            end
        end

        if context.joker_main then
            return {
                mult = card.ability.extra.mult,
                message = "Death!",
                colour = G.C.RED
            }
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Marin Noggenfogger",
    faction = {"Horde"},
    race = {"Goblin"},
    class = {"Rogue"},
    weapon = {"Daggers"},
    rarity = 2,
    cost = 5,
    index = 79,

    loc_txt = {
        "Played cards have a chance to transform:",
        "{C:green}25%{} become Rank {C:attention}King{}",
        "{C:red}25%{} become Rank {C:attention}2{}",
        "{C:inactive}(50% chance nothing happens){}"
    },

    calculate = function(self, card, context)
        
        if context.before and not context.blueprint then
            
            for i, played_card in ipairs(context.full_hand) do
                
                if played_card.config.center.key ~= 'm_stone' then
                    
                    local roll = pseudorandom('noggenfogger')
                    
                    if roll < 0.25 then
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                local new_key = string.sub(played_card.base.suit, 1, 1) .. '_K'
                                played_card:set_base(G.P_CARDS[new_key])
                                played_card:juice_up()
                                return true
                            end
                        }))
                        card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Big!", colour = G.C.ORANGE})
                    
                    elseif roll < 0.50 then
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                local new_key = string.sub(played_card.base.suit, 1, 1) .. '_2'
                                played_card:set_base(G.P_CARDS[new_key])
                                played_card:juice_up()
                                return true
                            end
                        }))
                        card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Shrink...", colour = G.C.RED})
                    end
                    
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Gazlowe",
    faction = {"Horde"},
    race = {"Goblin"},
    weapon = {"Hammer"},
    rarity = 2,
    cost = 5,
    index = 80,

    loc_txt = {
        "Discarding a {C:attention}Face Card{}",
        "earns {C:money}$#1#{}"
    },

    config = { extra = { money = 1 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.money }
    end,

    calculate = function(self, card, context)
        
        if context.discard and not context.blueprint then
            
            if context.other_card:is_face() then
                
                G.E_MANAGER:add_event(Event({
                    func = function() 
                        ease_dollars(card.ability.extra.money)
                        return true
                    end
                }))

                return {
                    message = "+$",
                    colour = G.C.MONEY,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Trade Prince Gallywix",
    faction = {"Horde"},
    race = {"Goblin"},
    class = {"Rogue"},
    weapon = {"Staff"},
    rarity = 2,
    cost = 5,
    index = 81,

    loc_txt = {
        "If you end the shop with",
        "{C:money}$#1#{}, gain {C:money}$#2#{}"
    },

    config = { extra = { money_limit = 0, money = 15 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.money_limit, card.ability.extra.money }
    end,

    calculate = function(self, card, context)
        
        if context.ending_shop then
            
            if G.GAME.dollars == card.ability.extra.money_limit then
                
                G.E_MANAGER:add_event(Event({
                    func = function() 
                        ease_dollars(card.ability.extra.money)
                        card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Payday!", colour = G.C.MONEY})
                        return true
                    end
                }))
                
                return {
                    message = "Cha-Ching!",
                    colour = G.C.MONEY,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Gelbin Mekkatorque",
    faction = {"Alliance"},
    race = {"Gnome"},
    weapon = {"Hammer"},
    rarity = 2,
    cost = 8,
    index = 82,

    config = { extra = { used_this_round = false } },

    loc_txt = {
        "If the {C:attention}first discard{} of the round",
        "is a {C:attention}single card{}, destroy it",
        "and create a {C:attention}Steel Copy{}",
        "in your hand"
    },

    calculate = function(self, card, context)

        if context.setting_blind then
            card.ability.extra.used_this_round = false
        end

        if context.discard and not card.ability.extra.used_this_round and not context.blueprint then
            
            card.ability.extra.used_this_round = true

            if #context.full_hand == 1 then
                
                local discarded_card = context.other_card
                
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local new_card = copy_card(discarded_card, nil, nil, G.playing_card)
                        new_card:set_ability(G.P_CENTERS.m_steel)
                        new_card:add_to_deck()
                        G.deck.config.card_limit = G.deck.config.card_limit + 1
                        table.insert(G.playing_cards, new_card)
                        
                        G.hand:emplace(new_card)
                        new_card:juice_up()
                        
                        discarded_card:start_dissolve()

                        return true
                    end
                }))

                return {
                    message = "Upgrade!",
                    colour = G.C.GREY,
                    card = card
                }
            else
                return {
                    message = "Missed!",
                    colour = G.C.RED,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Silas Darkmoon",
    faction = {"Alliance","Horde"},
    race = {"Gnome"}, 
    weapon = {"Fist"},
    rarity = 2,
    cost = 6,
    index = 83,

    loc_txt = {
        "When you {C:attention}Sell a Joker{},",
        "create a random",
        "{C:tarot}Tarot Card{}",
        "{C:inactive}(Must have room){}"
    },

    calculate = function(self, card, context)
        
        if context.selling_card and not context.blueprint then
            
            if context.card.ability.set == 'Joker' then
                
                if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                    
                    G.E_MANAGER:add_event(Event({
                        func = function() 
                            local new_card = create_card('Tarot', G.consumeables, nil, nil, nil, nil, nil, 'silas')
                            new_card:add_to_deck()
                            G.consumeables:emplace(new_card)
                            
                            card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Prize!", colour = G.C.PURPLE})
                            return true
                        end
                    }))
                    
                    return {
                        message = "Step Right Up!",
                        colour = G.C.PURPLE,
                        card = card
                    }
                else
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = "No Room!", colour = G.C.RED})
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Antonidas",
    faction = {"Alliance"},
    race = {"Human"},
    class = {"Mage"},
    weapon = {"Staff"},
    rarity = 1,
    cost = 5,
    index = 84,
    config = { extra = {} },
    loc_txt = {
        "Each time a {C:tarot}Tarot{} card is used,",
        "upgrade a random",
        "{C:attention}Poker Hand{}"
    },
    loc_vars = function(self, info_queue, card)
        return {}
    end,
    calculate = function(self, card, context)
        if context.using_consumeable and not context.blueprint then
            if context.consumeable.ability.set == "Tarot" then

                -- Collect all poker hand names
                local hands = {}
                for hand_name, _ in pairs(G.GAME.hands) do
                    table.insert(hands, hand_name)
                end

                if #hands > 0 then
                    local chosen = pseudorandom_element(hands, pseudoseed('antonidas_' .. G.GAME.round))
                    level_up_hand(card, chosen, false, 1)

                    return {
                        message = "Arcane Power!",
                        colour = G.C.BLUE,
                        card = card
                    }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Nathanos Blightcaller",
    faction = {"Horde"},
    race = {"Undead"},
    class = {"Hunter"},
    weapon = {"Bow","Axe"},
    rarity = 2,
    cost = 5,
    index = 85,

    loc_txt = {
        "When you discard a {C:attention}#1#{},",
        "gain {C:money}$#2#{}",
        "{C:inactive}(Target changes every Blind){}"
    },

    config = { extra = { target_rank = 'Ace', money = 4 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.target_rank, card.ability.extra.money }
    end,

    calculate = function(self, card, context)
        
        if context.setting_blind and not context.blueprint then
            local ranks = {'2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King', 'Ace'}
            card.ability.extra.target_rank = pseudorandom_element(ranks, pseudoseed('nathanos'))
            
            card_eval_status_text(card, 'extra', nil, nil, nil, {
                message = "New Bounty: " .. card.ability.extra.target_rank,
                colour = G.C.RED
            })
        end

        if context.discard and not context.blueprint then
            local discarded_rank = context.other_card.base.value 
            
            if discarded_rank == card.ability.extra.target_rank then
                
                G.E_MANAGER:add_event(Event({
                    func = function() 
                        ease_dollars(card.ability.extra.money)
                        return true
                    end
                }))

                return {
                    message = "Target Down!",
                    colour = G.C.MONEY,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Cho'Gall",
    faction = {"Legion"},
    race = {"Ogre"},
    class = {"Warlock"},
    weapon = {"Hammer"},
    rarity = 2,
    cost = 8,
    index = 86,

    loc_txt = {
        "When you use a {C:attention}Tarot{} or {C:planet}Planet{},",
        "{C:green}25%{} chance to add a",
        "copy to your consumable area",
        "{C:inactive}(Must have room){}"
    },

    calculate = function(self, card, context)
        
        if context.using_consumeable and not context.blueprint then
            
            local c_type = context.consumeable.ability.set
            if c_type == 'Tarot' or c_type == 'Planet' then
                
                if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                    
                    if pseudorandom('chogall') < 0.25 then
                        
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                local new_card = copy_card(context.consumeable, nil, nil, nil, nil)
                                new_card:add_to_deck()
                                G.consumeables:emplace(new_card)
                                return true
                            end
                        }))

                        return {
                            message = "Twisted!",
                            colour = G.C.PURPLE,
                            card = card
                        }
                    end
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Drek'Thar",
    faction = {"Horde"},
    race = {"Orc"},
    class = {"Shaman"},
    weapon = {"Hammer"},
    rarity = 2,
    cost = 7,
    index = 87,

    loc_txt = {
        "If played hand contains a {C:attention}Pair{},",
        "retrigger all scoring cards",
        "and they give {C:mult}+#1#{} Mult"
    },

    config = { extra = { mult = 5 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.mult }
    end,

    calculate = function(self, card, context)
        local function hand_contains_pair()
            return context.poker_hands and 
                context.poker_hands["Pair"] and 
                next(context.poker_hands["Pair"]) ~= nil
        end

        if context.cardarea == G.play and context.repetition and not context.repetition_only then
            if hand_contains_pair() then
                return {
                    message = "Spirits!",
                    repetitions = 1,
                    card = card
                }
            end
        end

        if context.individual and context.cardarea == G.play then
            if hand_contains_pair() then
                return {
                    mult = card.ability.extra.mult,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Garrosh Hellscream",
    faction = {"Horde"},
    race = {"Orc"},
    class = {"Warrior"},
    weapon = {"Axe"},
    rarity = 3,
    cost = 10,
    index = 88,

    loc_txt = {
        "{C:mult}+#1#{} Mult",
        "{C:inactive}(Gains Mult equal to",
        "{C:attention}Hands{} + {C:attention}Discards{}",
        "remaining when Blind is defeated){}"
    },

    config = { extra = { mult = 0 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.mult }
    end,

    calculate = function(self, card, context)
        
        if context.end_of_round and not context.repetition and not context.individual and not context.blueprint then
            
            local remaining_hands = G.GAME.current_round.hands_left
            local remaining_discards = G.GAME.current_round.discards_left
            local bonus = remaining_hands + remaining_discards
            
            if bonus > 0 then
                card.ability.extra.mult = card.ability.extra.mult + bonus
                
                return {
                    message = "Victory or Death!",
                    colour = G.C.RED,
                    card = card
                }
            end
        end

        if context.joker_main then
            if card.ability.extra.mult > 0 then
                return {
                    mult = card.ability.extra.mult,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Emperor Shaohao",
    faction = {"Alliance","Horde"},
    race = {"Pandaren"},
    class = {"Monk"},
    weapon = {"Staff"},
    rarity = 2,
    cost = 6,
    index = 89,
    loc_txt = {
        "At the start of each {C:attention}Blind{},",
        "summon a random {C:attention}Sha{} Joker"
    },
    loc_vars = function(self, info_queue, card)
        return {}
    end,
    calculate = function(self, card, context)
        if context.start_of_round and not context.blueprint then

            -- Collect all joker keys whose race includes "Sha"
            local sha_pool = {}
            for key, center in pairs(G.P_CENTERS) do
                if center.set == "Joker" and center.config and center.config.extra then
                    local race = center.config.extra.race
                    if race then
                        local race_list = type(race) == "table" and race or { race }
                        for _, r in ipairs(race_list) do
                            if r == "Sha" then
                                table.insert(sha_pool, key)
                                break
                            end
                        end
                    end
                end
            end

            if #sha_pool == 0 then return end

            -- Check joker limit
            if #G.jokers.cards >= G.jokers.config.card_limit then return end

            G.E_MANAGER:add_event(Event({
                func = function()
                    local chosen_key = pseudorandom_element(sha_pool, pseudoseed('shaohao_' .. G.GAME.round))
                    local sha = create_card('Joker', G.jokers, nil, nil, nil, nil, chosen_key, 'shaohao')
                    sha:add_to_deck()
                    G.jokers:emplace(sha)
                    sha:start_materialize()
                    card_eval_status_text(card, 'extra', nil, nil, nil, {
                        message = "The Sha Rises!",
                        colour = G.C.PURPLE
                    })
                    return true
                end
            }))
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Li Li Stormstout",
    faction = {"Alliance","Horde"},
    race = {"Pandaren"},
    class = {"Monk"},
    weapon = {"Staff","Fist"},
    rarity = 1,
    cost = 2,
    index = 90,

    loc_txt = {
        "{C:attention}+#1#{} Hand Size"
    },

    config = { extra = { h_size = 2 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.h_size }
    end,

    add_to_deck = function(self, card, from_debuff)
        G.hand.config.card_limit = G.hand.config.card_limit + card.ability.extra.h_size
    end,

    remove_from_deck = function(self, card, from_debuff)
        G.hand.config.card_limit = G.hand.config.card_limit - card.ability.extra.h_size
    end
})

Warcraft.create_warcraft_joker({
    name = "Lorewalker Cho",
    faction = {"Alliance","Horde"},
    race = {"Pandaren"},
    class = {"Monk"},
    rarity = 1,
    weapon = {"Staff","Fist"},
    cost = 5,
    index = 91,

    loc_txt = {
        "When you {C:attention}Skip a Blind{},",
        "create a {C:attention}Double Tag{}"
    },

    calculate = function(self, card, context)
        
        if context.skip_blind and not context.blueprint then
            
            G.E_MANAGER:add_event(Event({
                func = function() 
                    add_tag(Tag('tag_double'))
                    play_sound('generic1', 0.9 + math.random()*0.1, 0.8)
                    play_sound('holo1', 1.2 + math.random()*0.1, 0.4)
                    return true
                end
            }))

            return {
                message = "Story Time!",
                colour = G.C.PURPLE,
                card = card
            }
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Ji Firepaw",
    faction = {"Horde"},
    race = {"Pandaren"},
    class = {"Monk"},
    weapon = {"Staff","Fist"},
    rarity = 1,
    cost = 3,
    index = 92,

    loc_txt = {
        "Played {C:hearts}Hearts{} give",
        "{C:mult}+#1#{} Mult when scored"
    },

    config = { extra = { mult = 4 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.mult }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            
            if context.other_card:is_suit("Hearts") then
                return {
                    mult = card.ability.extra.mult,
                    card = context.other_card,
                    message = "Fire!",
                    colour = G.C.RED
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Aysa Cloudsinger",
    faction = {"Alliance"},
    race = {"Pandaren"},
    class = {"Monk"},
    weapon = {"Staff","Fist"},
    rarity = 1,
    cost = 3,
    index = 93,

    loc_txt = {
        "Played {C:clubs}Clubs{} give",
        "{C:mult}+#1#{} Mult when scored"
    },

    config = { extra = { mult = 4 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.mult }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            
            if context.other_card:is_suit("Clubs") then
                return {
                    mult = card.ability.extra.mult,
                    card = context.other_card,
                    message = "Calm...",
                    colour = G.C.BLUE
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Cairne Bloodhoof",
    faction = {"Horde"},
    race = {"Tauren"},
    class = {"Warrior"},
    weapon = {"Spear","Polearm","Hammer"},
    rarity = 3,
    cost = 8,
    index = 94,

    loc_txt = {
        "{C:attention}Prevents Death{} if chips",
        "are less than required.",
        "{C:red}Self Destructs{}, sets Chips",
        "to {C:attention}100%{} of Blind"
    },

    calculate = function(self, card, context)
        
        if context.game_over and not context.blueprint then
            
            if G.GAME.chips < G.GAME.blind.chips then
                
                G.E_MANAGER:add_event(Event({
                    func = function()
                        G.hand_text_area.blind_chips:juice_up()
                        G.hand_text_area.game_chips:juice_up()
                        play_sound('tarot1')
                        
                        G.GAME.chips = G.GAME.blind.chips
                        
                        card:start_dissolve(nil, true)
                        return true
                    end
                }))

                return {
                    message = "Reincarnation!",
                    saved = true,
                    colour = G.C.RED,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Baine Bloodhoof",
    faction = {"Horde"},
    race = {"Tauren"},
    class = {"Warrior"},
    weapon = {"Hammer"},
    rarity = 2,
    cost = 7,
    index = 95,

    loc_txt = {
        "Each {C:attention}Wild Card{} held in hand",
        "gives {X:mult,C:white} X#1# {} Mult"
    },

    config = { extra = { x_mult = 1.5 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult }
    end,

    calculate = function(self, card, context)
        
        if context.individual and context.cardarea == G.hand and not context.end_of_round then
            
            if context.other_card.ability.effect == "Wild Card" then
                
                return {
                    message = "Earthmother!",
                    x_mult = card.ability.extra.x_mult,
                    card = context.other_card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Magatha Grimtotem",
    faction = {"Horde"},
    race = {"Tauren"},
    class = {"Shaman"},
    weapon = {"Staff","Fist"},
    rarity = 2,
    cost = 6,
    index = 96,

    loc_txt = {
        "{C:mult}+#1#{} Mult",
        "At end of round, reduce the",
        "{C:attention}Sell Value{} of all Jokers by {C:money}$#2#{}",
        "and gain {C:mult}+#3#{} Mult for each {C:money}$#4#{} lost"
    },

    config = { extra = { mult = 0, money_reduce = 1, mult_gain = 1, money_gain_lost = 1 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.mult, card.ability.extra.money_reduce, card.ability.extra.mult_gain, card.ability.extra.money_gain_lost }
    end,

    calculate = function(self, card, context)
        
        if context.end_of_round and not context.repetition and not context.individual and not context.blueprint then
            
            local value_drained = 0
            
            for i = 1, #G.jokers.cards do
                local target_joker = G.jokers.cards[i]
                
                if target_joker.sell_cost > 0 then

                    if not target_joker.ability.extra_value then target_joker.ability.extra_value = 0 end
                    target_joker.ability.extra_value = target_joker.ability.extra_value - card.ability.extra.money_reduce
                    
                    target_joker:set_cost()
                    
                    value_drained = value_drained + card.ability.extra.money_reduce
                    
                    target_joker:juice_up()
                end
            end
            
            if (value_drained / card.ability.extra.money_gain_lost) > 0 then
                card.ability.extra.mult = card.ability.extra.mult + (value_drained / card.ability.extra.money_gain_lost)
                
                return {
                    message = "Betrayal!",
                    colour = G.C.RED,
                    card = card
                }
            end
        end

        if context.joker_main then
            if card.ability.extra.mult > 0 then
                return {
                    mult = card.ability.extra.mult,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Hamuul Runetotem",
    faction = {"Horde"},
    race = {"Tauren"},
    class = {"Druid"},
    weapon = {"Staff","Fist"},
    rarity = 2,
    cost = 6,
    index = 97,

    config = { extra = { used_this_blind = false } },

    loc_txt = {
        "On the {C:attention}first hand{} of each Blind,",
        "turn a random {C:attention}scoring card{}",
        "into a {C:attention}Wild Card{}"
    },

    calculate = function(self, card, context)
        
        if context.setting_blind then
            card.ability.extra.used_this_blind = false
        end

        if context.before and not context.blueprint then
            
            if not card.ability.extra.used_this_blind then
                
                if context.scoring_hand and #context.scoring_hand > 0 then
                    
                    card.ability.extra.used_this_blind = true
                    
                    local target_card = pseudorandom_element(context.scoring_hand, pseudoseed('hamuul'))
                    
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            target_card:set_ability(G.P_CENTERS.m_wild)
                            target_card:juice_up()
                            return true
                        end
                    }))

                    return {
                        message = "Nature Rises!",
                        colour = G.C.ORANGE,
                        card = card
                    }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Zul'jin",
    race = {"Troll"},
    class = {"Hunter"},
    weapon = {"Axe","Sword"},
    rarity = 2,
    cost = 6,
    index = 98,

    loc_txt = {
        "{C:mult}+#1#{} Mult",
        "{C:red}-#2#{} Discards"
    },

    config = { extra = { mult = 30, discard = 2 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.mult, card.ability.extra.discard }
    end,

    add_to_deck = function(self, card, from_debuff)
        G.GAME.round_resets.discards = G.GAME.round_resets.discards - card.ability.extra.discard
         if G.GAME.current_round.discards_left then
             G.GAME.current_round.discards_left = math.max(0, G.GAME.current_round.discards_left - card.ability.extra.discard)
        end
    end,

    remove_from_deck = function(self, card, from_debuff)
        G.GAME.round_resets.discards = G.GAME.round_resets.discards + card.ability.extra.discard
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return {
                mult = card.ability.extra.mult,
                message = "Taz'dingo!",
                colour = G.C.RED,
                card = card
            }
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Vol'jin",
    faction = {"Horde"},
    race = {"Troll"},
    class = {"Priest","Hunter"},
    weapon = {"Glaives","Polearm","Spear","Bow","Staff"},
    rarity = 2,
    cost = 5,
    index = 99,
    config = { extra = { chips = 100 } },
    loc_txt = {
        "{C:chips}+#1#{} Chips",
        "When {C:attention}sold{} or {C:attention}destroyed{},",
        "transfer all {C:attention}levels{} to the",
        "joker directly to the {C:attention}right{}"
    },
    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.chips }
    end,
    remove_from_deck = function(self, card, from_debuff)
        local voljin_idx = nil
        for i, j in ipairs(G.jokers.cards) do
            if j == card then
                voljin_idx = i
                break
            end
        end

        if not voljin_idx then return end

        local target = G.jokers.cards[voljin_idx + 1]
        if not target or not target.ability or not target.ability.extra then return end
        if not target.ability.extra.level then return end

        local levels_to_give = card.ability.extra.level or 1

        G.E_MANAGER:add_event(Event({
            func = function()
                target.ability.extra.level = target.ability.extra.level + levels_to_give
                if target.ability.extra.max_level and target.ability.extra.level > target.ability.extra.max_level then
                    target.ability.extra.max_level = target.ability.extra.level
                end
                card_eval_status_text(target, 'extra', nil, nil, nil, {
                    message = "Blessed!",
                    colour = G.C.GREEN
                })
                target:juice_up()
                return true
            end
        }))
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                chips = card.ability.extra.chips,
                card = card
            }
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Rokhan",
    faction = {"Horde"},
    race = {"Troll"},
    class = {"Hunter"},
    weapon = {"Daggers","Bow"},
    rarity = 2,
    cost = 6,
    index = 100,

    loc_txt = {
        "{C:green}1 in 3{} chance to create a",
        "{C:tarot}Tarot Card{} if played hand",
        "contains {C:attention}only Face Cards{}"
    },

    calculate = function(self, card, context)
        
        if context.before and not context.blueprint then
            
            local all_face = true
            if #context.full_hand > 0 then
                for i, played_card in ipairs(context.full_hand) do
                    if not played_card:is_face() then
                        all_face = false
                        break
                    end
                end
            else
                all_face = false 
            end

            if all_face then
                if pseudorandom('rokhan') < (1/3) then
                    
                    if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                        
                        G.E_MANAGER:add_event(Event({
                            func = function() 
                                local new_card = create_card('Tarot', G.consumeables, nil, nil, nil, nil, nil, 'rokhan')
                                new_card:add_to_deck()
                                G.consumeables:emplace(new_card)
                                return true
                            end
                        }))
                        
                        return {
                            message = "Voodoo!",
                            colour = G.C.PURPLE,
                            card = card
                        }
                    else
                        card_eval_status_text(card, 'extra', nil, nil, nil, {message = "No Room!", colour = G.C.RED})
                    end
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "King Rastakhan",
    faction = {"Horde"},
    race = {"Troll"},
    class = {"Priest"},
    weapon = {"Spear","Polearm","Sword"},
    rarity = 1,
    cost = 4,
    index = 101,

    loc_txt = {
        "{C:attention}Kings{} retrigger",
        "{C:attention}#1#{} additional time"
    },

    config = { extra = { retrigger = 1 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.retrigger }
    end,

    calculate = function(self, card, context)
        
        if context.cardarea == G.play and context.repetition and not context.repetition_only then
            
            if context.other_card:get_id() == 13 then
                return {
                    message = "Zandalar Forever!",
                    repetitions = card.ability.extra.retrigger,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Bwonsamdi",
    faction = {"Horde"},
    race = {"Troll","God","Loa"},
    class = {"Priest"},
    weapon = {"Polearm","Fist"},
    rarity = 3,
    cost = 10,
    index = 102,
    config = { extra = { x_mult = 1, x_mult_gain = 0.1 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "Gains {X:mult,C:white} X#2# {} Mult",
        "each time a {C:attention}Joker{} is sold"
    },
    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult, card.ability.extra.x_mult_gain }
    end,
    add_to_deck = function(self, card, from_debuff)
        -- Initialize retroactively from all jokers sold before acquiring Bwonsamdi
        local already_sold = G.GAME.warcraft_jokers_sold or 0
        if already_sold > 0 then
            card.ability.extra.x_mult = 1 + (already_sold * card.ability.extra.x_mult_gain)
            card_eval_status_text(card, 'extra', nil, nil, nil, {
                message = "Da Collection!",
                colour = G.C.PURPLE
            })
        end
    end,
    calculate = function(self, card, context)
        if context.selling_card and not context.blueprint then
            local sold = context.card
            if sold and sold.config and sold.config.center and sold.config.center.set == "Joker" then
                card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.x_mult_gain
                return {
                    message = "A Soul for Bwonsamdi!",
                    colour = G.C.PURPLE,
                    card = card
                }
            end
        end

        if context.joker_main then
            if card.ability.extra.x_mult > 1 then
                return {
                    x_mult = card.ability.extra.x_mult,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Leeroy Jenkins",
    faction = {"Alliance"},
    race = {"Human"},
    class = {"Paladin"},
    weapon = {"Sword"},
    rarity = 2,
    cost = 5,
    index = 103,

    loc_txt = {
        "{C:chips}+#1#{} Chips",
        "{C:red}Discards entire hand{}",
        "after playing"
    },

    config = { extra = { chips = 100 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.chips }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return {
                chips = card.ability.extra.chips,
                card = card
            }
        end

        if context.after and not context.blueprint then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function() 
                    local cards = {}
                    for _, v in ipairs(G.hand.cards) do table.insert(cards, v) end
                    for _, v in ipairs(cards) do
                        draw_card(G.hand, G.discard, 90, 'down', false, v)
                    end
                    return true 
                end
            }))
            return {
                message = "Leeeeeroy!",
                colour = G.C.RED,
                card = card
            }
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Edwin VanCleef",
    race = {"Human"},
    class = {"Rogue"},
    weapon = {"Daggers","Sword"},
    rarity = 2,
    cost = 6,
    index = 104,

    config = { extra = { mult = 2, gain = 0.5 } },

    loc_txt = {
        "{C:mult}+#1#{} Mult",
        "{C:inactive}(Gains {C:mult}+#2#{} Mult for",
        "every {C:attention}scoring card{} played){}"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.mult, card.ability.extra.gain }
    end,

    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.before and not context.blueprint then
            local count = #context.scoring_hand
            if count > 0 then
                card.ability.extra.mult = card.ability.extra.mult + (card.ability.extra.gain * count)
                return {
                    message = "Combo!",
                    colour = G.C.RED,
                    card = card
                }
            end
        end

        if context.joker_main then
            return {
                mult = card.ability.extra.mult,
                card = card
            }
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Prince Malchezaar",
    faction = {"Legion"},
    race = {"Demon"},
    class = {"Warlock"},
    weapon = {"Axe"},
    rarity = 3,
    cost = 8,
    index = 105,

    config = { extra = { count = 5 } },

    loc_txt = {
        "When {C:attention}Boss Blind{} is defeated,",
        "add {C:attention}#1#{} Random Enhanced",
        "cards to your deck"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.count }
    end,

    calculate = function(self, card, context)
        if context.end_of_round and not context.repetition and not context.individual and not context.blueprint then
            if G.GAME.blind.boss then
                G.E_MANAGER:add_event(Event({
                    func = function() 
                        for i = 1, card.ability.extra.count do
                            local _card = create_card('Base', G.pack_cards, nil, nil, true, true, nil, 'malchezaar')
                            local edition = poll_edition('malchezaar_ed', nil, true, true)
                            _card:set_edition(edition, true)
                            local enhancement = pseudorandom_element(G.P_CENTER_POOLS.Enhanced, pseudoseed('malchezaar'))
                            _card:set_ability(enhancement)
                            _card:add_to_deck()
                            G.deck:emplace(_card)
                            G.deck:shuffle('malchezaar_shuffle')
                        end
                        return true
                    end
                }))
                
                return {
                    message = "Legion!",
                    colour = G.C.PURPLE,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Bolvar Fordragon",
    faction = {"Alliance","Scourge"},
    class = {"Paladin","Death Knight"},
    weapon = {"Hammer","Shield"},
    rarity = 2,
    cost = 6,
    index = 106,

    config = { extra = { gain = 1 } },

    loc_txt = {
        "{C:attention}Stone Cards{} permanently",
        "gain {C:mult}+#1#{} Mult when scored"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.gain }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card.config.center.key == 'm_stone' then
                
                context.other_card.ability.perma_mult = (context.other_card.ability.perma_mult or 0) + card.ability.extra.gain
                
                return {
                    mult = context.other_card.ability.perma_mult,
                    message = "Upgrade!",
                    colour = G.C.RED,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Turalyon",
    faction = {"Alliance"},
    race = {"Human"},
    class = {"Paladin"},
    weapon = {"Sword","Shield"},
    rarity = 1,
    cost = 4,
    index = 107,

    config = { extra = { chips = 50, mult = 5 } },

    loc_txt = {
        "Scoring {C:money}Gold Cards{} give",
        "{C:chips}+#1#{} Chips and {C:mult}+5{} Mult"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.chips, card.ability.extra.mult }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card.config.center.key == 'm_gold' then
                return {
                    chips = card.ability.extra.chips,
                    mult = card.ability.extra.mult,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Danath Trollbane",
    faction = {"Alliance"},
    race = {"Human"},
    class = {"Warrior"},
    weapon = {"Sword","Shield"},
    rarity = 1,
    cost = 3,
    index = 108,

    config = { extra = { gain = 50 } },

    loc_txt = {
        "{C:chips}+#1#{} Chips",
        "{C:inactive}(+#2# per Ante completed){}"
    },

    loc_vars = function(self, info_queue, card)
        local current_bonus = card.ability.extra.gain * math.max(0, G.GAME.round_resets.ante - 1)
        return { current_bonus, card.ability.extra.gain }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return {
                chips = card.ability.extra.gain * math.max(0, G.GAME.round_resets.ante - 1),
                card = card
            }
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Matthias Shaw",
    faction = {"Alliance"},
    race = {"Human"},
    class = {"Rogue"},
    weapon = {"Daggers","Sword"},
    rarity = 2,
    cost = 8,
    index = 109,

    config = { extra = { slots = 1 } },

    loc_txt = {
        "{C:dark_edition}+#1#{} Joker Slot"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.slots }
    end,

    add_to_deck = function(self, card, from_debuff)
        G.jokers.config.card_limit = G.jokers.config.card_limit + card.ability.extra.slots
    end,

    remove_from_deck = function(self, card, from_debuff)
        G.jokers.config.card_limit = G.jokers.config.card_limit - card.ability.extra.slots
    end
})

Warcraft.create_warcraft_joker({
    name = "Genn Greymane",
    faction = {"Alliance"},
    race = {"Worgen"},
    class = {"Warrior"},
    weapon = {"Sword","Gun","Fist"},
    rarity = 1,
    cost = 6,
    index = 110,

    config = { extra = { mult = 4, chips = 20 } },

    loc_txt = {
        "Played cards with {C:attention}Even Rank{}",
        "{C:mult}+#1#{} Mult and {C:chips}+#2#{} Chips"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.mult, card.ability.extra.chips }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local id = context.other_card:get_id()
            if id and id >= 2 and id <= 10 and id % 2 == 0 then
                return {
                    mult = card.ability.extra.mult,
                    chips = card.ability.extra.chips,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Tess Greymane",
    faction = {"Alliance"},
    race = {"Human"},
    class = {"Rogue"},
    weapon = {"Daggers", "Sword", "Gun"},
    rarity = 3,
    cost = 10,
    index = 111,

    loc_txt = {
        "When {C:attention}Sold{}, create a",
        "copy of the {C:attention}left-most Joker{}",
        "{C:inactive}(Excluding Tess Greymane){}"
    },

    calculate = function(self, card, context)
        if context.selling_self and not context.blueprint then
            local target_joker = nil
            
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] ~= card then
                    target_joker = G.jokers.cards[i]
                    break
                end
            end

            if target_joker then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local new_card = copy_card(target_joker, nil, nil, nil, target_joker.edition and target_joker.edition.negative)
                        new_card:add_to_deck()
                        G.jokers:emplace(new_card)
                        new_card:start_materialize()
                        return true
                    end
                }))
                return {
                    message = "Thief!",
                    colour = G.C.PURPLE
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Vanessa VanCleef",
    race = {"Human"},
    class = {"Rogue"},
    weapon = {"Daggers"},
    rarity = 2,
    cost = 6,
    index = 112,

    config = { extra = { mult = 4 } },

    loc_txt = {
        "{C:mult}+#1#{} Mult for every",
        "card in your {C:attention}Discard Pile{}",
        "{C:inactive}(Currently {C:mult}+#2#{C:inactive} Mult){}"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.mult, card.ability.extra.mult * #G.discard.cards }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local bonus = card.ability.extra.mult * #G.discard.cards
            if bonus > 0 then
                return {
                    mult = bonus,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Orgrim Doomhammer",
    faction = {"Horde"},
    race = {"Orc"},
    class = {"Warrior"},
    weapon = {"Hammer"},
    rarity = 2,
    cost = 6,
    index = 113,

    config = { extra = { chips = 100 } },

    loc_txt = {
        "{C:chips}+#1#{} Chips for every",
        "{C:attention}Horde{} Joker you have",
        "{C:inactive}(Currently {C:chips}+#2#{C:inactive} Chips){}"
    },

    loc_vars = function(self, info_queue, card)
        local horde_count = 0
        if G.jokers then
            for _, v in ipairs(G.jokers.cards) do
                if v.ability.extra_center and v.ability.extra_center.faction == "Horde" then
                    horde_count = horde_count + 1
                end
            end
        end
        return { card.ability.extra.chips, card.ability.extra.chips * horde_count }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local horde_count = 0
            for _, v in ipairs(G.jokers.cards) do
                if v.ability.extra_center and v.ability.extra_center.faction == "Horde" then
                    horde_count = horde_count + 1
                end
            end
            
            if horde_count > 0 then
                return {
                    chips = card.ability.extra.chips * horde_count,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Durotan",
    faction = {"Horde"},
    race = {"Orc"},
    class = {"Warrior"},
    weapon = {"Axe"},
    rarity = 2,
    cost = 6,
    index = 114,

    loc_txt = {
        "If chips are less than {C:attention}50%{}",
        "of Blind after {C:attention}First Hand{},",
        "gain {X:mult,C:white} X#1# {} Mult",
        "{C:inactive}(Stacks after every hand for rest of round){}",
        "{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult){}"
    },

    config = { extra = { current_mult = 1, mult_gain = 1, active = false } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.mult_gain, card.ability.extra.current_mult }
    end,

    calculate = function(self, card, context)
        
        if context.setting_blind then
            card.ability.extra.current_mult = 1
            card.ability.extra.active = false
        end

        if context.after and not context.blueprint then
            
            if G.GAME.current_round.hands_played == 0 then
                if G.GAME.chips < (G.GAME.blind.chips * 0.5) then
                    card.ability.extra.active = true
                    card.ability.extra.current_mult = card.ability.extra.current_mult + card.ability.extra.mult_gain
                    return {
                        message = "Survival!",
                        colour = G.C.RED,
                        card = card
                    }
                end
            
            elseif card.ability.extra.active then
                card.ability.extra.current_mult = card.ability.extra.current_mult + card.ability.extra.mult_gain
                return {
                    message = "Rising!",
                    colour = G.C.RED,
                    card = card
                }
            end
        end

        if context.joker_main then
            if card.ability.extra.current_mult > 1 then
                return {
                    x_mult = card.ability.extra.current_mult,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Draka",
    faction = {"Horde"},
    race = {"Orc"},
    class = {"Warrior"},
    weapon = {"Daggers","Axe"},
    rarity = 2,
    cost = 6,
    index = 115,

    loc_txt = {
        "Played cards that are",
        "{C:attention}Face Down{} give",
        "{X:mult,C:white} X#1# {} Mult"
    },

    config = { extra = { x_mult = 4 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card.facing == 'back' then
                return {
                    x_mult = card.ability.extra.x_mult,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Eitrigg",
    faction = {"Horde"},
    race = {"Orc"},
    class = {"Warrior"},
    weapon = {"Sword","Axe"},
    rarity = 1,
    cost = 5,
    index = 116,

    config = { extra = { chips = 20, gain = 1 } },

    loc_txt = {
        "{C:chips}+#1#{} Chips",
        "{C:inactive}(Gains {C:chips}+#2#{C:inactive} Chips for every",
        "card remaining in deck at end of round){}"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.chips, card.ability.extra.gain }
    end,

    calculate = function(self, card, context)
        if context.end_of_round and not context.repetition and not context.individual and not context.blueprint then
            local deck_count = #G.deck.cards
            if deck_count > 0 then
                card.ability.extra.chips = card.ability.extra.chips + (deck_count * card.ability.extra.gain)
                return {
                    message = "Honor!",
                    colour = G.C.BLUE,
                    card = card
                }
            end
        end

        if context.joker_main then
            return {
                chips = card.ability.extra.chips,
                card = card
            }
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Nazgrel",
    faction = {"Horde"},
    race = {"Orc"},
    class = {"Warrior"},
    weapon = {"Axe"},
    rarity = 1,
    cost = 4,
    index = 117,

    loc_txt = {
        "{C:chips}+#1#{} Chips and {C:mult}+#2#{} Mult",
        "if scoring hand contains",
        "exactly {C:attention}one Face Card{}"
    },

    config = { extra = { chips = 100, mult = 2 } },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.chips, card.ability.extra.mult }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local face_count = 0
            for k, v in ipairs(context.scoring_hand) do
                if v:is_face() then face_count = face_count + 1 end
            end

            if face_count == 1 then
                return {
                    chips = card.ability.extra.chips,
                    mult = card.ability.extra.mult,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Kilrogg Deadeye",
    faction = {"Horde"},
    race = {"Orc"},
    class = {"Warrior"},
    weapon = {"Axe"},
    rarity = 2,
    cost = 6,
    index = 118,

    config = { extra = { rounds = 3, x_mult = 3 } },

    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "{C:red}Self Destructs{} in",
        "{C:attention}#2#{} rounds"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult, card.ability.extra.rounds }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return {
                x_mult = card.ability.extra.x_mult,
                card = card
            }
        end

        if context.end_of_round and not context.repetition and not context.individual and not context.blueprint then
            card.ability.extra.rounds = card.ability.extra.rounds - 1
            if card.ability.extra.rounds <= 0 then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('tarot1')
                        card.T.r = -0.2
                        card:start_dissolve(nil, true)
                        return true
                    end
                }))
                return {
                    message = "Destiny!",
                    colour = G.C.RED
                }
            else
                return {
                    message = card.ability.extra.rounds.. " Left",
                    colour = G.C.RED,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Blackhand",
    faction = {"Horde"},
    race = {"Orc"},
    class = {"Warrior"},
    weapon = {"Hammer"},
    rarity = 2,
    cost = 6,
    index = 119,

    config = { extra = { mult = 15 } },

    loc_txt = {
        "{C:mult}+#1#{} Mult for every",
        "{C:attention}Steel Card{} in your deck",
        "{C:inactive}(Currently {C:mult}+#2#{C:inactive} Mult){}"
    },

    loc_vars = function(self, info_queue, card)
        local steel_count = 0
        if G.playing_cards then
            for _, v in ipairs(G.playing_cards) do
                if v.config.center == G.P_CENTERS.m_steel then
                    steel_count = steel_count + 1
                end
            end
        end
        return { card.ability.extra.mult, card.ability.extra.mult * steel_count }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local steel_count = 0
            if G.playing_cards then
                for _, v in ipairs(G.playing_cards) do
                    if v.config.center == G.P_CENTERS.m_steel then
                        steel_count = steel_count + 1
                    end
                end
            end

            if steel_count > 0 then
                return {
                    mult = card.ability.extra.mult * steel_count,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Varok Saurfang",
    faction = {"Horde"},
    race = {"Orc"},
    class = {"Warrior"},
    weapon = {"Axe"},
    rarity = 1,
    cost = 6,
    index = 120,

    config = { extra = { dollars = 5, mult_gain = 10, current_mult = 0 } },

    loc_txt = {
        "If you win a round with",
        "{C:attention}0 Discards{} used,",
        "gain {C:money}$#1#{} and {C:mult}+#2#{} Mult",
        "{C:inactive}(Currently {C:mult}+#3#{C:inactive} Mult){}"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.dollars, card.ability.extra.mult_gain, card.ability.extra.current_mult }
    end,

    calculate = function(self, card, context)
        if context.end_of_round and not context.repetition and not context.individual and not context.blueprint then
            if G.GAME.current_round.discards_used == 0 then
                card.ability.extra.current_mult = card.ability.extra.current_mult + card.ability.extra.mult_gain
                ease_dollars(card.ability.extra.dollars)
                return {
                    message = "Honor!",
                    colour = G.C.RED,
                    card = card
                }
            end
        end

        if context.joker_main then
            if card.ability.extra.current_mult > 0 then
                return {
                    mult = card.ability.extra.current_mult,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Samuro",
    faction = {"Horde"},
    race = {"Orc"},
    class = {"Warrior"},
    weapon = {"Sword"},
    rarity = 2,
    cost = 6,
    index = 121,

    config = { extra = { count = 0, x_mult = 3 } },

    loc_txt = {
        "Every {C:attention}4th{} played hand",
        "scores {X:mult,C:white} X#1# {} Mult",
        "{C:inactive}(Hand #2#){}"
    },

    loc_vars = function(self, info_queue, card)
        local current_hand = (card.ability.extra.count % 4) + 1
        return { card.ability.extra.x_mult, current_hand }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            if (card.ability.extra.count + 1) % 4 == 0 then
                return {
                    x_mult = card.ability.extra.x_mult,
                    card = card
                }
            end
        end

        if context.after and not context.blueprint then
            card.ability.extra.count = card.ability.extra.count + 1
            return {
                message = "Training...",
                colour = G.C.ORANGE,
                card = card
            }
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Lei Shen",
    race = {"Mogu"},    
    class = {"Shaman"},
    weapon = {"Polearm","Axe"},
    rarity = 1,
    cost = 6,
    index = 122,
    config = { extra = {} },
    loc_txt = {
        "Scoring {C:clubs}Club{} cards permanently",
        "gain {C:chips}+Chips{} equal to the number",
        "of {C:clubs}Clubs{} in your deck"
    },
    loc_vars = function(self, info_queue, card)
        return {}
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:is_suit('Clubs') then
                -- Count Club cards in the full deck
                local club_count = 0
                if G.playing_cards then
                    for _, c in ipairs(G.playing_cards) do
                        if c:is_suit('Clubs') then
                            club_count = club_count + 1
                        end
                    end
                end

                if club_count > 0 then
                    context.other_card.ability.bonus = (context.other_card.ability.bonus or 0) + club_count

                    G.E_MANAGER:add_event(Event({
                        func = function()
                            context.other_card:juice_up()
                            return true
                        end
                    }))

                    return {
                        chips = club_count,
                        message = "Charged!",
                        colour = G.C.CLUBS,
                        card = card
                    }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Xavius",
    faction = {"Legion"},
    race = {"Demon"},
    class = {"Warlock"},
    weapon = {"Fist"},
    rarity = 2,
    cost = 5,
    index = 123,

    config = { extra = { Xmult = 2, h_size = -1 } },

    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "{C:attention}#2#{} Hand Size"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.Xmult, card.ability.extra.h_size }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return {
                x_mult = card.ability.extra.Xmult,
                card = card
            }
        end
    end,

    add_to_deck = function(self, card, from_debuff)
        G.hand:change_size(card.ability.extra.h_size)
    end,

    remove_from_deck = function(self, card, from_debuff)
        G.hand:change_size(-card.ability.extra.h_size)
    end
})

Warcraft.create_warcraft_joker({
    name = "Hakkar the Soulflayer",
    race = {"Loa","Beast"},
    class = {"Warlock"},
    weapon = {"Fist"},
    rarity = 3,
    cost = 8,
    index = 124,

    config = { extra = { chance = 5, gain = 15, mult = 0 } },

    loc_txt = {
        "When a card scores, {C:green}1 in #1#{}",
        "chance to destroy it.",
        "If destroyed, gain {C:mult}+#2#{} Mult",
        "{C:inactive}(Currently {C:mult}+#3#{C:inactive} Mult){}"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.chance, card.ability.extra.gain, card.ability.extra.mult }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
             if pseudorandom('hakkar') < G.GAME.probabilities.normal / card.ability.extra.chance then
                
                context.other_card.destroyed = true
                
                card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.gain
                
                return {
                    remove = true,
                    message = "Corrupted Blood!",
                    colour = G.C.RED,
                    card = card
                }
            end
        end

        if context.joker_main then
            if card.ability.extra.mult > 0 then
                return {
                    mult = card.ability.extra.mult,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Nefarian",
    race = {"Dragon"},
    class = {"Mage"},
    weapon = {"Sword","Fist"},
    rarity = 3,
    cost = 8,
    index = 125,

    config = { extra = { current_rank = 'Ace', x_mult = 2 } },

    loc_txt = {
        "At start of round, select",
        "a random {C:attention}Rank{}. Cards of that",
        "Rank give {X:mult,C:white} X#1# {} Mult",
        "{C:inactive}(Current: {C:attention}#2#{C:inactive}){}"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult, card.ability.extra.current_rank }
    end,

    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            local ranks = {'2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King', 'Ace'}
            card.ability.extra.current_rank = pseudorandom_element(ranks, pseudoseed('nefarian'))
            
            return {
                message = card.ability.extra.current_rank.."!",
                colour = G.C.PURPLE
            }
        end

        if context.individual and context.cardarea == G.play then
            if context.other_card.base.value == card.ability.extra.current_rank then
                return {
                    x_mult = card.ability.extra.x_mult,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Wrathion",
    faction = {"Alliance"},
    race = {"Dragon"},
    class = {"Rogue"},
    weapon = {"Daggers","Fist"},
    rarity = 3,
    cost = 8,
    index = 126,

    loc_txt = {
        "If you play a {C:attention}Royal Flush{},",
        "create a random {C:red}Rare Joker{}",
        "{C:inactive}(Must have room){}"
    },

    calculate = function(self, card, context)
        if context.joker_main then
            if context.scoring_name == 'Royal Flush' then
                
                if #G.jokers.cards < G.jokers.config.card_limit then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            local new_card = create_card('Joker', G.jokers, nil, 0.99, nil, nil, nil, 'wrathion')
                            new_card:add_to_deck()
                            G.jokers:emplace(new_card)
                            new_card:start_materialize()
                            return true
                        end
                    }))
                    
                    return {
                        message = "Destiny!",
                        colour = G.C.PURPLE,
                        card = card
                    }
                else
                    return {
                        message = "No Room!",
                        colour = G.C.RED,
                        card = card
                    }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Sabellian",
    race = {"Dragon"},
    class = {"Warrior"},
    weapon = {"Sword","Fist"},
    rarity = 2,
    cost = 6,
    index = 127,

    config = { extra = { chips = 50, mult = 5 } },

    loc_txt = {
        "{C:attention}Odd Ranked{} cards give",
        "{C:chips}+#1#{} Chips and {C:mult}+#2#{} Mult",
        "when scored"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.chips, card.ability.extra.mult }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local id = context.other_card:get_id()
            if (id > 0 and id < 11 and id % 2 == 1) or id == 14 then
                return {
                    chips = card.ability.extra.chips,
                    mult = card.ability.extra.mult,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Ebyssian",
    faction = {"Horde"},
    race = {"Dragon","Tauren"},
    class = {"Shaman"},
    weapon = {"Staff","Fist"},
    rarity = 1,
    cost = 3,
    index = 128,

    config = { extra = { chips = 50, mult = 3 } },

    loc_txt = {
        "{C:chips}+#1#{} Chips and {C:mult}+#2#{} Mult",
        "when a {C:attention}6{} is scored"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.chips, card.ability.extra.mult }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:get_id() == 6 then
                return {
                    chips = card.ability.extra.chips,
                    mult = card.ability.extra.mult,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Al'Akir the Windlord",
    race = {"Elemental"},
    class = {"Shaman"},
    weapon = {"Sword"},
    rarity = 3,
    cost = 8,
    index = 129,

    config = { extra = { repetitions = 2 } },

    loc_txt = {
        "Retrigger the {C:attention}first played card{}",
        "{C:attention}#1#{} times and give it",
        "a permanent {C:red}Red Seal{}"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.repetitions }
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            if context.scoring_hand and #context.scoring_hand > 0 then
                local first_card = context.scoring_hand[1]
                if first_card and first_card:get_seal() ~= 'Red' then
                    first_card:set_seal('Red', true, true)
                    return {
                        message = "Windfury!",
                        colour = G.C.RED,
                        card = card
                    }
                end
            end
        end

        if context.repetition and context.cardarea == G.play then
            if context.scoring_hand and context.other_card == context.scoring_hand[1] then
                return {
                    message = "Windfury!",
                    repetitions = card.ability.extra.repetitions,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Baron Geddon",
    race = {"Elemental"},
    class = {"Mage"},
    weapon = {"Fist"},
    rarity = 2,
    cost = 6,
    index = 130,

    config = { extra = { x_mult = 4 } },

    loc_txt = {
        "If played hand contains exactly",
        "{C:attention}one Red Card{}, destroy it",
        "and deal {X:mult,C:white} X#1# {} Mult"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult }
    end,

    calculate = function(self, card, context)
        
        if context.joker_main then
            local red_cards = {}
            for k, v in ipairs(context.scoring_hand) do
                if v:is_suit('Hearts') or v:is_suit('Diamonds') then
                    table.insert(red_cards, v)
                end
            end

            if #red_cards == 1 then
                local bomb_card = red_cards[1]
                
                G.E_MANAGER:add_event(Event({
                    func = function()
                        bomb_card.destroyed = true 
                        bomb_card:start_dissolve(nil, true)
                        return true
                    end
                }))

                return {
                    message = "Living Bomb!",
                    colour = G.C.RED,
                    x_mult = card.ability.extra.x_mult,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Majordomo Executus",
    race = {"Elemental"},
    class = {"Mage"},
    weapon = {"Staff"},
    rarity = 1,
    cost = 4,
    index = 131,

    config = { extra = { threshold = 8, mult = 30 } },

    loc_txt = {
        "If you have {C:attention}#1# or more{}",
        "cards in hand after playing,",
        "gain {C:mult}+#2#{} Mult"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.threshold, card.ability.extra.mult }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            if #G.hand.cards >= card.ability.extra.threshold then
                return {
                    mult = card.ability.extra.mult,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Mekgineer Thermaplugg",
    race = {"Gnome"},
    weapon = {"Hammer","Fist"},
    rarity = 2,
    cost = 6,
    index = 132,

    config = { extra = { mult = 25, chance = 6 } },

    loc_txt = {
        "{C:mult}+#1#{} Mult",
        "{C:green}1 in #2#{} chance to",
        "set score to {C:attention}0{}",
        "{C:inactive}(Radiation Leak!){}"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.mult, card.ability.extra.chance }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local failure = false
            if pseudorandom('thermaplugg') < G.GAME.probabilities.normal / card.ability.extra.chance then
                failure = true
            end

            if failure then
                return {
                    mult = card.ability.extra.mult,
                    x_mult = 0,
                    message = "Radiation!",
                    colour = G.C.GREEN,
                    card = card
                }
            else
                return {
                    mult = card.ability.extra.mult,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Hogger",
    race = {"Beast"},
    class = {"Warrior"},
    weapon = {"Hammer","Fist"},
    rarity = 1,
    cost = 2,
    index = 133,

    config = { extra = { chips = 50, mult = 5 } },

    loc_txt = {
        "Played {C:attention}2s, 3s, and 4s{}",
        "give {C:chips}+#1#{} Chips and",
        "{C:mult}+#2#{} Mult when scored"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.chips, card.ability.extra.mult }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local rank = context.other_card:get_id()
            if rank >= 2 and rank <= 4 then
                return {
                    chips = card.ability.extra.chips,
                    mult = card.ability.extra.mult,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Archmage Arugal",
    race = {"Human"},
    class = {"Mage"},
    weapon = {"Fist"},
    rarity = 2,
    cost = 6,
    index = 134,

    config = { extra = { chance = 6 } },

    loc_txt = {
        "Scoring {C:attention}Face Cards{} have",
        "{C:green}1 in #1#{} chance to become",
        "{C:attention}Wild Cards{} after scoring"
    },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_wild
        return { card.ability.extra.chance }
    end,

    calculate = function(self, card, context)
        if context.after and not context.blueprint then
            for i = 1, #context.scoring_hand do
                local other_card = context.scoring_hand[i]
                if other_card:is_face() and other_card.config.center ~= G.P_CENTERS.m_wild then
                    if pseudorandom('arugal') < G.GAME.probabilities.normal / card.ability.extra.chance then
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                other_card:set_ability(G.P_CENTERS.m_wild, nil, true)
                                other_card:juice_up()
                                return true
                            end
                        }))

                        return {
                            message = "Curse!",
                            colour = G.C.PURPLE,
                            card = card
                        }
                    end
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Darkmaster Gandling",
    faction = {"Scourge"}, 
    race = {"Human"},
    class = {"Warlock"}, 
    weapon = {"Staff"},
    rarity = 1,
    cost = 4,
    index = 135,

    loc_txt = {
        "If you discard exactly",
        "{C:attention}2 Face Cards{}, transform",
        "them into {C:attention}Stone Cards{}"
    },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_stone
        return { }
    end,

    calculate = function(self, card, context)
        if context.discard and not context.blueprint then
            local face_count = 0
            for _, v in ipairs(context.full_hand) do
                if v:is_face() then
                    face_count = face_count + 1
                end
            end
            if face_count == 2 and context.other_card:is_face() then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        context.other_card:set_ability(G.P_CENTERS.m_stone, nil, true)
                        context.other_card:juice_up()
                        return true
                    end
                }))

                return {
                    message = "Arise!",
                    colour = G.C.GREY,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Sindragosa",
    faction = {"Scourge"}, 
    race = {"Dragon"}, 
    class = {"Mage"}, 
    weapon = {"Fist"},
    rarity = 2,
    cost = 8,
    index = 136,

    loc_txt = {
        "When a {C:attention}Glass Card{} shatters,",
        "add {C:attention}2 copies{} of it to",
        "your deck"
    },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_glass
        return { }
    end,

    calculate = function(self, card, context)
        if context.remove_playing_cards and not context.blueprint then
            local shattered_glass = false
            
            for k, v in ipairs(context.removed) do
                if v.shattered then 
                    shattered_glass = true
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            for i = 1, 2 do
                                local new_card = copy_card(v, nil, nil, G.playing_card)
                                new_card:add_to_deck()
                                G.deck.config.card_limit = G.deck.config.card_limit + 1
                                table.insert(G.playing_cards, new_card)
                                G.deck:emplace(new_card)
                                new_card.shattered = nil
                                new_card.destroyed = nil
                            end
                            card:juicr()
                            return true
                        end
                    }))
                end
            end

            if shattered_glass then
                return {
                    message = "Risen!",
                    colour = G.C.BLUE,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Fyrakk",
    race = {"Dragon"},
    class = {"Warrior"},
    weapon = {"Axe","Fist"},
    rarity = 2,
    cost = 6,
    index = 137,
    config = { extra = { chance = 20 } },
    loc_txt = {
        "Scoring {C:attention}Steel {C:hearts}Heart{} Cards{}",
        "have a {C:green}#1# in 5{} chance to",
        "create a {C:spectral}Spectral{} card"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_steel
        return { card.ability.extra.chance / 20 }
    end,
    calculate = function(self, card, context)
        -- Triggers for cards scored in hand (held in hand scoring)
        local is_held_steel_heart = context.individual
            and context.cardarea == G.hand
            and context.other_card.config.center == G.P_CENTERS.m_steel
            and context.other_card:is_suit("Hearts")

        -- Triggers for cards scored in played hand
        local is_played_steel_heart = context.individual
            and context.cardarea == G.play
            and context.other_card.config.center == G.P_CENTERS.m_steel
            and context.other_card:is_suit("Hearts")

        if (is_held_steel_heart or is_played_steel_heart) and not context.blueprint then
            if pseudorandom('fyrakk') < (card.ability.extra.chance / 100.0) then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        if #G.consumeables.cards < G.consumeables.config.card_limit then
                            local spectral = create_card('Spectral', G.consumeables, nil, nil, nil, nil, nil, 'fyrakk')
                            spectral:add_to_deck()
                            G.consumeables:emplace(spectral)
                            spectral:juice_up()
                        else
                            card_eval_status_text(card, 'extra', nil, nil, nil, {
                                message = "No Room!",
                                colour = G.C.RED
                            })
                        end
                        return true
                    end
                }))
                return {
                    message = "Shadowflame!",
                    colour = G.C.RED,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Emberthal",
    race = {"Dragon"},
    class = {"Evoker"},
    weapon = {"Sword"},
    rarity = 1,
    cost = 5,
    index = 138,

    config = { extra = { chance = 2 } },

    loc_txt = {
        "{C:green}#1# in #2#{} chance to upgrade",
        "level of played {C:attention}poker hand{}"
    },

    loc_vars = function(self, info_queue, card)
        return { G.GAME.probabilities.normal, card.ability.extra.chance }
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            if pseudorandom('emberthal') < G.GAME.probabilities.normal / card.ability.extra.chance then
                level_up_hand(card, context.scoring_name, false, 1)
                
                return {
                    message = "Level Up!",
                    colour = G.C.PURPLE, 
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Sarkareth",
    race = {"Dragon"},
    class = {"Evoker"},
    weapon = {"Sword", "Fist"},
    rarity = 3,
    cost = 8,
    index = 139,
    blueprint_compat = true,

    loc_txt = {
        "Copies the ability of the",
        "{C:attention}Joker to the right{},",
        "but {C:attention}destroys it{} at",
        "the end of the round",
        "{C:inactive}(Must be compatible){}"
    },

    loc_vars = function(self, info_queue, card)
        return { }
    end,

    calculate = function(self, card, context)
        if context.end_of_round and not context.repetition and not context.blueprint and not context.individual then
             local my_pos = nil
             for i = 1, #G.jokers.cards do
                 if G.jokers.cards[i] == card then my_pos = i; break end
             end
             if my_pos and G.jokers.cards[my_pos + 1] then
                 local victim = G.jokers.cards[my_pos + 1]
                 if not victim.ability.eternal and not victim.getting_sliced then 
                     G.E_MANAGER:add_event(Event({
                         func = function()
                             victim.getting_sliced = true 
                             card:juice_up(0.8, 0.8)
                             victim:start_dissolve({G.C.BLACK}, nil, 1.6)
                             play_sound('slice1', 0.96+math.random()*0.08)
                             return true
                         end
                     }))
                     return {
                         message = "Consumed!",
                         colour = G.C.BLACK,
                         card = card
                     }
                 end
             end
        end
        local other_joker = nil
        for i = 1, #G.jokers.cards do
            if G.jokers.cards[i] == card then
                other_joker = G.jokers.cards[i+1]
                break
            end
        end
        if other_joker and other_joker ~= card then
            context.blueprint = (context.blueprint_card or card)
            context.blueprint_card = context.blueprint_card or card
            if other_joker.ability and other_joker.calculate_joker then
                local other_joker_ret = other_joker:calculate_joker(context)
                context.blueprint = nil
                context.blueprint_card = nil
                
                if other_joker_ret then
                    other_joker_ret.card = card 
                    other_joker_ret.colour = G.C.PURPLE 
                    return other_joker_ret
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Vyranoth",
    race = {"Dragon"},
    class = {"Mage"},
    weapon = {"Fist"},
    rarity = 1,
    cost = 5,
    index = 140,

    config = { extra = { x_mult = 3 } },

    loc_txt = {
        "If played hand contains",
        "both {C:clubs}Clubs{} and {C:spades}Spades{},",
        "give {X:mult,C:white} X#1# {} Mult"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local has_clubs = false
            local has_spades = false

            for _, v in ipairs(context.scoring_hand) do
                if v:is_suit('Clubs') then has_clubs = true end
                if v:is_suit('Spades') then has_spades = true end
            end

            if has_clubs and has_spades then
                return {
                    message = "Blizzard!",
                    colour = G.C.BLUE,
                    x_mult = card.ability.extra.x_mult,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Iridikron",
    race = {"Dragon"},
    class = {"Shaman"},
    weapon = {"Fist"},
    rarity = 2,
    cost = 8,
    index = 141,
    config = { extra = { x_chips = 1.5 } },
    loc_txt = {
        "Scoring {C:attention}Stone Cards{}",
        "give {X:chips,C:white} X#1# {} Chips"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_stone
        return { card.ability.extra.x_chips }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card.config.center == G.P_CENTERS.m_stone then
                return {
                    x_chips = card.ability.extra.x_chips,
                    message = "Fossilized!",
                    colour = G.C.GREY,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Galakrond",
    race = {"Dragon"},
    weapon = {"Fist"},
    rarity = 2,
    cost = 5,
    index = 142,

    config = { extra = { chips = 0, gain = 20 } },

    loc_txt = {
        "When you play a {C:attention}High Card{},",
        "this Joker gains {C:chips}+#2#{} Chips",
        "{C:inactive}(Currently {C:chips}+#1#{C:inactive} Chips){}"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.chips, card.ability.extra.gain }
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            if context.scoring_name == 'High Card' then
                card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.gain
                return {
                    message = "Devour!",
                    colour = G.C.CHIPS,
                    card = card
                }
            end
        end
        if context.joker_main then
            if card.ability.extra.chips > 0 then
                return {
                    chips = card.ability.extra.chips,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Malorne",
    faction = {"Alliance"},
    race = {"Beast","God"},
    class = {"Druid"},
    rarity = 2,
    cost = 4,
    index = 143,

    config = { extra = { h_size = 1, chips = 0, gain = 5 } },

    loc_txt = {
        "{C:attention}+#1#{} Hand Size",
        "This Joker gains {C:chips}+#2#{} Chips",
        "for each {C:clubs}Club{} held in hand",
        "when you play a hand",
        "{C:inactive}(Currently {C:chips}+#3#{C:inactive} Chips){}"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.h_size, card.ability.extra.gain, card.ability.extra.chips }
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local club_count = 0
            for _, v in ipairs(G.hand.cards) do
                if v:is_suit('Clubs') then
                    club_count = club_count + 1
                end
            end

            if club_count > 0 then
                card.ability.extra.chips = card.ability.extra.chips + (club_count * card.ability.extra.gain)
                return {
                    message = "Nature Grows!",
                    colour = G.C.CHIPS,
                    card = card
                }
            end
        end
        if context.joker_main then
            if card.ability.extra.chips > 0 then
                return {
                    chips = card.ability.extra.chips,
                    card = card
                }
            end
        end
    end,

    add_to_deck = function(self, card, from_debuff)
        G.hand:change_size(card.ability.extra.h_size)
    end,

    remove_from_deck = function(self, card, from_debuff)
        G.hand:change_size(-card.ability.extra.h_size)
    end
})

Warcraft.create_warcraft_joker({
    name = "Aviana",
    faction = {"Alliance"}, 
    race = {"Beast"},       
    class = {"Druid"},      
    weapon = {"Fist"},
    rarity = 2,
    cost = 7,
    index = 144,
    loc_txt = {
        "Jokers in the {C:attention}Shop{}",
        "cost {C:money}$1{}"
    },
    loc_vars = function(self, info_queue, card)
        return {}
    end,
    -- Refresh shop prices when Aviana enters or leaves
    add_to_deck = function(self, card, from_debuff)
        G.E_MANAGER:add_event(Event({
            func = function()
                if G.shop_jokers then
                    for _, c in ipairs(G.shop_jokers.cards) do
                        c:set_cost()
                    end
                end
                return true
            end
        }))
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.E_MANAGER:add_event(Event({
            func = function()
                if G.shop_jokers then
                    for _, c in ipairs(G.shop_jokers.cards) do
                        c:set_cost()
                    end
                end
                return true
            end
        }))
    end,
    calculate = function(self, card, context)
    end
})

Warcraft.create_warcraft_joker({
    name = "Ursoc",
    faction = {"Alliance"}, 
    race = {"Beast"},       
    class = {"Druid"},      
    weapon = {"Fist"},
    rarity = 1,
    cost = 3,
    index = 145,

    loc_txt = {
        "Played {C:diamonds}Diamond{} cards give",
        "double their {C:chips}Chip value{}"
    },

    loc_vars = function(self, info_queue, card)
        return { }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:is_suit('Diamonds') then
                return {
                    chips = context.other_card.base.nominal, 
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Goldrinn",
    faction = {"Alliance"}, 
    race = {"Beast"},       
    class = {"Warrior"},    
    weapon = {"Fist"},
    rarity = 3,
    cost = 8,
    index = 146,

    config = { extra = { x_mult = 4, loss = 5 } },

    loc_txt = {
        "If played hand is a {C:attention}High Card{}",
        "containing a {C:attention}Wild Card{},",
        "give {X:mult,C:white} X#1# {} Mult and lose {C:money}$#2#{}"
    },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_wild
        return { card.ability.extra.x_mult, card.ability.extra.loss }
    end,

    calculate = function(self, card, context)
        if context.joker_main and context.scoring_name == 'High Card' then
            local is_wild = false
            for _, v in ipairs(context.scoring_hand) do
                if v.config.center == G.P_CENTERS.m_wild then
                    is_wild = true
                    break
                end
            end

            if is_wild then
                ease_dollars(-card.ability.extra.loss)
                G.E_MANAGER:add_event(Event({
                    func = function() 
                        card:juice_up()
                        return true 
                    end
                }))

                return {
                    message = "Lo'Gosh!",
                    x_mult = card.ability.extra.x_mult,
                    colour = G.C.RED,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "G'huun",
    race = {"God"},
    weapon = {"Fist"},
    rarity = 3,
    cost = 8,
    index = 147,

    config = { extra = { bonus = 3, penalty = 2 } },

    loc_txt = {
        "{C:mult}+#1#{} Mult for each",
        "{C:attention}Sealed Card{} in your deck,",
        "minus {C:mult}#2#{} Mult for each",
        "{C:hearts}Heart{} or {C:spades}Spade{}",
        "{C:inactive}(Currently {C:mult}+#3#{C:inactive} Mult){}"
    },

    loc_vars = function(self, info_queue, card)
        local bonus_count = 0
        local penalty_count = 0
        if G.playing_cards then
            for _, v in ipairs(G.playing_cards) do
                if v:get_seal() then
                    bonus_count = bonus_count + 1
                end
                if v:is_suit('Hearts') or v:is_suit('Spades') then
                    penalty_count = penalty_count + 1
                end
            end
        end
        
        local current_mult = (bonus_count * card.ability.extra.bonus) - (penalty_count * card.ability.extra.penalty)
        if current_mult < 0 then current_mult = 0 end

        return { card.ability.extra.bonus, card.ability.extra.penalty, current_mult }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local bonus_count = 0
            local penalty_count = 0
            
            for _, v in ipairs(G.playing_cards) do
                if v:get_seal() then
                    bonus_count = bonus_count + 1
                end
                if v:is_suit('Hearts') or v:is_suit('Spades') then
                    penalty_count = penalty_count + 1
                end
            end

            local mult_amount = (bonus_count * card.ability.extra.bonus) - (penalty_count * card.ability.extra.penalty)
            if mult_amount < 0 then mult_amount = 0 end

            if mult_amount > 0 then
                return {
                    message = "Pestilence!",
                    mult = mult_amount,
                    colour = G.C.RED,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Xal'atath",
    class = {"Priest"},
    weapon = {"Daggers"},
    rarity = 3,
    cost = 8,
    index = 148,

    config = { extra = { x_mult = 3, chance = 2 } },

    loc_txt = {
        "Each scoring {C:attention}Ace{} gives",
        "{X:mult,C:white} X#1# {} Mult but has a",
        "{C:green}1 in #2#{} chance to be",
        "destroyed when scored"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult, card.ability.extra.chance }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:get_id() == 14 then 
                local destroy_card = false
                if pseudorandom('xalatath') < G.GAME.probabilities.normal / card.ability.extra.chance then
                    destroy_card = true
                end
                if destroy_card then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            context.other_card:start_dissolve()
                            return true
                        end
                    }))
                end
                return {
                    x_mult = card.ability.extra.x_mult,
                    card = card,
                    message = destroy_card and "Consumed!" or nil,
                    colour = destroy_card and G.C.BLACK or nil
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Dimensius the All-Devouring",
    race = {"God"},
    weapon = {"Fist"},
    rarity = 3,
    cost = 8,
    index = 149,

    config = { extra = { mult = 0, gain = 15 } },

    loc_txt = {
        "When played, remove {C:attention}Edition{}",
        "from scoring cards and gain",
        "{C:mult}+#2#{} Mult for each removed",
        "{C:inactive}(Currently {C:mult}+#1#{C:inactive} Mult){}"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.mult, card.ability.extra.gain }
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local devoured_count = 0
            
            for k, v in ipairs(context.scoring_hand) do
                if v.edition then
                    devoured_count = devoured_count + 1
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            v:set_edition(nil, true) 
                            v:juice_up()
                            return true
                        end
                    }))
                end
            end

            if devoured_count > 0 then
                card.ability.extra.mult = card.ability.extra.mult + (devoured_count * card.ability.extra.gain)
                return {
                    message = "Devoured!",
                    colour = G.C.PURPLE,
                    card = card
                }
            end
        end
        if context.joker_main and card.ability.extra.mult > 0 then
            return {
                mult = card.ability.extra.mult,
                card = card
            }
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Mimiron",
    race = {"Gnome", "Robot"},
    weapon = {"Hammer", "Fist"},
    rarity = 3,
    cost = 8,
    index = 150,
    loc_txt = {
        "Scoring {C:attention}Steel Cards{} give",
        "{C:mult}+Mult{} equal to the number of",
        "{C:attention}Sealed{} cards in your deck",
        "and gain a random {C:attention}Seal{}",
        "if they don't have one"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_steel
        return {}
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local scored_card = context.other_card
            if scored_card.config.center == G.P_CENTERS.m_steel then

                -- Count sealed cards in the deck
                local seal_count = 0
                if G.playing_cards then
                    for _, c in ipairs(G.playing_cards) do
                        if c.seal then
                            seal_count = seal_count + 1
                        end
                    end
                end

                -- Give a random seal if the card doesn't have one
                if not scored_card.seal then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            local seals = {"Red", "Blue", "Gold", "Purple"}
                            local chosen = pseudorandom_element(seals, pseudoseed('mimiron_seal_' .. G.GAME.round))
                            scored_card:set_seal(chosen, true)
                            scored_card:juice_up()
                            return true
                        end
                    }))
                end

                if seal_count > 0 then
                    return {
                        mult = seal_count,
                        message = "V-07-TR-0N!",
                        colour = G.C.GREY,
                        card = card
                    }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Millificent Manastorm",
    faction = {"Alliance"},
    race = {"Gnome"},
    class = {"Mage"},
    weapon = {"Hammer", "Gun"},
    rarity = 2,
    cost = 6,
    index = 151,

    config = { extra = { mult = 4, chance = 7 } },

    loc_txt = {
        "Played {C:attention}Even Ranked{} cards",
        "of {C:spades}Spades{} or {C:clubs}Clubs{} give",
        "{C:mult}+#1#{} Mult and have a {C:green}1 in #2#{}",
        "chance to become {C:attention}Steel Cards{}"
    },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_steel
        return { card.ability.extra.mult, card.ability.extra.chance }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local other = context.other_card
            local rank = other:get_id()
            if other:is_suit('Spades') or other:is_suit('Clubs') then
                if rank == 2 or rank == 4 or rank == 6 or rank == 8 or rank == 10 then
                    local transformed = false
                    if other.config.center ~= G.P_CENTERS.m_steel then
                        if pseudorandom('millificent') < G.GAME.probabilities.normal / card.ability.extra.chance then
                            transformed = true
                            G.E_MANAGER:add_event(Event({
                                func = function()
                                    other:set_ability(G.P_CENTERS.m_steel, nil, true)
                                    other:juice_up()
                                    return true
                                end
                            }))
                        end
                    end
                    return {
                        mult = card.ability.extra.mult,
                        card = card,
                        message = transformed and "Rocket Chicken!" or nil,
                        colour = transformed and G.C.GREY or nil
                    }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Baron Revilgaz",
    race = {"Goblin"},
    class = {"Rogue"},
    weapon = {"Sword", "Gun"},
    rarity = 2,
    cost = 6,
    index = 152,

    config = { extra = { debt_limit = 20, x_mult = 3 } },

    loc_txt = {
        "Go into debt up to {C:red}-$#1#{}",
        "{X:mult,C:white} X#2# {} Mult if your",
        "balance is {C:red}negative{}"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.debt_limit, card.ability.extra.x_mult }
    end,

    add_to_deck = function(self, card, from_debuff)
        G.GAME.bankrupt_at = G.GAME.bankrupt_at - card.ability.extra.debt_limit
    end,

    remove_from_deck = function(self, card, from_debuff)
        G.GAME.bankrupt_at = G.GAME.bankrupt_at + card.ability.extra.debt_limit
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            if G.GAME.dollars < 0 then
                return {
                    message = "Pay Up!",
                    x_mult = card.ability.extra.x_mult,
                    colour = G.C.RED,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Rhonin",
    faction = {"Alliance"}, 
    race = {"Human"},
    class = {"Mage"}, 
    weapon = {"Staff"},
    rarity = 2,
    cost = 6,
    index = 153,

    config = { extra = { chance = 4 } },

    loc_txt = {
        "Scoring {C:attention}Face Cards{} have",
        "{C:green}1 in #1#{} chance to become",
        "{C:attention}Glass Cards{} after scoring"
    },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_glass
        return { card.ability.extra.chance }
    end,

    calculate = function(self, card, context)
        if context.after and not context.blueprint then
            for i = 1, #context.scoring_hand do
                local other_card = context.scoring_hand[i]
                if other_card:is_face() and other_card.config.center ~= G.P_CENTERS.m_glass then
                    if pseudorandom('rhonin') < G.GAME.probabilities.normal / card.ability.extra.chance then
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                other_card:set_ability(G.P_CENTERS.m_glass, nil, true)
                                other_card:juice_up()
                                return true
                            end
                        }))

                        return {
                            message = "Polymorph!", 
                            colour = G.C.BLUE,
                            card = card
                        }
                    end
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Krasus",
    race = {"Dragon"},          
    class = {"Mage"},           
    weapon = {"Staff","Fist"},
    rarity = 2,
    cost = 6,
    index = 154,

    config = { extra = { chips_per_card = 30 } },

    loc_txt = {
        "Gives {C:chips}+#1#{} Chips for each",
        "{C:hearts}Heart{} held in hand"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.chips_per_card }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local heart_count = 0
            for _, v in ipairs(G.hand.cards) do
                if v:is_suit('Hearts') then
                    heart_count = heart_count + 1
                end
            end

            if heart_count > 0 then
                return {
                    message = "Ruby Life!",
                    chips = heart_count * card.ability.extra.chips_per_card,
                    colour = G.C.RED,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Broxigar",
    faction = {"Horde"},    
    race = {"Orc"},
    class = {"Warrior"},    
    weapon = {"Axe"},
    rarity = 3,
    cost = 8,
    index = 155,

    config = { extra = { x_mult = 2 } },

    loc_txt = {
        "Played {C:attention}Bonus Cards{} give",
        "{X:mult,C:white} X#1# {} Mult when scored"
    },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_bonus
        return { card.ability.extra.x_mult }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card.config.center == G.P_CENTERS.m_bonus then
                return {
                    x_mult = card.ability.extra.x_mult,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Whitemane",
    race = {"Human"},
    class = {"Priest"}, 
    weapon = {"Staff"},
    rarity = 3,
    cost = 8,
    index = 156,

    config = { extra = { mult_per_card = 4 } },

    loc_txt = {
        "{C:attention}Gold Cards{} held in hand",
        "or played give {C:mult}+#1#{} Mult",
        "for every card in your",
        "{C:attention}discard pile{}"
    },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_gold
        local discard_size = 0
        if G.discard then discard_size = #G.discard.cards end
        
        return { card.ability.extra.mult_per_card, discard_size * card.ability.extra.mult_per_card }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local gold_count = 0
            for _, v in ipairs(G.hand.cards) do
                if v.config.center == G.P_CENTERS.m_gold then
                    gold_count = gold_count + 1
                end
            end
            for _, v in ipairs(context.scoring_hand) do
                if v.config.center == G.P_CENTERS.m_gold then
                    gold_count = gold_count + 1
                end
            end

            local discard_size = #G.discard.cards

            if gold_count > 0 and discard_size > 0 then
                local total_mult = gold_count * discard_size * card.ability.extra.mult_per_card
                
                return {
                    message = "Resurrection!",
                    mult = total_mult,
                    colour = G.C.RED, 
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Sha of Fear",
    race = {"Sha"},
    weapon = {"Fist"},
    rarity = 3,
    cost = 8,
    index = 157,

    config = { extra = { chips = 50 } },

    loc_txt = {
        "{C:spades}Spades{} are always {C:attention}Debuffed{},",
        "but {C:attention}Debuffed Cards{} give",
        "{C:chips}+#1#{} Chips when scored"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.chips }
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            for k, v in ipairs(context.scoring_hand) do
                if v:is_suit('Spades') then
                    v:set_debuff(true) 
                end
            end
        end
        if context.joker_main then
            local debuff_count = 0
            
            for k, v in ipairs(context.scoring_hand) do
                if v.debuff then
                    debuff_count = debuff_count + 1
                end
            end

            if debuff_count > 0 then
                return {
                    message = "Fear!",
                    chips = debuff_count * card.ability.extra.chips,
                    colour = G.C.PURPLE,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Patchwerk",
    faction = {"Scourge"}, 
    race = {"Undead"},     
    class = {"Warrior"},   
    weapon = {"Axe"},
    rarity = 1,          
    cost = 5,
    index = 158,

    config = { extra = { mult = 4 } },

    loc_txt = {
        "Played {C:diamonds}Diamond{} cards give",
        "{C:mult}+#1#{} Mult when scored"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.mult }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:is_suit('Diamonds') then
                return {
                    mult = card.ability.extra.mult,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Stitches",
    faction = {"Scourge"}, 
    race = {"Undead"},     
    class = {"Warrior"},   
    weapon = {"Axe"},
    rarity = 3,          
    cost = 8,
    index = 159,

    config = { extra = { mult = 0, gain = 4 } },

    loc_txt = {
        "This Joker gains {C:mult}+#2#{} Mult",
        "if you discard exactly",
        "{C:attention}1 card{} at a time",
        "{C:inactive}(Currently {C:mult}+#1#{C:inactive} Mult){}"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.mult, card.ability.extra.gain }
    end,

    calculate = function(self, card, context)
        if context.discard and not context.blueprint then
            if context.other_card == context.full_hand[#context.full_hand] then
                if #context.full_hand == 1 then
                    card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.gain
                    
                    return {
                        message = "Hooked!",
                        colour = G.C.RED,
                        card = card
                    }
                end
            end
        end
        if context.joker_main and card.ability.extra.mult > 0 then
            return {
                mult = card.ability.extra.mult,
                card = card
            }
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Gamon",
    faction = {"Horde"},
    race = {"Tauren"},
    class = {"Warrior"},
    weapon = {"Axe"},
    rarity = 3,
    cost = 8,
    index = 160,

    loc_txt = {
        "All {C:attention}probabilities{} are set",
        "to {C:green}0{}"
    },

    loc_vars = function(self, info_queue, card)
        return { }
    end,

    add_to_deck = function(self, card, from_debuff)
        G.GAME.probabilities.normal = 0
    end,

    remove_from_deck = function(self, card, from_debuff)
        G.GAME.probabilities.normal = 1
        if G.jokers then
            for k, v in ipairs(G.jokers.cards) do
                if v.ability.name == 'Oops! All 6s' and not v.debuff then
                    G.GAME.probabilities.normal = G.GAME.probabilities.normal * 2
                end
            end
        end
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            G.GAME.probabilities.normal = 0
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Daelin Proudmoore",
    faction = {"Alliance"},
    race = {"Human"},
    class = {"Warrior"},
    weapon = {"Sword"},
    rarity = 1,
    cost = 4,
    index = 161,

    config = { extra = { chips_per_debuff = 15, mult_per_debuff = 3 } },

    loc_txt = {
        "Your {C:attention}Horde{} Jokers are",
        "{C:red}Debuffed{} while this is present.",
        "Played cards give {C:chips}+#1#{} Chips",
        "and {C:mult}+#2#{} Mult for each",
        "{C:attention}Debuffed Joker{} you own"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.chips_per_debuff, card.ability.extra.mult_per_debuff }
    end,
    add_to_deck = function(self, card, from_debuff)
        if G.jokers and G.jokers.cards then
            for _, j in ipairs(G.jokers.cards) do
                j:set_debuff()
            end
        end
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.E_MANAGER:add_event(Event({
            func = function()
                if G.jokers and G.jokers.cards then
                    for _, j in ipairs(G.jokers.cards) do
                        j:set_debuff()
                    end
                end
                return true
            end
        }))
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local debuff_count = 0
            if G.jokers and G.jokers.cards then
                for _, j in ipairs(G.jokers.cards) do
                    if j.debuff then
                        debuff_count = debuff_count + 1
                    end
                end
            end
            if debuff_count > 0 then
                return {
                    chips = card.ability.extra.chips_per_debuff * debuff_count,
                    mult = card.ability.extra.mult_per_debuff * debuff_count,
                    card = card,
                    message = "Kul Tiras!",
                    colour = G.C.BLUE
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Mannoroth",
    faction = {"Legion"},
    race = {"Demon"},
    class = {"Warrior"},
    weapon = {"Glaives","Polearm"},
    rarity = 2,
    cost = 5,
    index = 162,

    config = { extra = { x_mult = 2, value_loss = 1 } },

    loc_txt = {
        "Your {C:attention}Orc{} Jokers each give",
        "{X:mult,C:white} X#1# {} Mult.",
        "At end of round, your {C:attention}Orc{} Jokers",
        "lose {C:money}$#2#{} of Sell Value.",
        "If an Orc reaches {C:money}$0{}, it is {C:red}destroyed{}."
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult, card.ability.extra.value_loss }
    end,

    calculate = function(self, card, context)
        if context.other_joker then
            local other = context.other_joker
            local race = other.ability and other.ability.extra and other.ability.extra.race
            local is_orc = false
            
            if type(race) == "table" then
                for _, r in ipairs(race) do if r == "Orc" then is_orc = true break end end
            elseif race == "Orc" then
                is_orc = true
            end

            if is_orc then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        other:juice_up(0.5, 0.5)
                        return true
                    end
                }))
                return {
                    message = "Blood Curse!",
                    Xmult_mod = card.ability.extra.x_mult,
                    colour = G.C.RED
                }
            end
        end
        if context.end_of_round and not context.repetition and not context.individual and not context.blueprint then
            local destroyed_any = false
            if G.jokers and G.jokers.cards then
                for i = #G.jokers.cards, 1, -1 do
                    local j = G.jokers.cards[i]
                    local race = j.ability and j.ability.extra and j.ability.extra.race
                    local is_orc = false
                    
                    if type(race) == "table" then
                        for _, r in ipairs(race) do if r == "Orc" then is_orc = true break end end
                    elseif race == "Orc" then
                        is_orc = true
                    end
                    if is_orc and j ~= card then 
                        j.ability.extra_value = (j.ability.extra_value or 0) - card.ability.extra.value_loss
                        j:set_cost()
                        
                        if j.sell_cost <= 0 and not j.ability.eternal and not j.getting_sliced then
                            j.getting_sliced = true
                            G.E_MANAGER:add_event(Event({
                                func = function()
                                    card:juice_up(0.8, 0.8)
                                    j:start_dissolve({G.C.RED}, nil, 1.6)
                                    play_sound('slice1', 0.96 + math.random() * 0.08)
                                    return true
                                end
                            }))
                            destroyed_any = true
                        else
                            G.E_MANAGER:add_event(Event({
                                func = function()
                                    j:juice_up(0.5, 0.5)
                                    card_eval_status_text(j, 'extra', nil, nil, nil, {message = "-$1 Value", colour = G.C.MONEY})
                                    return true
                                end
                            }))
                        end
                    end
                end
            end
            if destroyed_any then
                return {
                    message = "Consumed!",
                    colour = G.C.RED,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Baron Rivendare",
    faction = {"Scourge"},
    race = {"Undead"},
    class = {"Death Knight"},
    weapon = {"Sword"},
    rarity = 3,
    cost = 8,
    index = 163,

    config = { extra = { face_target = 4, x_mult = 5, retrigger = 1 } },

    loc_txt = {
        "If your played hand contains",
        "exactly {C:attention}#1# Face Cards{},",
        "give {X:mult,C:white} X#2# {} Mult and",
        "retrigger all {C:attention}Face Cards{}"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.face_target, card.ability.extra.x_mult }
    end,

    calculate = function(self, card, context)
        local face_count = 0
        if context.full_hand then
            for _, v in ipairs(context.full_hand) do
                if v:is_face() then
                    face_count = face_count + 1
                end
            end
        end
        if face_count == card.ability.extra.face_target then
            if context.repetition and context.cardarea == G.play then
                if context.other_card:is_face() then
                    return {
                        message = "Horseman!",
                        repetitions = card.ability.extra.retrigger,
                        card = card
                    }
                end
            end
            if context.joker_main then
                return {
                    message = "The Four Horsemen!",
                    Xmult_mod = card.ability.extra.x_mult,
                    colour = G.C.DARK_EDITION
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Professor Putricide",
    faction = {"Scourge"},
    race = {"Undead"},
    class = {"Warlock"},
    rarity = 2,
    cost = 6,
    index = 164,

    loc_txt = {
        "When a hand is played,",
        "a random {C:attention}held card{} gains",
        "a random {C:attention}Enhancement{}.",
        "If it already has one, it gains",
        "a random {C:dark_edition}Edition{} instead."
    },

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            if G.hand and G.hand.cards and #G.hand.cards > 0 then
                local target_card = pseudorandom_element(G.hand.cards, pseudoseed('putricide_target'))
                
                G.E_MANAGER:add_event(Event({
                    func = function()
                        if target_card.config.center == G.P_CENTERS.c_base then
                            local enhancement = pseudorandom_element(G.P_CENTER_POOLS.Enhanced, pseudoseed('putricide_enh'))
                            target_card:set_ability(enhancement, nil, true)
                            card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Mutated!", colour = G.C.GREEN})
                        else
                            local edition = poll_edition('putricide_ed', nil, true, true)
                            if edition then
                                target_card:set_edition(edition, true)
                                card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Perfected!", colour = G.C.DARK_EDITION})
                            end
                        end
                        
                        target_card:juice_up()
                        card:juice_up()
                        play_sound('tarot1')
                        return true
                    end
                }))
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Grand Magistrix Elisande",
    race = {"Night Elf"},
    class = {"Mage"},
    weapon = {"Staff"},
    rarity = 3,
    cost = 8,
    index = 165,

    config = { extra = { x_mult = 3 } },

    loc_txt = {
        "If played {C:attention}poker hand{} is",
        "the same as the",
        "{C:attention}previous hand played{},",
        "give {X:mult,C:white} X#1# {} Mult"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            if G.GAME.last_hand_played and context.scoring_name == G.GAME.last_hand_played then
                return {
                    message = "Time Loop!",
                    Xmult_mod = card.ability.extra.x_mult,
                    colour = G.C.PURPLE
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Helya",
    race = {"Undead"},
    class = {"Warlock"}, 
    weapon = {"Fist"},
    rarity = 1,
    cost = 4,
    index = 166,
    config = { extra = { chips = 0 } },
    loc_txt = {
        "When a blind is defeated,",
        "permanently gain {C:chips}+Chips{}",
        "equal to cards in the",
        "{C:attention}Discard Pile{}",
        "{C:inactive}(Currently {C:chips}+#1#{C:inactive} Chips){}"
    },
    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.chips }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.repetition and not context.individual and not context.blueprint then
            local discard_count = (G.discard and G.discard.cards) and #G.discard.cards or 0

            if discard_count > 0 then
                card.ability.extra.chips = card.ability.extra.chips + discard_count
                return {
                    message = "Helheim!",
                    colour = G.C.PURPLE,
                    card = card
                }
            end
        end

        if context.joker_main then
            if card.ability.extra.chips > 0 then
                return {
                    chips = card.ability.extra.chips,
                    colour = G.C.CHIPS,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Neptulon",
    race = {"Elemental"},
    class = {"Shaman"},
    weapon = {"Polearm"},
    rarity = 1,
    cost = 3,
    index = 167,

    loc_txt = {
        "Played {C:spades}Spades{} give",
        "{C:attention}double{} their base {C:chips}Chip{} value",
        "when scored"
    },

    loc_vars = function(self, info_queue, card)
        return { }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:is_suit('Spades') then
                local extra_chips = context.other_card.base.nominal
                
                if extra_chips > 0 then
                    return {
                        chips = extra_chips,
                        card = context.other_card,
                        message = "Tidal Surge!",
                        colour = G.C.CHIPS
                    }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Therazane",
    race = {"Elemental"},
    class = {"Shaman"}, 
    weapon = {"Fist"},
    rarity = 1,
    cost = 4,
    index = 168,

    config = { extra = { chips = 30, mult = 6 } },

    loc_txt = {
        "Scoring {C:diamonds}Diamonds{} and {C:attention}Stone Cards{}",
        "give {C:chips}+#1#{} Chips and {C:mult}+#2#{} Mult"
    },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_stone
        return { card.ability.extra.chips, card.ability.extra.mult }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local other = context.other_card
            if other:is_suit('Diamonds') or other.config.center.key == 'm_stone' then
                return {
                    chips = card.ability.extra.chips,
                    mult = card.ability.extra.mult,
                    card = other,
                    message = "Stonemother!",
                    colour = G.C.ORANGE
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Freya",
    faction = {"Horde", "Alliance"},
    race = {"Titan"},
    class = {"Druid"}, 
    weapon = {"Staff"},
    rarity = 1,
    cost = 5,
    index = 169,

    loc_txt = {
        "When you defeat a {C:attention}Blind{},",
        "add a random {C:attention}Wild{} {C:attention}Ace{}",
        "to your deck"
    },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_wild
        return { }
    end,

    calculate = function(self, card, context)
        if context.end_of_round and not context.repetition and not context.individual and not context.blueprint then
            
            G.E_MANAGER:add_event(Event({
                func = function() 
                    local suit = pseudorandom_element({'S','H','D','C'}, pseudoseed('freya_suit'))
                    local base_key = suit .. '_A'
                    local new_card = create_card('Base', G.deck, nil, nil, nil, nil, nil, 'freya')
                    new_card:set_base(G.P_CARDS[base_key])
                    new_card:set_ability(G.P_CENTERS.m_wild)
                    new_card:add_to_deck()
                    table.insert(G.playing_cards, new_card)
                    G.deck:emplace(new_card)
                    
                    new_card:juice_up()
                    play_sound('tarot1')
                    return true
                end
            }))

            return {
                message = "Life Blooms!",
                colour = G.C.GREEN,
                card = card
            }
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Ra-den",
    faction = {"Horde", "Alliance"},
    race = {"Titan"},
    class = {"Shaman"}, 
    weapon = {"Hammer"},
    rarity = 3,
    cost = 8,
    index = 170,

    config = { extra = { x_mult = 1, gain = 0.2, repetitions = 1 } },

    loc_txt = {
        "Cards with a {C:blue}Blue Seal{} retrigger",
        "{C:attention}#1#{} additional time.",
        "This Joker gains {X:mult,C:white} X#2# {} Mult",
        "every time a {C:blue}Blue Seal{} scores",
        "{C:inactive}(Currently {X:mult,C:white} X#3# {C:inactive} Mult){}"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.repetitions, card.ability.extra.gain, card.ability.extra.x_mult }
    end,

    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            if context.other_card:get_seal() == 'Blue' then
                return {
                    message = "Highkeeper!",
                    repetitions = card.ability.extra.repetitions,
                    card = card
                }
            end
        end
        if context.individual and context.cardarea == G.play and not context.blueprint then
            if context.other_card:get_seal() == 'Blue' then
                card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.gain
                return {
                    message = "Power!",
                    colour = G.C.BLUE,
                    card = card
                }
            end
        end
        if context.joker_main then
            if card.ability.extra.x_mult > 1 then
                return {
                    Xmult_mod = card.ability.extra.x_mult,
                    message = "Lightning!",
                    colour = G.C.BLUE
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Loken",
    faction = {"Horde", "Alliance"},
    race = {"Titan"},
    class = {"Mage"},
    rarity = 2,
    cost = 6,
    index = 171,
    config = { extra = {} },
    loc_txt = {
        "Sealed cards are always",
        "drawn first from your deck"
    },
    loc_vars = function(self, info_queue, card)
        return {}
    end,
    add_to_deck = function(self, card, from_debuff)
        -- Sort immediately on acquisition
        if G.deck and G.deck.cards then
            table.sort(G.deck.cards, function(a, b)
                local a_sealed = a.seal and true or false
                local b_sealed = b.seal and true or false
                if a_sealed ~= b_sealed then
                    return not a_sealed
                end
                return false
            end)
        end
    end,
    calculate = function(self, card, context)
    end
})

Warcraft.create_warcraft_joker({
    name = "Nat Pagle",
    race = {"Human"},
    class = {"Hunter"},
    weapon = {"Polearm"},
    rarity = 2,
    cost = 5,
    index = 172,

    config = { extra = { req = 3, current = 0 } },

    loc_txt = {
        "Every {C:attention}#1#{} Discards used,",
        "{C:green}reel in{} a random {C:attention}Consumable{}",
        "into an empty slot",
        "{C:inactive}(Currently {C:attention}#2#{C:inactive} / #1#){}"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.req, card.ability.extra.current }
    end,

    calculate = function(self, card, context)
        if context.discard and not context.blueprint then
            -- Trigger on first card of the batch
            if context.other_card == context.full_hand[1] then
                card.ability.extra.current = card.ability.extra.current + 1
                if card.ability.extra.current >= card.ability.extra.req then
                    card.ability.extra.current = 0
                    if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                        G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                local c_types = {'Tarot', 'Planet', 'Spectral', 'Equipment'}
                                local chosen_type = pseudorandom_element(c_types, pseudoseed('nat_pagle'))
                                local new_card = create_card(chosen_type, G.consumeables, nil, nil, nil, nil, nil, 'nat_pagle')
                                new_card:add_to_deck()
                                G.consumeables:emplace(new_card)
                                G.GAME.consumeable_buffer = 0
                                return true
                            end
                        }))
                        return { message = "Caught One!", colour = G.C.GREEN, card = card }
                    else
                        return { message = "Line Snapped!", colour = G.C.RED, card = card }
                    end
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Gruul",
    race = {"Gronn"},
    class = {"Warrior"},
    weapon = {"Fist", "Hammer"},
    rarity = 2,
    cost = 6,
    index = 173,

    config = { extra = { chips = 200, chip_gain = 50, h_size = -1 } },

    loc_txt = {
        "{C:chips}+#1#{} Chips",
        "Gains {C:chips}+#2#{} Chips",
        "at the end of each Blind.",
        "{C:attention}#3#{} Hand Size"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.chips, card.ability.extra.chip_gain, card.ability.extra.h_size }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return {
                chips = card.ability.extra.chips,
                card = card
            }
        end
        if context.end_of_round and not context.repetition and not context.individual and not context.blueprint then
            card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_gain
            return {
                message = "Growth!",
                colour = G.C.CHIPS,
                card = card
            }
        end
    end,
    add_to_deck = function(self, card, from_debuff)
        G.hand:change_size(card.ability.extra.h_size)
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.hand:change_size(-card.ability.extra.h_size)
    end
})

Warcraft.create_warcraft_joker({
    name = "Winter Queen",
    race = {"God"},
    class = {"Druid"}, 
    weapon = {"Staff"},
    rarity = 3,
    cost = 8,
    index = 174,

    loc_txt = {
        "Whenever a playing card is {C:red}destroyed{},",
        "add a copy of it to your deck",
        "with a {C:dark_edition}Polychrome{} edition",
        "and a {C:attention}Wild{} enhancement"
    },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.e_polychrome
        info_queue[#info_queue+1] = G.P_CENTERS.m_wild
        return { }
    end,

    calculate = function(self, card, context)
        if context.remove_playing_cards and not context.blueprint then
            
            if #context.removed > 0 then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        for _, destroyed_card in ipairs(context.removed) do
                            local new_card = copy_card(destroyed_card, nil, nil, G.playing_card)
                            new_card.shattered = nil
                            new_card.destroyed = nil
                            new_card:set_edition({polychrome = true}, true, true)
                            new_card:set_ability(G.P_CENTERS.m_wild, nil, true)
                            new_card:add_to_deck()
                            G.deck.config.card_limit = G.deck.config.card_limit + 1
                            table.insert(G.playing_cards, new_card)
                            G.deck:emplace(new_card)
                            
                        end
                        
                        card:juice_up()
                        play_sound('tarot1')
                        return true
                    end
                }))

                return {
                    message = "Rebirth!",
                    colour = G.C.DARK_EDITION,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "The Primus",
    race = {"God"},
    class = {"Death Knight"}, 
    weapon = {"Sword"},
    rarity = 3,
    cost = 8,
    index = 175,

    config = { extra = { mult = 0 } },

    loc_txt = {
        "If played hand is a {C:attention}Pair{},",
        "destroy a random scoring card",
        "and gain its {C:chips}Base Chips{}",
        "as permanent {C:mult}Mult{}",
        "{C:inactive}(Currently {C:mult}+#1#{C:inactive} Mult){}"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.mult }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            if context.scoring_name == "Pair" and context.scoring_hand and #context.scoring_hand > 0 then
                local target_card = pseudorandom_element(context.scoring_hand, pseudoseed('primus'))

                if target_card and not target_card.dissolving then
                    local gained_mult = target_card.base.nominal or 0
                    card.ability.extra.mult = card.ability.extra.mult + gained_mult

                    G.E_MANAGER:add_event(Event({
                        func = function()
                            target_card:start_dissolve({remove_as_card = true})
                            return true
                        end
                    }))

                    return {
                        message = "+" .. gained_mult .. " Mult!",
                        mult = card.ability.extra.mult,
                        colour = G.C.MULT,
                        card = card
                    }
                end
            end

            if card.ability.extra.mult > 0 then
                return {
                    message = "Fleshcrafted!",
                    mult = card.ability.extra.mult,
                    colour = G.C.MULT,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Kyrestia",
    race = {"God"},
    class = {"Paladin"}, 
    weapon = {"Spear","Polearm"},
    rarity = 2,
    cost = 6,
    index = 176,

    loc_txt = {
        "Scoring {C:attention}Odd{} cards",
        "permanently gain {C:attention}1 Rank{}",
        "{C:inactive}(Stops at Ace){}"
    },

    loc_vars = function(self, info_queue, card)
        return { }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local other = context.other_card
            local id = other:get_id()
            if id > 0 and id < 14 and id % 2 == 1 then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local current_id = other:get_id()
                        if current_id < 14 then
                            local suit_prefix = string.sub(other.base.suit, 1, 1) 
                            local suffixes = {"2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K", "A"}
                            local new_suffix = suffixes[current_id]
                            
                            local new_key = suit_prefix .. "_" .. new_suffix
                            other:set_base(G.P_CARDS[new_key])
                            other:juice_up()
                        end
                        return true
                    end
                }))

                return {
                    message = "Ascended!",
                    colour = G.C.ORANGE,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Herald Volazj",
    race = {"Faceless One"},
    class = {"Priest"}, 
    rarity = 2,
    cost = 5,
    index = 177,

    loc_txt = {
        "Each scoring card changes to a",
        "{C:attention}random suit{} after scoring"
    },

    loc_vars = function(self, info_queue, card)
        return { }
    end,

    calculate = function(self, card, context)
        if context.after and not context.blueprint then
            local changed_cards = false
            
            if context.scoring_hand and #context.scoring_hand > 0 then
                for i = 1, #context.scoring_hand do
                    local scored_card = context.scoring_hand[i]
                    
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            local current_suit = scored_card.base.suit
                            local all_suits = {'Spades', 'Hearts', 'Clubs', 'Diamonds'}
                            local possible_new_suits = {}
                            for _, s in ipairs(all_suits) do
                                if s ~= current_suit then
                                    table.insert(possible_new_suits, s)
                                end
                            end
                            
                            local new_suit = pseudorandom_element(possible_new_suits, pseudoseed('volazj'))
                            
                            scored_card:change_suit(new_suit)
                            scored_card:juice_up()
                            
                            return true
                        end
                    }))
                    changed_cards = true
                end
            end

            if changed_cards then
                return {
                    message = "Madness!",
                    colour = G.C.PURPLE,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Nythendra",
    faction = {"Legion"}, 
    race = {"Dragon"},
    class = {"Warlock"}, 
    weapon = {"Fist"},
    rarity = 2,
    cost = 6,
    index = 178,

    config = { extra = { mult = -2, chips = 100 } },

    loc_txt = {
        "Played {C:hearts}Hearts{} give {C:red}#1#{} Mult",
        "and {C:chips}+#2#{} Chips when scored",
        "{C:inactive}(Corrupted Life){}"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.mult, card.ability.extra.chips }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:is_suit('Hearts') then
                return {
                    mult = card.ability.extra.mult,
                    chips = card.ability.extra.chips,
                    card = context.other_card,
                    message = "Infested!",
                    colour = G.C.GREEN 
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Ultraxion",
    race = {"Dragon"},
    class = {"Warlock"}, 
    weapon = {"Fist"},
    rarity = 3, 
    cost = 8,
    index = 179,

    config = { extra = { x_mult = 5.0, decay = 0.5, payout = 25 } },

    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "Loses {X:mult,C:white} X#2# {} Mult after",
        "each hand played.",
        "If it drops to {X:mult,C:white} X1 {}, it is {C:red}destroyed{}",
        "and you gain {C:money}$#3#{}"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult, card.ability.extra.decay, card.ability.extra.payout }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            if card.ability.extra.x_mult > 1 then
                return {
                    message = "Hour of Twilight!",
                    Xmult_mod = card.ability.extra.x_mult,
                    colour = G.C.DARK_EDITION
                }
            end
        end
        if context.after and not context.blueprint then
            card.ability.extra.x_mult = card.ability.extra.x_mult - card.ability.extra.decay
            if card.ability.extra.x_mult <= 1.0 then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('tarot1')
                        card.T.r = -0.2
                        card:juice_up(0.3, 0.4)
                        card.states.collide.can = false
                        ease_dollars(card.ability.extra.payout)
                        card:start_dissolve(nil, true)
                        return true
                    end
                }))

                return {
                    message = "Fading Light!",
                    colour = G.C.MONEY
                }
            else
                return {
                    message = "-X0.5 Mult",
                    colour = G.C.RED,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "King Mukla",
    race = {"Beast"},
    class = {"Warrior"},
    weapon = {"Fist"},
    rarity = 2,
    cost = 6,
    index = 180,

    config = { extra = { chance = 3 } },

    loc_txt = {
        "Played {C:clubs}Clubs{} have a",
        "{C:green}1 in #1#{} chance to generate",
        "a random {C:attention}Consumable{}",
        "when scored"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.chance }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:is_suit('Clubs') then
                if pseudorandom('mukla') < G.GAME.probabilities.normal / card.ability.extra.chance then
                    if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                        G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                        
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                local c_types = {'Tarot', 'Planet', 'Spectral', 'Equipment'}
                                local chosen_type = pseudorandom_element(c_types, pseudoseed('mukla_type'))
                                
                                local new_card = create_card(chosen_type, G.consumeables, nil, nil, nil, nil, nil, 'mukla')
                                new_card:add_to_deck()
                                G.consumeables:emplace(new_card)
                                G.GAME.consumeable_buffer = 0
                                return true
                            end
                        }))

                        return {
                            message = "Bananas!",
                            colour = G.C.GREEN,
                            card = card
                        }
                    end
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Captain Eudora",
    faction = {"Horde"}, 
    race = {"Vulpera"},
    class = {"Rogue"}, 
    weapon = {"Gun"},
    rarity = 2,
    cost = 6,
    index = 181,

    config = { extra = { dollars = 2, retrigger = 1 } },

    loc_txt = {
        "Played {C:attention}Lucky Cards{} give",
        "{C:money}$#1#{} and retrigger",
        "{C:attention}#2#{} additional time"
    },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_lucky
        return { card.ability.extra.dollars, card.ability.extra.retrigger }
    end,

    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            if context.other_card.config.center.key == 'm_lucky' then
                return {
                    message = "Powder Shot!",
                    repetitions = card.ability.extra.retrigger,
                    card = card
                }
            end
        end
        if context.individual and context.cardarea == G.play then
            if context.other_card.config.center.key == 'm_lucky' then
                return {
                    dollars = card.ability.extra.dollars,
                    card = card,
                    message = "Plunder!",
                    colour = G.C.MONEY
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Captain Cookie",
    race = {"Murloc"},
    class = {"Warrior"}, 
    weapon = {"Hammer"},
    rarity = 2,
    cost = 5,
    index = 182,

    loc_txt = {
        "Scores the combined {C:attention}Base Chip{}",
        "value of all cards",
        "currently held in hand",
        "{C:inactive}(Currently {C:chips}+#1#{C:inactive} Chips){}"
    },

    loc_vars = function(self, info_queue, card)
        local hand_chips = 0
        if G.hand and G.hand.cards then
            for _, v in ipairs(G.hand.cards) do
                if not v.debuff then
                    hand_chips = hand_chips + (v.base.nominal or 0)
                end
            end
        end
        return { hand_chips }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local hand_chips = 0
            if G.hand and G.hand.cards then
                for _, v in ipairs(G.hand.cards) do
                    if not v.debuff then
                        hand_chips = hand_chips + (v.base.nominal or 0)
                    end
                end
            end
            if hand_chips > 0 then
                return {
                    chips = hand_chips,
                    message = "Leftovers!",
                    colour = G.C.CHIPS,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Griftah",
    race = {"Troll"},
    class = {"Rogue"},
    weapon = {"Staff"},
    rarity = 1,
    cost = 4,
    index = 183,

    config = { extra = { mult = 0, mult_gain = 1 } },

    loc_txt = {
        "{C:mult}+#1#{} Mult",
        "{C:inactive}(Gains {C:mult}+#2#{C:inactive} Mult each time",
        "you {C:attention}Reroll{} the shop){}"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.mult, card.ability.extra.mult_gain }
    end,

    calculate = function(self, card, context)
        if context.reroll_shop and not context.blueprint then
            card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain
            return {
                message = "A Bargain!",
                colour = G.C.MULT,
                card = card
            }
        end
        if context.joker_main then
            if card.ability.extra.mult > 0 then
                return {
                    mult = card.ability.extra.mult,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Princess Talanji",
    faction = {"Horde"}, 
    race = {"Troll"},
    class = {"Priest"}, 
    weapon = {"Staff"},
    rarity = 2,
    cost = 6,
    index = 184,

    config = { extra = { mult = 0, gain = 3 } },

    loc_txt = {
        "{C:mult}+#1#{} Mult",
        "{C:inactive}(Gains {C:mult}+#2#{C:inactive} Mult when you",
        "use a {C:tarot}Tarot Card{}){}"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.mult, card.ability.extra.gain }
    end,

    calculate = function(self, card, context)
        if context.using_consumeable and not context.blueprint then
            if context.consumeable.ability.set == 'Tarot' then
                card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.gain
                G.E_MANAGER:add_event(Event({
                    func = function() 
                        card_eval_status_text(card, 'extra', nil, nil, nil, {
                            message = "Loa's Blessing!", 
                            colour = G.C.PURPLE
                        })
                        card:juice_up()
                        return true
                    end
                }))
            end
        end
        if context.joker_main then
            if card.ability.extra.mult > 0 then
                return {
                    mult = card.ability.extra.mult,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Thassarian",
    faction = {"Alliance"}, 
    race = {"Human"},
    class = {"Death Knight"},
    weapon = {"Sword"},
    rarity = 1,
    cost = 4,
    index = 185,

    config = { extra = { repetitions = 1 } },

    loc_txt = {
        "Played {C:attention}10s{} retrigger",
        "{C:attention}#1#{} additional time"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.repetitions }
    end,

    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            if context.other_card:get_id() == 10 then
                return {
                    message = "Obliterate!",
                    repetitions = card.ability.extra.repetitions,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Il'Gynoth",
    race = {"God"},
    class = {"Warlock"}, 
    weapon = {"Fist"},
    rarity = 3,
    cost = 8,
    index = 186,

    config = { extra = { x_mult = 3 } },

    loc_txt = {
        "Cards with a {C:purple}Purple Seal{}",
        "give {X:mult,C:white} X#1# {} Mult when scored"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:get_seal() == 'Purple' then
                return {
                    x_mult = card.ability.extra.x_mult,
                    card = context.other_card,
                    message = "Whispers!",
                    colour = G.C.PURPLE
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Artificer Xy'mox",
    race = {"Broker"},
    class = {"Mage"}, 
    weapon = {"Sword"},
    rarity = 2,
    cost = 6,
    index = 187,

    config = { extra = { mult_per = 15 } },

    loc_txt = {
        "{C:mult}+#1#{} Mult for each",
        "{C:attention}Consumable{} currently held",
        "{C:inactive}(Currently {C:mult}+#2#{C:inactive} Mult){}"
    },

    loc_vars = function(self, info_queue, card)
        local count = 0
        if G.consumeables and G.consumeables.cards then
            count = #G.consumeables.cards
        end
        return { card.ability.extra.mult_per, count * card.ability.extra.mult_per }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local count = 0
            if G.consumeables and G.consumeables.cards then
                count = #G.consumeables.cards
            end

            if count > 0 then
                return {
                    mult = count * card.ability.extra.mult_per,
                    message = "Relics!",
                    colour = G.C.MULT,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Mueh'zala",
    race = {"God","Loa"},
    class = {"Priest"}, 
    weapon = {"Polearm"},
    rarity = 3, 
    cost = 10,
    index = 188,
    config = { extra = { x_mult = 1, x_mult_gain = 0.1, threshold = 10 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "Gains {X:mult,C:white} X#2# {} Mult for every",
        "{C:attention}#3#{} cards discarded this run",
        "{C:inactive}(Total Discarded: {C:attention}#4#{C:inactive}){}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.x_mult,
            card.ability.extra.x_mult_gain,
            card.ability.extra.threshold,
            G.GAME.warcraft_cards_discarded or 0
        }
    end,
    add_to_deck = function(self, card, from_debuff)
        -- Retroactively calculate x_mult from discards before acquisition
        local total_discarded = G.GAME.warcraft_cards_discarded or 0
        local boosts = math.floor(total_discarded / card.ability.extra.threshold)
        if boosts > 0 then
            card.ability.extra.x_mult = 1 + (boosts * card.ability.extra.x_mult_gain)
            card_eval_status_text(card, 'extra', nil, nil, nil, {
                message = "Soul Harvest!",
                colour = G.C.PURPLE
            })
        end
    end,
    calculate = function(self, card, context)
        if context.discard and not context.blueprint then
            -- Only process once per discard action using first card trigger
            if context.other_card ~= context.full_hand[1] then return end

            local total = G.GAME.warcraft_cards_discarded or 0
            local discarded_this_action = #context.full_hand
            local old_boosts = math.floor((total - discarded_this_action) / card.ability.extra.threshold)
            local new_boosts = math.floor(total / card.ability.extra.threshold)

            if new_boosts > old_boosts then
                local gained = (new_boosts - old_boosts) * card.ability.extra.x_mult_gain
                card.ability.extra.x_mult = card.ability.extra.x_mult + gained
                return {
                    message = "Soul Harvest!",
                    colour = G.C.PURPLE,
                    card = card
                }
            end
        end

        if context.joker_main then
            if card.ability.extra.x_mult > 1 then
                return {
                    Xmult_mod = card.ability.extra.x_mult,
                    message = "Death's Power!",
                    colour = G.C.PURPLE
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "The Runecarver",
    race = {"God"},
    class = {"Death Knight"}, 
    rarity = 3,
    cost = 10,
    index = 189,

    config = { extra = { x_mult_per = 1 } },

    loc_txt = {
        "Generates a random {C:attention}Equipment{}",
        "at the end of the {C:attention}Shop phase{}.",
        "{X:mult,C:white} X#1# {} Mult for each {C:attention}Joker{}",
        "that has an {C:attention}Equipment{} attached",
        "{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult){}"
    },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = {key = 'equipment', set = 'Other'}
        local count = 0
        if G.jokers and G.jokers.cards then
            for _, j in ipairs(G.jokers.cards) do
                if j.ability.warcraft_equipment then 
                    count = count + 1
                end
            end
        end

        return { 
            card.ability.extra.x_mult_per, 
            1 + (count * card.ability.extra.x_mult_per) 
        }
    end,

    calculate = function(self, card, context)
        if context.ending_shop and not context.blueprint then
            if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local new_card = create_card('Equipment', G.consumeables, nil, nil, nil, nil, nil, 'runecarver')
                        new_card:add_to_deck()
                        G.consumeables:emplace(new_card)
                        G.GAME.consumeable_buffer = 0
                        return true
                    end
                }))
                return {
                    message = "Memory Restored!",
                    colour = G.C.BLUE,
                    card = card
                }
            end
        end
        if context.joker_main then
            local count = 0
            for _, j in ipairs(G.jokers.cards) do
                if j.ability.warcraft_equipment then
                    count = count + 1
                end
            end

            local total_xmult = 1 + (count * card.ability.extra.x_mult_per)

            if total_xmult > 1 then
                return {
                    Xmult_mod = total_xmult,
                    message = "Domination!",
                    colour = G.C.DARK_EDITION
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Pelagos",
    race = {"Kyrian"},
    class = {"Priest"}, 
    weapon = {"Polearm"},
    rarity = 2,
    cost = 6,
    index = 190,

    config = { extra = { x_mult = 2 } },

    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult if played hand",
        "contains only {C:attention}Even Ranked{} cards",
        "{C:inactive}(2, 4, 6, 8, 10, Q){}"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local only_even = true
            for i = 1, #context.full_hand do
                local id = context.full_hand[i]:get_id()
                if id % 2 ~= 0 or id == 14 then 
                    only_even = false
                    break
                end
            end

            if only_even and #context.full_hand > 0 then
                return {
                    message = "Soulbind!",
                    Xmult_mod = card.ability.extra.x_mult,
                    colour = G.C.BLUE
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Ve'nari",
    race = {"Broker"},
    class = {"Rogue"},
    weapon = {"Bow"},
    rarity = 2,
    cost = 6,
    index = 191,

    config = { extra = { mult = 0, gain = 7 } },

    loc_txt = {
        "{C:mult}+#1#{} Mult",
        "Gains {C:mult}+#2#{} Mult for each",
        "{C:money}$1{} of {C:attention}Interest{} earned",
        "{C:inactive}(Currently {C:mult}+#3#{C:inactive} Mult){}"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.mult, card.ability.extra.gain, card.ability.extra.mult }
    end,

    calculate = function(self, card, context)
        if context.interest and not context.blueprint then
            local interest_earned = context.interest_amt or 0
            if interest_earned > 0 then
                card.ability.extra.mult = card.ability.extra.mult + (interest_earned * card.ability.extra.gain)
                return {
                    message = "Appreciated!",
                    colour = G.C.MULT,
                    card = card
                }
            end
        end
        if context.joker_main then
            if card.ability.extra.mult > 0 then
                return {
                    mult = card.ability.extra.mult,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Broll Bearmantle",
    faction = {"Alliance"},
    race = {"Night Elf"},
    class = {"Druid"},
    weapon = {"Staff","Fist"},
    rarity = 2,
    cost = 6,
    index = 192,

    config = { extra = { x_mult = 2 } },

    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult if",
        "played hand is a {C:attention}Pair{}"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            if context.scoring_name == "Pair" then
                return {
                    message = "Nature's Rage!",
                    Xmult_mod = card.ability.extra.x_mult,
                    colour = G.C.GREEN,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Gahz'rilla",
    race = {"Beast"},
    weapon = {"Fist"},
    rarity = 2,
    cost = 8,
    index = 193,

    config = { extra = { x_mult = 3 } },

    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult if",
        "played hand is a",
        "{C:attention}Three of a Kind{}"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            if context.scoring_name == "Three of a Kind" then
                return {
                    message = "Multi-Headed!",
                    Xmult_mod = card.ability.extra.x_mult,
                    colour = G.C.ORANGE,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Huntsman Altimor",
    race = {"Venthyr"},
    class = {"Hunter"},
    weapon = {"Bow","Daggers"},
    rarity = 2,
    cost = 6,
    index = 194,
    config = { extra = {} },
    loc_txt = {
        "Each time a {C:attention}Wild Card{} scores,",
        "a random {C:attention}Beast{} Joker",
        "gains a {C:attention}Level{} and {C:attention}Ilvl{}"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_wild
        return {}
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            if context.other_card.config.center.key == 'm_wild' then

                -- Collect all Beast jokers
                local beast_jokers = {}
                if G.jokers then
                    for _, j in ipairs(G.jokers.cards) do
                        if j ~= card and Warcraft.is_race(j, "Beast") then
                            table.insert(beast_jokers, j)
                        end
                    end
                end

                if #beast_jokers > 0 then
                    local target = pseudorandom_element(beast_jokers, pseudoseed('altimor_' .. G.GAME.round))

                    G.E_MANAGER:add_event(Event({
                        func = function()
                            -- Level up (bypass cap by raising max_level if needed)
                            if target.ability.extra and target.ability.extra.level then
                                target.ability.extra.level = target.ability.extra.level + 1
                                if target.ability.extra.max_level and
                                   target.ability.extra.level > target.ability.extra.max_level then
                                    target.ability.extra.max_level = target.ability.extra.level
                                end
                            end

                            -- Ilvl up (bypass cap)
                            if target.ability.wow_equipment then
                                local eq = target.ability.wow_equipment
                                eq.ilvl = (eq.ilvl or 1) + 1
                                -- Bypass the per-round ilvl gain cap
                                eq.ilvl_gained_this_round = 0
                            end

                            card_eval_status_text(target, 'extra', nil, nil, nil, {
                                message = "Empowered!",
                                colour = G.C.GREEN
                            })
                            target:juice_up()
                            return true
                        end
                    }))

                    return {
                        message = "Margore!",
                        colour = G.C.GREEN,
                        card = card
                    }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Vereesa Windrunner",
    faction = {"Alliance"},
    race = {"Blood Elf"},
    class = {"Hunter"},
    weapon = {"Bow","Sword"},
    rarity = 1,
    cost = 4,
    index = 195,
    config = { extra = {} },
    loc_txt = {
        "Scoring {C:attention}3s{} give {C:mult}+Mult{}",
        "equal to the number of {C:attention}3s{} in your deck"
    },
    loc_vars = function(self, info_queue, card)
        return {}
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:get_id() == 3 then
                local count = 0
                if G.playing_cards then
                    for _, c in ipairs(G.playing_cards) do
                        if c:get_id() == 3 then
                            count = count + 1
                        end
                    end
                end

                if count > 0 then
                    return {
                        mult = count,
                        card = context.other_card,
                        message = "Thas'dorah!",
                        colour = G.C.MULT
                    }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Algalon the Observer",
    race = {"Titan"},
    class = {"Mage"},
    weapon = {"Fist"},
    rarity = 3,
    cost = 20,
    index = 196,

    config = { extra = { payout = 100 } },

    loc_txt = {
        "If you would {C:red}fail{} a Blind,",
        "prevent {C:attention}Game Over{}, {C:red}destroy{}",
        "all Jokers, and gain {C:money}$#1#{}"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.payout }
    end,

    calculate = function(self, card, context)
        if context.game_over and not context.blueprint then
            if G.GAME.chips < G.GAME.blind.chips then
                
                G.E_MANAGER:add_event(Event({
                    func = function()
                        attention_text({
                            text = 'RE-ORIGINATION ABORTED',
                            scale = 1.3, 
                            hold = 3,
                            major = card,
                            backdrop_colour = G.C.BLUE,
                            align = 'cm',
                        })
                        play_sound('magic1')
                        ease_dollars(card.ability.extra.payout)
                        for i = #G.jokers.cards, 1, -1 do
                            local j = G.jokers.cards[i]
                            j:start_dissolve()
                        end
                        G.GAME.chips = G.GAME.blind.chips
                        return true
                    end
                }))

                return {
                    saved = true 
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Lothraxion",
    faction = {"Alliance","legion"}, 
    race = {"Undead","Demon","Nathrezim"},
    class = {"Paladin"}, 
    weapon = {"Sword"},
    rarity = 1,
    cost = 4,
    index = 197,

    config = { extra = { chance = 10 } },

    loc_txt = {
        "Scoring cards have a",
        "{C:green}1 in #1#{} chance to",
        "become {C:money}Gold Cards{}"
    },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_gold
        return { card.ability.extra.chance }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local other = context.other_card
            if other.config.center ~= G.P_CENTERS.m_gold then
                if pseudorandom('lothraxion') < G.GAME.probabilities.normal / card.ability.extra.chance then
                    
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            other:set_ability(G.P_CENTERS.m_gold)
                            other:juice_up()
                            return true
                        end
                    }))

                    return {
                        message = "Redeemed!",
                        colour = G.C.MONEY,
                        card = card
                    }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Shirvallah",
    faction = {"Horde"}, 
    race = {"Loa"},
    class = {"Paladin"},
    weapon = {"Fist"},
    rarity = 1,
    cost = 5,
    index = 198,

    config = { extra = { mult = 4 } },

    loc_txt = {
        "Played {C:attention}6s, 7s, and 8s{} give",
        "{C:mult}+#1#{} Mult when scored"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.mult }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local id = context.other_card:get_id()
            if id == 6 or id == 7 or id == 8 then
                return {
                    mult = card.ability.extra.mult,
                    card = context.other_card,
                    message = "Loa's Strength!",
                    colour = G.C.ORANGE
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Ohn'ahra",
    race = {"Beast", "God"},
    class = {"Druid"},
    weapon = {"Fist"},
    rarity = 2,
    cost = 7,
    index = 199,

    config = { extra = { hand_size = 2, discards = 1 } },

    loc_txt = {
        "{C:attention}+#1#{} Hand Size",
        "{C:attention}+#2#{} Discard each round"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.hand_size, card.ability.extra.discards }
    end,
    add_to_deck = function(self, card, from_debuff)
        G.hand:change_relative_config('card_limit', card.ability.extra.hand_size)
        G.GAME.round_resets.discards = G.GAME.round_resets.discards + card.ability.extra.discards
        ease_discard(card.ability.extra.discards)
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.hand:change_relative_config('card_limit', -card.ability.extra.hand_size)
        G.GAME.round_resets.discards = G.GAME.round_resets.discards - card.ability.extra.discards
        ease_discard(-card.ability.extra.discards)
    end
})

Warcraft.create_warcraft_joker({
    name = "Malkorok",
    faction = {"Horde"}, 
    race = {"Orc"},
    class = {"Warrior"},
    weapon = {"Sword"},
    rarity = 2,
    cost = 6,
    index = 200,

    config = { extra = { mult = 5, repetitions = 1 } },

    loc_txt = {
        "Played {C:attention}Bonus Cards{} give",
        "{C:mult}+#1#{} Mult and retrigger",
        "{C:attention}#2#{} additional time"
    },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_bonus
        return { card.ability.extra.mult, card.ability.extra.retrigger }
    end,

    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            if context.other_card.config.center.key == 'm_bonus' then
                return {
                    message = "Fatal Strike!",
                    repetitions = card.ability.extra.repetitions,
                    card = card
                }
            end
        end
        if context.individual and context.cardarea == G.play then
            if context.other_card.config.center.key == 'm_bonus' then
                return {
                    mult = card.ability.extra.mult,
                    card = context.other_card,
                    message = "Enraged!",
                    colour = G.C.RED
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Remornia",
    class = {"Warrior"}, 
    weapon = {"Sword"},
    rarity = 3,
    cost = 10,
    index = 201,

    config = { extra = { ilvl_gain = 10 } },

    loc_txt = {
        "Cannot be {C:attention}Equipped{}.",
        "When a {C:attention}Blind{} is defeated, all",
        "{C:attention}Equipment{} on other Jokers",
        "permanently gain {C:attention}+#1# ilvl{}."
    },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = {key = 'equipment', set = 'Other'}
        return { card.ability.extra.ilvl_gain }
    end,

    calculate = function(self, card, context)
        if context.end_of_round and not context.blueprint and not (context.individual or context.repetition) then
            local equipment_found = false
            
            for _, j in ipairs(G.jokers.cards) do
                if j ~= card and j.ability.warcraft_equipment then
                    j.ability.warcraft_equipment.ilvl = (j.ability.warcraft_equipment.ilvl or 0) + card.ability.extra.ilvl_gain
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            card_eval_status_text(j, 'extra', nil, nil, nil, {
                                message = "Sharpened!", 
                                colour = G.C.RED
                            })
                            j:juice_up()
                            return true
                        end
                    }))
                    equipment_found = true
                end
            end

            if equipment_found then
                return {
                    message = "Feed the Blade!",
                    colour = G.C.DARK_EDITION,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Mankrik",
    faction = {"Horde"},
    race = {"Orc"},
    class = {"Warrior"},
    weapon = {"Axe"},
    rarity = 2,
    cost = 5,
    index = 202,

    config = { extra = { chips = 0, mult = 0, chip_gain = 5, mult_gain = 2 } },

    loc_txt = {
        "{C:chips}+#1#{} Chips, {C:mult}+#2#{} Mult",
        "{C:inactive}(Gains {C:chips}+#3#{} and {C:mult}+#4#{} per",
        "{C:attention}Queen{} discarded this run){}"
    },

    loc_vars = function(self, info_queue, card)
        return { 
            card.ability.extra.chips, 
            card.ability.extra.mult, 
            card.ability.extra.chip_gain, 
            card.ability.extra.mult_gain 
        }
    end,

    calculate = function(self, card, context)
        if context.discard and not context.blueprint then
            local queens_discarded = 0
            for i = 1, #context.full_hand do
                if context.full_hand[i]:get_id() == 12 then 
                    queens_discarded = queens_discarded + 1
                end
            end

            if queens_discarded > 0 then
                card.ability.extra.chips = card.ability.extra.chips + (queens_discarded * card.ability.extra.chip_gain)
                card.ability.extra.mult = card.ability.extra.mult + (queens_discarded * card.ability.extra.mult_gain)
                
                return {
                    message = "Olgra?!",
                    colour = G.C.RED,
                    card = card
                }
            end
        end
        if context.joker_main then
            if card.ability.extra.chips > 0 or card.ability.extra.mult > 0 then
                return {
                    chips = card.ability.extra.chips,
                    mult = card.ability.extra.mult,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Moroes",
    race = {"Undead"},
    class = {"Rogue"},
    weapon = {"Daggers","Sword"},
    rarity = 3, 
    cost = 9,
    index = 203,

    config = { extra = { x_mult = 1, gain = 0.3, threshold = 5, guests = {} } },

    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "Gains {X:mult,C:white} X#2# {} for every {C:attention}#3#{}",
        "unique {C:attention}Jokers{} seen this run",
        "{C:inactive}(Guests seen: {C:attention}#4#{C:inactive})"
    },

    loc_vars = function(self, info_queue, card)
        local count = 0
        for _ in pairs(card.ability.extra.guests) do count = count + 1 end
        return { card.ability.extra.x_mult, card.ability.extra.gain, card.ability.extra.threshold, count }
    end,

    calculate = function(self, card, context)
        if (context.setting_blind or context.buying_card or context.open_booster) and not context.blueprint then
            local new_guest_found = false
            for _, j in ipairs(G.jokers.cards) do
                local j_key = j.config.center.key
                if not card.ability.extra.guests[j_key] then
                    card.ability.extra.guests[j_key] = true
                    new_guest_found = true
                end
            end

            if new_guest_found then
                local count = 0
                for _ in pairs(card.ability.extra.guests) do count = count + 1 end
                local new_xmult = 1 + (math.floor(count / card.ability.extra.threshold) * card.ability.extra.gain)
                
                if new_xmult > card.ability.extra.x_mult then
                    card.ability.extra.x_mult = new_xmult
                    return {
                        message = "Guest Arrived!",
                        colour = G.C.BLUE,
                        card = card
                    }
                end
            end
        end
        if context.joker_main then
            if card.ability.extra.x_mult > 1 then
                return {
                    Xmult_mod = card.ability.extra.x_mult,
                    message = "Welcome!",
                    colour = G.C.PURPLE
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Prince Renathal",
    race = {"Venthyr"},
    class = {"Warrior"},
    weapon = {"Sword"},
    rarity = 3, 
    cost = 10,
    index = 204,

    config = { extra = { slots = 2 } },

    loc_txt = {
        "{C:attention}+#1#{} Joker Slots"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.slots }
    end,
    add_to_deck = function(self, card, from_debuff)
        G.jokers.config.card_limit = G.jokers.config.card_limit + card.ability.extra.slots
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.jokers.config.card_limit = G.jokers.config.card_limit - card.ability.extra.slots
    end
})

Warcraft.create_warcraft_joker({
    name = "Old Murk-Eye",
    race = {"Murloc"},
    class = {"Warrior"},
    weapon = {"Hammer","Fist"},
    rarity = 2,
    cost = 6,
    index = 205,

    config = { extra = { chip_mod = 6, mult_mod = 1 } },

    loc_txt = {
        "{C:chips}+#1#{} Chips and {C:mult}+#2#{} Mult for each",
        "{C:attention}2, 3, or 4{} in your full deck",
        "{C:inactive}(Currently {C:chips}+#3#{C:inactive} Chips and {C:mult}+#4#{C:inactive} Mult)"
    },

    loc_vars = function(self, info_queue, card)
        local count = 0
        if G.playing_cards then
            for _, v in ipairs(G.playing_cards) do
                local id = v:get_id()
                if id == 2 or id == 3 or id == 4 then
                    count = count + 1
                end
            end
        end
        return { 
            card.ability.extra.chip_mod, 
            card.ability.extra.mult_mod, 
            count * card.ability.extra.chip_mod, 
            count * card.ability.extra.mult_mod 
        }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local count = 0
            for _, v in ipairs(G.playing_cards) do
                local id = v:get_id()
                if id == 2 or id == 3 or id == 4 then
                    count = count + 1
                end
            end

            if count > 0 then
                return {
                    chips = count * card.ability.extra.chip_mod,
                    mult = count * card.ability.extra.mult_mod,
                    message = "Mrglglgl!",
                    colour = G.C.GREEN,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Vanndar Stormpike",
    faction = {"Alliance"},
    race = {"Dwarf"},
    class = {"Warrior"}, 
    weapon = {"Axe","Hammer","Shield"},
    rarity = 3, 
    cost = 8,
    index = 206,

    config = { extra = { x_mult = 3 } },

    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult if",
        "played hand is a",
        "{C:attention}Full House{}"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            if context.scoring_name == "Full House" then
                return {
                    message = "For Ironforge!",
                    Xmult_mod = card.ability.extra.x_mult,
                    colour = G.C.CHIPS, 
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Al'ar",
    race = {"Elemental"},
    class = {"Mage"},
    weapon = {"Fist"},
    rarity = 2,
    cost = 7,
    index = 207,

    config = { extra = { chips = 500, loss = 100, gain = 200 } },

    loc_txt = {
        "{C:chips}+#1#{} Chips",
        "{C:red}-#2#{} Chips per {C:attention}hand played{}",
        "{C:chips}+#3#{} Chips whenever a {C:attention}Joker{}",
        "is {C:red}sold{} or {C:red}destroyed{}"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.chips, card.ability.extra.loss, card.ability.extra.gain }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return {
                chips = card.ability.extra.chips,
                card = card
            }
        end
        if context.after and not context.blueprint then
            card.ability.extra.chips = card.ability.extra.chips - card.ability.extra.loss
            return {
                message = "-" .. card.ability.extra.loss,
                colour = G.C.RED
            }
        end
        if context.remove_from_deck and not context.blueprint then
            if context.other_card and context.other_card.ability.set == 'Joker' and context.other_card ~= card then
                card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.gain
                return {
                    message = "Rebirth!",
                    colour = G.C.CHIPS,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Blingtron 3000",
    race = {"Gnome", "Robot"},
    class = {"Rogue"},
    weapon = {"Gun", "Fist"},
    rarity = 1,
    cost = 4,
    index = 208,

    loc_txt = {
        "At the end of the {C:attention}Shop phase{},",
        "attach a random {C:attention}Equipment{}",
        "to a random {C:attention}Joker{} that doesn't",
        "already have one."
    },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = {key = 'equipment', set = 'Other'}
        return {}
    end,

    calculate = function(self, card, context)
        if context.ending_shop and not context.blueprint then
            local targets = {}
            for _, j in ipairs(G.jokers.cards) do
                if not j.ability.warcraft_equipment then
                    table.insert(targets, j)
                end
            end
            if #targets > 0 then
                local target_joker = pseudorandom_element(targets, pseudoseed('blingtron'))
                
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local temp_eff = create_card('Equipment', G.consumeables, nil, nil, nil, nil, nil, 'bling')
                        if temp_eff.apply_to_joker then
                            temp_eff:apply_to_joker(target_joker)
                        else
                            target_joker.ability.warcraft_equipment = temp_eff.ability
                        end
                        
                        card_eval_status_text(target_joker, 'extra', nil, nil, nil, {
                            message = "Party Gift!", 
                            colour = G.C.GOLD
                        })
                        temp_eff:remove()
                        return true
                    end
                }))

                return {
                    message = "Free Loot!",
                    colour = G.C.MONEY,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Harrison Jones",
    faction = {"Alliance"}, 
    race = {"Human"},
    class = {"Rogue"}, 
    weapon = {"Hammer","Sword"},
    rarity = 2,
    cost = 6,
    index = 209,

    config = { extra = { mult = 0, chips = 0, mult_gain = 5, chip_gain = 40 } },

    loc_txt = {
        "{C:mult}+#1#{} Mult, {C:chips}+#2#{} Chips",
        "Gains {C:mult}+#3#{} Mult when an {C:attention}Equipment{} is used",
        "Gains {C:chips}+#4#{} Chips when an {C:attention}Equipment{} is sold"
    },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = {key = 'equipment', set = 'Other'}
        return { 
            card.ability.extra.mult, 
            card.ability.extra.chips, 
            card.ability.extra.mult_gain, 
            card.ability.extra.chip_gain 
        }
    end,

    calculate = function(self, card, context)
        if context.using_consumeable and not context.blueprint then
            if context.consumeable.config.center.set == 'Equipment' then
                card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain
                return {
                    message = "Discovery!",
                    colour = G.C.MULT,
                    card = card
                }
            end
        end
        if context.selling_card and not context.blueprint then
            local sold = context.card
            if sold and sold.config and sold.config.center and sold.config.center.set == 'Equipment' then
                card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_gain
                return {
                    message = "To the Museum!",
                    colour = G.C.CHIPS,
                    card = card
                }
            end
        end
        if context.joker_main then
            if card.ability.extra.mult > 0 or card.ability.extra.chips > 0 then
                return {
                    mult = card.ability.extra.mult,
                    chips = card.ability.extra.chips,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Theotar, the Mad Duke",
    race = {"Venthyr"},
    rarity = 1,
    cost = 4,
    index = 210,

    config = { extra = { x_mult = 1.2, gain = 0.15 } },

    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "Swaps position with a random {C:attention}Joker{}",
        "before scoring. Gains {X:mult,C:white} X#2# {} per swap."
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult, card.ability.extra.gain }
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local other_jokers = {}
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] ~= card then
                    table.insert(other_jokers, i)
                end
            end
            if #other_jokers > 0 then
                local target_idx = pseudorandom_element(other_jokers, pseudoseed('theotar'))
                local my_idx = 0
                for i = 1, #G.jokers.cards do
                    if G.jokers.cards[i] == card then my_idx = i break end
                end
                G.jokers.cards[my_idx], G.jokers.cards[target_idx] = G.jokers.cards[target_idx], G.jokers.cards[my_idx]
                card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.gain
                
                return {
                    message = "Swap!",
                    colour = G.C.PURPLE,
                    card = card
                }
            end
        end
        if context.joker_main then
            if card.ability.extra.x_mult > 1 then
                return {
                    Xmult_mod = card.ability.extra.x_mult,
                    message = "Madness!",
                    colour = G.C.MULT
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Chef Nomi",
    race = {"Pandaren"},
    weapon = {"Hammer"},
    rarity = 2,
    cost = 6,
    index = 211,

    config = { extra = { mult = 0, gain = 15 } },

    loc_txt = {
        "{C:mult}+#1#{} Mult",
        "At the end of the {C:attention}Shop phase{},",
        "{C:red}destroy{} a random {C:attention}Consumable{}",
        "to permanently gain {C:mult}+#2#{} Mult.",
        "(Currently {C:mult}+#1#{C:inactive} Mult){}"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.mult, card.ability.extra.gain }
    end,

    calculate = function(self, card, context)
        if context.ending_shop and not context.blueprint then
            if G.consumeables.cards[1] then
                local card_to_burn = pseudorandom_element(G.consumeables.cards, pseudoseed('nomi'))
                
                G.E_MANAGER:add_event(Event({
                    func = function()
                        card_to_burn:start_dissolve()
                        card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.gain
                        
                        card_eval_status_text(card, 'extra', nil, nil, nil, {
                            message = "Well Done!", 
                            colour = G.C.FILTER
                        })
                        return true
                    end
                }))
            end
        end
        if context.joker_main then
            if card.ability.extra.mult > 0 then
                return {
                    mult = card.ability.extra.mult,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Invincible",
    faction = {"Scourge"},
    race = {"Undead"},
    class = {"Death Knight"}, 
    weapon = {"Fist"},
    rarity = 3, 
    cost = 10,
    index = 212,

    config = { extra = { chance = 10, slots_gained = 0 } },

    loc_txt = {
        "{C:green}1 in #1#{} chance to permanently",
        "gain {C:attention}+1{} Joker Slot when",
        "a {C:attention}Blind{} is defeated.",
        "{C:inactive}(Total slots gained: {C:attention}+#2#{C:inactive})"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.chance, card.ability.extra.slots_gained }
    end,

    calculate = function(self, card, context)
        if context.end_of_round and not context.blueprint and not (context.individual or context.repetition) then
            if pseudorandom('invincible') < G.GAME.probabilities.normal / card.ability.extra.chance then
                G.jokers.config.card_limit = G.jokers.config.card_limit + 1
                card.ability.extra.slots_gained = card.ability.extra.slots_gained + 1
                
                return {
                    message = "Drop Obtained!",
                    colour = G.C.FILTER,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Lord Jaraxxus",
    faction = {"Legion"}, 
    race = {"Demon"},
    class = {"Warlock"},
    weapon = {"Axe"},
    rarity = 1,
    cost = 7,
    index = 213,

    config = { extra = { x_mult = 1, gain = 1 } },

    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "Gains {X:mult,C:white} X#2# {} whenever a",
        "{C:attention}Gnome Joker{} is {C:red}sold{} or {C:red}destroyed{}"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult, card.ability.extra.gain }
    end,

    calculate = function(self, card, context)
        if context.remove_from_deck and not context.blueprint then
            if context.other_card and context.other_card.ability.set == 'Joker' then
                if context.other_card.ability.warcraft_race == "Gnome" then
                    card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.gain
                    return {
                        message = "OBLIVION!",
                        colour = G.C.RED,
                        card = card
                    }
                end
            end
        end
        if context.joker_main then
            if card.ability.extra.x_mult > 1 then
                return {
                    Xmult_mod = card.ability.extra.x_mult,
                    message = "INFERNO!",
                    colour = G.C.DARK_EDITION
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Queen Neferess",
    race = {"Nerubian"},
    weapon = {"Fist"},
    rarity = 2,
    cost = 7,
    index = 214,

    config = { extra = { chips = 30, mult = 6 } },

    loc_txt = {
        "At the start of each {C:attention}Blind{},",
        "create a random {C:spades}Spade{} card in hand.",
        "{C:spades}Spades{} give {C:chips}+#1#{} Chips and",
        "{C:mult}+#2#{} Mult when scored."
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.chips, card.ability.extra.mult }
    end,

    calculate = function(self, card, context)
        if context.setting_blind and not (context.blueprint or context.re-set_joker) then
            G.E_MANAGER:add_event(Event({
                func = function()
                    local _card = create_playing_card({
                        front = pseudorandom_element(G.P_CARDS, pseudoseed('neferess')), 
                        center = G.P_CENTERS.c_base
                    }, G.hand, nil, nil, {suit = 'Spades'})
                    
                    G.hand:sort()
                    card_eval_status_text(card, 'extra', nil, nil, nil, {
                        message = "The Swarm Grows!",
                        colour = G.C.CHIPS
                    })
                    return true
                end
            }))
        end
        if context.individual and context.cardarea == G.play then
            if context.other_card:is_suit('Spades') then
                return {
                    chips = card.ability.extra.chips,
                    mult = card.ability.extra.mult,
                    card = context.other_card,
                    colour = G.C.CHIPS
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Queen Ansurek",
    race = {"Nerubian"},
    weapon = {"Fist"},
    rarity = 3, 
    cost = 9,
    index = 215,

    config = { extra = { first_buy = true } },

    loc_txt = {
        "The {C:attention}first Joker{} bought in each",
        "shop becomes {C:dark_edition}Negative{} and {C:red}Perishable{}.",
        "{C:inactive}(Currently: #1#){}"
    },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.e_negative
        info_queue[#info_queue+1] = G.P_CENTERS.m_perishable
        return { card.ability.extra.first_buy and "{C:green}Ready{}" or "{C:red}Used{}" }
    end,

    calculate = function(self, card, context)
        if context.ending_shop then
            card.ability.extra.first_buy = true
        end
        if context.buying_card and not context.blueprint then
            if context.card.ability.set == 'Joker' and card.ability.extra.first_buy then
                card.ability.extra.first_buy = false
                
                G.E_MANAGER:add_event(Event({
                    func = function()
                        context.card:set_edition({negative = true}, true)
                        context.card:set_perishable(true)
                        
                        card_eval_status_text(card, 'extra', nil, nil, nil, {
                            message = "Corrupted!",
                            colour = G.C.DARK_EDITION
                        })
                        return true
                    end
                }))
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Argus the Unmaker",
    race = {"Titan"},
    weapon = {"Polearm"},
    rarity = 3,
    cost = 10,
    index = 216,

    config = { extra = { chips = 0, first_discard = true } },

    loc_txt = {
        "{C:chips}+#1#{} Chips",
        "The {C:attention}first card{} discarded each",
        "Blind is {C:red}destroyed{}; gain its",
        "{C:chips}base Chips{} permanently.",
        "(Currently {C:chips}+#1#{C:inactive}){}",
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.chips }
    end,

    calculate = function(self, card, context)
        if context.setting_blind then
            card.ability.extra.first_discard = true
        end
        if context.discard and not context.blueprint and card.ability.extra.first_discard then
            local target_card = context.full_hand[1]
            card.ability.extra.first_discard = false
            local chip_gain = target_card:get_chip_bonus()

            G.E_MANAGER:add_event(Event({
                func = function()
                    card.ability.extra.chips = card.ability.extra.chips + chip_gain
                    target_card:start_dissolve()
                    
                    card_eval_status_text(card, 'extra', nil, nil, nil, {
                        message = "Unmade!",
                        colour = G.C.CHIPS
                    })
                    return true
                end
            }))
        end
        if context.joker_main then
            if card.ability.extra.chips > 0 then
                return {
                    chips = card.ability.extra.chips,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Raszageth",
    race = {"Dragon"},
    class = {"Shaman"},
    weapon = {"Fist"},
    rarity = 3,
    cost = 10,
    index = 217,

    config = { extra = { x_mult = 1, gain = 0.2 } },

    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "When a card with a {C:blue}Blue Seal{} scores,",
        "{C:red}remove{} the seal and permanently",
        "gain {X:mult,C:white} X#2# {} Mult."
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult, card.ability.extra.gain }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card.seal == 'Blue' then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        context.other_card:set_seal(nil) 
                        card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.gain
                        
                        card_eval_status_text(card, 'extra', nil, nil, nil, {
                            message = "Storm Surge!",
                            colour = G.C.BLUE
                        })
                        return true
                    end
                }))
            end
        end
        if context.joker_main then
            if card.ability.extra.x_mult > 1 then
                return {
                    Xmult_mod = card.ability.extra.x_mult,
                    message = "Crackling Power!",
                    colour = G.C.SECONDARY_SET
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Aegwynn",
    faction = {"Alliance"},
    race = {"Human"},
    class = {"Mage"},
    weapon = {"Staff"},
    rarity = 3,
    cost = 10,
    index = 218,

    config = { extra = { chips = 500, x_mult = 3 } },

    loc_txt = {
        "If {C:attention}Aegwynn{} is your only",
        "{C:attention}Human{} and {C:blue}Alliance{} Joker,",
        "gain {C:chips}+#1#{} Chips and {X:mult,C:white} X#2# {} Mult."
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.chips, card.ability.extra.x_mult }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local is_alone = true
            for _, j in ipairs(G.jokers.cards) do
                if j ~= card then
                    if j.ability.warcraft_race == "Human" or j.ability.warcraft_faction == "Alliance" then
                        is_alone = false
                        break
                    end
                end
            end

            if is_alone then
                return {
                    chips = card.ability.extra.chips,
                    Xmult_mod = card.ability.extra.x_mult,
                    message = "Magna's Power!",
                    colour = G.C.PURPLE,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Varimathras",
    faction = {"Scourge","Legion","Horde"}, 
    race = {"Undead","Demon","Nathrezim"},
    class = {"Rogue"},
    weapon = {"Sword","Fist"},
    rarity = 1,
    cost = 3,
    index = 219,

    config = { extra = { mult_val = 5, xmult_val = 0.2 } },

    loc_txt = {
        "{C:mult}+#1#{} Mult for each Joker of your {C:attention}most{} owned Horde and Alliance faction,",
        "{C:red}-#1#{} Mult for each of the {C:attention}least{} owned.",
        "{X:mult,C:white} X#2# {} Mult for each Joker of your {C:attention}most{} owned Scourge and Legion faction,",
        "{C:red}X-#2#{} Mult for each of the {C:attention}least{} owned."
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.mult_val, card.ability.extra.xmult_val }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local counts = { Alliance = 0, Horde = 0, Legion = 0, Scourge = 0 }
            for _, j in ipairs(G.jokers.cards) do
                local f = j.ability.warcraft_faction
                if counts[f] ~= nil then
                    counts[f] = counts[f] + 1
                end
            end
            local mortal_mult = 0
            if counts.Alliance > counts.Horde then
                mortal_mult = (counts.Alliance * card.ability.extra.mult_val) - (counts.Horde * card.ability.extra.mult_val)
            else
                mortal_mult = (counts.Horde * card.ability.extra.mult_val) - (counts.Alliance * card.ability.extra.mult_val)
            end
            local evil_xmult = 1
            local diff = math.abs(counts.Legion - counts.Scourge)
            evil_xmult = 1 + (diff * card.ability.extra.xmult_val)

            return {
                mult = mortal_mult,
                Xmult_mod = evil_xmult,
                message = "Betrayal!",
                colour = G.C.FILTER,
                card = card
            }
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Tichondrius",
    faction = {"Scourge","Legion"}, 
    race = {"Undead", "Demon", "Nathrezim"},
    class = {"Warlock"},
    weapon = {"Sword","Fist"},
    rarity = 3,
    cost = 10,
    index = 220,

    loc_txt = {
        "Copies the effect of the",
        "{C:attention}rightmost{} Joker during a {C:attention}Blind{}."
    },

    calculate = function(self, card, context)
        if G.STATE ~= G.STATES.SHOP and G.jokers and G.jokers.cards then
            local rightmost = G.jokers.cards[#G.jokers.cards]
            
            if rightmost and rightmost ~= card and rightmost.config.center.key ~= self.key then
                
                local res = SMODS.blueprint_effect(card, rightmost, context)
                
                if res then
                    res.colour = G.C.DARK_EDITION 
                    return res
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Terenas Menethil II",
    faction = {"Alliance"},
    race = {"Human"},
    weapon = {"Hammer","Shield"},
    rarity = 2,
    cost = 7,
    index = 221,
    config = { extra = { x_chips = 1, x_mult = 1, x_gain = 0.2 } },
    loc_txt = {
        "{X:chips,C:white} X#1# {} Chips  {X:mult,C:white} X#2# {} Mult",
        "Gains {X:chips,C:white} X#3# {} Chips when a",
        "{C:attention}King{} is added to your deck",
        "Gains {X:mult,C:white} X#3# {} Mult when a",
        "{C:attention}King{} is {C:red}destroyed{}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.x_chips,
            card.ability.extra.x_mult,
            card.ability.extra.x_gain
        }
    end,
    calculate = function(self, card, context)
        -- Gain XChips when a King is added to the deck
        if context.playing_card_added and not context.blueprint then
            local added = context.card
            if added and added:get_id() == 13 then
                card.ability.extra.x_chips = card.ability.extra.x_chips + card.ability.extra.x_gain
                return {
                    message = "Heir to the Throne!",
                    colour = G.C.CHIPS,
                    card = card
                }
            end
        end

        -- Gain XMult when a King is destroyed
        if context.remove_playing_cards and not context.blueprint then
            local found = false
            for _, removed_card in ipairs(context.removed) do
                if removed_card:get_id() == 13 then
                    card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.x_gain
                    found = true
                end
            end
            if found then
                return {
                    message = "For Lordaeron!",
                    colour = G.C.MULT,
                    card = card
                }
            end
        end

        -- Apply both multipliers during scoring
        if context.joker_main then
            if card.ability.extra.x_chips > 1 or card.ability.extra.x_mult > 1 then
                return {
                    x_chips = card.ability.extra.x_chips,
                    x_mult = card.ability.extra.x_mult,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Rezan",
    faction = {"Horde"}, 
    race = {"God","Loa"},
    class = {"Paladin"},
    weapon = {"Fist"},
    rarity = 3,
    cost = 9,
    index = 222,

    config = { extra = { x_mult = 1.5 } },

    loc_txt = {
        "Scoring {C:attention}Kings{} become {C:dark_edition}Wild Cards{}",
        "and give {X:mult,C:white} X#1# {} Mult when scored."
    },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_wild
        return { card.ability.extra.x_mult }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local other = context.other_card
            if other:get_id() == 13 then
                if other.config.center ~= G.P_CENTERS.m_wild then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            other:set_ability(G.P_CENTERS.m_wild)
                            other:juice_up()
                            return true
                        end
                    }))
                end
                return {
                    Xmult_mod = card.ability.extra.x_mult,
                    card = other,
                    message = "Loa's Blessing!",
                    colour = G.C.GOLD
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Thalyssra",
    faction = {"Horde"}, 
    race = {"Night Elf"}, 
    class = {"Mage"},
    weapon = {"Staff"},
    rarity = 2,
    cost = 6,
    index = 223,

    config = { extra = { mult = 30, loss = 10, reset_val = 40 } },

    loc_txt = {
        "{C:mult}+#1#{} Mult",
        "Loses {C:red}#2#{} Mult per {C:attention}hand played{}.",
        "Resets to {C:mult}+#3#{} Mult whenever",
        "a {C:attention}Planet card{} is used."
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.mult, card.ability.extra.loss, card.ability.extra.reset_val }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return {
                mult = card.ability.extra.mult,
                card = card
            }
        end
        if context.after and not context.blueprint then
            card.ability.extra.mult = card.ability.extra.mult - card.ability.extra.loss
            return {
                message = "Withering...",
                colour = G.C.RED
            }
        end
        if context.using_consumeable and not context.blueprint then
            if context.consumeable.config.center.set == 'Planet' then
                card.ability.extra.mult = card.ability.extra.reset_val
                return {
                    message = "Arcan'dor Bloom!",
                    colour = G.C.SECONDARY_SET,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Johnny Awesome",
    faction = {"Horde"}, 
    race = {"Human"}, 
    class = {"Hunter"}, 
    weapon = {"Bow"},
    rarity = 2,
    cost = 6,
    index = 224,
    loc_txt = {
        "Gains {C:mult}+Mult{} equal to the total",
        "{C:attention}ilvl{} of all {C:attention}Equipment{}",
        "currently on your Jokers.",
        "Gains {C:attention}+24 Ilvl{} when equipped",
        "{C:inactive}(Currently {C:mult}+#1#{C:inactive} Mult){}"
    },
    loc_vars = function(self, info_queue, card)
        local total_ilvl = 0
        if G.jokers then
            for _, j in ipairs(G.jokers.cards) do
                if j.ability.wow_equipment then
                    total_ilvl = total_ilvl + (j.ability.wow_equipment.ilvl or 0)
                end
            end
        end
        return { total_ilvl }
    end,
    on_equip = function(self, joker)
        if joker.ability.wow_equipment then
            joker.ability.wow_equipment.ilvl = joker.ability.wow_equipment.ilvl + 24
            card_eval_status_text(joker, 'extra', nil, nil, nil, {
                message = "BiS!",
                colour = G.C.GOLD
            })
        end
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local total_ilvl = 0
            for _, j in ipairs(G.jokers.cards) do
                if j.ability.wow_equipment then
                    total_ilvl = total_ilvl + (j.ability.wow_equipment.ilvl or 0)
                end
            end
            if total_ilvl > 0 then
                return {
                    mult = total_ilvl,
                    card = card,
                    message = "BiS Gear!",
                    colour = G.C.MULT
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "A'dal",
    faction = {"Alliance"}, 
    race = {"Naaru"},
    class = {"Priest"}, 
    rarity = 3,
    cost = 10,
    index = 225,

    config = { extra = { chips = 0, chip_gain = 20, money_gain = 2 } },

    loc_txt = {
        "{C:chips}+#1#{} Chips",
        "Whenever a {C:money}Gold Card{} or {C:money}Gold Seal{}",
        "triggers, permanently gain {C:chips}+#2#{} Chips",
        "and {C:money}$#3#{}."
    },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_gold
        info_queue[#info_queue+1] = G.P_SEALS.Gold
        return { card.ability.extra.chips, card.ability.extra.chip_gain, card.ability.extra.money_gain }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card.seal == 'Gold' then
                card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_gain
                ease_dollars(card.ability.extra.money_gain)
                return {
                    message = "The Light!",
                    colour = G.C.MONEY,
                    card = card
                }
            end
        end
        if context.individual and context.cardarea == G.hand and not context.end_of_round then
            if context.other_card.config.center == G.P_CENTERS.m_gold then
                card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_gain
                ease_dollars(card.ability.extra.money_gain)
                return {
                    message = "Blessed!",
                    colour = G.C.GOLD,
                    card = card
                }
            end
        end
        if context.joker_main then
            if card.ability.extra.chips > 0 then
                return {
                    chips = card.ability.extra.chips,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Xuen",
    race = {"Beast", "God"},
    class = {"Monk"},
    weapon = {"Fist"},
    rarity = 3,
    cost = 9,
    index = 226,

    config = { extra = { x_mult = 3, level_up = 3 } },

    loc_txt = {
        "If played hand is exactly a {C:attention}High Card{},",
        "give {X:mult,C:white} X#1# {} Mult and upgrade",
        "{C:attention}High Card{} by {C:attention}#2#{} levels."
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult, card.ability.extra.level_up }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            if context.scoring_name == "High Card" then
                update_hand_stack(context.scoring_name, card.ability.extra.level_up)
                
                return {
                    message = "Tiger's Strength!",
                    Xmult_mod = card.ability.extra.x_mult,
                    colour = G.C.SECONDARY_SET, 
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Niuzao",
    race = {"Beast","God"},
    class = {"Monk"},
    weapon = {"Fist"},
    rarity = 2,
    cost = 7,
    index = 227,
    config = { extra = { x_mult = 2, count = 2 } },
    loc_txt = {
        "The first {C:attention}#2#{} scoring cards",
        "each hand give",
        "{X:mult,C:white} X#1# {} Mult when scored"
    },
    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult, card.ability.extra.count }
    end,
    calculate = function(self, card, context)
        -- Reset counter at the start of each hand
        if context.before and not context.blueprint then
            card.ability.extra.cards_scored_this_hand = 0
        end

        if context.individual and context.cardarea == G.play and not context.blueprint then
            if card.ability.extra.cards_scored_this_hand < card.ability.extra.count then
                card.ability.extra.cards_scored_this_hand = card.ability.extra.cards_scored_this_hand + 1
                return {
                    x_mult = card.ability.extra.x_mult,
                    message = "Iron Hide!",
                    colour = G.C.MULT,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Chi-Ji",
    race = {"Beast", "God"},
    class = {"Monk"}, 
    weapon = {"Fist"},
    rarity = 2,
    cost = 7,
    index = 228,

    config = { extra = { x_mult = 1, gain = 1 } },

    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "Gains {X:mult,C:white} X#2# {} after each {C:attention}hand played{}.",
        "{C:red}Resets{} when {C:attention}Blind{} is defeated."
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult, card.ability.extra.gain }
    end,

    calculate = function(self, card, context)
        if context.after and not context.blueprint then
            card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.gain
            return {
                message = "Hope Rising!",
                colour = G.C.RED
            }
        end
        if context.end_of_round and not (context.individual or context.repetition) and not context.blueprint then
            card.ability.extra.x_mult = 1
            return {
                message = "Resting...",
                colour = G.C.FILTER
            }
        end
        if context.joker_main then
            if card.ability.extra.x_mult > 1 then
                return {
                    Xmult_mod = card.ability.extra.x_mult,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Yu'lon",
    race = {"Beast", "God"},
    class = {"Monk"},
    weapon = {"Fist"},
    rarity = 3,
    cost = 9,
    index = 229,

    config = { extra = { x_mult = 1, gain = 0.2, hands_played = {} } },

    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "Permanently gains {X:mult,C:white} X#2# {} for each",
        "{C:attention}unique{} Poker Hand played this run.",
        "{C:inactive}(#3#/8 unique hands found){}"
    },

    loc_vars = function(self, info_queue, card)
        local count = 0
        for _ in pairs(card.ability.extra.hands_played) do count = count + 1 end
        return { card.ability.extra.x_mult, card.ability.extra.gain, count }
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local hand_type = context.scoring_name
            if not card.ability.extra.hands_played[hand_type] then
                card.ability.extra.hands_played[hand_type] = true
                card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.gain
                
                return {
                    message = "Wisdom Gained!",
                    colour = G.C.FILTER,
                    card = card
                }
            end
        end
        if context.joker_main then
            if card.ability.extra.x_mult > 1 then
                return {
                    Xmult_mod = card.ability.extra.x_mult,
                    message = "X" .. card.ability.extra.x_mult .. " Mult",
                    colour = G.C.MULT,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Calia Menethil",
    faction = {"Alliance"}, 
    race = {"Undead"},
    class = {"Priest"},
    weapon = {"Staff"},
    rarity = 3,
    cost = 9,
    index = 230,

    config = { extra = { x_mult = 1, gain = 0.5 } },

    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "If played hand contains at least",
        "one {C:attention}Gold Card{} and one {C:attention}Stone Card{},",
        "permanently gain {X:mult,C:white} X#2# {} Mult."
    },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_gold
        info_queue[#info_queue+1] = G.P_CENTERS.m_stone
        return { card.ability.extra.x_mult, card.ability.extra.gain }
    end,

    calculate = function(self, card, context)
        if context.joker_main and not context.blueprint then
            local has_gold = false
            local has_stone = false
            for _, k in ipairs(context.scoring_hand) do
                if k.config.center == G.P_CENTERS.m_gold then has_gold = true end
                if k.config.center == G.P_CENTERS.m_stone then has_stone = true end
            end

            if has_gold and has_stone then
                card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.gain
                return {
                    message = "Divine Union!",
                    colour = G.C.GOLD,
                    Xmult_mod = card.ability.extra.x_mult,
                    card = card
                }
            end
        end
        if context.joker_main and card.ability.extra.x_mult > 1 then
            return {
                Xmult_mod = card.ability.extra.x_mult,
                card = card
            }
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Reno Jackson",
    faction = {"Alliance"}, 
    race = {"Human"}, 
    class = {"Mage"}, 
    weapon = {"Staff","Gun","Sword"},
    rarity = 3,
    cost = 8,
    index = 231,

    config = { extra = { x_mult = 4 } },

    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult if",
        "played hand has",
        "{C:attention}no duplicate ranks{}."
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local seen_ranks = {}
            local has_duplicate = false
            
            for _, k in ipairs(context.scoring_hand) do
                local rank = k.base.value
                if seen_ranks[rank] then
                    has_duplicate = true
                    break
                end
                seen_ranks[rank] = true
            end
            if not has_duplicate then
                return {
                    message = "Rich!",
                    Xmult_mod = card.ability.extra.x_mult,
                    colour = G.C.GOLD,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Elise Starseeker",
    faction = {"Alliance"}, 
    race = {"Night Elf"},
    class = {"Druid"}, 
    weapon = {"Staff","Daggers"},
    rarity = 3,
    cost = 8,
    index = 232,

    config = { extra = { x_mult = 2 } },

    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult and generate",
        "a random {C:attention}Equipment{} if played",
        "hand is any type of {C:attention}Straight{}.",
    },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = {key = 'equipment', set = 'Other'}
        return { card.ability.extra.x_mult }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            if Warcraft.is_straight_hand(context.scoring_name) then
                if #G.consumeables.cards < G.consumeables.config.card_limit then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            local _card = create_card('Equipment', G.consumeables, nil, nil, nil, nil, nil, 'elise')
                            _card:add_to_deck()
                            G.consumeables:emplace(_card)
                            return true
                        end
                    }))
                end
                return {
                    message = "Discovery!",
                    Xmult_mod = card.ability.extra.x_mult,
                    colour = G.C.GREEN,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Sir Finley Mrrgglton",
    faction = {"Alliance"}, 
    race = {"Murloc"},
    class = {"Paladin"}, 
    weapon = {"Sword","Shield","Polearm","Spear","Fist"},
    rarity = 2,
    cost = 6,
    index = 233,

    config = { extra = { mult = 0, gain = 5 } },

    loc_txt = {
        "{C:mult}+#1#{} Mult",
        "Permanently gain {C:mult}+#2#{} Mult",
        "whenever a {C:attention}Booster Pack{} is opened.",
        "{C:inactive}(Currently {C:mult}+#1#{C:inactive} Mult){}"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.mult, card.ability.extra.gain }
    end,

    calculate = function(self, card, context)
        if context.open_pack and not context.blueprint then
            card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.gain
            return {
                message = "Mrgl!",
                colour = G.C.MULT,
                card = card
            }
        end
        if context.joker_main then
            if card.ability.extra.mult > 0 then
                return {
                    mult = card.ability.extra.mult,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Ashamane",
    faction = {"Alliance"},
    race = {"Beast", "God"},
    class = {"Druid"},
    weapon = {"Fist"},
    rarity = 2,
    cost = 6,
    index = 234,

    config = { extra = { mult = 15 } },

    loc_txt = {
        "Played {C:attention}Wild Cards{} give",
        "{C:mult}+#1#{} Mult when scored",
        "if their rank is an {C:attention}Odd Number{}"
    },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_wild
        return { card.ability.extra.mult }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local other = context.other_card
            local id = other:get_id()
            local is_odd = (id > 0 and id % 2 == 1) or (id == 14)
            
            if other.config.center.key == 'm_wild' and is_odd then
                return {
                    mult = card.ability.extra.mult,
                    card = other,
                    message = "Feral Strike!",
                    colour = G.C.MULT
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Huln Highmountain",
    faction = {"Horde"},
    race = {"Tauren"},
    class = {"Hunter"},
    weapon = {"Polearm", "Spear"},
    rarity = 2,
    cost = 6,
    index = 235,

    config = { extra = { repetitions = 1 } },

    loc_txt = {
        "Cards directly {C:attention}adjacent{} to the",
        "{C:attention}highest-ranked{} scoring card",
        "retrigger {C:attention}#1#{} additional time"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.repetitions }
    end,

    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            
            if context.scoring_hand and #context.scoring_hand > 0 then
                local max_rank = -1
                local max_index = -1
                
                for i = 1, #context.scoring_hand do
                    local rank = context.scoring_hand[i]:get_id()
                    if rank > max_rank then
                        max_rank = rank
                        max_index = i
                    end
                end
                local other_index = -1
                for i = 1, #context.scoring_hand do
                    if context.scoring_hand[i] == context.other_card then
                        other_index = i
                        break
                    end
                end
                if other_index ~= -1 and max_index ~= -1 then
                    if other_index == (max_index - 1) or other_index == (max_index + 1) then
                        return {
                            message = "Eagle Spear!",
                            repetitions = card.ability.extra.repetitions,
                            card = card
                        }
                    end
                end
            end
            
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Garr",
    race = {"Elemental"},
    class = {"Warrior"},
    weapon = {"Fist"},
    rarity = 2,
    cost = 6,
    index = 236,

    config = { extra = { chips = 30, mult = 4 } },

    loc_txt = {
        "Played {C:attention}Stone Cards{} and {C:hearts}Hearts{}",
        "give {C:chips}+#1#{} Chips and {C:mult}+#2#{} Mult",
        "when scored"
    },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_stone
        return { card.ability.extra.chips, card.ability.extra.mult }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local other = context.other_card
            if other.config.center.key == 'm_stone' or other:is_suit('Hearts') then
                return {
                    chips = card.ability.extra.chips,
                    mult = card.ability.extra.mult,
                    card = other,
                    message = "Firesworn!",
                    colour = G.C.ORANGE
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Tur Ragepaw",
    race = {"Furbolg"},
    weapon = {"Fist"},
    rarity = 2,
    cost = 6,
    index = 237,

    config = { extra = { mult = 15 } },

    loc_txt = {
        "Played {C:attention}Bonus Cards{} and",
        "{C:attention}Lucky Cards{} give {C:mult}+#1#{} Mult",
        "when scored"
    },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_bonus
        info_queue[#info_queue+1] = G.P_CENTERS.m_lucky
        return { card.ability.extra.mult }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local other = context.other_card
            if other.config.center.key == 'm_bonus' or other.config.center.key == 'm_lucky' then
                return {
                    mult = card.ability.extra.mult,
                    card = other,
                    message = "Brawler!",
                    colour = G.C.MULT
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Murloc Holmes",
    race = {"Murloc"},
    class = {"Rogue"}, 
    weapon = {"Daggers"},
    rarity = 2,
    cost = 6,
    index = 238,

    loc_txt = {
        "If played hand contains",
        "a {C:attention}Straight{}, create a",
        "random {C:attention}Quest{} card",
        "{C:inactive}(Must have room){}"
    },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = {key = 'quest', set = 'Other'}
        return {}
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            if context.poker_hands and context.poker_hands['Straight'] and next(context.poker_hands['Straight']) then
                if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                    G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                    
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            local _card = create_card('Quest', G.consumeables, nil, nil, nil, nil, nil, 'murloc_holmes')
                            _card:add_to_deck()
                            G.consumeables:emplace(_card)
                            G.GAME.consumeable_buffer = 0
                            return true
                        end
                    }))
                    
                    return {
                        message = "Elementary!",
                        colour = G.C.PURPLE,
                        card = card
                    }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Sneed",
    faction = {"Horde"},
    race = {"Goblin"},
    class = {"Warrior"},
    weapon = {"Axe"},
    rarity = 2,
    cost = 6,
    index = 239,

    loc_txt = {
        "When this Joker is",
        "{C:attention}sold{} or {C:red}destroyed{},",
        "it creates a random",
        "{C:attention}Joker{} to take its place"
    },

    calculate = function(self, card, context)
        if (context.selling_self or (context.joker_type_destroyed and context.card == card)) and not context.blueprint then
            
            G.E_MANAGER:add_event(Event({
                func = function()
                    local new_card = create_card('Joker', G.jokers, nil, nil, nil, nil, nil, 'sneed')
                    new_card:add_to_deck()
                    G.jokers:emplace(new_card)
                    new_card:start_materialize()
                    return true
                end
            }))

            return {
                message = "Eject!",
                colour = G.C.ORANGE
            }
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Kazakus",
    faction = {"Horde"},
    race = {"Troll", "Dragon"},
    class = {"Mage", "Warlock", "Priest"}, 
    weapon = {"Staff"},
    rarity = 2,
    cost = 6,
    index = 240,

    config = { extra = { x_mult_per = 0.5 } },

    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult for every",
        "{C:attention}different type{} of Consumable",
        "currently in your possession",
        "{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult){}"
    },

    loc_vars = function(self, info_queue, card)
        local unique_types = {}
        local count = 0
        if G.consumeables and G.consumeables.cards then
            for _, v in ipairs(G.consumeables.cards) do
                local set = v.ability.set
                if not unique_types[set] then
                    unique_types[set] = true
                    count = count + 1
                end
            end
        end
        local current_xmult = 1 + (count * card.ability.extra.x_mult_per)
        return { card.ability.extra.x_mult_per, current_xmult }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local unique_types = {}
            local count = 0
            if G.consumeables and G.consumeables.cards then
                for _, v in ipairs(G.consumeables.cards) do
                    local set = v.ability.set
                    if not unique_types[set] then
                        unique_types[set] = true
                        count = count + 1
                    end
                end
            end

            local total_xmult = 1 + (count * card.ability.extra.x_mult_per)
            
            if total_xmult > 1 then
                return {
                    message = "Custom Potion!",
                    Xmult_mod = total_xmult,
                    colour = G.C.MULT,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Morgl the Oracle",
    race = {"Murloc"},
    class = {"Shaman"},
    weapon = {"Staff"},
    rarity = 2,
    cost = 6,
    index = 241,

    config = { extra = { mult_per_tarot = 2 } },

    loc_txt = {
        "Played {C:attention}2s, 3s, and 4s{} give",
        "{C:mult}+#1#{} Mult for each",
        "{C:tarot}Tarot{} card used this run",
        "{C:inactive}(Currently {C:mult}+#2#{C:inactive} Mult){}"
    },

    loc_vars = function(self, info_queue, card)
        local tarot_count = (G.GAME and G.GAME.consumeable_usage_total and G.GAME.consumeable_usage_total.tarot) or 0
        return { vars = { card.ability.extra.mult_per_tarot, tarot_count * card.ability.extra.mult_per_tarot } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            local id = played_card:get_id()
            
            if id == 2 or id == 3 or id == 4 then
                local tarot_count = (G.GAME and G.GAME.consumeable_usage_total and G.GAME.consumeable_usage_total.tarot) or 0

                if tarot_count > 0 then
                    local bonus_mult = tarot_count * card.ability.extra.mult_per_tarot
                    return {
                        mult = bonus_mult,
                        card = played_card,
                        message = "Wisdom of the Deep!",
                        colour = G.C.MULT
                    }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Mr. Bigglesworth",
    faction = {"Scourge"},
    race = {"Beast", "Undead"},
    weapon = {"Fist"},
    rarity = 3,
    cost = 8,
    index = 242,

    config = { extra = { blinds_defeated = 0, threshold = 9 } },

    loc_txt = {
        "Every {C:attention}#1#{} Blinds beaten,",
        "a random {C:attention}Scourge{} Joker",
        "becomes {C:dark_edition}Negative{}.",
        "{C:inactive}(Blinds defeated: #2#/#1#){}"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.threshold, card.ability.extra.blinds_defeated }
    end,

    calculate = function(self, card, context)
        if context.end_of_round and not context.blueprint and not (context.individual or context.repetition) then
            card.ability.extra.blinds_defeated = card.ability.extra.blinds_defeated + 1
            
            if card.ability.extra.blinds_defeated >= card.ability.extra.threshold then
                card.ability.extra.blinds_defeated = 0
                local scourge_jokers = {}
                if G.jokers and G.jokers.cards then
                    for _, j in ipairs(G.jokers.cards) do
                        if j.ability.extra and j.ability.extra.faction == "Scourge" then
                            if not j.edition or not j.edition.negative then
                                table.insert(scourge_jokers, j)
                            end
                        end
                    end
                end
                if #scourge_jokers > 0 then
                    local target = pseudorandom_element(scourge_jokers, pseudoseed('bigglesworth'))
                    
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            target:set_edition({negative = true}, true)
                            target:juice_up()
                            return true
                        end
                    }))
                    
                    return {
                        message = "Corrupted!",
                        colour = G.C.DARK_EDITION,
                        card = card
                    }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Mutanus",
    faction = {"Legion"},
    race = {"Murloc", "Demon"},
    class = {"Warrior"},
    weapon = {"Fist"},
    rarity = 2,
    cost = 7,
    index = 243,

    config = { extra = { mult = 0 } },

    loc_txt = {
        "At the end of the {C:attention}Shop phase{},",
        "eat the Joker to the right.",
        "Gain its {C:money}Sell Value{} as {C:money}Money{}",
        "and as permanent {C:mult}+Mult{} on this Joker.",
        "{C:inactive}(Currently {C:mult}+#1#{C:inactive} Mult){}"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.mult }
    end,

    calculate = function(self, card, context)
        if context.ending_shop and not context.blueprint then
            local my_pos = nil
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then my_pos = i break end
            end
            if my_pos and G.jokers.cards[my_pos + 1] then
                local victim = G.jokers.cards[my_pos + 1]
                if not victim.ability.eternal and not victim.getting_sliced then
                    
                    local sell_value = victim.sell_cost
                    
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            ease_dollars(sell_value)
                            card.ability.extra.mult = card.ability.extra.mult + sell_value
                            victim.getting_sliced = true
                            victim:start_dissolve(nil, true)
                            
                            card:juice_up(0.5, 0.5)
                            return true
                        end
                    }))
                    
                    return {
                        message = "Devoured!",
                        colour = G.C.RED,
                        card = card
                    }
                end
            end
        end
        if context.joker_main and card.ability.extra.mult > 0 then
            return {
                mult = card.ability.extra.mult,
                card = card
            }
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Murky",
    faction = {"Horde"},
    race = {"Murloc"},
    class = {"Warrior"},
    weapon = {"Fist"},
    rarity = 1,
    cost = 3,
    index = 244,

    config = { extra = { chips_per_card = 20 } },

    loc_txt = {
        "{C:chips}+#1#{} Chips for every",
        "card remaining in your deck",
        "that {C:attention}matches{} a scored card's",
        "{C:attention}Rank and Suit{}.",
        "{C:inactive}(Currently {C:chips}+#2#{C:inactive} Chips){}"
    },

    loc_vars = function(self, info_queue, card)
        local total_bonus = 0
        if G.playing_cards and G.hand and G.hand.highlighted then
            for _, scored_card in ipairs(G.hand.highlighted) do
                for _, deck_card in ipairs(G.playing_cards) do
                    if deck_card.area == G.deck and deck_card.base.id == scored_card.base.id and deck_card.base.suit == scored_card.base.suit then
                        total_bonus = total_bonus + card.ability.extra.chips_per_card
                    end
                end
            end
        end
        
        return { card.ability.extra.chips_per_card, total_bonus }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local total_bonus = 0
            for _, scored_card in ipairs(context.scoring_hand) do
                for _, deck_card in ipairs(G.deck.cards) do
                    if deck_card.base.id == scored_card.base.id and deck_card:is_suit(scored_card.base.suit) then
                        total_bonus = total_bonus + card.ability.extra.chips_per_card
                    end
                end
            end

            if total_bonus > 0 then
                return {
                    chips = total_bonus,
                    message = "Murgl!",
                    colour = G.C.CHIPS,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Blackseed",
    race = {"Furbolg"},
    class = {"Druid"},
    weapon = {"Staff","Daggers"},
    rarity = 1,
    cost = 3,
    index = 245,

    config = { extra = { used_this_blind = false } },

    loc_txt = {
        "The {C:attention}first card{} drawn",
        "each Blind becomes a",
        "{C:attention}Wild Card{}"
    },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_wild
        return { }
    end,

    calculate = function(self, card, context)
        if context.setting_blind then
            card.ability.extra.used_this_blind = false
        end
        if context.hand_drawn and not card.ability.extra.used_this_blind and not context.blueprint then
            if #context.hand_drawn > 0 then
                -- Last index = first drawn (top of deck)
                local target_card = context.hand_drawn[#context.hand_drawn]
                
                G.E_MANAGER:add_event(Event({
                    func = function()
                        target_card:set_ability(G.P_CENTERS.m_wild, nil, true)
                        target_card:juice_up()
                        return true
                    end
                }))
                
                card.ability.extra.used_this_blind = true
                
                return {
                    message = "Nature's Corruption!",
                    colour = G.C.GREEN,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Bristlesnarl",
    race = {"Furbolg"},
    class = {"Hunter"},
    weapon = {"Spear","Polearm","Fist"},
    rarity = 1,
    cost = 4,
    index = 246,

    config = { extra = { mult = 0, mult_gain = 8, mult_loss = 1 } },

    loc_txt = {
        "{C:mult}+#1#{} Mult",
        "Each round you win {C:attention}without discarding{},",
        "permanently gain {C:mult}+#2#{}.",
        "If you do discard, lose {C:mult}-#3#{}.",
        "{C:inactive}(Currently {C:mult}+#1#{C:inactive} Mult){}"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.mult, card.ability.extra.mult_gain, card.ability.extra.mult_loss }
    end,

    calculate = function(self, card, context)
        if context.end_of_round and not (context.individual or context.repetition) and not context.blueprint then
            if G.GAME.current_round.discards_used == 0 then
                card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain
                return {
                    message = "Feral Growth!",
                    colour = G.C.MULT,
                    card = card
                }
            elseif G.GAME.current_round.discards_used > 0 then
                card.ability.extra.mult = math.max(0, card.ability.extra.mult - card.ability.extra.mult_loss)
                return {
                    message = "Wounded...",
                    colour = G.C.RED,
                    card = card
                }
            end
        end
        if context.joker_main then
            if card.ability.extra.mult > 0 then
                return {
                    mult = card.ability.extra.mult,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Elder Brandlemar",
    race = {"Furbolg"},
    class = {"Druid"},
    weapon = {"Staff","Fist"},
    rarity = 2,
    cost = 6,
    index = 247,

    config = { extra = { chips = 0, gain = 20 } },

    loc_txt = {
        "{C:chips}+#1#{} Chips",
        "Each {C:planet}Planet{} card used",
        "gives permanent {C:chips}+#2#{} Chips",
        "{C:inactive}(Currently {C:chips}+#1#{C:inactive} Chips){}"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.chips, card.ability.extra.gain }
    end,

    calculate = function(self, card, context)
        if context.using_consumeable and not context.blueprint then
            if context.consumeable.ability.set == 'Planet' then
                card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.gain
                
                return {
                    message = "Nature's Wisdom!",
                    colour = G.C.CHIPS,
                    card = card
                }
            end
        end
        if context.joker_main then
            if card.ability.extra.chips > 0 then
                return {
                    chips = card.ability.extra.chips,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Elder Jari",
    race = {"Furbolg"},
    class = {"Druid"},
    weapon = {"Daggers","Fist"},
    rarity = 2,
    cost = 5,
    index = 248,

    config = { extra = { level_up = 1 } },

    loc_txt = {
        "Using a {C:tarot}Tarot card{}",
        "levels up your {C:attention}Straight{} by {C:attention}#1#{}",
        "{C:inactive}(Currently {C:attention}#2#{C:inactive} levels){}"
    },

    loc_vars = function(self, info_queue, card)
        local lvl = 0
        if G.GAME and G.GAME.hands then
            lvl = G.GAME.hands["Straight"].level
        end
        return { card.ability.extra.level_up, lvl }
    end,

    calculate = function(self, card, context)
        if context.using_consumeable and not context.blueprint then
            
            if context.consumeable.ability.set == 'Tarot' then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        level_up_hand(card, "Straight", false, card.ability.extra.level_up)
                        
                        card_eval_status_text(card, 'extra', nil, nil, nil, {
                            message = "Level Up!", 
                            colour = G.C.PURPLE
                        })
                        card:juice_up()
                        return true
                    end
                }))
                
                return {
                    message = "Nature's Path!",
                    colour = G.C.PURPLE,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Frostfur",
    race = {"Furbolg"},
    class = {"Mage"},
    weapon = {"Staff", "Fist"},
    rarity = 2,
    cost = 6,
    index = 249,

    config = { extra = { chips = 50 } },

    loc_txt = {
        "If you end the round with {C:attention}unused discards{},",
        "a random card held in hand",
        "permanently gains {C:chips}+#1#{} Chips."
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.chips }
    end,

    calculate = function(self, card, context)
        if context.end_of_round and not (context.individual or context.repetition) and not context.blueprint then
            if G.GAME.current_round.discards_left > 0 then
                if G.hand and G.hand.cards and #G.hand.cards > 0 then
                    local target_card = pseudorandom_element(G.hand.cards, pseudorandom('frostfur'))
                    target_card.ability.perma_bonus = (target_card.ability.perma_bonus or 0) + card.ability.extra.chips
                    
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            target_card:juice_up()
                            card_eval_status_text(target_card, 'extra', nil, nil, nil, {
                                message = "Frost-Forged!", 
                                colour = G.C.CHIPS
                            })
                            return true
                        end
                    }))
                    
                    return {
                        message = "Frozen!",
                        colour = G.C.CHIPS,
                        card = card
                    }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Alexandros Mograine",
    faction = {"Alliance"},
    race = {"Human"},
    class = {"Paladin"},
    weapon = {"Sword"},
    rarity = 3,
    cost = 8,
    index = 250,

    config = { extra = { x_mult = 1, gain = 1 } },

    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "Gains {X:mult,C:white} X#2# {} Mult",
        "each time you beat a {C:attention}Boss Blind{}",
        "{C:inactive}(Currently {X:mult,C:white} X#1# {C:inactive} Mult){}"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult, card.ability.extra.gain }
    end,

    calculate = function(self, card, context)
        if context.end_of_round and context.beat_boss and not context.blueprint then
            card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.gain
            
            G.E_MANAGER:add_event(Event({
                func = function()
                    card:juice_up(0.5, 0.5)
                    card_eval_status_text(card, 'extra', nil, nil, nil, {
                        message = "Ashbringer Empowered!",
                        colour = G.C.GOLD
                    })
                    return true
                end
            }))
        end
        if context.joker_main and card.ability.extra.x_mult > 1 then
            return {
                Xmult_mod = card.ability.extra.x_mult,
                message = "The Ashbringer!",
                colour = G.C.GOLD,
                card = card
            }
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Dread Admiral Eliza",
    faction = {"Horde"},
    race = {"Human","Undead"},
    class = {"Rogue"}, 
    weapon = {"Sword"},
    rarity = 2,
    cost = 6,
    index = 251,

    config = { extra = { x_mult = 3, threshold = 15 } },

    loc_txt = {
        "If you have {C:money}$#1#{} or more",
        "during scoring, gain {X:mult,C:white} X#2# {} Mult"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.threshold, card.ability.extra.x_mult }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            if G.GAME.dollars >= card.ability.extra.threshold then
                return {
                    message = "Plunder!",
                    Xmult_mod = card.ability.extra.x_mult,
                    colour = G.C.MULT,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Fleet Admiral Tethys",
    faction = {"Horde"},
    race = {"Human"},
    class = {"Rogue"},
    weapon = {"Sword"},
    rarity = 2,
    cost = 7,
    index = 252,

    config = { extra = { hand_size_per_equip = 1 } },

    loc_txt = {
        "{C:attention}+#1#{} Hand Size for",
        "each {C:attention}Equipment{} attached",
        "to your Jokers",
        "{C:inactive}(Currently {C:attention}+#2#{C:inactive} Hand Size){}"
    },

    loc_vars = function(self, info_queue, card)
        local count = 0
        if G.jokers and G.jokers.cards then
            for _, j in ipairs(G.jokers.cards) do
                if j.ability.warcraft_equipment then
                    count = count + 1
                end
            end
        end
        return { card.ability.extra.hand_size_per_equip, count * card.ability.extra.hand_size_per_equip }
    end,
    calculate = function(self, card, context)
        if context.setting_blind or context.starting_shop then
            local count = 0
            for _, j in ipairs(G.jokers.cards) do
                if j.ability.warcraft_equipment then
                    count = count + 1
                end
            end
            
            local target_bonus = count * card.ability.extra.hand_size_per_equip
            local current_bonus = card.ability.extra.current_bonus or 0
            
            if target_bonus ~= current_bonus then
                G.hand:change_size(target_bonus - current_bonus)
                card.ability.extra.current_bonus = target_bonus
            end
        end
    end,

    add_to_deck = function(self, card, from_debuff)
        card.ability.extra.current_bonus = 0
    end,

    remove_from_deck = function(self, card, from_debuff)
        if card.ability.extra.current_bonus and card.ability.extra.current_bonus > 0 then
            G.hand:change_size(-card.ability.extra.current_bonus)
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Taoshi",
    faction = {"Horde"},
    race = {"Pandaren"},
    class = {"Rogue"},
    weapon = {"Daggers"},
    rarity = 2,
    cost = 6,
    index = 253,

    config = { extra = { x_mult = 3, hand_size = 2 } },

    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult if played",
        "hand contains exactly",
        "{C:attention}#2# cards{}"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult, card.ability.extra.hand_size }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            if context.full_hand and #context.full_hand == card.ability.extra.hand_size then
                
                return {
                    message = "Hidden Blade!",
                    Xmult_mod = card.ability.extra.x_mult,
                    colour = G.C.MULT,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Vindicator Maraad",
    faction = {"Alliance"},
    race = {"Draenei"},
    class = {"Paladin"},
    weapon = {"Hammer", "Shield"},
    rarity = 2,
    cost = 6,
    index = 254,

    config = { extra = { x_mult = 3 } },

    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult if",
        "your played hand contains",
        "{C:attention}no Face Cards{}"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            
            local has_face = false
            if context.full_hand then
                for _, v in ipairs(context.full_hand) do
                    if v:is_face() then
                        has_face = true
                        break
                    end
                end
            end
            if not has_face and #context.full_hand > 0 then
                return {
                    message = "Light's Judgment!",
                    Xmult_mod = card.ability.extra.x_mult,
                    colour = G.C.MULT,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Kargath Bladefist",
    faction = {"Horde"},
    race = {"Orc"},
    class = {"Warrior"},
    weapon = {"Sword"},
    rarity = 2,
    cost = 6,
    index = 255,

    config = { extra = { x_mult = 1, gain = 0.2 } },

    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "Playing an {C:attention}8{} destroys it",
        "and gives permanent {X:mult,C:white} +X#2# {} Mult",
        "{C:inactive}(Currently X#1#){}"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult, card.ability.extra.gain }
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local destroyed_any = false
            
            for _, played_card in ipairs(context.full_hand) do
                if played_card:get_id() == 8 and not played_card.shattered then
                    
                    played_card.shattered = true
                    played_card:start_dissolve()
                    
                    card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.gain
                    destroyed_any = true
                end
            end

            if destroyed_any then
                return {
                    message = "Shattered Hand!",
                    colour = G.C.RED,
                    card = card
                }
            end
        end
        if context.joker_main then
            if card.ability.extra.x_mult > 1 then
                return {
                    Xmult_mod = card.ability.extra.x_mult,
                    message = "Bladefist!",
                    colour = G.C.MULT,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Kleia",
    faction = {"Alliance"},
    race = {"Kyrian"},
    class = {"Priest"},
    weapon = {"Polearm"},
    rarity = 2,
    cost = 6,
    index = 256,

    config = { extra = { mult = 0, gain = 5 } },

    loc_txt = {
        "{C:mult}+#1#{} Mult",
        "Gains permanent {C:mult}+#2#{} Mult",
        "whenever the Joker to the right triggers",
        "{C:inactive}(Currently {C:mult}+#1#{C:inactive} Mult){}"
    },

    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.mult, card.ability.extra.gain }
    end,

    calculate = function(self, card, context)
        if context.post_trigger and not context.blueprint then
            local my_pos = nil
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then my_pos = i; break end
            end
            if my_pos and G.jokers.cards[my_pos + 1] == context.other_card and context.other_ret then
                card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.gain
                
                return {
                    message = "Ascended!",
                    colour = G.C.MULT,
                    card = card
                }
            end
        end
        if context.joker_main then
            if card.ability.extra.mult > 0 then
                return {
                    mult = card.ability.extra.mult,
                    card = card
                }
            end
        end
    end
})

sendDebugMessage("Azeroth Balatro Mod : Generating all Jokers done!")