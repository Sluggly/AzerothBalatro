sendDebugMessage("Azeroth Balatro Mod : Generating all Jokers...")
Warcraft.create_warcraft_joker({
    name = "Archimonde",
    faction = {"Legion"},
    race = {"Demon", "Draenei"},
    class = {"Warlock"},
    weapon = {"Fist", "Hammer"},
    damage = {"Shadow"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Gul'dan", "Kil'Jaeden","Prophet Velen","Sargeras"},
    role = {"Ranged DPS"},
    rarity = 3,
    cost = 8,
    index = 1,
    config = { extra = {
        x_mult = 1,
        x_mult_gain = 0.15,
        x_mult_gain_per_level = 0.03,
        x_mult_gain_per_ilvl = 0.01
    }},
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "Gains {X:mult,C:white} X#2# {} Mult when a",
        "{C:red}Demon{} or {C:red}Legion{} Joker",
        "is {C:attention}added{}, {C:attention}sold{} or {C:attention}destroyed{}"
    },
    loc_vars = function(self, info_queue, card)
        local effective_gain = Warcraft.get_scaled_gain(card,card.ability.extra.x_mult_gain,card.ability.extra.x_mult_gain_per_level,card.ability.extra.x_mult_gain_per_ilvl)
        return { card.ability.extra.x_mult, effective_gain }
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
            local effective_gain = Warcraft.get_scaled_gain(card,card.ability.extra.x_mult_gain,card.ability.extra.x_mult_gain_per_level,card.ability.extra.x_mult_gain_per_ilvl)
            card.ability.extra.x_mult = card.ability.extra.x_mult + (count * effective_gain)
            card_eval_status_text(card, 'extra', nil, nil, nil, {
                message = "Burning Legion!",
                colour = G.C.RED
            })
        end
    end,
    calculate = function(self, card, context)
        if context.card_added and not context.blueprint then
            local added = context.card
            if added and added ~= card and Warcraft.is_demon_or_legion(added) then
                local effective_gain = Warcraft.get_scaled_gain(card,card.ability.extra.x_mult_gain,card.ability.extra.x_mult_gain_per_level,card.ability.extra.x_mult_gain_per_ilvl)
                card.ability.extra.x_mult = card.ability.extra.x_mult + effective_gain
                return { message = "Burning Legion!", colour = G.C.RED, card = card }
            end
        end

        if context.selling_card and not context.blueprint then
            local sold = context.card
            if sold and sold ~= card and Warcraft.is_demon_or_legion(sold) then
                local effective_gain = Warcraft.get_scaled_gain(card,card.ability.extra.x_mult_gain,card.ability.extra.x_mult_gain_per_level,card.ability.extra.x_mult_gain_per_ilvl)
                card.ability.extra.x_mult = card.ability.extra.x_mult + effective_gain
                return { message = "Burning Legion!", colour = G.C.RED, card = card }
            end
        end

        if context.joker_type_destroyed and not context.blueprint then
            local destroyed = context.card
            if destroyed and destroyed ~= card and Warcraft.is_demon_or_legion(destroyed) then
                local effective_gain = Warcraft.get_scaled_gain(card,card.ability.extra.x_mult_gain,card.ability.extra.x_mult_gain_per_level,card.ability.extra.x_mult_gain_per_ilvl)
                card.ability.extra.x_mult = card.ability.extra.x_mult + effective_gain
                return { message = "Sacrificed!", colour = G.C.RED, card = card }
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
    damage = {"Fire"},
    armor = {"Mail"},
    profession = {},
    combo = {"Majordomo Executus", "Garr", "Baron Geddon"},
    role = {"Ranged DPS"},
    rarity = 3,
    cost = 8,
    index = 2,
    config = { extra = { destroy = 1, mult = 8, mult_per_level = 1, mult_per_ilvl = 0.25 } },
    loc_txt = {
        "When hand is played,",
        "destroy {C:attention}#1# random card{} in hand.",
        "If a card is destroyed, gain",
        "{C:mult}+#2#{} Mult for this hand"
    },
    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.destroy, Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            if G.hand and G.hand.cards and #G.hand.cards > 0 then
                local target_card = pseudorandom_element(G.hand.cards, pseudoseed('ragnaros_' .. G.GAME.round))
                if target_card and not target_card.dissolving then
                    local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl)
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            target_card:start_dissolve({remove_as_card = true})
                            return true
                        end
                    }))
                    return {
                        message = "BY FIRE BE PURGED!",
                        mult = effective_mult,
                        colour = G.C.RED,
                        card = card
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
    damage = {"Shadow"},
    armor = {"Leather"},
    profession = {},
    combo = {"Kael'thas Sunstrider", "Lady Vashj", 'Tyrande Whisperwind', "Malfurion Stormrage", "Maiev Shadowsong"},
    role = {"Melee DPS"},
    rarity = 1,
    cost = 5,
    index = 3,
    config = { extra = { x_mult = 1.5, x_mult_gain = 0.1, x_mult_gain_per_level = 0.02, x_mult_gain_per_ilvl = 0.01 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "Gains {X:mult,C:white} X#2# {} Mult,",
        "a {C:attention}Level{} and {C:attention}Ilvl{}",
        "each time a {C:spectral}Spectral{} card is used"
    },
    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult, Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_gain, card.ability.extra.x_mult_gain_per_level, card.ability.extra.x_mult_gain_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.using_consumeable and not context.blueprint then
            if context.consumeable.ability.set == "Spectral" then
                local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_gain, card.ability.extra.x_mult_gain_per_level, card.ability.extra.x_mult_gain_per_ilvl)
                card.ability.extra.x_mult = card.ability.extra.x_mult + effective_gain

                -- Level up (bypass cap)
                if card.ability.extra.level then
                    card.ability.extra.level = card.ability.extra.level + 1
                    if card.ability.extra.max_level and card.ability.extra.level > card.ability.extra.max_level then
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
    damage = {"Nature"},
    armor = {"Mail"},
    profession = {},
    combo = {"Cairne Bloodhoof", "Baine Bloodhoof", "Garrosh Hellscream", "Grommash Hellscream", "Vol'jin", "Varok Saurfang", "Eitrigg"},
    role = {"Ranged DPS"},
    rarity = 3,
    cost = 8,
    index = 4,
    config = { extra = { suits = 4, suits_per_level = -0.2, suits_per_ilvl = -0.1 } },
    loc_txt = {
        "If played hand contains",
        "{C:attention}#1# different suits{}:",
        "Give played cards a random",
        "{C:attention}Enhancement{} and {C:dark_edition}Edition{}",
        "{C:inactive}(If they don't have one){}"
    },
    loc_vars = function(self, info_queue, card)
        return { math.max(1, math.ceil(Warcraft.get_scaled_gain(card, card.ability.extra.suits, card.ability.extra.suits_per_level, card.ability.extra.suits_per_ilvl))) }
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local required_suits = math.max(1, math.ceil(Warcraft.get_scaled_gain(card, card.ability.extra.suits, card.ability.extra.suits_per_level, card.ability.extra.suits_per_ilvl)))

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

            if unique_count >= required_suits then
                local triggered = false
                for _, played_card in ipairs(context.full_hand) do
                    if played_card.config.center.set == 'Default' then
                        local enhancement = pseudorandom_element(G.P_CENTER_POOLS.Enhanced, pseudoseed('thrall_enhance_' .. G.GAME.round))
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
    damage = {"Shadow"},
    armor = {"Plate"},
    profession = {},
    combo = {"Jaine Proudmoore", "Sylvanas Windrunner", "Uther the Lightbringer", "Terenas Menethil II", "Kel'Thuzad", "Anub'Arak"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 6,
    index = 5,
    config = { extra = { mult = 0, mult_gain = 3, mult_gain_per_level = 0.5, mult_gain_per_ilvl = 0.25 } },
    loc_txt = {
        "If played hand contains {C:attention}no Face Cards{}:",
        "Destroy all scored cards and",
        "gain {C:mult}+#1#{} Mult",
        "{C:inactive}(Currently {C:mult}+#2#{C:inactive} Mult){}"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.mult_gain, card.ability.extra.mult_gain_per_level, card.ability.extra.mult_gain_per_ilvl), card.ability.extra.mult }
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
                    local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.mult_gain, card.ability.extra.mult_gain_per_level, card.ability.extra.mult_gain_per_ilvl)
                    card.ability.extra.mult = card.ability.extra.mult + effective_gain

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
    damage = {"Nature"},
    armor = {"Leather"},
    profession = {},
    combo = {"Tyrande Whisperwind", "Illidan Stormrage", "Ysera"},
    role = {"Ranged DPS"},
    rarity = 3,
    cost = 8,
    index = 6,
    config = { extra = { h_size = 1, hand = 1, discard = 1, money = 2, money_per_level = 0.1, money_per_ilvl = 0.1 } },
    loc_txt = {
        "{C:attention}+#1#{} Hand Size, {C:blue}+#2#{} Hand,",
        "{C:red}+#3#{} Discard",
        "If played hand is a {C:attention}Flush{},",
        "increase sell value of",
        "{C:attention}leftmost Joker{} by {C:money}$#4#{}"
    },
    loc_vars = function(self, info_queue, card)
        local level = card.ability.extra.level or 1
        local h_size = 1 + math.floor((level - 1) / 10)
        return { h_size, card.ability.extra.hand, card.ability.extra.discard, Warcraft.get_scaled_gain(card, card.ability.extra.money, card.ability.extra.money_per_level, card.ability.extra.money_per_ilvl) }
    end,
    add_to_deck = function(self, card, from_debuff)
        local level = card.ability.extra.level or 1
        local h_size = 1 + math.floor((level - 1) / 10)
        card.ability.extra.h_size = h_size
        G.hand.config.card_limit = G.hand.config.card_limit + h_size
        G.GAME.round_resets.hands = G.GAME.round_resets.hands + card.ability.extra.hand
        G.GAME.round_resets.discards = G.GAME.round_resets.discards + card.ability.extra.discard
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.hand.config.card_limit = G.hand.config.card_limit - card.ability.extra.h_size
        G.GAME.round_resets.hands = G.GAME.round_resets.hands - card.ability.extra.hand
        G.GAME.round_resets.discards = G.GAME.round_resets.discards - card.ability.extra.discard
    end,
    calculate = function(self, card, context)
        -- Update hand size when level changes
        if context.end_of_round and not context.repetition and not context.individual and not context.blueprint then
            local level = card.ability.extra.level or 1
            local new_h_size = 1 + math.floor((level - 1) / 10)
            if new_h_size ~= card.ability.extra.h_size then
                local diff = new_h_size - card.ability.extra.h_size
                card.ability.extra.h_size = new_h_size
                G.hand.config.card_limit = G.hand.config.card_limit + diff
            end
        end

        if context.joker_main then
            if context.scoring_name == "Flush" then
                if G.jokers.cards[1] then
                    local target = G.jokers.cards[1]
                    local effective_money = Warcraft.get_scaled_gain(card, card.ability.extra.money, card.ability.extra.money_per_level, card.ability.extra.money_per_ilvl)
                    target.sell_cost = (target.sell_cost or 0) + effective_money
                    card_eval_status_text(target, 'extra', nil, nil, nil, { message = "+$ Value", colour = G.C.MONEY })
                    return { message = "Wild Growth!", colour = G.C.GREEN }
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
    damage = {"Holy"},
    armor = {"Plate"},
    profession = {},
    combo = {"Varian Wrynn", "Genn Greymane", "Mathias Shaw"},
    role = {"Healer"},
    rarity = 3,
    cost = 8,
    index = 7,
    config = { extra = { discard = 2, discard_reduction_per_level = 0.1, discard_reduction_per_ilvl = 0.025, current_penalty = 2 } },
    loc_txt = {
        "{C:attention}Boss Blinds{} have no effect",
        "{C:red}-#1#{} Discards{}"
    },
    loc_vars = function(self, info_queue, card)
        local reduction = Warcraft.get_scaled_gain(card, 0, card.ability.extra.discard_reduction_per_level, card.ability.extra.discard_reduction_per_ilvl)
        local effective = card.ability.extra.discard - reduction
        return { effective }
    end,
    add_to_deck = function(self, card, from_debuff)
        local reduction = Warcraft.get_scaled_gain(card, 0, card.ability.extra.discard_reduction_per_level, card.ability.extra.discard_reduction_per_ilvl)
        local effective = card.ability.extra.discard - reduction
        card.ability.extra.current_penalty = effective
        G.GAME.round_resets.discards = G.GAME.round_resets.discards - effective
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.GAME.round_resets.discards = G.GAME.round_resets.discards + card.ability.extra.current_penalty
    end,
    calculate = function(self, card, context)
        -- Update penalty when level or ilvl changes
        if context.end_of_round and not context.repetition and not context.individual and not context.blueprint then
            local reduction = Warcraft.get_scaled_gain(card, 0, card.ability.extra.discard_reduction_per_level, card.ability.extra.discard_reduction_per_ilvl)
            local new_penalty = card.ability.extra.discard - reduction
            if new_penalty ~= card.ability.extra.current_penalty then
                local diff = card.ability.extra.current_penalty - new_penalty
                G.GAME.round_resets.discards = G.GAME.round_resets.discards + diff
                card.ability.extra.current_penalty = new_penalty
            end
        end

        if context.setting_blind and not context.blueprint then
            if G.GAME.blind and G.GAME.blind.boss and not G.GAME.blind.disabled then
                G.GAME.blind:disable()
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = "Silenced!", colour = G.C.BLUE })
            end
        end

        if context.first_hand_drawn and not context.blueprint then
            if G.GAME.blind and G.GAME.blind.boss and not G.GAME.blind.disabled then
                G.GAME.blind:disable()
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = "Silenced!", colour = G.C.BLUE })
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
    damage = {"Shadow"},
    armor = {"Plate"},
    profession = {},
    combo = {"Archimonde", "Mannoroth", "Sargeras"},
    role = {"Tank"},
    rarity = 3,
    cost = 8,
    index = 8,
    config = { extra = { x_mult = 4, money = -3, x_mult_per_level = 0.25, x_mult_per_ilvl = 0.1 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "{C:red}$#2#{} when hand is played"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl), card.ability.extra.money }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local effective_x_mult = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl)
            ease_dollars(card.ability.extra.money)
            card_eval_status_text(card, 'extra', nil, nil, nil, {
                message = "-$",
                colour = G.C.RED
            })
            return {
                message = "My Blood Is Yours!",
                Xmult_mod = effective_x_mult,
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
    damage = {"Frost"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Arthas Menethil", "Lich King", "Ner'zhul"},
    role = {"Ranged DPS"},
    rarity = 1,
    cost = 4,
    index = 9,
    config = { extra = { stone_count = 5, stone_count_per_level = 0.2, stone_count_per_ilvl = 0.1 } },
    loc_txt = {
        "When a blind starts, add",
        "{C:attention}#1#{} temporary {C:attention}Stone Cards{}",
        "to your hand"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_stone
        return { math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.stone_count, card.ability.extra.stone_count_per_level, card.ability.extra.stone_count_per_ilvl)) }
    end,
    calculate = function(self, card, context)
        if context.first_hand_drawn and not context.blueprint then
            local effective_count = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.stone_count, card.ability.extra.stone_count_per_level, card.ability.extra.stone_count_per_ilvl))
            
            G.E_MANAGER:add_event(Event({
                func = function()
                    for i = 1, effective_count do
                        local new_card = create_card('Base', G.hand, nil, nil, nil, nil, nil, 'kelthuzad')
                        new_card:set_ability(G.P_CENTERS.m_stone)
                        new_card.is_temporary = true
                        new_card:add_to_deck()
                        table.insert(G.playing_cards, new_card)
                        G.hand:emplace(new_card)
                        
                        new_card.facing = 'front'
                        new_card.sprite_facing = 'front'
                        new_card.front_hidden = false
                        
                        new_card:juice_up()
                    end
                    return true
                end
            }))
            
            return {
                message = "Rise, Minions!",
                colour = G.C.PURPLE,
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
    damage = {"Physical"},
    armor = {"Mail"},
    profession = {},
    combo = {"Arthas Menethil", "Lich King", "Saphiron"},
    role = {"Tank"},
    rarity = 3,
    cost = 8,
    index = 10,
    config = { extra = { bonus_chips = 2, bonus_chips_per_level = 0.5, bonus_chips_per_ilvl = 0.25 } },
    loc_txt = {
        "Played {C:attention}Spades{} return to",
        "your deck after scoring",
        "and gain {C:chips}+#1#{} permanent Chips"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.bonus_chips, card.ability.extra.bonus_chips_per_level, card.ability.extra.bonus_chips_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.destroying_card and not context.blueprint then
            local card_to_save = context.destroying_card
            if card_to_save:is_suit("Spades") and not card_to_save.dissolving then
                local bonus = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.bonus_chips, card.ability.extra.bonus_chips_per_level, card.ability.extra.bonus_chips_per_ilvl))
                G.E_MANAGER:add_event(Event({
                    func = function()
                        -- Add permanent chips to the saved card
                        card_to_save.ability.perma_bonus = (card_to_save.ability.perma_bonus or 0) + bonus
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
    damage = {"Shadow"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Archimonde", "Prophet Velen", "Kil'Jaeden"},
    role = {"Ranged DPS"},
    rarity = 1,
    cost = 8,
    index = 11,
    config = { extra = { x_mult = 3, x_mult_per_level = 0.25, x_mult_per_ilvl = 0.1 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "{C:red}Destroys the highest rank{}",
        "{C:red}card{} in played hand"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local target_card = nil
            local max_rank = -1
            if context.full_hand then
                for _, played_card in ipairs(context.full_hand) do
                    if played_card:get_id() > max_rank and not played_card.dissolving then
                        max_rank = played_card:get_id()
                        target_card = played_card
                    end
                end
            end

            if target_card then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        target_card:start_dissolve({remove_as_card = true})
                        return true
                    end
                }))
                card_eval_status_text(target_card, 'extra', nil, nil, nil, {
                    message = "Consumed!",
                    colour = G.C.RED
                })
            end

            return {
                message = "The Deceiver!",
                Xmult_mod = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
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
    damage = {"Shadow"},
    armor = {"Mail"},
    profession = {},
    combo = {"Alleria Windrunner", "Vereesa Windrunner", "Zovaal", "Arthas Menethil"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 5,
    index = 12,
    config = { extra = { stone_count = 1, stone_count_per_level = 0.25, stone_count_per_ilvl = 0.25 } },
    loc_txt = {
        "If played hand contains a {C:attention}Face Card{}:",
        "{C:red}Destroy it{}, then create {C:attention}#1#{}",
        "{C:attention}Stone Card(s){}"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_stone
        return { Warcraft.get_scaled_gain(card, card.ability.extra.stone_count, card.ability.extra.stone_count_per_level, card.ability.extra.stone_count_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local target_card = nil
            if context.scoring_hand then
                for _, played_card in ipairs(context.scoring_hand) do
                    if played_card:is_face() and not played_card.dissolving then
                        target_card = played_card
                        break
                    end
                end
            end

            if target_card then
                -- Get the scaled number of Stone Cards to spawn
                local stones_to_create = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.stone_count, card.ability.extra.stone_count_per_level, card.ability.extra.stone_count_per_ilvl))

                G.E_MANAGER:add_event(Event({
                    func = function()
                        target_card:start_dissolve({remove_as_card = true})
                        return true
                    end
                }))

                if stones_to_create > 0 then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            -- Loop to create the exact amount of Stone Cards
                            for i = 1, stones_to_create do
                                local new_card = create_card('Base', G.hand, nil, nil, nil, nil, nil, 'sylvanas_spawn')
                                new_card:set_ability(G.P_CENTERS.m_stone)
                                new_card:add_to_deck()
                                table.insert(G.playing_cards, new_card)
                                G.hand:emplace(new_card)
                                new_card:juice_up()
                            end
                            return true
                        end
                    }))
                end

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
    damage = {"Arcane"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Alleria Windrunner", "Illidan Stormrage", "Turalyon"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 4,
    index = 13,
    config = { extra = { copies = 1, copies_per_level = 0.5, copies_per_ilvl = 0.25 } },
    loc_txt = {
        "Each time a playing card is",
        "added to your deck,",
        "add {C:attention}#1#{} extra copies of it"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.copies, card.ability.extra.copies_per_level, card.ability.extra.copies_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.playing_card_added and not context.blueprint then
            local added = context.card
            
            -- Ignore temporary cards AND clones made by Khadgar to prevent infinite loops!
            if added and not added.is_temporary and not added.khadgar_clone then
                local copies_to_make = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.copies, card.ability.extra.copies_per_level, card.ability.extra.copies_per_ilvl))
                
                if copies_to_make > 0 then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            for i = 1, copies_to_make do
                                local copy = copy_card(added)
                                copy.khadgar_clone = true -- Tag it so Khadgar ignores it
                                copy:add_to_deck()
                                table.insert(G.playing_cards, copy)
                                G.deck:emplace(copy)
                                copy:juice_up()
                            end
                            return true
                        end
                    }))
                    return {
                        message = "Multicast!",
                        colour = G.C.PURPLE,
                        card = card
                    }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Jaina Proudmoore",
    faction = {"Alliance","Pirate"},
    race = {"Human"},
    class = {"Mage"},
    weapon = {"Staff"},
    damage = {"Frost"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Arthas Menethil", "Daelin Proudmoore", "Thrall", "Varian Wrynn"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 8,
    index = 14,
    config = { extra = { chips = 20, base_chance = 1, max_chance = 4, chips_per_level = 5, chips_per_ilvl = 3 } },
    loc_txt = {
        "Played {C:attention}Glass Cards{} do not shatter.",
        "Played {C:clubs}Clubs{} give {C:chips}+#1#{} Chips",
        "and have a {C:green}#2# in #3#{} chance to",
        "become {C:attention}Glass Cards{}"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.chips, card.ability.extra.chips_per_level, card.ability.extra.chips_per_ilvl), card.ability.extra.base_chance, card.ability.extra.max_chance }
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
                local effective_chips = Warcraft.get_scaled_gain(card, card.ability.extra.chips, card.ability.extra.chips_per_level, card.ability.extra.chips_per_ilvl)
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
                    chips = effective_chips,
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
    damage = {"Arcane"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Millificent Manastorm", "Magnus Manastorm", "Bwonsamdi"},
    role = {"Ranged DPS"},
    rarity = 3,
    cost = 8,
    index = 15,
    config = { extra = { max_cost = 1, mult = 0, mult_gain = 2, mult_gain_per_level = 0.5, mult_gain_per_ilvl = 0.5 } },
    loc_txt = {
        "Everything in the Shop costs {C:money}$#1#{}.",
        "You cannot gain {C:attention}Interest{}.",
        "You cannot {C:attention}Reroll{} the Shop.",
        "Gains {C:mult}+#2#{} Mult when anything",
        "is bought in the {C:attention}Shop{}",
        "{C:inactive}(Currently {C:mult}+#3#{C:inactive} Mult){}"
    },
    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.max_cost, Warcraft.get_scaled_gain(card, card.ability.extra.mult_gain, card.ability.extra.mult_gain_per_level, card.ability.extra.mult_gain_per_ilvl), card.ability.extra.mult }
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
        G.GAME.discount_percent = card.ability.extra_old_discount or 0
        G.GAME.interest_cap = card.ability.extra_old_cap or 5
        G.GAME.current_round.reroll_cost = G.GAME.round_resets.reroll_cost or 5
    end,
    calculate = function(self, card, context)
        if context.setting_blind or context.reroll_shop or context.end_of_round then
            if G.shop_booster then
                for k, v in pairs(G.shop_booster.cards) do v.cost = 0; v:set_cost() end
            end
            if G.shop_jokers then
                for k, v in pairs(G.shop_jokers.cards) do v.cost = 0; v:set_cost() end
            end
            G.GAME.current_round.reroll_cost = 10000000
        end

        -- Gain mult when anything is bought in the shop
        if context.buying_card and not context.blueprint then
            local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.mult_gain, card.ability.extra.mult_gain_per_level, card.ability.extra.mult_gain_per_ilvl)
            card.ability.extra.mult = card.ability.extra.mult + effective_gain
            return {
                message = "Bargain!",
                colour = G.C.MONEY,
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
    name = "Grom Hellscream",
    faction = {"Horde"},
    race = {"Orc"},
    class = {"Warrior"},
    weapon = {"Axe"},
    damage = {"Physical"},
    armor = {"Unarmored"},
    profession = {},
    combo = {"Garrosh Hellscream", "Thrall", "Mannoroth", "Jaina Proudmoore"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 7,
    index = 16,
    config = { extra = { mult = 4, mult_per_level = 1, mult_per_ilvl = 0.5 } },
    loc_txt = {
        "{C:mult}+#1#{} Mult for every",
        "{C:attention}Discard{} remaining"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local discards = G.GAME.current_round.discards_left
            local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl)
            local mult_gain = discards * effective_mult
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
    damage = {"Physical"},
    armor = {"Leather"},
    profession = {},
    combo = {"Thrall", "Jaina Proudmoore", "Daelin Proudmoore", "Misha", "Huffer", "Leok", "Rokhan"},
    role = {"Melee DPS"},
    rarity = 1,
    cost = 8,
    index = 17,
    config = { extra = { mult = 10, mult_per_level = 1, mult_per_ilvl = 0.25 } },
    loc_txt = {
        "{C:mult}+#1#{} Mult for each",
        "{C:attention}Wild Card{} in your",
        "full deck"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl) }
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
            local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl)
            local bonus_mult = wild_count * effective_mult
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
    damage = {"Arcane"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Malfurion Stormrage", "Illidan Stormrage", "Maiev Shadowsong", "Ysera"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 8,
    index = 18,
    config = { extra = { x_mult = 1, x_mult_gain = 0.1, x_mult_gain_per_level = 0.05, x_mult_gain_per_ilvl = 0.01 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "Gains {X:mult,C:white} X#2# {} Mult when",
        "you use a {C:planet}Planet{} card",
        "or {C:tarot}The Moon{} card"
    },
    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult, Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_gain, card.ability.extra.x_mult_gain_per_level, card.ability.extra.x_mult_gain_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.using_consumeable and not context.blueprint then
            local c_card = context.consumeable
            local triggered = false
            if c_card.ability.set == 'Planet' then triggered = true end
            if c_card.config.center.key == 'c_moon' then triggered = true end
            if triggered then
                local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_gain, card.ability.extra.x_mult_gain_per_level, card.ability.extra.x_mult_gain_per_ilvl)
                card.ability.extra.x_mult = card.ability.extra.x_mult + effective_gain
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
    damage = {"Fire"},
    armor = {"Leather"},
    profession = {},
    combo = {"Lili Stormstout", "Coren Direbrew", "Magni Bronzebeard", "Rexxar", "Rokhan"},
    role = {"Tank"},
    rarity = 1,
    cost = 3,
    index = 19,
    config = { extra = { number = 3, retrigger = 2, retrigger_per_level = 0.1, retrigger_per_ilvl = 0.05 } },
    loc_txt = {
        "If played hand contains",
        "exactly {C:attention}#1# cards{},",
        "retrigger each played",
        "card {C:attention}#2# times{}"
    },
    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.number, Warcraft.get_scaled_gain(card, card.ability.extra.retrigger, card.ability.extra.retrigger_per_level, card.ability.extra.retrigger_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            if context.full_hand and #context.full_hand == card.ability.extra.number then
                local effective_retrigger = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.retrigger, card.ability.extra.retrigger_per_level, card.ability.extra.retrigger_per_ilvl))
                return {
                    message = "Storm, Earth, Fire!",
                    repetitions = effective_retrigger,
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
    damage = {"Holy"},
    armor = {"Plate"},
    profession = {},
    combo = {"Arthas Menethil", "Jaina Proudmoore", "Terenas Menethil II"},
    role = {"Healer"},
    rarity = 1,
    cost = 3,
    index = 20,
    config = { extra = { mult = 0, chips = 0, mult_gain = 5, mult_gain_per_level = 1, chip_gain = 15, chip_gain_per_ilvl = 3 } },
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
            Warcraft.get_scaled_gain(card, card.ability.extra.mult_gain, card.ability.extra.mult_gain_per_level, 0),
            Warcraft.get_scaled_gain(card, card.ability.extra.chip_gain, 0, card.ability.extra.chip_gain_per_ilvl),
            card.ability.extra.mult,
            card.ability.extra.chips
        }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            local scored_card = context.other_card

            if scored_card.config.center.key == 'm_stone' and not scored_card.dissolving then
                local effective_mult_gain = Warcraft.get_scaled_gain(card, card.ability.extra.mult_gain, card.ability.extra.mult_gain_per_level, 0)
                card.ability.extra.mult = card.ability.extra.mult + effective_mult_gain
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

            if scored_card.config.center.key == 'm_gold' then
                local effective_chip_gain = Warcraft.get_scaled_gain(card, card.ability.extra.chip_gain, 0, card.ability.extra.chip_gain_per_ilvl)
                card.ability.extra.chips = card.ability.extra.chips + effective_chip_gain
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
    damage = {"Holy"},
    armor = {"Plate"},
    profession = {},
    combo = {"Lich King", "Arthas Menethil", "Bolvar Fordragon"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 7,
    index = 21,
    config = { extra = { x_mult = 1.5, x_mult_gain = 0.2, x_mult_gain_per_level = 0.1, x_mult_gain_per_ilvl = 0.1 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "Gains {X:mult,C:white} X#2# {} Mult",
        "when you defeat a {C:attention}Blind{}"
    },
    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult, Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_gain, card.ability.extra.x_mult_gain_per_level, card.ability.extra.x_mult_gain_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_gain, card.ability.extra.x_mult_gain_per_level, card.ability.extra.x_mult_gain_per_ilvl)
            card.ability.extra.x_mult = card.ability.extra.x_mult + effective_gain
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
    damage = {"Nature"},
    armor = {"Leather"},
    profession = {},
    combo = {"Varian Wrynn", "Rehgar Earthfury", "Broll Bearmantle", "Aegwynn"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 5,
    index = 22,
    config = { extra = { number = 1, money = 5, money_per_level = 1, money_per_ilvl = 0.5 } },
    loc_txt = {
        "If {C:attention}last discard{} of round",
        "is exactly {C:attention}#1# card{},",
        "destroy it and gain {C:money}$#2#{}"
    },
    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.number, Warcraft.get_scaled_gain(card, card.ability.extra.money, card.ability.extra.money_per_level, card.ability.extra.money_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.discard and not context.blueprint then
            if context.full_hand and #context.full_hand == card.ability.extra.number then
                if G.GAME.current_round.discards_left == 1 then
                    local effective_money = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.money, card.ability.extra.money_per_level, card.ability.extra.money_per_ilvl))
                    ease_dollars(effective_money)
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
    race = {"Orc", "Draenei"},
    class = {"Rogue"},
    weapon = {"Daggers"},
    damage = {"Nature"},
    armor = {"Leather"},
    profession = {},
    combo = {"Khadgar", "Medivh", "King Llane Wrynn"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 9,
    index = 23,
    config = { extra = { x_mult = 4, x_mult_per_level = 0.5, x_mult_per_ilvl = 0.2 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult if played",
        "hand contains a {C:attention}King{}.",
        "Scored Kings are {C:red}destroyed{}"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl) }
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
                    Xmult_mod = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
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
    damage = {"Shadow"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Archimonde", "Kil'Jaeden", "Sargeras", "Illidan Stormrage"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 6,
    index = 24,
    config = { extra = { mult = 0, mult_gain = 3, mult_gain_per_level = 1, mult_gain_per_ilvl = 0.5 } },
    loc_txt = {
        "{C:mult}+#1#{} Mult",
        "When hand is played, destroy",
        "a {C:attention}random card{} in your",
        "{C:attention}deck{} and gain {C:mult}+#2#{} Mult"
    },
    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.mult, Warcraft.get_scaled_gain(card, card.ability.extra.mult_gain, card.ability.extra.mult_gain_per_level, card.ability.extra.mult_gain_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            if G.deck.cards and #G.deck.cards > 0 then
                local target_card = pseudorandom_element(G.deck.cards, pseudoseed('guldan_' .. G.GAME.round))
                if target_card then
                    local effective_gain = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.mult_gain, card.ability.extra.mult_gain_per_level, card.ability.extra.mult_gain_per_ilvl))
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            target_card:start_dissolve({remove_as_card = true})
                            return true
                        end
                    }))
                    card.ability.extra.mult = card.ability.extra.mult + effective_gain
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
    damage = {"Holy"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Archimonde", "Kil'Jaeden", "Turalyon", 'Illidan Stormrage'},
    role = {"Healer"},
    rarity = 2,
    cost = 7,
    index = 25,
    config = { extra = { perma_chips = 1, perma_chips_per_level = 1, perma_chips_per_ilvl = 0.5 } },
    loc_txt = {
        "All cards are considered",
        "{C:attention}Face Cards{}",
        "Face cards gain {C:chips}+#1#{} permanent",
        "Chips when scored"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.perma_chips, card.ability.extra.perma_chips_per_level, card.ability.extra.perma_chips_per_ilvl) }
    end,
    add_to_deck = function(self, card, from_debuff)
        G.GAME.velen_active = true
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.GAME.velen_active = false
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            if context.other_card:is_face() then
                local bonus = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.perma_chips, card.ability.extra.perma_chips_per_level, card.ability.extra.perma_chips_per_ilvl))
                context.other_card.ability.perma_bonus = (context.other_card.ability.perma_bonus or 0) + bonus
                return {
                    message = "Light's Grace!",
                    colour = G.C.BLUE,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Varian Wrynn",
    faction = {"Alliance"},
    race = {"Human"},
    class = {"Warrior"},
    weapon = {"Sword"},
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {},
    combo = {"Anduin Wrynn", "Jaina Proudmoore", "Thrall", "Gul'Dan"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 10,
    index = 26,
    -- CHANGED: Swapped chips scaling for copies scaling. 
    -- (0.5 per level = 1 extra copy every 2 levels!)
    config = { extra = { chance = 2, copies = 1, copies_per_level = 0.5, copies_per_ilvl = 0.25 } },
    loc_txt = {
        "When you play a",
        "{C:clubs}Club{} {C:attention}Face Card{},",
        "{C:green}1 in #1#{} chance to create",
        "{C:attention}#2#{} cop(y/ies) in your hand"
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.chance,
            math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.copies, card.ability.extra.copies_per_level, card.ability.extra.copies_per_ilvl))
        }
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            if context.scoring_hand then
                for _, played_card in ipairs(context.scoring_hand) do
                    if played_card:is_suit("Clubs") and played_card:is_face() and not played_card.dissolving then
                        if pseudorandom('varian') < (1 / card.ability.extra.chance) then
                            
                            -- Calculate the scaled amount of copies to generate
                            local copies_to_make = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.copies, card.ability.extra.copies_per_level, card.ability.extra.copies_per_ilvl))
                            
                            if copies_to_make > 0 then
                                card:juice_up()
                                G.E_MANAGER:add_event(Event({
                                    func = function()
                                        -- Loop to create the exact amount of copies
                                        for i = 1, copies_to_make do
                                            local new_card = copy_card(played_card, nil, nil, G.playing_card)
                                            -- (Removed the perma_bonus injection here)
                                            new_card:add_to_deck()
                                            table.insert(G.playing_cards, new_card)
                                            G.hand:emplace(new_card)
                                            new_card:juice_up()
                                        end
                                        play_sound('card1')
                                        return true
                                    end
                                }))
                                return {
                                    message = "Shalamayne!",
                                    colour = G.C.CLUBS,
                                    card = card
                                }
                            end
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
    damage = {"Piercing"},
    armor = {"Leather"},
    profession = {"Skinner","Leatherworker"},
    combo = {"Magni Bronzebeard", "Brann Bronzebeard", "Muradin Bronzebeard"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 5,
    index = 27,
    config = { extra = { money = 7, money_per_level = 1, money_per_ilvl = 0.5 } },
    loc_txt = {
        "Each time a {C:attention}Wild Card{}",
        "is discarded, gain {C:money}$#1#{}"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.money, card.ability.extra.money_per_level, card.ability.extra.money_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.discard and not context.blueprint then
            if context.other_card.config.center.key == 'm_wild' then
                ease_dollars(math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.money, card.ability.extra.money_per_level, card.ability.extra.money_per_ilvl)))
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
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {},
    combo = {"Arthas Menethil", "Brann Bronzebeard", "Magni Bronzebeard"},
    role = {"Tank"},
    rarity = 2,
    cost = 11,
    index = 28,
    config = { extra = { x_mult = 1.5, x_mult_per_level = 0.1, x_mult_per_ilvl = 0.1 } },
    loc_txt = {
        "Played {C:attention}Stone Cards{}",
        "give {X:mult,C:white} X#1# {} Mult",
        "when scored"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card.config.center.key == 'm_stone' then
                return {
                    x_mult = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
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
    damage = {"Fire","Frost","Arcane"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Khadgar", "Gul'dan", "Ner'zhul"},
    role = {"Ranged DPS"},
    rarity = 1,
    cost = 4,
    index = 29,
    config = { extra = { tags = 1, tags_per_level = 0.1, tags_per_ilvl = 0.1 } },
    loc_txt = {
        "When you {C:attention}Skip a Blind{},",
        "create {C:attention}#1#{} {C:spectral}Spectral Tag(s){}"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.tags, card.ability.extra.tags_per_level, card.ability.extra.tags_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.skip_blind and not context.blueprint then
            local effective_tags = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.tags, card.ability.extra.tags_per_level, card.ability.extra.tags_per_ilvl))
            G.E_MANAGER:add_event(Event({
                func = function()
                    card_eval_status_text(card, 'extra', nil, nil, nil, {
                        message = "Portal Opened!",
                        colour = G.C.SPECTRAL
                    })
                    return true
                end
            }))
            for i = 1, effective_tags do
                G.E_MANAGER:add_event(Event({
                    func = function()
                        add_tag(Tag('tag_ethereal'))
                        play_sound('generic1')
                        return true
                    end
                }))
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Kayn Sunfury",
    race = {"Blood Elf"},
    class = {"Demon Hunter"},
    weapon = {"Glaives"},
    damage = {"Shadow"},
    armor = {"Leather"},
    profession = {},
    combo = {"Illidan Stormrage", "Maiev Shadowsong", "Kor'vas Bloodthorn"},
    role = {"Melee DPS"},
    rarity = 1,
    cost = 2,
    index = 30,
    config = { extra = { chips = 10, chips_per_level = 1, chips_per_ilvl = 1 } },
    loc_txt = {
        "{C:chips}+#1#{} Chips for every",
        "{C:attention}Enhanced Card{} in your",
        "full deck",
        "{C:inactive}(Currently {C:chips}+#2#{C:inactive} Chips){}"
    },
    loc_vars = function(self, info_queue, card)
        local enhanced_count = 0
        if G.playing_cards then
            for _, v in ipairs(G.playing_cards) do
                -- Safer check using the string key instead of the table reference
                if v.config and v.config.center and v.config.center.key ~= 'c_base' then
                    enhanced_count = enhanced_count + 1
                end
            end
        end
        local effective_chips = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.chips, card.ability.extra.chips_per_level, card.ability.extra.chips_per_ilvl))
        return { effective_chips, enhanced_count * effective_chips }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local enhanced_count = 0
            if G.playing_cards then
                for _, v in ipairs(G.playing_cards) do
                    -- Safer check using the string key
                    if v.config and v.config.center and v.config.center.key ~= 'c_base' then
                        enhanced_count = enhanced_count + 1
                    end
                end
            end
            local effective_chips = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.chips, card.ability.extra.chips_per_level, card.ability.extra.chips_per_ilvl))
            local chips_bonus = enhanced_count * effective_chips
            if chips_bonus > 0 then
                return {
                    message = "Illidari!",
                    chips = chips_bonus, -- CHANGED FROM chip_mod to chips!
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
    damage = {"Shadow"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Arthas Menethil", "Lich King", "Gul'dan", "Kel'thuzad"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 10,
    index = 31,
    config = { extra = { cards = 1, cards_per_level = 0.2, cards_per_ilvl = 0.1 } },
    loc_txt = {
        "When playing a",
        "{C:attention}Four of a Kind{} of {C:attention}Kings{},",
        "create {C:attention}#1#{} random",
        "{C:dark_edition}Negative{} {C:spectral}Spectral{} card(s)"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.cards, card.ability.extra.cards_per_level, card.ability.extra.cards_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            if context.scoring_name == 'Four of a Kind' then
                local is_kings = false
                if context.scoring_hand and #context.scoring_hand > 0 then
                    for _, v in ipairs(context.scoring_hand) do
                        if v:get_id() == 13 then
                            is_kings = true
                            break
                        end
                    end
                end
                if is_kings then
                    local effective_cards = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.cards, card.ability.extra.cards_per_level, card.ability.extra.cards_per_ilvl))
                    for i = 1, effective_cards do
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                if #G.consumeables.cards < G.consumeables.config.card_limit then
                                    local new_card = create_card('Spectral', G.consumeables, nil, nil, nil, nil, nil, 'nerzhul')
                                    new_card:set_edition({negative = true}, true)
                                    new_card:add_to_deck()
                                    G.consumeables:emplace(new_card)
                                end
                                return true
                            end
                        }))
                    end
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
    damage = {"Physical"},
    armor = {"Leather"},
    profession = {},
    combo = {"Garrosh Hellscream", "Thrall", "Varian Wrynn"},
    role = {"Tank"},
    rarity = 2,
    cost = 8,
    index = 32,
    config = { extra = { bonus_chips = 3, bonus_chips_per_level = 1, bonus_chips_per_ilvl = 0.5 } },
    loc_txt = {
        "If played hand has {C:attention}no{}",
        "{C:attention}Enhancements{} or {C:dark_edition}Editions{},",
        "played cards permanently",
        "gain a {C:red}Red Seal{} and {C:chips}+#1#{} Chips"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.bonus_chips, card.ability.extra.bonus_chips_per_level, card.ability.extra.bonus_chips_per_ilvl) }
    end,
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
                local bonus = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.bonus_chips, card.ability.extra.bonus_chips_per_level, card.ability.extra.bonus_chips_per_ilvl))
                local cards_modified = 0
                for _, played_card in ipairs(context.full_hand) do
                    played_card.ability.perma_bonus = (played_card.ability.perma_bonus or 0) + bonus
                    if played_card:get_seal() ~= 'Red' then
                        played_card:set_seal('Red', nil, true)
                    end
                    cards_modified = cards_modified + 1
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
    damage = {"Nature"},
    armor = {"Unarmored"},
    profession = {},
    combo = {"Malfurion Stormrage", "Tyrande Whisperwind", "Ysera"},
    role = {"Ranged DPS"},
    rarity = 1,
    cost = 3,
    index = 33,
    config = { extra = { mult = 3, mult_per_level = 0.3, mult_per_ilvl = 0.3 } },
    loc_txt = {
        "Retrigger all played {C:attention}3s{}.",
        "Played {C:attention}3s{} give {C:mult}+#1#{} Mult",
        "When a blind is defeated,",
        "add a random {C:attention}3{} to your deck"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl) }
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
                    mult = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl)),
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
    damage = {"Frost"},
    armor = {"Cloth"},
    profession = {},
    combo = {"N'Zoth", "Gul'dan", "Sargeras"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 5,
    index = 34,
    config = { extra = { x_mult = 1.5, x_mult_per_level = 0.1, x_mult_per_ilvl = 0.1 } },
    loc_txt = {
        "Each {C:attention}Queen{} held in",
        "hand gives {X:mult,C:white} X#1# {} Mult"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.hand and not context.end_of_round then
            if context.other_card:get_id() == 12 and not context.other_card.debuff then
                return {
                    x_mult = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
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
    damage = {"Shadow"},
    armor = {"Plate"},
    profession = {},
    combo = {"Alexandros Mograine", "Lich King", "Arthas Menethil"},
    role = {"Tank"},
    rarity = 2,
    cost = 6,
    index = 35,
    config = { extra = { bonus_chips = 5, bonus_chips_per_level = 1, bonus_chips_per_ilvl = 0.5 } },
    loc_txt = {
        "Played cards that",
        "{C:attention}do not score{}",
        "become {C:attention}Stone Cards{}",
        "with {C:chips}+#1#{} permanent Chips"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.bonus_chips, card.ability.extra.bonus_chips_per_level, card.ability.extra.bonus_chips_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.after and not context.blueprint then
            local converted_cards = false
            if context.full_hand and context.scoring_hand then
                local bonus = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.bonus_chips, card.ability.extra.bonus_chips_per_level, card.ability.extra.bonus_chips_per_ilvl))
                for _, played_card in ipairs(context.full_hand) do
                    local is_scoring = false
                    for _, scoring_card in ipairs(context.scoring_hand) do
                        if played_card == scoring_card then
                            is_scoring = true
                            break
                        end
                    end
                    if not is_scoring and played_card.config.center.key ~= 'm_stone' and not played_card.dissolving then
                        played_card:set_ability(G.P_CENTERS.m_stone, nil, true)
                        played_card.ability.perma_bonus = (played_card.ability.perma_bonus or 0) + bonus
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
    race = {"Undead", "Orc", "Human"},
    class = {"Death Knight"},
    weapon = {"Staff","Hammer"},
    damage = {"Shadow"},
    armor = {"Plate"},
    profession = {},
    combo = {"Illidan Stormrage", "Gul'dan", "Ner'zhul"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 7,
    index = 36,
    config = { extra = { x_mult = 1, x_mult_gain = 0.25, x_mult_gain_per_level = 0.1, x_mult_gain_per_ilvl = 0.05 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "Gains {X:mult,C:white} X#2# {} Mult when",
        "a playing card is {C:red}destroyed{}"
    },
    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult, Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_gain, card.ability.extra.x_mult_gain_per_level, card.ability.extra.x_mult_gain_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.remove_playing_cards and not context.blueprint then
            local destroyed_count = #context.removed
            if destroyed_count > 0 then
                local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_gain, card.ability.extra.x_mult_gain_per_level, card.ability.extra.x_mult_gain_per_ilvl)
                card.ability.extra.x_mult = card.ability.extra.x_mult + (effective_gain * destroyed_count)
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
    damage = {"Piercing"},
    armor = {"Mail"},
    profession = {},
    combo = {"Sylvanas Windrunner", "Vereesa Windrunner", "Turalyon", "Khadgar"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 5,
    index = 37,
    config = { extra = { base_chance = 1, max_chance = 10, max_chance_per_level = -0.2, max_chance_per_ilvl = -0.1 } },
    loc_txt = {
        "Played cards have a",
        "{C:green}#1# in #2#{} chance to gain",
        "a {C:purple}Purple Seal{}"
    },
    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.base_chance, Warcraft.get_scaled_gain(card, card.ability.extra.max_chance, card.ability.extra.max_chance_per_level, card.ability.extra.max_chance_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local effective_max = math.max(1, Warcraft.get_scaled_gain(card, card.ability.extra.max_chance, card.ability.extra.max_chance_per_level, card.ability.extra.max_chance_per_ilvl))
            local cards_infused = false
            if context.full_hand then
                for _, played_card in ipairs(context.full_hand) do
                    if pseudorandom('alleria') < (card.ability.extra.base_chance / effective_max) then
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
    damage = {"Fire"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Illidan Stormrage", "Jaine Proudmoore", "Lord Garithos", "Lady Vashj"},
    role = {"Ranged DPS"},
    rarity = 1,
    cost = 4,
    index = 38,
    config = { extra = { x_mult = 2, x_mult_per_level = 0.1, x_mult_per_ilvl = 0.1 } },
    loc_txt = {
        "Played {C:attention}Glass Cards{}",
        "give {X:mult,C:white} X#1# {} Mult",
        "when scored"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card.config.center.key == 'm_glass' then
                return {
                    x_mult = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
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
    damage = {"Shadow"},
    armor = {"Unarmored"},
    profession = {},
    combo = {"Kil'Jaeden", "Sylvanas Windrunner", "Ner'zhul"},
    role = {"Tank"},
    rarity = 1,
    cost = 5,
    index = 39,
    config = { extra = { bonus_chips = 3, bonus_chips_per_level = 0.5, bonus_chips_per_ilvl = 0.25 } },
    loc_txt = {
        "{C:attention}Jacks{} are considered",
        "{C:attention}Wild Cards{} and",
        "cannot be {C:attention}Debuffed{}",
        "Scored {C:attention}Jacks{} gain {C:chips}+#1#{} permanent Chips"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.bonus_chips, card.ability.extra.bonus_chips_per_level, card.ability.extra.bonus_chips_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.debuff_card and not context.blueprint then
            if context.debuff_card:get_id() == 11 then
                return "prevent_debuff"
            end
        end

        if context.individual and context.cardarea == G.play and not context.blueprint then
            if context.other_card:get_id() == 11 then
                local bonus = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.bonus_chips, card.ability.extra.bonus_chips_per_level, card.ability.extra.bonus_chips_per_ilvl))
                context.other_card.ability.perma_bonus = (context.other_card.ability.perma_bonus or 0) + bonus
                return {
                    message = "Possessed!",
                    colour = G.C.PURPLE,
                    card = card
                }
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
    damage = {"Shadow"},
    armor = {"Unarmored"},
    profession = {},
    combo = {"Arthas Menethil", "Lich King", "Sire Denathrius"},
    role = {"Tank"},
    rarity = 3,
    cost = 10,
    index = 40,
    config = { extra = {
        chips = 0, mult = 0,
        chips_gain = 50, chips_gain_per_ilvl = 10,
        mult_gain = 5, mult_gain_per_level = 1,
        gold_gain = 3
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
            Warcraft.get_scaled_gain(card, card.ability.extra.chips_gain, 0, card.ability.extra.chips_gain_per_ilvl),
            Warcraft.get_scaled_gain(card, card.ability.extra.mult_gain, card.ability.extra.mult_gain_per_level, 0),
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
    class = {"Shaman", "Rogue"},
    weapon = {"Daggers"},
    damage = {"Physical"},
    armor = {"Leather"},
    profession = {},
    combo = {"Illidan Stormrage", "Maiev Shadowsong", "Farseer Nobundo"},
    role = {"Melee DPS"},
    rarity = 1,
    cost = 2,
    index = 41,
    config = { extra = { mult = 4, mult_per_level = 0.5, chips = 20, chips_per_ilvl = 2 } },
    loc_txt = {
        "Played {C:attention}Red Cards{} give {C:mult}+#1#{} Mult,",
        "Played {C:attention}Black Cards{} give {C:chips}+#2#{} Chips",
        "{C:inactive}(Wild Cards give both){}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, 0),
            Warcraft.get_scaled_gain(card, card.ability.extra.chips, 0, card.ability.extra.chips_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local other = context.other_card
            local is_red = other:is_suit("Hearts") or other:is_suit("Diamonds")
            local is_black = other:is_suit("Spades") or other:is_suit("Clubs")
            local ret = { card = other }
            local triggered = false

            if is_red then
                ret.mult = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, 0))
                triggered = true
            end
            if is_black then
                ret.chips = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.chips, 0, card.ability.extra.chips_per_ilvl))
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
    weapon = {"Staff"},
    damage = {"Nature"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Akama", "Illidan Stormrage", "Maiev Shadowsong", "Prophet Velen"},
    role = {"Healer"},
    rarity = 2,
    cost = 8,
    index = 42,
    config = { extra = { retrigger = 1, retrigger_per_level = 0.1, retrigger_per_ilvl = 0.1 } },
    loc_txt = {
        "Retrigger the {C:attention}first played card{}",
        "of each {C:attention}Suit{} {C:attention}#1#{} time(s)"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.retrigger, card.ability.extra.retrigger_per_level, card.ability.extra.retrigger_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            local other = context.other_card
            local hand = context.full_hand
            local matches = 0
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
                    matches = matches + 1
                end
            end
            if matches > 0 then
                local effective_retrigger = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.retrigger, card.ability.extra.retrigger_per_level, card.ability.extra.retrigger_per_ilvl))
                return {
                    message = "Elements!",
                    repetitions = matches * effective_retrigger,
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
    damage = {"Holy"},
    armor = {"Plate"},
    profession = {},
    combo = {"Khadgar", "Blackhand", "Archimonde", "Grommash Hellscream"},
    role = {"Tank"},
    rarity = 2,
    cost = 6,
    index = 43,
    config = { extra = { chips = 10, chips_per_level = 1, chips_per_ilvl = 1 } },
    loc_txt = {
        "Scoring {C:attention}Glass Cards{}",
        "permanently gain",
        "{C:chips}+#1#{} Chips"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.chips, card.ability.extra.chips_per_level, card.ability.extra.chips_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card.config.center.key == 'm_glass' then
                local bonus = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.chips, card.ability.extra.chips_per_level, card.ability.extra.chips_per_ilvl))
                context.other_card.ability.perma_bonus = (context.other_card.ability.perma_bonus or 0) + bonus
                return {
                    extra = { message = "Upgraded!", colour = G.C.CHIPS },
                    colour = G.C.CHIPS,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Alexstrasza",
    faction = {"Pantheon"},
    race = {"Dragon"},
    weapon = {"Staff","Claw","Teeth"},
    damage = {"Fire"},
    armor = {"Mail"},
    profession = {},
    combo = {"Nozdormu", "Ysera", "Kalecgos", "Thrall", "Neltharion", "Deathwing"},
    role = {"Healer"},
    rarity = 2,
    cost = 5,
    index = 44,
    config = { extra = { x_mult = 1.5, x_mult_per_level = 0.1, x_mult_per_ilvl = 0.05 } },
    loc_txt = {
        "Played {C:hearts}Hearts{} give",
        "{X:mult,C:white} X#1# {} Mult when scored.",
        "All {C:hearts}Hearts{} are considered",
        "{C:attention}Face Cards{}"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:is_suit('Hearts') then
                return {
                    x_mult = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
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
    faction = {"Pantheon"},
    race = {"Dragon"},
    class = {"Mage"},
    weapon = {"Staff","Claw","Teeth"},
    damage = {"Arcane"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Alexstrasza", "Ysera", "Nozdormu", "Thrall", "Neltharion", "Deathwing"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 4,
    index = 45,
    config = { extra = { packs = 1, packs_per_level = 0.1, packs_per_ilvl = 0.05 } },
    loc_txt = {
        "{C:tarot}Arcana Packs{} cost {C:money}$0{}",
        "An extra {C:attention}#1#{} {C:tarot}Mega Arcana Pack(s){}",
        "appears in every {C:attention}Shop{}"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.packs, card.ability.extra.packs_per_level, card.ability.extra.packs_per_ilvl) }
    end,
    add_to_deck = function(self, card, from_debuff)
        if G.shop_booster then
            for _, c in ipairs(G.shop_booster.cards) do c:set_cost() end
        end
    end,
    remove_from_deck = function(self, card, from_debuff)
        if G.shop_booster then
            for _, c in ipairs(G.shop_booster.cards) do c:set_cost() end
        end
    end,
    calculate = function(self, card, context)
    end
})

Warcraft.create_warcraft_joker({
    name = "Malygos",
    faction = {"Pantheon"},
    race = {"Dragon"},
    class = {"Mage"},
    weapon = {"Staff","Claw","Teeth"},
    damage = {"Arcane"},
    armor = {"Mail"},
    profession = {},
    combo = {"Kalecgos", "Alexstrasza", "Nozdormu"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 5,
    index = 46,
    config = { extra = { mult = 20, mult_per_level = 2, mult_per_ilvl = 2 } },
    loc_txt = {
        "{C:mult}+#1#{} Mult for every",
        "empty {C:attention}Consumable Slot{}",
        "{C:inactive}(Currently {C:mult}+#2#{C:inactive} Mult){}"
    },
    loc_vars = function(self, info_queue, card)
        local empty_slots = math.max(0, G.consumeables.config.card_limit - #G.consumeables.cards)
        local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl)
        return { effective_mult, empty_slots * effective_mult }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local empty_slots = math.max(0, G.consumeables.config.card_limit - #G.consumeables.cards)
            local effective_mult = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl))
            local mult_bonus = empty_slots * effective_mult
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
    faction = {"Pantheon"},
    race = {"Dragon"},
    class = {"Warrior"},
    weapon = {"Hammer","Claw","Teeth"},
    damage = {"Fire"},
    armor = {"Plate"},
    profession = {},
    combo = {"Alexstrasza", "Nozdormu", "Ysera"},
    role = {"Tank"},
    rarity = 2,
    cost = 8,
    index = 47,
    config = { extra = { chips = 300, chips_per_level = 20, chips_per_ilvl = 20, h_size = 1 } },
    loc_txt = {
        "{C:chips}+#1#{} Chips",
        "{C:attention}-#2#{} Hand Size"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.chips, card.ability.extra.chips_per_level, card.ability.extra.chips_per_ilvl), card.ability.extra.h_size }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                chip_mod = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.chips, card.ability.extra.chips_per_level, card.ability.extra.chips_per_ilvl)),
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
    faction = {"Pantheon"},
    race = {"Dragon"},
    class = {"Mage"},
    weapon = {"Staff","Claw","Teeth"},
    damage = {"Nature"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Alexstrasza", "Kalecgos", "Ysera"},
    role = {"Ranged DPS"},
    rarity = 1,
    cost = 8,
    index = 48,
    config = { extra = { hand = 1, hand_per_level = 0.1, discard = 1, discard_per_ilvl = 0.05, current_hand = 1, current_discard = 1 } },
    loc_txt = {
        "{C:blue}+#1#{} Hand and",
        "{C:red}+#2#{} Discard",
        "per round"
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.hand, card.ability.extra.hand_per_level, 0),
            Warcraft.get_scaled_gain(card, card.ability.extra.discard, 0, card.ability.extra.discard_per_ilvl)
        }
    end,
    add_to_deck = function(self, card, from_debuff)
        local effective_hand = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.hand, card.ability.extra.hand_per_level, 0))
        local effective_discard = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.discard, 0, card.ability.extra.discard_per_ilvl))
        card.ability.extra.current_hand = effective_hand
        card.ability.extra.current_discard = effective_discard
        G.GAME.round_resets.hands = G.GAME.round_resets.hands + effective_hand
        G.GAME.round_resets.discards = G.GAME.round_resets.discards + effective_discard
        if G.GAME.current_round.hands_left then
            G.GAME.current_round.hands_left = G.GAME.current_round.hands_left + effective_hand
            G.GAME.current_round.discards_left = G.GAME.current_round.discards_left + effective_discard
        end
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.GAME.round_resets.hands = G.GAME.round_resets.hands - card.ability.extra.current_hand
        G.GAME.round_resets.discards = G.GAME.round_resets.discards - card.ability.extra.current_discard
        if G.GAME.current_round.hands_left then
            G.GAME.current_round.hands_left = math.max(0, G.GAME.current_round.hands_left - card.ability.extra.current_hand)
            G.GAME.current_round.discards_left = math.max(0, G.GAME.current_round.discards_left - card.ability.extra.current_discard)
        end
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.repetition and not context.individual and not context.blueprint then
            local new_hand = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.hand, card.ability.extra.hand_per_level, 0))
            local new_discard = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.discard, 0, card.ability.extra.discard_per_ilvl))
            local hand_diff = new_hand - card.ability.extra.current_hand
            local discard_diff = new_discard - card.ability.extra.current_discard
            if hand_diff ~= 0 or discard_diff ~= 0 then
                G.GAME.round_resets.hands = G.GAME.round_resets.hands + hand_diff
                G.GAME.round_resets.discards = G.GAME.round_resets.discards + discard_diff
                card.ability.extra.current_hand = new_hand
                card.ability.extra.current_discard = new_discard
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Ysera",
    faction = {"Pantheon"},
    race = {"Dragon"},
    class = {"Druid"},
    weapon = {"Staff", "Claw","Teeth"},
    damage = {"Nature"},
    armor = {"Mail"},
    profession = {},
    combo = {"Alexstrasza","Nozdormu","Kalecgos"},
    role = {"Melee DPS"},
    rarity = 1,
    cost = 4,
    index = 49,
    config = { extra = { number = 2, number_per_level = 0.1, number_per_ilvl = 0.1 } },
    loc_txt = {
        "When you {C:attention}Skip a Blind{},",
        "create {C:attention}#1#{} random",
        "{C:tarot}Tarot{} cards"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.number, card.ability.extra.number_per_level, card.ability.extra.number_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.skip_blind then
            local effective_number = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.number, card.ability.extra.number_per_level, card.ability.extra.number_per_ilvl))
            G.E_MANAGER:add_event(Event({
                func = function()
                    for i = 1, effective_number do
                        local new_card = create_card('Tarot', G.consumeables, nil, nil, nil, nil, nil, 'ysera')
                        new_card:add_to_deck()
                        G.consumeables:emplace(new_card)
                    end
                    card_eval_status_text(card, 'extra', nil, nil, nil, { message = "Dream!", colour = G.C.PURPLE })
                    return true
                end
            }))
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Onyxia",
    race = {"Dragon"},
    weapon = {"Claw","Teeth"},
    damage = {"Fire"},
    armor = {"leather"},
    profession = {},
    combo = {"Varian Wrynn", "Deathwing", "Neltharion", "Nefarian", "Sabellian", "Ebyssian"},
    role = {"Ranged DPS"},
    rarity = 1,
    cost = 4,
    index = 50,
    config = { extra = { copies = 1, copies_per_level = 0.1, copies_per_ilvl = 0.1 } },
    loc_txt = {
        "When you play a {C:attention}Queen{},",
        "create {C:attention}#1#{} permanent {C:attention}2(s){}",
        "of a random suit in your deck"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.copies, card.ability.extra.copies_per_level, card.ability.extra.copies_per_ilvl) }
    end,
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
                local effective_copies = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.copies, card.ability.extra.copies_per_level, card.ability.extra.copies_per_ilvl))
                G.E_MANAGER:add_event(Event({
                    func = function()
                        for i = 1, queens_count * effective_copies do
                            local suit = pseudorandom_element({'S','H','D','C'}, pseudoseed('onyxia_' .. i .. '_' .. G.GAME.round))
                            local new_card = create_card('Base', G.deck, nil, nil, nil, nil, nil, 'onyxia')
                            new_card:set_base(G.P_CARDS[suit .. '_2'])
                            new_card:add_to_deck()
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
    damage = {"Nature"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Nozdormu", "Kalecgos", "Alexstrasza", "Ysera"},
    role = {"Ranged DPS"},
    rarity = 1,
    cost = 3,
    index = 51,
    -- CHANGED: Swapped chips for 'returns'. 
    -- Scaling at 0.5/0.25 means +1 extra return every 2 levels or 4 ilvls!
    config = { extra = { returns = 1, returns_per_level = 0.5, returns_per_ilvl = 0.25, hands_returned_this_blind = 0 } },
    loc_txt = {
        "The {C:attention}first #1#{} scored hand(s)",
        "each blind are returned",
        "to your {C:attention}hand{} after scoring.",
        "{C:inactive}(Returned: #2# / #1#){}"
    },
    loc_vars = function(self, info_queue, card)
        local max_returns = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.returns, card.ability.extra.returns_per_level, card.ability.extra.returns_per_ilvl))
        return { 
            max_returns, 
            card.ability.extra.hands_returned_this_blind 
        }
    end,
    calculate = function(self, card, context)
        -- 1. Reset the counter when the blind actually starts drawing cards
        if context.first_hand_drawn and not context.blueprint then
            card.ability.extra.hands_returned_this_blind = 0
        end

        -- 2. Mark the scoring cards BEFORE they are scored
        if context.before and not context.blueprint then
            local max_returns = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.returns, card.ability.extra.returns_per_level, card.ability.extra.returns_per_ilvl))
            
            if card.ability.extra.hands_returned_this_blind < max_returns then
                card.ability.extra.hands_returned_this_blind = card.ability.extra.hands_returned_this_blind + 1
                
                -- Tag every card in the scoring hand so Chromie remembers them
                if context.scoring_hand then
                    for _, c in ipairs(context.scoring_hand) do
                        if c.ability then
                            c.ability.chromie_saved = true
                        end
                    end
                end
                
                return {
                    message = "Time Shift!",
                    colour = G.C.ORANGE,
                    card = card
                }
            end
        end

        -- 3. Intercept the cards as they try to leave the play area
        if context.stay_flipped and context.from_area == G.play and not context.blueprint then
            local played_card = context.other_card
            
            -- If this card was tagged by Chromie, wipe the tag and send it to the hand!
            if played_card.ability and played_card.ability.chromie_saved then
                played_card.ability.chromie_saved = nil
                
                return {
                    modify = { to_area = G.hand }
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Saphiron",
    faction = {"Scourge"},
    race = {"Undead"},
    weapon = {"Fist"},
    damage = {"Frost"},
    armor = {"Plate"},
    profession = {},
    combo = {"Arthas Menethil", "Lich King", "Kel'thuzad"},
    role = {"Ranged DPS"},
    rarity = 1,
    cost = 5,
    index = 52,
    config = { extra = { bonus_chips = 3, bonus_chips_per_level = 0.5, bonus_chips_per_ilvl = 0.25 } },
    loc_txt = {
        "Played {C:attention}Blue Seal{} cards",
        "become {C:attention}Glass Cards{},",
        "Played {C:attention}Glass Cards{} gain",
        "a {C:blue}Blue Seal{}",
        "Both gain {C:chips}+#1#{} permanent Chips"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.bonus_chips, card.ability.extra.bonus_chips_per_level, card.ability.extra.bonus_chips_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local bonus = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.bonus_chips, card.ability.extra.bonus_chips_per_level, card.ability.extra.bonus_chips_per_ilvl))
            local changed = false
            for _, v in ipairs(context.full_hand) do
                local is_glass = (v.config.center.key == 'm_glass')
                local has_blue = (v:get_seal() == 'Blue')
                if has_blue and not is_glass then
                    v:set_ability(G.P_CENTERS.m_glass, nil, true)
                    v.ability.perma_bonus = (v.ability.perma_bonus or 0) + bonus
                    v:juice_up()
                    changed = true
                    is_glass = true
                end
                if is_glass and not has_blue then
                    v:set_seal('Blue', nil, true)
                    v.ability.perma_bonus = (v.ability.perma_bonus or 0) + bonus
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
    damage = {"Piercing"},
    armor = {"Leather"},
    profession = {},
    combo = {"Magni Bronzebeard", "Muradin Bronzebeard", "Harrisson Jones", "Moira Thaurissan"},
    role = {"Ranged DPS"},
    rarity = 1,
    cost = 4,
    index = 53,
    config = { extra = { retrigger = 3, retrigger_per_level = 0.2, retrigger_per_ilvl = 0.1 } },
    loc_txt = {
        "Retrigger the",
        "{C:attention}first scoring card{}",
        "{C:attention}#1#{} times"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.retrigger, card.ability.extra.retrigger_per_level, card.ability.extra.retrigger_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            if context.scoring_hand and context.scoring_hand[1] == context.other_card then
                return {
                    message = "Brann!",
                    repetitions = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.retrigger, card.ability.extra.retrigger_per_level, card.ability.extra.retrigger_per_ilvl)),
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
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {},
    combo = {"Brann Bronzebeard", "Muradin Bronzebeard", "Moira Thaurissan"},
    role = {"Tank"},
    rarity = 3,
    cost = 9,
    index = 54,
    config = { extra = { x_mult = 1.5, x_mult_per_level = 0.1, x_mult_per_ilvl = 0.1 } },
    loc_txt = {
        "Scoring {C:diamonds}Diamonds{} give",
        "{X:mult,C:white} X#1# {} Mult"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:is_suit("Diamonds") then
                context.other_card:juice_up()
                return {
                    x_mult = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
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
    damage = {"Holy"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Brann Bronzebeard", "Magni Bronzebeard","Muradin Bronzebeard", "Emperor Dagran Thaurissan"},
    role = {"Healer"},
    rarity = 2,
    cost = 4,
    index = 55,
    config = { extra = { mult = 20, mult_per_level = 3, mult_per_ilvl = 2 } },
    loc_txt = {
        "If played hand contains a",
        "{C:attention}King{} and a {C:attention}Queen{},",
        "destroy the {C:attention}King{} and give the",
        "{C:attention}Queen{} {C:mult}+#1#{} Mult permanently"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl) }
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
                local effective_mult = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl))
                queen.ability.perma_mult = (queen.ability.perma_mult or 0) + effective_mult
                queen:juice_up()
                card_eval_status_text(queen, 'extra', nil, nil, nil, { message = "Upgrade!", colour = G.C.MULT })
                G.E_MANAGER:add_event(Event({
                    func = function()
                        king:start_dissolve({remove_as_card = true})
                        return true
                    end
                }))
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
    damage = {"Nature"},
    armor = {"Unarmored"},
    profession = {},
    combo = {"Kurdran Wildhammer", "Alexstrasza", "Vereesa Windrunner"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 6,
    index = 56,
    config = { extra = { retrigger = 1, retrigger_per_level = 0.3, retrigger_per_ilvl = 0.2 } },
    loc_txt = {
        "Played {C:attention}Wild Cards{}",
        "retrigger {C:attention}#1#{} time(s)"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.retrigger, card.ability.extra.retrigger_per_level, card.ability.extra.retrigger_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            if context.other_card.config.center.key == 'm_wild' then
                return {
                    message = "Wildhammer!",
                    repetitions = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.retrigger, card.ability.extra.retrigger_per_level, card.ability.extra.retrigger_per_ilvl)),
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
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {},
    combo = {"Thrall", "Lady Liadrin", "Carine Bloodhoof", "Baine Bloodhoof"},
    role = {"Tank"},
    rarity = 1,
    cost = 6,
    index = 57,
    config = { extra = { number = 1, bonus_chips = 5, bonus_chips_per_level = 1, bonus_chips_per_ilvl = 0.5 } },
    loc_txt = {
        "If you play exactly {C:attention}#1# card{},",
        "it permanently gains a",
        "{C:red}Red Seal{} and {C:chips}+#2#{} Chips"
    },
    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.number, Warcraft.get_scaled_gain(card, card.ability.extra.bonus_chips, card.ability.extra.bonus_chips_per_level, card.ability.extra.bonus_chips_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            if #context.full_hand == card.ability.extra.number then
                local played_card = context.full_hand[1]
                local bonus = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.bonus_chips, card.ability.extra.bonus_chips_per_level, card.ability.extra.bonus_chips_per_ilvl))
                played_card.ability.perma_bonus = (played_card.ability.perma_bonus or 0) + bonus
                if played_card:get_seal() ~= 'Red' then
                    played_card:set_seal('Red', nil, true)
                end
                played_card:juice_up()
                return {
                    message = "Ranger's Mark!",
                    colour = G.C.RED,
                    card = card
                }
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
    damage = {"Holy"},
    armor = {"Plate"},
    profession = {},
    combo = {"Lor'themar Theron", "Zul'jin", "Sylvanas Windrunner", "Arthas Menethil"},
    role = {"Tank"},
    rarity = 2,
    cost = 5,
    index = 58,
    config = { extra = { x_mult = 2, x_mult_per_level = 0.1, x_mult_per_ilvl = 0.1, money = 1 } },
    loc_txt = {
        "Played {C:hearts}Hearts{} give",
        "{X:mult,C:white} X#1# {} Mult when scored,",
        "but you lose {C:money}$#2#{}",
        "for each {C:hearts}Heart{} scored"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl), card.ability.extra.money }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:is_suit("Hearts") then
                ease_dollars(-card.ability.extra.money)
                return {
                    x_mult = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
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
    damage = {"Physical"},
    armor = {"Mail"},
    profession = {},
    combo = {"Illidan Stormrage", "Tyrande Whisperwind", "Malfurion Stormrage", "Kael'thas Sunstrider"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 7,
    index = 59,
    config = { extra = { x_mult = 1, x_mult_gain = 0.25, x_mult_gain_per_level = 0.1, x_mult_gain_per_ilvl = 0.05 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "Gains {X:mult,C:white} X#2# {} Mult each time",
        "an {C:red}Enemy{} is killed by its",
        "{C:attention}Kill Condition{}"
    },
    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult, Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_gain, card.ability.extra.x_mult_gain_per_level, card.ability.extra.x_mult_gain_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            G.GAME.warcraft_kills_this_hand = 0
        end

        if context.after and not context.blueprint then
            local kills = G.GAME.warcraft_kills_this_hand or 0
            if kills > 0 then
                local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_gain, card.ability.extra.x_mult_gain_per_level, card.ability.extra.x_mult_gain_per_ilvl)
                card.ability.extra.x_mult = card.ability.extra.x_mult + (kills * effective_gain)
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
    damage = {"Nature"},
    armor = {"Mail"},
    profession = {},
    combo = {"Illidan Stormrage", "Lord Garithos", "Kael'thas Sunstrider"},
    role = {"Ranged DPS"},
    rarity = 1,
    cost = 4,
    index = 60,
    config = { extra = { retrigger = 1, retrigger_per_level = 0.5, retrigger_per_ilvl = 0.3 } },
    loc_txt = {
        "Retrigger the card in the",
        "{C:attention}exact center{} of the",
        "scoring hand {C:attention}#1#{} time(s)",
        "{C:inactive}(Only works with odd number of cards){}"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.retrigger, card.ability.extra.retrigger_per_level, card.ability.extra.retrigger_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            local hand = context.scoring_hand
            local count = #hand
            if count % 2 == 1 then
                local center_idx = math.ceil(count / 2)
                if context.other_card == hand[center_idx] then
                    return {
                        message = "Medusa!",
                        repetitions = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.retrigger, card.ability.extra.retrigger_per_level, card.ability.extra.retrigger_per_ilvl)),
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
    damage = {"Shadow"},
    armor = {"Plate"},
    profession = {},
    combo = {"Sylvanas Windrunner", "Anduin Wrynn", "Sire Denathrius"},
    role = {"Tank"},
    rarity = 3,
    cost = 20,
    index = 61,
    config = { extra = { x_mult = 5, x_mult_per_level = 1, x_mult_per_ilvl = 0.5 } },
    loc_txt = {
        "Played {C:attention}Debuffed Cards{} score",
        "their Chips and give",
        "{X:mult,C:white} X#1# {} Mult"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local effective_x_mult = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl)
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
                local total_x_mult = effective_x_mult ^ debuffed_count
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
    damage = {"Nature"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Remornia", "Zovaal", "Mal'ganis"},
    role = {"Tank"},
    rarity = 3,
    cost = 10,
    index = 62,
    config = { extra = { mult = 1, mult_per_level = 0.2, mult_per_ilvl = 0.1, money = 1 } },
    loc_txt = {
        "Played cards give",
        "{C:mult}+#1#{} Mult for every",
        "{C:money}$#2#{} you have",
        "{C:inactive}(Currently {C:mult}+#3#{C:inactive} Mult){}"
    },
    loc_vars = function(self, info_queue, card)
        local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl)
        local bonus = effective_mult * math.max(0, G.GAME.dollars / card.ability.extra.money)
        return { effective_mult, card.ability.extra.money, bonus }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl)
            local bonus = effective_mult * math.max(0, G.GAME.dollars / card.ability.extra.money)
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
    faction = {"Legion", "Pantheon"},
    race = {"Titan"},
    weapon = {"Sword"},
    damage = {"Fire"},
    armor = {"Plate"},
    profession = {},
    combo = {"Argus the Unmaker", "Kil'Jaeden", "Archimonde", "Illidan Stormrage"},
    role = {"Melee DPS"},
    rarity = 3,
    cost = 20,
    index = 63,
    config = { extra = { x_mult = 1, gain = 0.5, gain_per_level = 0.2, gain_per_ilvl = 0.1 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "When you play a hand,",
        "destroy the Joker to the {C:attention}right{}",
        "and gain {X:mult,C:white} X#2# {} Mult.",
        "If no Joker is to the right,",
        "{C:red}Debuff{} this Joker for the hand"
    },
    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.x_mult, Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl) }
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
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            victim:start_dissolve({remove_as_card = true})
                            return true
                        end
                    }))
                    local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl)
                    card.ability.extra.x_mult = card.ability.extra.x_mult + effective_gain
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
    damage = {"Shadow"},
    armor = {"Leather"},
    profession = {},
    combo = {"Yogg Saron", "N'Zoth", "Y'Shaarj"},
    role = {"Ranged DPS"},
    rarity = 1,
    cost = 5,
    index = 64,
    config = { extra = { chips = 0, gain = 10, gain_per_level = 1, gain_per_ilvl = 1 } },
    loc_txt = {
        "{C:chips}+#1#{} Chips",
        "{C:inactive}(Gains {C:chips}+#2#{C:inactive} Chips every time",
        "{C:inactive}a card with {C:attention}Odd Rank{C:inactive} is",
        "{C:inactive}scored){}"
    },
    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.chips, math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl)) }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local rank_id = context.other_card:get_id()
            
            local is_odd = rank_id and rank_id > 0 and ((rank_id % 2 == 1) or (rank_id == 14))
            
            if is_odd then
                local effective_gain = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl))
                card.ability.extra.chips = card.ability.extra.chips + effective_gain
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
                    chips = card.ability.extra.chips, -- CHANGED: from chip_mod to chips
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
    weapon = {"Tentacle"},
    damage = {"Shadow"},
    armor = {"Leather"},
    profession = {},
    combo = {"C'Thun", "Y'Shaarj", "N'Zoth"},
    role = {"Ranged DPS"},
    rarity = 3,
    cost = 8,
    index = 65,
    config = { extra = { equipment = 1, equipment_per_level = 0.25, equipment_per_ilvl = 0.1 } },
    loc_txt = {
        "When you {C:attention}Skip a Blind{},",
        "create {C:attention}#1#{} random",
        "{C:attention}Equipment{} card(s)"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.equipment, card.ability.extra.equipment_per_level, card.ability.extra.equipment_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.skip_blind then
            local effective_count = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.equipment, card.ability.extra.equipment_per_level, card.ability.extra.equipment_per_ilvl))
            G.E_MANAGER:add_event(Event({
                func = function()
                    if not Warcraft.Equipment.keys or #Warcraft.Equipment.keys == 0 then
                        card_eval_status_text(card, 'extra', nil, nil, nil, { message = "No Loot!", colour = G.C.RED })
                        return true
                    end
                    for i = 1, effective_count do
                        local chosen_key = pseudorandom_element(Warcraft.Equipment.keys, pseudoseed('yogg_' .. i .. '_' .. G.GAME.round))
                        local new_card = create_card('Equipment', G.consumeables, nil, nil, nil, nil, chosen_key, 'yogg')
                        new_card:add_to_deck()
                        G.consumeables:emplace(new_card)
                    end
                    card_eval_status_text(card, 'extra', nil, nil, nil, { message = "Madness!", colour = G.C.PURPLE })
                    return true
                end
            }))
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Y'Shaarj",
    race = {"God"},
    weapon = {"Tentacle"},
    damage = {"Shadow"},
    armor = {"Leather"},
    profession = {},
    combo = {"C'Thun", "Yogg Saron", "N'Zoth"},
    role = {"Ranged DPS"},
    rarity = 1,
    cost = 4,
    index = 66,
    config = { extra = { bonus_chips = 3, bonus_chips_per_level = 0.5, bonus_chips_per_ilvl = 0.25 } },
    loc_txt = {
        "After drawing your {C:attention}opening hand{},",
        "order the remaining deck from",
        "{C:attention}Highest{} to {C:attention}Lowest{} Rank",
        "Opening hand gains {C:chips}+#1#{} permanent Chips"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.bonus_chips, card.ability.extra.bonus_chips_per_level, card.ability.extra.bonus_chips_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.first_hand_drawn then
            local bonus = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.bonus_chips, card.ability.extra.bonus_chips_per_level, card.ability.extra.bonus_chips_per_ilvl))
            G.E_MANAGER:add_event(Event({
                func = function()
                    -- Apply permanent chips to opening hand
                    for _, c in ipairs(G.hand.cards) do
                        c.ability.perma_bonus = (c.ability.perma_bonus or 0) + bonus
                        c:juice_up()
                    end
                    -- Sort remaining deck highest to lowest
                    table.sort(G.deck.cards, function(a, b)
                        return a.base.id < b.base.id
                    end)
                    G.deck:juice_up()
                    card_eval_status_text(card, 'extra', nil, nil, nil, { message = "Unleashed!", colour = G.C.RED })
                    return true
                end
            }))
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "N'Zoth",
    race = {"God"},
    weapon = {"Tentacle"},
    damage = {"Shadow"},
    armor = {"Leather"},
    profession = {},
    combo = {"C'Thun", "Yogg Saron", "Y'Shaarj"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 5,
    index = 67,
    config = { extra = { bonus_chips = 5, bonus_chips_per_level = 1, bonus_chips_per_ilvl = 0.5 } },
    loc_txt = {
        "Scoring {C:attention}Stone Cards{}",
        "gain a random {C:attention}Seal{}",
        "and {C:chips}+#1#{} permanent Chips"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.bonus_chips, card.ability.extra.bonus_chips_per_level, card.ability.extra.bonus_chips_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card.config.center.key == 'm_stone' then
                local bonus = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.bonus_chips, card.ability.extra.bonus_chips_per_level, card.ability.extra.bonus_chips_per_ilvl))
                context.other_card.ability.perma_bonus = (context.other_card.ability.perma_bonus or 0) + bonus
                if not context.other_card.seal then
                    local valid_seals = {}
                    for k, _ in pairs(G.P_SEALS) do
                        table.insert(valid_seals, k)
                    end
                    if #valid_seals > 0 then
                        local chosen_seal = pseudorandom_element(valid_seals, pseudoseed('nzoth_' .. G.GAME.round))
                        context.other_card:set_seal(chosen_seal, true, true)
                    end
                end
                return {
                    message = "Corrupted!",
                    colour = G.C.PURPLE,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Aman'Thul",
    faction = {"Pantheon"},
    race = {"Titan"},
    weapon = {"Staff"},
    damage = {"Arcane"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Eonar", "Sargeras", "Khaz'goroth", "Norgannon", "Aggramar", "Golganneth"},
    role = {"Tank"},
    rarity = 2,
    cost = 4,
    index = 68,
    config = { extra = { x_mult = 3, x_mult_per_level = 0.5, x_mult_per_ilvl = 0.25 } },
    loc_txt = {
        "Played {C:attention}Straights{} give",
        "{X:mult,C:white} X#1# {} Mult"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local hand_name = context.scoring_name
            if hand_name == "Straight" or hand_name == "Straight Flush" or hand_name == "Royal Flush" then
                return {
                    message = "Order!",
                    x_mult = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
                    colour = G.C.BLUE
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Eonar",
    faction = {"Pantheon"},
    race = {"Titan"},
    weapon = {"Staff"},
    damage = {"Nature"},
    armor = {"Unarmored"},
    profession = {},
    combo = {"Aman'Thul", "Sargeras", "Khaz'goroth", "Norgannon", "Aggramar", "Golganneth"},
    role = {"Healer"},
    rarity = 2,
    cost = 9,
    index = 69,
    config = { extra = { bonus_chips = 5, bonus_chips_per_level = 1, bonus_chips_per_ilvl = 0.5 } },
    loc_txt = {
        "When you play a {C:attention}Pair{}, create a",
        "new card added to your deck:",
        "{C:attention}Left Card{}: Rank, Chips, Edition",
        "{C:attention}Right Card{}: Suit, Enhancement, Seal",
        "Child gains {C:chips}+#1#{}"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.bonus_chips, card.ability.extra.bonus_chips_per_level, card.ability.extra.bonus_chips_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            if context.scoring_name == "Pair" then
                local parent_A = context.scoring_hand[1]
                local parent_B = context.scoring_hand[2]
                local bonus = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.bonus_chips, card.ability.extra.bonus_chips_per_level, card.ability.extra.bonus_chips_per_ilvl))
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
                        -- Inherit parent_A's permanent chips + scaling bonus
                        local inherited = parent_A.ability.perma_bonus or 0
                        child.ability.perma_bonus = inherited + bonus
                        child:add_to_deck()
                        G.deck.config.card_limit = G.deck.config.card_limit + 1
                        table.insert(G.playing_cards, child)
                        G.hand:emplace(child)
                        child:juice_up()
                        card_eval_status_text(card, 'extra', nil, nil, nil, { message = "Life Created!", colour = G.C.GREEN })
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
    faction = {"Pantheon"},
    race = {"Titan"},
    weapon = {"Hammer"},
    damage = {"Nature"},
    armor = {"Plate"},
    profession = {},
    combo = {"Aman'Thul", "Sargeras", "Eonar", "Norgannon", "Aggramar", "Golganneth"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 7,
    index = 70,
    config = { extra = { steel_count = 3, steel_count_per_level = 0.2, steel_count_per_ilvl = 0.05 } },
    loc_txt = {
        "Before scoring, add {C:attention}#1#{} temporary",
        "{C:attention}Steel Cards{} of random value",
        "between {C:attention}2{} and {C:attention}5{}",
        "to the scored hand"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_steel
        return { Warcraft.get_scaled_gain(card, card.ability.extra.steel_count, card.ability.extra.steel_count_per_level, card.ability.extra.steel_count_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local effective_count = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.steel_count, card.ability.extra.steel_count_per_level, card.ability.extra.steel_count_per_ilvl))
            G.E_MANAGER:add_event(Event({
                func = function()
                    local suits = {"S", "H", "D", "C"}
                    local ranks = {"2", "3", "4", "5"}
                    for i = 1, effective_count do
                        local suit = pseudorandom_element(suits, pseudoseed('khaz_suit_' .. G.GAME.round .. '_' .. i))
                        local rank = pseudorandom_element(ranks, pseudoseed('khaz_rank_' .. G.GAME.round .. '_' .. i))
                        local card_key = suit .. "_" .. rank
                        local temp = create_card('Base', G.play, nil, nil, nil, nil, nil, 'khazgoroth')
                        temp:set_base(G.P_CARDS[card_key])
                        temp:set_ability(G.P_CENTERS.m_steel, nil, true)
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
    faction = {"Pantheon"},
    race = {"Titan"},
    class = {"Mage"},
    weapon = {"Staff"},
    damage = {"Arcane"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Aman'Thul", "Sargeras", "Khaz'goroth", "Eonar", "Aggramar", "Golganneth"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 6,
    index = 71,
    config = { extra = { 
        x_mult = 1.5, 
        x_mult_per_level = 0.1, 
        x_mult_per_ilvl = 0.05 
    }},
    loc_txt = {
        "Played cards with a {C:blue}Blue Seal{}",
        "give {X:mult,C:white} X#1# {} Mult",
        "when scored"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:get_seal() == 'Blue' then
                local effective_xmult = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl)
                return {
                    x_mult = effective_xmult,
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
    faction = {"Pantheon"},
    race = {"Titan"},
    class = {"Warrior"},
    weapon = {"Sword"},
    damage = {"Fire"},
    armor = {"Plate"},
    profession = {},
    combo = {"Aman'Thul", "Sargeras", "Khaz'goroth", "Norgannon", "Eonar", "Golganneth"},
    role = {"Melee DPS"},
    rarity = 1,
    cost = 2,
    index = 72,
    config = { extra = { mult = 2, mult_per_level = 1, mult_per_ilvl = 0.5 } },
    loc_txt = {
        "Held {C:attention}Steel Cards{}",
        "each give {C:mult}+#1#{} Mult"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.hand and not context.blueprint then
            if context.other_card.config.center.key == 'm_steel' and not context.other_card.debuff then
                return {
                    message = "Defense!",
                    h_mult = Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl),
                    card = context.other_card,
                    colour = G.C.RED 
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Golganneth",
    faction = {"Pantheon"},
    race = {"Titan"},
    class = {"Shaman"},
    weapon = {"Hammer"},
    damage = {"Nature"},
    armor = {"Mail"},
    profession = {},
    combo = {"Aman'Thul", "Sargeras", "Khaz'goroth", "Norgannon", "Aggramar", "Eonar"},
    role = {"Ranged DPS"},
    rarity = 1,
    cost = 3,
    index = 73,
    config = { extra = { base_chance = 10, chance_red_per_level = 0.1, chance_red_per_ilvl = 0.05 } },
    loc_txt = {
        "Played {C:clubs}Clubs{} have a",
        "{C:green}1 in #1#{} chance to",
        "gain a random {C:attention}Edition{}"
    },
    loc_vars = function(self, info_queue, card)
        return { math.max(1, Warcraft.get_scaled_gain(card, card.ability.extra.base_chance, -card.ability.extra.chance_red_per_level, -card.ability.extra.chance_red_per_ilvl)) }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:is_suit('Clubs') then
                local effective_denom = math.max(1, Warcraft.get_scaled_gain(card, card.ability.extra.base_chance, -card.ability.extra.chance_red_per_level, -card.ability.extra.chance_red_per_ilvl))
                if pseudorandom('golganneth') < (G.GAME.probabilities.normal / effective_denom) then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            local edition = poll_edition('golganneth', nil, true, true)
                            context.other_card:set_edition(edition, true, true)
                            context.other_card:juice_up()
                            return true
                        end
                    }))
                    return { message = "Storm!", colour = G.C.CHIPS, card = card }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Odyn",
    faction = {"Pantheon"},
    race = {"Titan"},
    class = {"Warrior"},
    weapon = {"Sword","Spear","Polearm"},
    damage = {"Fire"},
    armor = {"Plate"},
    profession = {},
    combo = {"Helya", "Aman'Thul", "Khaz'goroth", "Norgannon", "Aggramar", "Golganneth"},
    role = {"Tank"},
    rarity = 1,
    cost = 5,
    index = 74,
    config = { extra = { tags = 1, tags_per_level = 0.1, tags_per_ilvl = 0.05 } },
    loc_txt = {
        "If you win a Blind in",
        "exactly {C:attention}1 hand{},",
        "create {C:attention}#1#{} {C:attention}Double Tag(s){}"
    },
    loc_vars = function(self, info_queue, card)
        return { math.max(1, Warcraft.get_scaled_gain(card, card.ability.extra.tags, card.ability.extra.tags_per_level, card.ability.extra.tags_per_ilvl)) }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.repetition and not context.individual and not context.blueprint then
            if G.GAME.current_round.hands_played == 1 then
                local effective_tags = math.max(1, math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.tags, card.ability.extra.tags_per_level, card.ability.extra.tags_per_ilvl)))
                G.E_MANAGER:add_event(Event({
                    func = function()
                        for i = 1, effective_tags do
                            add_tag(Tag('tag_double'))
                        end
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
    faction = {"Pantheon"},
    race = {"Titan"},
    class = {"Warrior"},
    weapon = {"Hammer"},
    damage = {"Nature"},
    armor = {"Plate"},
    profession = {},
    combo = {"Aman'Thul", "Sargeras", "Khaz'goroth", "Norgannon", "Aggramar", "Golganneth"},
    role = {"Melee DPS"},
    rarity = 1,
    cost = 4,
    index = 75,
    config = { extra = { chips = 15, chips_per_level = 5, chips_per_ilvl = 2 } },
    loc_txt = {
        "If you play a {C:attention}High Card{},",
        "upgrade the {C:attention}rank{} of the card",
        "and gain {C:chips}+#1#{} permanent Chips."
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.chips, card.ability.extra.chips_per_level, card.ability.extra.chips_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            if context.scoring_name == "High Card" then
                local played_card = context.scoring_hand[1]
                local rank_id = played_card:get_id()

                if rank_id < 14 then
                    local bonus = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.chips, card.ability.extra.chips_per_level, card.ability.extra.chips_per_ilvl))
                    
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            -- Rank Up
                            local suffixes = {"2","3","4","5","6","7","8","9","T","J","Q","K","A"}
                            local new_key = string.sub(played_card.base.suit, 1, 1) .. "_" .. suffixes[rank_id]
                            if G.P_CARDS[new_key] then
                                played_card:set_base(G.P_CARDS[new_key])
                            end
                            
                            -- Perma Chip Gain
                            played_card.ability.perma_bonus = (played_card.ability.perma_bonus or 0) + bonus
                            
                            played_card:juice_up()
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
    faction = {"Pantheon"},
    race = {"Titan"},
    class = {"Paladin"},
    weapon = {"Hammer"},
    damage = {"Holy"},
    armor = {"Plate"},
    profession = {},
    combo = {"Aman'Thul", "Sargeras", "Khaz'goroth", "Norgannon", "Aggramar", "Golganneth"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 5,
    index = 76,
    config = { extra = { retrigger = 2, retrigger_per_level = 0.2, retrigger_per_ilvl = 0.1 } },
    loc_txt = {
        "Cards with Rank {C:attention}2, 3, or 4{}",
        "retrigger {C:attention}#1#{} additional time(s)"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.retrigger, card.ability.extra.retrigger_per_level, card.ability.extra.retrigger_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play and not context.repetition_only then
            local rank_id = context.other_card:get_id()
            if rank_id >= 2 and rank_id <= 4 then
                local effective_retrigger = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.retrigger, card.ability.extra.retrigger_per_level, card.ability.extra.retrigger_per_ilvl))
                return {
                    message = "Justice!",
                    repetitions = effective_retrigger,
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
    damage = {"Holy"},
    armor = {"Unarmored"},
    profession = {},
    combo = {"Tyrande Whisperwind", "Winter Queen", "Malfurion Stormrage"},
    role = {"Healer"},
    rarity = 3,
    cost = 9,
    index = 77,
    config = { extra = { 
        x_chips = 1, x_mult = 1, 
        base_gain = 0.2, gain_per_level = 0.1, gain_per_ilvl = 0.05 
    } },
    loc_txt = {
        "{X:chips,C:white} X#1# {} Chips  {X:mult,C:white} X#2# {} Mult",
        "Gains {X:chips,C:white} X#3# {} Chips when a",
        "{C:attention}Night Elf{} Joker is acquired",
        "Gains {X:mult,C:white} X#3# {} Mult when a",
        "{C:attention}Night Elf{} Joker is sold"
    },
    loc_vars = function(self, info_queue, card)
        local gain = Warcraft.get_scaled_gain(card, card.ability.extra.base_gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl)
        return { card.ability.extra.x_chips, card.ability.extra.x_mult, gain }
    end,
    calculate = function(self, card, context, stats, extra, joker_ret)
        local gain = Warcraft.get_scaled_gain(card, card.ability.extra.base_gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl)
        
        if context.playing_card_added and not context.blueprint then
            local added = context.card
            if added and added ~= card and Warcraft.is_race(added, "Night Elf") then
                card.ability.extra.x_chips = card.ability.extra.x_chips + gain
                return { message = "Moon's Grace!", colour = G.C.PURPLE, card = card }
            end
        end

        if context.selling_card and not context.blueprint then
            local sold = context.card
            if sold and sold ~= card and Warcraft.is_race(sold, "Night Elf") then
                card.ability.extra.x_mult = card.ability.extra.x_mult + gain
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
    damage = {"Nature"},
    armor = {"Plate"},
    profession = {},
    combo = {"Darkmaster Gandling", "Sylvanas Windrunner", "Sally Whitemane"},
    role = {"Melee DPS"},
    rarity = 1,
    cost = 3,
    index = 78,
    config = { extra = { mult = 5, gain = 3, gain_per_level = 3, gain_per_ilvl = 1 } },
    loc_txt = {
        "{C:mult}+#1#{} Mult",
        "{C:inactive}(Gains {C:mult}+#2#{C:inactive} Mult when",
        "any playing card is {C:attention}destroyed{}){}"
    },
    loc_vars = function(self, info_queue, card)
        return { 
            card.ability.extra.mult, 
            Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl) 
        }
    end,
    calculate = function(self, card, context, stats, extra, joker_ret)
        if context.remove_playing_cards and not context.blueprint then
            local destroyed_count = #context.removed
            if destroyed_count > 0 then
                local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl)
                card.ability.extra.mult = card.ability.extra.mult + (effective_gain * destroyed_count)
                return {
                    message = "Purge!",
                    colour = G.C.RED,
                    card = card
                }
            end
        end

        if context.joker_main then
            if card.ability.extra.mult > 0 then
                return {
                    mult = card.ability.extra.mult,
                    message = "Death!",
                    colour = G.C.RED,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Marin Noggenfogger",
    faction = {"Horde"},
    race = {"Goblin"},
    class = {"Rogue"},
    weapon = {"Daggers"},
    damage = {"Nature"},
    armor = {"Cloth"},
    profession = {"Alchemist"},
    combo = {"Gazlowe", "Trade Prince Gallywix", "Baron Revilgaz"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 5,
    index = 79,
    config = { extra = { base_chips = 20, chips_per_level = 20, chips_per_ilvl = 10 } },
    loc_txt = {
        "Played cards have a chance to transform:",
        "{C:green}25%{} become Rank {C:attention}King{},",
        "{C:red}25%{} become Rank {C:attention}2{},",
        "{C:chips}50%{} gain {C:chips}+#1#{} permanent Chips"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.base_chips, card.ability.extra.chips_per_level, card.ability.extra.chips_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local bonus = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.base_chips, card.ability.extra.chips_per_level, card.ability.extra.chips_per_ilvl))
            
            for _, played_card in ipairs(context.full_hand) do
                if played_card.config.center.key ~= 'm_stone' then
                    local roll = pseudorandom('noggenfogger_' .. G.GAME.round)
                    
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
                    
                    else
                        -- The 50% "Nothing" effect is now the Chip gain!
                        played_card.ability.perma_bonus = (played_card.ability.perma_bonus or 0) + bonus
                        played_card:juice_up()
                        card_eval_status_text(card, 'extra', nil, nil, nil, {message = "+" .. bonus .. " Chips!", colour = G.C.CHIPS})
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
    damage = {"Physical"},
    armor = {"Leather"},
    profession = {"Engineer"},
    combo = {"Marin Noggenfogger", "Trade Prince Gallywix", "Baron Revilgaz"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 5,
    index = 80,
    config = { extra = { base_money = 2, money_per_level = 0.5, money_per_ilvl = 0.25 } },
    loc_txt = {
        "Discarding a {C:attention}Face Card{}",
        "earns {C:money}$#1#{} and increases",
        "a random {C:attention}Joker's{} sell value",
        "by {C:money}$1{}."
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.base_money, card.ability.extra.money_per_level, card.ability.extra.money_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.discard and not context.blueprint then
            if context.other_card:is_face() then
                local money_gain = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.base_money, card.ability.extra.money_per_level, card.ability.extra.money_per_ilvl))
                
                G.E_MANAGER:add_event(Event({
                    func = function()
                        ease_dollars(money_gain)

                        if G.jokers and #G.jokers.cards > 0 then
                            local target = pseudorandom_element(G.jokers.cards, pseudoseed('gazlowe_' .. G.GAME.round))
                            target.ability.extra_value = (target.ability.extra_value or 0) + 1
                            target:set_cost()
                            card_eval_status_text(target, 'extra', nil, nil, nil, {
                                message = "+$1 Value!",
                                colour = G.C.MONEY
                            })
                            target:juice_up()
                        end
                        return true
                    end
                }))

                return {
                    message = "Deal!",
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
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {},
    combo = {"Marin Noggenfogger", "Gazlowe", "Baron Revilgaz", "Xal'atath", "Sylvanas Windrunner"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 5,
    index = 81,
    config = { extra = { money_limit = 0, base_money = 15, money_per_level = 2, money_per_ilvl = 1 } },
    loc_txt = {
        "If you end the shop with",
        "{C:money}$#1#{}, gain {C:money}$#2#{}"
    },
    loc_vars = function(self, info_queue, card)
        return { card.ability.extra.money_limit, Warcraft.get_scaled_gain(card, card.ability.extra.base_money, card.ability.extra.money_per_level, card.ability.extra.money_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.ending_shop and not context.blueprint then
            if G.GAME.dollars == card.ability.extra.money_limit then
                local effective_money = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.base_money, card.ability.extra.money_per_level, card.ability.extra.money_per_ilvl))
                
                G.E_MANAGER:add_event(Event({
                    func = function() 
                        ease_dollars(effective_money)
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
    weapon = {"Hammer","Gun"},
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {"Engineer"},
    combo = {"Anduin Wrynn", "Jaina Proudmoore", "Magni Bronzebeard", "Sicco Thermaplugg"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 8,
    index = 82,
    config = { extra = { used_this_blind = false, copies = 1, copies_per_level = 0.2, copies_per_ilvl = 0.1 } },
    loc_txt = {
        "If the {C:attention}first discard{} of the round",
        "is a {C:attention}single card{}, destroy it",
        "and create {C:attention}#1#{} {C:attention}Steel Copy(s){}",
        "in your hand"
    },
    loc_vars = function(self, info_queue, card)
        return { math.max(1, Warcraft.get_scaled_gain(card, card.ability.extra.copies, card.ability.extra.copies_per_level, card.ability.extra.copies_per_ilvl)) }
    end,
    calculate = function(self, card, context)
        if context.setting_blind then
            card.ability.extra.used_this_blind = false
        end

        if context.discard and not card.ability.extra.used_this_blind and not context.blueprint then
            card.ability.extra.used_this_blind = true
            
            if #context.full_hand == 1 then
                local discarded_card = context.other_card
                local effective_copies = math.max(1, math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.copies, card.ability.extra.copies_per_level, card.ability.extra.copies_per_ilvl)))
                
                G.E_MANAGER:add_event(Event({
                    func = function()
                        for i = 1, effective_copies do
                            local new_card = copy_card(discarded_card, nil, nil, G.playing_card)
                            new_card:set_ability(G.P_CENTERS.m_steel, nil, true)
                            new_card:add_to_deck()
                            G.deck.config.card_limit = G.deck.config.card_limit + 1
                            table.insert(G.playing_cards, new_card)
                            G.hand:emplace(new_card)
                            new_card:juice_up()
                        end
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
    damage = {"Physical"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Tickatus", "Madam Goya", "Burth"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 6,
    index = 83,
    config = { extra = { cards = 1, cards_per_level = 0.1, cards_per_ilvl = 0.05 } },
    loc_txt = {
        "When you {C:attention}Sell a Joker{},",
        "create {C:attention}#1#{} random",
        "{C:tarot}Tarot Card(s){}",
        "{C:inactive}(Must have room){}"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.cards, card.ability.extra.cards_per_level, card.ability.extra.cards_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.selling_card and not context.blueprint then
            
            if context.card.ability.set == 'Joker' then
                local effective_count = math.max(1, math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.cards, card.ability.extra.cards_per_level, card.ability.extra.cards_per_ilvl)))
                
                if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            for i = 1, effective_count do
                                if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                                    local new_card = create_card('Tarot', G.consumeables, nil, nil, nil, nil, nil, 'silas')
                                    new_card:add_to_deck()
                                    G.consumeables:emplace(new_card)
                                end
                            end
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
    damage = {"Frost"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Jaina Proudmoore", "Arthas Menethil", "Kel'Thuzad"},
    role = {"Ranged DPS"},
    rarity = 1,
    cost = 5,
    index = 84,
    config = { extra = { level_up = 1, level_up_per_level = 0.3, level_up_per_ilvl = 0.1 } },
    loc_txt = {
        "Each time a {C:tarot}Tarot{} card is used,",
        "upgrade a random",
        "{C:attention}Poker Hand{} by {C:attention}#1#{} level(s)"
    },
    loc_vars = function(self, info_queue, card)
        return { math.max(1, Warcraft.get_scaled_gain(card, card.ability.extra.level_up, card.ability.extra.level_up_per_level, card.ability.extra.level_up_per_ilvl)) }
    end,
    calculate = function(self, card, context)
        if context.using_consumeable and not context.blueprint then
            if context.consumeable.ability.set == "Tarot" then
                
                local hands = {}
                for hand_name, _ in pairs(G.GAME.hands) do
                    table.insert(hands, hand_name)
                end

                if #hands > 0 then
                    local chosen = pseudorandom_element(hands, pseudoseed('antonidas_' .. G.GAME.round))
                    local gain = math.max(1, math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.level_up, card.ability.extra.level_up_per_level, card.ability.extra.level_up_per_ilvl)))
                    
                    level_up_hand(card, chosen, false, gain)

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
    damage = {"Piercing"},
    armor = {"Leather"},
    profession = {},
    combo = {"Sylvanas Windrunner", "Malfurion Stormrage", "Tyrande Whisperwind"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 5,
    index = 85,
    config = { extra = { base_money = 4, money_per_level = 1, money_per_ilvl = 0.5, target_rank = 'Ace' } },
    loc_txt = {
        "When you discard a {C:attention}#1#{},",
        "gain {C:money}$#2#{}",
        "{C:inactive}(Target changes every Blind){}"
    },
    loc_vars = function(self, info_queue, card)
        return { 
            card.ability.extra.target_rank, 
            Warcraft.get_scaled_gain(card, card.ability.extra.base_money, card.ability.extra.money_per_level, card.ability.extra.money_per_ilvl) 
        }
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            local ranks = {'2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King', 'Ace'}
            card.ability.extra.target_rank = pseudorandom_element(ranks, pseudoseed('nathanos_' .. G.GAME.round))
            card_eval_status_text(card, 'extra', nil, nil, nil, {
                message = "New Bounty: " .. card.ability.extra.target_rank,
                colour = G.C.RED
            })
        end

        if context.discard and not context.blueprint then
            if context.other_card.base.value == card.ability.extra.target_rank then
                local effective_money = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.base_money, card.ability.extra.money_per_level, card.ability.extra.money_per_ilvl))
                
                G.E_MANAGER:add_event(Event({
                    func = function() 
                        ease_dollars(effective_money)
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
    damage = {"Shadow"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Gul'dan", "C'Thun", "Med'an", "Blackhand", "Ragnaros", "Kilrogg Deadeye", "Orgrim Doomhammer", "Deathwing"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 8,
    index = 86,
    config = { extra = { base_chance = 5, chance_per_level = 0.1, chance_per_ilvl = 0.05 } },
    loc_txt = {
        "When you use a {C:tarot}Tarot{} or {C:planet}Planet{},",
        "{C:green}1 in #1#{} chance to add",
        "a copy to your consumable area",
        "{C:inactive}(Must have room){}"
    },
    loc_vars = function(self, info_queue, card)
        return { math.max(1, Warcraft.get_scaled_gain(card, card.ability.extra.base_chance, -card.ability.extra.chance_per_level, -card.ability.extra.chance_per_ilvl)) }
    end,
    calculate = function(self, card, context)
        if context.using_consumeable and not context.blueprint then
            local c_type = context.consumeable.ability.set
            if c_type == 'Tarot' or c_type == 'Planet' then
                
                local denom = math.max(1, Warcraft.get_scaled_gain(card, card.ability.extra.base_chance, -card.ability.extra.chance_per_level, -card.ability.extra.chance_per_ilvl))
                
                if pseudorandom('chogall') < (G.GAME.probabilities.normal / denom) then
                    
                    if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                        G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                        
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                local new_card = copy_card(context.consumeable, nil, nil, nil, nil)
                                new_card:add_to_deck()
                                G.consumeables:emplace(new_card)
                                G.GAME.consumeable_buffer = 0
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
    damage = {"Nature"},
    armor = {"Mail"},
    profession = {},
    combo = {"Vanndar Stormpike", "Thrall", "Blackhand", "Durotan", "Ner'zhul", "Orgrim Doomhammer"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 7,
    index = 87,
    config = { extra = { mult = 5, mult_per_level = 1, mult_per_ilvl = 0.5 } },
    loc_txt = {
        "If played hand contains a {C:attention}Pair{},",
        "retrigger all scoring cards",
        "and they give {C:mult}+#1#{} Mult"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl) }
    end,
    calculate = function(self, card, context)
        local function hand_contains_pair()
            return context.poker_hands and context.poker_hands["Pair"] and next(context.poker_hands["Pair"]) ~= nil
        end

        local effective_mult = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl))

        if context.repetition and context.cardarea == G.play then
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
                    mult = effective_mult,
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
    damage = {"Physical"},
    armor = {"Unarmored"},
    profession = {},
    combo = {"Thrall", "Grommash Hellscream", "Y'Shaarj"},
    role = {"Tank"},
    rarity = 1,
    cost = 6,
    index = 88,
    config = { extra = { 
        hand_gain = 1, hand_gain_level = 0.2, 
        discard_gain = 1, discard_gain_ilvl = 0.1, 
        mult = 0 
    } },
    loc_txt = {
        "Gains {C:mult}+#1#{} Mult per {C:attention}Hand{} and",
        "{C:mult}+#2#{} Mult per {C:attention}Discard{} remaining",
        "when Blind is defeated.",
        "{C:inactive}(Currently {C:mult}+#3#{C:inactive} Mult){}"
    },
    loc_vars = function(self, info_queue, card)
        return { 
            Warcraft.get_scaled_gain(card, card.ability.extra.hand_gain, card.ability.extra.hand_gain_level, 0),
            Warcraft.get_scaled_gain(card, card.ability.extra.discard_gain, 0, card.ability.extra.discard_gain_ilvl),
            card.ability.extra.mult 
        }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.blueprint and not (context.individual or context.repetition) then
            local hand_gain = Warcraft.get_scaled_gain(card, card.ability.extra.hand_gain, card.ability.extra.hand_gain_level, 0)
            local disc_gain = Warcraft.get_scaled_gain(card, card.ability.extra.discard_gain, 0, card.ability.extra.discard_gain_ilvl)
            
            local bonus = (G.GAME.current_round.hands_left * hand_gain) + (G.GAME.current_round.discards_left * disc_gain)
            
            if bonus > 0 then
                card.ability.extra.mult = card.ability.extra.mult + math.floor(bonus)
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
    damage = {"Physical"},
    armor = {"Leather"},
    profession = {},
    combo = {"Sha of Fear", "Sha of Anger", "Sha of Doubt", "Sha of Despair", "Sha of Hatred", "Sha of Pride", "Sha of Violence"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 6,
    index = 89,
    config = { extra = { base_level = 1, level_gain_per_level = 1, level_gain_per_ilvl = 0.5 } },
    loc_txt = {
        "At the start of each {C:attention}Blind{},",
        "summon a random {C:attention}Sha{} Joker",
        "with {C:attention}+#1#{} Levels"
    },
    loc_vars = function(self, info_queue, card)
        return { math.max(0, Warcraft.get_scaled_gain(card, card.ability.extra.base_level, card.ability.extra.level_gain_per_level, card.ability.extra.level_gain_per_ilvl)) }
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            
            local sha_pool = {}
            for key, center in pairs(G.P_CENTERS) do
                if center.config and type(center.config.extra) == "table" then
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

            if #sha_pool > 0 and #G.jokers.cards < G.jokers.config.card_limit then
                local level_bonus = math.max(0, math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.base_level, card.ability.extra.level_gain_per_level, card.ability.extra.level_gain_per_ilvl)))
                
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local chosen_key = pseudorandom_element(sha_pool, pseudoseed('shaohao_' .. G.GAME.round))
                        local sha = create_card('Joker', G.jokers, nil, nil, nil, nil, chosen_key, 'shaohao')
                        
                        -- Apply the scaling to the new Joker's level
                        sha.ability.extra.level = (sha.ability.extra.level or 1) + level_bonus
                        
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
    end
})

Warcraft.create_warcraft_joker({
    name = "Li Li Stormstout",
    faction = {"Alliance","Horde"},
    race = {"Pandaren"},
    class = {"Monk"},
    weapon = {"Staff","Fist"},
    damage = {"Physical"},
    armor = {"Leather"},
    profession = {"Herbalist"},
    combo = {"Chen Stormstout", "Ji Firepaw", "Aysa Cloudsinger", "Taoshi"},
    role = {"Healer"},
    rarity = 1,
    cost = 2,
    index = 90,
    config = { extra = { h_size = 2, h_size_level = 0.1, h_size_ilvl = 0.05, current_bonus = 2 } },
    loc_txt = {
        "{C:attention}+#1#{} Hand Size"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.h_size, card.ability.extra.h_size_level, card.ability.extra.h_size_ilvl) }
    end,
    add_to_deck = function(self, card, from_debuff)
        local bonus = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.h_size, card.ability.extra.h_size_level, card.ability.extra.h_size_ilvl))
        card.ability.extra.current_bonus = bonus
        G.hand:change_size(bonus)
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.hand:change_size(-card.ability.extra.current_bonus)
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.repetition and not context.individual and not context.blueprint then
            local bonus = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.h_size, card.ability.extra.h_size_level, card.ability.extra.h_size_ilvl))
            if bonus ~= card.ability.extra.current_bonus then
                G.hand:change_size(bonus - card.ability.extra.current_bonus)
                card.ability.extra.current_bonus = bonus
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Lorewalker Cho",
    faction = {"Alliance","Horde"},
    race = {"Pandaren"},
    class = {"Monk"},
    weapon = {"Staff","Fist"},
    damage = {"Physical"},
    armor = {"Cloth"},
    profession = {"Archaeologist"},
    combo = {"Brann Bronzebeard", "Chen Stormstout", "Li Li Stormstout"},
    role = {"Healer"},
    rarity = 1,
    cost = 5,
    index = 91,
    config = { extra = { tags = 1, tags_per_level = 0.1, tags_per_ilvl = 0.1 } },
    loc_txt = {
        "When you {C:attention}Skip a Blind{},",
        "create {C:attention}#1#{} {C:attention}Double Tag(s){}"
    },
    loc_vars = function(self, info_queue, card)
        return { math.max(1, math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.tags, card.ability.extra.tags_per_level, card.ability.extra.tags_per_ilvl))) }
    end,
    calculate = function(self, card, context)
        if context.skip_blind and not context.blueprint then
            local effective_tags = math.max(1, math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.tags, card.ability.extra.tags_per_level, card.ability.extra.tags_per_ilvl)))
            G.E_MANAGER:add_event(Event({
                func = function()
                    for i = 1, effective_tags do
                        add_tag(Tag('tag_double'))
                    end
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
    damage = {"Fire"},
    armor = {"Leather"},
    profession = {},
    combo = {"Aysa Cloudsinger", "Chen Stormstout", "Li Li Stormstout"},
    role = {"Melee DPS"},
    rarity = 1,
    cost = 3,
    index = 92,
    config = { extra = { mult = 4, mult_per_level = 1, mult_per_ilvl = 0.5 } },
    loc_txt = {
        "Played {C:hearts}Hearts{} give",
        "{C:mult}+#1#{} Mult when scored"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:is_suit("Hearts") then
                return {
                    mult = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl)),
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
    damage = {"Frost"},
    armor = {"Leather"},
    profession = {},
    combo = {"Ji Firepaw", "Chen Stormstout", "Li Li Stormstout"},
    role = {"Melee DPS"},
    rarity = 1,
    cost = 3,
    index = 93,
    config = { extra = { mult = 4, mult_per_level = 1, mult_per_ilvl = 0.5 } },
    loc_txt = {
        "Played {C:clubs}Clubs{} give",
        "{C:mult}+#1#{} Mult when scored"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:is_suit("Clubs") then
                return {
                    mult = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl)),
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
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {},
    combo = {"Garrosh Hellscream", "Baine Bloodhoof", "Thrall", "Jaine Proudmoore", "Magatha Grimtotem"},
    role = {"Tank"},
    rarity = 3,
    cost = 8,
    index = 94,
    config = { extra = { base_pct = 50, pct_per_level = 7, pct_per_ilvl = 3 } },
    loc_txt = {
        "{C:attention}Prevents Death{} if chips",
        "are less than required.",
        "{C:red}Self Destructs{}, add",
        "{C:chips}+#1#%{} of Blind chips"
    },
    loc_vars = function(self, info_queue, card)
        return { math.min(100, Warcraft.get_scaled_gain(card, card.ability.extra.base_pct, card.ability.extra.pct_per_level, card.ability.extra.pct_per_ilvl)) }
    end,
    calculate = function(self, card, context)
        if context.game_over and not context.blueprint then
            if G.GAME.chips < G.GAME.blind.chips then
                local pct = math.min(100, Warcraft.get_scaled_gain(card, card.ability.extra.base_pct, card.ability.extra.pct_per_level, card.ability.extra.pct_per_ilvl)) / 100
                local chip_gain = math.floor(G.GAME.blind.chips * pct)

                G.E_MANAGER:add_event(Event({
                    func = function()
                        G.hand_text_area.blind_chips:juice_up()
                        G.hand_text_area.game_chips:juice_up()
                        play_sound('tarot1')
                        G.GAME.chips = G.GAME.chips + chip_gain
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
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {},
    combo = {"Cairne Bloodhoof", "Thrall", "Jaina Proudmoore", "Sylvanas Windrunner", "Zovaal"},
    role = {"Tank"},
    rarity = 2,
    cost = 7,
    index = 95,
    config = { extra = { base_xmult = 1.5, scale_level = 0.1, scale_ilvl = 0.1 } },
    loc_txt = {
        "Each {C:attention}Wild Card{} held in hand",
        "gives {X:mult,C:white} X#1# {} Mult"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.base_xmult, card.ability.extra.scale_level, card.ability.extra.scale_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.hand and not context.end_of_round then
            if context.other_card.config.center.key == 'm_wild' and not context.other_card.debuff then
                return {
                    message = "Earthmother!",
                    x_mult = Warcraft.get_scaled_gain(card, card.ability.extra.base_xmult, card.ability.extra.scale_level, card.ability.extra.scale_ilvl),
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
    damage = {"Nature"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Garrosh Hellscream", "Cairne Bloodhoof", "Baine Bloodhoof", "Broll Bearmantle"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 6,
    index = 96,
    config = { extra = { 
        mult = 0, money_reduce = 1, 
        base_mult_gain = 1, mult_gain_per_level = 1, mult_gain_per_ilvl = 0.5 
    } },
    loc_txt = {
        "{C:mult}+#1#{} Mult",
        "At end of round, reduce the",
        "{C:attention}Sell Value{} of all Jokers by {C:money}$1{}",
        "and gain {C:mult}+#2#{} Mult for each $1 lost"
    },
    loc_vars = function(self, info_queue, card)
        return { 
            card.ability.extra.mult, 
            Warcraft.get_scaled_gain(card, card.ability.extra.base_mult_gain, card.ability.extra.mult_gain_per_level, card.ability.extra.mult_gain_per_ilvl) 
        }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.repetition and not context.individual and not context.blueprint then
            local value_drained = 0
            for i = 1, #G.jokers.cards do
                local target_joker = G.jokers.cards[i]
                if target_joker.sell_cost > 0 then
                    target_joker.ability.extra_value = (target_joker.ability.extra_value or 0) - card.ability.extra.money_reduce
                    target_joker:set_cost()
                    value_drained = value_drained + card.ability.extra.money_reduce
                    target_joker:juice_up()
                end
            end
            
            if value_drained > 0 then
                local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.base_mult_gain, card.ability.extra.mult_gain_per_level, card.ability.extra.mult_gain_per_ilvl)
                card.ability.extra.mult = card.ability.extra.mult + (value_drained * effective_gain)
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
    weapon = {"Staff", "Fist"},
    damage = {"Nature"},
    armor = {"Leather"},
    profession = {},
    combo = {"Guff Runetotem", "Malfurion Stormrage", "Ragnaros", "Deathwing", "Xavius", "Cairne Bloodhoof"},
    role = {"Healer"},
    rarity = 2,
    cost = 6,
    index = 97,
    config = { extra = { base_cards = 1, cards_per_level = 0.2, cards_per_ilvl = 0.1, used_this_blind = false } },
    loc_txt = {
        "On the {C:attention}first hand{} of each Blind,",
        "turn {C:attention}#1#{} random {C:attention}scoring card(s){}",
        "into {C:attention}Wild Cards{}"
    },
    loc_vars = function(self, info_queue, card)
        return { math.max(1, Warcraft.get_scaled_gain(card, card.ability.extra.base_cards, card.ability.extra.cards_per_level, card.ability.extra.cards_per_ilvl)) }
    end,
    calculate = function(self, card, context)
        if context.setting_blind then
            card.ability.extra.used_this_blind = false
        end

        if context.before and not context.blueprint then
            if not card.ability.extra.used_this_blind and context.scoring_hand and #context.scoring_hand > 0 then
                card.ability.extra.used_this_blind = true
                
                local effective_count = math.max(1, math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.base_cards, card.ability.extra.cards_per_level, card.ability.extra.cards_per_ilvl)))
                
                G.E_MANAGER:add_event(Event({
                    func = function()
                        for i = 1, effective_count do
                            local target_card = pseudorandom_element(context.scoring_hand, pseudoseed('hamuul_' .. G.GAME.round .. '_' .. i))
                            if target_card then
                                target_card:set_ability(G.P_CENTERS.m_wild, nil, true)
                                target_card:juice_up()
                            end
                        end
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
})

Warcraft.create_warcraft_joker({
    name = "Zul'jin",
    race = {"Troll"},
    class = {"Hunter"},
    weapon = {"Axe","Sword"},
    damage = {"Physical"},
    armor = {"Leather"},
    profession = {},
    combo = {"Thrall", "Vol'jin", "Zalazane"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 6,
    index = 98,
    config = { extra = { 
        base_mult = 30, mult_per_level = 4, 
        base_discard = 2, discard_per_ilvl = -0.1 
    } },
    loc_txt = {
        "{C:mult}+#1#{} Mult",
        "{C:red}-#2#{} Discards"
    },
    loc_vars = function(self, info_queue, card)
        return { 
            Warcraft.get_scaled_gain(card, card.ability.extra.base_mult, card.ability.extra.mult_per_level, 0),
            Warcraft.get_scaled_gain(card, card.ability.extra.base_discard, 0, card.ability.extra.discard_per_ilvl)
        }
    end,
    add_to_deck = function(self, card, from_debuff)
        local effective_discard = Warcraft.get_scaled_gain(card, card.ability.extra.base_discard, 0, card.ability.extra.discard_per_ilvl)
        G.GAME.round_resets.discards = G.GAME.round_resets.discards - effective_discard
        if G.GAME.current_round.discards_left then
            G.GAME.current_round.discards_left = math.max(0, G.GAME.current_round.discards_left - effective_discard)
        end
    end,
    remove_from_deck = function(self, card, from_debuff)
        local effective_discard = Warcraft.get_scaled_gain(card, card.ability.extra.base_discard, 0, card.ability.extra.discard_per_ilvl)
        G.GAME.round_resets.discards = G.GAME.round_resets.discards + effective_discard
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.base_mult, card.ability.extra.mult_per_level, 0)
            return {
                mult = effective_mult,
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
    damage = {"Piercing"},
    armor = {"Leather"},
    profession = {},
    combo = {"Thrall", "Sylvanas Windrunner", "Zul'jin", "Varian Wrynn"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 5,
    index = 99,
    config = { extra = { base_chips = 100, chips_per_level = 30, chips_per_ilvl = 30 } },
    loc_txt = {
        "{C:chips}+#1#{} Chips",
        "When {C:attention}sold{} or {C:attention}destroyed{},",
        "transfer all {C:attention}levels{} to the",
        "joker directly to the {C:attention}right{}"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.base_chips, card.ability.extra.chips_per_level, card.ability.extra.chips_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local effective_chips = Warcraft.get_scaled_gain(card, card.ability.extra.base_chips, card.ability.extra.chips_per_level, card.ability.extra.chips_per_ilvl)
            return {
                chips = effective_chips,
                card = card
            }
        end

        -- Trigger exactly when sold or when destroyed
        if (context.selling_self or (context.joker_type_destroyed and context.card == card)) 
        and not context.blueprint and not card.ability.extra.voljin_triggered then
            
            local voljin_idx = nil
            if G.jokers and G.jokers.cards then
                for i, j in ipairs(G.jokers.cards) do
                    if j == card then
                        voljin_idx = i
                        break
                    end
                end
            end

            if voljin_idx and G.jokers.cards[voljin_idx + 1] then
                local target = G.jokers.cards[voljin_idx + 1]
                if target.ability and target.ability.extra and target.ability.extra.level then
                    local levels_to_give = card.ability.extra.level or 1
                    
                    -- Safety flag so it doesn't double-trigger if multiple contexts fire
                    card.ability.extra.voljin_triggered = true

                    G.E_MANAGER:add_event(Event({
                        func = function()
                            target.ability.extra.level = (target.ability.extra.level or 1) + levels_to_give
                            
                            -- Ensure max_level keeps up with the new level
                            if target.ability.extra.max_level and target.ability.extra.level > target.ability.extra.max_level then
                                target.ability.extra.max_level = target.ability.extra.level
                            end
                            
                            card_eval_status_text(target, 'extra', nil, nil, nil, {
                                message = "Loa's Blessing!",
                                colour = G.C.GREEN
                            })
                            target:juice_up()
                            return true
                        end
                    }))
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Rokhan",
    faction = {"Horde"},
    race = {"Troll"},
    class = {"Hunter"},
    weapon = {"Daggers","Bow"},
    damage = {"Piercing"},
    armor = {"Leather"},
    profession = {},
    combo = {"Rexxar", "Thrall", "Daelin Proudmoore", "Jaina Proudmoore"},
    role = {"Healer"},
    rarity = 2,
    cost = 6,
    index = 100,
    config = { extra = { base_chance = 4, chance_red_per_level = 0.1, chance_red_per_ilvl = 0.1 } },
    loc_txt = {
        "{C:green}1 in #1#{} chance to create a",
        "{C:tarot}Tarot Card{} if played hand",
        "contains {C:attention}only Face Cards{}"
    },
    loc_vars = function(self, info_queue, card)
        return { math.max(1, Warcraft.get_scaled_gain(card, card.ability.extra.base_chance, -card.ability.extra.chance_red_per_level, -card.ability.extra.chance_red_per_ilvl)) }
    end,
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
                local effective_denom = math.max(1, Warcraft.get_scaled_gain(card, card.ability.extra.base_chance, -card.ability.extra.chance_red_per_level, -card.ability.extra.chance_red_per_ilvl))
                
                if pseudorandom('rokhan') < (G.GAME.probabilities.normal / effective_denom) then
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
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {},
    combo = {"Princess Talanji", "Bwonsamdi", "Prophet Zul", "Jaina Proudmoore"},
    role = {"Tank"},
    rarity = 1,
    cost = 4,
    index = 101,
    config = { extra = { base_retrigger = 1, retrigger_per_level = 0.3, retrigger_per_ilvl = 0.3 } },
    loc_txt = {
        "{C:attention}Kings{} retrigger",
        "{C:attention}#1#{} additional time(s)"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.base_retrigger, card.ability.extra.retrigger_per_level, card.ability.extra.retrigger_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.cardarea == G.play and context.repetition and not context.repetition_only then
            if context.other_card:get_id() == 13 then
                local reps = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.base_retrigger, card.ability.extra.retrigger_per_level, card.ability.extra.retrigger_per_ilvl))
                return {
                    message = "Zandalar Forever!",
                    repetitions = reps,
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
    damage = {"Shadow"},
    armor = {"Leather"},
    profession = {},
    combo = {"King Rastakhan", "Mueh'zala", "Princess Talanji"},
    role = {"Ranged DPS"},
    rarity = 3,
    cost = 10,
    index = 102,
    config = { extra = { x_mult = 1, gain = 0.1, gain_per_level = 0.05, gain_per_ilvl = 0.025 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "Gains {X:mult,C:white} X#2# {} Mult",
        "each time a {C:attention}Joker{} is sold"
    },
    loc_vars = function(self, info_queue, card)
        return { 
            card.ability.extra.x_mult, 
            Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl) 
        }
    end,
    add_to_deck = function(self, card, from_debuff)
        local already_sold = G.GAME.warcraft_jokers_sold or 0
        if already_sold > 0 then
            local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl)
            card.ability.extra.x_mult = 1 + (already_sold * effective_gain)
            card_eval_status_text(card, 'extra', nil, nil, nil, {
                message = "Da Collection!",
                colour = G.C.PURPLE
            })
        end
    end,
    calculate = function(self, card, context)
        if context.selling_card and not context.blueprint then
            local sold = context.card
            if sold and sold.ability and sold.ability.set == "Joker" then
                local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl)
                card.ability.extra.x_mult = card.ability.extra.x_mult + effective_gain
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
                    Xmult_mod = card.ability.extra.x_mult,
                    colour = G.C.PURPLE,
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
    damage = {"Holy"},
    armor = {"Plate"},
    profession = {},
    combo = {"Onyxia", "Nefarian", "Katrana Prestor"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 5,
    index = 103,
    config = { extra = { base_chips = 100, chips_per_level = 40, chips_per_ilvl = 30 } },
    loc_txt = {
        "{C:chips}+#1#{} Chips",
        "{C:red}Discards entire hand{}",
        "after playing"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.base_chips, card.ability.extra.chips_per_level, card.ability.extra.chips_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                chips = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.base_chips, card.ability.extra.chips_per_level, card.ability.extra.chips_per_ilvl)),
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
    faction = {"Pirate"},
    race = {"Human"},
    class = {"Rogue"},
    weapon = {"Daggers","Sword"},
    damage = {"Physical"},
    armor = {"Leather"},
    profession = {},
    combo = {"Captain Greenskin", "Vanessa VanCleef", "Sneed", "Mr. Smite"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 6,
    index = 104,
    config = { extra = { mult = 2, gain = 0.5, gain_per_level = 0.2, gain_per_ilvl = 0.1 } },
    loc_txt = {
        "{C:mult}+#1#{} Mult",
        "{C:inactive}(Gains {C:mult}+#2#{} Mult for",
        "every {C:attention}scoring card{} played){}"
    },
    loc_vars = function(self, info_queue, card)
        return { 
            card.ability.extra.mult, 
            Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl) 
        }
    end,
    calculate = function(self, card, context)
        if context.before and context.cardarea == G.jokers and not context.blueprint then
            local count = #context.scoring_hand
            if count > 0 then
                local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl)
                card.ability.extra.mult = card.ability.extra.mult + (effective_gain * count)
                return {
                    message = "Combo!",
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
    name = "Prince Malchezaar",
    faction = {"Legion"},
    race = {"Demon"},
    class = {"Warlock"},
    weapon = {"Axe"},
    damage = {"Shadow"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Archimonde", "Medivh", "Khadgar"},
    role = {"Ranged DPS"},
    rarity = 3,
    cost = 8,
    index = 105,
    config = { extra = { count = 5, count_per_level = 0.2, count_per_ilvl = 0.2 } },
    loc_txt = {
        "When {C:attention}Boss Blind{} is defeated,",
        "add {C:attention}#1#{} Random Enhanced",
        "cards to your deck"
    },
    loc_vars = function(self, info_queue, card)
        return { math.max(1, Warcraft.get_scaled_gain(card, card.ability.extra.count, card.ability.extra.count_per_level, card.ability.extra.count_per_ilvl)) }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.repetition and not context.individual and not context.blueprint then
            if G.GAME.blind.boss then
                local effective_count = math.max(1, math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.count, card.ability.extra.count_per_level, card.ability.extra.count_per_ilvl)))
                
                G.E_MANAGER:add_event(Event({
                    func = function() 
                        for i = 1, effective_count do
                            local _card = create_card('Base', G.pack_cards, nil, nil, true, true, nil, 'malchezaar')
                            local edition = poll_edition('malchezaar_ed', nil, true, true)
                            _card:set_edition(edition, true)
                            local enhancement = pseudorandom_element(G.P_CENTER_POOLS.Enhanced, pseudoseed('malchezaar_' .. G.GAME.round))
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
    damage = {"Shadow", "Frost"},
    armor = {"Plate"},
    profession = {},
    combo = {"Tirion Fordring", "Sylvanas Windrunner", "Thrall", "Jaina Proudmoore", "Baine Bloodhoof", "Anduin Wrynn", "Lich King", "Arthas Menethil", "Grand Apothecary Putress"},
    role = {"Tank"},
    rarity = 2,
    cost = 6,
    index = 106,
    config = { extra = { base_mult = 1, mult_per_level = 0.25, mult_per_ilvl = 0.25 } },
    loc_txt = {
        "{C:attention}Stone Cards{} permanently",
        "gain {C:mult}+#1#{} Mult when scored"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.base_mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card.config.center.key == 'm_stone' then
                local bonus = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.base_mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl))
                
                context.other_card.ability.perma_mult = (context.other_card.ability.perma_mult or 0) + bonus
                
                return {
                    mult = context.other_card.ability.perma_mult,
                    message = "Upgrade!",
                    colour = G.C.MULT,
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
    damage = {"Holy"},
    armor = {"Plate"},
    profession = {},
    combo = {"Alleria Windrunner", "Arator the Redeemer", "Illidan Stormrage", "Prophet Velen", "Danath Trollbane"},
    role = {"Melee DPS"},
    rarity = 1,
    cost = 4,
    index = 107,
    config = { extra = { 
        base_chips = 50, chips_per_level = 15, chips_per_ilvl = 0,
        base_mult = 5, mult_per_level = 0, mult_per_ilvl = 0.5 
    } },
    loc_txt = {
        "Scoring {C:money}Gold Cards{} give",
        "{C:chips}+#1#{} Chips and {C:mult}+#2#{} Mult"
    },
    loc_vars = function(self, info_queue, card)
        return { 
            Warcraft.get_scaled_gain(card, card.ability.extra.base_chips, card.ability.extra.chips_per_level, card.ability.extra.chips_per_ilvl),
            Warcraft.get_scaled_gain(card, card.ability.extra.base_mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl) 
        }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card.config.center.key == 'm_gold' then
                local eff_chips = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.base_chips, card.ability.extra.chips_per_level, card.ability.extra.chips_per_ilvl))
                local eff_mult = Warcraft.get_scaled_gain(card, card.ability.extra.base_mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl)
                
                return {
                    chips = eff_chips,
                    mult = eff_mult,
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
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {},
    combo = {"Turalyon", "Khadgar", "Alleria Windrunner", "Kurdran Wildhammer", "Kilrogg Deadeye", "Ner'zhul", "Eitrigg", "Mathias Shaw"},
    role = {"Melee DPS"},
    rarity = 1,
    cost = 3,
    index = 108,
    config = { extra = { base_gain = 50, gain_per_level = 30, gain_per_ilvl = 20 } },
    loc_txt = {
        "{C:chips}+#1#{} Chips",
        "{C:inactive}(+#2# per Ante completed){}"
    },
    loc_vars = function(self, info_queue, card)
        local gain = Warcraft.get_scaled_gain(card, card.ability.extra.base_gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl)
        local current_bonus = gain * math.max(0, G.GAME.round_resets.ante - 1)
        return { current_bonus, gain }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local gain = Warcraft.get_scaled_gain(card, card.ability.extra.base_gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl)
            return {
                chips = gain * math.max(0, G.GAME.round_resets.ante - 1),
                card = card
            }
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Mathias Shaw",
    faction = {"Alliance"},
    race = {"Human"},
    class = {"Rogue"},
    weapon = {"Daggers","Sword"},
    damage = {"Physical"},
    armor = {"Leather"},
    profession = {},
    combo = {"Anduin Wrynn", "Genn Greymane", "Danath Trollbane"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 8,
    index = 109,
    config = { extra = { base_slots = 1, slots_per_level = 0.1, slots_per_ilvl = 0.05, current_bonus = 1 } },
    loc_txt = {
        "{C:dark_edition}+#1#{} Joker Slot"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.base_slots, card.ability.extra.slots_per_level, card.ability.extra.slots_per_ilvl) }
    end,
    add_to_deck = function(self, card, from_debuff)
        local bonus = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.base_slots, card.ability.extra.slots_per_level, card.ability.extra.slots_per_ilvl))
        card.ability.extra.current_bonus = bonus
        G.jokers:change_size(bonus)
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.jokers:change_size(-card.ability.extra.current_bonus)
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.repetition and not context.individual and not context.blueprint then
            local bonus = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.base_slots, card.ability.extra.slots_per_level, card.ability.extra.slots_per_ilvl))
            if bonus ~= card.ability.extra.current_bonus then
                G.jokers:change_size(bonus - card.ability.extra.current_bonus)
                card.ability.extra.current_bonus = bonus
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Genn Greymane",
    faction = {"Alliance"},
    race = {"Worgen"},
    class = {"Warrior"},
    weapon = {"Sword","Gun","Claw"},
    damage = {"Piercing"},
    armor = {"Leather"},
    profession = {},
    combo = {"Anduin Wrynn", "Tess Greymane", "Sylvanas Windrunner", "Mathias Shaw"},
    role = {"Melee DPS"},
    rarity = 1,
    cost = 6,
    index = 110,
    config = { extra = { 
        base_mult = 4, mult_per_level = 0.5, mult_per_ilvl = 0,
        base_chips = 20, chips_per_level = 0, chips_per_ilvl = 3 
    } },
    loc_txt = {
        "Played cards with {C:attention}Even Rank{}",
        "{C:mult}+#1#{} Mult and {C:chips}+#2#{} Chips"
    },
    loc_vars = function(self, info_queue, card)
        return { 
            Warcraft.get_scaled_gain(card, card.ability.extra.base_mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl),
            Warcraft.get_scaled_gain(card, card.ability.extra.base_chips, card.ability.extra.chips_per_level, card.ability.extra.chips_per_ilvl) 
        }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and card.ability.triggered_this_hand then
            local id = context.other_card:get_id()
            if id and id >= 2 and id <= 10 and id % 2 == 0 then
                return {
                    mult = Warcraft.get_scaled_gain(card, card.ability.extra.base_mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl),
                    chips = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.base_chips, card.ability.extra.chips_per_level, card.ability.extra.chips_per_ilvl)),
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
    damage = {"Piercing"},
    armor = {"Leather"},
    profession = {},
    combo = {"Genn Greymane", "Sylvanas Windrunner", "Anduin Wrynn"},
    role = {"Melee DPS"},
    rarity = 3,
    cost = 10,
    index = 111,
    config = { extra = { base_copies = 1, copies_per_level = 0.1, copies_per_ilvl = 0.05 } },
    loc_txt = {
        "When {C:attention}Sold{}, create {C:attention}#1#{} copy(s)",
        "of the {C:attention}left-most Joker{}",
        "{C:inactive}(Excluding Tess Greymane){}"
    },
    loc_vars = function(self, info_queue, card)
        -- ADDED: math.floor and math.max so the tooltip always shows a clean, whole number!
        local copies = math.max(1, math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.base_copies, card.ability.extra.copies_per_level, card.ability.extra.copies_per_ilvl)))
        return { copies }
    end,
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
                local effective_copies = math.max(1, math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.base_copies, card.ability.extra.copies_per_level, card.ability.extra.copies_per_ilvl)))
                
                G.E_MANAGER:add_event(Event({
                    func = function()
                        -- 1. Anchor the text to the target joker instead of the dying Tess
                        card_eval_status_text(target_joker, 'extra', nil, nil, nil, {
                            message = "Thief!",
                            colour = G.C.PURPLE
                        })

                        for i = 1, effective_copies do
                            -- 2. Added support for Negative Jokers to bypass the slot limit!
                            local is_negative = target_joker.edition and target_joker.edition.negative
                            
                            -- 3. REMOVED the '- 1' from the limit check!
                            if #G.jokers.cards <= G.jokers.config.card_limit or is_negative then
                                local new_card = copy_card(target_joker, nil, nil, nil, is_negative)
                                new_card:add_to_deck()
                                G.jokers:emplace(new_card)
                                new_card:start_materialize()
                            end
                        end
                        return true
                    end
                }))
                
                -- DO NOT return a table here! Let the event handle the popup.
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Vanessa VanCleef",
    faction = {"Pirate"},
    race = {"Human"},
    class = {"Rogue"},
    weapon = {"Daggers"},
    damage = {"Piercing"},
    armor = {"Leather"},
    profession = {},
    combo = {"Edwin VanCleef", "Sneed", "Mr. Smite", "Captain Greenskin"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 6,
    index = 112,
    config = { extra = { base_mult = 4, mult_per_level = 1, mult_per_ilvl = 0.5 } },
    loc_txt = {
        "{C:mult}+#1#{} Mult for every",
        "card in your {C:attention}Discard Pile{}",
        "{C:inactive}(Currently {C:mult}+#2#{C:inactive} Mult){}"
    },
    loc_vars = function(self, info_queue, card)
        local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.base_mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl)
        local discard_count = G.discard and #G.discard.cards or 0
        return { effective_mult, discard_count * effective_mult }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local discard_count = G.discard and #G.discard.cards or 0
            if discard_count > 0 then
                local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.base_mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl)
                return {
                    mult = discard_count * effective_mult,
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
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {},
    combo = {"Thrall", "Durotan", "Blackhand", "Grommash Hellscream", "Kilrogg Deadeye", "Gul'dan", "Ner'zhul"},
    role = {"Tank"},
    rarity = 2,
    cost = 6,
    index = 113,
    config = { extra = { base_chips = 100, chips_per_level = 40, chips_per_ilvl = 20 } },
    loc_txt = {
        "{C:chips}+#1#{} Chips for every",
        "{C:attention}Horde{} Joker you have",
        "{C:inactive}(Currently {C:chips}+#2#{C:inactive} Chips){}"
    },
    loc_vars = function(self, info_queue, card)
        local horde_count = 0
        if G.jokers and G.jokers.cards then
            for _, v in ipairs(G.jokers.cards) do
                if v.ability and v.ability.extra and v.ability.extra.faction == "Horde" then
                    horde_count = horde_count + 1
                end
            end
        end
        local effective_chips = Warcraft.get_scaled_gain(card, card.ability.extra.base_chips, card.ability.extra.chips_per_level, card.ability.extra.chips_per_ilvl)
        return { effective_chips, horde_count * effective_chips }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local horde_count = 0
            if G.jokers and G.jokers.cards then
                for _, v in ipairs(G.jokers.cards) do
                    if v.ability and v.ability.extra and v.ability.extra.faction == "Horde" then
                        horde_count = horde_count + 1
                    end
                end
            end
            
            local effective_chips = Warcraft.get_scaled_gain(card, card.ability.extra.base_chips, card.ability.extra.chips_per_level, card.ability.extra.chips_per_ilvl)
            if horde_count > 0 then
                return {
                    chips = horde_count * effective_chips,
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
    damage = {"Physical"},
    armor = {"Leather"},
    profession = {},
    combo = {"Thrall", "Orgrim Doomhammer", "Gul'dan", "Grommash Hellscream", "Kilrogg Deadeye", "Ner'zhul", "Blackhand"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 6,
    index = 114,
    config = { extra = { 
        base_mult_gain = 1, mult_gain_per_level = 0.25, mult_gain_per_ilvl = 0.2, 
        current_mult = 1, active = false 
    } },
    loc_txt = {
        "{X:mult,C:white} X#2# {} Mult",
        "If chips < {C:attention}50%{} of Blind after {C:attention}1st Hand{},",
        "gain {X:mult,C:white} X#1# {} Mult per hand played.",
        "{C:inactive}(Currently X#2#){}"
    },
    loc_vars = function(self, info_queue, card)
        return { 
            Warcraft.get_scaled_gain(card, card.ability.extra.base_mult_gain, card.ability.extra.mult_gain_per_level, card.ability.extra.mult_gain_per_ilvl),
            card.ability.extra.current_mult 
        }
    end,
    calculate = function(self, card, context)
        if context.setting_blind then
            card.ability.extra.current_mult = 1
            card.ability.extra.active = false
        end

        if context.after and not context.blueprint then
            local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.base_mult_gain, card.ability.extra.mult_gain_per_level, card.ability.extra.mult_gain_per_ilvl)
            
            -- Activation check
            if G.GAME.current_round.hands_played == 0 then
                if G.GAME.chips < (G.GAME.blind.chips * 0.5) then
                    card.ability.extra.active = true
                    card.ability.extra.current_mult = card.ability.extra.current_mult + effective_gain
                    return { message = "Survival!", colour = G.C.RED, card = card }
                end
            elseif card.ability.extra.active then
                card.ability.extra.current_mult = card.ability.extra.current_mult + effective_gain
                return { message = "Rising!", colour = G.C.RED, card = card }
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
    damage = {"Piercing"},
    armor = {"Plate"},
    profession = {},
    combo = {"Thrall", "Orgrim Doomhammer", "Durotan", "Blackhand", "Gul'dan", "Ner'zhul", "Kilrogg Deadeye"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 6,
    index = 115,
    config = { extra = { base_xmult = 4, xmult_per_level = 1, xmult_per_ilvl = 0.5 } },
    loc_txt = {
        "Played cards that are",
        "{C:attention}Face Down{} give",
        "{X:mult,C:white} X#1# {} Mult"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.base_xmult, card.ability.extra.xmult_per_level, card.ability.extra.xmult_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card.facing == 'back' then
                return {
                    x_mult = Warcraft.get_scaled_gain(card, card.ability.extra.base_xmult, card.ability.extra.xmult_per_level, card.ability.extra.xmult_per_ilvl),
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
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {},
    combo = {"Danath Trollbane", "Thrall", "Garrosh Hellscream"},
    role = {"Melee DPS"},
    rarity = 1,
    cost = 5,
    index = 116,
    config = { extra = { chips = 20, base_gain = 5, gain_per_level = 0.2, gain_per_ilvl = 0.2 } },
    loc_txt = {
        "{C:chips}+#1#{} Chips",
        "{C:inactive}(Gains {C:chips}+#2#{} per card in deck at end of round){}"
    },
    loc_vars = function(self, info_queue, card)
        return { 
            card.ability.extra.chips, 
            Warcraft.get_scaled_gain(card, card.ability.extra.base_gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl) 
        }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.repetition and not context.individual and not context.blueprint then
            local deck_count = #G.deck.cards
            if deck_count > 0 then
                local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.base_gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl)
                card.ability.extra.chips = card.ability.extra.chips + math.floor(deck_count * effective_gain)
                return {
                    message = "Honor!",
                    colour = G.C.BLUE,
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
    name = "Nazgrel",
    faction = {"Horde"},
    race = {"Orc"},
    class = {"Warrior"},
    weapon = {"Axe"},
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {},
    combo = {"Garrosh Hellscream", "Thrall", "Eitrigg"},
    role = {"Melee DPS"},
    rarity = 1,
    cost = 4,
    index = 117,
    config = { extra = { chips = 100, chips_per_level = 30, mult = 2, mult_per_ilvl = 0.5 } },
    loc_txt = {
        "{C:chips}+#1#{} Chips and {C:mult}+#2#{} Mult",
        "if scoring hand contains",
        "exactly {C:attention}one Face Card{}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.chips, card.ability.extra.chips_per_level, 0),
            Warcraft.get_scaled_gain(card, card.ability.extra.mult, 0, card.ability.extra.mult_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local face_count = 0
            for _, v in ipairs(context.scoring_hand) do
                if v:is_face() then face_count = face_count + 1 end
            end
            if face_count == 1 then
                return {
                    chips = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.chips, card.ability.extra.chips_per_level, 0)),
                    mult = Warcraft.get_scaled_gain(card, card.ability.extra.mult, 0, card.ability.extra.mult_per_ilvl),
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
    damage = {"Shadow"},
    armor = {"Plate"},
    profession = {},
    combo = {"Gul'dan", "Durotan", "Grommash Hellscream", "Thrall", "Ner'zhul", "Blackhand"},
    role = {"Tank"},
    rarity = 2,
    cost = 6,
    index = 118,
    config = { extra = { rounds = 3, rounds_per_ilvl = 0.5, x_mult = 3, x_mult_per_level = 2 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "{C:red}Self Destructs{} in",
        "{C:attention}#2#{} rounds"
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, 0),
            Warcraft.get_scaled_gain(card, card.ability.extra.rounds, 0, card.ability.extra.rounds_per_ilvl)
        }
    end,
    add_to_deck = function(self, card, from_debuff)
        -- Initialize rounds from scaled value at acquisition time
        card.ability.extra.rounds_remaining = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.rounds, 0, card.ability.extra.rounds_per_ilvl))
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                x_mult = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, 0),
                card = card
            }
        end

        if context.end_of_round and not context.repetition and not context.individual and not context.blueprint then
            -- Use rounds_remaining as the live counter, falling back to base if not set
            if not card.ability.extra.rounds_remaining then
                card.ability.extra.rounds_remaining = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.rounds, 0, card.ability.extra.rounds_per_ilvl))
            end
            card.ability.extra.rounds_remaining = card.ability.extra.rounds_remaining - 1
            if card.ability.extra.rounds_remaining <= 0 then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('tarot1')
                        card.T.r = -0.2
                        card:start_dissolve({remove_as_card = true})
                        return true
                    end
                }))
                return {
                    message = "Destiny!",
                    colour = G.C.RED
                }
            else
                return {
                    message = card.ability.extra.rounds_remaining .. " Left",
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
    damage = {"Fire"},
    armor = {"Plate"},
    profession = {},
    combo = {"Durotan", "Yrel", "Vindicator Maraad", "Gul'dan", "Orgrim Doomhammer", "Thrall", "Ner'zhul", "Kilrogg Deadeye"},
    role = {"Tank"},
    rarity = 2,
    cost = 6,
    index = 119,
    config = { extra = { mult = 15, mult_per_level = 3, mult_per_ilvl = 3 } },
    loc_txt = {
        "{C:mult}+#1#{} Mult for every",
        "{C:attention}Steel Card{} in your deck",
        "{C:inactive}(Currently {C:mult}+#2#{C:inactive} Mult){}"
    },
    loc_vars = function(self, info_queue, card)
        local steel_count = 0
        if G.playing_cards then
            for _, v in ipairs(G.playing_cards) do
                if v.config.center == G.P_CENTERS.m_steel then steel_count = steel_count + 1 end
            end
        end
        local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl)
        return { effective_mult, effective_mult * steel_count }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local steel_count = 0
            if G.playing_cards then
                for _, v in ipairs(G.playing_cards) do
                    if v.config.center == G.P_CENTERS.m_steel then steel_count = steel_count + 1 end
                end
            end
            if steel_count > 0 then
                local effective_mult = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl))
                return {
                    mult = effective_mult * steel_count,
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
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {},
    combo = {"Sylvanas Windrunner", "Dranosh Saurfang", "Thrall", "Anduin Wrynn", "Jaina Proudmoore"},
    role = {"Melee DPS"},
    rarity = 1,
    cost = 6,
    index = 120,
    config = { extra = { dollars = 5, dollars_per_ilvl = 1, mult_gain = 10, mult_gain_per_level = 2, current_mult = 0 } },
    loc_txt = {
        "If you win a round with",
        "{C:attention}0 Discards{} used,",
        "gain {C:money}$#1#{} and {C:mult}+#2#{} Mult",
        "{C:inactive}(Currently {C:mult}+#3#{C:inactive} Mult){}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.dollars, 0, card.ability.extra.dollars_per_ilvl),
            Warcraft.get_scaled_gain(card, card.ability.extra.mult_gain, card.ability.extra.mult_gain_per_level, 0),
            card.ability.extra.current_mult
        }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.repetition and not context.individual and not context.blueprint then
            if G.GAME.current_round.discards_used == 0 then
                local effective_mult = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.mult_gain, card.ability.extra.mult_gain_per_level, 0))
                local effective_dollars = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.dollars, 0, card.ability.extra.dollars_per_ilvl))
                card.ability.extra.current_mult = card.ability.extra.current_mult + effective_mult
                ease_dollars(effective_dollars)
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
    damage = {"Physical"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Thrall", "Rexxar", "Rokhan", "Vol'jin"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 6,
    index = 121,
    config = { extra = { count = 0, x_mult = 3, x_mult_per_level = 0.5, x_mult_per_ilvl = 0.5 } },
    loc_txt = {
        "Every {C:attention}4th{} played hand",
        "scores {X:mult,C:white} X#1# {} Mult",
        "{C:inactive}(Hand #2#){}"
    },
    loc_vars = function(self, info_queue, card)
        local current_hand = (card.ability.extra.count % 4) + 1
        return { Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl), current_hand }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            if (card.ability.extra.count + 1) % 4 == 0 then
                return {
                    x_mult = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
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
    damage = {"Nature"},
    armor = {"Mail"},
    profession = {},
    combo = {"Ra-Den", "Aman'Thul", "Xuen", "Dark Animus"},
    role = {"Melee DPS"},
    rarity = 1,
    cost = 6,
    index = 122,
    config = { extra = { multiplier = 1, multiplier_per_level = 0.5, multiplier_per_ilvl = 0.5 } },
    loc_txt = {
        "Scoring {C:clubs}Club{} cards permanently",
        "gain {C:chips}+#1#{} Chips{}",
        "per {C:clubs}Club{} in your deck"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.multiplier, card.ability.extra.multiplier_per_level, card.ability.extra.multiplier_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:is_suit('Clubs') then
                local club_count = 0
                if G.playing_cards then
                    for _, c in ipairs(G.playing_cards) do
                        if c:is_suit('Clubs') then club_count = club_count + 1 end
                    end
                end
                if club_count > 0 then
                    local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.multiplier, card.ability.extra.multiplier_per_level, card.ability.extra.multiplier_per_ilvl)
                    local bonus = math.floor(club_count * effective_mult)
                    context.other_card.ability.bonus = (context.other_card.ability.bonus or 0) + bonus
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            context.other_card:juice_up()
                            return true
                        end
                    }))
                    return {
                        chips = bonus,
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
    damage = {"Shadow"},
    armor = {"Leather"},
    profession = {},
    combo = {"Malfurion Stormrage", "Ysera", "Tyrande Whisperwind", "Cenarius"},
    role = {"Tank"},
    rarity = 2,
    cost = 5,
    index = 123,
    config = { extra = { Xmult = 2, x_mult_per_level = 0.4, x_mult_per_ilvl = 0.3, h_size = -1 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "{C:attention}#2#{} Hand Size"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.Xmult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl), card.ability.extra.h_size }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                x_mult = Warcraft.get_scaled_gain(card, card.ability.extra.Xmult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
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
    damage = {"Nature"},
    armor = {"Mail"},
    profession = {},
    combo = {"Shirvallah", "Mueh'zala", "Bwonsamdi", "Jin'do the Hexxer", "Bloodlord Mandokir"},
    role = {"Melee DPS"},
    rarity = 3,
    cost = 8,
    index = 124,
    config = { extra = { chance = 5, chance_per_level = -0.2, gain = 15, gain_per_ilvl = 3, mult = 0 } },
    loc_txt = {
        "When a card scores, {C:green}1 in #1#{}",
        "chance to destroy it.",
        "If destroyed, gain {C:mult}+#2#{} Mult",
        "{C:inactive}(Currently {C:mult}+#3#{C:inactive} Mult){}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.chance, card.ability.extra.chance_per_level, 0),
            Warcraft.get_scaled_gain(card, card.ability.extra.gain, 0, card.ability.extra.gain_per_ilvl),
            card.ability.extra.mult
        }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            local effective_chance = math.max(1, Warcraft.get_scaled_gain(card, card.ability.extra.chance, card.ability.extra.chance_per_level, 0))
            if pseudorandom('hakkar') < G.GAME.probabilities.normal / effective_chance then
                local effective_gain = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.gain, 0, card.ability.extra.gain_per_ilvl))
                context.other_card.destroyed = true
                card.ability.extra.mult = card.ability.extra.mult + effective_gain
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
    damage = {"Fire"},
    armor = {"Plate"},
    profession = {},
    combo = {"Chromaggus", "Deathwing", "Wrathion", "Onyxia"},
    role = {"Melee DPS"},
    rarity = 3,
    cost = 8,
    index = 125,
    config = { extra = { current_rank = 'Ace', x_mult = 2, x_mult_per_level = 0.3, x_mult_per_ilvl = 0.1 } },
    loc_txt = {
        "At start of round, select",
        "a random {C:attention}Rank{}. Cards of that",
        "Rank give {X:mult,C:white} X#1# {} Mult",
        "{C:inactive}(Current: {C:attention}#2#{C:inactive}){}"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl), card.ability.extra.current_rank }
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            local ranks = {'2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King', 'Ace'}
            card.ability.extra.current_rank = pseudorandom_element(ranks, pseudoseed('nefarian_' .. G.GAME.round))
            return {
                message = card.ability.extra.current_rank .. "!",
                colour = G.C.PURPLE
            }
        end
        if context.individual and context.cardarea == G.play then
            if context.other_card.base.value == card.ability.extra.current_rank then
                return {
                    x_mult = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
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
    damage = {"Fire"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Anduin Wrynn", "Neltharion", "Deathwing", "N'Zoth", "Sabellian", "Ebyssian"},
    role = {"Melee DPS"},
    rarity = 3,
    cost = 8,
    index = 126,
    config = { extra = { jokers = 1, jokers_per_level = 0.2, jokers_per_ilvl = 0.1 } },
    loc_txt = {
        "If you play a {C:attention}Royal Flush{},",
        "create {C:attention}#1#{} random {C:red}Rare Joker(s){}"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.jokers, card.ability.extra.jokers_per_level, card.ability.extra.jokers_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            if context.scoring_name == 'Royal Flush' then
                local effective_count = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.jokers, card.ability.extra.jokers_per_level, card.ability.extra.jokers_per_ilvl))
                local added = 0
                for i = 1, effective_count do
                    if #G.jokers.cards + added < G.jokers.config.card_limit then
                        added = added + 1
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                local new_card = create_card('Joker', G.jokers, nil, 0.99, nil, nil, nil, 'wrathion')
                                new_card:add_to_deck()
                                G.jokers:emplace(new_card)
                                new_card:start_materialize()
                                return true
                            end
                        }))
                    end
                end
                if added > 0 then
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
    race = {"Dragon","Human"},
    class = {"Warrior"},
    weapon = {"Sword","Fist"},
    damage = {"Fire"},
    armor = {"Plate"},
    profession = {},
    combo = {"Wrathion", "Ebyssian", "Neltharion", "Deathwing"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 6,
    index = 127,
    config = { extra = { chips = 50, chips_per_level = 15, mult = 5, mult_per_ilvl = 1 } },
    loc_txt = {
        "{C:attention}Odd Ranked{} cards give",
        "{C:chips}+#1#{} Chips and {C:mult}+#2#{} Mult",
        "when scored"
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.chips, card.ability.extra.chips_per_level, 0),
            Warcraft.get_scaled_gain(card, card.ability.extra.mult, 0, card.ability.extra.mult_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local id = context.other_card:get_id()
            if (id > 0 and id < 11 and id % 2 == 1) or id == 14 then
                return {
                    chips = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.chips, card.ability.extra.chips_per_level, 0)),
                    mult = Warcraft.get_scaled_gain(card, card.ability.extra.mult, 0, card.ability.extra.mult_per_ilvl),
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
    damage = {"Fire"},
    armor = {"Plate"},
    profession = {},
    combo = {"Wrathion", "Sabellian", "Neltharion", "Deathwing"},
    role = {"Melee DPS"},
    rarity = 1,
    cost = 3,
    index = 128,
    config = { extra = { chips = 50, chips_per_level = 15, mult = 3, mult_per_ilvl = 0.5 } },
    loc_txt = {
        "{C:chips}+#1#{} Chips and {C:mult}+#2#{} Mult",
        "when a {C:attention}6{} is scored"
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.chips, card.ability.extra.chips_per_level, 0),
            Warcraft.get_scaled_gain(card, card.ability.extra.mult, 0, card.ability.extra.mult_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:get_id() == 6 then
                return {
                    chips = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.chips, card.ability.extra.chips_per_level, 0)),
                    mult = Warcraft.get_scaled_gain(card, card.ability.extra.mult, 0, card.ability.extra.mult_per_ilvl),
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
    damage = {"Nature"},
    armor = {"Plate"},
    profession = {},
    combo = {"Ragnaros", "Therazane", "Neptulon"},
    role = {"Melee DPS"},
    rarity = 3,
    cost = 8,
    index = 129,
    config = { extra = { repetitions = 2, repetitions_per_level = 0.3, repetitions_per_ilvl = 0.1 } },
    loc_txt = {
        "Retrigger the {C:attention}first played card{}",
        "{C:attention}#1#{} times and give it",
        "a permanent {C:red}Red Seal{}"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.repetitions, card.ability.extra.repetitions_per_level, card.ability.extra.repetitions_per_ilvl) }
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
                    repetitions = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.repetitions, card.ability.extra.repetitions_per_level, card.ability.extra.repetitions_per_ilvl)),
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
    damage = {"Fire"},
    armor = {"Unarmored"},
    profession = {},
    combo = {"Ragnaros", "Garr", "Majordomo Executus"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 6,
    index = 130,
    config = { extra = { x_mult = 4, x_mult_per_level = 1, x_mult_per_ilvl = 0.5 } },
    loc_txt = {
        "If played hand contains exactly",
        "{C:attention}one Red Card{}, destroy it",
        "and deal {X:mult,C:white} X#1# {} Mult"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local red_cards = {}
            for _, v in ipairs(context.scoring_hand) do
                if v:is_suit('Hearts') or v:is_suit('Diamonds') then
                    table.insert(red_cards, v)
                end
            end
            if #red_cards == 1 then
                local bomb_card = red_cards[1]
                G.E_MANAGER:add_event(Event({
                    func = function()
                        bomb_card:start_dissolve({remove_as_card = true})
                        return true
                    end
                }))
                return {
                    message = "Living Bomb!",
                    colour = G.C.RED,
                    x_mult = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
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
    damage = {"Fire"},
    armor = {"Mail"},
    profession = {},
    combo = {"Ragnaros", "Garr", "Baron Geddon"},
    role = {"Ranged DPS"},
    rarity = 1,
    cost = 4,
    index = 131,
    config = { extra = { threshold = 8, threshold_per_level = -0.3, mult = 30, mult_per_ilvl = 3 } },
    loc_txt = {
        "If you have {C:attention}#1# or more{}",
        "cards in hand after playing,",
        "gain {C:mult}+#2#{} Mult"
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.threshold, card.ability.extra.threshold_per_level, 0),
            Warcraft.get_scaled_gain(card, card.ability.extra.mult, 0, card.ability.extra.mult_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local effective_threshold = math.max(1, math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.threshold, card.ability.extra.threshold_per_level, 0)))
            if #G.hand.cards >= effective_threshold then
                return {
                    mult = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.mult, 0, card.ability.extra.mult_per_ilvl)),
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Sicco Thermaplugg",
    race = {"Gnome"},
    weapon = {"Hammer","Fist"},
    damage = {"Fire"},
    armor = {"Plate"},
    profession = {"Engineer"},
    combo = {"Gelbin Mekkatorque", "Zovaal", "Emperor Dagran Thaurissan", "Moira Thaurissan"},
    role = {"Tank"},
    rarity = 2,
    cost = 6,
    index = 132,
    config = { extra = { mult = 25, mult_per_level = 5, chance = 6, chance_per_ilvl = 1 } },
    loc_txt = {
        "{C:mult}+#1#{} Mult",
        "{C:green}1 in #2#{} chance to",
        "set score to {C:attention}0{}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, 0),
            Warcraft.get_scaled_gain(card, card.ability.extra.chance, 0, card.ability.extra.chance_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local effective_mult = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, 0))
            local effective_chance = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.chance, 0, card.ability.extra.chance_per_ilvl))
            if pseudorandom('thermaplugg') < G.GAME.probabilities.normal / effective_chance then
                return {
                    mult = effective_mult,
                    x_mult = 0,
                    message = "Radiation!",
                    colour = G.C.GREEN,
                    card = card
                }
            else
                return {
                    mult = effective_mult,
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
    damage = {"Physical"},
    armor = {"Leather"},
    profession = {},
    combo = {"Edwin VanCleef", "Varian Wrynn", "Anduin Wrynn"},
    role = {"Melee DPS"},
    rarity = 1,
    cost = 2,
    index = 133,
    config = { extra = { chips = 50, chips_per_level = 8, mult = 5, mult_per_ilvl = 1 } },
    loc_txt = {
        "Played {C:attention}2s, 3s, and 4s{}",
        "give {C:chips}+#1#{} Chips and",
        "{C:mult}+#2#{} Mult when scored"
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.chips, card.ability.extra.chips_per_level, 0),
            Warcraft.get_scaled_gain(card, card.ability.extra.mult, 0, card.ability.extra.mult_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local rank = context.other_card:get_id()
            if rank >= 2 and rank <= 4 then
                return {
                    chips = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.chips, card.ability.extra.chips_per_level, 0)),
                    mult = Warcraft.get_scaled_gain(card, card.ability.extra.mult, 0, card.ability.extra.mult_per_ilvl),
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
    damage = {"Shadow"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Malfurion Stormrage", "Genn Greymane", "Lich King", "Prince Keleseth"},
    role = {"Ranged DPS"},
    rarity = 1,
    cost = 4,
    index = 134,
    config = { extra = { chance = 6, chance_per_level = -0.3, chance_per_ilvl = -0.2 } },
    loc_txt = {
        "Scoring {C:attention}Face Cards{} have",
        "{C:green}1 in #1#{} chance to become",
        "{C:attention}Wild Cards{} after scoring"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_wild
        return { Warcraft.get_scaled_gain(card, card.ability.extra.chance, card.ability.extra.chance_per_level, card.ability.extra.chance_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.after and not context.blueprint then
            local effective_chance = math.max(1, Warcraft.get_scaled_gain(card, card.ability.extra.chance, card.ability.extra.chance_per_level, card.ability.extra.chance_per_ilvl))
            for _, other_card in ipairs(context.scoring_hand) do
                if other_card:is_face() and other_card.config.center ~= G.P_CENTERS.m_wild then
                    if pseudorandom('arugal') < G.GAME.probabilities.normal / effective_chance then
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
    damage = {"Shadow"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Lich King", "Kel'Thuzad", "Baron Rivendare", "Mal'Ganis", "Lady Deathwhisper"},
    role = {"Ranged DPS"},
    rarity = 1,
    cost = 4,
    index = 135,
    config = { extra = { bonus_chips = 10, bonus_chips_per_level = 2, bonus_chips_per_ilvl = 1 } },
    loc_txt = {
        "If you discard exactly",
        "{C:attention}2 Face Cards{}, transform",
        "them into {C:attention}Stone Cards{}",
        "with {C:chips}+#1#{} permanent Chips"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_stone
        return { Warcraft.get_scaled_gain(card, card.ability.extra.bonus_chips, card.ability.extra.bonus_chips_per_level, card.ability.extra.bonus_chips_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.discard and not context.blueprint then
            local face_count = 0
            for _, v in ipairs(context.full_hand) do
                if v:is_face() then face_count = face_count + 1 end
            end
            if face_count == 2 and context.other_card:is_face() then
                local bonus = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.bonus_chips, card.ability.extra.bonus_chips_per_level, card.ability.extra.bonus_chips_per_ilvl))
                G.E_MANAGER:add_event(Event({
                    func = function()
                        context.other_card:set_ability(G.P_CENTERS.m_stone, nil, true)
                        context.other_card.ability.perma_bonus = (context.other_card.ability.perma_bonus or 0) + bonus
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
    race = {"Dragon","Undead"}, 
    class = {"Mage"}, 
    weapon = {"Fist"},
    damage = {"Frost"},
    armor = {"Mail"},
    profession = {},
    combo = {"Lich King", "Saphiron", "Kel'Thuzad", "Arthas Menethil", "Malygos"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 8,
    index = 136,
    config = { extra = { copies = 2, copies_per_level = 0.3, copies_per_ilvl = 0.1 } },
    loc_txt = {
        "When a {C:attention}Glass Card{} shatters,",
        "add {C:attention}#1#{} copies of it to",
        "your deck"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_glass
        return { Warcraft.get_scaled_gain(card, card.ability.extra.copies, card.ability.extra.copies_per_level, card.ability.extra.copies_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.remove_playing_cards and not context.blueprint then
            local shattered_glass = false
            local effective_copies = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.copies, card.ability.extra.copies_per_level, card.ability.extra.copies_per_ilvl))
            for _, v in ipairs(context.removed) do
                if v.shattered then
                    shattered_glass = true
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            for i = 1, effective_copies do
                                local new_card = copy_card(v, nil, nil, G.playing_card)
                                new_card:add_to_deck()
                                G.deck.config.card_limit = G.deck.config.card_limit + 1
                                table.insert(G.playing_cards, new_card)
                                G.deck:emplace(new_card)
                                new_card.shattered = nil
                                new_card.destroyed = nil
                            end
                            card:juice_up()
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
    damage = {"Fire"},
    armor = {"Plate"},
    profession = {},
    combo = {"Iridikron", "Vyranoth", "Sarkareth", "Emberthal"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 6,
    index = 137,
    config = { extra = { chance = 20, chance_per_level = -0.2, chance_per_ilvl = -0.1 } },
    loc_txt = {
        "Scoring {C:attention}Steel {C:hearts}Heart{} Cards{}",
        "have a {C:green}#1# in 5{} chance to",
        "create a {C:spectral}Spectral{} card"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_steel
        local effective_chance = math.max(1, Warcraft.get_scaled_gain(card, card.ability.extra.chance, card.ability.extra.chance_per_level, card.ability.extra.chance_per_ilvl))
        return { effective_chance / 20 }
    end,
    calculate = function(self, card, context)
        local is_held_steel_heart = context.individual
            and context.cardarea == G.hand
            and context.other_card.config.center == G.P_CENTERS.m_steel
            and context.other_card:is_suit("Hearts")

        local is_played_steel_heart = context.individual
            and context.cardarea == G.play
            and context.other_card.config.center == G.P_CENTERS.m_steel
            and context.other_card:is_suit("Hearts")

        if (is_held_steel_heart or is_played_steel_heart) and not context.blueprint then
            local effective_chance = math.max(1, Warcraft.get_scaled_gain(card, card.ability.extra.chance, card.ability.extra.chance_per_level, card.ability.extra.chance_per_ilvl))
            if pseudorandom('fyrakk') < (effective_chance / 100.0) then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        if #G.consumeables.cards < G.consumeables.config.card_limit then
                            local spectral = create_card('Spectral', G.consumeables, nil, nil, nil, nil, nil, 'fyrakk')
                            spectral:add_to_deck()
                            G.consumeables:emplace(spectral)
                            spectral:juice_up()
                        else
                            card_eval_status_text(card, 'extra', nil, nil, nil, { message = "No Room!", colour = G.C.RED })
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
    damage = {"Fire"},
    armor = {"Mail"},
    profession = {},
    combo = {"Iridikron", "Vyranoth", "Sarkareth", "Fyrakk"},
    role = {"Ranged DPS"},
    rarity = 1,
    cost = 5,
    index = 138,
    config = { extra = { chance = 2, levels = 1, levels_per_level = 0.3, levels_per_ilvl = 0.3 } },
    loc_txt = {
        "{C:green}#1# in #2#{} chance to upgrade",
        "level of played {C:attention}poker hand{}",
        "by {C:attention}#3#{} level(s)"
    },
    loc_vars = function(self, info_queue, card)
        return {
            G.GAME.probabilities.normal,
            card.ability.extra.chance,
            Warcraft.get_scaled_gain(card, card.ability.extra.levels, card.ability.extra.levels_per_level, card.ability.extra.levels_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            if pseudorandom('emberthal') < G.GAME.probabilities.normal / card.ability.extra.chance then
                local effective_levels = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.levels, card.ability.extra.levels_per_level, card.ability.extra.levels_per_ilvl))
                level_up_hand(card, context.scoring_name, false, effective_levels)
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
    damage = {"Fire"},
    armor = {"Mail"},
    profession = {},
    combo = {"Iridikron", "Vyranoth", "Emberthal", "Fyrakk"},
    role = {"Ranged DPS"},
    rarity = 3,
    cost = 8,
    index = 139,
    blueprint_compat = true,
    config = { extra = { destroy_chance = 2, destroy_chance_per_level = 0.3, destroy_chance_per_ilvl = 0.2 } },
    loc_txt = {
        "Copies the ability of the",
        "{C:attention}Joker to the right{},",
        "{C:green}1 in #1#{} chance to destroy it",
        "at end of round",
        "{C:inactive}(Must be compatible){}"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.destroy_chance, card.ability.extra.destroy_chance_per_level, card.ability.extra.destroy_chance_per_ilvl) }
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
                    local effective_chance = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.destroy_chance, card.ability.extra.destroy_chance_per_level, card.ability.extra.destroy_chance_per_ilvl))
                    if pseudorandom('sarkareth') < (1 / effective_chance) then
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                victim.getting_sliced = true
                                card:juice_up(0.8, 0.8)
                                victim:start_dissolve({G.C.BLACK}, nil, 1.6)
                                play_sound('slice1', 0.96 + math.random() * 0.08)
                                return true
                            end
                        }))
                        return {
                            message = "Consumed!",
                            colour = G.C.BLACK,
                            card = card
                        }
                    else
                        card_eval_status_text(card, 'extra', nil, nil, nil, {
                            message = "Preserved!",
                            colour = G.C.GREEN
                        })
                    end
                end
            end
        end

        local other_joker = nil
        for i = 1, #G.jokers.cards do
            if G.jokers.cards[i] == card then
                other_joker = G.jokers.cards[i + 1]
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
    damage = {"Frost"},
    armor = {"Mail"},
    profession = {},
    combo = {"Iridikron", "Sarkareth", "Emberthal", "Fyrakk"},
    role = {"Ranged DPS"},
    rarity = 1,
    cost = 5,
    index = 140,
    config = { extra = { x_mult = 3, x_mult_per_level = 0.25, x_mult_per_ilvl = 0.1 } },
    loc_txt = {
        "If played hand contains",
        "both {C:clubs}Clubs{} and {C:spades}Spades{},",
        "give {X:mult,C:white} X#1# {} Mult"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl) }
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
                    x_mult = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
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
    damage = {"Nature"},
    armor = {"Plate"},
    profession = {},
    combo = {"Vyranoth", "Sarkareth", "Emberthal", "Fyrakk"},
    role = {"Tank"},
    rarity = 2,
    cost = 8,
    index = 141,
    config = { extra = { x_chips = 1.5, x_chips_per_level = 0.25, x_chips_per_ilvl = 0.1 } },
    loc_txt = {
        "Scoring {C:attention}Stone Cards{}",
        "give {X:chips,C:white} X#1# {} Chips"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_stone
        return { Warcraft.get_scaled_gain(card, card.ability.extra.x_chips, card.ability.extra.x_chips_per_level, card.ability.extra.x_chips_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card.config.center == G.P_CENTERS.m_stone then
                return {
                    x_chips = Warcraft.get_scaled_gain(card, card.ability.extra.x_chips, card.ability.extra.x_chips_per_level, card.ability.extra.x_chips_per_ilvl),
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
    damage = {"Nature"},
    armor = {"Plate"},
    profession = {},
    combo = {"Iridikron", "Vyranoth", "Sarkareth", "Emberthal", "Fyrakk"},
    role = {"Tank"},
    rarity = 2,
    cost = 5,
    index = 142,
    config = { extra = { chips = 0, gain = 20, gain_per_level = 10, gain_per_ilvl = 10 } },
    loc_txt = {
        "When you play a {C:attention}High Card{},",
        "this Joker gains {C:chips}+#2#{} Chips",
        "{C:inactive}(Currently {C:chips}+#1#{C:inactive} Chips){}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.chips,
            Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            if context.scoring_name == 'High Card' then
                local effective_gain = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl))
                card.ability.extra.chips = card.ability.extra.chips + effective_gain
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
    damage = {"Nature"},
    armor = {"Leather"},
    profession = {},
    combo = {"Cenarius", "Ysera", "Ursoc", "Malfurion Stormrage"},
    role = {"Healer"},
    rarity = 2,
    cost = 4,
    index = 143,
    config = { extra = { h_size = 1, h_size_per_level = 0.1, chips = 0, gain = 5, gain_per_ilvl = 0.5, current_h_size = 1 } },
    loc_txt = {
        "{C:attention}+#1#{} Hand Size",
        "This Joker gains {C:chips}+#2#{} Chips",
        "for each {C:clubs}Club{} held in hand",
        "when you play a hand",
        "{C:inactive}(Currently {C:chips}+#3#{C:inactive} Chips){}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.h_size, card.ability.extra.h_size_per_level, 0),
            Warcraft.get_scaled_gain(card, card.ability.extra.gain, 0, card.ability.extra.gain_per_ilvl),
            card.ability.extra.chips
        }
    end,
    add_to_deck = function(self, card, from_debuff)
        local effective_h_size = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.h_size, card.ability.extra.h_size_per_level, 0))
        card.ability.extra.current_h_size = effective_h_size
        G.hand:change_size(effective_h_size)
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.hand:change_size(-card.ability.extra.current_h_size)
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.repetition and not context.individual and not context.blueprint then
            local new_h_size = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.h_size, card.ability.extra.h_size_per_level, 0))
            local diff = new_h_size - card.ability.extra.current_h_size
            if diff ~= 0 then
                G.hand:change_size(diff)
                card.ability.extra.current_h_size = new_h_size
            end
        end

        if context.before and not context.blueprint then
            local club_count = 0
            for _, v in ipairs(G.hand.cards) do
                if v:is_suit('Clubs') then club_count = club_count + 1 end
            end
            if club_count > 0 then
                local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.gain, 0, card.ability.extra.gain_per_ilvl)
                card.ability.extra.chips = card.ability.extra.chips + (club_count * effective_gain)
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
    end
})

Warcraft.create_warcraft_joker({
    name = "Aviana",
    faction = {"Alliance"}, 
    race = {"Beast"},       
    class = {"Druid"},      
    weapon = {"Fist"},
    damage = {"Nature"},
    armor = {"Leather"},
    profession = {},
    combo = {"Ursoc", "Malorne", "Malfurion Stormrage"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 7,
    index = 144,
    config = { extra = { joker_cost = 2, joker_cost_per_level = -0.2, joker_cost_per_ilvl = -0.1 } },
    loc_txt = {
        "Jokers in the {C:attention}Shop{}",
        "cost {C:money}$#1#{}"
    },
    loc_vars = function(self, info_queue, card)
        return { math.max(0, Warcraft.get_scaled_gain(card, card.ability.extra.joker_cost, card.ability.extra.joker_cost_per_level, card.ability.extra.joker_cost_per_ilvl)) }
    end,
    add_to_deck = function(self, card, from_debuff)
        G.E_MANAGER:add_event(Event({
            func = function()
                if G.shop_jokers then
                    for _, c in ipairs(G.shop_jokers.cards) do c:set_cost() end
                end
                return true
            end
        }))
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.E_MANAGER:add_event(Event({
            func = function()
                if G.shop_jokers then
                    for _, c in ipairs(G.shop_jokers.cards) do c:set_cost() end
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
    damage = {"Physical"},
    armor = {"Leather"},
    profession = {},
    combo = {"Xavius", "Ysera", "Malfurion Stormrage", "Malorne"},
    role = {"Tank"},
    rarity = 1,
    cost = 3,
    index = 145,
    config = { extra = { x_chips = 2, x_chips_per_level = 0.3, x_chips_per_ilvl = 0.3 } },
    loc_txt = {
        "Scoring {C:diamonds}Diamond{} cards",
        "give {X:chips,C:white} X#1# {} Chips"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.x_chips, card.ability.extra.x_chips_per_level, card.ability.extra.x_chips_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:is_suit('Diamonds') then
                return {
                    x_chips = Warcraft.get_scaled_gain(card, card.ability.extra.x_chips, card.ability.extra.x_chips_per_level, card.ability.extra.x_chips_per_ilvl),
                    card = context.other_card,
                    message = "Bear Charge!",
                    colour = G.C.DIAMONDS
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
    damage = {"Physical"},
    armor = {"Leather"},
    profession = {},
    combo = {"Ursoc", "Malorne","Malfurion Stormrage","Cenarius","Aviana"},
    role = {"Melee DPS"},
    rarity = 3,
    cost = 8,
    index = 146,
    config = { extra = { x_mult = 4, x_mult_per_level = 1, loss = 5, loss_per_ilvl = -0.2 } },
    loc_txt = {
        "If played hand is a {C:attention}High Card{}",
        "containing a {C:attention}Wild Card{},",
        "give {X:mult,C:white} X#1# {} Mult",
        "and lose {C:money}$#2#{}"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_wild
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, 0),
            Warcraft.get_scaled_gain(card, card.ability.extra.loss, 0, card.ability.extra.loss_per_ilvl)
        }
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
                local effective_loss = Warcraft.get_scaled_gain(card, card.ability.extra.loss, 0, card.ability.extra.loss_per_ilvl)
                -- negative loss = gain money
                ease_dollars(-math.floor(effective_loss))
                G.E_MANAGER:add_event(Event({
                    func = function()
                        card:juice_up()
                        return true
                    end
                }))
                return {
                    message = "Lo'Gosh!",
                    x_mult = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, 0),
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
    damage = {"Nature"},
    armor = {"Leather"},
    profession = {},
    combo = {"MOTHER", "Magni Bronzebeard", "Prophet Zul", "King Rastakhan", "Princess Talanji"},
    role = {"Tank"},
    rarity = 2,
    cost = 5,
    index = 147,
    config = { extra = { bonus = 3, bonus_per_level = 0.5, penalty = 2, penalty_per_ilvl = 0.5 } },
    loc_txt = {
        "{C:mult}+#1#{} Mult for each",
        "{C:attention}Sealed Card{} in your deck,",
        "minus {C:mult}#2#{} Mult for each",
        "{C:hearts}Heart{} or {C:spades}Spade{}",
        "{C:inactive}(Currently {C:mult}+#3#{C:inactive} Mult){}"
    },
    loc_vars = function(self, info_queue, card)
        local effective_bonus = Warcraft.get_scaled_gain(card, card.ability.extra.bonus, card.ability.extra.bonus_per_level, 0)
        local effective_penalty = Warcraft.get_scaled_gain(card, card.ability.extra.penalty, 0, card.ability.extra.penalty_per_ilvl)
        local bonus_count = 0
        local penalty_count = 0
        if G.playing_cards then
            for _, v in ipairs(G.playing_cards) do
                if v:get_seal() then bonus_count = bonus_count + 1 end
                if v:is_suit('Hearts') or v:is_suit('Spades') then penalty_count = penalty_count + 1 end
            end
        end
        local current_mult = math.max(0, (bonus_count * effective_bonus) - (penalty_count * effective_penalty))
        return { effective_bonus, effective_penalty, current_mult }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local effective_bonus = Warcraft.get_scaled_gain(card, card.ability.extra.bonus, card.ability.extra.bonus_per_level, 0)
            local effective_penalty = Warcraft.get_scaled_gain(card, card.ability.extra.penalty, 0, card.ability.extra.penalty_per_ilvl)
            local bonus_count = 0
            local penalty_count = 0
            for _, v in ipairs(G.playing_cards) do
                if v:get_seal() then bonus_count = bonus_count + 1 end
                if v:is_suit('Hearts') or v:is_suit('Spades') then penalty_count = penalty_count + 1 end
            end
            local mult_amount = math.max(0, (bonus_count * effective_bonus) - (penalty_count * effective_penalty))
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
    damage = {"Shadow"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Alleria Windrunner", "Khadgar", "Queen Ansurek", "N'Zoth", "Dimensius the All-Devouring"},
    role = {"Ranged DPS"},
    rarity = 3,
    cost = 8,
    index = 148,
    config = { extra = { x_mult = 3, x_mult_per_level = 0.5, x_mult_per_ilvl = 0.3, chance = 2 } },
    loc_txt = {
        "Each scoring {C:attention}Ace{} gives",
        "{X:mult,C:white} X#1# {} Mult but has a",
        "{C:green}1 in #2#{} chance to be",
        "destroyed when scored"
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
            card.ability.extra.chance
        }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:get_id() == 14 then
                local destroy_card = pseudorandom('xalatath') < G.GAME.probabilities.normal / card.ability.extra.chance
                if destroy_card then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            context.other_card:start_dissolve({remove_as_card = true})
                            return true
                        end
                    }))
                end
                return {
                    x_mult = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
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
    damage = {"Shadow"},
    armor = {"Unarmored"},
    profession = {},
    combo = {"Xal'atath", "Trade Prince Gallywix", "Kael'thas Sunstrider"},
    role = {"Tank"},
    rarity = 3,
    cost = 8,
    index = 149,
    config = { extra = { mult = 0, gain = 15, gain_per_level = 15, gain_per_ilvl = 15 } },
    loc_txt = {
        "When played, remove {C:attention}Edition{}",
        "from scoring cards and gain",
        "{C:mult}+#2#{} Mult for each removed",
        "{C:inactive}(Currently {C:mult}+#1#{C:inactive} Mult){}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.mult,
            Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local devoured_count = 0
            for _, v in ipairs(context.scoring_hand) do
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
                local effective_gain = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl))
                card.ability.extra.mult = card.ability.extra.mult + (devoured_count * effective_gain)
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
    faction = {"Pantheon"},
    race = {"Gnome", "Robot"},
    weapon = {"Hammer", "Fist"},
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {"Engineer"},
    combo = {"Thorim", "Hodir","Freya","Yogg Saron"},
    role = {"Tank"},
    rarity = 3,
    cost = 8,
    index = 150,
    config = { extra = { mult_per_seal = 1, mult_per_seal_per_level = 0.5, mult_per_seal_per_ilvl = 0.5 } },
    loc_txt = {
        "Scoring {C:attention}Steel Cards{} give",
        "{C:mult}+#1#{} Mult per {C:attention}Sealed{}",
        "card in your deck",
        "and gain a random {C:attention}Seal{}",
        "if they don't have one"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_steel
        return { Warcraft.get_scaled_gain(card, card.ability.extra.mult_per_seal, card.ability.extra.mult_per_seal_per_level, card.ability.extra.mult_per_seal_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local scored_card = context.other_card
            if scored_card.config.center == G.P_CENTERS.m_steel then
                local seal_count = 0
                if G.playing_cards then
                    for _, c in ipairs(G.playing_cards) do
                        if c.seal then seal_count = seal_count + 1 end
                    end
                end

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
                    local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.mult_per_seal, card.ability.extra.mult_per_seal_per_level, card.ability.extra.mult_per_seal_per_ilvl)
                    return {
                        mult = seal_count * effective_mult,
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
    damage = {"Nature"},
    armor = {"Cloth"},
    profession = {"Engineer"},
    combo = {"Millhouse Manastorm", "Magnus Manastorm", "Bwonsamdi", "Mueh'zala"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 6,
    index = 151,
    config = { extra = { mult = 4, mult_per_level = 1, chance = 7, chance_per_ilvl = -0.2 } },
    loc_txt = {
        "Played {C:attention}Even Ranked{} cards",
        "of {C:spades}Spades{} or {C:clubs}Clubs{} give",
        "{C:mult}+#1#{} Mult and have a {C:green}1 in #2#{}",
        "chance to become {C:attention}Steel Cards{}"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_steel
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, 0),
            Warcraft.get_scaled_gain(card, card.ability.extra.chance, 0, card.ability.extra.chance_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local other = context.other_card
            local rank = other:get_id()
            if other:is_suit('Spades') or other:is_suit('Clubs') then
                if rank == 2 or rank == 4 or rank == 6 or rank == 8 or rank == 10 then
                    local effective_chance = math.max(1, Warcraft.get_scaled_gain(card, card.ability.extra.chance, 0, card.ability.extra.chance_per_ilvl))
                    local transformed = false
                    if other.config.center ~= G.P_CENTERS.m_steel then
                        if pseudorandom('millificent') < G.GAME.probabilities.normal / effective_chance then
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
                        mult = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, 0)),
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
    faction = {"Pirate"},
    race = {"Goblin"},
    class = {"Rogue"},
    weapon = {"Sword", "Gun"},
    damage = {"Piercing"},
    armor = {"Leather"},
    profession = {},
    combo = {"Marin Noggenfogger", "Trade Prince Gallywix", "Gazlowe"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 6,
    index = 152,
    config = { extra = { debt_limit = 20, debt_limit_per_level = 2, x_mult = 3, x_mult_per_ilvl = 0.1, current_debt = 20 } },
    loc_txt = {
        "Go into debt up to {C:red}-$#1#{}",
        "{X:mult,C:white} X#2# {} Mult if your",
        "balance is {C:red}negative{}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.debt_limit, card.ability.extra.debt_limit_per_level, 0),
            Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, 0, card.ability.extra.x_mult_per_ilvl)
        }
    end,
    add_to_deck = function(self, card, from_debuff)
        local effective_debt = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.debt_limit, card.ability.extra.debt_limit_per_level, 0))
        card.ability.extra.current_debt = effective_debt
        G.GAME.bankrupt_at = G.GAME.bankrupt_at - effective_debt
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.GAME.bankrupt_at = G.GAME.bankrupt_at + card.ability.extra.current_debt
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.repetition and not context.individual and not context.blueprint then
            local new_debt = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.debt_limit, card.ability.extra.debt_limit_per_level, 0))
            local diff = new_debt - card.ability.extra.current_debt
            if diff ~= 0 then
                G.GAME.bankrupt_at = G.GAME.bankrupt_at - diff
                card.ability.extra.current_debt = new_debt
            end
        end

        if context.joker_main then
            if G.GAME.dollars < 0 then
                return {
                    message = "Pay Up!",
                    x_mult = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, 0, card.ability.extra.x_mult_per_ilvl),
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
    damage = {"Frost","Fire"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Vereesa Windrunner", "Alleria Windrunner", "Sylvanas Windrunner", "Turalyon", "Arator the Redeemer", "Alexstrasza", "Krasus"},
    role = {"Ranged DPS"},
    rarity = 1,
    cost = 4,
    index = 153,
    config = { extra = { chance = 4, chance_per_level = -0.2, chance_per_ilvl = -0.1 } },
    loc_txt = {
        "Scoring {C:attention}Face Cards{} have",
        "{C:green}1 in #1#{} chance to become",
        "{C:attention}Glass Cards{} after scoring"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_glass
        return { Warcraft.get_scaled_gain(card, card.ability.extra.chance, card.ability.extra.chance_per_level, card.ability.extra.chance_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.after and not context.blueprint then
            local effective_chance = math.max(1, Warcraft.get_scaled_gain(card, card.ability.extra.chance, card.ability.extra.chance_per_level, card.ability.extra.chance_per_ilvl))
            for _, other_card in ipairs(context.scoring_hand) do
                if other_card:is_face() and other_card.config.center ~= G.P_CENTERS.m_glass then
                    if pseudorandom('rhonin') < G.GAME.probabilities.normal / effective_chance then
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
    race = {"Human", "Dragon"},          
    class = {"Mage"},           
    weapon = {"Staff","Fist"},
    damage = {"Fire"},
    armor = {"Mail"},
    profession = {},
    combo = {"Alexstrasza", "Rhonin", "Deathwing", "Neltharion"},
    role = {"Melee DPS"},
    rarity = 1,
    cost = 3,
    index = 154,
    config = { extra = { chips_per_card = 30, chips_per_card_per_level = 10, chips_per_card_per_ilvl = 5 } },
    loc_txt = {
        "Gives {C:chips}+#1#{} Chips for each",
        "{C:hearts}Heart{} held in hand"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.chips_per_card, card.ability.extra.chips_per_card_per_level, card.ability.extra.chips_per_card_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local heart_count = 0
            for _, v in ipairs(G.hand.cards) do
                if v:is_suit('Hearts') then heart_count = heart_count + 1 end
            end
            if heart_count > 0 then
                local effective_chips = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.chips_per_card, card.ability.extra.chips_per_card_per_level, card.ability.extra.chips_per_card_per_ilvl))
                return {
                    message = "Ruby Life!",
                    chips = heart_count * effective_chips,
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
    damage = {"Physical"},
    armor = {"Unarmored"},
    profession = {},
    combo = {"Cenarius", "Malfurion Stormrage", "Sargeras"},
    role = {"Melee DPS"},
    rarity = 3,
    cost = 8,
    index = 155,
    config = { extra = { x_mult = 2, x_mult_per_level = 0.5, x_mult_per_ilvl = 0.25 } },
    loc_txt = {
        "Played {C:attention}Bonus Cards{} give",
        "{X:mult,C:white} X#1# {} Mult when scored"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_bonus
        return { Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card.config.center == G.P_CENTERS.m_bonus then
                return {
                    x_mult = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Sally Whitemane",
    race = {"Human", "Undead"},
    class = {"Priest", "Death Knight"}, 
    weapon = {"Staff"},
    damage = {"Holy"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Lilian Voss", "Darion Mograine", "Nazgrim"},
    role = {"Healer"},
    rarity = 1,
    cost = 4,
    index = 156,
    config = { extra = { mult_per_card = 4, mult_per_card_per_level = 1, mult_per_card_per_ilvl = 1 } },
    loc_txt = {
        "{C:attention}Gold Cards{} held in hand",
        "or played give {C:mult}+#1#{} Mult",
        "for every card in your",
        "{C:attention}discard pile{}"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_gold
        local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.mult_per_card, card.ability.extra.mult_per_card_per_level, card.ability.extra.mult_per_card_per_ilvl)
        local discard_size = G.discard and #G.discard.cards or 0
        return { effective_mult, discard_size * effective_mult }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local gold_count = 0
            for _, v in ipairs(G.hand.cards) do
                if v.config.center == G.P_CENTERS.m_gold then gold_count = gold_count + 1 end
            end
            for _, v in ipairs(context.scoring_hand) do
                if v.config.center == G.P_CENTERS.m_gold then gold_count = gold_count + 1 end
            end
            local discard_size = #G.discard.cards
            if gold_count > 0 and discard_size > 0 then
                local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.mult_per_card, card.ability.extra.mult_per_card_per_level, card.ability.extra.mult_per_card_per_ilvl)
                return {
                    message = "Resurrection!",
                    mult = gold_count * discard_size * effective_mult,
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
    weapon = {"Claw"},
    damage = {"Shadow"},
    armor = {"Leather"},
    profession = {},
    combo = {"Emperor Shaohao", "Sha of Anger", "Sha of Doubt", "Sha of Despair", "Sha of Hatred", "Sha of Pride", "Sha of Violence", "Niuzao"},
    role = {"Tank"},
    rarity = 1,
    cost = 3,
    index = 157,
    config = { extra = { chips = 50, chips_per_level = 30, chips_per_ilvl = 20 } },
    loc_txt = {
        "{C:spades}Spades{} are always {C:attention}Debuffed{},",
        "but {C:attention}Debuffed Cards{} give",
        "{C:chips}+#1#{} Chips when scored"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.chips, card.ability.extra.chips_per_level, card.ability.extra.chips_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local debuff_chips = 0
            if context.full_hand then
                local effective_chips = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.chips, card.ability.extra.chips_per_level, card.ability.extra.chips_per_ilvl))
                for _, v in ipairs(context.full_hand) do
                    if v.debuff then
                        debuff_chips = debuff_chips + effective_chips
                    end
                end
            end
            if debuff_chips > 0 then
                return {
                    message = "Fear!",
                    chips = debuff_chips,
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
    damage = {"Physical"},
    armor = {"Unarmored"},
    profession = {},
    combo = {"Lich King", "Kel'Thuzad", "Stiches"},
    role = {"Tank"},
    rarity = 1,          
    cost = 5,
    index = 158,
    config = { extra = { multiplier = 1, multiplier_per_level = 0.5, multiplier_per_ilvl = 0.5 } },
    loc_txt = {
        "Each time a {C:diamonds}Diamond{} card scores,",
        "it permanently gains its",
        "{C:chips}Base Chips{} x {C:attention}#1#{} as bonus chips"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.multiplier, card.ability.extra.multiplier_per_level, card.ability.extra.multiplier_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            if context.other_card:is_suit('Diamonds') then
                local base_chips = context.other_card.base.nominal or 0
                local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.multiplier, card.ability.extra.multiplier_per_level, card.ability.extra.multiplier_per_ilvl)
                local bonus = math.floor(base_chips * effective_mult)
                context.other_card.ability.perma_bonus = (context.other_card.ability.perma_bonus or 0) + bonus
                return {
                    message = "Plated!",
                    colour = G.C.DIAMONDS,
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
    damage = {"Physical"},
    armor = {"Unarmored"},
    profession = {},
    combo = {"Lich King", "Kel'Thuzad", "Patchwerk"},
    role = {"Tank"},
    rarity = 2,          
    cost = 5,
    index = 159,
    config = { extra = { mult = 0, gain = 4, gain_per_level = 2, gain_per_ilvl = 1 } },
    loc_txt = {
        "Gain {C:mult}+#2#{} Mult",
        "if you discard exactly",
        "{C:attention}1 card{} at a time",
        "{C:inactive}(Currently {C:mult}+#1#{C:inactive} Mult){}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.mult,
            Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.discard and not context.blueprint then
            if context.other_card == context.full_hand[#context.full_hand] then
                if #context.full_hand == 1 then
                    local effective_gain = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl))
                    card.ability.extra.mult = card.ability.extra.mult + effective_gain
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
    damage = {"Physical"},
    armor = {"Leather"},
    profession = {},
    combo = {"Thrall", "Garrosh Hellscream", "Nazgrel"},
    role = {"Tank"},
    rarity = 2,
    cost = 6,
    index = 160,
    config = { extra = { x_mult = 1.5, x_mult_per_level = 0.3, x_mult_per_ilvl = 0.2 } },
    loc_txt = {
        "All {C:attention}probabilities{} are set",
        "to {C:green}0{}",
        "{X:mult,C:white} X#1# {} Mult"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl) }
    end,
    add_to_deck = function(self, card, from_debuff)
        G.GAME.probabilities.normal = 0
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.GAME.probabilities.normal = 1
        if G.jokers then
            for _, v in ipairs(G.jokers.cards) do
                if v.ability.name == 'Oops! All 6s' and not v.debuff then
                    G.GAME.probabilities.normal = G.GAME.probabilities.normal * 2
                end
            end
        end
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            G.GAME.probabilities.normal = 0
            return {
                x_mult = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
                message = "No Chance!",
                colour = G.C.RED,
                card = card
            }
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Daelin Proudmoore",
    faction = {"Alliance","Pirate"},
    race = {"Human"},
    class = {"Warrior"},
    weapon = {"Sword"},
    damage = {"Physical"},
    armor = {"Leather"},
    profession = {},
    combo = {"Rexxar", "Jaina Proudmoore", "Rekhan"},
    role = {"Melee DPS"},
    rarity = 1,
    cost = 4,
    index = 161,
    config = { extra = { chips_per_debuff = 200, chips_per_debuff_per_level = 50, mult_per_debuff = 30, mult_per_debuff_per_ilvl = 20 } },
    loc_txt = {
        "Your {C:attention}Horde{} Jokers are",
        "{C:red}Debuffed{} while this is present.",
        "Played cards give {C:chips}+#1#{} Chips",
        "and {C:mult}+#2#{} Mult for each",
        "{C:attention}Debuffed Joker{} you own"
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.chips_per_debuff, card.ability.extra.chips_per_debuff_per_level, 0),
            Warcraft.get_scaled_gain(card, card.ability.extra.mult_per_debuff, 0, card.ability.extra.mult_per_debuff_per_ilvl)
        }
    end,
    add_to_deck = function(self, card, from_debuff)
        if G.jokers and G.jokers.cards then
            for _, j in ipairs(G.jokers.cards) do j:set_debuff() end
        end
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.E_MANAGER:add_event(Event({
            func = function()
                if G.jokers and G.jokers.cards then
                    for _, j in ipairs(G.jokers.cards) do j:set_debuff() end
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
                    if j.debuff then debuff_count = debuff_count + 1 end
                end
            end
            if debuff_count > 0 then
                local effective_chips = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.chips_per_debuff, card.ability.extra.chips_per_debuff_per_level, 0))
                local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.mult_per_debuff, 0, card.ability.extra.mult_per_debuff_per_ilvl)
                return {
                    chips = effective_chips * debuff_count,
                    mult = effective_mult * debuff_count,
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
    damage = {"Fire"},
    armor = {"Leather"},
    profession = {},
    combo = {"Grommash Hellscream", "Thrall", "Archimonde", "Magtheridon"},
    role = {"Tank"},
    rarity = 2,
    cost = 5,
    index = 162,
    config = { extra = { x_mult = 2, x_mult_per_level = 0.5, x_mult_per_ilvl = 0.5, value_loss = 1 } },
    loc_txt = {
        "Your {C:attention}Orc{} Jokers each give",
        "{X:mult,C:white} X#1# {} Mult.",
        "At end of round, your {C:attention}Orc{} Jokers",
        "lose {C:money}$#2#{} of Sell Value.",
        "If an Orc reaches {C:money}$0{}, it is {C:red}destroyed{}."
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
            card.ability.extra.value_loss
        }
    end,
    calculate = function(self, card, context)
        if context.other_joker then
            local other = context.other_joker
            if Warcraft.is_race(other, "Orc") then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        other:juice_up(0.5, 0.5)
                        return true
                    end
                }))
                return {
                    message = "Blood Curse!",
                    Xmult_mod = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
                    colour = G.C.RED
                }
            end
        end

        if context.end_of_round and not context.repetition and not context.individual and not context.blueprint then
            local destroyed_any = false
            if G.jokers and G.jokers.cards then
                for i = #G.jokers.cards, 1, -1 do
                    local j = G.jokers.cards[i]
                    if Warcraft.is_race(j, "Orc") and j ~= card then
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
                                    card_eval_status_text(j, 'extra', nil, nil, nil, { message = "-$1 Value", colour = G.C.MONEY })
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
    damage = {"Shadow"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Lich King", "Kel'Thuzad", "Alexandros Mograine"},
    role = {"Melee DPS"},
    rarity = 3,
    cost = 8,
    index = 163,
    config = { extra = { face_target = 4, x_mult = 5, x_mult_per_level = 1, retrigger = 1, retrigger_per_ilvl = 0.2 } },
    loc_txt = {
        "If your played hand contains",
        "exactly {C:attention}#1# Face Cards{},",
        "give {X:mult,C:white} X#2# {} Mult and",
        "retrigger all {C:attention}Face Cards{} {C:attention}#3#{} time(s)"
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.face_target,
            Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, 0),
            Warcraft.get_scaled_gain(card, card.ability.extra.retrigger, 0, card.ability.extra.retrigger_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        local face_count = 0
        if context.full_hand then
            for _, v in ipairs(context.full_hand) do
                if v:is_face() then face_count = face_count + 1 end
            end
        end

        if face_count == card.ability.extra.face_target then
            if context.repetition and context.cardarea == G.play then
                if context.other_card:is_face() then
                    return {
                        message = "Horseman!",
                        repetitions = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.retrigger, 0, card.ability.extra.retrigger_per_ilvl)),
                        card = card
                    }
                end
            end

            if context.joker_main then
                return {
                    message = "The Four Horsemen!",
                    Xmult_mod = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, 0),
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
    damage = {"Nature"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Lich King", "Arthas Menethil", "Rotface", "Festergut"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 6,
    index = 164,
    config = { extra = { targets = 1, targets_per_level = 0.2, targets_per_ilvl = 0.2 } },
    loc_txt = {
        "When a hand is played,",
        "{C:attention}#1#{} random held card(s) gain",
        "a random {C:attention}Enhancement{}.",
        "If it already has one, it gains",
        "a random {C:dark_edition}Edition{} instead."
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.targets, card.ability.extra.targets_per_level, card.ability.extra.targets_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            if G.hand and G.hand.cards and #G.hand.cards > 0 then
                local effective_targets = math.min(
                    math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.targets, card.ability.extra.targets_per_level, card.ability.extra.targets_per_ilvl)),
                    #G.hand.cards
                )
                -- Pick unique targets
                local available = {}
                for _, c in ipairs(G.hand.cards) do table.insert(available, c) end
                for i = 1, effective_targets do
                    if #available == 0 then break end
                    local target_card = pseudorandom_element(available, pseudoseed('putricide_target_' .. i .. '_' .. G.GAME.round))
                    -- Remove from available to avoid duplicates
                    for j = #available, 1, -1 do
                        if available[j] == target_card then table.remove(available, j); break end
                    end
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            if target_card.config.center == G.P_CENTERS.c_base then
                                local enhancement = pseudorandom_element(G.P_CENTER_POOLS.Enhanced, pseudoseed('putricide_enh_' .. i))
                                target_card:set_ability(enhancement, nil, true)
                                card_eval_status_text(card, 'extra', nil, nil, nil, { message = "Mutated!", colour = G.C.GREEN })
                            else
                                local edition = poll_edition('putricide_ed_' .. i, nil, true, true)
                                if edition then
                                    target_card:set_edition(edition, true)
                                    card_eval_status_text(card, 'extra', nil, nil, nil, { message = "Perfected!", colour = G.C.DARK_EDITION })
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
    end
})

Warcraft.create_warcraft_joker({
    name = "Grand Magistrix Elisande",
    race = {"Night Elf"},
    class = {"Mage"},
    weapon = {"Staff"},
    damage = {"Arcane"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Gul'dan", "Thalyssra", "Queen Azshara"},
    role = {"Ranged DPS"},
    rarity = 3,
    cost = 8,
    index = 165,
    config = { extra = { x_mult = 3, x_mult_per_level = 0.5, x_mult_per_ilvl = 0.4, last_hand = nil } },
    loc_txt = {
        "If played {C:attention}poker hand{} is",
        "the same as the",
        "{C:attention}previous hand played{},",
        "give {X:mult,C:white} X#1# {} Mult",
        "{C:inactive}(Previous: #2#){}"
    },
    loc_vars = function(self, info_queue, card)
        return { 
            Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
            card.ability.extra.last_hand or "None"
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            if card.ability.extra.last_hand and context.scoring_name == card.ability.extra.last_hand then
                return {
                    message = "Time Loop!",
                    Xmult_mod = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
                    colour = G.C.PURPLE
                }
            end
        end

        if context.after and not context.blueprint then
            card.ability.extra.last_hand = context.scoring_name
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Helya",
    faction = {"Pantheon"},
    race = {"Undead"},
    class = {"Warlock"}, 
    weapon = {"Fist"},
    damage = {"Shadow"},
    armor = {"Mail"},
    profession = {},
    combo = {"Odyn", "Ra-den", "Loken"},
    role = {"Ranged DPS"},
    rarity = 1,
    cost = 4,
    index = 166,
    config = { extra = { chips = 0, chips_per_card = 1, chips_per_card_per_level = 0.5, chips_per_card_per_ilvl = 0.5 } },
    loc_txt = {
        "When a blind is defeated,",
        "permanently gain {C:chips}+#2#{} Chips{}",
        "per card in the {C:attention}Discard Pile{}",
        "{C:inactive}(Currently {C:chips}+#1#{C:inactive} Chips){}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.chips,
            Warcraft.get_scaled_gain(card, card.ability.extra.chips_per_card, card.ability.extra.chips_per_card_per_level, card.ability.extra.chips_per_card_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.repetition and not context.individual and not context.blueprint then
            local discard_count = (G.discard and G.discard.cards) and #G.discard.cards or 0
            if discard_count > 0 then
                local effective_per_card = Warcraft.get_scaled_gain(card, card.ability.extra.chips_per_card, card.ability.extra.chips_per_card_per_level, card.ability.extra.chips_per_card_per_ilvl)
                card.ability.extra.chips = card.ability.extra.chips + math.floor(discard_count * effective_per_card)
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
    damage = {"Frost"},
    armor = {"Mail"},
    profession = {},
    combo = {"Therazane", "Ragnaros", "Al'Akir"},
    role = {"Ranged DPS"},
    rarity = 1,
    cost = 3,
    index = 167,
    config = { extra = { multiplier = 2, multiplier_per_level = 0.5, multiplier_per_ilvl = 0.5 } },
    loc_txt = {
        "Scoring {C:spades}Spades{} score",
        "{C:attention}#1#x{} their base {C:chips}Chip{} value"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.multiplier, card.ability.extra.multiplier_per_level, card.ability.extra.multiplier_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:is_suit('Spades') then
                local base = context.other_card.base.nominal or 0
                local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.multiplier, card.ability.extra.multiplier_per_level, card.ability.extra.multiplier_per_ilvl)
                -- Add (multiplier - 1) times base so total becomes multiplier * base
                local bonus = math.floor(base * (effective_mult - 1))
                if bonus > 0 then
                    return {
                        chips = bonus,
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
    damage = {"Nature"},
    armor = {"Plate"},
    profession = {},
    combo = {"Neptulon", "Ragnaros", "Al'Akir"},
    role = {"Tank"},
    rarity = 1,
    cost = 4,
    index = 168,
    config = { extra = { chips = 30, chips_per_level = 15, mult = 6, mult_per_ilvl = 1 } },
    loc_txt = {
        "Scoring {C:diamonds}Diamonds{} and {C:attention}Stone Cards{}",
        "give {C:chips}+#1#{} Chips and {C:mult}+#2#{} Mult"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_stone
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.chips, card.ability.extra.chips_per_level, 0),
            Warcraft.get_scaled_gain(card, card.ability.extra.mult, 0, card.ability.extra.mult_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local other = context.other_card
            if other:is_suit('Diamonds') or other.config.center.key == 'm_stone' then
                other:juice_up()
                card:juice_up()
                return {
                    chips = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.chips, card.ability.extra.chips_per_level, 0)),
                    mult = Warcraft.get_scaled_gain(card, card.ability.extra.mult, 0, card.ability.extra.mult_per_ilvl),
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
    faction = {"Pantheon"},
    race = {"Titan"},
    class = {"Druid"}, 
    weapon = {"Staff"},
    damage = {"Nature"},
    armor = {"Leather"},
    profession = {},
    combo = {"Thorim", "Tyr", "Mimiron"},
    role = {"Healer"},
    rarity = 1,
    cost = 5,
    index = 169,
    config = { extra = { cards = 1, cards_per_level = 0.3, cards_per_ilvl = 0.2 } },
    loc_txt = {
        "When you defeat a {C:attention}Blind{},",
        "add {C:attention}#1#{} random {C:attention}Wild Ace(s){}",
        "to your deck"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_wild
        return { Warcraft.get_scaled_gain(card, card.ability.extra.cards, card.ability.extra.cards_per_level, card.ability.extra.cards_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.repetition and not context.individual and not context.blueprint then
            local effective_cards = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.cards, card.ability.extra.cards_per_level, card.ability.extra.cards_per_ilvl))
            G.E_MANAGER:add_event(Event({
                func = function()
                    for i = 1, effective_cards do
                        local suit = pseudorandom_element({'S','H','D','C'}, pseudoseed('freya_suit_' .. i .. '_' .. G.GAME.round))
                        local new_card = create_card('Base', G.deck, nil, nil, nil, nil, nil, 'freya')
                        new_card:set_base(G.P_CARDS[suit .. '_A'])
                        new_card:set_ability(G.P_CENTERS.m_wild)
                        new_card:add_to_deck()
                        table.insert(G.playing_cards, new_card)
                        G.deck:emplace(new_card)
                        new_card:juice_up()
                    end
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
    faction = {"Pantheon"},
    race = {"Titan"},
    class = {"Shaman"}, 
    weapon = {"Hammer"},
    damage = {"Nature"},
    armor = {"Plate"},
    profession = {},
    combo = {"Aman'Thul", "Lei Shen", "Thorim", "Hodir"},
    role = {"Tank"},
    rarity = 3,
    cost = 8,
    index = 170,
    config = { extra = { x_mult = 1, gain = 0.2, gain_per_ilvl = 0.05, repetitions = 1, repetitions_per_level = 0.2 } },
    loc_txt = {
        "Cards with a {C:blue}Blue Seal{} retrigger",
        "{C:attention}#1#{} additional time(s).",
        "This Joker gains {X:mult,C:white} X#2# {} Mult",
        "every time a {C:blue}Blue Seal{} scores",
        "{C:inactive}(Currently {X:mult,C:white} X#3# {C:inactive} Mult){}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.repetitions, card.ability.extra.repetitions_per_level, 0),
            Warcraft.get_scaled_gain(card, card.ability.extra.gain, 0, card.ability.extra.gain_per_ilvl),
            card.ability.extra.x_mult
        }
    end,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            if context.other_card:get_seal() == 'Blue' then
                return {
                    message = "Highkeeper!",
                    repetitions = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.repetitions, card.ability.extra.repetitions_per_level, 0)),
                    card = card
                }
            end
        end

        if context.individual and context.cardarea == G.play and not context.blueprint then
            if context.other_card:get_seal() == 'Blue' then
                local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.gain, 0, card.ability.extra.gain_per_ilvl)
                card.ability.extra.x_mult = card.ability.extra.x_mult + effective_gain
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
    faction = {"Pantheon"},
    race = {"Titan"},
    class = {"Mage"},
    damage = {"Nature"},
    armor = {"MPlate"},
    profession = {},
    combo = {"Thorim", "Hodir", "Ra-Den"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 6,
    index = 171,
    config = { extra = { bonus_chips = 2, bonus_chips_per_level = 0.5, bonus_chips_per_ilvl = 0.3 } },
    loc_txt = {
        "Sealed cards are always",
        "drawn first from your deck.",
        "Sealed cards gain {C:chips}+#1#{} permanent",
        "Chips each time they are drawn"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.bonus_chips, card.ability.extra.bonus_chips_per_level, card.ability.extra.bonus_chips_per_ilvl) }
    end,
    add_to_deck = function(self, card, from_debuff)
        Warcraft.loken_sort_deck()
    end,
    remove_from_deck = function(self, card, from_debuff)
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            Warcraft.loken_sort_deck()
        end

        if context.before and not context.blueprint then
            Warcraft.loken_sort_deck()
        end

        -- Give permanent chips to sealed cards when drawn into hand
        if context.hand_drawn and not context.blueprint then
            local bonus = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.bonus_chips, card.ability.extra.bonus_chips_per_level, card.ability.extra.bonus_chips_per_ilvl))
            for _, c in ipairs(context.hand_drawn) do
                if c.seal then
                    c.ability.perma_bonus = (c.ability.perma_bonus or 0) + bonus
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Nat Pagle",
    race = {"Human"},
    class = {"Hunter"},
    weapon = {"Polearm"},
    damage = {"Physical"},
    armor = {"Cloth"},
    profession = {"Fisher"},
    combo = {"Thrall", "Arthas Menethil", "Archimonde"},
    role = {"Healer"},
    rarity = 2,
    cost = 5,
    index = 172,
    config = { extra = { req = 3, req_per_level = -0.1, req_per_ilvl = -0.05, current = 0 } },
    loc_txt = {
        "Every {C:attention}#1#{} Discards used,",
        "{C:green}reel in{} a random {C:attention}Consumable{}",
        "into an empty slot",
        "{C:inactive}(Currently {C:attention}#2#{C:inactive} / #1#){}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.req, card.ability.extra.req_per_level, card.ability.extra.req_per_ilvl),
            card.ability.extra.current
        }
    end,
    calculate = function(self, card, context)
        if context.discard and not context.blueprint then
            if context.other_card == context.full_hand[1] then
                local effective_req = math.max(1, math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.req, card.ability.extra.req_per_level, card.ability.extra.req_per_ilvl)))
                card.ability.extra.current = card.ability.extra.current + 1
                if card.ability.extra.current >= effective_req then
                    card.ability.extra.current = 0
                    if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                        G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                local c_types = {'Tarot', 'Planet', 'Spectral', 'Equipment'}
                                local chosen_type = pseudorandom_element(c_types, pseudoseed('nat_pagle_' .. G.GAME.round))
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
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {},
    combo = {"Blackhand", "Sabellian", "Illidan Stormrage"},
    role = {"Tank"},
    rarity = 2,
    cost = 6,
    index = 173,
    config = { extra = { chips = 200, chip_gain = 50, chip_gain_per_level = 40, chip_gain_per_ilvl = 40, h_size = -1 } },
    loc_txt = {
        "{C:chips}+#1#{} Chips",
        "Gains {C:chips}+#2#{} Chips",
        "at the end of each Blind.",
        "{C:attention}#3#{} Hand Size"
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.chips,
            Warcraft.get_scaled_gain(card, card.ability.extra.chip_gain, card.ability.extra.chip_gain_per_level, card.ability.extra.chip_gain_per_ilvl),
            card.ability.extra.h_size
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                chips = card.ability.extra.chips,
                card = card
            }
        end
        if context.end_of_round and not context.repetition and not context.individual and not context.blueprint then
            local effective_gain = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.chip_gain, card.ability.extra.chip_gain_per_level, card.ability.extra.chip_gain_per_ilvl))
            card.ability.extra.chips = card.ability.extra.chips + effective_gain
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
    damage = {"Nature"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Elune", "Tyrande Whisperwind", "Ursoc", "Ysera"},
    role = {"Healer"},
    rarity = 3,
    cost = 8,
    index = 174,
    config = { extra = { copies = 1, copies_per_level = 0.2, copies_per_ilvl = 0.1 } },
    loc_txt = {
        "Whenever a playing card is {C:red}destroyed{},",
        "add {C:attention}#1#{} copy/copies to your deck",
        "with {C:dark_edition}Polychrome{} and {C:attention}Wild{} enhancement"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.e_polychrome
        info_queue[#info_queue+1] = G.P_CENTERS.m_wild
        return { Warcraft.get_scaled_gain(card, card.ability.extra.copies, card.ability.extra.copies_per_level, card.ability.extra.copies_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.remove_playing_cards and not context.blueprint then
            if #context.removed > 0 then
                local effective_copies = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.copies, card.ability.extra.copies_per_level, card.ability.extra.copies_per_ilvl))
                G.E_MANAGER:add_event(Event({
                    func = function()
                        for _, destroyed_card in ipairs(context.removed) do
                            for i = 1, effective_copies do
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
    damage = {"Shadow"},
    armor = {"Mail"},
    profession = {},
    combo = {"Sire Denathrius", "Zovaal", "Winter Queen"},
    role = {"Tank"},
    rarity = 3,
    cost = 8,
    index = 175,
    config = { extra = { mult = 0, multiplier = 1, multiplier_per_level = 1, multiplier_per_ilvl = 1 } },
    loc_txt = {
        "If played hand is a {C:attention}Pair{},",
        "destroy a random scoring card",
        "and gain its {C:chips}Base Chips{} x {C:attention}#2#{}",
        "as permanent {C:mult}Mult{}",
        "{C:inactive}(Currently {C:mult}+#1#{C:inactive} Mult){}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.mult,
            Warcraft.get_scaled_gain(card, card.ability.extra.multiplier, card.ability.extra.multiplier_per_level, card.ability.extra.multiplier_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            if context.scoring_name == "Pair" and context.scoring_hand and #context.scoring_hand > 0 then
                local target_card = pseudorandom_element(context.scoring_hand, pseudoseed('primus_' .. G.GAME.round))
                if target_card and not target_card.dissolving then
                    local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.multiplier, card.ability.extra.multiplier_per_level, card.ability.extra.multiplier_per_ilvl)
                    local gained_mult = math.floor((target_card.base.nominal or 0) * effective_mult)
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
    damage = {"Holy"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Uther the Lightbringer", "Pelagos", "Kleia", "Kyrestia"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 6,
    index = 176,
    config = { extra = { bonus_chips = 3, bonus_chips_per_level = 0.5, bonus_chips_per_ilvl = 0.5 } },
    loc_txt = {
        "Scoring {C:attention}Odd{} cards",
        "permanently gain {C:attention}1 Rank{}",
        "and {C:chips}+#1#{} Chips",
        "{C:inactive}(Stops at Ace){}"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.bonus_chips, card.ability.extra.bonus_chips_per_level, card.ability.extra.bonus_chips_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local other = context.other_card
            local id = other:get_id()
            if id > 0 and id < 14 and id % 2 == 1 then
                local bonus = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.bonus_chips, card.ability.extra.bonus_chips_per_level, card.ability.extra.bonus_chips_per_ilvl))
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local current_id = other:get_id()
                        if current_id < 14 then
                            local suit_prefix = string.sub(other.base.suit, 1, 1)
                            local suffixes = {"2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K", "A"}
                            local new_key = suit_prefix .. "_" .. suffixes[current_id]
                            other:set_base(G.P_CARDS[new_key])
                            other.ability.perma_bonus = (other.ability.perma_bonus or 0) + bonus
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
    damage = {"Shadow"},
    armor = {"Leather"},
    profession = {},
    combo = {"Yogg Saron", "Anub'Arak", "Lich King"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 5,
    index = 177,
    config = { extra = { bonus_chips = 2, bonus_chips_per_level = 0.5, bonus_chips_per_ilvl = 0.3 } },
    loc_txt = {
        "Each scoring card changes to a",
        "{C:attention}random suit{} after scoring",
        "and gains {C:chips}+#1#{} permanent Chips"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.bonus_chips, card.ability.extra.bonus_chips_per_level, card.ability.extra.bonus_chips_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.after and not context.blueprint then
            if context.scoring_hand and #context.scoring_hand > 0 then
                local bonus = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.bonus_chips, card.ability.extra.bonus_chips_per_level, card.ability.extra.bonus_chips_per_ilvl))
                for _, scored_card in ipairs(context.scoring_hand) do
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            local current_suit = scored_card.base.suit
                            local possible_new_suits = {}
                            for _, s in ipairs({'Spades', 'Hearts', 'Clubs', 'Diamonds'}) do
                                if s ~= current_suit then table.insert(possible_new_suits, s) end
                            end
                            local new_suit = pseudorandom_element(possible_new_suits, pseudoseed('volazj_' .. G.GAME.round))
                            scored_card:change_suit(new_suit)
                            scored_card.ability.perma_bonus = (scored_card.ability.perma_bonus or 0) + bonus
                            scored_card:juice_up()
                            return true
                        end
                    }))
                end
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
    race = {"Undead", "Dragon"},
    class = {"Warlock"}, 
    weapon = {"Fist"},
    damage = {"Nature"},
    armor = {"Mail"},
    profession = {},
    combo = {"Xavius", "Ysera", "Cenarius"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 6,
    index = 178,
    config = { extra = { mult = -2, mult_per_level = 0.1, chips = 100, chips_per_ilvl = 20 } },
    loc_txt = {
        "Played {C:hearts}Hearts{} give {C:red}#1#{} Mult",
        "and {C:chips}+#2#{} Chips when scored"
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, 0),
            Warcraft.get_scaled_gain(card, card.ability.extra.chips, 0, card.ability.extra.chips_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:is_suit('Hearts') then
                return {
                    mult = Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, 0),
                    chips = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.chips, 0, card.ability.extra.chips_per_ilvl)),
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
    damage = {"Shadow"},
    armor = {"Mail"},
    profession = {},
    combo = {"Deathwing", "Neltharion", "Thrall"},
    role = {"Ranged DPS"},
    rarity = 3, 
    cost = 8,
    index = 179,
    config = { extra = { x_mult = 5.0, decay = 0.5, payout = 25, payout_per_level = 3, payout_per_ilvl = 3 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "Loses {X:mult,C:white} X#2# {} Mult after",
        "each hand played.",
        "If it drops to {X:mult,C:white} X1 {}, it is {C:red}destroyed{}",
        "and you gain {C:money}$#3#{}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.x_mult,
            card.ability.extra.decay,
            Warcraft.get_scaled_gain(card, card.ability.extra.payout, card.ability.extra.payout_per_level, card.ability.extra.payout_per_ilvl)
        }
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
                local effective_payout = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.payout, card.ability.extra.payout_per_level, card.ability.extra.payout_per_ilvl))
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('tarot1')
                        card.T.r = -0.2
                        card:juice_up(0.3, 0.4)
                        card.states.collide.can = false
                        ease_dollars(effective_payout)
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
    damage = {"Physical"},
    armor = {"Leather"},
    profession = {},
    combo = {"Hemet Nesingwary", "King Krush", "A.F. Kay"},
    role = {"Tank"},
    rarity = 2,
    cost = 6,
    index = 180,
    config = { extra = { chance = 6, chance_per_level = -0.2, chance_per_ilvl = -0.1 } },
    loc_txt = {
        "Played {C:clubs}Clubs{} have a",
        "{C:green}1 in #1#{} chance to generate",
        "a random {C:attention}Consumable{}",
        "when scored"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.chance, card.ability.extra.chance_per_level, card.ability.extra.chance_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:is_suit('Clubs') then
                local effective_chance = math.max(1, Warcraft.get_scaled_gain(card, card.ability.extra.chance, card.ability.extra.chance_per_level, card.ability.extra.chance_per_ilvl))
                if pseudorandom('mukla') < G.GAME.probabilities.normal / effective_chance then
                    if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                        G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                local c_types = {'Tarot', 'Planet', 'Spectral', 'Equipment'}
                                local chosen_type = pseudorandom_element(c_types, pseudoseed('mukla_type_' .. G.GAME.round))
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
    faction = {"Pirate"}, 
    race = {"Vulpera"},
    class = {"Rogue"}, 
    weapon = {"Gun"},
    damage = {"Piercing"},
    armor = {"Leather"},
    profession = {},
    combo = {"Harlan Sweete", "Skycap'n Kragg", "Flynn Fairwind"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 6,
    index = 181,
    config = { extra = { dollars = 2, dollars_per_ilvl = 0.1, retrigger = 1, retrigger_per_level = 0.2 } },
    loc_txt = {
        "Played {C:attention}Lucky Cards{} give",
        "{C:money}$#1#{} and retrigger",
        "{C:attention}#2#{} additional time(s)"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_lucky
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.dollars, 0, card.ability.extra.dollars_per_ilvl),
            Warcraft.get_scaled_gain(card, card.ability.extra.retrigger, card.ability.extra.retrigger_per_level, 0)
        }
    end,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            if context.other_card.config.center.key == 'm_lucky' then
                return {
                    message = "Powder Shot!",
                    repetitions = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.retrigger, card.ability.extra.retrigger_per_level, 0)),
                    card = card
                }
            end
        end
        if context.individual and context.cardarea == G.play then
            if context.other_card.config.center.key == 'm_lucky' then
                return {
                    dollars = Warcraft.get_scaled_gain(card, card.ability.extra.dollars, 0, card.ability.extra.dollars_per_ilvl),
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
    faction = {"Pirate"},
    race = {"Murloc"},
    class = {"Warrior"}, 
    weapon = {"Hammer"},
    damage = {"Physical"},
    armor = {"Unarmored"},
    profession = {},
    combo = {"Edwin Vancleef", "Captain Greenskin", "Mr. Smite"},
    role = {"Healer"},
    rarity = 2,
    cost = 5,
    index = 182,
    config = { extra = { multiplier = 1, multiplier_per_level = 0.5, multiplier_per_ilvl = 0.5 } },
    loc_txt = {
        "Scores the combined {C:attention}Base Chip{}",
        "value of all cards in hand",
        "{C:attention}#2#{} times",
        "{C:inactive}(Currently {C:chips}+#1#{C:inactive} Chips){}"
    },
    loc_vars = function(self, info_queue, card)
        local hand_chips = 0
        if G.hand and G.hand.cards then
            for _, v in ipairs(G.hand.cards) do
                if not v.debuff then hand_chips = hand_chips + (v.base.nominal or 0) end
            end
        end
        local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.multiplier, card.ability.extra.multiplier_per_level, card.ability.extra.multiplier_per_ilvl)
        return { hand_chips * effective_mult, effective_mult }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local hand_chips = 0
            if G.hand and G.hand.cards then
                for _, v in ipairs(G.hand.cards) do
                    if not v.debuff then hand_chips = hand_chips + (v.base.nominal or 0) end
                end
            end
            if hand_chips > 0 then
                local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.multiplier, card.ability.extra.multiplier_per_level, card.ability.extra.multiplier_per_ilvl)
                return {
                    chips = math.floor(hand_chips * effective_mult),
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
    damage = {"Physical"},
    armor = {"Cloth"},
    profession = {},
    combo = {"King Rastakhan", "A'dal", "Khadgar"},
    role = {"Melee DPS"},
    rarity = 1,
    cost = 4,
    index = 183,
    config = { extra = { mult = 0, mult_gain = 1, mult_gain_per_level = 0.5, mult_gain_per_ilvl = 0.3 } },
    loc_txt = {
        "{C:mult}+#1#{} Mult",
        "{C:inactive}(Gains {C:mult}+#2#{C:inactive} Mult each time",
        "you {C:attention}Reroll{} the shop){}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.mult,
            Warcraft.get_scaled_gain(card, card.ability.extra.mult_gain, card.ability.extra.mult_gain_per_level, card.ability.extra.mult_gain_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.reroll_shop and not context.blueprint then
            local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.mult_gain, card.ability.extra.mult_gain_per_level, card.ability.extra.mult_gain_per_ilvl)
            card.ability.extra.mult = card.ability.extra.mult + effective_gain
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
    damage = {"Physical"},
    armor = {"Mail"},
    profession = {},
    combo = {"King Rastakhan", "Bwonsamdi", "Baine Bloodhood"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 6,
    index = 184,
    config = { extra = { mult = 0, gain = 3, gain_per_level = 0.5, gain_per_ilvl = 0.3 } },
    loc_txt = {
        "{C:mult}+#1#{} Mult",
        "{C:inactive}(Gains {C:mult}+#2#{C:inactive} Mult when you",
        "use a {C:tarot}Tarot Card{}){}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.mult,
            Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.using_consumeable and not context.blueprint then
            if context.consumeable.ability.set == 'Tarot' then
                local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl)
                card.ability.extra.mult = card.ability.extra.mult + effective_gain
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
    damage = {"Shadow"},
    armor = {"Plate"},
    profession = {},
    combo = {"Arthas Menethil", "Lich King", "Mal'Ganis"},
    role = {"Melee DPS"},
    rarity = 1,
    cost = 4,
    index = 185,
    config = { extra = { repetitions = 1, repetitions_per_level = 0.2, chance = 15, chance_per_ilvl = -0.2 } },
    loc_txt = {
        "Played {C:attention}10s{} retrigger",
        "{C:attention}#1#{} additional time(s)",
        "{C:green}#2# in 100{} chance to generate",
        "a {C:spectral}Spectral{} card when a",
        "{C:attention}10{} scores"
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.repetitions, card.ability.extra.repetitions_per_level, 0),
            Warcraft.get_scaled_gain(card, card.ability.extra.chance, 0, card.ability.extra.chance_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            if context.other_card:get_id() == 10 then
                return {
                    message = "Obliterate!",
                    repetitions = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.repetitions, card.ability.extra.repetitions_per_level, 0)),
                    card = card
                }
            end
        end

        if context.individual and context.cardarea == G.play and not context.blueprint then
            if context.other_card:get_id() == 10 then
                local effective_chance = math.max(1, Warcraft.get_scaled_gain(card, card.ability.extra.chance, 0, card.ability.extra.chance_per_ilvl))
                if pseudorandom('thassarian') < (effective_chance / 100.0) then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            if #G.consumeables.cards < G.consumeables.config.card_limit then
                                local spectral = create_card('Spectral', G.consumeables, nil, nil, nil, nil, nil, 'thassarian')
                                spectral:add_to_deck()
                                G.consumeables:emplace(spectral)
                                spectral:juice_up()
                            else
                                card_eval_status_text(card, 'extra', nil, nil, nil, { message = "No Room!", colour = G.C.RED })
                            end
                            return true
                        end
                    }))
                    return {
                        message = "Death's Whisper!",
                        colour = G.C.PURPLE,
                        card = card
                    }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Il'Gynoth",
    race = {"God"},
    class = {"Warlock"}, 
    weapon = {"Fist"},
    damage = {"Shadow"},
    armor = {"Leather"},
    profession = {},
    combo = {"Cenarius", "N'Zoth", "Nythendra"},
    role = {"Ranged DPS"},
    rarity = 3,
    cost = 8,
    index = 186,
    config = { extra = { x_mult = 3, x_mult_per_level = 0.3, x_mult_per_ilvl = 0.1 } },
    loc_txt = {
        "Cards with a {C:purple}Purple Seal{}",
        "give {X:mult,C:white} X#1# {} Mult when scored"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:get_seal() == 'Purple' then
                return {
                    x_mult = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
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
    damage = {"Arcane"},
    armor = {"Plate"},
    profession = {},
    combo = {"Sire Denathrius", "Zovaal", "Ve'nari"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 6,
    index = 187,
    config = { extra = { mult_per = 15, mult_per_per_level = 5, mult_per_per_ilvl = 3 } },
    loc_txt = {
        "{C:mult}+#1#{} Mult for each",
        "{C:attention}Consumable{} currently held",
        "{C:inactive}(Currently {C:mult}+#2#{C:inactive} Mult){}"
    },
    loc_vars = function(self, info_queue, card)
        local count = G.consumeables and #G.consumeables.cards or 0
        local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.mult_per, card.ability.extra.mult_per_per_level, card.ability.extra.mult_per_per_ilvl)
        return { effective_mult, count * effective_mult }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local count = G.consumeables and #G.consumeables.cards or 0
            if count > 0 then
                local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.mult_per, card.ability.extra.mult_per_per_level, card.ability.extra.mult_per_per_ilvl)
                return {
                    mult = count * effective_mult,
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
    damage = {"Shadow"},
    armor = {"Unarmored"},
    profession = {},
    combo = {"Bwonsamdi", "Millhouse Manastorm", "Millificent Manastorm"},
    role = {"Tank"},
    rarity = 3, 
    cost = 10,
    index = 188,
    config = { extra = { x_mult = 1, x_mult_gain = 0.1, x_mult_gain_per_level = 0.05, threshold = 10, threshold_per_ilvl = -0.1 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "Gains {X:mult,C:white} X#2# {} Mult for every",
        "{C:attention}#3#{} cards discarded this run",
        "{C:inactive}(Total Discarded: {C:attention}#4#{C:inactive}){}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.x_mult,
            Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_gain, card.ability.extra.x_mult_gain_per_level, 0),
            math.max(1, math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.threshold, 0, card.ability.extra.threshold_per_ilvl))),
            (G.GAME and G.GAME.warcraft_cards_discarded) or 0
        }
    end,
    add_to_deck = function(self, card, from_debuff)
        local total_discarded = (G.GAME and G.GAME.warcraft_cards_discarded) or 0
        local effective_threshold = math.max(1, math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.threshold, 0, card.ability.extra.threshold_per_ilvl)))
        local boosts = math.floor(total_discarded / effective_threshold)
        if boosts > 0 then
            local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_gain, card.ability.extra.x_mult_gain_per_level, 0)
            card.ability.extra.x_mult = 1 + (boosts * effective_gain)
            card_eval_status_text(card, 'extra', nil, nil, nil, {
                message = "Soul Harvest!",
                colour = G.C.PURPLE
            })
        end
    end,
    calculate = function(self, card, context)
        if context.discard and not context.blueprint then
            if context.other_card ~= context.full_hand[1] then return end
            local total = (G.GAME and G.GAME.warcraft_cards_discarded) or 0
            local discarded_this_action = #context.full_hand
            local effective_threshold = math.max(1, math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.threshold, 0, card.ability.extra.threshold_per_ilvl)))
            local old_boosts = math.floor((total - discarded_this_action) / effective_threshold)
            local new_boosts = math.floor(total / effective_threshold)
            if new_boosts > old_boosts then
                local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_gain, card.ability.extra.x_mult_gain_per_level, 0)
                card.ability.extra.x_mult = card.ability.extra.x_mult + ((new_boosts - old_boosts) * effective_gain)
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
    damage = {"Shadow"},
    armor = {"Plate"},
    profession = {},
    combo = {"Zovaal", "The Primus", "Winter Queen", "Anduin Wrynn"},
    role = {"Tank"},
    rarity = 3,
    cost = 10,
    index = 189,
    config = { extra = { x_mult_per = 1, x_mult_per_per_level = 0.5, x_mult_per_per_ilvl = 0.3 } },
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
                if j.ability.wow_equipment then count = count + 1 end
            end
        end
        local effective_per = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_per, card.ability.extra.x_mult_per_per_level, card.ability.extra.x_mult_per_per_ilvl)
        return { effective_per, 1 + (count * effective_per) }
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
                if j.ability.wow_equipment then count = count + 1 end
            end
            local effective_per = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_per, card.ability.extra.x_mult_per_per_level, card.ability.extra.x_mult_per_per_ilvl)
            local total_xmult = 1 + (count * effective_per)
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
    damage = {"Holy"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Kleia", "Kyrestia", "Uther the Lightbringer"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 6,
    index = 190,
    config = { extra = { x_mult = 2, x_mult_per_level = 0.3, x_mult_per_ilvl = 0.1 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult if played hand",
        "contains only {C:attention}Even Ranked{} cards"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local only_even = true
            for _, v in ipairs(context.full_hand) do
                local id = v:get_id()
                if id % 2 ~= 0 or id == 14 then
                    only_even = false
                    break
                end
            end
            if only_even and #context.full_hand > 0 then
                return {
                    message = "Soulbind!",
                    Xmult_mod = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
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
    damage = {"Arcane"},
    armor = {"Plate"},
    profession = {},
    combo = {"Artificer Xy'mox", "Zovaal", "Dimensius the All-Devouring"},
    role = {"Healer"},
    rarity = 2,
    cost = 6,
    index = 191,
    config = { extra = { mult = 0, gain = 7, gain_per_level = 1, gain_per_ilvl = 1 } },
    loc_txt = {
        "{C:mult}+#1#{} Mult",
        "Gains {C:mult}+#2#{} Mult for each",
        "{C:money}$1{} of {C:attention}Interest{} earned",
        "{C:inactive}(Currently {C:mult}+#3#{C:inactive} Mult){}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.mult,
            Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl),
            card.ability.extra.mult
        }
    end,
    calculate = function(self, card, context)
        if context.interest and not context.blueprint then
            local interest_earned = context.interest_amt or 0
            if interest_earned > 0 then
                local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl)
                card.ability.extra.mult = card.ability.extra.mult + (interest_earned * effective_gain)
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
    weapon = {"Staff","Claw"},
    damage = {"Nature"},
    armor = {"Leather"},
    profession = {},
    combo = {"Malfurion Stormrage", "Rehgar Earthfury", "Varian Wrynn", "Valeera Sanguinar"},
    role = {"Tank"},
    rarity = 2,
    cost = 6,
    index = 192,
    config = { extra = { x_mult = 2, x_mult_per_level = 0.5, x_mult_per_ilvl = 0.3 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult if",
        "played hand is a {C:attention}Pair{}"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            if context.scoring_name == "Pair" then
                return {
                    message = "Nature's Rage!",
                    Xmult_mod = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
                    colour = G.C.GREEN,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Gahz'rilla",
    race = {"Beast", "God"},
    weapon = {"Fist"},
    damage = {"Physical"},
    armor = {"Mail"},
    profession = {},
    combo = {"C'Thun", "N'Zoth", "Y'Shaarj", "Yogg Saron"},
    role = {"Tank"},
    rarity = 2,
    cost = 8,
    index = 193,
    config = { extra = { x_mult = 3, x_mult_per_level = 0.3, x_mult_per_ilvl = 0.3 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult if",
        "played hand is a",
        "{C:attention}Three of a Kind{}"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            if context.scoring_name == "Three of a Kind" then
                return {
                    message = "Multi-Headed!",
                    Xmult_mod = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
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
    damage = {"Piercing"},
    armor = {"Leather"},
    profession = {},
    combo = {"Sire Denathrius", "Zovaal", "Prince Renathal", "Theotar, the Mad Duke"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 6,
    index = 194,
    config = { extra = { level_gain = 1, level_gain_per_level = 0.2, ilvl_gain = 1, ilvl_gain_per_ilvl = 0.3 } },
    loc_txt = {
        "Each time a {C:attention}Wild Card{} scores,",
        "a random {C:attention}Beast{} Joker",
        "gains {C:attention}#1#{} Level(s) and {C:attention}#2#{} Ilvl"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_wild
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.level_gain, card.ability.extra.level_gain_per_level, 0),
            Warcraft.get_scaled_gain(card, card.ability.extra.ilvl_gain, 0, card.ability.extra.ilvl_gain_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            if context.other_card.config.center.key == 'm_wild' then
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
                    local effective_level = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.level_gain, card.ability.extra.level_gain_per_level, 0))
                    local effective_ilvl = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.ilvl_gain, 0, card.ability.extra.ilvl_gain_per_ilvl))
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            if target.ability.extra and target.ability.extra.level then
                                target.ability.extra.level = target.ability.extra.level + effective_level
                                if target.ability.extra.max_level and target.ability.extra.level > target.ability.extra.max_level then
                                    target.ability.extra.max_level = target.ability.extra.level
                                end
                            end
                            if target.ability.wow_equipment then
                                local eq = target.ability.wow_equipment
                                eq.ilvl = (eq.ilvl or 1) + effective_ilvl
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
    damage = {"Piercing"},
    armor = {"Leather"},
    profession = {},
    combo = {"Alleria Windrunner", "Sylvanas Windrunner", "Rhonin", "Arator the Redeemer"},
    role = {"Ranged DPS"},
    rarity = 1,
    cost = 4,
    index = 195,
    config = { extra = { multiplier = 1, multiplier_per_level = 0.3, multiplier_per_ilvl = 0.3 } },
    loc_txt = {
        "Scoring {C:attention}3s{} give {C:mult}+#1#{} Mult{}",
        "per {C:attention}3{} in your deck"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.multiplier, card.ability.extra.multiplier_per_level, card.ability.extra.multiplier_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:get_id() == 3 then
                local count = 0
                if G.playing_cards then
                    for _, c in ipairs(G.playing_cards) do
                        if c:get_id() == 3 then count = count + 1 end
                    end
                end
                if count > 0 then
                    local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.multiplier, card.ability.extra.multiplier_per_level, card.ability.extra.multiplier_per_ilvl)
                    return {
                        mult = count * effective_mult,
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
    faction = {"Pantheon"},
    class = {"Mage"},
    weapon = {"Fist"},
    damage = {"Holy"},
    armor = {"Unarmored"},
    profession = {},
    combo = {"Brann Bronzebeard", "Aman'Thul", "Loken"},
    role = {"Melee DPS"},
    rarity = 3,
    cost = 20,
    index = 196,
    config = { extra = { payout = 100, payout_per_level = 10, payout_per_ilvl = 2 } },
    loc_txt = {
        "If you would {C:red}fail{} a Blind,",
        "prevent {C:attention}Game Over{}, {C:red}destroy{}",
        "all Jokers, and gain {C:money}$#1#{}"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.payout, card.ability.extra.payout_per_level, card.ability.extra.payout_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.game_over and not context.blueprint then
            if G.GAME.chips < G.GAME.blind.chips then
                local effective_payout = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.payout, card.ability.extra.payout_per_level, card.ability.extra.payout_per_ilvl))
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
                        ease_dollars(effective_payout)
                        for i = #G.jokers.cards, 1, -1 do
                            local j = G.jokers.cards[i]
                            j:start_dissolve()
                        end
                        G.GAME.chips = G.GAME.blind.chips
                        return true
                    end
                }))
                return { saved = true }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Lothraxion",
    faction = {"Alliance","Legion"}, 
    race = {"Undead","Demon","Nathrezim"},
    class = {"Paladin"}, 
    weapon = {"Sword"},
    damage = {"Holy"},
    armor = {"Plate"},
    profession = {},
    combo = {"Turalyon", "Prophet Velen", "Alleria Windrunner"},
    role = {"Healer"},
    rarity = 1,
    cost = 4,
    index = 197,
    config = { extra = { chance = 10, chance_per_level = -0.2, chance_per_ilvl = -0.1 } },
    loc_txt = {
        "Scoring cards have a",
        "{C:green}1 in #1#{} chance to",
        "become {C:money}Gold Cards{}"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_gold
        return { Warcraft.get_scaled_gain(card, card.ability.extra.chance, card.ability.extra.chance_per_level, card.ability.extra.chance_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local other = context.other_card
            if other.config.center ~= G.P_CENTERS.m_gold then
                local effective_chance = math.max(1, Warcraft.get_scaled_gain(card, card.ability.extra.chance, card.ability.extra.chance_per_level, card.ability.extra.chance_per_ilvl))
                if pseudorandom('lothraxion') < G.GAME.probabilities.normal / effective_chance then
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
    damage = {"Physical"},
    armor = {"Leather"},
    profession = {},
    combo = {"Hakkar the Soulflayer", "Bwonsamdi", "Rezan"},
    role = {"Melee DPS"},
    rarity = 1,
    cost = 5,
    index = 198,
    config = { extra = { mult = 4, mult_per_level = 1, mult_per_ilvl = 0.5 } },
    loc_txt = {
        "Played {C:attention}6s, 7s, and 8s{} give",
        "{C:mult}+#1#{} Mult when scored"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local id = context.other_card:get_id()
            if id == 6 or id == 7 or id == 8 then
                return {
                    mult = Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl),
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
    damage = {"Nature"},
    armor = {"Leather"},
    profession = {},
    combo = {"Huln Highmountain", "Odyn", "Merithra"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 7,
    index = 199,
    config = { extra = { hand_size = 2, hand_size_per_level = 0.1, discards = 1, discards_per_ilvl = 0.1, current_hand_size = 2, current_discards = 1 } },
    loc_txt = {
        "{C:attention}+#1#{} Hand Size",
        "{C:attention}+#2#{} Discard each round"
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.hand_size, card.ability.extra.hand_size_per_level, 0),
            Warcraft.get_scaled_gain(card, card.ability.extra.discards, 0, card.ability.extra.discards_per_ilvl)
        }
    end,
    add_to_deck = function(self, card, from_debuff)
        local effective_hand = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.hand_size, card.ability.extra.hand_size_per_level, 0))
        local effective_discards = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.discards, 0, card.ability.extra.discards_per_ilvl))
        card.ability.extra.current_hand_size = effective_hand
        card.ability.extra.current_discards = effective_discards
        G.hand:change_relative_config('card_limit', effective_hand)
        G.GAME.round_resets.discards = G.GAME.round_resets.discards + effective_discards
        ease_discard(effective_discards)
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.hand:change_relative_config('card_limit', -card.ability.extra.current_hand_size)
        G.GAME.round_resets.discards = G.GAME.round_resets.discards - card.ability.extra.current_discards
        ease_discard(-card.ability.extra.current_discards)
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.repetition and not context.individual and not context.blueprint then
            local new_hand = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.hand_size, card.ability.extra.hand_size_per_level, 0))
            local new_discards = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.discards, 0, card.ability.extra.discards_per_ilvl))
            local hand_diff = new_hand - card.ability.extra.current_hand_size
            local discard_diff = new_discards - card.ability.extra.current_discards
            if hand_diff ~= 0 then
                G.hand:change_relative_config('card_limit', hand_diff)
                card.ability.extra.current_hand_size = new_hand
            end
            if discard_diff ~= 0 then
                G.GAME.round_resets.discards = G.GAME.round_resets.discards + discard_diff
                card.ability.extra.current_discards = new_discards
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Malkorok",
    faction = {"Horde"}, 
    race = {"Orc"},
    class = {"Warrior"},
    weapon = {"Sword"},
    damage = {"Physical"},
    armor = {"Unarmored"},
    profession = {},
    combo = {"Garrosh Hellscream", "Y'Shaarj", "Rend Blackhand"},
    role = {"Tank"},
    rarity = 2,
    cost = 6,
    index = 200,
    config = { extra = { mult = 5, mult_per_level = 1, repetitions = 1, repetitions_per_ilvl = 0.2 } },
    loc_txt = {
        "Played {C:attention}Bonus Cards{} give",
        "{C:mult}+#1#{} Mult and retrigger",
        "{C:attention}#2#{} additional time(s)"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_bonus
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, 0),
            Warcraft.get_scaled_gain(card, card.ability.extra.repetitions, 0, card.ability.extra.repetitions_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            if context.other_card.config.center.key == 'm_bonus' then
                return {
                    message = "Fatal Strike!",
                    repetitions = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.repetitions, 0, card.ability.extra.repetitions_per_ilvl)),
                    card = card
                }
            end
        end
        if context.individual and context.cardarea == G.play then
            if context.other_card.config.center.key == 'm_bonus' then
                return {
                    mult = Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, 0),
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
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {},
    combo = {"Sire Denathrius", "Zovaal", "Prince Renathal"},
    role = {"Melee DPS"},
    rarity = 3,
    cost = 10,
    index = 201,
    config = { extra = { ilvl_gain = 10, ilvl_gain_per_level = 3 } },
    loc_txt = {
        "Cannot be {C:attention}Equipped{}.",
        "When a {C:attention}Blind{} is defeated, all",
        "{C:attention}Equipment{} on other Jokers",
        "permanently gain {C:attention}+#1# ilvl{}."
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = {key = 'equipment', set = 'Other'}
        return { Warcraft.get_scaled_gain(card, card.ability.extra.ilvl_gain, card.ability.extra.ilvl_gain_per_level, 0) }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.blueprint and not (context.individual or context.repetition) then
            local effective_gain = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.ilvl_gain, card.ability.extra.ilvl_gain_per_level, 0))
            local equipment_found = false
            for _, j in ipairs(G.jokers.cards) do
                if j ~= card and j.ability.wow_equipment then
                    j.ability.wow_equipment.ilvl = (j.ability.wow_equipment.ilvl or 0) + effective_gain
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
    weapon = {"Axe", "Shield", "Sword"},
    damage = {"Physical"},
    armor = {"Leather"},
    profession = {},
    combo = {"Thrall", "Agamaggan", "Charlga"},
    role = {"Tank"},
    rarity = 2,
    cost = 5,
    index = 202,
    config = { extra = { chips = 0, mult = 0, chip_gain = 5, chip_gain_per_level = 1, mult_gain = 2, mult_gain_per_ilvl = 0.5 } },
    loc_txt = {
        "{C:chips}+#1#{} Chips, {C:mult}+#2#{} Mult",
        "{C:inactive}(Gains {C:chips}+#3#{} and {C:mult}+#4#{} per",
        "{C:attention}Queen{} discarded this run){}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.chips,
            card.ability.extra.mult,
            Warcraft.get_scaled_gain(card, card.ability.extra.chip_gain, card.ability.extra.chip_gain_per_level, 0),
            Warcraft.get_scaled_gain(card, card.ability.extra.mult_gain, 0, card.ability.extra.mult_gain_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.discard and not context.blueprint then
            local queens_discarded = 0
            for _, v in ipairs(context.full_hand) do
                if v:get_id() == 12 then queens_discarded = queens_discarded + 1 end
            end
            if queens_discarded > 0 then
                local effective_chip_gain = Warcraft.get_scaled_gain(card, card.ability.extra.chip_gain, card.ability.extra.chip_gain_per_level, 0)
                local effective_mult_gain = Warcraft.get_scaled_gain(card, card.ability.extra.mult_gain, 0, card.ability.extra.mult_gain_per_ilvl)
                card.ability.extra.chips = card.ability.extra.chips + (queens_discarded * effective_chip_gain)
                card.ability.extra.mult = card.ability.extra.mult + (queens_discarded * effective_mult_gain)
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
    damage = {"Physical"},
    armor = {"Leather"},
    profession = {},
    combo = {"Medivh", "The Curator", "Khadgar", "Aegwynn"},
    role = {"Melee DPS"},
    rarity = 3, 
    cost = 9,
    index = 203,
    config = { extra = { x_mult = 1, gain = 0.3, gain_per_level = 0.1, gain_per_ilvl = 0.1, threshold = 5, guests = {} } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "Gains {X:mult,C:white} X#2# {} for every {C:attention}#3#{}",
        "unique {C:attention}Jokers{} seen this run",
        "{C:inactive}(Guests seen: {C:attention}#4#{C:inactive})"
    },
    loc_vars = function(self, info_queue, card)
        local count = 0
        for _ in pairs(card.ability.extra.guests) do count = count + 1 end
        return {
            card.ability.extra.x_mult,
            Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl),
            card.ability.extra.threshold,
            count
        }
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
                local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl)
                local new_xmult = 1 + (math.floor(count / card.ability.extra.threshold) * effective_gain)
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
    damage = {"Physical"},
    armor = {"Leather"},
    profession = {},
    combo = {"Sire Denathrius", "Remornia", "Mal'Ganis"},
    role = {"Melee DPS"},
    rarity = 3, 
    cost = 10,
    index = 204,
    config = { extra = { slots = 2, slots_per_level = 0.1, slots_per_ilvl = 0.05, current_slots = 2 } },
    loc_txt = {
        "{C:attention}+#1#{} Joker Slots"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.slots, card.ability.extra.slots_per_level, card.ability.extra.slots_per_ilvl) }
    end,
    add_to_deck = function(self, card, from_debuff)
        local effective_slots = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.slots, card.ability.extra.slots_per_level, card.ability.extra.slots_per_ilvl))
        card.ability.extra.current_slots = effective_slots
        G.jokers.config.card_limit = G.jokers.config.card_limit + effective_slots
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.jokers.config.card_limit = G.jokers.config.card_limit - card.ability.extra.current_slots
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.repetition and not context.individual and not context.blueprint then
            local new_slots = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.slots, card.ability.extra.slots_per_level, card.ability.extra.slots_per_ilvl))
            local diff = new_slots - card.ability.extra.current_slots
            if diff ~= 0 then
                G.jokers.config.card_limit = G.jokers.config.card_limit + diff
                card.ability.extra.current_slots = new_slots
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Old Murk-Eye",
    race = {"Murloc"},
    class = {"Warrior"},
    weapon = {"Hammer","Fist"},
    damage = {"Physical"},
    armor = {"Unarmored"},
    profession = {},
    combo = {"Morgl the Oracle", "Mutanus the Devourer", "Murky"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 6,
    index = 205,
    config = { extra = { chip_mod = 6, chip_mod_per_level = 1, mult_mod = 1, mult_mod_per_ilvl = 0.5 } },
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
                if id == 2 or id == 3 or id == 4 then count = count + 1 end
            end
        end
        local effective_chip = Warcraft.get_scaled_gain(card, card.ability.extra.chip_mod, card.ability.extra.chip_mod_per_level, 0)
        local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.mult_mod, 0, card.ability.extra.mult_mod_per_ilvl)
        return { effective_chip, effective_mult, count * effective_chip, count * effective_mult }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local count = 0
            for _, v in ipairs(G.playing_cards) do
                local id = v:get_id()
                if id == 2 or id == 3 or id == 4 then count = count + 1 end
            end
            if count > 0 then
                local effective_chip = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.chip_mod, card.ability.extra.chip_mod_per_level, 0))
                local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.mult_mod, 0, card.ability.extra.mult_mod_per_ilvl)
                return {
                    chips = count * effective_chip,
                    mult = count * effective_mult,
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
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {},
    combo = {"Tavish Stormpike", "Anduin Wrynn", "Drek'Thar"},
    role = {"Tank"},
    rarity = 3, 
    cost = 8,
    index = 206,
    config = { extra = { x_mult = 3, x_mult_per_level = 1, x_mult_per_ilvl = 0.5 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult if",
        "played hand is a",
        "{C:attention}Full House{}"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            if context.scoring_name == "Full House" then
                return {
                    message = "For Ironforge!",
                    Xmult_mod = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
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
    damage = {"Fire"},
    armor = {"Unarmored"},
    profession = {},
    combo = {"Kael'Thas Sunstrider", "Illidan Stormrage", "Akama"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 7,
    index = 207,
    config = { extra = { chips = 500, loss = 100, loss_per_ilvl = -5, gain = 200, gain_per_level = 30 } },
    loc_txt = {
        "{C:chips}+#1#{} Chips",
        "{C:red}-#2#{} Chips per {C:attention}hand played{}",
        "{C:chips}+#3#{} Chips whenever a {C:attention}Joker{}",
        "is {C:red}sold{} or {C:red}destroyed{}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.chips,
            Warcraft.get_scaled_gain(card, card.ability.extra.loss, 0, card.ability.extra.loss_per_ilvl),
            Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, 0)
        }
    end,
    calculate = function(self, card, context)
        -- 1. Normal Scoring
        if context.joker_main then
            if card.ability.extra.chips > 0 then
                return {
                    chips = card.ability.extra.chips,
                    card = card
                }
            end
        end
        
        -- 2. Hand Played: Decrease Chips
        if context.after and not context.blueprint then
            local effective_loss = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.loss, 0, card.ability.extra.loss_per_ilvl))
            -- math.max ensures the chips don't plunge into negative numbers!
            card.ability.extra.chips = math.max(0, card.ability.extra.chips - effective_loss)
            
            return {
                message = "-" .. effective_loss,
                colour = G.C.RED
            }
        end
        
        -- 3. Joker Sold
        if context.selling_card and not context.blueprint then
            local sold = context.card
            if sold and sold ~= card and sold.ability and sold.ability.set == 'Joker' then
                local effective_gain = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, 0))
                card.ability.extra.chips = card.ability.extra.chips + effective_gain
                return {
                    message = "Rebirth!",
                    colour = G.C.CHIPS,
                    card = card
                }
            end
        end

        -- 4. Joker Destroyed (Enemy kill conditions, Madness, etc.)
        if context.joker_type_destroyed and not context.blueprint then
            local destroyed = context.card
            if destroyed and destroyed ~= card and destroyed.ability and destroyed.ability.set == 'Joker' then
                local effective_gain = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, 0))
                card.ability.extra.chips = card.ability.extra.chips + effective_gain
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
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {},
    combo = {"Mimiron", "Jeeves", "Reaves"},
    role = {"Tank"},
    rarity = 3,
    cost = 10,
    index = 208,
    config = { extra = { starting_ilvl = 10, starting_ilvl_per_level = 1, starting_ilvl_per_ilvl = 1 } },
    loc_txt = {
        "At the end of the {C:attention}Shop phase{},",
        "attach a random {C:attention}Equipment{}",
        "to a random {C:attention}Joker{} that doesn't",
        "already have one.",
        "{C:inactive}(Starting Ilvl: {C:attention}#1#{C:inactive}){}"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = {key = 'equipment', set = 'Other'}
        return { Warcraft.get_scaled_gain(card, card.ability.extra.starting_ilvl, card.ability.extra.starting_ilvl_per_level, card.ability.extra.starting_ilvl_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.ending_shop and not context.blueprint then
            local targets = {}
            for _, j in ipairs(G.jokers.cards) do
                if not j.ability.wow_equipment then table.insert(targets, j) end
            end
            if #targets > 0 then
                local target_joker = pseudorandom_element(targets, pseudoseed('blingtron_' .. G.GAME.round))
                local effective_ilvl = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.starting_ilvl, card.ability.extra.starting_ilvl_per_level, card.ability.extra.starting_ilvl_per_ilvl))
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local valid_keys = {}
                        for key, _ in pairs(Warcraft.Equipment.items) do
                            if Warcraft.Equipment.can_attach(target_joker, key) then
                                table.insert(valid_keys, key)
                            end
                        end
                        if #valid_keys == 0 then
                            for key, _ in pairs(Warcraft.Equipment.items) do
                                table.insert(valid_keys, key)
                            end
                        end
                        if #valid_keys > 0 then
                            local chosen_key = pseudorandom_element(valid_keys, pseudoseed('blingtron_eq_' .. G.GAME.round))
                            Warcraft.Equipment.attach(target_joker, chosen_key, effective_ilvl)
                            card_eval_status_text(target_joker, 'extra', nil, nil, nil, {
                                message = "Party Gift!",
                                colour = G.C.GOLD
                            })
                            target_joker:juice_up()
                        end
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
    damage = {"Physical"},
    armor = {"Leather"},
    profession = {"Archaeologist"},
    combo = {"Brann Bronzebeard", "Elise Starseeker", "Reno Jackson"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 6,
    index = 209,
    config = { extra = { mult = 0, chips = 0, mult_gain = 5, mult_gain_per_level = 2, chip_gain = 40, chip_gain_per_ilvl = 5 } },
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
            Warcraft.get_scaled_gain(card, card.ability.extra.mult_gain, card.ability.extra.mult_gain_per_level, 0),
            Warcraft.get_scaled_gain(card, card.ability.extra.chip_gain, 0, card.ability.extra.chip_gain_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.using_consumeable and not context.blueprint then
            if context.consumeable.config.center.set == 'Equipment' then
                local effective_mult_gain = Warcraft.get_scaled_gain(card, card.ability.extra.mult_gain, card.ability.extra.mult_gain_per_level, 0)
                card.ability.extra.mult = card.ability.extra.mult + effective_mult_gain
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
                local effective_chip_gain = Warcraft.get_scaled_gain(card, card.ability.extra.chip_gain, 0, card.ability.extra.chip_gain_per_ilvl)
                card.ability.extra.chips = card.ability.extra.chips + effective_chip_gain
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
    damage = {"Physical"},
    armor = {"Unarmored"},
    profession = {"Cook"},
    combo = {"Prince Renathal", "Sire Denathrius", "Zovaal"},
    role = {"Healer"},
    rarity = 2,
    cost = 7,
    index = 210,
    config = { extra = { x_mult = 1.2, gain = 0.15, gain_per_level = 0.05, gain_per_ilvl = 0.025 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "Swaps position with a random {C:attention}Joker{}",
        "before scoring. Gains {X:mult,C:white} X#2# {} per swap."
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.x_mult,
            Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local other_jokers = {}
            for i = 1, #G.jokers.cards do
                local j = G.jokers.cards[i]
                if j ~= card and not j.pinned and not (j.ability.extra and j.ability.extra.is_enemy) then
                    table.insert(other_jokers, i)
                end
            end
            if #other_jokers > 0 then
                local target_idx = pseudorandom_element(other_jokers, pseudoseed('theotar_' .. G.GAME.round))
                local my_idx = nil
                for i = 1, #G.jokers.cards do
                    if G.jokers.cards[i] == card then my_idx = i; break end
                end
                if my_idx and target_idx and my_idx ~= target_idx then
                    G.jokers.cards[my_idx], G.jokers.cards[target_idx] = G.jokers.cards[target_idx], G.jokers.cards[my_idx]
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            G.jokers:hard_set_T()
                            G.jokers:align_cards()
                            return true
                        end
                    }))
                    local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl)
                    card.ability.extra.x_mult = card.ability.extra.x_mult + effective_gain
                    return {
                        message = "Swap!",
                        colour = G.C.PURPLE,
                        card = card
                    }
                end
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
    class = {"Shaman"},
    weapon = {"Hammer"},
    damage = {"Fire"},
    armor = {"Cloth"},
    profession = {"Cook"},
    combo = {"Khadgar", "Archmage Vargoth", "Nat Pagle"},
    role = {"Healer"},
    rarity = 2,
    cost = 6,
    index = 211,
    config = { extra = { mult = 0, gain = 15, gain_per_level = 4, gain_per_ilvl = 3 } },
    loc_txt = {
        "{C:mult}+#1#{} Mult",
        "At the end of the {C:attention}Shop phase{},",
        "{C:red}destroy{} a random {C:attention}Consumable{}",
        "to permanently gain {C:mult}+#2#{} Mult.",
        "{C:inactive}(Currently {C:mult}+#1#{C:inactive} Mult){}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.mult,
            Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.ending_shop and not context.blueprint then
            if G.consumeables.cards[1] then
                local card_to_burn = pseudorandom_element(G.consumeables.cards, pseudoseed('nomi_' .. G.GAME.round))
                local effective_gain = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl))
                G.E_MANAGER:add_event(Event({
                    func = function()
                        card_to_burn:start_dissolve()
                        card.ability.extra.mult = card.ability.extra.mult + effective_gain
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
    race = {"Undead", "Beast"},
    class = {"Death Knight"}, 
    weapon = {"Fist"},
    damage = {"Shadow"},
    armor = {"Plate"},
    profession = {},
    combo = {"Arthas Menethil", "Sylvanas Windrunner", "Kel'Thuzad"},
    role = {"Tank"},
    rarity = 3, 
    cost = 10,
    index = 212,
    config = { extra = { chance = 10, chance_per_level = -0.1, chance_per_ilvl = -0.05, slots_gained = 0 } },
    loc_txt = {
        "{C:green}1 in #1#{} chance to permanently",
        "gain {C:attention}+1{} Joker Slot when",
        "a {C:attention}Blind{} is defeated.",
        "{C:inactive}(Total slots gained: {C:attention}+#2#{C:inactive})"
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.chance, card.ability.extra.chance_per_level, card.ability.extra.chance_per_ilvl),
            card.ability.extra.slots_gained
        }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.blueprint and not (context.individual or context.repetition) then
            local effective_chance = math.max(1, Warcraft.get_scaled_gain(card, card.ability.extra.chance, card.ability.extra.chance_per_level, card.ability.extra.chance_per_ilvl))
            if pseudorandom('invincible') < G.GAME.probabilities.normal / effective_chance then
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
    damage = {"Fire"},
    armor = {"Plate"},
    profession = {},
    combo = {"Wilfred Fizzlebang", "Archimonde", "Gul'dan"},
    role = {"Tank"},
    rarity = 1,
    cost = 7,
    index = 213,
    config = { extra = { x_mult = 1, gain = 1, gain_per_level = 0.5, gain_per_ilvl = 0.3 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "Gains {X:mult,C:white} X#2# {} whenever a",
        "{C:attention}Gnome Joker{} is {C:red}sold{} or {C:red}destroyed{}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.x_mult,
            Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.remove_from_deck and not context.blueprint then
            if context.other_card and context.other_card.ability.set == 'Joker' then
                if Warcraft.is_race(context.other_card, "Gnome") then
                    local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl)
                    card.ability.extra.x_mult = card.ability.extra.x_mult + effective_gain
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
    damage = {"Shadow"},
    armor = {"Leather"},
    profession = {},
    combo = {"Queen Ansurek", "Xal'atath", "Anub'arak", "N'Zoth"},
    role = {"Tank"},
    rarity = 2,
    cost = 7,
    index = 214,
    config = { extra = { chips = 30, mult = 6, cards = 1, cards_per_level = 0.2, cards_per_ilvl = 0.2 } },
    loc_txt = {
        "At the start of each {C:attention}Blind{},",
        "create {C:attention}#3#{} random {C:spades}Spade{} card(s) in hand.",
        "{C:spades}Spades{} give {C:chips}+#1#{} Chips and",
        "{C:mult}+#2#{} Mult when scored."
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.chips,
            card.ability.extra.mult,
            math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.cards, card.ability.extra.cards_per_level, card.ability.extra.cards_per_ilvl))
        }
    end,
    calculate = function(self, card, context)
        if context.first_hand_drawn and not context.blueprint then
            local effective_cards = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.cards, card.ability.extra.cards_per_level, card.ability.extra.cards_per_ilvl))
            
            if effective_cards > 0 then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local ranks = {'2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K', 'A'}
                        
                        for i = 1, effective_cards do
                            local chosen_rank = pseudorandom_element(ranks, pseudoseed('neferess_' .. i .. '_' .. G.GAME.round))
                            local chosen_front = G.P_CARDS['S_' .. chosen_rank]
                            
                            -- create_playing_card natively handles adding to deck, array insertion, and emplacement!
                            local new_card = create_playing_card({
                                front = chosen_front, 
                                center = G.P_CENTERS.c_base
                            }, G.hand, nil, nil, nil)
                            
                            -- FORCE VISIBILITY
                            new_card.facing = 'front'
                            new_card.sprite_facing = 'front'
                            new_card.front_hidden = false
                            new_card.is_temporary = true
                            
                            new_card:juice_up()
                        end
                        
                        G.hand:sort()
                        
                        card_eval_status_text(card, 'extra', nil, nil, nil, {
                            message = "The Swarm Grows!",
                            colour = G.C.BLUE 
                        })
                        return true
                    end
                }))
            end
        end
        
        if context.individual and context.cardarea == G.play then
            if context.other_card:is_suit('Spades') then
                return {
                    chips = card.ability.extra.chips,
                    mult = card.ability.extra.mult,
                    card = context.other_card,
                    colour = G.C.BLUE
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Queen Ansurek",
    race = {"Nerubian"},
    weapon = {"Fist"},
    damage = {"Shadow"},
    armor = {"Leather"},
    profession = {},
    combo = {"Queen Neferess", "Xal'atath", "Anub'arak", "N'Zoth"},
    role = {"Tank"},
    rarity = 3, 
    cost = 9,
    index = 215,
    config = { extra = { buys_remaining = 0, buys_per_level = 0.2, starting_level = 1, starting_level_per_ilvl = 1 } },
    loc_txt = {
        "The first {C:attention}#1#{} Joker(s){} bought",
        "each shop become {C:dark_edition}Negative{} and {C:red}Perishable{}",
        "and start at level {C:attention}#2#{}.",
        "{C:inactive}(Remaining this shop: {C:attention}#3#{C:inactive}){}"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.e_negative
        info_queue[#info_queue+1] = G.P_CENTERS.m_perishable
        return {
            Warcraft.get_scaled_gain(card, 1, card.ability.extra.buys_per_level, 0),
            Warcraft.get_scaled_gain(card, card.ability.extra.starting_level, 0, card.ability.extra.starting_level_per_ilvl),
            card.ability.extra.buys_remaining
        }
    end,
    calculate = function(self, card, context)
        if context.ending_shop then
            -- Reset counter at start of each shop
            card.ability.extra.buys_remaining = math.floor(Warcraft.get_scaled_gain(card, 1, card.ability.extra.buys_per_level, 0))
        end

        if context.buying_card and not context.blueprint then
            if context.card.ability.set == 'Joker' and card.ability.extra.buys_remaining > 0 then
                card.ability.extra.buys_remaining = card.ability.extra.buys_remaining - 1
                local effective_level = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.starting_level, 0, card.ability.extra.starting_level_per_ilvl))
                G.E_MANAGER:add_event(Event({
                    func = function()
                        context.card:set_edition({negative = true}, true)
                        context.card:set_perishable(true)
                        -- Set starting level
                        if context.card.ability.extra and effective_level > 1 then
                            context.card.ability.extra.level = effective_level
                            if context.card.ability.extra.max_level and effective_level > context.card.ability.extra.max_level then
                                context.card.ability.extra.max_level = effective_level
                            end
                        end
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
    faction = {"Legion", "Pantheon"},
    race = {"Titan"},
    weapon = {"Polearm"},
    damage = {"Shadow"},
    armor = {"Plate"},
    profession = {},
    combo = {"Aman'Thul", "Eonar", "Magni Bronzebeard", "Sargeras"},
    role = {"Melee DPS"},
    rarity = 3,
    cost = 10,
    index = 216,
    config = { extra = { chips = 0, first_discard = true, multiplier = 1, multiplier_per_level = 1, multiplier_per_ilvl = 0.5 } },
    loc_txt = {
        "{C:chips}+#1#{} Chips",
        "The {C:attention}first card{} discarded each",
        "Blind is {C:red}destroyed{}; gain its",
        "{C:chips}base Chips{} x {C:attention}#2#{} permanently.",
        "{C:inactive}(Currently {C:chips}+#1#{C:inactive}){}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.chips,
            Warcraft.get_scaled_gain(card, card.ability.extra.multiplier, card.ability.extra.multiplier_per_level, card.ability.extra.multiplier_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.setting_blind then
            card.ability.extra.first_discard = true
        end

        if context.discard and not context.blueprint and card.ability.extra.first_discard then
            local target_card = context.full_hand[1]
            card.ability.extra.first_discard = false
            local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.multiplier, card.ability.extra.multiplier_per_level, card.ability.extra.multiplier_per_ilvl)
            local chip_gain = math.floor((target_card:get_chip_bonus() or target_card.base.nominal or 0) * effective_mult)
            G.E_MANAGER:add_event(Event({
                func = function()
                    card.ability.extra.chips = card.ability.extra.chips + chip_gain
                    target_card:start_dissolve({remove_as_card = true})
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
    damage = {"Nature"},
    armor = {"Mail"},
    profession = {},
    combo = {"Iridikron", "Fyrakk", "Vyranoth", "Kurog Grimtotem", "Wrathion"},
    role = {"Ranged DPS"},
    rarity = 3,
    cost = 10,
    index = 217,
    config = { extra = { x_mult = 1.5, gain = 0.2, gain_per_level = 0.1, gain_per_ilvl = 0.05 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "When a card with a {C:blue}Blue Seal{} scores,",
        "{C:red}remove{} the seal and permanently",
        "gain {X:mult,C:white} X#2# {} Mult."
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.x_mult,
            Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card.seal == 'Blue' then
                local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl)
                G.E_MANAGER:add_event(Event({
                    func = function()
                        context.other_card:set_seal(nil)
                        card.ability.extra.x_mult = card.ability.extra.x_mult + effective_gain
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
    damage = {"Arcane"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Medivh", "Khadgar", "Nielas Aran", "Sargeras"},
    role = {"Ranged DPS"},
    rarity = 3,
    cost = 10,
    index = 218,
    config = { extra = { chips = 500, chips_per_level = 50, x_mult = 3, x_mult_per_ilvl = 0.3 } },
    loc_txt = {
        "If {C:attention}Aegwynn{} is your only",
        "{C:attention}Human{} and {C:blue}Alliance{} Joker,",
        "gain {C:chips}+#1#{} Chips and {X:mult,C:white} X#2# {} Mult."
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.chips, card.ability.extra.chips_per_level, 0),
            Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, 0, card.ability.extra.x_mult_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local is_alone = true
            for _, j in ipairs(G.jokers.cards) do
                if j ~= card then
                    if Warcraft.is_race(j, "Human") or Warcraft.is_faction(j, "Alliance") then
                        is_alone = false
                        break
                    end
                end
            end
            if is_alone then
                return {
                    chips = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.chips, card.ability.extra.chips_per_level, 0)),
                    Xmult_mod = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, 0, card.ability.extra.x_mult_per_ilvl),
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
    damage = {"Shadow"},
    armor = {"Plate"},
    profession = {},
    combo = {"Mal'Ganis", "Sylvanas Windrunner", "Tichondrius", "Zovaal"},
    role = {"Tank"},
    rarity = 1,
    cost = 3,
    index = 219,
    config = { extra = { mult_val = 5, mult_val_per_level = 1, xmult_val = 0.2, xmult_val_per_ilvl = 0.05 } },
    loc_txt = {
        "{C:mult}+#1#{} Mult for each of the {C:attention}most{} owned",
        "{C:attention}Horde/Alliance{} Joker,",
        "{C:red}-#3#{} Mult for each of the {C:attention}least{} owned.",
        "{X:mult,C:white} X#2# {} Mult for each of the {C:attention}most{} owned",
        "{C:attention}Scourge/Legion{} Joker,",
        "{C:red}X-#4#{} Mult for each of the {C:attention}least{} owned."
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.mult_val, card.ability.extra.mult_val_per_level, 0),
            Warcraft.get_scaled_gain(card, card.ability.extra.xmult_val, 0, card.ability.extra.xmult_val_per_ilvl),
            card.ability.extra.mult_val,
            card.ability.extra.xmult_val
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local counts = { Alliance = 0, Horde = 0, Legion = 0, Scourge = 0 }
            for _, j in ipairs(G.jokers.cards) do
                if j.ability and j.ability.extra and j.ability.extra.faction then
                    local factions = type(j.ability.extra.faction) == "table" and j.ability.extra.faction or {j.ability.extra.faction}
                    for _, f in ipairs(factions) do
                        if counts[f] ~= nil then counts[f] = counts[f] + 1 end
                    end
                end
            end

            local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.mult_val, card.ability.extra.mult_val_per_level, 0)
            local base_mult = card.ability.extra.mult_val
            local most_mortal = math.max(counts.Alliance, counts.Horde)
            local least_mortal = math.min(counts.Alliance, counts.Horde)
            local mortal_mult = (most_mortal * effective_mult) - (least_mortal * base_mult)

            local effective_xmult = Warcraft.get_scaled_gain(card, card.ability.extra.xmult_val, 0, card.ability.extra.xmult_val_per_ilvl)
            local base_xmult = card.ability.extra.xmult_val
            local most_evil = math.max(counts.Legion, counts.Scourge)
            local least_evil = math.min(counts.Legion, counts.Scourge)
            local evil_xmult = 1 + (most_evil * effective_xmult) - (least_evil * base_xmult)

            return {
                mult = mortal_mult,
                Xmult_mod = math.max(0.01, evil_xmult),
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
    damage = {"Shadow"},
    armor = {"Plate"},
    profession = {},
    combo = {"Arthas Menethil", "Lich King", "Ner'zhul", "Mal'Ganis", "Varimathras"},
    role = {"Tank"},
    rarity = 3,
    cost = 10,
    index = 220,
    config = { extra = { level_gain = 0, level_gain_per_level = 0.2, ilvl_gain = 0, ilvl_gain_per_ilvl = 0.1 } },
    loc_txt = {
        "Copies the effect of the",
        "{C:attention}rightmost{} Joker during a {C:attention}Blind{}.",
        "At end of blind, rightmost gains",
        "{C:attention}+#1#{} Level(s) and {C:attention}+#2#{} Ilvl{}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.level_gain, card.ability.extra.level_gain_per_level, 0),
            Warcraft.get_scaled_gain(card, card.ability.extra.ilvl_gain, 0, card.ability.extra.ilvl_gain_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        -- Copy rightmost joker effect during blind
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

        -- Buff rightmost at end of blind
        if context.end_of_round and not context.repetition and not context.individual and not context.blueprint then
            local rightmost = G.jokers and G.jokers.cards[#G.jokers.cards]
            if rightmost and rightmost ~= card then
                local effective_level = Warcraft.get_scaled_gain(card, card.ability.extra.level_gain, card.ability.extra.level_gain_per_level, 0)
                local effective_ilvl = Warcraft.get_scaled_gain(card, card.ability.extra.ilvl_gain, 0, card.ability.extra.ilvl_gain_per_ilvl)

                if effective_level > 0 and rightmost.ability.extra and rightmost.ability.extra.level then
                    rightmost.ability.extra.level = rightmost.ability.extra.level + effective_level
                    if rightmost.ability.extra.max_level and rightmost.ability.extra.level > rightmost.ability.extra.max_level then
                        rightmost.ability.extra.max_level = rightmost.ability.extra.level
                    end
                end

                if effective_ilvl > 0 and rightmost.ability.wow_equipment then
                    rightmost.ability.wow_equipment.ilvl = (rightmost.ability.wow_equipment.ilvl or 1) + effective_ilvl
                    rightmost.ability.wow_equipment.ilvl_gained_this_round = 0
                end

                if effective_level > 0 or effective_ilvl > 0 then
                    card_eval_status_text(rightmost, 'extra', nil, nil, nil, {
                        message = "Empowered!",
                        colour = G.C.DARK_EDITION
                    })
                    rightmost:juice_up()
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
    damage = {"Physical"},
    armor = {"Mail"},
    profession = {},
    combo = {"Arthas Menethil", "Calia Menethil", "Orgrim Doomhammer", "Lich King"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 7,
    index = 221,
    config = { extra = { x_chips = 1, x_mult = 1, x_gain = 0.2, x_gain_per_level = 0.1, x_gain_per_ilvl = 0.05 } },
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
            Warcraft.get_scaled_gain(card, card.ability.extra.x_gain, card.ability.extra.x_gain_per_level, card.ability.extra.x_gain_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.playing_card_added and not context.blueprint then
            local added = context.card
            if added and added:get_id() == 13 then
                local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.x_gain, card.ability.extra.x_gain_per_level, card.ability.extra.x_gain_per_ilvl)
                card.ability.extra.x_chips = card.ability.extra.x_chips + effective_gain
                return {
                    message = "Heir to the Throne!",
                    colour = G.C.CHIPS,
                    card = card
                }
            end
        end

        if context.remove_playing_cards and not context.blueprint then
            local found = false
            for _, removed_card in ipairs(context.removed) do
                if removed_card:get_id() == 13 then
                    local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.x_gain, card.ability.extra.x_gain_per_level, card.ability.extra.x_gain_per_ilvl)
                    card.ability.extra.x_mult = card.ability.extra.x_mult + effective_gain
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
    damage = {"Physical"},
    armor = {"Mail"},
    profession = {},
    combo = {"King Rastakhan", "Bwonsamdi", "Princess Talanji"},
    role = {"Melee DPS"},
    rarity = 3,
    cost = 9,
    index = 222,
    config = { extra = { x_mult = 1.5, x_mult_per_level = 0.2, x_mult_per_ilvl = 0.2 } },
    loc_txt = {
        "Scoring {C:attention}Kings{} become {C:dark_edition}Wild Cards{}",
        "and give {X:mult,C:white} X#1# {} Mult when scored."
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_wild
        return { Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl) }
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
                    Xmult_mod = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
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
    damage = {"Arcane"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Grand Magistrix Elisande", "Gul'dan", "Khadgar"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 6,
    index = 223,
    config = { extra = { mult = 30, loss = 10, loss_per_ilvl = -0.5, reset_val = 40, reset_val_per_level = 5 } },
    loc_txt = {
        "{C:mult}+#1#{} Mult",
        "Loses {C:red}#2#{} Mult per {C:attention}hand played{}.",
        "Resets to {C:mult}+#3#{} Mult whenever",
        "a {C:attention}Planet card{} is used."
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.mult,
            Warcraft.get_scaled_gain(card, card.ability.extra.loss, 0, card.ability.extra.loss_per_ilvl),
            Warcraft.get_scaled_gain(card, card.ability.extra.reset_val, card.ability.extra.reset_val_per_level, 0)
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                mult = card.ability.extra.mult,
                card = card
            }
        end

        if context.after and not context.blueprint then
            local effective_loss = math.max(0, Warcraft.get_scaled_gain(card, card.ability.extra.loss, 0, card.ability.extra.loss_per_ilvl))
            card.ability.extra.mult = card.ability.extra.mult - effective_loss
            return {
                message = "Withering...",
                colour = G.C.RED
            }
        end

        if context.using_consumeable and not context.blueprint then
            if context.consumeable.config.center.set == 'Planet' then
                local effective_reset = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.reset_val, card.ability.extra.reset_val_per_level, 0))
                card.ability.extra.mult = effective_reset
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
    damage = {"Piercing"},
    armor = {"Mail"},
    profession = {},
    combo = {"Invincible", "Illidan Stormrage", "Lich King"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 6,
    index = 224,
    config = { extra = { multiplier = 1, multiplier_per_level = 0.3, multiplier_per_ilvl = 0.1 } },
    loc_txt = {
        "Gains {C:mult}+Mult{} equal to the total",
        "{C:attention}ilvl{} of all {C:attention}Equipment{}",
        "{C:attention}#2#{} times.",
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
        local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.multiplier, card.ability.extra.multiplier_per_level, card.ability.extra.multiplier_per_ilvl)
        return { total_ilvl * effective_mult, effective_mult }
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
                local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.multiplier, card.ability.extra.multiplier_per_level, card.ability.extra.multiplier_per_ilvl)
                return {
                    mult = math.floor(total_ilvl * effective_mult),
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
    damage = {"Holy"},
    armor = {"Unarmored"},
    profession = {},
    combo = {"Khadgar", "Illidan Stormrage", "Akama"},
    role = {"Healer"},
    rarity = 3,
    cost = 10,
    index = 225,
    config = { extra = { chips = 0, chip_gain = 20, chip_gain_per_level = 10, money_gain = 2, money_gain_per_ilvl = 0.5 } },
    loc_txt = {
        "{C:chips}+#1#{} Chips",
        "Whenever a {C:money}Gold Card{} or {C:money}Gold Seal{}",
        "triggers, permanently gain {C:chips}+#2#{} Chips",
        "and {C:money}$#3#{}."
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_gold
        info_queue[#info_queue+1] = G.P_SEALS.Gold
        return {
            card.ability.extra.chips,
            Warcraft.get_scaled_gain(card, card.ability.extra.chip_gain, card.ability.extra.chip_gain_per_level, 0),
            Warcraft.get_scaled_gain(card, card.ability.extra.money_gain, 0, card.ability.extra.money_gain_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        local function trigger(msg)
            local effective_chips = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.chip_gain, card.ability.extra.chip_gain_per_level, 0))
            local effective_money = Warcraft.get_scaled_gain(card, card.ability.extra.money_gain, 0, card.ability.extra.money_gain_per_ilvl)
            card.ability.extra.chips = card.ability.extra.chips + effective_chips
            ease_dollars(effective_money)
            return { message = msg, colour = G.C.MONEY, card = card }
        end

        if context.individual and context.cardarea == G.play then
            if context.other_card.seal == 'Gold' then
                return trigger("The Light!")
            end
        end

        if context.individual and context.cardarea == G.hand and not context.end_of_round then
            if context.other_card.config.center == G.P_CENTERS.m_gold then
                return trigger("Blessed!")
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
    weapon = {"Claw", "Teeth"},
    damage = {"Physical"},
    armor = {"Leather"},
    profession = {},
    combo = {"Chi-ji", "Niuzao", "Yu'lon"},
    role = {"Melee DPS"},
    rarity = 3,
    cost = 9,
    index = 226,
    config = { extra = { x_mult = 3, x_mult_per_level = 0.3, level_up = 3, level_up_per_ilvl = 0.3 } },
    loc_txt = {
        "If played hand is exactly a {C:attention}High Card{},",
        "give {X:mult,C:white} X#1# {} Mult and upgrade",
        "{C:attention}High Card{} by {C:attention}#2#{} levels."
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, 0),
            math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.level_up, 0, card.ability.extra.level_up_per_ilvl))
        }
    end,
    calculate = function(self, card, context)
        -- 1. Level up BEFORE scoring starts so the current hand benefits from the new level
        if context.before and not context.blueprint then
            if context.scoring_name == "High Card" then
                local effective_level_up = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.level_up, 0, card.ability.extra.level_up_per_ilvl))
                if effective_level_up > 0 then
                    level_up_hand(card, 'High Card', false, effective_level_up)
                    return {
                        message = "Tiger's Strength!",
                        colour = G.C.SECONDARY_SET,
                        card = card
                    }
                end
            end
        end

        -- 2. Apply XMult during the normal Joker scoring phase
        if context.joker_main then
            if context.scoring_name == "High Card" then
                local effective_xmult = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, 0)
                if effective_xmult > 1 then
                    return {
                        Xmult_mod = effective_xmult,
                        message = "X" .. effective_xmult .. " Mult!",
                        colour = G.C.MULT,
                        card = card
                    }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Niuzao",
    race = {"Beast","God"},
    class = {"Monk"},
    weapon = {"Horn"},
    damage = {"Physical"},
    armor = {"Leather"},
    profession = {},
    combo = {"Xuen", "Chi-ji", "Yu'lon"},
    role = {"Tank"},
    rarity = 2,
    cost = 7,
    index = 227,
    config = { extra = { x_mult = 2, x_mult_per_ilvl = 0.1, count = 2, count_per_level = 0.3 } },
    loc_txt = {
        "The first {C:attention}#2#{} scoring cards",
        "each hand give",
        "{X:mult,C:white} X#1# {} Mult when scored"
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, 0, card.ability.extra.x_mult_per_ilvl),
            Warcraft.get_scaled_gain(card, card.ability.extra.count, card.ability.extra.count_per_level, 0)
        }
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            card.ability.extra.cards_scored_this_hand = 0
        end

        if context.individual and context.cardarea == G.play and not context.blueprint then
            local effective_count = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.count, card.ability.extra.count_per_level, 0))
            if card.ability.extra.cards_scored_this_hand < effective_count then
                card.ability.extra.cards_scored_this_hand = card.ability.extra.cards_scored_this_hand + 1
                return {
                    x_mult = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, 0, card.ability.extra.x_mult_per_ilvl),
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
    weapon = {"Beak"},
    damage = {"Physical"},
    armor = {"Leather"},
    profession = {},
    combo = {"Xuen", "Niuzao", "Yu'lon"},
    role = {"Healer"},
    rarity = 2,
    cost = 7,
    index = 228,
    config = { extra = { x_mult = 1, gain = 1, gain_per_level = 0.3, gain_per_ilvl = 0.2 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "Gains {X:mult,C:white} X#2# {} after each {C:attention}hand played{}.",
        "{C:red}Resets{} when {C:attention}Blind{} is defeated."
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.x_mult,
            Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.after and not context.blueprint then
            local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl)
            card.ability.extra.x_mult = card.ability.extra.x_mult + effective_gain
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
    damage = {"Fire"},
    armor = {"Mail"},
    profession = {},
    combo = {"Xuen", "Niuzao", "Chi-ji"},
    role = {"Ranged DPS"},
    rarity = 3,
    cost = 9,
    index = 229,
    config = { extra = { x_mult = 1.5, gain = 0.2, gain_per_level = 0.1, gain_per_ilvl = 0.05, hands_played = {} } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "Permanently gains {X:mult,C:white} X#2# {} for each",
        "{C:attention}unique{} Poker Hand played this run.",
        "{C:inactive}(#3# unique hands found){}"
    },
    loc_vars = function(self, info_queue, card)
        local count = 0
        for _ in pairs(card.ability.extra.hands_played) do count = count + 1 end
        return {
            card.ability.extra.x_mult,
            Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl),
            count
        }
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local hand_type = context.scoring_name
            if not card.ability.extra.hands_played[hand_type] then
                card.ability.extra.hands_played[hand_type] = true
                local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl)
                card.ability.extra.x_mult = card.ability.extra.x_mult + effective_gain
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
                    message = "X" .. string.format("%.2f", card.ability.extra.x_mult) .. " Mult",
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
    damage = {"Holy"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Arthas Menethil", "Terenas Menethil II", "Jaine Proudmoore"},
    role = {"Healer"},
    rarity = 3,
    cost = 9,
    index = 230,
    config = { extra = { x_mult = 1.5, gain = 0.5, gain_per_level = 0.1, gain_per_ilvl = 0.05 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "If played hand contains at least",
        "one {C:attention}Gold Card{} and one {C:attention}Stone Card{},",
        "permanently gain {X:mult,C:white} X#2# {} Mult."
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_gold
        info_queue[#info_queue+1] = G.P_CENTERS.m_stone
        return {
            card.ability.extra.x_mult,
            Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl)
        }
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
                local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl)
                card.ability.extra.x_mult = card.ability.extra.x_mult + effective_gain
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
    damage = {"Physical"},
    armor = {"Leather"},
    profession = {"Archaeologist"},
    combo = {"Harrison Jones", "Elsie Starseeker", "Sir Finley Mrrgglton", "Arch-Thief Rafaam"},
    role = {"Healer"},
    rarity = 3,
    cost = 8,
    index = 231,
    config = { extra = { x_mult = 4, x_mult_per_level = 0.3, x_mult_per_ilvl = 0.2 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult if",
        "played hand has",
        "{C:attention}no duplicate ranks{}."
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl) }
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
                    Xmult_mod = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
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
    damage = {"Nature"},
    armor = {"Leather"},
    profession = {"Archaeologist"},
    combo = {"Reno Jackson", "Harrison Jones", "Sir Finley Mrrgglton", "Arch-Thief Rafaam"},
    role = {"Ranged DPS"},
    rarity = 3,
    cost = 8,
    index = 232,
    config = { extra = { x_mult = 2, x_mult_per_level = 0.5, equipment = 1, equipment_per_ilvl = 0.1 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult and generate",
        "{C:attention}#2#{} random {C:attention}Equipment(s){} if played",
        "hand is any type of {C:attention}Straight{}."
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = {key = 'equipment', set = 'Other'}
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, 0),
            Warcraft.get_scaled_gain(card, card.ability.extra.equipment, 0, card.ability.extra.equipment_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            if Warcraft.is_straight_hand(context.scoring_name) then
                local effective_equipment = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.equipment, 0, card.ability.extra.equipment_per_ilvl))
                G.E_MANAGER:add_event(Event({
                    func = function()
                        for i = 1, effective_equipment do
                            if #G.consumeables.cards < G.consumeables.config.card_limit then
                                local _card = create_card('Equipment', G.consumeables, nil, nil, nil, nil, nil, 'elise')
                                _card:add_to_deck()
                                G.consumeables:emplace(_card)
                            end
                        end
                        return true
                    end
                }))
                return {
                    message = "Discovery!",
                    Xmult_mod = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, 0),
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
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {"Archaeologist"},
    combo = {"Elise Starseeker", "Reno Jackson", "Harrison Jones", "Arch-Thief Rafaam"},
    role = {"Tank"},
    rarity = 2,
    cost = 6,
    index = 233,
    config = { extra = { mult = 0, gain = 5, gain_per_level = 3, gain_per_ilvl = 3 } },
    loc_txt = {
        "{C:mult}+#1#{} Mult",
        "Permanently gain {C:mult}+#2#{} Mult",
        "whenever a {C:attention}Booster Pack{} is opened.",
        "{C:inactive}(Currently {C:mult}+#1#{C:inactive} Mult){}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.mult,
            Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.open_pack and not context.blueprint then
            local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl)
            card.ability.extra.mult = card.ability.extra.mult + effective_gain
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
    weapon = {"Claw", "Teeth"},
    damage = {"Physical"},
    armor = {"Leather"},
    profession = {},
    combo = {"Freya", "Cenarius", "Archimonde", "Malorne"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 6,
    index = 234,
    config = { extra = { mult = 15, mult_per_level = 3, mult_per_ilvl = 3 } },
    loc_txt = {
        "Played {C:attention}Wild Cards{} give",
        "{C:mult}+#1#{} Mult when scored",
        "if their rank is an {C:attention}Odd Number{}"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_wild
        return { Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local other = context.other_card
            local id = other:get_id()
            local is_odd = (id > 0 and id % 2 == 1) or (id == 14)
            if other.config.center.key == 'm_wild' and is_odd then
                return {
                    mult = Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl),
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
    damage = {"Physical"},
    armor = {"Mail"},
    profession = {},
    combo = {"Cenarius", "Krasus", "Malorne", "Malfurion Stormrage", "Ohn'ahra", "Jarod Shadowsong", "Tichondrius", "Deathwing", "Neltharion"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 6,
    index = 235,
    config = { extra = { repetitions = 1, repetitions_per_level = 0.2, repetitions_per_ilvl = 0.1 } },
    loc_txt = {
        "Cards directly {C:attention}adjacent{} to the",
        "{C:attention}highest-ranked{} scoring card",
        "retrigger {C:attention}#1#{} additional time(s)"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.repetitions, card.ability.extra.repetitions_per_level, card.ability.extra.repetitions_per_ilvl) }
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
                            repetitions = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.repetitions, card.ability.extra.repetitions_per_level, card.ability.extra.repetitions_per_ilvl)),
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
    damage = {"Fire"},
    armor = {"Plate"},
    profession = {},
    combo = {"Baron Geddon", "Ragnaros", "Majordomo Executus"},
    role = {"Tank"},
    rarity = 2,
    cost = 6,
    index = 236,
    config = { extra = { chips = 30, chips_per_level = 8, mult = 4, mult_per_ilvl = 0.5 } },
    loc_txt = {
        "Scoring {C:attention}Stone Cards{} and {C:hearts}Hearts{}",
        "give {C:chips}+#1#{} Chips and {C:mult}+#2#{} Mult"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_stone
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.chips, card.ability.extra.chips_per_level, 0),
            Warcraft.get_scaled_gain(card, card.ability.extra.mult, 0, card.ability.extra.mult_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local other = context.other_card
            if other.config.center.key == 'm_stone' or other:is_suit('Hearts') then
                return {
                    chips = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.chips, card.ability.extra.chips_per_level, 0)),
                    mult = Warcraft.get_scaled_gain(card, card.ability.extra.mult, 0, card.ability.extra.mult_per_ilvl),
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
    class = {"Warrior"}, 
    weapon = {"Fist"},
    damage = {"Physical"},
    armor = {"Leather"},
    profession = {},
    combo = {"Ursoc", "Blackseed", "Bristlesnarl", "Elder Brandlemar", "Elder Jari", "Frostfur"},
    role = {"Tank"},
    rarity = 2,
    cost = 6,
    index = 237,
    config = { extra = { mult = 15, mult_per_level = 3, mult_per_ilvl = 2 } },
    loc_txt = {
        "Played {C:attention}Bonus Cards{} and",
        "{C:attention}Lucky Cards{} give {C:mult}+#1#{} Mult",
        "when scored"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_bonus
        info_queue[#info_queue+1] = G.P_CENTERS.m_lucky
        return { Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local other = context.other_card
            if other.config.center.key == 'm_bonus' or other.config.center.key == 'm_lucky' then
                return {
                    mult = Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl),
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
    damage = {"Physical"},
    armor = {"Leather"},
    profession = {},
    combo = {"Tess Greymane", "Lord Darius Crowley", "Sire Denathrius"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 6,
    index = 238,
    config = { extra = { quests = 1, quests_per_level = 0.1, quests_per_ilvl = 0.05 } },
    loc_txt = {
        "If played hand contains",
        "a {C:attention}Straight{}, create {C:attention}#1#{}",
        "random {C:attention}Quest{} card(s)"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = {key = 'quest', set = 'Other'}
        return { Warcraft.get_scaled_gain(card, card.ability.extra.quests, card.ability.extra.quests_per_level, card.ability.extra.quests_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            if context.poker_hands and context.poker_hands['Straight'] and next(context.poker_hands['Straight']) then
                local effective_quests = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.quests, card.ability.extra.quests_per_level, card.ability.extra.quests_per_ilvl))
                local added = 0
                G.E_MANAGER:add_event(Event({
                    func = function()
                        for i = 1, effective_quests do
                            if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                                local _card = create_card('Quest', G.consumeables, nil, nil, nil, nil, nil, 'murloc_holmes')
                                _card:add_to_deck()
                                G.consumeables:emplace(_card)
                                G.GAME.consumeable_buffer = 0
                                added = added + 1
                            end
                        end
                        return true
                    end
                }))
                if effective_quests > 0 then
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
    faction = {"Pirate"},
    race = {"Goblin"},
    class = {"Warrior"},
    weapon = {"Axe", "Fist Weapons"},
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {"Engineer"},
    combo = {"Edwin Vancleef", "Captain Greenskin", "Mr. Smite"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 6,
    index = 239,
    config = { extra = { jokers = 1, jokers_per_level = 0.2, jokers_per_ilvl = 0.1 } },
    loc_txt = {
        "When this Joker is",
        "{C:attention}sold{} or {C:red}destroyed{},",
        "it creates {C:attention}#1#{} random",
        "{C:attention}Joker(s){} to take its place"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.jokers, card.ability.extra.jokers_per_level, card.ability.extra.jokers_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if (context.selling_self or (context.joker_type_destroyed and context.card == card)) and not context.blueprint then
            local effective_jokers = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.jokers, card.ability.extra.jokers_per_level, card.ability.extra.jokers_per_ilvl))
            G.E_MANAGER:add_event(Event({
                func = function()
                    for i = 1, effective_jokers do
                        if #G.jokers.cards < G.jokers.config.card_limit then
                            local new_card = create_card('Joker', G.jokers, nil, nil, nil, nil, nil, 'sneed')
                            new_card:add_to_deck()
                            G.jokers:emplace(new_card)
                            new_card:start_materialize()
                        end
                    end
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
    damage = {"Nature"},
    armor = {"Cloth"},
    profession = {"Alchemist"},
    combo = {"Onyxia", "Katrana Prestor", "Marin Noggenfogger"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 6,
    index = 240,
    config = { extra = { x_mult_per = 0.5, x_mult_per_per_level = 0.1, x_mult_per_per_ilvl = 0.1 } },
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
                if not unique_types[set] then unique_types[set] = true; count = count + 1 end
            end
        end
        local effective_per = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_per, card.ability.extra.x_mult_per_per_level, card.ability.extra.x_mult_per_per_ilvl)
        return { effective_per, 1 + (count * effective_per) }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local unique_types = {}
            local count = 0
            if G.consumeables and G.consumeables.cards then
                for _, v in ipairs(G.consumeables.cards) do
                    local set = v.ability.set
                    if not unique_types[set] then unique_types[set] = true; count = count + 1 end
                end
            end
            local effective_per = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_per, card.ability.extra.x_mult_per_per_level, card.ability.extra.x_mult_per_per_ilvl)
            local total_xmult = 1 + (count * effective_per)
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
    damage = {"Nature"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Mutanus the Devourer", "Murky", "Old Murk-Eye", "Thrall"},
    role = {"Healer"},
    rarity = 2,
    cost = 6,
    index = 241,
    config = { extra = { mult_per_tarot = 2, mult_per_tarot_per_level = 0.2, mult_per_tarot_per_ilvl = 0.1 } },
    loc_txt = {
        "Played {C:attention}2s, 3s, and 4s{} give",
        "{C:mult}+#1#{} Mult for each",
        "{C:tarot}Tarot{} card used this run",
        "{C:inactive}(Currently {C:mult}+#2#{C:inactive} Mult){}"
    },
    loc_vars = function(self, info_queue, card)
        local tarot_count = (G.GAME and G.GAME.consumeable_usage_total and G.GAME.consumeable_usage_total.tarot) or 0
        local effective_per = Warcraft.get_scaled_gain(card, card.ability.extra.mult_per_tarot, card.ability.extra.mult_per_tarot_per_level, card.ability.extra.mult_per_tarot_per_ilvl)
        return { vars = { effective_per, tarot_count * effective_per } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            local id = played_card:get_id()
            if id == 2 or id == 3 or id == 4 then
                local tarot_count = (G.GAME and G.GAME.consumeable_usage_total and G.GAME.consumeable_usage_total.tarot) or 0
                if tarot_count > 0 then
                    local effective_per = Warcraft.get_scaled_gain(card, card.ability.extra.mult_per_tarot, card.ability.extra.mult_per_tarot_per_level, card.ability.extra.mult_per_tarot_per_ilvl)
                    return {
                        mult = tarot_count * effective_per,
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
    weapon = {"Claw"},
    damage = {"Frost"},
    armor = {"Leather"},
    profession = {},
    combo = {"Kel'Thuzad", "Arthas Menethil", "Lich King"},
    role = {"Melee DPS"},
    rarity = 3,
    cost = 8,
    index = 242,
    config = { extra = { blinds_defeated = 0, threshold = 9, threshold_per_level = -0.1, threshold_per_ilvl = -0.05 } },
    loc_txt = {
        "Every {C:attention}#1#{} Blinds beaten,",
        "a random {C:attention}Scourge{} Joker",
        "becomes {C:dark_edition}Negative{}.",
        "{C:inactive}(Blinds defeated: #2#/#1#){}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.threshold, card.ability.extra.threshold_per_level, card.ability.extra.threshold_per_ilvl),
            card.ability.extra.blinds_defeated
        }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.blueprint and not (context.individual or context.repetition) then
            local effective_threshold = math.max(1, math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.threshold, card.ability.extra.threshold_per_level, card.ability.extra.threshold_per_ilvl)))
            card.ability.extra.blinds_defeated = card.ability.extra.blinds_defeated + 1
            if card.ability.extra.blinds_defeated >= effective_threshold then
                card.ability.extra.blinds_defeated = 0
                local scourge_jokers = {}
                if G.jokers and G.jokers.cards then
                    for _, j in ipairs(G.jokers.cards) do
                        if Warcraft.is_faction(j, "Scourge") then
                            if not j.edition or not j.edition.negative then
                                table.insert(scourge_jokers, j)
                            end
                        end
                    end
                end
                if #scourge_jokers > 0 then
                    local target = pseudorandom_element(scourge_jokers, pseudoseed('bigglesworth_' .. G.GAME.round))
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
    name = "Mutanus the Devourer",
    faction = {"Legion"},
    race = {"Murloc", "Demon"},
    class = {"Warrior"},
    weapon = {"Fist"},
    damage = {"Physical"},
    armor = {"Unarmored"},
    profession = {},
    combo = {"Murky", "Old Murk-Eye", "Morgl the Oracle", "Naralex"},
    role = {"Tank"},
    rarity = 2,
    cost = 7,
    index = 243,
    config = { extra = { mult = 0, money_per_sell = 1, money_per_sell_per_level = 0.2, mult_per_sell = 1, mult_per_sell_per_ilvl = 0.2 } },
    loc_txt = {
        "At the end of the {C:attention}Shop phase{},",
        "eat the Joker to the right.",
        "Gain {C:money}$#2#{} and {C:mult}+#3#{} Mult",
        "per point of its {C:money}Sell Value{}.",
        "{C:inactive}(Currently {C:mult}+#1#{C:inactive} Mult){}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.mult,
            Warcraft.get_scaled_gain(card, card.ability.extra.money_per_sell, card.ability.extra.money_per_sell_per_level, 0),
            Warcraft.get_scaled_gain(card, card.ability.extra.mult_per_sell, 0, card.ability.extra.mult_per_sell_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.ending_shop and not context.blueprint then
            local my_pos = nil
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then my_pos = i; break end
            end
            if my_pos and G.jokers.cards[my_pos + 1] then
                local victim = G.jokers.cards[my_pos + 1]
                if not victim.ability.eternal and not victim.getting_sliced then
                    local sell_value = victim.sell_cost
                    local effective_money = Warcraft.get_scaled_gain(card, card.ability.extra.money_per_sell, card.ability.extra.money_per_sell_per_level, 0)
                    local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.mult_per_sell, 0, card.ability.extra.mult_per_sell_per_ilvl)
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            ease_dollars(math.floor(sell_value * effective_money))
                            card.ability.extra.mult = card.ability.extra.mult + (sell_value * effective_mult)
                            victim.getting_sliced = true
                            victim:start_dissolve({remove_as_card = true})
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
    damage = {"Physical"},
    armor = {"Unarmored"},
    profession = {},
    combo = {"Mutanus", "Old Murk-Eye", "Morgl the Oracle"},
    role = {"Tank"},
    rarity = 1,
    cost = 3,
    index = 244,
    config = { extra = { chips_per_rank = 5, chips_per_rank_per_level = 1, mult_per_suit = 1, mult_per_suit_per_ilvl = 0.2 } },
    loc_txt = {
        "{C:chips}+#1#{} Chips for each card in your",
        "deck matching the {C:attention}Rank{}",
        "of the first scored card",
        "{C:mult}+#2#{} Mult for each card in your",
        "deck matching the {C:attention}Suit{}",
        "of the first scored card"
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.chips_per_rank, card.ability.extra.chips_per_rank_per_level, 0),
            Warcraft.get_scaled_gain(card, card.ability.extra.mult_per_suit, 0, card.ability.extra.mult_per_suit_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            if not context.scoring_hand or #context.scoring_hand == 0 then return end
            local first_card = context.scoring_hand[1]
            local target_rank = first_card.base.id
            local target_suit = first_card.base.suit
            local rank_count = 0
            local suit_count = 0
            for _, c in ipairs(G.playing_cards) do
                if c.base.id == target_rank then rank_count = rank_count + 1 end
                if c:is_suit(target_suit) then suit_count = suit_count + 1 end
            end
            local effective_chips = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.chips_per_rank, card.ability.extra.chips_per_rank_per_level, 0))
            local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.mult_per_suit, 0, card.ability.extra.mult_per_suit_per_ilvl)
            local total_chips = rank_count * effective_chips
            local total_mult = suit_count * effective_mult
            if total_chips > 0 or total_mult > 0 then
                return {
                    chips = total_chips,
                    mult = total_mult,
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
    damage = {"Nature"},
    armor = {"Leather"},
    profession = {},
    combo = {"Tur Ragepaw", "Bristlesnarl", "Elder Brandlemar", "Elder Jari", "Frostfur"},
    role = {"Healer"},
    rarity = 1,
    cost = 3,
    index = 245,
    config = { extra = { used_this_blind = false, cards = 1, cards_per_level = 0.2, cards_per_ilvl = 0.1, cards_converted_this_blind = 0 } },
    loc_txt = {
        "The first {C:attention}#1#{} card(s) drawn",
        "each Blind become",
        "{C:attention}Wild Cards{}"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_wild
        return { Warcraft.get_scaled_gain(card, card.ability.extra.cards, card.ability.extra.cards_per_level, card.ability.extra.cards_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.setting_blind then
            card.ability.extra.cards_converted_this_blind = 0
        end

        if context.hand_drawn and not context.blueprint then
            local effective_cards = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.cards, card.ability.extra.cards_per_level, card.ability.extra.cards_per_ilvl))
            if card.ability.extra.cards_converted_this_blind < effective_cards and #context.hand_drawn > 0 then
                -- Convert from the top of the deck (last index = first drawn)
                local remaining = effective_cards - card.ability.extra.cards_converted_this_blind
                local to_convert = math.min(remaining, #context.hand_drawn)
                for i = #context.hand_drawn, #context.hand_drawn - to_convert + 1, -1 do
                    local target_card = context.hand_drawn[i]
                    card.ability.extra.cards_converted_this_blind = card.ability.extra.cards_converted_this_blind + 1
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            target_card:set_ability(G.P_CENTERS.m_wild, nil, true)
                            target_card:juice_up()
                            return true
                        end
                    }))
                end
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
    damage = {"Physical"},
    armor = {"Leather"},
    profession = {},
    combo = {"Tur Ragepaw", "Blackseed", "Elder Brandlemar", "Elder Jari", "Frostfur"},
    role = {"Melee DPS"},
    rarity = 1,
    cost = 4,
    index = 246,
    config = { extra = { mult = 0, mult_gain = 8, mult_gain_per_level = 1, mult_gain_per_ilvl = 0.5, mult_loss = 1 } },
    loc_txt = {
        "{C:mult}+#1#{} Mult",
        "Each round you win {C:attention}without discarding{},",
        "permanently gain {C:mult}+#2#{}.",
        "If you do discard, lose {C:mult}-#3#{}.",
        "{C:inactive}(Currently {C:mult}+#1#{C:inactive} Mult){}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.mult,
            Warcraft.get_scaled_gain(card, card.ability.extra.mult_gain, card.ability.extra.mult_gain_per_level, card.ability.extra.mult_gain_per_ilvl),
            card.ability.extra.mult_loss
        }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not (context.individual or context.repetition) and not context.blueprint then
            if G.GAME.current_round.discards_used == 0 then
                local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.mult_gain, card.ability.extra.mult_gain_per_level, card.ability.extra.mult_gain_per_ilvl)
                card.ability.extra.mult = card.ability.extra.mult + effective_gain
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
    damage = {"Nature"},
    armor = {"Leather"},
    profession = {},
    combo = {"Tur Ragepaw", "Blackseed", "Bristlesnarl", "Elder Jari", "Frostfur"},
    role = {"Healer"},
    rarity = 2,
    cost = 6,
    index = 247,
    config = { extra = { chips = 0, gain = 20, gain_per_level = 5, gain_per_ilvl = 3 } },
    loc_txt = {
        "{C:chips}+#1#{} Chips",
        "Each {C:planet}Planet{} card used",
        "gives permanent {C:chips}+#2#{} Chips"
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.chips,
            Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.using_consumeable and not context.blueprint then
            if context.consumeable.ability.set == 'Planet' then
                local effective_gain = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl))
                card.ability.extra.chips = card.ability.extra.chips + effective_gain
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
    damage = {"Nature"},
    armor = {"Leather"},
    profession = {},
    combo = {"Tur Ragepaw", "Blackseed", "Bristlesnarl", "Elder Brandlemar", "Frostfur"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 5,
    index = 248,
    config = { extra = { level_up = 1, level_up_per_level = 0.2, level_up_per_ilvl = 0.1 } },
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
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.level_up, card.ability.extra.level_up_per_level, card.ability.extra.level_up_per_ilvl),
            lvl
        }
    end,
    calculate = function(self, card, context)
        if context.using_consumeable and not context.blueprint then
            if context.consumeable.ability.set == 'Tarot' then
                local effective_level = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.level_up, card.ability.extra.level_up_per_level, card.ability.extra.level_up_per_ilvl))
                G.E_MANAGER:add_event(Event({
                    func = function()
                        level_up_hand(card, "Straight", false, effective_level)
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
    damage = {"Frost"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Tur Ragepaw", "Blackseed", "Bristlesnarl", "Elder Brandlemar", "Elder Jari"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 6,
    index = 249,
    config = { extra = { chips = 50, chips_per_ilvl = 10, cards = 1, cards_per_level = 0.3 } },
    loc_txt = {
        "If you end the round with {C:attention}unused discards{},",
        "{C:attention}#2#{} random card(s) held in hand",
        "permanently gain {C:chips}+#1#{} Chips."
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.chips, 0, card.ability.extra.chips_per_ilvl),
            Warcraft.get_scaled_gain(card, card.ability.extra.cards, card.ability.extra.cards_per_level, 0)
        }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not (context.individual or context.repetition) and not context.blueprint then
            if G.GAME.current_round.discards_left > 0 then
                if G.hand and G.hand.cards and #G.hand.cards > 0 then
                    local effective_chips = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.chips, 0, card.ability.extra.chips_per_ilvl))
                    local effective_cards = math.min(math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.cards, card.ability.extra.cards_per_level, 0)), #G.hand.cards)
                    local available = {}
                    for _, c in ipairs(G.hand.cards) do table.insert(available, c) end
                    for i = 1, effective_cards do
                        if #available == 0 then break end
                        local target_card = pseudorandom_element(available, pseudoseed('frostfur_' .. i .. '_' .. G.GAME.round))
                        for j = #available, 1, -1 do
                            if available[j] == target_card then table.remove(available, j); break end
                        end
                        target_card.ability.perma_bonus = (target_card.ability.perma_bonus or 0) + effective_chips
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
                    end
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
    race = {"Human", "Undead"},
    class = {"Paladin", "Death Knight"},
    weapon = {"Sword"},
    damage = {"Holy", "Shadow"},
    armor = {"Plate"},
    profession = {},
    combo = {"Darion Mograine", "Kel'Thuzad", "Magni Bronzebeard", "Lich King"},
    role = {"Tank"},
    rarity = 2,
    cost = 8,
    index = 250,
    config = { extra = { x_mult = 1, gain = 1, gain_per_level = 0.2, gain_per_ilvl = 0.2 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "Gains {X:mult,C:white} X#2# {} Mult",
        "each time you beat a {C:attention}Boss Blind{}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.x_mult,
            Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and context.beat_boss and not context.blueprint then
            local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl)
            card.ability.extra.x_mult = card.ability.extra.x_mult + effective_gain
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
    faction = {"Horde", "Pirate"},
    race = {"Human","Undead"},
    class = {"Rogue"}, 
    weapon = {"Sword"},
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {},
    combo = {"Fleet Admiral Tethys", "Captain Hooktusk", "Admiral Taylor"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 6,
    index = 251,
    config = { extra = { x_mult = 3, x_mult_per_level = 0.3, threshold = 15, threshold_per_ilvl = -0.2 } },
    loc_txt = {
        "If you have {C:money}$#1#{} or more",
        "during scoring, gain {X:mult,C:white} X#2# {} Mult"
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.threshold, 0, card.ability.extra.threshold_per_ilvl),
            Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, 0)
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local effective_threshold = Warcraft.get_scaled_gain(card, card.ability.extra.threshold, 0, card.ability.extra.threshold_per_ilvl)
            if G.GAME.dollars >= effective_threshold then
                return {
                    message = "Plunder!",
                    Xmult_mod = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, 0),
                    colour = G.C.MULT,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Fleet Admiral Tethys",
    faction = {"Horde", "Pirate"},
    race = {"Human"},
    class = {"Rogue"},
    weapon = {"Sword"},
    damage = {"Physical"},
    armor = {"Leather"},
    profession = {},
    combo = {"Dread Admiral Eliza", "Captain Hooktusk", "Tess Greymane", "Lilian Voss", "Mathias Shaw"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 7,
    index = 252,
    config = { extra = { hand_size_per_equip = 1, hand_size_per_equip_per_level = 0.1, hand_size_per_equip_per_ilvl = 0.05, current_bonus = 0 } },
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
                if j.ability.wow_equipment then count = count + 1 end
            end
        end
        local effective_per = Warcraft.get_scaled_gain(card, card.ability.extra.hand_size_per_equip, card.ability.extra.hand_size_per_equip_per_level, card.ability.extra.hand_size_per_equip_per_ilvl)
        return { effective_per, count * effective_per }
    end,
    add_to_deck = function(self, card, from_debuff)
        card.ability.extra.current_bonus = 0
    end,
    remove_from_deck = function(self, card, from_debuff)
        if card.ability.extra.current_bonus and card.ability.extra.current_bonus > 0 then
            G.hand:change_size(-card.ability.extra.current_bonus)
        end
    end,
    calculate = function(self, card, context)
        if context.setting_blind or context.starting_shop then
            local count = 0
            for _, j in ipairs(G.jokers.cards) do
                if j.ability.wow_equipment then count = count + 1 end
            end
            local effective_per = Warcraft.get_scaled_gain(card, card.ability.extra.hand_size_per_equip, card.ability.extra.hand_size_per_equip_per_level, card.ability.extra.hand_size_per_equip_per_ilvl)
            local target_bonus = math.floor(count * effective_per)
            local current_bonus = card.ability.extra.current_bonus or 0
            if target_bonus ~= current_bonus then
                G.hand:change_size(target_bonus - current_bonus)
                card.ability.extra.current_bonus = target_bonus
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Taoshi",
    faction = {"Horde"},
    race = {"Pandaren"},
    class = {"Rogue"},
    weapon = {"Daggers"},
    damage = {"Physical"},
    armor = {"Mail"},
    profession = {},
    combo = {"Taran Zhu", "Niuzao", "Mathias Shaw", "Lei-Shen", "Chen Stormstout", "Li Li Stormstout"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 6,
    index = 253,
    config = { extra = { x_mult = 3, x_mult_per_level = 0.3, x_mult_per_ilvl = 0.3, hand_size = 2 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult if played",
        "hand contains exactly",
        "{C:attention}#2# cards{}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
            card.ability.extra.hand_size
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            if context.full_hand and #context.full_hand == card.ability.extra.hand_size then
                return {
                    message = "Hidden Blade!",
                    Xmult_mod = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
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
    damage = {"Holy"},
    armor = {"Plate"},
    profession = {},
    combo = {"Varian Wrynn", "Yrel", "Garona Halforcen", "Blackhand"},
    role = {"Tank"},
    rarity = 2,
    cost = 6,
    index = 254,
    config = { extra = { x_mult = 3, x_mult_per_level = 0.4, x_mult_per_ilvl = 0.2 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult if",
        "your played hand contains",
        "{C:attention}no Face Cards{}"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl) }
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
                    Xmult_mod = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
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
    damage = {"Physical"},
    armor = {"Leather"},
    profession = {},
    combo = {"Magtheridon", "Ner'zhul", "Gul'dan", "Grommash Hellscream", "Blackhand", "Illidan Stormrage", "Kilrogg Deadeye"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 6,
    index = 255,
    config = { extra = { x_mult = 1, gain = 0.2, gain_per_level = 0.1, gain_per_ilvl = 0.05 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "Playing an {C:attention}8{} destroys it",
        "and gives permanent {X:mult,C:white} +X#2# {} Mult",
        "{C:inactive}(Currently X#1#){}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.x_mult,
            Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local cards_to_destroy = {}
            for _, played_card in ipairs(context.full_hand) do
                if played_card:get_id() == 8 and not played_card.dissolving then
                    table.insert(cards_to_destroy, played_card)
                end
            end
            if #cards_to_destroy > 0 then
                local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl)
                for _, played_card in ipairs(cards_to_destroy) do
                    card.ability.extra.x_mult = card.ability.extra.x_mult + effective_gain
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            played_card:start_dissolve({remove_as_card = true})
                            return true
                        end
                    }))
                end
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
    damage = {"Holy"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Pelagos", "Anduin Wrynn", "Uther the Lightbringer"},
    role = {"Healer"},
    rarity = 2,
    cost = 6,
    index = 256,
    config = { extra = { mult = 0, gain = 5, gain_per_level = 1, gain_per_ilvl = 1 } },
    loc_txt = {
        "{C:mult}+#1#{} Mult",
        "Gains permanent {C:mult}+#2#{} Mult",
        "whenever the Joker to the right triggers",
        "{C:inactive}(Currently {C:mult}+#1#{C:inactive} Mult){}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.mult,
            Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.post_trigger and not context.blueprint then
            local my_pos = nil
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then my_pos = i; break end
            end
            if my_pos and G.jokers.cards[my_pos + 1] == context.other_card and context.other_ret then
                local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.gain, card.ability.extra.gain_per_level, card.ability.extra.gain_per_ilvl)
                card.ability.extra.mult = card.ability.extra.mult + effective_gain
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

Warcraft.create_warcraft_joker({
    name = "Zalazane",
    faction = {"Horde"},
    race = {"Troll"},
    class = {"Warlock"},
    weapon = {"Staff", "Fist"},
    damage = {"Shadow"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Vol'jin", "Rexxar", "Daelin Proudmoore", "Bwonsamdi"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 5,
    index = 257,
    config = { extra = { mult = 20, mult_per_level = 1, mult_per_ilvl = 0.5 } },
    loc_txt = {
        "At the start of each {C:attention}Blind{},",
        "hex a random card in hand,",
        "permanently {C:red}Debuffing{} it.",
        "{C:attention}Debuffed{} cards give {C:mult}+#1#{} Mult",
        "when played"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            if G.hand and G.hand.cards and #G.hand.cards > 0 then
                local target = pseudorandom_element(G.hand.cards, pseudoseed('zalazane_' .. G.GAME.round))
                G.E_MANAGER:add_event(Event({
                    func = function()
                        target.ability.zalazane_hexed = true
                        target:set_debuff(true)
                        target:juice_up()
                        card_eval_status_text(card, 'extra', nil, nil, nil, {
                            message = "Hexed!",
                            colour = G.C.PURPLE
                        })
                        return true
                    end
                }))
            end
        end

        if context.individual and context.cardarea == G.play then
            if context.other_card.debuff then
                local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl)
                return {
                    mult = effective_mult,
                    card = context.other_card,
                    message = "Hex!",
                    colour = G.C.PURPLE
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Grand Apothecary Putress",
    faction = {"Scourge", "Horde"},
    race = {"Undead"},
    class = {"Warlock"},
    weapon = {"Staff"},
    damage = {"Shadow"},
    armor = {"Leather"},
    profession = {"Alchemist"},
    combo = {"Sylvanas Windrunner", "Varimathras", "Thrall", "Lich King", "Arthas Menethil", "Bolvar Fordragon", "Dranosh Saurfang"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 6,
    index = 258,
    config = { extra = { chance = 4, chance_per_level = -0.2, chance_per_ilvl = -0.1, x_mult = 3, x_mult_per_level = 0.5, x_mult_per_ilvl = 0.3 } },
    loc_txt = {
        "When a card scores,",
        "{C:green}1 in #1#{} chance to {C:red}destroy{} it",
        "and give {X:mult,C:white} X#2# {} Mult"
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.chance, card.ability.extra.chance_per_level, card.ability.extra.chance_per_ilvl),
            Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            local effective_chance = math.max(1, Warcraft.get_scaled_gain(card, card.ability.extra.chance, card.ability.extra.chance_per_level, card.ability.extra.chance_per_ilvl))
            if pseudorandom('putress') < G.GAME.probabilities.normal / effective_chance then
                local effective_x_mult = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl)
                G.E_MANAGER:add_event(Event({
                    func = function()
                        context.other_card:start_dissolve({remove_as_card = true})
                        return true
                    end
                }))
                return {
                    x_mult = effective_x_mult,
                    card = card,
                    message = "New Plague!",
                    colour = G.C.GREEN
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Jeeves",
    race = {"Robot"},
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {"Engineer"},
    combo = {"Reaves", "Blingtron 3000", "Mimiron"},
    role = {"Healer"},
    rarity = 1,
    cost = 4,
    index = 259,
    config = { extra = { money = 5, money_per_level = 0.5, money_per_ilvl = 0.5 } },
    loc_txt = {
        "Each time an {C:attention}Equipment{}",
        "triggers, gain {C:money}$#1#{}"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = {key = 'equipment', set = 'Other'}
        return { Warcraft.get_scaled_gain(card, card.ability.extra.money, card.ability.extra.money_per_level, card.ability.extra.money_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.equipment_trigger and not context.blueprint then
            local effective_money = Warcraft.get_scaled_gain(card, card.ability.extra.money, card.ability.extra.money_per_level, card.ability.extra.money_per_ilvl)
            ease_dollars(effective_money)
            return {
                message = "At Your Service!",
                colour = G.C.MONEY,
                dollars = effective_money,
                card = card
            }
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Reaves",
    race = {"Robot"},
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {"Engineer"},
    combo = {"Jeeves", "Blingtron 3000", "Mimiron"},
    role = {"Healer"},
    rarity = 2,
    cost = 6,
    index = 260,
    config = { extra = { chance = 4, chance_per_level = -0.2, chance_per_ilvl = -0.1 } },
    loc_txt = {
        "Each time an {C:attention}Equipment{}",
        "triggers, {C:green}1 in #1#{} chance to",
        "generate a random {C:attention}Consumable{}"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = {key = 'equipment', set = 'Other'}
        return { Warcraft.get_scaled_gain(card, card.ability.extra.chance, card.ability.extra.chance_per_level, card.ability.extra.chance_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.equipment_trigger and not context.blueprint then
            local effective_chance = math.max(1, Warcraft.get_scaled_gain(card, card.ability.extra.chance, card.ability.extra.chance_per_level, card.ability.extra.chance_per_ilvl))
            if pseudorandom('reaves') < G.GAME.probabilities.normal / effective_chance then
                if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                    G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            local c_types = {'Tarot', 'Planet', 'Equipment'}
                            local chosen_type = pseudorandom_element(c_types, pseudoseed('reaves_type_' .. G.GAME.round))
                            local new_card = create_card(chosen_type, G.consumeables, nil, nil, nil, nil, nil, 'reaves')
                            new_card:add_to_deck()
                            G.consumeables:emplace(new_card)
                            G.GAME.consumeable_buffer = 0
                            return true
                        end
                    }))
                    return {
                        message = "EJECT!",
                        colour = G.C.GREEN,
                        card = card
                    }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "XT-002 Deconstructor",
    race = {"Robot"},
    class = {"Warrior"},
    weapon = {"Hammer"},
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {},
    combo = {"Mimiron", "Freya", "Hodir", "Thorim", "Flame Leviathan"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 6,
    index = 261,
    config = { extra = { base_chips = 100, base_chips_per_level = 10, chips_per_destroy = 30, chips_per_destroy_per_ilvl = 5, current_chips = 100 } },
    loc_txt = {
        "Scoring {C:hearts}Hearts{} give",
        "{C:chips}+#1#{} Chips",
        "{C:inactive}(+#2#{C:inactive} per card destroyed,",
        "{C:attention}#3#{C:inactive} destroyed this run){}"
    },
    loc_vars = function(self, info_queue, card)
        local destroyed = G.GAME.warcraft_cards_destroyed or 0
        local effective_per = Warcraft.get_scaled_gain(card, card.ability.extra.chips_per_destroy, 0, card.ability.extra.chips_per_destroy_per_ilvl)
        local effective_base = Warcraft.get_scaled_gain(card, card.ability.extra.base_chips, card.ability.extra.base_chips_per_level, 0)
        local total = math.floor(effective_base + destroyed * effective_per)
        return { total, effective_per, destroyed }
    end,
    add_to_deck = function(self, card, from_debuff)
        -- Retroactively calculate from already destroyed cards
        local destroyed = G.GAME.warcraft_cards_destroyed or 0
        local effective_per = Warcraft.get_scaled_gain(card, card.ability.extra.chips_per_destroy, 0, card.ability.extra.chips_per_destroy_per_ilvl)
        local effective_base = Warcraft.get_scaled_gain(card, card.ability.extra.base_chips, card.ability.extra.base_chips_per_level, 0)
        card.ability.extra.current_chips = math.floor(effective_base + destroyed * effective_per)
    end,
    calculate = function(self, card, context)
        -- Update current_chips whenever a card is destroyed
        if context.remove_playing_cards and not context.blueprint then
            if context.removed and #context.removed > 0 then
                -- Increment global counter
                G.GAME.warcraft_cards_destroyed = (G.GAME.warcraft_cards_destroyed or 0) + #context.removed
                local effective_per = Warcraft.get_scaled_gain(card, card.ability.extra.chips_per_destroy, 0, card.ability.extra.chips_per_destroy_per_ilvl)
                card.ability.extra.current_chips = card.ability.extra.current_chips + math.floor(#context.removed * effective_per)
                return {
                    message = "Tantrum!",
                    colour = G.C.RED,
                    card = card
                }
            end
        end

        if context.individual and context.cardarea == G.play then
            if context.other_card:is_suit('Hearts') then
                return {
                    chips = card.ability.extra.current_chips,
                    card = context.other_card,
                    message = "HEARTS!",
                    colour = G.C.HEARTS
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "V-07-TR-0N",
    race = {"Robot"},
    weapon = {"Gun", "Fist"},
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {},
    combo = {"XT-002 Deconstructor", "Mimiron", "Freya", "Hodir", "Thorim", "Flame Leviathan"},
    role = {"Tank"},
    rarity = 3,
    cost = 10,
    index = 262,
    config = { extra = { retrigger = 4, retrigger_per_level = 0.3, retrigger_per_ilvl = 0.2, chips = 50, chips_per_level = 5, chips_per_ilvl = 5 } },
    loc_txt = {
        "If played hand is exactly a",
        "{C:attention}Four of a Kind{}, all scoring",
        "cards retrigger {C:attention}#1#{} times",
        "and give {C:chips}+#2#{} Chips"
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.retrigger, card.ability.extra.retrigger_per_level, card.ability.extra.retrigger_per_ilvl),
            Warcraft.get_scaled_gain(card, card.ability.extra.chips, card.ability.extra.chips_per_level, card.ability.extra.chips_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            if context.scoring_name == "Four of a Kind" then
                return {
                    message = "V-07-TR-0N!",
                    repetitions = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.retrigger, card.ability.extra.retrigger_per_level, card.ability.extra.retrigger_per_ilvl)),
                    card = card
                }
            end
        end

        if context.individual and context.cardarea == G.play then
            if context.scoring_name == "Four of a Kind" then
                return {
                    chips = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.chips, card.ability.extra.chips_per_level, card.ability.extra.chips_per_ilvl)),
                    card = context.other_card,
                    message = "COMBINE!",
                    colour = G.C.CHIPS
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Trilliax",
    race = {"Robot"},
    weapon = {"Fist"},
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {},
    combo = {"Grand Magistrix Elisande", "Gul'dan", "Thalyssra"},
    role = {"Tank"},
    rarity = 2,
    cost = 6,
    index = 263,
    config = { extra = {
        x_mult_per_seal = 0.3, x_mult_per_seal_per_level = 0.05, x_mult_per_seal_per_ilvl = 0.03,
        chips_per_enhancement = 30, chips_per_enhancement_per_level = 5, chips_per_enhancement_per_ilvl = 3,
        mult_per_edition = 8, mult_per_edition_per_level = 1, mult_per_edition_per_ilvl = 0.5
    } },
    loc_txt = {
        "Scoring cards lose their {C:attention}Enhancement{},",
        "{C:attention}Edition{} and {C:attention}Seal{}.",
        "Gain {X:mult,C:white} X#1# {} per Seal,",
        "{C:chips}+#2#{} Chips per Enhancement,",
        "{C:mult}+#3#{} Mult per Edition removed.",
        "{C:attention}Debuffed{} cards trigger all three."
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_per_seal, card.ability.extra.x_mult_per_seal_per_level, card.ability.extra.x_mult_per_seal_per_ilvl),
            Warcraft.get_scaled_gain(card, card.ability.extra.chips_per_enhancement, card.ability.extra.chips_per_enhancement_per_level, card.ability.extra.chips_per_enhancement_per_ilvl),
            Warcraft.get_scaled_gain(card, card.ability.extra.mult_per_edition, card.ability.extra.mult_per_edition_per_level, card.ability.extra.mult_per_edition_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            local other = context.other_card
            local is_debuffed = other.debuff

            local has_seal = other:get_seal() ~= nil
            local has_enhancement = other.config.center.set == 'Enhanced'
            local has_edition = other.edition ~= nil

            -- Debuffed cards trigger all three regardless
            local triggers_seal = has_seal or is_debuffed
            local triggers_enhancement = has_enhancement or is_debuffed
            local triggers_edition = has_edition or is_debuffed

            if not triggers_seal and not triggers_enhancement and not triggers_edition then return end

            local effective_x_mult = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_per_seal, card.ability.extra.x_mult_per_seal_per_level, card.ability.extra.x_mult_per_seal_per_ilvl)
            local effective_chips = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.chips_per_enhancement, card.ability.extra.chips_per_enhancement_per_level, card.ability.extra.chips_per_enhancement_per_ilvl))
            local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.mult_per_edition, card.ability.extra.mult_per_edition_per_level, card.ability.extra.mult_per_edition_per_ilvl)

            G.E_MANAGER:add_event(Event({
                func = function()
                    if triggers_seal and has_seal then
                        other:set_seal(nil, true)
                    end
                    if triggers_enhancement and has_enhancement then
                        other:set_ability(G.P_CENTERS.c_base, nil, true)
                    end
                    if triggers_edition and has_edition then
                        other:set_edition(nil, true)
                    end
                    if is_debuffed then
                        other:set_debuff(false)
                    end
                    other:juice_up()
                    return true
                end
            }))

            -- Build result with all applicable bonuses
            local result = { card = card, message = "Cleansed!", colour = G.C.WHITE }
            if triggers_x_mult then result.x_mult = effective_x_mult end
            if triggers_chips then result.chips = effective_chips end
            if triggers_mult then result.mult = effective_mult end

            -- Compose the actual return based on what triggered
            local total_chips = triggers_enhancement and effective_chips or 0
            local total_mult = triggers_edition and effective_mult or 0
            local total_x_mult = triggers_seal and effective_x_mult or 1

            if total_x_mult > 1 or total_chips > 0 or total_mult > 0 then
                return {
                    chips = total_chips > 0 and total_chips or nil,
                    mult = total_mult > 0 and total_mult or nil,
                    x_mult = total_x_mult > 1 and total_x_mult or nil,
                    card = card,
                    message = is_debuffed and "Purified!" or "Cleansed!",
                    colour = G.C.WHITE
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Arcanotron",
    race = {"Robot"},
    class = {"Mage"},
    weapon = {"Fist"},
    damage = {"Arcane"},
    armor = {"Plate"},
    profession = {},
    combo = {"Electron", "Magmatron", "Toxitron"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 5,
    index = 264,
    config = { extra = { x_mult = 1, x_mult_gain = 0.25, x_mult_gain_per_level = 0.05, x_mult_gain_per_ilvl = 0.03 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "Scoring cards with a {C:blue}Blue Seal{}",
        "give {X:mult,C:white} X#2# {} Mult permanently",
        "and change to a {C:purple}Purple Seal{}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.x_mult,
            Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_gain, card.ability.extra.x_mult_gain_per_level, card.ability.extra.x_mult_gain_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            local played_card = context.other_card
            
            if played_card:get_seal() == 'Blue' then
                local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_gain, card.ability.extra.x_mult_gain_per_level, card.ability.extra.x_mult_gain_per_ilvl)
                card.ability.extra.x_mult = card.ability.extra.x_mult + effective_gain
                
                G.E_MANAGER:add_event(Event({
                    func = function()
                        played_card:set_seal('Purple', true, true)
                        played_card:juice_up()
                        return true
                    end
                }))
                
                return {
                    message = "Arcane Power!",
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
    name = "Electron",
    race = {"Robot"},
    class = {"Shaman"},
    weapon = {"Fist"},
    damage = {"Nature"},
    armor = {"Plate"},
    profession = {},
    combo = {"Arcanotron", "Magmatron", "Toxitron"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 5,
    index = 265,
    config = { extra = { x_mult = 1, x_mult_gain = 0.25, x_mult_gain_per_level = 0.05, x_mult_gain_per_ilvl = 0.03 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "Scoring cards with a {C:money}Gold Seal{}",
        "give {X:mult,C:white} X#2# {} Mult permanently",
        "and change to a {C:blue}Blue Seal{}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.x_mult,
            Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_gain, card.ability.extra.x_mult_gain_per_level, card.ability.extra.x_mult_gain_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            local played_card = context.other_card

            if played_card:get_seal() == 'Gold' then
                local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_gain, card.ability.extra.x_mult_gain_per_level, card.ability.extra.x_mult_gain_per_ilvl)
                card.ability.extra.x_mult = card.ability.extra.x_mult + effective_gain
                G.E_MANAGER:add_event(Event({
                    func = function()
                        played_card:set_seal('Blue', true, true)
                        played_card:juice_up()
                        return true
                    end
                }))
                return {
                    message = "Static Charge!",
                    colour = G.C.BLUE,
                    card = card
                }
            end
        end

        if context.joker_main then
            if card.ability.extra.x_mult > 1 then
                return {
                    Xmult_mod = card.ability.extra.x_mult,
                    colour = G.C.BLUE
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Magmatron",
    race = {"Robot"},
    class = {"Warrior"},
    weapon = {"Fist"},
    damage = {"Fire"},
    armor = {"Plate"},
    profession = {},
    combo = {"Arcanotron", "Electron", "Toxitron"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 5,
    index = 266,
    config = { extra = { x_mult = 1, x_mult_gain = 0.25, x_mult_gain_per_level = 0.05, x_mult_gain_per_ilvl = 0.03 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "Scoring cards with a {C:red}Red Seal{}",
        "give {X:mult,C:white} X#2# {} Mult permanently",
        "and change to a {C:money}Gold Seal{}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.x_mult,
            Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_gain, card.ability.extra.x_mult_gain_per_level, card.ability.extra.x_mult_gain_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            local played_card = context.other_card

            if played_card:get_seal() == 'Red' then
                local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_gain, card.ability.extra.x_mult_gain_per_level, card.ability.extra.x_mult_gain_per_ilvl)
                card.ability.extra.x_mult = card.ability.extra.x_mult + effective_gain
                G.E_MANAGER:add_event(Event({
                    func = function()
                        played_card:set_seal('Gold', true, true)
                        played_card:juice_up()
                        return true
                    end
                }))
                return {
                    message = "Molten Core!",
                    colour = G.C.ORANGE,
                    card = card
                }
            end
        end

        if context.joker_main then
            if card.ability.extra.x_mult > 1 then
                return {
                    Xmult_mod = card.ability.extra.x_mult,
                    colour = G.C.ORANGE
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Toxitron",
    race = {"Robot"},
    class = {"Warlock"},
    weapon = {"Fist"},
    damage = {"Nature"},
    armor = {"Plate"},
    profession = {},
    combo = {"Arcanotron", "Electron", "Magmatron"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 5,
    index = 267,
    config = { extra = { x_mult = 1, x_mult_gain = 0.25, x_mult_gain_per_level = 0.05, x_mult_gain_per_ilvl = 0.03 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "Scoring cards with a {C:purple}Purple Seal{}",
        "give {X:mult,C:white} X#2# {} Mult permanently",
        "and change to a {C:red}Red Seal{}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.x_mult,
            Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_gain, card.ability.extra.x_mult_gain_per_level, card.ability.extra.x_mult_gain_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            local played_card = context.other_card

            if played_card:get_seal() == 'Purple' then
                local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_gain, card.ability.extra.x_mult_gain_per_level, card.ability.extra.x_mult_gain_per_ilvl)
                card.ability.extra.x_mult = card.ability.extra.x_mult + effective_gain
                G.E_MANAGER:add_event(Event({
                    func = function()
                        played_card:set_seal('Red', true, true)
                        played_card:juice_up()
                        return true
                    end
                }))
                return {
                    message = "Toxic Waste!",
                    colour = G.C.GREEN,
                    card = card
                }
            end
        end

        if context.joker_main then
            if card.ability.extra.x_mult > 1 then
                return {
                    Xmult_mod = card.ability.extra.x_mult,
                    colour = G.C.GREEN
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Fel Reaver",
    faction = {"Legion"},
    race = {"Demon"},
    weapon = {"Fist"},
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {},
    combo = {"Illidan Stormrage", "Magtheridon", "Kil'Jaeden"},
    role = {"Tank"},
    rarity = 2,
    cost = 6,
    index = 268,
    config = { extra = { x_mult = 2, x_mult_per_level = 0.3, x_mult_per_ilvl = 0.2, h_size = -1 } },
    loc_txt = {
        "Scoring {C:attention}Steel Cards{}",
        "give {X:mult,C:white} X#1# {} Mult",
        "{C:attention}#2#{} Hand Size"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_steel
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
            card.ability.extra.h_size
        }
    end,
    add_to_deck = function(self, card, from_debuff)
        G.hand:change_size(card.ability.extra.h_size)
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.hand:change_size(-card.ability.extra.h_size)
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card.config.center == G.P_CENTERS.m_steel then
                return {
                    x_mult = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
                    card = context.other_card,
                    message = "STOMP!",
                    colour = G.C.GREEN
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Iron Juggernaut",
    faction = {"Horde"},
    race = {"Robot"},
    class = {"Warrior"},
    weapon = {"Hammer"},
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {},
    combo = {"Gamon", "Garrosh Hellscream", "Nazgrim"},
    role = {"Melee DPS"},
    rarity = 3,
    cost = 8,
    index = 269,
    config = { extra = { x_mult = 5, x_mult_per_level = 1, x_mult_per_ilvl = 0.5, base_chance = 6, chance_per_horde = 1 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "{C:green}1 in #2#{} chance to {C:red}self destruct{}",
        "each hand played.",
        "{C:attention}+#3#{} to chance per {C:attention}Horde{} Joker",
        "{C:inactive}(Currently {C:green}1 in #4#{C:inactive}){}"
    },
    loc_vars = function(self, info_queue, card)
        local horde_count = 0
        if G.jokers then
            for _, j in ipairs(G.jokers.cards) do
                if j ~= card and Warcraft.is_faction(j, "Horde") then
                    horde_count = horde_count + 1
                end
            end
        end
        local effective_chance = card.ability.extra.base_chance + (horde_count * card.ability.extra.chance_per_horde)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
            card.ability.extra.base_chance,
            card.ability.extra.chance_per_horde,
            effective_chance
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                x_mult = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
                card = card
            }
        end

        if context.after and not context.blueprint then
            local horde_count = 0
            for _, j in ipairs(G.jokers.cards) do
                if j ~= card and Warcraft.is_faction(j, "Horde") then
                    horde_count = horde_count + 1
                end
            end
            local effective_chance = card.ability.extra.base_chance + (horde_count * card.ability.extra.chance_per_horde)
            
            if pseudorandom('iron_juggernaut') < G.GAME.probabilities.normal / effective_chance then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('tarot1')
                        card.T.r = -0.2
                        card:juice_up(0.3, 0.4)
                        
                        card_eval_status_text(card, 'extra', nil, nil, nil, {
                            message = "KABOOM!",
                            colour = G.C.RED
                        })
                        
                        card:start_dissolve({remove_as_card = true})
                        return true
                    end
                }))
            else
                return {
                    message = "For the Horde!",
                    colour = G.C.RED,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "MOTHER",
    faction = {"Alliance"},
    race = {"Robot"},
    weapon = {"Fist"},
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {},
    combo = {"Brann Bronzebeard", "N'Zoth", "G'huun", "Hir'eek"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 6,
    index = 270,
    config = { extra = { x_mult_per_card = 1.2, x_mult_per_card_per_level = 0.05, x_mult_per_card_per_ilvl = 0.03 } },
    loc_txt = {
        "{C:attention}Debuffed{} cards held in hand",
        "each give {X:mult,C:white} X#1# {} Mult",
        "{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult){}"
    },
    loc_vars = function(self, info_queue, card)
        local debuff_count = 0
        if G.hand and G.hand.cards then
            for _, c in ipairs(G.hand.cards) do
                if c.debuff then debuff_count = debuff_count + 1 end
            end
        end
        local effective_per = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_per_card, card.ability.extra.x_mult_per_card_per_level, card.ability.extra.x_mult_per_card_per_ilvl)
        local total = 1
        for i = 1, debuff_count do total = total * effective_per end
        return { effective_per, total }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local debuff_count = 0
            if G.hand and G.hand.cards then
                for _, c in ipairs(G.hand.cards) do
                    if c.debuff then debuff_count = debuff_count + 1 end
                end
            end
            if debuff_count > 0 then
                local effective_per = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_per_card, card.ability.extra.x_mult_per_card_per_level, card.ability.extra.x_mult_per_card_per_ilvl)
                local total_x_mult = 1
                for i = 1, debuff_count do
                    total_x_mult = total_x_mult * effective_per
                end
                return {
                    Xmult_mod = total_x_mult,
                    message = "Filtered!",
                    colour = G.C.RED,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "King Mechagon",
    race = {"Gnome"},
    class = {"Warrior"},
    weapon = {"Gun", "Hammer"},
    damage = {"Nature"},
    armor = {"Plate"},
    profession = {"Engineer"},
    combo = {"Tinkmaster Overspark", "Gazlowe", "Gelbin Mekkatorque"},
    role = {"Tank"},
    rarity = 3,
    cost = 8,
    index = 271,
    config = { extra = { chance = 4, chance_per_level = -0.2, chance_per_ilvl = -0.1 } },
    loc_txt = {
        "Scoring {C:attention}non-enhanced{} cards have",
        "{C:green}1 in #1#{} chance to become {C:attention}Steel{}.",
        "Scoring {C:attention}Steel Cards{} have",
        "{C:green}1 in #1#{} chance to gain a random {C:dark_edition}Edition{}",
        "and {C:green}1 in #1#{} chance to gain a random {C:attention}Seal{}"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_steel
        return { Warcraft.get_scaled_gain(card, card.ability.extra.chance, card.ability.extra.chance_per_level, card.ability.extra.chance_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            local other = context.other_card
            local effective_chance = math.max(1, Warcraft.get_scaled_gain(card, card.ability.extra.chance, card.ability.extra.chance_per_level, card.ability.extra.chance_per_ilvl))
            local changed = false

            -- Non-enhanced card → chance to become Steel
            if other.config.center == G.P_CENTERS.c_base then
                if pseudorandom('mechagon_steel') < G.GAME.probabilities.normal / effective_chance then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            other:set_ability(G.P_CENTERS.m_steel, nil, true)
                            other:juice_up()
                            return true
                        end
                    }))
                    changed = true
                end
            end

            -- Steel card → chance for edition
            if other.config.center == G.P_CENTERS.m_steel then
                if pseudorandom('mechagon_edition') < G.GAME.probabilities.normal / effective_chance then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            local edition = poll_edition('mechagon_ed_' .. G.GAME.round, nil, true, true)
                            if edition then
                                other:set_edition(edition, true)
                                other:juice_up()
                            end
                            return true
                        end
                    }))
                    changed = true
                end

                -- Steel card → chance for seal
                if pseudorandom('mechagon_seal') < G.GAME.probabilities.normal / effective_chance then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            if not other:get_seal() then
                                local seals = {"Red", "Blue", "Gold", "Purple"}
                                local chosen = pseudorandom_element(seals, pseudoseed('mechagon_seal_type_' .. G.GAME.round))
                                other:set_seal(chosen, true, true)
                                other:juice_up()
                            end
                            return true
                        end
                    }))
                    changed = true
                end
            end

            if changed then
                return {
                    message = "Mechanized!",
                    colour = G.C.GREY,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "The Curator",
    race = {"Robot"},
    weapon = {"First"},
    damage = {"Nature"},
    armor = {"Plate"},
    profession = {},
    combo = {"Medivh","Moroes","Khadgar"},
    role = {"Tank"},
    rarity = 3,
    cost = 9,
    index = 272,
    config = { extra = {
        x_mult_per_faction = 0.2, x_mult_per_faction_per_level = 0.05, x_mult_per_faction_per_ilvl = 0.03,
        x_chips_per_weapon = 0.2, x_chips_per_weapon_per_level = 0.05, x_chips_per_weapon_per_ilvl = 0.03,
        mult_per_race = 3, mult_per_race_per_level = 0.5, mult_per_race_per_ilvl = 0.3,
        chips_per_class = 20, chips_per_class_per_level = 3, chips_per_class_per_ilvl = 2
    } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult per unique {C:attention}Faction{}",
        "{X:chips,C:white} X#2# {} Chips per unique {C:attention}Weapon{}",
        "{C:mult}+#3#{} Mult per unique {C:attention}Race{}",
        "{C:chips}+#4#{} Chips per unique {C:attention}Class{}",
        "{C:inactive}(#5# Factions, #6# Weapons, #7# Races, #8# Classes){}"
    },
    loc_vars = function(self, info_queue, card)
        local factions, weapons, races, classes = {}, {}, {}, {}
        if G.jokers then
            for _, j in ipairs(G.jokers.cards) do
                if j.ability and j.ability.extra then
                    local function count_unique(tbl, attr)
                        local val = j.ability.extra[attr]
                        if type(val) == "table" then
                            for _, v in ipairs(val) do tbl[v] = true end
                        elseif val then
                            tbl[val] = true
                        end
                    end
                    count_unique(factions, "faction")
                    count_unique(weapons, "weapon")
                    count_unique(races, "race")
                    count_unique(classes, "class")
                end
            end
        end
        local fc, wc, rc, cc = 0, 0, 0, 0
        for _ in pairs(factions) do fc = fc + 1 end
        for _ in pairs(weapons) do wc = wc + 1 end
        for _ in pairs(races) do rc = rc + 1 end
        for _ in pairs(classes) do cc = cc + 1 end
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_per_faction, card.ability.extra.x_mult_per_faction_per_level, card.ability.extra.x_mult_per_faction_per_ilvl),
            Warcraft.get_scaled_gain(card, card.ability.extra.x_chips_per_weapon, card.ability.extra.x_chips_per_weapon_per_level, card.ability.extra.x_chips_per_weapon_per_ilvl),
            Warcraft.get_scaled_gain(card, card.ability.extra.mult_per_race, card.ability.extra.mult_per_race_per_level, card.ability.extra.mult_per_race_per_ilvl),
            Warcraft.get_scaled_gain(card, card.ability.extra.chips_per_class, card.ability.extra.chips_per_class_per_level, card.ability.extra.chips_per_class_per_ilvl),
            fc, wc, rc, cc
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local factions, weapons, races, classes = {}, {}, {}, {}
            for _, j in ipairs(G.jokers.cards) do
                if j.ability and j.ability.extra then
                    local function count_unique(tbl, attr)
                        local val = j.ability.extra[attr]
                        if type(val) == "table" then
                            for _, v in ipairs(val) do tbl[v] = true end
                        elseif val then
                            tbl[val] = true
                        end
                    end
                    count_unique(factions, "faction")
                    count_unique(weapons, "weapon")
                    count_unique(races, "race")
                    count_unique(classes, "class")
                end
            end
            local fc, wc, rc, cc = 0, 0, 0, 0
            for _ in pairs(factions) do fc = fc + 1 end
            for _ in pairs(weapons) do wc = wc + 1 end
            for _ in pairs(races) do rc = rc + 1 end
            for _ in pairs(classes) do cc = cc + 1 end

            local effective_x_mult = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_per_faction, card.ability.extra.x_mult_per_faction_per_level, card.ability.extra.x_mult_per_faction_per_ilvl)
            local effective_x_chips = Warcraft.get_scaled_gain(card, card.ability.extra.x_chips_per_weapon, card.ability.extra.x_chips_per_weapon_per_level, card.ability.extra.x_chips_per_weapon_per_ilvl)
            local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.mult_per_race, card.ability.extra.mult_per_race_per_level, card.ability.extra.mult_per_race_per_ilvl)
            local effective_chips = Warcraft.get_scaled_gain(card, card.ability.extra.chips_per_class, card.ability.extra.chips_per_class_per_level, card.ability.extra.chips_per_class_per_ilvl)

            local total_x_mult = 1 + (fc * effective_x_mult)
            local total_x_chips = 1 + (wc * effective_x_chips)
            local total_mult = rc * effective_mult
            local total_chips = math.floor(cc * effective_chips)

            if total_x_mult > 1 or total_x_chips > 1 or total_mult > 0 or total_chips > 0 then
                return {
                    Xmult_mod = total_x_mult > 1 and total_x_mult or nil,
                    x_chips = total_x_chips > 1 and total_x_chips or nil,
                    mult = total_mult > 0 and total_mult or nil,
                    chips = total_chips > 0 and total_chips or nil,
                    message = "Exhibit All!",
                    colour = G.C.PURPLE,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Alarm-o-Bot",
    race = {"Robot"},
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {},
    combo = {"Sicco Thermaplugg", "Gelbin Mekkatorque", "Tinkmaster Overspark"},
    role = {"Tank"},
    rarity = 1,
    cost = 4,
    index = 273,
    config = { extra = { enemy_count = 2, enemy_count_per_level = 0.2, enemy_count_per_ilvl = 0.1 } },
    loc_txt = {
        "At the start of each {C:attention}Blind{},",
        "spawn {C:attention}#1#{} extra {C:red}Enemies{}",
        "with no penalty effect"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.enemy_count, card.ability.extra.enemy_count_per_level, card.ability.extra.enemy_count_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            local effective_count = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.enemy_count, card.ability.extra.enemy_count_per_level, card.ability.extra.enemy_count_per_ilvl))
            
            G.E_MANAGER:add_event(Event({
                func = function()
                    local current_ante = G.GAME.round_resets.ante
                    local valid_small_enemies = {}
                    
                    -- Use your pre-existing enemy pool and filter by Ante
                    for _, key in ipairs(Warcraft.Enemies.Pools.small) do
                        local center = G.P_CENTERS[key]
                        local min = (center and center.config.extra and center.config.extra.min_ante) or 1
                        if current_ante >= min then
                            table.insert(valid_small_enemies, key)
                        end
                    end

                    if #valid_small_enemies == 0 then return true end

                    for i = 1, effective_count do
                        local chosen_key = pseudorandom_element(valid_small_enemies, pseudoseed('alarmobot_' .. i .. '_' .. G.GAME.round))
                        local new_enemy = create_card('Joker', G.jokers, nil, nil, nil, nil, chosen_key, 'alarmobot')
                        
                        -- Make the spawned enemies behave like normal enemies (Negative, Pinned, Eternal)
                        new_enemy:set_edition({negative = true}, true, true)
                        new_enemy:set_eternal(true)
                        new_enemy.pinned = true
                        new_enemy.sell_cost = 0
                        new_enemy.ability.extinct = true

                        if new_enemy.ability.extra then
                            -- ADDED: Generate the kill requirement so it isn't "Unknown"!
                            new_enemy.ability.extra.kill_req = Warcraft.Enemies.generate_kill_req(new_enemy.ability.extra.target_cat, new_enemy.ability.extra.target_val)
                            
                            -- Disable the penalty by marking it as alarm-spawned
                            new_enemy.ability.extra.alarmobot_spawned = true
                        end
                        
                        new_enemy:add_to_deck()
                        G.jokers:emplace(new_enemy)
                        new_enemy:start_materialize()
                    end
                    return true
                end
            }))
            
            return {
                message = "INTRUDER ALERT!",
                colour = G.C.RED,
                card = card
            }
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Tickatus",
    faction = {"Legion"},
    race = {"Demon"},
    weapon = {"Fist"},
    damage = {"Fire"},
    armor = {"Unarmored"},
    profession = {},
    combo = {"Silas Darkmoon", "Burth", "Madam Goya"},
    role = {"Tank"},
    rarity = 2,
    cost = 6,
    index = 274,
    config = { extra = { prizes_per_boss = 1, prizes_per_level = 0.2, prizes_per_ilvl = 0.1 } },
    loc_txt = {
        "After defeating a {C:attention}Boss Blind{},",
        "generate {C:attention}#1#{} random",
        "{C:purple}Darkmoon Prize(s){}"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.prizes_per_boss, card.ability.extra.prizes_per_level, card.ability.extra.prizes_per_ilvl) }
    end,
    calculate = function(self, card, context)
        -- ADDED: context.main_eval guarantees this only fires ONCE per round end!
        if context.end_of_round and context.main_eval and context.beat_boss and not context.blueprint then
            local effective_count = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.prizes_per_boss, card.ability.extra.prizes_per_level, card.ability.extra.prizes_per_ilvl))
            local prize_keys = {
                'c_war_prize_level',
                'c_war_prize_ilvl',
                'c_war_prize_joker_slot',
                'c_war_prize_hand_size',
                'c_war_prize_hands',
                'c_war_prize_discards'
            }
            
            -- Only trigger if we are actually going to generate something
            if effective_count > 0 then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        for i = 1, effective_count do
                            if G.consumeables and #G.consumeables.cards < G.consumeables.config.card_limit then
                                local chosen_key = pseudorandom_element(prize_keys, pseudoseed('tickatus_prize_' .. i .. '_' .. G.GAME.round))
                                local new_card = create_card('DarkmoonPrize', G.consumeables, nil, nil, nil, nil, chosen_key, 'tickatus')
                                new_card:add_to_deck()
                                G.consumeables:emplace(new_card)
                                new_card:juice_up()
                            end
                        end
                        return true
                    end
                }))
                
                return {
                    message = "Darkmoon Faire!",
                    colour = G.C.PURPLE,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Sha of Anger",
    race = {"Sha"},
    weapon = {"Fist"},
    damage = {"Shadow"},
    armor = {"Unarmored"},
    profession = {},
    combo = {"Emperor Shaohao", "Sha of Fear", "Sha of Doubt", "Sha of Despair", "Sha of Hatred", "Sha of Pride", "Sha of Violence"},
    role = {"Tank"},
    rarity = 2,
    cost = 6,
    index = 275,
    config = { extra = { mult = -20, mult_gain = 3, mult_gain_per_level = 0.5, mult_gain_per_ilvl = 0.3, current_mult = -20 } },
    loc_txt = {
        "{C:mult}#1#{} Mult",
        "Gains {C:mult}+#2#{} Mult per",
        "card {C:attention}discarded{}.",
        "{C:red}Resets{} at end of {C:attention}Blind{}.",
        "{C:inactive}(Currently {C:mult}#3#{C:inactive} Mult){}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.mult,
            Warcraft.get_scaled_gain(card, card.ability.extra.mult_gain, card.ability.extra.mult_gain_per_level, card.ability.extra.mult_gain_per_ilvl),
            card.ability.extra.current_mult
        }
    end,
    calculate = function(self, card, context)
        -- Reset at start of each blind
        if context.setting_blind and not context.blueprint then
            card.ability.extra.current_mult = card.ability.extra.mult
            return {
                message = "RAGE!",
                colour = G.C.RED,
                card = card
            }
        end

        -- Gain mult per card discarded
        if context.discard and not context.blueprint then
            local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.mult_gain, card.ability.extra.mult_gain_per_level, card.ability.extra.mult_gain_per_ilvl)
            card.ability.extra.current_mult = card.ability.extra.current_mult + effective_gain
            return {
                message = "+Anger!",
                colour = G.C.RED,
                card = card
            }
        end

        -- Apply mult during scoring (can be negative)
        if context.joker_main then
            if card.ability.extra.current_mult ~= 0 then
                return {
                    mult = card.ability.extra.current_mult,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Sha of Doubt",
    race = {"Sha"},
    weapon = {"Fist"},
    damage = {"Shadow"},
    armor = {"Unarmored"},
    profession = {},
    combo = {"Emperor Shaohao", "Sha of Fear", "Sha of Anger", "Sha of Despair", "Sha of Hatred", "Sha of Pride", "Sha of Violence"},
    role = {"Tank"},
    rarity = 2,
    cost = 6,
    index = 276,
    config = { extra = { base_mult = 60, base_mult_per_level = 5, base_mult_per_ilvl = 3, current_mult = 60, timer = 0, decay_rate = 1, decay_rate_per_ilvl = -0.05 } },
    loc_txt = {
        "{C:mult}+#1#{} Mult",
        "Loses {C:mult}#2#{} Mult per second",
        "during a {C:attention}Blind{}.",
        "{C:red}Resets{} at end of {C:attention}Blind{}.",
        "{C:inactive}(Currently {C:mult}#3#{C:inactive} Mult){}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.base_mult, card.ability.extra.base_mult_per_level, 0),
            Warcraft.get_scaled_gain(card, card.ability.extra.decay_rate, 0, card.ability.extra.decay_rate_per_ilvl),
            card.ability.extra.current_mult
        }
    end,
    calculate = function(self, card, context)
        -- Reset at start of each blind
        if context.setting_blind and not context.blueprint then
            card.ability.extra.current_mult = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.base_mult, card.ability.extra.base_mult_per_level, 0))
            card.ability.extra.timer = 0
            return {
                message = "Doubt...",
                colour = G.C.PURPLE,
                card = card
            }
        end

        -- Apply mult during scoring
        if context.joker_main then
            if card.ability.extra.current_mult ~= 0 then
                return {
                    mult = card.ability.extra.current_mult,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Sha of Despair",
    race = {"Sha"},
    weapon = {"Fist"},
    damage = {"Shadow"},
    armor = {"Unarmored"},
    profession = {},
    combo = {"Emperor Shaohao", "Sha of Fear", "Sha of Anger", "Sha of Doubt", "Sha of Hatred", "Sha of Pride", "Sha of Violence"},
    role = {"Tank"},
    rarity = 2,
    cost = 6,
    index = 277,
    config = { extra = { x_mult_per_hand = 0.5, x_mult_per_hand_per_level = 0.1, x_mult_per_hand_per_ilvl = 0.05 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult per",
        "{C:attention}Hand{} remaining",
        "{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult){}"
    },
    loc_vars = function(self, info_queue, card)
        local hands_left = G.GAME.current_round and G.GAME.current_round.hands_left or 0
        local effective_per = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_per_hand, card.ability.extra.x_mult_per_hand_per_level, card.ability.extra.x_mult_per_hand_per_ilvl)
        local total = math.max(0.01, hands_left * effective_per)
        return { effective_per, total }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local hands_left = G.GAME.current_round and G.GAME.current_round.hands_left or 0
            local effective_per = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_per_hand, card.ability.extra.x_mult_per_hand_per_level, card.ability.extra.x_mult_per_hand_per_ilvl)
            local total_x_mult = math.max(0.01, hands_left * effective_per)
            return {
                Xmult_mod = total_x_mult,
                message = "Despair...",
                colour = G.C.PURPLE,
                card = card
            }
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Sha of Hatred",
    race = {"Sha"},
    weapon = {"Fist"},
    damage = {"Shadow"},
    armor = {"Unarmored"},
    profession = {},
    combo = {"Emperor Shaohao", "Sha of Fear", "Sha of Anger", "Sha of Doubt", "Sha of Despair", "Sha of Pride", "Sha of Violence"},
    role = {"Tank"},
    rarity = 2,
    cost = 6,
    index = 278,
    config = { extra = { x_chips = 4, x_chips_per_level = 0.5, x_chips_per_ilvl = 0.3, penalty_per_race = 0.2, penalty_per_race_per_ilvl = -0.02 } },
    loc_txt = {
        "{X:chips,C:white} X#1# {} Chips",
        "Loses {X:chips,C:white} X#2# {} Chips",
        "per unique {C:attention}Race{} among your Jokers",
        "{C:inactive}(Currently {X:chips,C:white} X#3# {C:inactive} Chips){}"
    },
    loc_vars = function(self, info_queue, card)
        local unique_races = {}
        if G.jokers then
            for _, j in ipairs(G.jokers.cards) do
                if j ~= card and j.ability and j.ability.extra and j.ability.extra.race then
                    local races = type(j.ability.extra.race) == "table" and j.ability.extra.race or {j.ability.extra.race}
                    for _, r in ipairs(races) do unique_races[r] = true end
                end
            end
        end
        local race_count = 0
        for _ in pairs(unique_races) do race_count = race_count + 1 end
        local effective_x_chips = Warcraft.get_scaled_gain(card, card.ability.extra.x_chips, card.ability.extra.x_chips_per_level, card.ability.extra.x_chips_per_ilvl)
        local effective_penalty = Warcraft.get_scaled_gain(card, card.ability.extra.penalty_per_race, 0, card.ability.extra.penalty_per_race_per_ilvl)
        local total = math.max(0.01, effective_x_chips - (race_count * effective_penalty))
        return { effective_x_chips, effective_penalty, total }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local unique_races = {}
            for _, j in ipairs(G.jokers.cards) do
                if j ~= card and j.ability and j.ability.extra and j.ability.extra.race then
                    local races = type(j.ability.extra.race) == "table" and j.ability.extra.race or {j.ability.extra.race}
                    for _, r in ipairs(races) do unique_races[r] = true end
                end
            end
            local race_count = 0
            for _ in pairs(unique_races) do race_count = race_count + 1 end
            local effective_x_chips = Warcraft.get_scaled_gain(card, card.ability.extra.x_chips, card.ability.extra.x_chips_per_level, card.ability.extra.x_chips_per_ilvl)
            local effective_penalty = Warcraft.get_scaled_gain(card, card.ability.extra.penalty_per_race, 0, card.ability.extra.penalty_per_race_per_ilvl)
            local total = math.max(0.01, effective_x_chips - (race_count * effective_penalty))
            return {
                x_chips = total,
                message = "HATRED!",
                colour = G.C.RED,
                card = card
            }
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Sha of Pride",
    race = {"Sha"},
    weapon = {"Fist"},
    damage = {"Shadow"},
    armor = {"Unarmored"},
    profession = {},
    combo = {"Emperor Shaohao", "Sha of Fear", "Sha of Anger", "Sha of Doubt", "Sha of Despair", "Sha of Hatred", "Sha of Violence"},
    role = {"Tank"},
    rarity = 3,
    cost = 8,
    index = 279,
    config = { extra = { x_mult = 3, x_mult_per_level = 0.5, x_mult_per_ilvl = 0.3, hands_played_this_blind = 0 } },
    loc_txt = {
        "The {C:attention}first scoring card{}",
        "retriggers and gives {X:mult,C:white} X#1# {} Mult.",
        "If the {C:attention}Blind{} is not beaten",
        "in a {C:attention}single hand{},",
        "this Joker is {C:red}destroyed{}."
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl) }
    end,
    calculate = function(self, card, context)
        -- Reset counter at start of each blind
        if context.setting_blind and not context.blueprint then
            card.ability.extra.hands_played_this_blind = 0
        end

        -- Track hands played
        if context.after and not context.blueprint then
            card.ability.extra.hands_played_this_blind = card.ability.extra.hands_played_this_blind + 1
        end

        -- Destroy if more than 1 hand was needed to beat the blind
        if context.end_of_round and not context.repetition and not context.individual and not context.blueprint then
            if card.ability.extra.hands_played_this_blind > 1 then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('tarot1')
                        card.T.r = -0.2
                        card:juice_up(0.3, 0.4)
                        card:start_dissolve({remove_as_card = true})
                        return true
                    end
                }))
                return {
                    message = "Humbled...",
                    colour = G.C.PURPLE
                }
            end
        end

        -- Retrigger first scoring card
        if context.repetition and context.cardarea == G.play then
            if context.scoring_hand and context.other_card == context.scoring_hand[1] then
                return {
                    message = "PRIDE!",
                    repetitions = 1,
                    card = card
                }
            end
        end

        -- XMult on first scoring card
        if context.individual and context.cardarea == G.play then
            if context.scoring_hand and context.other_card == context.scoring_hand[1] then
                return {
                    x_mult = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
                    card = context.other_card,
                    message = "PRIDE!",
                    colour = G.C.PURPLE
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Sha of Violence",
    race = {"Sha"},
    weapon = {"Fist"},
    damage = {"Shadow"},
    armor = {"Unarmored"},
    profession = {},
    combo = {"Emperor Shaohao", "Sha of Fear", "Sha of Anger", "Sha of Doubt", "Sha of Despair", "Sha of Hatred", "Sha of Pride"},
    role = {"Tank"},
    rarity = 2,
    cost = 6,
    index = 280,
    config = { extra = { x_chips = 0.4, x_chips_gain = 0.5, x_chips_gain_per_level = 0.1, x_chips_gain_per_ilvl = 0.05 } },
    loc_txt = {
        "{X:chips,C:white} X#1# {} Chips",
        "Gains {X:chips,C:white} X#2# {} Chips each time",
        "a playing card is {C:red}destroyed{}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.x_chips,
            Warcraft.get_scaled_gain(card, card.ability.extra.x_chips_gain, card.ability.extra.x_chips_gain_per_level, card.ability.extra.x_chips_gain_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.remove_playing_cards and not context.blueprint then
            if context.removed and #context.removed > 0 then
                local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.x_chips_gain, card.ability.extra.x_chips_gain_per_level, card.ability.extra.x_chips_gain_per_ilvl)
                card.ability.extra.x_chips = card.ability.extra.x_chips + (#context.removed * effective_gain)
                return {
                    message = "VIOLENCE!",
                    colour = G.C.RED,
                    card = card
                }
            end
        end

        if context.joker_main then
            if card.ability.extra.x_chips > 1 then
                return {
                    x_chips = card.ability.extra.x_chips,
                    message = "Bloodlust!",
                    colour = G.C.RED,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "The Lich King",
    faction = {"Scourge"},
    race = {"Undead"},
    class = {"Death Knight"},
    weapon = {"Sword"},
    damage = {"Shadow"},
    armor = {"Plate"},
    profession = {},
    combo = {"Arthas Menethil", "Ner'zhul", "Bolvar Fordragon"},
    role = {"Tank"},
    rarity = 3,
    cost = 10,
    index = 281,
    config = { extra = {
        x_mult_per_undead = 0.3, x_mult_per_undead_per_level = 0.05, x_mult_per_undead_per_ilvl = 0.03,
        x_chips_per_scourge = 0.3, x_chips_per_scourge_per_level = 0.05, x_chips_per_scourge_per_ilvl = 0.03,
        raise_chance = 4, raise_chance_per_level = -0.2, raise_chance_per_ilvl = -0.1
    } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult per {C:attention}Undead{} Joker",
        "{X:chips,C:white} X#2# {} Chips per {C:attention}Scourge{} Joker",
        "End of shop: {C:green}1 in #3#{} chance to add",
        "{C:attention}Undead{} race or {C:attention}Scourge{} faction",
        "to a random Joker"
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_per_undead, card.ability.extra.x_mult_per_undead_per_level, card.ability.extra.x_mult_per_undead_per_ilvl),
            Warcraft.get_scaled_gain(card, card.ability.extra.x_chips_per_scourge, card.ability.extra.x_chips_per_scourge_per_level, card.ability.extra.x_chips_per_scourge_per_ilvl),
            Warcraft.get_scaled_gain(card, card.ability.extra.raise_chance, card.ability.extra.raise_chance_per_level, card.ability.extra.raise_chance_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.ending_shop and not context.blueprint then
            local effective_chance = math.max(1, Warcraft.get_scaled_gain(card, card.ability.extra.raise_chance, card.ability.extra.raise_chance_per_level, card.ability.extra.raise_chance_per_ilvl))

            -- Try to add Undead race
            if pseudorandom('lichking_undead') < G.GAME.probabilities.normal / effective_chance then
                local targets = {}
                for _, j in ipairs(G.jokers.cards) do
                    if j ~= card and not Warcraft.is_race(j, "Undead") then
                        table.insert(targets, j)
                    end
                end
                if #targets > 0 then
                    local target = pseudorandom_element(targets, pseudoseed('lichking_undead_target_' .. G.GAME.round))
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            if type(target.ability.extra.race) == "table" then
                                table.insert(target.ability.extra.race, "Undead")
                            elseif target.ability.extra.race then
                                target.ability.extra.race = {target.ability.extra.race, "Undead"}
                            else
                                target.ability.extra.race = {"Undead"}
                            end
                            card_eval_status_text(target, 'extra', nil, nil, nil, {
                                message = "Risen!",
                                colour = G.C.GREY
                            })
                            target:juice_up()
                            return true
                        end
                    }))
                end
            end

            -- Try to add Scourge faction
            if pseudorandom('lichking_scourge') < G.GAME.probabilities.normal / effective_chance then
                local targets = {}
                for _, j in ipairs(G.jokers.cards) do
                    if j ~= card and not Warcraft.is_faction(j, "Scourge") then
                        table.insert(targets, j)
                    end
                end
                if #targets > 0 then
                    local target = pseudorandom_element(targets, pseudoseed('lichking_scourge_target_' .. G.GAME.round))
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            if type(target.ability.extra.faction) == "table" then
                                table.insert(target.ability.extra.faction, "Scourge")
                            elseif target.ability.extra.faction then
                                target.ability.extra.faction = {target.ability.extra.faction, "Scourge"}
                            else
                                target.ability.extra.faction = {"Scourge"}
                            end
                            card_eval_status_text(target, 'extra', nil, nil, nil, {
                                message = "Corrupted!",
                                colour = G.C.DARK_EDITION
                            })
                            target:juice_up()
                            return true
                        end
                    }))
                end
            end

            return {
                message = "ALL SHALL SERVE!",
                colour = G.C.DARK_EDITION,
                card = card
            }
        end

        if context.joker_main then
            local undead_count = 0
            local scourge_count = 0
            for _, j in ipairs(G.jokers.cards) do
                if j ~= card then
                    if Warcraft.is_race(j, "Undead") then undead_count = undead_count + 1 end
                    if Warcraft.is_faction(j, "Scourge") then scourge_count = scourge_count + 1 end
                end
            end

            local effective_x_mult = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_per_undead, card.ability.extra.x_mult_per_undead_per_level, card.ability.extra.x_mult_per_undead_per_ilvl)
            local effective_x_chips = Warcraft.get_scaled_gain(card, card.ability.extra.x_chips_per_scourge, card.ability.extra.x_chips_per_scourge_per_level, card.ability.extra.x_chips_per_scourge_per_ilvl)

            local total_x_mult = 1 + (undead_count * effective_x_mult)
            local total_x_chips = 1 + (scourge_count * effective_x_chips)

            if total_x_mult > 1 or total_x_chips > 1 then
                return {
                    Xmult_mod = total_x_mult > 1 and total_x_mult or nil,
                    x_chips = total_x_chips > 1 and total_x_chips or nil,
                    message = "FROSTMOURNE HUNGERS!",
                    colour = G.C.DARK_EDITION,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Kurog Grimtotem",
    faction = {"Horde"},
    race = {"Tauren"},
    class = {"Shaman"},
    weapon = {"Hammer"},
    damage = {"Nature"},
    armor = {"Leather"},
    profession = {},
    combo = {"Raszageth", "Magatha Grimtotem", "Cairne Bloodhoof"},
    role = {"Ranged DPS"},
    rarity = 3,
    cost = 8,
    index = 282,
    config = { extra = {
        current_suit = "Spades",
        suit_cycle = {"Spades", "Hearts", "Clubs", "Diamonds"},
        suit_index = 1,
        -- Track XMult per suit separately
        x_mult_spades = 1.2,
        x_mult_hearts = 1.2,
        x_mult_clubs = 1.2,
        x_mult_diamonds = 1.2,
        x_mult_gain = 0.2,
        x_mult_gain_per_level = 0.05,
        x_mult_gain_per_ilvl = 0.03,
    } },
    loc_txt = {
        "Scoring {C:attention}#1#{} cards retrigger",
        "and give {X:mult,C:white} X#2# {} Mult.",
        "Gains {X:mult,C:white} X#3# {} Mult when that",
        "suit scores. {C:attention}Suit changes{} each hand."
    },
    loc_vars = function(self, info_queue, card)
        local suit = card.ability.extra.current_suit
        local current_x_mult = card.ability.extra["x_mult_" .. string.lower(suit)] or 1.2
        local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_gain, card.ability.extra.x_mult_gain_per_level, card.ability.extra.x_mult_gain_per_ilvl)
        return { suit, current_x_mult, effective_gain }
    end,
    calculate = function(self, card, context)
        -- Advance suit at the start of each new hand
        if context.before and not context.blueprint then
            local cycle = card.ability.extra.suit_cycle
            card.ability.extra.suit_index = (card.ability.extra.suit_index % #cycle) + 1
            card.ability.extra.current_suit = cycle[card.ability.extra.suit_index]
            return {
                message = card.ability.extra.current_suit .. "!",
                colour = G.C.SUITS[card.ability.extra.current_suit] or G.C.ORANGE,
                card = card
            }
        end

        -- Retrigger active suit cards
        if context.repetition and context.cardarea == G.play then
            if context.other_card:is_suit(card.ability.extra.current_suit) then
                return {
                    message = "Primal!",
                    repetitions = 1,
                    card = card
                }
            end
        end

        -- XMult and gain when active suit scores
        if context.individual and context.cardarea == G.play then
            local suit = card.ability.extra.current_suit
            if context.other_card:is_suit(suit) then
                local suit_key = "x_mult_" .. string.lower(suit)
                local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_gain, card.ability.extra.x_mult_gain_per_level, card.ability.extra.x_mult_gain_per_ilvl)
                card.ability.extra[suit_key] = (card.ability.extra[suit_key] or 1.2) + effective_gain
                return {
                    x_mult = card.ability.extra[suit_key],
                    card = context.other_card,
                    message = "Primal Storm!",
                    colour = G.C.ORANGE
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Murozond",
    faction = {"Horde", "Alliance"},
    race = {"Dragon"},
    class = {"Mage"},
    weapon = {"Fist"},
    damage = {"Nature"},
    armor = {"Mail"},
    profession = {},
    combo = {"Nozdormu", "Chromie", "Morchie", "Alexstrasza"},
    role = {"Ranged DPS"},
    rarity = 3,
    cost = 8,
    index = 283,
    config = { extra = {
        x_mult = 1,
        x_mult_gain = 0.5,
        x_mult_gain_per_level = 0.1,
        x_mult_gain_per_ilvl = 0.05,
        blinds_skipped = 0,
        negative_threshold = 6,
        became_negative = false
    } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "Gains {X:mult,C:white} X#2# {} per {C:attention}Blind Skipped{}.",
        "Becomes {C:dark_edition}Negative{} after",
        "{C:attention}#3#{} skipped Blinds.",
        "{C:inactive}(Blinds skipped: #4#/#3#){}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.x_mult,
            Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_gain, card.ability.extra.x_mult_gain_per_level, card.ability.extra.x_mult_gain_per_ilvl),
            card.ability.extra.negative_threshold,
            card.ability.extra.blinds_skipped
        }
    end,
    add_to_deck = function(self, card, from_debuff)
        -- Retroactively calculate from already skipped blinds
        local skipped = G.GAME.skips or 0
        card.ability.extra.blinds_skipped = skipped
        local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_gain, card.ability.extra.x_mult_gain_per_level, card.ability.extra.x_mult_gain_per_ilvl)
        card.ability.extra.x_mult = 1 + (skipped * effective_gain)

        -- Retroactively apply negative if threshold already reached
        if skipped >= card.ability.extra.negative_threshold and not card.ability.extra.became_negative then
            card.ability.extra.became_negative = true
            G.E_MANAGER:add_event(Event({
                func = function()
                    card:set_edition({negative = true}, true)
                    card:juice_up()
                    return true
                end
            }))
        end
    end,
    calculate = function(self, card, context)
        if context.skip_blind and not context.blueprint then
            card.ability.extra.blinds_skipped = card.ability.extra.blinds_skipped + 1

            -- Track global skip count
            G.GAME.skips = (G.GAME.skips or 0) + 1

            local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_gain, card.ability.extra.x_mult_gain_per_level, card.ability.extra.x_mult_gain_per_ilvl)
            card.ability.extra.x_mult = card.ability.extra.x_mult + effective_gain

            -- Check if threshold reached for negative edition
            if card.ability.extra.blinds_skipped >= card.ability.extra.negative_threshold
            and not card.ability.extra.became_negative then
                card.ability.extra.became_negative = true
                G.E_MANAGER:add_event(Event({
                    func = function()
                        card:set_edition({negative = true}, true)
                        card_eval_status_text(card, 'extra', nil, nil, nil, {
                            message = "Infinite!",
                            colour = G.C.DARK_EDITION
                        })
                        card:juice_up()
                        return true
                    end
                }))
            end

            return {
                message = "Timeline Devoured!",
                colour = G.C.DARK_EDITION,
                card = card
            }
        end

        if context.joker_main then
            if card.ability.extra.x_mult > 1 then
                return {
                    Xmult_mod = card.ability.extra.x_mult,
                    message = "Infinite Dragonflight!",
                    colour = G.C.DARK_EDITION,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Chrono-Lord Deios",
    race = {"Blood Elf", "Dragon"},
    class = {"Mage"},
    weapon = {"Staff"},
    damage = {"Nature"},
    armor = {"Leather"},
    profession = {},
    combo = {"Murozond", "Chromie", "Morchie"},
    role = {"Ranged DPS"},
    rarity = 3,
    cost = 9,
    index = 284,
    config = { extra = { copies = 3, copies_per_level = 0.3, copies_per_ilvl = 0.2, used_this_shop = false } },
    loc_txt = {
        "The {C:attention}first Consumable{} used",
        "each {C:attention}Shop{} is duplicated",
        "{C:attention}#1#{} time(s) as {C:dark_edition}Negative{} copies"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.copies, card.ability.extra.copies_per_level, card.ability.extra.copies_per_ilvl) }
    end,
    calculate = function(self, card, context)
        -- Reset at start of each shop
        if context.starting_shop and not context.blueprint then
            card.ability.extra.used_this_shop = false
        end

        if context.using_consumeable and not context.blueprint and not card.ability.extra.used_this_shop then
            card.ability.extra.used_this_shop = true
            local effective_copies = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.copies, card.ability.extra.copies_per_level, card.ability.extra.copies_per_ilvl))
            local source = context.consumeable
            if not source then return end

            G.E_MANAGER:add_event(Event({
                func = function()
                    for i = 1, effective_copies do
                        local copy = create_card(
                            source.ability.set,
                            G.consumeables,
                            nil, nil, nil, nil,
                            source.config.center.key,
                            'deios'
                        )
                        copy:set_edition({negative = true}, true)
                        copy:add_to_deck()
                        G.consumeables:emplace(copy)
                        copy:juice_up()
                    end
                    card_eval_status_text(card, 'extra', nil, nil, nil, {
                        message = "Time Loop!",
                        colour = G.C.DARK_EDITION
                    })
                    return true
                end
            }))
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Shandris Feathermoon",
    faction = {"Alliance"},
    race = {"Night Elf"},
    class = {"Hunter"},
    weapon = {"Bow"},
    damage = {"Piercing"},
    armor = {"Leather"},
    profession = {},
    combo = {"Tyrande Whisperwind", "Maiev", "Illidan Stormrage", "Malfurion Stormrage"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 6,
    index = 285,
    config = { extra = { x_mult = 1.5, x_mult_gain = 0.3, x_mult_gain_per_level = 0.05, x_mult_gain_per_ilvl = 0.03 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "Scoring cards in a {C:attention}High Card{}",
        "each give {X:mult,C:white} X#1# {} Mult.",
        "Gains {X:mult,C:white} X#2# {} each time",
        "a {C:attention}High Card{} is played."
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.x_mult,
            Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_gain, card.ability.extra.x_mult_gain_per_level, card.ability.extra.x_mult_gain_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        -- Gain XMult each time High Card is played
        if context.before and not context.blueprint then
            if context.scoring_name == "High Card" then
                local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_gain, card.ability.extra.x_mult_gain_per_level, card.ability.extra.x_mult_gain_per_ilvl)
                card.ability.extra.x_mult = card.ability.extra.x_mult + effective_gain
                return {
                    message = "Precision!",
                    colour = G.C.GREEN,
                    card = card
                }
            end
        end

        -- XMult per scoring card in High Card
        if context.individual and context.cardarea == G.play then
            if context.scoring_name == "High Card" then
                return {
                    x_mult = card.ability.extra.x_mult,
                    card = context.other_card,
                    message = "Eagle Eye!",
                    colour = G.C.GREEN
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Searinox",
    race = {"Dragon"},
    class = {"Warrior"},
    weapon = {"Fist"},
    damage = {"Fire"},
    armor = {"Plate"},
    profession = {},
    combo = {"Arthas Menethil", "Uther the Lightbringer", "Muradin Bronzebeard"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 5,
    index = 286,
    config = { extra = { chance = 20, chance_per_level = -0.3, chance_per_ilvl = -0.2, ilvl_gain = 1, ilvl_gain_per_level = 0.2, ilvl_gain_per_ilvl = 0.1 } },
    loc_txt = {
        "Played {C:hearts}Hearts{} have a",
        "{C:green}1 in #1#{} chance to give",
        "{C:attention}+#2#{} Ilvl{} to all equipped Jokers"
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.chance, card.ability.extra.chance_per_level, card.ability.extra.chance_per_ilvl),
            Warcraft.get_scaled_gain(card, card.ability.extra.ilvl_gain, card.ability.extra.ilvl_gain_per_level, card.ability.extra.ilvl_gain_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            if context.other_card:is_suit('Hearts') then
                local effective_chance = math.max(1, Warcraft.get_scaled_gain(card, card.ability.extra.chance, card.ability.extra.chance_per_level, card.ability.extra.chance_per_ilvl))
                if pseudorandom('searinox') < G.GAME.probabilities.normal / effective_chance then
                    local effective_ilvl = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.ilvl_gain, card.ability.extra.ilvl_gain_per_level, card.ability.extra.ilvl_gain_per_ilvl))
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            local upgraded = false
                            for _, j in ipairs(G.jokers.cards) do
                                if j.ability.wow_equipment then
                                    j.ability.wow_equipment.ilvl = (j.ability.wow_equipment.ilvl or 0) + effective_ilvl
                                    j.ability.wow_equipment.ilvl_gained_this_round = 0
                                    j:juice_up()
                                    upgraded = true
                                end
                            end
                            if upgraded then
                                card_eval_status_text(card, 'extra', nil, nil, nil, {
                                    message = "Dragonfire Forge!",
                                    colour = G.C.ORANGE
                                })
                            end
                            return true
                        end
                    }))
                    return {
                        message = "Dragonfire!",
                        colour = G.C.ORANGE,
                        card = card
                    }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Lord Garithos",
    faction = {"Alliance"},
    race = {"Human"},
    class = {"Warrior"},
    weapon = {"Sword", "Shield"},
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {},
    combo = {"Sylvanas Windrunner", "Kael'thas Sunstrider", "Lady Vashj", "Varimathras"},
    role = {"Tank"},
    rarity = 3,
    cost = 8,
    index = 287,
    config = { extra = { x_mult = 5, x_mult_per_level = 1, x_mult_per_ilvl = 0.5 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult if every",
        "Joker you own is {C:attention}Human{}.",
        "Any non-{C:attention}Human{} Joker",
        "{C:red}Debuffs{} this one."
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl) }
    end,
    calculate = function(self, card, context)
        -- Check for non-human jokers and debuff accordingly
        if context.setting_blind or context.buying_card or context.selling_card then
            local has_non_human = false
            for _, j in ipairs(G.jokers.cards) do
                if j ~= card and not Warcraft.is_race(j, "Human") then
                    has_non_human = true
                    break
                end
            end
            G.E_MANAGER:add_event(Event({
                func = function()
                    if has_non_human and not card.debuff then
                        card:set_debuff(true)
                        card_eval_status_text(card, 'extra', nil, nil, nil, {
                            message = "Disgusting!",
                            colour = G.C.RED
                        })
                    elseif not has_non_human and card.debuff then
                        card:set_debuff(false)
                        card_eval_status_text(card, 'extra', nil, nil, nil, {
                            message = "Purity!",
                            colour = G.C.BLUE
                        })
                    end
                    return true
                end
            }))
        end

        if context.joker_main and not card.debuff then
            local all_human = true
            for _, j in ipairs(G.jokers.cards) do
                if j ~= card and not Warcraft.is_race(j, "Human") then
                    all_human = false
                    break
                end
            end
            if all_human then
                return {
                    Xmult_mod = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
                    message = "For the Alliance!",
                    colour = G.C.BLUE,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Shade of Aran",
    race = {"Human", "Undead"},
    class = {"Mage"},
    weapon = {"Staff"},
    damage = {"Fire", "Frost", "Arcane"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Medivh", "Nielas Aran", "Khadgar"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 6,
    index = 288,
    config = { extra = {
        chips = 120, chips_per_level = 15, chips_per_ilvl = 10,
        mult = 25, mult_per_level = 3, mult_per_ilvl = 2,
        x_mult = 2.5, x_mult_per_level = 0.3, x_mult_per_ilvl = 0.2
    } },
    loc_txt = {
        "Each hand randomly applies:",
        "{C:chips}Frost: +#1#{} Chips{}",
        "{C:mult}Fire: +#2#{} Mult{}",
        "{C:attention}Arcane: {X:mult,C:white} X#3# {} Mult{}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.chips, card.ability.extra.chips_per_level, card.ability.extra.chips_per_ilvl),
            Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl),
            Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local roll = pseudorandom('shade_of_aran_' .. G.GAME.round .. '_' .. (G.GAME.current_round.hands_played or 0))
            if roll < 0.333 then
                -- Frost
                local effective_chips = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.chips, card.ability.extra.chips_per_level, card.ability.extra.chips_per_ilvl))
                return {
                    chips = effective_chips,
                    message = "Blizzard!",
                    colour = G.C.CHIPS,
                    card = card
                }
            elseif roll < 0.666 then
                -- Fire
                local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl)
                return {
                    mult = effective_mult,
                    message = "Pyroblast!",
                    colour = G.C.RED,
                    card = card
                }
            else
                -- Arcane
                local effective_x_mult = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl)
                return {
                    Xmult_mod = effective_x_mult,
                    message = "Arcane Surge!",
                    colour = G.C.PURPLE,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Attumen the Huntsman",
    race = {"Human", "Undead"},
    class = {"Warrior"},
    weapon = {"Sword"},
    damage = {"Shadow"},
    armor = {"Plate"},
    profession = {},
    combo = {"Medivh", "Moroes", "Khadgar"},
    role = {"Melee DPS"},
    rarity = 3,
    cost = 8,
    index = 289,
    config = { extra = { x_mult = 2, x_mult_per_level = 0.3, x_mult_per_ilvl = 0.2, summon_chance = 50, summon_chance_per_level = -0.5, summon_chance_per_ilvl = -0.3 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult if played hand",
        "contains both a {C:attention}Face Card{}",
        "and a {C:attention}Non-Face Card{}.",
        "{C:green}1 in #2#{} chance to summon",
        "{C:attention}Midnight{} when this triggers."
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
            Warcraft.get_scaled_gain(card, card.ability.extra.summon_chance, card.ability.extra.summon_chance_per_level, card.ability.extra.summon_chance_per_ilvl)
        }
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
                -- Check if Midnight already exists
                local has_midnight = false
                for _, j in ipairs(G.jokers.cards) do
                    if j.ability.name == "Midnight" then
                        has_midnight = true
                        break
                    end
                end

                -- Try to summon Midnight
                if not has_midnight then
                    local effective_chance = math.max(1, Warcraft.get_scaled_gain(card, card.ability.extra.summon_chance, card.ability.extra.summon_chance_per_level, card.ability.extra.summon_chance_per_ilvl))
                    if pseudorandom('attumen_midnight') < G.GAME.probabilities.normal / effective_chance then
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                if #G.jokers.cards < G.jokers.config.card_limit then
                                    local midnight = create_card('Joker', G.jokers, nil, nil, nil, nil, 'j_war_midnight', 'attumen')
                                    midnight:add_to_deck()
                                    G.jokers:emplace(midnight)
                                    midnight:start_materialize()
                                    card_eval_status_text(card, 'extra', nil, nil, nil, {
                                        message = "Midnight Appears!",
                                        colour = G.C.DARK_EDITION
                                    })
                                end
                                return true
                            end
                        }))
                    end
                end

                return {
                    Xmult_mod = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
                    message = "Charge!",
                    colour = G.C.ORANGE,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Alysrazor",
    race = {"Beast", "Elemental"},
    weapon = {"Fist"},
    damage = {"Fire"},
    armor = {"Unarmored"},
    profession = {},
    combo = {"Ragnaros", "Fandral Staghelm","Baleroc"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 6,
    index = 290,
    config = { extra = { base_chips = 10, base_chips_per_level = 2, base_chips_per_ilvl = 1, multiplier = 2, multiplier_per_ilvl = 0.1, hands_played_this_blind = 0 } },
    loc_txt = {
        "Each hand played this Blind",
        "gives {C:chips}+Chips{} that doubles.",
        "{C:inactive}(Start: {C:chips}+#1#{C:inactive}, x{C:attention}#2#{C:inactive} per hand){}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.base_chips, card.ability.extra.base_chips_per_level, card.ability.extra.base_chips_per_ilvl),
            Warcraft.get_scaled_gain(card, card.ability.extra.multiplier, 0, card.ability.extra.multiplier_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            card.ability.extra.hands_played_this_blind = 0
        end

        if context.joker_main then
            local effective_base = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.base_chips, card.ability.extra.base_chips_per_level, card.ability.extra.base_chips_per_ilvl))
            local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.multiplier, 0, card.ability.extra.multiplier_per_ilvl)
            local hands = card.ability.extra.hands_played_this_blind or 0
            -- chips = base * multiplier^hands_played
            local total_chips = math.floor(effective_base * (effective_mult ^ hands))
            if total_chips > 0 then
                return {
                    chips = total_chips,
                    message = "Liftoff!",
                    colour = G.C.ORANGE,
                    card = card
                }
            end
        end

        if context.after and not context.blueprint then
            card.ability.extra.hands_played_this_blind = (card.ability.extra.hands_played_this_blind or 0) + 1
            return {
                message = "Faster!",
                colour = G.C.ORANGE,
                card = card
            }
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Brutallus",
    faction = {"Legion"},
    race = {"Demon"},
    class = {"Warrior"},
    weapon = {"Sword", "Fist"},
    damage = {"Fire"},
    armor = {"Plate"},
    profession = {},
    combo = {"Azgalor","Mannoroth","Magtheridon","Kil'Jaeden"},
    role = {"Tank"},
    rarity = 2,
    cost = 6,
    index = 291,
    config = { extra = { x_chips = 2, x_chips_per_level = 0.3, x_chips_per_ilvl = 0.2, retrigger = 1, retrigger_per_level = 0.2, retrigger_per_ilvl = 0.1 } },
    loc_txt = {
        "Scoring {C:attention}6s{} retrigger",
        "{C:attention}#2#{} time(s) and give",
        "{X:chips,C:white} X#1# {} Chips"
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.x_chips, card.ability.extra.x_chips_per_level, card.ability.extra.x_chips_per_ilvl),
            Warcraft.get_scaled_gain(card, card.ability.extra.retrigger, card.ability.extra.retrigger_per_level, card.ability.extra.retrigger_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            if context.other_card:get_id() == 6 then
                return {
                    message = "STOMP!",
                    repetitions = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.retrigger, card.ability.extra.retrigger_per_level, card.ability.extra.retrigger_per_ilvl)),
                    card = card
                }
            end
        end

        if context.individual and context.cardarea == G.play then
            if context.other_card:get_id() == 6 then
                return {
                    x_chips = Warcraft.get_scaled_gain(card, card.ability.extra.x_chips, card.ability.extra.x_chips_per_level, card.ability.extra.x_chips_per_ilvl),
                    card = context.other_card,
                    message = "Brutalize!",
                    colour = G.C.RED
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Baleroc",
    faction = {"Legion"},
    race = {"Demon"},
    class = {"Warrior"},
    weapon = {"Sword"},
    damage = {"Fire"},
    armor = {"Plate"},
    profession = {},
    combo = {"Alysrazor", "Fandral Staghelm", "Ragnaros"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 6,
    index = 292,
    config = { extra = { converts_per_ilvl = 0.2 } },
    loc_txt = {
        "At end of each Blind, if",
        "{C:hearts}Hearts{} are not the majority",
        "suit in your deck, convert",
        "{C:attention}#1#{} random card(s) to {C:hearts}Hearts{}"
    },
    loc_vars = function(self, info_queue, card)
        local effective_converts = math.max(1, math.floor(Warcraft.get_scaled_gain(card, 1, 0, card.ability.extra.converts_per_ilvl)))
        return { effective_converts }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.repetition and not context.individual and not context.blueprint then
            if not G.playing_cards then return end

            -- Count suits
            local suit_counts = { Hearts = 0, Spades = 0, Diamonds = 0, Clubs = 0 }
            for _, c in ipairs(G.playing_cards) do
                for suit, _ in pairs(suit_counts) do
                    if c:is_suit(suit) then
                        suit_counts[suit] = suit_counts[suit] + 1
                        break
                    end
                end
            end

            local total = #G.playing_cards
            local heart_count = suit_counts.Hearts
            local majority = total / 4  -- Hearts must be strictly more than 25% to count as majority

            -- Check if Hearts are not the majority
            local hearts_are_majority = true
            for suit, count in pairs(suit_counts) do
                if suit ~= "Hearts" and count >= heart_count then
                    hearts_are_majority = false
                    break
                end
            end

            if not hearts_are_majority then
                local effective_converts = math.max(1, math.floor(Warcraft.get_scaled_gain(card, 1, 0, card.ability.extra.converts_per_ilvl)))

                -- Collect non-Heart cards
                local non_hearts = {}
                for _, c in ipairs(G.playing_cards) do
                    if not c:is_suit('Hearts') then
                        table.insert(non_hearts, c)
                    end
                end

                if #non_hearts > 0 then
                    local to_convert = math.min(effective_converts, #non_hearts)
                    for i = 1, to_convert do
                        local target = pseudorandom_element(non_hearts, pseudoseed('baleroc_' .. i .. '_' .. G.GAME.round))
                        -- Remove from pool to avoid duplicates
                        for j = #non_hearts, 1, -1 do
                            if non_hearts[j] == target then
                                table.remove(non_hearts, j)
                                break
                            end
                        end
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                target:change_suit('Hearts')
                                target:juice_up()
                                return true
                            end
                        }))
                    end
                    return {
                        message = "Gatekeeper!",
                        colour = G.C.HEARTS,
                        card = card
                    }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "The Beast",
    race = {"Beast"},
    weapon = {"Teeth"},
    damage = {"Fire"},
    armor = {"Leather"},
    profession = {},
    combo = {"Finkle Einhorn","Nefarian", "Onyxia"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 6,
    index = 293,
    config = { extra = { x_mult = 2, x_mult_per_level = 0.3, x_mult_per_ilvl = 0.2 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "When {C:red}sold or destroyed{},",
        "summon a random {C:attention}Gnome{} Joker"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                Xmult_mod = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
                message = "RAAAWR!",
                colour = G.C.RED,
                card = card
            }
        end

        if (context.selling_self or (context.remove_from_deck and context.card == card)) and not context.blueprint then
            -- Collect all Gnome jokers
            local gnome_jokers = {}
            for k, v in pairs(G.P_CENTERS) do
                if v.set == "Joker"
                and v.config and v.config.extra
                and type(v.config.extra) == "table"
                and Warcraft.is_race_by_config(v.config.extra, "Gnome") then
                    table.insert(gnome_jokers, k)
                end
            end

            if #gnome_jokers > 0 then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        if #G.jokers.cards < G.jokers.config.card_limit then
                            local chosen_key = pseudorandom_element(gnome_jokers, pseudoseed('the_beast_' .. G.GAME.round))
                            local new_card = create_card('Joker', G.jokers, nil, nil, nil, nil, chosen_key, 'the_beast')
                            new_card:add_to_deck()
                            G.jokers:emplace(new_card)
                            new_card:start_materialize()
                            card_eval_status_text(card, 'extra', nil, nil, nil, {
                                message = "Core Hound!",
                                colour = G.C.RED
                            })
                        end
                        return true
                    end
                }))
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Detheroc",
    faction = {"Scourge", "Legion"},
    race = {"Undead", "Demon", "Nathrezim"},
    class = {"Warlock"},
    weapon = {"Sword", "Fist"},
    damage = {"Shadow"},
    armor = {"Plate"},
    profession = {},
    combo = {"Argus the Unmaker", "Aggramar", "Mal'Ganis", "Tichondrius", "Varimathras"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 7,
    index = 294,
    config = { extra = { debuff_chance = 1, debuff_chance_per_level = -0.05, debuff_chance_per_ilvl = -0.03 } },
    loc_txt = {
        "Copies the effect of the",
        "{C:attention}Joker to the right{}",
        "during a {C:attention}Blind{}.",
        "{C:green}1 in #1#{} chance to {C:red}Debuff{}",
        "it after each hand played."
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.debuff_chance, card.ability.extra.debuff_chance_per_level, card.ability.extra.debuff_chance_per_ilvl) }
    end,
    calculate = function(self, card, context)
        -- Undbuff the right joker at start of each blind
        if context.setting_blind and not context.blueprint then
            local my_pos = nil
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then my_pos = i; break end
            end
            if my_pos and G.jokers.cards[my_pos + 1] then
                local right = G.jokers.cards[my_pos + 1]
                if right.debuff then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            right:set_debuff(false)
                            return true
                        end
                    }))
                end
            end
        end

        -- Debuff right joker after each hand with scaling chance
        if context.after and not context.blueprint then
            local my_pos = nil
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then my_pos = i; break end
            end
            if my_pos and G.jokers.cards[my_pos + 1] then
                local right = G.jokers.cards[my_pos + 1]
                local effective_chance = math.max(1, Warcraft.get_scaled_gain(card, card.ability.extra.debuff_chance, card.ability.extra.debuff_chance_per_level, card.ability.extra.debuff_chance_per_ilvl))
                if pseudorandom('balnazzar') < G.GAME.probabilities.normal / effective_chance then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            right:set_debuff(true)
                            card_eval_status_text(card, 'extra', nil, nil, nil, {
                                message = "Possessed!",
                                colour = G.C.PURPLE
                            })
                            return true
                        end
                    }))
                end
            end
        end

        -- Copy right joker effect during blind
        if G.STATE ~= G.STATES.SHOP and G.jokers and G.jokers.cards then
            local my_pos = nil
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then my_pos = i; break end
            end
            if my_pos and G.jokers.cards[my_pos + 1] then
                local right = G.jokers.cards[my_pos + 1]
                if right and right ~= card and not right.debuff then
                    context.blueprint = (context.blueprint_card or card)
                    context.blueprint_card = context.blueprint_card or card
                    if right.ability and right.calculate_joker then
                        local ret = right:calculate_joker(context)
                        context.blueprint = nil
                        context.blueprint_card = nil
                        if ret then
                            ret.card = card
                            ret.colour = G.C.PURPLE
                            return ret
                        end
                    end
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Baron Ashbury",
    race = {"Human", "Undead"},
    class = {"Priest"},
    weapon = {"Sword","Daggers"},
    damage = {"Physical"},
    armor = {"Leather"},
    profession = {},
    combo = {"Lord Godfrey", "Sylvanas Windrunner", "Archmage Arugal", "Genn Greymane"},
    role = {"Melee DPS"},
    rarity = 3,
    cost = 8,
    index = 295,
    config = { extra = { chips = 0, drain_percent = 0.99, drain_percent_per_ilvl = -0.005, mult = 5, mult_per_level = 1, mult_per_ilvl = 0.5 } },
    loc_txt = {
        "{C:mult}+#3#{} Mult. Before scoring,",
        "drains {C:attention}#1#%{} of current Chips",
        "as permanent {C:chips}+Chips{} on this Joker.",
        "{C:inactive}(Currently {C:chips}+#2#{C:inactive} Chips){}"
    },
    loc_vars = function(self, info_queue, card)
        local effective_drain = Warcraft.get_scaled_gain(card, card.ability.extra.drain_percent, 0, card.ability.extra.drain_percent_per_ilvl)
        effective_drain = math.max(0.01, math.min(0.99, effective_drain))
        return {
            math.floor(effective_drain * 100),
            card.ability.extra.chips,
            Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        -- Drain chips before scoring
        if context.before and not context.blueprint then
            local effective_drain = Warcraft.get_scaled_gain(card, card.ability.extra.drain_percent, 0, card.ability.extra.drain_percent_per_ilvl)
            effective_drain = math.max(0.01, math.min(0.99, effective_drain))
            if hand_chips and hand_chips > 0 then
                local drained = math.floor(hand_chips * effective_drain)
                hand_chips = hand_chips - drained
                card.ability.extra.chips = card.ability.extra.chips + drained
                return {
                    message = "Pain Suppression!",
                    colour = G.C.PURPLE,
                    card = card
                }
            end
        end

        -- Apply accumulated chips and mult during scoring
        if context.joker_main then
            local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl)
            local result = {
                mult = effective_mult,
                card = card
            }
            if card.ability.extra.chips > 0 then
                result.chips = card.ability.extra.chips
            end
            return result
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Amnennar the Coldbringer",
    faction = {"Scourge"},
    race = {"Undead"},
    class = {"Mage"},
    weapon = {"Staff"},
    damage = {"Frost"},
    armor = {"Mail"},
    profession = {},
    combo = {"Agamaggan", "Kel'Thuzad", "Agem Cursethorn"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 6,
    index = 296,
    config = { extra = { chance_per_level = -0.15, chance_per_ilvl = -0.1, base_chance = 8 } },
    loc_txt = {
        "If scoring hand contains",
        "{C:attention}no duplicate ranks{},",
        "{C:green}1 in #1#{} chance to transform",
        "a random scoring card into",
        "a {C:attention}Glass{} or {C:attention}Stone{} Card"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_glass
        info_queue[#info_queue+1] = G.P_CENTERS.m_stone
        return { math.max(1, Warcraft.get_scaled_gain(card, card.ability.extra.base_chance, card.ability.extra.chance_per_level, card.ability.extra.chance_per_ilvl)) }
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            -- Check for duplicate ranks in scoring hand
            local seen_ranks = {}
            local has_duplicate = false
            for _, v in ipairs(context.scoring_hand) do
                local rank = v.base.value
                if seen_ranks[rank] then
                    has_duplicate = true
                    break
                end
                seen_ranks[rank] = true
            end

            if not has_duplicate and #context.scoring_hand > 0 then
                local effective_chance = math.max(1, Warcraft.get_scaled_gain(card, card.ability.extra.base_chance, card.ability.extra.chance_per_level, card.ability.extra.chance_per_ilvl))
                if pseudorandom('amnennar') < G.GAME.probabilities.normal / effective_chance then
                    -- Pick a random scoring card that isn't already glass or stone
                    local valid_targets = {}
                    for _, v in ipairs(context.scoring_hand) do
                        if v.config.center.key ~= 'm_glass' and v.config.center.key ~= 'm_stone' then
                            table.insert(valid_targets, v)
                        end
                    end

                    if #valid_targets > 0 then
                        local target = pseudorandom_element(valid_targets, pseudoseed('amnennar_target_' .. G.GAME.round))
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                -- Randomly choose glass or stone
                                local roll = pseudorandom('amnennar_type_' .. G.GAME.round)
                                if roll < 0.5 then
                                    target:set_ability(G.P_CENTERS.m_glass, nil, true)
                                    card_eval_status_text(card, 'extra', nil, nil, nil, {
                                        message = "Frozen!",
                                        colour = G.C.CHIPS
                                    })
                                else
                                    target:set_ability(G.P_CENTERS.m_stone, nil, true)
                                    card_eval_status_text(card, 'extra', nil, nil, nil, {
                                        message = "Entombed!",
                                        colour = G.C.GREY
                                    })
                                end
                                target:juice_up()
                                return true
                            end
                        }))
                        return {
                            message = "Coldbringer!",
                            colour = G.C.CHIPS,
                            card = card
                        }
                    end
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Archaedas",
    faction = {"Pantheon"},
    race = {"Titan"},
    weapon = {"Fist"},
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {},
    combo = {"Tyr", "Ironaya", "Khaz'goroth", "Norgannon"},
    role = {"Tank"},
    rarity = 2,
    cost = 6,
    index = 297,
    config = { extra = { chips = 10, chips_per_level = 5, chips_per_ilvl = 3, stone_gain = 5, stone_gain_per_level = 1, stone_gain_per_ilvl = 0.5, accumulated = 0 } },
    loc_txt = {
        "{C:chips}+#1#{} Chips.",
        "Each time a {C:attention}Stone Card{} scores,",
        "gain {C:chips}+#2#{} permanent Chips",
        "and give it all accumulated",
        "Chips as permanent Chips.",
        "{C:inactive}(Accumulated: {C:chips}+#3#{C:inactive}){}"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_stone
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.chips, card.ability.extra.chips_per_level, card.ability.extra.chips_per_ilvl),
            Warcraft.get_scaled_gain(card, card.ability.extra.stone_gain, card.ability.extra.stone_gain_per_level, card.ability.extra.stone_gain_per_ilvl),
            card.ability.extra.accumulated
        }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            if context.other_card.config.center.key == 'm_stone' then
                local effective_gain = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.stone_gain, card.ability.extra.stone_gain_per_level, card.ability.extra.stone_gain_per_ilvl))

                -- Archaedas accumulates chips
                card.ability.extra.accumulated = card.ability.extra.accumulated + effective_gain

                -- Stone card receives all of Archaedas's accumulated chips
                context.other_card.ability.perma_bonus = (context.other_card.ability.perma_bonus or 0) + card.ability.extra.accumulated

                G.E_MANAGER:add_event(Event({
                    func = function()
                        context.other_card:juice_up()
                        return true
                    end
                }))

                return {
                    message = "Awakened!",
                    colour = G.C.ORANGE,
                    card = card
                }
            end
        end

        if context.joker_main then
            local effective_chips = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.chips, card.ability.extra.chips_per_level, card.ability.extra.chips_per_ilvl))
            return {
                chips = effective_chips,
                card = card
            }
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Lady Deathwhisper",
    faction = {"Scourge"},
    race = {"Undead"},
    class = {"Warlock"},
    weapon = {"Staff"},
    damage = {"Frost"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Darkmaster Gandling", "Lich King", "Baron Rivendare", "Kel'Thuzad", "Mal'Ganis"},
    role = {"Ranged DPS"},
    rarity = 3,
    cost = 8,
    index = 298,
    config = { extra = { chance = 4, chance_per_level = -0.2, chance_per_ilvl = -0.1 } },
    loc_txt = {
        "Scoring {C:attention}Glass{} or {C:attention}Stone Cards{}",
        "have a {C:green}1 in #1#{} chance to be",
        "duplicated into your deck",
        "and placed in your {C:attention}hand{}"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_glass
        info_queue[#info_queue+1] = G.P_CENTERS.m_stone
        return { Warcraft.get_scaled_gain(card, card.ability.extra.chance, card.ability.extra.chance_per_level, card.ability.extra.chance_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            local other = context.other_card
            local is_glass = other.config.center.key == 'm_glass'
            local is_stone = other.config.center.key == 'm_stone'

            if is_glass or is_stone then
                local effective_chance = math.max(1, Warcraft.get_scaled_gain(card, card.ability.extra.chance, card.ability.extra.chance_per_level, card.ability.extra.chance_per_ilvl))
                if pseudorandom('deathwhisper') < G.GAME.probabilities.normal / effective_chance then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            local copy = copy_card(other, nil, nil, G.playing_card)
                            copy.shattered = nil
                            copy.destroyed = nil
                            copy:add_to_deck()
                            G.deck.config.card_limit = G.deck.config.card_limit + 1
                            table.insert(G.playing_cards, copy)
                            -- Place directly into hand
                            G.hand:emplace(copy)
                            G.hand:sort()
                            copy:juice_up()
                            card_eval_status_text(card, 'extra', nil, nil, nil, {
                                message = "Arise, Servant!",
                                colour = G.C.DARK_EDITION
                            })
                            return true
                        end
                    }))
                    return {
                        message = "Cult of the Damned!",
                        colour = G.C.DARK_EDITION,
                        card = card
                    }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "General Drakkisath",
    race = {"Dragon"},
    class = {"Warrior"},
    weapon = {"Sword", "Fist"},
    damage = {"Fire"},
    armor = {"Mail"},
    profession = {},
    combo = {"Nefarian", "Ragnaros", "Chromaggus"},
    role = {"Tank"},
    rarity = 3,
    cost = 8,
    index = 299,
    config = { extra = { mult_per_level = 1, mult_per_level_per_level = 0.2, mult_per_level_per_ilvl = 0.1 } },
    loc_txt = {
        "{C:mult}+Mult{} equal to the combined",
        "{C:attention}Level{} of all {C:attention}Dragon{} Jokers.",
        "At end of {C:attention}Shop{}, give {C:attention}+1 Level{}",
        "to a random {C:attention}Dragon{} Joker",
        "for each {C:attention}Dragon{} Joker you own."
    },
    loc_vars = function(self, info_queue, card)
        local total_levels = 0
        local dragon_count = 0
        if G.jokers then
            for _, j in ipairs(G.jokers.cards) do
                if j ~= card and Warcraft.is_race(j, "Dragon") then
                    dragon_count = dragon_count + 1
                    total_levels = total_levels + (j.ability.extra and j.ability.extra.level or 1)
                end
            end
        end
        local effective_per = Warcraft.get_scaled_gain(card, card.ability.extra.mult_per_level, card.ability.extra.mult_per_level_per_level, card.ability.extra.mult_per_level_per_ilvl)
        return { effective_per, total_levels, dragon_count }
    end,
    calculate = function(self, card, context)
        -- Give levels to random dragon jokers at end of shop
        if context.ending_shop and not context.blueprint then
            local dragon_jokers = {}
            for _, j in ipairs(G.jokers.cards) do
                if j ~= card and Warcraft.is_race(j, "Dragon") then
                    table.insert(dragon_jokers, j)
                end
            end

            if #dragon_jokers > 0 then
                -- Give one level per dragon joker owned
                for i = 1, #dragon_jokers do
                    local target = pseudorandom_element(dragon_jokers, pseudoseed('drakkisath_level_' .. i .. '_' .. G.GAME.round))
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            if target.ability.extra then
                                target.ability.extra.level = (target.ability.extra.level or 1) + 1
                                if target.ability.extra.max_level and target.ability.extra.level > target.ability.extra.max_level then
                                    target.ability.extra.max_level = target.ability.extra.level
                                end
                                card_eval_status_text(target, 'extra', nil, nil, nil, {
                                    message = "Level Up!",
                                    colour = G.C.GREEN
                                })
                                target:juice_up()
                            end
                            return true
                        end
                    }))
                end
                return {
                    message = "Blackrock Command!",
                    colour = G.C.RED,
                    card = card
                }
            end
        end

        -- +Mult equal to combined dragon levels
        if context.joker_main then
            local total_levels = 0
            for _, j in ipairs(G.jokers.cards) do
                if j ~= card and Warcraft.is_race(j, "Dragon") then
                    total_levels = total_levels + (j.ability.extra and j.ability.extra.level or 1)
                end
            end
            if total_levels > 0 then
                local effective_per = Warcraft.get_scaled_gain(card, card.ability.extra.mult_per_level, card.ability.extra.mult_per_level_per_level, card.ability.extra.mult_per_level_per_ilvl)
                return {
                    mult = total_levels * effective_per,
                    message = "Conflagration!",
                    colour = G.C.RED,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Dark Animus",
    race = {"Undead", "Robot"},
    weapon = {"Fist"},
    damage = {"Nature"},
    armor = {"Plate"},
    profession = {},
    combo = {"Lei Shen", "Ra-Den", "Taoshi"},
    role = {"Tank"},
    rarity = 2,
    cost = 7,
    index = 300,
    config = { extra = { 
        accumulated = 0, 
        drain_amt = 1, 
        chips_per_dollar = 10, 
        chips_per_dollar_per_level = 2, 
        chips_per_dollar_per_ilvl = 1 
    } },
    loc_txt = {
        "At end of each {C:attention}Blind{}, drain",
        "{C:money}$#1#{} sell value from {C:attention}adjacent Jokers{}.",
        "Gains {C:chips}+#2#{} Chips for every {C:money}$1{} drained.",
        "Scoring cards gain the accumulated",
        "{C:chips}Chips{} permanently.",
        "{C:inactive}(Accumulated: {C:chips}+#3#{C:inactive}){}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.drain_amt,
            math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.chips_per_dollar, card.ability.extra.chips_per_dollar_per_level, card.ability.extra.chips_per_dollar_per_ilvl)),
            card.ability.extra.accumulated
        }
    end,
    calculate = function(self, card, context)
        -- Drain adjacent jokers at end of blind (using main_eval to prevent double-triggering!)
        if context.end_of_round and context.main_eval and not context.blueprint then
            local my_pos = nil
            if G.jokers and G.jokers.cards then
                for i = 1, #G.jokers.cards do
                    if G.jokers.cards[i] == card then my_pos = i; break end
                end
            end

            if my_pos then
                local drain_amt = card.ability.extra.drain_amt
                local effective_multiplier = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.chips_per_dollar, card.ability.extra.chips_per_dollar_per_level, card.ability.extra.chips_per_dollar_per_ilvl))
                local total_drained = 0

                local function drain_joker(j)
                    if j and not j.ability.eternal then
                        -- Decrease sell value
                        j.ability.extra_value = (j.ability.extra_value or 0) - drain_amt
                        j:set_cost()
                        total_drained = total_drained + drain_amt
                        
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                j:juice_up()
                                card_eval_status_text(j, 'extra', nil, nil, nil, {
                                    message = "-$" .. drain_amt .. " Value",
                                    colour = G.C.MONEY
                                })
                                -- Destroy if sell cost reaches 0
                                if j.sell_cost <= 0 and not j.ability.eternal and not j.getting_sliced then
                                    j.getting_sliced = true
                                    j:start_dissolve({remove_as_card = true})
                                end
                                return true
                            end
                        }))
                    end
                end

                -- Drain left neighbor
                drain_joker(G.jokers.cards[my_pos - 1])
                -- Drain right neighbor
                drain_joker(G.jokers.cards[my_pos + 1])

                -- Calculate and add the scaled chips
                if total_drained > 0 then
                    local chips_gained = total_drained * effective_multiplier
                    card.ability.extra.accumulated = card.ability.extra.accumulated + chips_gained
                    
                    return {
                        message = "Life Drain!",
                        colour = G.C.PURPLE,
                        card = card
                    }
                end
            end
        end

        -- Give accumulated chips to scoring cards as perma bonus
        if context.individual and context.cardarea == G.play and not context.blueprint then
            if card.ability.extra.accumulated > 0 then
                local played_card = context.other_card
                
                played_card.ability.perma_bonus = (played_card.ability.perma_bonus or 0) + card.ability.extra.accumulated
                
                G.E_MANAGER:add_event(Event({
                    func = function()
                        played_card:juice_up()
                        return true
                    end
                }))
                
                return {
                    message = "Animated!",
                    colour = G.C.PURPLE,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Star Augur Etraeus",
    faction = {"Legion"},
    race = {"Night Elf", "Demon"},
    class = {"Mage"},
    weapon = {"Staff"},
    damage = {"Arcane"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Grand Magistrix Elisande", "Tichondrius", "Gul'dan", "Illidan Stormrage", "Thalyssra"},
    role = {"Ranged DPS"},
    rarity = 3,
    cost = 8,
    index = 301,
    config = { extra = { x_mult = 1, x_mult_gain = 0.3, x_mult_gain_per_level = 0.05, x_mult_gain_per_ilvl = 0.03 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "Gains {X:mult,C:white} X#2# {} when a hand",
        "containing a {C:attention}Pair{} is played.",
        "If the {C:attention}Pair{} cards are not",
        "{C:attention}adjacent{}, this Joker is {C:red}destroyed{}."
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.x_mult,
            Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_gain, card.ability.extra.x_mult_gain_per_level, card.ability.extra.x_mult_gain_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            -- Check if the hand contains a pair
            local rank_positions = {}
            for i, v in ipairs(context.scoring_hand) do
                local rank = v.base.value
                if not rank_positions[rank] then
                    rank_positions[rank] = {}
                end
                table.insert(rank_positions[rank], i)
            end

            -- Find if any rank appears exactly twice (a pair)
            local pair_positions = nil
            for rank, positions in pairs(rank_positions) do
                if #positions >= 2 then
                    pair_positions = positions
                    break
                end
            end

            if pair_positions then
                -- Check adjacency — the two paired cards must be next to each other
                local pos1 = pair_positions[1]
                local pos2 = pair_positions[2]
                local are_adjacent = math.abs(pos1 - pos2) == 1

                if not are_adjacent then
                    -- Destroy the joker
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            play_sound('tarot1')
                            card.T.r = -0.2
                            card:juice_up(0.3, 0.4)
                            card:start_dissolve({remove_as_card = true})
                            return true
                        end
                    }))
                    return {
                        message = "Misaligned!",
                        colour = G.C.RED
                    }
                else
                    -- Pair is adjacent — gain XMult
                    local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_gain, card.ability.extra.x_mult_gain_per_level, card.ability.extra.x_mult_gain_per_ilvl)
                    card.ability.extra.x_mult = card.ability.extra.x_mult + effective_gain
                    return {
                        message = "Aligned!",
                        colour = G.C.PURPLE,
                        card = card
                    }
                end
            end
        end

        if context.joker_main then
            if card.ability.extra.x_mult > 1 then
                return {
                    Xmult_mod = card.ability.extra.x_mult,
                    message = "Cosmic!",
                    colour = G.C.PURPLE,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Durumu the Forgotten",
    faction = {"Horde", "Alliance"},
    race = {"Demon"},
    weapon = {"Fist"},
    damage = {"Fire"},
    armor = {"Leather"},
    profession = {},
    combo = {"Lei Shen", "Dark Animus", "Ra-Den"},
    role = {"Ranged DPS"},
    rarity = 3,
    cost = 8,
    index = 302,
    config = { extra = {
        mult = 0, chips = 0,
        mult_gain = 5, mult_gain_per_level = 1, mult_gain_per_ilvl = 0.5,
        chips_gain = 20, chips_gain_per_level = 3, chips_gain_per_ilvl = 2
    } },
    loc_txt = {
        "{C:mult}+#1#{} Mult, {C:chips}+#2#{} Chips",
        "If scoring cards are in order",
        "from {C:attention}lowest{} to {C:attention}highest{} rank,",
        "gain {C:mult}+#3#{} Mult and {C:chips}+#4#{} Chips permanently.",
        "{C:inactive}(Currently {C:mult}+#1#{C:inactive} Mult, {C:chips}+#2#{C:inactive} Chips){}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.mult,
            card.ability.extra.chips,
            Warcraft.get_scaled_gain(card, card.ability.extra.mult_gain, card.ability.extra.mult_gain_per_level, card.ability.extra.mult_gain_per_ilvl),
            Warcraft.get_scaled_gain(card, card.ability.extra.chips_gain, card.ability.extra.chips_gain_per_level, card.ability.extra.chips_gain_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            if #context.scoring_hand < 2 then return end

            -- Helper to get rank, with ace_high flag
            local function get_rank(c, ace_high)
                local id = c:get_id()
                if id == 14 then return ace_high and 14 or 1 end
                return id
            end

            local function check_ascending(ace_high)
                for i = 2, #context.scoring_hand do
                    local prev = get_rank(context.scoring_hand[i - 1], ace_high)
                    local curr = get_rank(context.scoring_hand[i], ace_high)
                    if curr < prev then return false end
                end
                return true
            end

            -- Valid if ascending with Ace as low OR Ace as high
            local in_order = check_ascending(false) or check_ascending(true)

            if in_order then
                local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.mult_gain, card.ability.extra.mult_gain_per_level, card.ability.extra.mult_gain_per_ilvl)
                local effective_chips = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.chips_gain, card.ability.extra.chips_gain_per_level, card.ability.extra.chips_gain_per_ilvl))
                card.ability.extra.mult = card.ability.extra.mult + effective_mult
                card.ability.extra.chips = card.ability.extra.chips + effective_chips
                return {
                    message = "The Beam!",
                    colour = G.C.PURPLE,
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
    name = "Elegon",
    faction = {"Horde", "Alliance"},
    race = {"Dragon", "God"},
    class = {"Mage"},
    weapon = {"Fist"},
    damage = {"Arcane"},
    armor = {"Unarmored"},
    profession = {},
    combo = {"Lorewalker Cho", "Lei Shen", "Yu'lon"},
    role = {"Ranged DPS"},
    rarity = 3,
    cost = 8,
    index = 303,
    config = { extra = { copies = 1, copies_per_level = 0.2, copies_per_ilvl = 0.1, used_this_shop = false } },
    loc_txt = {
        "The {C:attention}first Planet card{} used",
        "each {C:attention}Shop{} creates {C:attention}#1#{}",
        "{C:dark_edition}Negative{} copy/copies of itself"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.copies, card.ability.extra.copies_per_level, card.ability.extra.copies_per_ilvl) }
    end,
    calculate = function(self, card, context)
        -- Reset at start of each shop
        if context.starting_shop and not context.blueprint then
            card.ability.extra.used_this_shop = false
        end

        if context.using_consumeable and not context.blueprint and not card.ability.extra.used_this_shop then
            local source = context.consumeable
            if source and source.ability.set == 'Planet' then
                card.ability.extra.used_this_shop = true
                local effective_copies = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.copies, card.ability.extra.copies_per_level, card.ability.extra.copies_per_ilvl))

                G.E_MANAGER:add_event(Event({
                    func = function()
                        for i = 1, effective_copies do
                            if #G.consumeables.cards < G.consumeables.config.card_limit then
                                local copy = create_card(
                                    'Planet',
                                    G.consumeables,
                                    nil, nil, nil, nil,
                                    source.config.center.key,
                                    'elegon'
                                )
                                copy:set_edition({negative = true}, true)
                                copy:add_to_deck()
                                G.consumeables:emplace(copy)
                                copy:juice_up()
                            end
                        end
                        card_eval_status_text(card, 'extra', nil, nil, nil, {
                            message = "Celestial!",
                            colour = G.C.FILTER
                        })
                        return true
                    end
                }))
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Arcanist Doan",
    faction = {"Alliance"},
    race = {"Human"},
    class = {"Mage"},
    weapon = {"Staff"},
    damage = {"Arcane"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Sally Whitemane", "Alexandros Mograine", "Darion Mograine"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 6,
    index = 304,
    config = { extra = { x_mult = 1, x_mult_gain = 0.3, x_mult_gain_per_level = 0.05, x_mult_gain_per_ilvl = 0.03 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "{C:red}Debuffs{} adjacent Jokers before",
        "scoring, then unDebuffs after.",
        "Gains {X:mult,C:white} X#2# {} per Joker",
        "Debuffed this way."
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.x_mult,
            Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_gain, card.ability.extra.x_mult_gain_per_level, card.ability.extra.x_mult_gain_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local my_pos = nil
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then my_pos = i; break end
            end

            if my_pos then
                local silenced = {}
                local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_gain, card.ability.extra.x_mult_gain_per_level, card.ability.extra.x_mult_gain_per_ilvl)

                local function silence(j)
                    if j and not j.debuff and not j.ability.eternal then
                        j:set_debuff(true)
                        table.insert(silenced, j)
                        card.ability.extra.x_mult = card.ability.extra.x_mult + effective_gain
                    end
                end

                silence(G.jokers.cards[my_pos - 1])
                silence(G.jokers.cards[my_pos + 1])

                if #silenced > 0 then
                    -- Schedule unDebuff after scoring
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        blockable = false,
                        func = function()
                            for _, j in ipairs(silenced) do
                                if j and j.debuff then
                                    j:set_debuff(false)
                                end
                            end
                            return true
                        end
                    }))
                    return {
                        message = "SILENCE!",
                        colour = G.C.PURPLE,
                        card = card
                    }
                end
            end
        end

        if context.joker_main then
            if card.ability.extra.x_mult > 1 then
                return {
                    Xmult_mod = card.ability.extra.x_mult,
                    message = "Arcane Power!",
                    colour = G.C.PURPLE,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Coren Direbrew",
    race = {"Dwarf"},
    class = {"Warrior"},
    weapon = {"Hammer", "Fist"},
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {},
    combo = {"Chen Stormstout", "Emperor Dagran Thaurissan", "Moira Thaurissan"},
    role = {"Tank"},
    rarity = 2,
    cost = 5,
    index = 305,
    config = { extra = { levels_per_reroll = 1, levels_per_reroll_per_level = 0.2, levels_per_reroll_per_ilvl = 0.1 } },
    loc_txt = {
        "Each time you {C:attention}Reroll{} the shop,",
        "give {C:attention}+#1#{} Level(s){} to a",
        "random {C:attention}Joker{}"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.levels_per_reroll, card.ability.extra.levels_per_reroll_per_level, card.ability.extra.levels_per_reroll_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.reroll_shop and not context.blueprint then
            local valid_jokers = {}
            for _, j in ipairs(G.jokers.cards) do
                if j ~= card and j.ability.extra and j.ability.extra.level then
                    table.insert(valid_jokers, j)
                end
            end

            if #valid_jokers > 0 then
                local target = pseudorandom_element(valid_jokers, pseudoseed('coren_' .. G.GAME.round .. '_' .. (G.GAME.rerolls or 0)))
                local effective_levels = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.levels_per_reroll, card.ability.extra.levels_per_reroll_per_level, card.ability.extra.levels_per_reroll_per_ilvl))

                G.E_MANAGER:add_event(Event({
                    func = function()
                        target.ability.extra.level = (target.ability.extra.level or 1) + effective_levels
                        if target.ability.extra.max_level and target.ability.extra.level > target.ability.extra.max_level then
                            target.ability.extra.max_level = target.ability.extra.level
                        end
                        card_eval_status_text(target, 'extra', nil, nil, nil, {
                            message = "Cheers!",
                            colour = G.C.GOLD
                        })
                        target:juice_up()
                        return true
                    end
                }))

                return {
                    message = "Another Round!",
                    colour = G.C.GOLD,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Lord Godfrey",
    faction = {"Alliance"},
    race = {"Human", "Undead"},
    class = {"Rogue"},
    weapon = {"Gun", "Sword"},
    damage = {"Piercing"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Genn Greymane", "Baron Ashbury", "Darius Crowley", "Sylvanas Windrunner"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 6,
    index = 306,
    config = { extra = { rank_reduction = 2, money_gain = 5, money_gain_per_level = 1, money_gain_per_ilvl = 0.5 } },
    loc_txt = {
        "If you discard a {C:attention}single card{},",
        "lower its rank by {C:attention}#1#{}.",
        "If rank drops below {C:attention}2{},",
        "destroy it and gain {C:money}$#2#{}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.rank_reduction,
            Warcraft.get_scaled_gain(card, card.ability.extra.money_gain, card.ability.extra.money_gain_per_level, card.ability.extra.money_gain_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.discard and not context.blueprint then
            -- Only trigger on single card discards
            if #context.full_hand ~= 1 then return end

            local target = context.full_hand[1]
            if not target then return end

            local current_id = target:get_id()
            -- Map rank id to rank string
            local rank_map = {
                [2] = "2", [3] = "3", [4] = "4", [5] = "5",
                [6] = "6", [7] = "7", [8] = "8", [9] = "9",
                [10] = "T", [11] = "J", [12] = "Q", [13] = "K", [14] = "A"
            }
            local new_id = current_id - card.ability.extra.rank_reduction

            if new_id < 2 then
                -- Destroy the card and gain money
                local effective_money = Warcraft.get_scaled_gain(card, card.ability.extra.money_gain, card.ability.extra.money_gain_per_level, card.ability.extra.money_gain_per_ilvl)
                G.E_MANAGER:add_event(Event({
                    func = function()
                        ease_dollars(math.floor(effective_money))
                        target:start_dissolve({remove_as_card = true})
                        card_eval_status_text(card, 'extra', nil, nil, nil, {
                            message = "Executed!",
                            colour = G.C.RED
                        })
                        return true
                    end
                }))
                return {
                    message = "Pistol Barrage!",
                    colour = G.C.RED,
                    card = card
                }
            else
                -- Lower the rank
                local new_rank = rank_map[new_id]
                if new_rank then
                    local suit_prefix = string.sub(target.base.suit, 1, 1)
                    local new_key = suit_prefix .. "_" .. new_rank
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            if G.P_CARDS[new_key] then
                                target:set_base(G.P_CARDS[new_key])
                                target:juice_up()
                                card_eval_status_text(card, 'extra', nil, nil, nil, {
                                    message = "-" .. card.ability.extra.rank_reduction .. " Rank!",
                                    colour = G.C.RED
                                })
                            end
                            return true
                        end
                    }))
                    return {
                        message = "Cursed Bullets!",
                        colour = G.C.RED,
                        card = card
                    }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Festergut",
    faction = {"Scourge"},
    race = {"Undead"},
    class = {"Warlock"},
    weapon = {"Fist"},
    damage = {"Nature"},
    armor = {"Leather"},
    profession = {},
    combo = {"Professor Putricide", "Rotface", "Lich King"},
    role = {"Tank"},
    rarity = 2,
    cost = 6,
    index = 307,
    config = { extra = { mult_per_card = 8, mult_per_card_per_level = 1, mult_per_card_per_ilvl = 0.5, current_mult = 0 } },
    loc_txt = {
        "{C:mult}+#2#{} Mult",
        "Gains {C:mult}+#1#{} Mult per card",
        "{C:attention}discarded{}.",
        "{C:red}Resets{} after the next hand played.",
        "{C:inactive}(Currently {C:mult}+#2#{C:inactive} Mult){}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.mult_per_card, card.ability.extra.mult_per_card_per_level, card.ability.extra.mult_per_card_per_ilvl),
            card.ability.extra.current_mult
        }
    end,
    calculate = function(self, card, context)
        -- Stack mult per discarded card
        if context.discard and not context.blueprint then
            local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.mult_per_card, card.ability.extra.mult_per_card_per_level, card.ability.extra.mult_per_card_per_ilvl)
            card.ability.extra.current_mult = card.ability.extra.current_mult + effective_gain
            return {
                message = "Inhale!",
                colour = G.C.GREEN,
                card = card
            }
        end

        -- Apply mult then reset after hand is played
        if context.joker_main then
            if card.ability.extra.current_mult > 0 then
                return {
                    mult = card.ability.extra.current_mult,
                    message = "EXHALE!",
                    colour = G.C.GREEN,
                    card = card
                }
            end
        end

        -- Reset after hand is scored
        if context.after and not context.blueprint then
            if card.ability.extra.current_mult > 0 then
                card.ability.extra.current_mult = 0
                return {
                    message = "Reset...",
                    colour = G.C.RED,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Rotface",
    faction = {"Scourge"},
    race = {"Undead"},
    class = {"Warlock"},
    weapon = {"Fist"},
    damage = {"Nature"},
    armor = {"Leather"},
    profession = {},
    combo = {"Professor Putricide", "Festergut", "Lich King"},
    role = {"Tank"},
    rarity = 2,
    cost = 6,
    index = 308,
    config = { extra = { x_mult = 2, x_mult_per_level = 0.3, x_mult_per_ilvl = 0.2 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "When {C:red}destroyed{}, replace",
        "this Joker with a random",
        "{C:red}Rare{} Joker"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                Xmult_mod = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
                message = "Mutated!",
                colour = G.C.GREEN,
                card = card
            }
        end

        -- Trigger on destruction (not sale)
        if context.remove_from_deck and context.card == card
        and not context.selling_self and not context.blueprint then
            G.E_MANAGER:add_event(Event({
                func = function()
                    if #G.jokers.cards < G.jokers.config.card_limit then
                        local new_card = create_card('Joker', G.jokers, nil, 0.99, nil, nil, nil, 'rotface')
                        new_card:add_to_deck()
                        G.jokers:emplace(new_card)
                        new_card:start_materialize()
                        card_eval_status_text(new_card, 'extra', nil, nil, nil, {
                            message = "Mutated Into!",
                            colour = G.C.GREEN
                        })
                    end
                    return true
                end
            }))
            return {
                message = "Ooze!",
                colour = G.C.GREEN
            }
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Flame Leviathan",
    race = {"Robot"},
    damage = {"Fire"},
    armor = {"Plate"},
    profession = {},
    combo = {"Mimiron", "XT-002 Deconstructor", "V-07-TR-0N"},
    role = {"Tank"},
    rarity = 2,
    cost = 6,
    index = 309,
    config = { extra = { chips = 30, chips_per_level = 5, chips_per_ilvl = 3, mult = 5, mult_per_level = 1, mult_per_ilvl = 0.5 } },
    loc_txt = {
        "Each time a {C:attention}Steel Card{}",
        "is drawn, gain",
        "{C:chips}+#1#{} Chips and {C:mult}+#2#{} Mult",
        "permanently"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_steel
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.chips, card.ability.extra.chips_per_level, card.ability.extra.chips_per_ilvl),
            Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.hand_drawn and not context.blueprint then
            local effective_chips = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.chips, card.ability.extra.chips_per_level, card.ability.extra.chips_per_ilvl))
            local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl)
            local found = false

            for _, drawn_card in ipairs(context.hand_drawn) do
                if drawn_card.config.center == G.P_CENTERS.m_steel then
                    card.ability.extra.chips = card.ability.extra.chips + effective_chips
                    card.ability.extra.mult = card.ability.extra.mult + effective_mult
                    found = true
                end
            end

            if found then
                return {
                    message = "Orbital Strike!",
                    colour = G.C.ORANGE,
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
    name = "Eadric the Pure",
    faction = {"Alliance"},
    race = {"Human"},
    class = {"Paladin"},
    weapon = {"Hammer", "Shield"},
    damage = {"Holy"},
    armor = {"Plate"},
    profession = {},
    combo = {"Tirion Fordring", "Lich King", "Turalyon", "Arator the Redeemer"},
    role = {"Healer"},
    rarity = 2,
    cost = 6,
    index = 310,
    config = { extra = { x_mult = 2, x_mult_per_level = 0.3, x_mult_per_ilvl = 0.2 } },
    loc_txt = {
        "If scoring hand contains a {C:attention}Pair{},",
        "transform all cards of that",
        "rank into {C:attention}Aces{}.",
        "Gives {X:mult,C:white} X#1# {} Mult."
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            -- Find paired ranks in scoring hand
            local rank_counts = {}
            for _, v in ipairs(context.scoring_hand) do
                local rank = v.base.value
                rank_counts[rank] = (rank_counts[rank] or 0) + 1
            end

            -- Find the first paired rank
            local paired_rank = nil
            for rank, count in pairs(rank_counts) do
                if count >= 2 then
                    paired_rank = rank
                    break
                end
            end

            if paired_rank then
                local transformed = false
                G.E_MANAGER:add_event(Event({
                    func = function()
                        -- Transform ALL cards of that rank in the scoring hand into Aces
                        for _, v in ipairs(context.scoring_hand) do
                            if v.base.value == paired_rank and v.base.value ~= 'Ace' then
                                local suit_prefix = string.sub(v.base.suit, 1, 1)
                                local ace_key = suit_prefix .. "_A"
                                if G.P_CARDS[ace_key] then
                                    v:set_base(G.P_CARDS[ace_key])
                                    v:juice_up()
                                    transformed = true
                                end
                            end
                        end
                        if transformed then
                            card_eval_status_text(card, 'extra', nil, nil, nil, {
                                message = "Purified!",
                                colour = G.C.GOLD
                            })
                        end
                        return true
                    end
                }))

                return {
                    x_mult = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
                    message = "Light's Hammer!",
                    colour = G.C.GOLD,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Dargrul",
    faction = {"Horde"},
    race = {"Drogbar"},
    class = {"Warrior"},
    weapon = {"Hammer", "Fist"},
    damage = {"Nature"},
    armor = {"Leather"},
    profession = {},
    combo = {"Neltharion", "Huln Highmountain", "Mayla Highmountain"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 6,
    index = 311,
    config = { extra = { x_mult = 2, x_mult_per_level = 0.3, x_mult_per_ilvl = 0.2, chance = 4, chance_per_level = -0.2, chance_per_ilvl = -0.1 } },
    loc_txt = {
        "Played {C:attention}Stone Cards{} give",
        "{X:mult,C:white} X#1# {} Mult, but have a",
        "{C:green}1 in #2#{} chance to destroy",
        "the card to the {C:attention}right{} after scoring"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_stone
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
            Warcraft.get_scaled_gain(card, card.ability.extra.chance, card.ability.extra.chance_per_level, card.ability.extra.chance_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            if context.other_card.config.center.key == 'm_stone' then
                local effective_chance = math.max(1, Warcraft.get_scaled_gain(card, card.ability.extra.chance, card.ability.extra.chance_per_level, card.ability.extra.chance_per_ilvl))

                if pseudorandom('dargrul') < G.GAME.probabilities.normal / effective_chance then
                    -- Find the card to the right in the scoring hand
                    local scored_idx = nil
                    for i, v in ipairs(context.scoring_hand) do
                        if v == context.other_card then
                            scored_idx = i
                            break
                        end
                    end

                    if scored_idx and context.scoring_hand[scored_idx + 1] then
                        local victim = context.scoring_hand[scored_idx + 1]
                        if not victim.dissolving then
                            G.E_MANAGER:add_event(Event({
                                func = function()
                                    victim:start_dissolve({remove_as_card = true})
                                    card_eval_status_text(card, 'extra', nil, nil, nil, {
                                        message = "Landslide!",
                                        colour = G.C.ORANGE
                                    })
                                    return true
                                end
                            }))
                        end
                    end
                end

                return {
                    x_mult = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
                    card = context.other_card,
                    message = "Pillar of Earth!",
                    colour = G.C.ORANGE
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Rehgar Earthfury",
    faction = {"Horde"},
    race = {"Orc"},
    class = {"Shaman"},
    weapon = {"Hammer", "Fist"},
    damage = {"Nature"},
    armor = {"Mail"},
    profession = {},
    combo = {"Varian Wrynn", "Thrall", "Broll Bearmantle", "Valeera Sanguinar", "Malfurion Stormrage", "Hamuul Runetoteù"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 6,
    index = 312,
    config = { extra = { retrigger = 2, retrigger_per_level = 0.2, retrigger_per_ilvl = 0.1 } },
    loc_txt = {
        "Cards with a {C:red}Red Seal{}",
        "retrigger {C:attention}#1#{} additional time(s).",
        "Using a {C:attention}Discard{} destroys a",
        "random {C:red}Red Seal{} card in your deck."
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.retrigger, card.ability.extra.retrigger_per_level, card.ability.extra.retrigger_per_ilvl) }
    end,
    calculate = function(self, card, context)
        -- Retrigger Red Seal cards
        if context.repetition and context.cardarea == G.play then
            if context.other_card:get_seal() == 'Red' then
                return {
                    message = "Ancestral Spirit!",
                    repetitions = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.retrigger, card.ability.extra.retrigger_per_level, card.ability.extra.retrigger_per_ilvl)),
                    card = card
                }
            end
        end

        -- Destroy a random Red Seal card when discarding
        if context.discard and not context.blueprint then
            -- Only trigger once per discard action
            if context.other_card ~= context.full_hand[1] then return end

            local red_seal_cards = {}
            for _, c in ipairs(G.playing_cards) do
                if c:get_seal() == 'Red' then
                    table.insert(red_seal_cards, c)
                end
            end

            if #red_seal_cards > 0 then
                local victim = pseudorandom_element(red_seal_cards, pseudoseed('rehgar_' .. G.GAME.round))
                G.E_MANAGER:add_event(Event({
                    func = function()
                        victim:start_dissolve({remove_as_card = true})
                        card_eval_status_text(card, 'extra', nil, nil, nil, {
                            message = "Blood Price!",
                            colour = G.C.RED
                        })
                        return true
                    end
                }))
                return {
                    message = "Blood Lust!",
                    colour = G.C.RED,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Jarod Shadowsong",
    faction = {"Alliance"},
    race = {"Night Elf"},
    class = {"Warrior"},
    weapon = {"Sword"},
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {},
    combo = {"Maiev Shadowsong", "Huln Highmountain", "Archimonde", "Malfurion Stormrage", "Tichondrius", "Shandris Feathermoon", "Tyrande Whisperwind"},
    role = {"Melee DPS"},
    rarity = 1,
    cost = 5,
    index = 313,
    config = { extra = { chance = 3, chance_per_level = -0.1, chance_per_ilvl = -0.05 } },
    loc_txt = {
        "When playing any {C:attention}Straight{},",
        "{C:green}1 in #1#{} chance to give a",
        "random {C:attention}Seal{} to the",
        "{C:attention}highest ranked{} card"
    },
    loc_vars = function(self, info_queue, card)
        return { math.max(1, Warcraft.get_scaled_gain(card, card.ability.extra.chance, card.ability.extra.chance_per_level, card.ability.extra.chance_per_ilvl)) }
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local hand_name = context.scoring_name
            if hand_name == "Straight" or hand_name == "Straight Flush" or hand_name == "Royal Flush" then
                local effective_chance = math.max(1, Warcraft.get_scaled_gain(card, card.ability.extra.chance, card.ability.extra.chance_per_level, card.ability.extra.chance_per_ilvl))
                if pseudorandom('jarod') < G.GAME.probabilities.normal / effective_chance then
                    -- Find highest ranked card in scoring hand
                    local highest_card = nil
                    local highest_id = -1
                    for _, v in ipairs(context.scoring_hand) do
                        local id = v:get_id()
                        if id > highest_id then
                            highest_id = id
                            highest_card = v
                        end
                    end

                    if highest_card then
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                local seals = {"Red", "Blue", "Gold", "Purple"}
                                local chosen = pseudorandom_element(seals, pseudoseed('jarod_seal_' .. G.GAME.round))
                                highest_card:set_seal(chosen, true, true)
                                highest_card:juice_up()
                                card_eval_status_text(card, 'extra', nil, nil, nil, {
                                    message = "Marked!",
                                    colour = G.C.GOLD
                                })
                                return true
                            end
                        }))
                        return {
                            message = "Demon Hunter!",
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
    name = "Fandral Staghelm",
    faction = {"Horde"},
    race = {"Night Elf"},
    class = {"Druid"},
    weapon = {"Staff"},
    damage = {"Fire"},
    armor = {"Leather"},
    profession = {},
    combo = {"Alysrazor","Ragnaros","Baleroc", "Malfurion Stormrage", "Broll Bearmantle", "Naralex", "Hamuul Runetotem"},
    role = {"Ranged DPS"},
    rarity = 3,
    cost = 8,
    index = 314,
    config = { extra = { bonus_choose = 1, bonus_choose_per_level = 0.2, bonus_choose_per_ilvl = 0.1 } },
    loc_txt = {
        "In {C:attention}Booster Packs{},",
        "choose {C:attention}#1#{} additional card(s)"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.bonus_choose, card.ability.extra.bonus_choose_per_level, card.ability.extra.bonus_choose_per_ilvl) }
    end,
    add_to_deck = function(self, card, from_debuff)
        local effective_bonus = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.bonus_choose, card.ability.extra.bonus_choose_per_level, card.ability.extra.bonus_choose_per_ilvl))
        card.ability.extra.current_bonus = effective_bonus
        G.E_MANAGER:add_event(Event({
            func = function()
                if G.pack_cards then
                    G.pack_cards.config.choose = (G.pack_cards.config.choose or 1) + effective_bonus
                end
                return true
            end
        }))
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.E_MANAGER:add_event(Event({
            func = function()
                if G.pack_cards then
                    G.pack_cards.config.choose = math.max(1, (G.pack_cards.config.choose or 1) - (card.ability.extra.current_bonus or 1))
                end
                return true
            end
        }))
    end,
    calculate = function(self, card, context)
        -- Update choose count when opening a pack
        if context.open_booster and not context.blueprint then
            local effective_bonus = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.bonus_choose, card.ability.extra.bonus_choose_per_level, card.ability.extra.bonus_choose_per_ilvl))
            if effective_bonus ~= (card.ability.extra.current_bonus or 1) then
                local diff = effective_bonus - (card.ability.extra.current_bonus or 1)
                card.ability.extra.current_bonus = effective_bonus
                if G.pack_cards then
                    G.pack_cards.config.choose = math.max(1, (G.pack_cards.config.choose or 1) + diff)
                end
            end
            return {
                message = "Archdruid!",
                colour = G.C.GREEN,
                card = card
            }
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Admiral Taylor",
    faction = {"Alliance","Pirate"},
    race = {"Human"},
    class = {"Warrior"},
    weapon = {"Sword", "Shield"},
    damage = {"Physical"},
    armor = {"Leather"},
    profession = {},
    combo = {"Dread Admiral Eliza", "Fleet Admiral Tethys", "Captain Hooktusk"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 7,
    index = 315,
    config = { extra = {
        level_gain = 1, level_gain_per_level = 0.2, level_gain_per_ilvl = 0.1,
        ilvl_gain = 2, ilvl_gain_per_level = 0.3, ilvl_gain_per_ilvl = 0.2
    } },
    loc_txt = {
        "At end of {C:attention}Shop{}, make a",
        "random Joker {C:attention}Eternal{}.",
        "All {C:attention}Eternal{} Jokers gain",
        "{C:attention}+#1#{} Level(s) and {C:attention}+#2#{} Ilvl{}",
        "at end of each {C:attention}Shop{}."
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.level_gain, card.ability.extra.level_gain_per_level, card.ability.extra.level_gain_per_ilvl),
            Warcraft.get_scaled_gain(card, card.ability.extra.ilvl_gain, card.ability.extra.ilvl_gain_per_level, card.ability.extra.ilvl_gain_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.ending_shop and not context.blueprint then
            local effective_level = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.level_gain, card.ability.extra.level_gain_per_level, card.ability.extra.level_gain_per_ilvl))
            local effective_ilvl = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.ilvl_gain, card.ability.extra.ilvl_gain_per_level, card.ability.extra.ilvl_gain_per_ilvl))

            -- Find non-eternal jokers to make eternal
            local non_eternal = {}
            for _, j in ipairs(G.jokers.cards) do
                if j ~= card and not j.ability.eternal then
                    table.insert(non_eternal, j)
                end
            end

            -- Make a random joker eternal
            if #non_eternal > 0 then
                local target = pseudorandom_element(non_eternal, pseudoseed('admiral_eternal_' .. G.GAME.round))
                G.E_MANAGER:add_event(Event({
                    func = function()
                        target.ability.eternal = true
                        card_eval_status_text(target, 'extra', nil, nil, nil, {
                            message = "Sworn In!",
                            colour = G.C.GOLD
                        })
                        target:juice_up()
                        return true
                    end
                }))
            end

            -- Level up and ilvl all eternal jokers
            local eternal_count = 0
            for _, j in ipairs(G.jokers.cards) do
                if j ~= card and j.ability.eternal then
                    eternal_count = eternal_count + 1
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            -- Level up
                            if j.ability.extra and j.ability.extra.level then
                                j.ability.extra.level = (j.ability.extra.level or 1) + effective_level
                                if j.ability.extra.max_level and j.ability.extra.level > j.ability.extra.max_level then
                                    j.ability.extra.max_level = j.ability.extra.level
                                end
                            end
                            -- Ilvl up
                            if j.ability.wow_equipment then
                                j.ability.wow_equipment.ilvl = (j.ability.wow_equipment.ilvl or 1) + effective_ilvl
                                j.ability.wow_equipment.ilvl_gained_this_round = 0
                            end
                            card_eval_status_text(j, 'extra', nil, nil, nil, {
                                message = "Loyal!",
                                colour = G.C.GOLD
                            })
                            j:juice_up()
                            return true
                        end
                    }))
                end
            end

            if eternal_count > 0 or #non_eternal > 0 then
                return {
                    message = "For the Alliance!",
                    colour = G.C.BLUE,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "General Nazgrim",
    faction = {"Horde"},
    race = {"Orc"},
    class = {"Warrior"},
    weapon = {"Sword", "Shield"},
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {},
    combo = {"Lich King", "Darion Mograine", "Anduin Wrynn", "Thrall", "Varok Saurfang", "Baine Bloodhoof", "Vol'jin", "Sally Whitemane", "Bolvar Fordragon"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 6,
    index = 316,
    config = { extra = {
        x_mult_per_warrior = 0.2, x_mult_per_warrior_per_level = 0.05, x_mult_per_warrior_per_ilvl = 0.03,
        x_chips_per_orc = 0.2, x_chips_per_orc_per_level = 0.05, x_chips_per_orc_per_ilvl = 0.03
    } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult per {C:attention}Warrior{}",
        "or {C:attention}Death Knight{} Joker.",
        "{X:chips,C:white} X#2# {} Chips per {C:attention}Orc{} Joker.",
        "{C:inactive}(#3# Warriors/DKs, #4# Orcs){}"
    },
    loc_vars = function(self, info_queue, card)
        local warrior_count = 0
        local orc_count = 0
        if G.jokers then
            for _, j in ipairs(G.jokers.cards) do
                if j ~= card and j.ability and j.ability.extra then
                    if Warcraft.is_class(j, "Warrior") or Warcraft.is_class(j, "Death Knight") then
                        warrior_count = warrior_count + 1
                    end
                    if Warcraft.is_race(j, "Orc") then
                        orc_count = orc_count + 1
                    end
                end
            end
        end
        local effective_x_mult = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_per_warrior, card.ability.extra.x_mult_per_warrior_per_level, card.ability.extra.x_mult_per_warrior_per_ilvl)
        local effective_x_chips = Warcraft.get_scaled_gain(card, card.ability.extra.x_chips_per_orc, card.ability.extra.x_chips_per_orc_per_level, card.ability.extra.x_chips_per_orc_per_ilvl)
        return { effective_x_mult, effective_x_chips, warrior_count, orc_count }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local warrior_count = 0
            local orc_count = 0
            for _, j in ipairs(G.jokers.cards) do
                if j ~= card and j.ability and j.ability.extra then
                    if Warcraft.is_class(j, "Warrior") or Warcraft.is_class(j, "Death Knight") then
                        warrior_count = warrior_count + 1
                    end
                    if Warcraft.is_race(j, "Orc") then
                        orc_count = orc_count + 1
                    end
                end
            end

            local effective_x_mult = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_per_warrior, card.ability.extra.x_mult_per_warrior_per_level, card.ability.extra.x_mult_per_warrior_per_ilvl)
            local effective_x_chips = Warcraft.get_scaled_gain(card, card.ability.extra.x_chips_per_orc, card.ability.extra.x_chips_per_orc_per_level, card.ability.extra.x_chips_per_orc_per_ilvl)

            local total_x_mult = 1 + (warrior_count * effective_x_mult)
            local total_x_chips = 1 + (orc_count * effective_x_chips)

            if total_x_mult > 1 or total_x_chips > 1 then
                return {
                    Xmult_mod = total_x_mult > 1 and total_x_mult or nil,
                    x_chips = total_x_chips > 1 and total_x_chips or nil,
                    message = "Lok'tar Ogar!",
                    colour = G.C.RED,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Kor'vas Bloodthorn",
    faction = {"Horde"},
    race = {"Blood Elf"},
    class = {"Demon Hunter"},
    weapon = {"Glaives"},
    damage = {"Fire"},
    armor = {"Leather"},
    profession = {},
    combo = {"Illidan Stormrage", "Maiev Shadowsong", "Magni Bronzebeard", "Khadgar", "Prophet Velen"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 6,
    index = 317,
    config = { extra = { retrigger = 1, retrigger_per_level = 0.2, retrigger_per_ilvl = 0.1 } },
    loc_txt = {
        "Retrigger the {C:attention}leftmost{}",
        "and {C:attention}rightmost{} scoring",
        "cards {C:attention}#1#{} time(s)"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.retrigger, card.ability.extra.retrigger_per_level, card.ability.extra.retrigger_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            if not context.scoring_hand or #context.scoring_hand == 0 then return end
            local hand = context.scoring_hand
            local leftmost = hand[1]
            local rightmost = hand[#hand]
            local other = context.other_card

            -- Handle edge case where leftmost and rightmost are the same card (single card hand)
            if leftmost == rightmost then
                if other == leftmost then
                    return {
                        message = "Fel Rush!",
                        repetitions = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.retrigger, card.ability.extra.retrigger_per_level, card.ability.extra.retrigger_per_ilvl)),
                        card = card
                    }
                end
            else
                if other == leftmost or other == rightmost then
                    return {
                        message = "Fel Rush!",
                        repetitions = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.retrigger, card.ability.extra.retrigger_per_level, card.ability.extra.retrigger_per_ilvl)),
                        card = card
                    }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Arator the Redeemer",
    faction = {"Alliance"},
    race = {"Human", "Blood Elf"},
    class = {"Paladin", "Hunter"},
    weapon = {"Sword", "Bow"},
    damage = {"Holy"},
    armor = {"Plate"},
    profession = {},
    combo = {"Alleria Windrunner", "Turalyon","Rhonin","Sylvanas Windrunner","Vereesa Windrunner"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 6,
    index = 318,
    config = { extra = {
        x_mult_per_gold = 0.2, x_mult_per_gold_per_level = 0.05, x_mult_per_gold_per_ilvl = 0.03,
        x_chips_per_purple = 0.2, x_chips_per_purple_per_level = 0.05, x_chips_per_purple_per_ilvl = 0.03
    } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult per {C:money}Gold Seal{}",
        "{X:chips,C:white} X#2# {} Chips per {C:purple}Purple Seal{}",
        "in your deck.",
        "{C:inactive}(#3# Gold, #4# Purple Seals){}"
    },
    loc_vars = function(self, info_queue, card)
        local gold_count = 0
        local purple_count = 0
        if G.playing_cards then
            for _, c in ipairs(G.playing_cards) do
                local seal = c:get_seal()
                if seal == 'Gold' then gold_count = gold_count + 1
                elseif seal == 'Purple' then purple_count = purple_count + 1 end
            end
        end
        local effective_x_mult = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_per_gold, card.ability.extra.x_mult_per_gold_per_level, card.ability.extra.x_mult_per_gold_per_ilvl)
        local effective_x_chips = Warcraft.get_scaled_gain(card, card.ability.extra.x_chips_per_purple, card.ability.extra.x_chips_per_purple_per_level, card.ability.extra.x_chips_per_purple_per_ilvl)
        return { effective_x_mult, effective_x_chips, gold_count, purple_count }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local gold_count = 0
            local purple_count = 0
            if G.playing_cards then
                for _, c in ipairs(G.playing_cards) do
                    local seal = c:get_seal()
                    if seal == 'Gold' then gold_count = gold_count + 1
                    elseif seal == 'Purple' then purple_count = purple_count + 1 end
                end
            end

            local effective_x_mult = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_per_gold, card.ability.extra.x_mult_per_gold_per_level, card.ability.extra.x_mult_per_gold_per_ilvl)
            local effective_x_chips = Warcraft.get_scaled_gain(card, card.ability.extra.x_chips_per_purple, card.ability.extra.x_chips_per_purple_per_level, card.ability.extra.x_chips_per_purple_per_ilvl)

            local total_x_mult = 1 + (gold_count * effective_x_mult)
            local total_x_chips = 1 + (purple_count * effective_x_chips)

            if total_x_mult > 1 or total_x_chips > 1 then
                return {
                    Xmult_mod = total_x_mult > 1 and total_x_mult or nil,
                    x_chips = total_x_chips > 1 and total_x_chips or nil,
                    message = "Redeemed!",
                    colour = G.C.GOLD,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "King Ymiron",
    faction = {"Scourge"},
    race = {"Human", "Undead"},
    class = {"Warrior"},
    weapon = {"Axe", "Sword"},
    damage = {"Shadow"},
    armor = {"Plate"},
    profession = {},
    combo = {"Helya","Lich King","Odyn","Arthas Menethil"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 6,
    index = 319,
    config = { extra = { mult_per_debuff = 3, mult_per_debuff_per_level = 0.5, mult_per_debuff_per_ilvl = 0.3 } },
    loc_txt = {
        "After each hand played,",
        "permanently {C:red}Debuff{} a random",
        "card held in hand.",
        "{C:mult}+#1#{} Mult per {C:attention}Debuffed{}",
        "card in your deck.",
        "{C:inactive}(Currently {C:mult}+#2#{C:inactive} Mult){}"
    },
    loc_vars = function(self, info_queue, card)
        local debuff_count = 0
        if G.playing_cards then
            for _, c in ipairs(G.playing_cards) do
                if c.debuff then debuff_count = debuff_count + 1 end
            end
        end
        local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.mult_per_debuff, card.ability.extra.mult_per_debuff_per_level, card.ability.extra.mult_per_debuff_per_ilvl)
        return { effective_mult, debuff_count * effective_mult }
    end,
    calculate = function(self, card, context)
        -- Permanently debuff a random held card after each hand
        if context.after and not context.blueprint then
            local valid_targets = {}
            if G.hand and G.hand.cards then
                for _, c in ipairs(G.hand.cards) do
                    if not c.debuff then
                        table.insert(valid_targets, c)
                    end
                end
            end

            if #valid_targets > 0 then
                local target = pseudorandom_element(valid_targets, pseudoseed('ymiron_' .. G.GAME.round .. '_' .. (G.GAME.current_round.hands_played or 0)))
                G.E_MANAGER:add_event(Event({
                    func = function()
                        target.ability.ymiron_debuffed = true
                        target:set_debuff(true)
                        target:juice_up()
                        card_eval_status_text(card, 'extra', nil, nil, nil, {
                            message = "Cursed!",
                            colour = G.C.RED
                        })
                        return true
                    end
                }))
                return {
                    message = "Vrykul Curse!",
                    colour = G.C.RED,
                    card = card
                }
            end
        end

        -- +Mult per debuffed card in deck
        if context.joker_main then
            local debuff_count = 0
            if G.playing_cards then
                for _, c in ipairs(G.playing_cards) do
                    if c.debuff then debuff_count = debuff_count + 1 end
                end
            end
            if debuff_count > 0 then
                local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.mult_per_debuff, card.ability.extra.mult_per_debuff_per_level, card.ability.extra.mult_per_debuff_per_ilvl)
                return {
                    mult = debuff_count * effective_mult,
                    message = "Vrykul Might!",
                    colour = G.C.RED,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Tinkmaster Overspark",
    faction = {"Alliance"},
    race = {"Gnome"},
    class = {"Mage"},
    weapon = {"Hammer"},
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {"Engineer"},
    combo = {"Alarm-o-Bot", "Sicco Thermaplugg", "Gelbin Mekkatorque", "Sylvanas Windrunner", "King Mechagon"},
    role = {"Melee DPS"},
    rarity = 1,
    cost = 4,
    index = 320,
    config = { extra = { used_this_blind = false, bonus_chips = 0, bonus_chips_per_level = 5, bonus_chips_per_ilvl = 3 } },
    loc_txt = {
        "Once per {C:attention}Blind{}, if you",
        "discard a {C:attention}single card{},",
        "transform it into a {C:attention}5{}",
        "or an {C:attention}Ace{} at random.",
        "Transformed cards gain {C:chips}+#1#{} Chips."
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.bonus_chips, card.ability.extra.bonus_chips_per_level, card.ability.extra.bonus_chips_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            card.ability.extra.used_this_blind = false
        end

        if context.discard and not context.blueprint and not card.ability.extra.used_this_blind then
            if #context.full_hand ~= 1 then return end

            local target = context.full_hand[1]
            if not target then return end

            card.ability.extra.used_this_blind = true

            G.E_MANAGER:add_event(Event({
                func = function()
                    local suit_prefix = string.sub(target.base.suit, 1, 1)
                    -- Randomly choose between 5 and Ace
                    local new_rank = pseudorandom('tinkmaster_' .. G.GAME.round) < 0.5 and "5" or "A"
                    local new_key = suit_prefix .. "_" .. new_rank
                    if G.P_CARDS[new_key] then
                        target:set_base(G.P_CARDS[new_key])
                        -- Apply bonus chips
                        local effective_chips = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.bonus_chips, card.ability.extra.bonus_chips_per_level, card.ability.extra.bonus_chips_per_ilvl))
                        if effective_chips > 0 then
                            target.ability.perma_bonus = (target.ability.perma_bonus or 0) + effective_chips
                        end
                        target:juice_up()
                        card_eval_status_text(card, 'extra', nil, nil, nil, {
                            message = new_rank == "A" and "Deathspark!" or "Squirrel!",
                            colour = new_rank == "A" and G.C.GOLD or G.C.GREEN
                        })
                    end
                    return true
                end
            }))

            return {
                message = "Tinkered!",
                colour = G.C.GREEN,
                card = card
            }
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Anduin Lothar",
    faction = {"Alliance"},
    race = {"Human"},
    class = {"Warrior"},
    weapon = {"Sword", "Shield"},
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {},
    combo = {"Varian Wrynn", "Turalyon", "King Llane Wrynn", "Medivh", "Khadgar", "Blackhand"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 6,
    index = 321,
    config = { extra = { retrigger_per_number = 1, retrigger_per_number_per_level = 0.2, retrigger_per_number_per_ilvl = 0.1 } },
    loc_txt = {
        "Played {C:attention}Face Cards{} retrigger",
        "{C:attention}#1#{} time(s) for each",
        "{C:attention}Numbered Card{} (2-10)",
        "in your scoring hand"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.retrigger_per_number, card.ability.extra.retrigger_per_number_per_level, card.ability.extra.retrigger_per_number_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            if context.other_card:is_face() then
                -- Count numbered cards (2-10) in scoring hand
                local number_count = 0
                if context.scoring_hand then
                    for _, v in ipairs(context.scoring_hand) do
                        local id = v:get_id()
                        if id >= 2 and id <= 10 then
                            number_count = number_count + 1
                        end
                    end
                end

                if number_count > 0 then
                    local effective_retrigger = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.retrigger_per_number, card.ability.extra.retrigger_per_number_per_level, card.ability.extra.retrigger_per_number_per_ilvl))
                    local total = number_count * effective_retrigger
                    return {
                        message = "Champion!",
                        repetitions = total,
                        card = card
                    }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Dr. Boom",
    race = {"Goblin"},
    class = {"Warrior"},
    weapon = {"Fist", "Gun"},
    damage = {"Fire"},
    armor = {"Cloth"},
    profession = {"Engineer"},
    combo = {"Zilliax", "The Great Akazamzarak", "Millhouse Manastorm", "Kael'thas Sunstrider", "King Togwaggle", "Queen Wagtoggle", "Arch-Thief Rafaam", "Hagatha the Witch"},
    role = {"Ranged DPS"},
    rarity = 3,
    cost = 8,
    index = 322,
    config = { extra = { boom_bots = 2, boom_bots_per_level = 0.2, boom_bots_per_ilvl = 0.1 } },
    loc_txt = {
        "At start of each {C:attention}Blind{},",
        "add {C:attention}#1#{} temporary {C:attention}Aces{}",
        "with a random {C:dark_edition}Edition{}",
        "to your hand"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.boom_bots, card.ability.extra.boom_bots_per_level, card.ability.extra.boom_bots_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            local effective_count = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.boom_bots, card.ability.extra.boom_bots_per_level, card.ability.extra.boom_bots_per_ilvl))
            G.E_MANAGER:add_event(Event({
                func = function()
                    local suits = {'S', 'H', 'D', 'C'}
                    for i = 1, effective_count do
                        local suit = pseudorandom_element(suits, pseudoseed('drboom_suit_' .. i .. '_' .. G.GAME.round))
                        local ace_key = suit .. '_A'
                        if G.P_CARDS[ace_key] then
                            local boom_bot = create_card('Base', G.hand, nil, nil, nil, nil, nil, 'drboom')
                            boom_bot:set_base(G.P_CARDS[ace_key])
                            -- Apply random edition
                            local edition = poll_edition('drboom_ed_' .. i .. '_' .. G.GAME.round, nil, true, true)
                            if edition then
                                boom_bot:set_edition(edition, true)
                            end
                            boom_bot.is_temporary = true
                            boom_bot:add_to_deck()
                            G.deck.config.card_limit = G.deck.config.card_limit + 1
                            table.insert(G.playing_cards, boom_bot)
                            G.hand:emplace(boom_bot)
                            boom_bot:juice_up()
                        end
                    end
                    G.hand:sort()
                    card_eval_status_text(card, 'extra', nil, nil, nil, {
                        message = "BOOOOM!",
                        colour = G.C.RED
                    })
                    return true
                end
            }))
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Koltira Deathweaver",
    faction = {"Horde", "Scourge"},
    race = {"Blood Elf"},
    class = {"Death Knight"},
    weapon = {"Sword"},
    damage = {"Shadow"},
    armor = {"Plate"},
    profession = {},
    combo = {"Lich King", "Thassarian", "Arthas Menethil", "Sylvanas Windrunner"},
    role = {"Tank"},
    rarity = 2,
    cost = 6,
    index = 323,
    config = { extra = { x_mult = 3, x_mult_per_level = 0.5, x_mult_per_ilvl = 0.3 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "Must be your {C:attention}rightmost{} Joker",
        "or this Joker is {C:red}Debuffed{}."
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl) }
    end,
    calculate = function(self, card, context)
        -- Check position and update debuff state
        if context.setting_blind or context.buying_card or context.selling_card then
            local is_rightmost = G.jokers.cards[#G.jokers.cards] == card
            G.E_MANAGER:add_event(Event({
                func = function()
                    if not is_rightmost and not card.debuff then
                        card:set_debuff(true)
                        card_eval_status_text(card, 'extra', nil, nil, nil, {
                            message = "Captive!",
                            colour = G.C.RED
                        })
                    elseif is_rightmost and card.debuff then
                        card:set_debuff(false)
                        card_eval_status_text(card, 'extra', nil, nil, nil, {
                            message = "Free!",
                            colour = G.C.GREEN
                        })
                    end
                    return true
                end
            }))
        end

        if context.joker_main and not card.debuff then
            -- Double check position at score time
            if G.jokers.cards[#G.jokers.cards] == card then
                return {
                    Xmult_mod = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
                    message = "Death's Embrace!",
                    colour = G.C.DARK_EDITION,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Bartender Bob",
    race = {"Human"},
    class = {"Rogue"},
    weapon = {"Fist"},
    damage = {"Nature"},
    armor = {"Cloth"},
    profession = {"Alchemist"},
    combo = {"Harth Stonebrew", "The Great Akazamzarak", "Silas Darkmoon", "Tickatus"},
    role = {"Healer"},
    rarity = 1,
    cost = 4,
    index = 324,
    config = { extra = { rarity = 0.99 } },
    loc_txt = {
        "A random {C:red}Rare Joker{} always",
        "appears in the shop.",
        "{C:attention}+1{} Shop Joker slot."
    },
    loc_vars = function(self, info_queue, card)
        return {}
    end,
    add_to_deck = function(self, card, from_debuff)
        G.E_MANAGER:add_event(Event({
            func = function()
                if G.shop_jokers then
                    G.shop_jokers.config.card_limit = G.shop_jokers.config.card_limit + 1
                end
                return true
            end
        }))
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.E_MANAGER:add_event(Event({
            func = function()
                if G.shop_jokers then
                    G.shop_jokers.config.card_limit = math.max(2, G.shop_jokers.config.card_limit - 1)
                end
                return true
            end
        }))
    end,
    calculate = function(self, card, context)
        -- Inject a Rare Joker each time the shop is generated or rerolled
        if (context.reroll_shop or context.starting_shop) and not context.blueprint then
            G.E_MANAGER:add_event(Event({
                func = function()
                    if G.shop_jokers then
                        -- Check if a Bob rare slot already exists
                        local has_bob_rare = false
                        for _, j in ipairs(G.shop_jokers.cards) do
                            if j.ability and j.ability.bob_rare then
                                has_bob_rare = true
                                break
                            end
                        end

                        if not has_bob_rare then
                            -- Temporarily expand limit if the shop is already full
                            local over = #G.shop_jokers.cards >= G.shop_jokers.config.card_limit
                            if over then
                                G.shop_jokers.config.card_limit = G.shop_jokers.config.card_limit + 1
                            end
                            
                            -- Create the card
                            local rare_joker = create_card('Joker', G.shop_jokers, nil, 3, nil, nil, nil, 'bartender_bob')
                            rare_joker.ability.bob_rare = true
                            
                            -- Flag it as a shop item
                            rare_joker.shop_joker = true
                            
                            -- Put it in the shop
                            G.shop_jokers:emplace(rare_joker)
                            
                            -- Generate the cost/price tag in the background
                            rare_joker:set_cost() 
                            rare_joker:start_materialize()
                            
                            -- ADDED: Manually strip the "hand selection" properties
                            rare_joker.states.collide.can_select = false
                            rare_joker.states.drag.can_drag = false
                            
                            -- ADDED: Force the shop to update its layout and physically draw the Buy button!
                            G.shop_jokers:align_cards()
                            
                            -- Restore the limit
                            if over then
                                G.shop_jokers.config.card_limit = G.shop_jokers.config.card_limit - 1
                            end
                        end
                    end
                    return true
                end
            }))
            return {
                message = "Last Call!",
                colour = G.C.GOLD,
                card = card
            }
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Zekhan",
    faction = {"Horde"},
    race = {"Troll"},
    class = {"Shaman"},
    weapon = {"Staff", "Fist"},
    damage = {"Nature"},
    armor = {"Mail"},
    profession = {},
    combo = {"Varok Saurfang", "Sylvanas Windrunner","Anduin Wrynn","Baine Bloodhoof","Thrall"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 6,
    index = 325,
    config = { extra = { base_mult = 1, mult_per_level = 0.2, mult_per_ilvl = 0.1 } },
    loc_txt = {
        "Scoring cards retrigger a number",
        "of times equal to their {C:attention}scoring position{}",
        "multiplied by {C:attention}#1#{}"
    },
    loc_vars = function(self, info_queue, card)
        local eff_mult = Warcraft.get_scaled_gain(card, card.ability.extra.base_mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl)
        return { eff_mult }
    end,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            if context.scoring_hand then
                local target_index = 0
                
                -- Find the position of the card in the scoring hand
                for i, sc in ipairs(context.scoring_hand) do
                    if sc == context.other_card then
                        target_index = i
                        break
                    end
                end
                
                if target_index > 0 then
                    local eff_mult = Warcraft.get_scaled_gain(card, card.ability.extra.base_mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl)
                    local reps = math.floor(target_index * eff_mult)
                    
                    if reps > 0 then
                        return {
                            message = "Zappy Boy!",
                            repetitions = reps,
                            card = card
                        }
                    end
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Lord Marrowgar",
    faction = {"Scourge"},
    race = {"Undead"},
    weapon = {"Axe"},
    damage = {"Frost"},
    armor = {"Unarmored"},
    profession = {},
    combo = {"Lich King", "Arthas Menethil", "Kel'Thuzad", "Lady Deathwhisper", "Professor Putricide"},
    role = {"Tank"},
    rarity = 3,
    cost = 10,
    index = 326,
    config = { extra = { 
        base_max_reps = 10, reps_per_level = 1, reps_per_ilvl = 0.5,
        base_chance = 100, chance_red_per_level = 1, chance_red_per_ilvl = 0.5 
    } },
    loc_txt = {
        "Scoring cards retrigger a {C:attention}random{}",
        "number of times between {C:attention}1{} and {C:attention}#1#{}.",
        "Each time a card retriggers, it has",
        "a {C:green}1 in #2#{} chance to be {C:red}destroyed{}."
    },
    loc_vars = function(self, info_queue, card)
        return { 
            math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.base_max_reps, card.ability.extra.reps_per_level, card.ability.extra.reps_per_ilvl)),
            math.max(1, Warcraft.get_scaled_gain(card, card.ability.extra.base_chance, -card.ability.extra.chance_red_per_level, -card.ability.extra.chance_red_per_ilvl))
        }
    end,
    calculate = function(self, card, context)
        -- 1. Roll for Retriggers
        if context.repetition and context.cardarea == G.play then
            local max_reps = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.base_max_reps, card.ability.extra.reps_per_level, card.ability.extra.reps_per_ilvl))
            local rolled_reps = math.ceil(pseudorandom('marrowgar_reps') * max_reps)
            
            -- Track how many times this specific card was told to retrigger this hand
            context.other_card.ability.marrowgar_reps = rolled_reps
            
            return {
                message = "BONESTORM!",
                repetitions = rolled_reps,
                card = card
            }
        end

        -- 2. Destroy cards AFTER scoring (if they rolled the bad chance during their retriggers)
        if context.after and not context.blueprint then
            local destroyed_any = false
            local chance_denom = math.max(1, Warcraft.get_scaled_gain(card, card.ability.extra.base_chance, -card.ability.extra.chance_red_per_level, -card.ability.extra.chance_red_per_ilvl))
            
            if context.scoring_hand then
                for _, scored_card in ipairs(context.scoring_hand) do
                    local reps = scored_card.ability.marrowgar_reps or 0
                    
                    -- Roll the destruction chance once for every single retrigger it took
                    for i = 1, reps do
                        if pseudorandom('marrowgar_destroy_' .. i) < (G.GAME.probabilities.normal / chance_denom) then
                            if not scored_card.dissolving then
                                destroyed_any = true
                                G.E_MANAGER:add_event(Event({
                                    func = function()
                                        scored_card:start_dissolve({remove_as_card = true})
                                        return true
                                    end
                                }))
                                break -- Don't try to destroy it multiple times
                            end
                        end
                    end
                    -- Clear the tracker
                    scored_card.ability.marrowgar_reps = nil
                end
            end
            
            if destroyed_any then
                return {
                    message = "More bones!",
                    colour = G.C.RED,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Patches the Pirate",
    faction = {"Pirate"},
    race = {"Demon"},
    class = {"Rogue", "Warrior"},
    weapon = {"Sword", "Gun"},
    damage = {"Shadow"},
    armor = {"Leather"},
    profession = {},
    combo = {"Skycap'n Kragg", "Captain Eudora", "Harlan Sweete"},
    role = {"Melee DPS"},
    rarity = 3,
    cost = 8,
    index = 327,
    config = { extra = { first_buy = true, added_card_id = nil } },
    loc_txt = {
        "When {C:attention}bought{}, adds a {C:dark_edition}Polychrome{}",
        "{C:attention}Ace of Spades{} to your deck.",
        "That card is {C:attention}always drawn first{}",
        "at the start of each Blind."
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.e_polychrome
        return {}
    end,
    calculate = function(self, card, context)
        -- 1. Create Patches the Pirate when bought
        if context.buying_card and not context.blueprint then
            if context.card.ability.set == 'Joker' and card.ability.extra.first_buy then
                card.ability.extra.first_buy = false
                
                G.E_MANAGER:add_event(Event({
                    func = function()
                        -- Create the Ace of Spades
                        local new_card = create_card('Base', G.deck, nil, nil, nil, nil, nil, 'patches')
                        new_card:set_base(G.P_CARDS.S_A)
                        new_card:set_edition({polychrome = true}, true)
                        new_card:add_to_deck()
                        table.insert(G.playing_cards, new_card)
                        G.deck:emplace(new_card)
                        new_card:juice_up()
                        
                        -- Save its unique ID so Patches knows which card to pull
                        card.ability.extra.added_card_id = new_card.unique_val
                        
                        card_eval_status_text(card, 'extra', nil, nil, nil, {
                            message = "I'm in charge now!",
                            colour = G.C.DARK_EDITION
                        })
                        return true
                    end
                }))
            end
        end

        -- 2. Force Draw Patches at the start of the Blind
        if context.first_hand_drawn and not context.blueprint then
            local target_id = card.ability.extra.added_card_id
            if target_id then
                local found_card = nil
                
                -- Find Patches in the deck
                if G.deck and G.deck.cards then
                    for i = 1, #G.deck.cards do
                        if G.deck.cards[i].unique_val == target_id then
                            found_card = G.deck.cards[i]
                            break
                        end
                    end
                end

                -- If he's in the deck, yank him into the hand!
                if found_card and #G.hand.cards < G.hand.config.card_limit then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            G.deck:remove_card(found_card)
                            G.hand:emplace(found_card)
                            found_card:juice_up()
                            return true
                        end
                    }))
                    
                    return {
                        message = "Charge!",
                        colour = G.C.RED,
                        card = card
                    }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Arch-Thief Rafaam",
    faction = {"Legion"},
    race = {"Ethereal"},
    class = {"Mage"},
    weapon = {"Staff"},
    damage = {"Shadow"},
    armor = {"Mail"},
    profession = {"Archaeologist"},
    combo = {"Reno Jackson", "Elise Starseeker", "Sir Finley Mrrgglton", "Sire Denathrius", "Galakrond"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 7,
    index = 328,
    config = { extra = { used_this_blind = false, copies = 1, copies_per_level = 0.2, copies_per_ilvl = 0.1 } },
    loc_txt = {
        "Once per {C:attention}Blind{}, create",
        "{C:attention}#1#{} copy/copies of the",
        "{C:attention}second scoring card{}",
        "and add it to your deck"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.copies, card.ability.extra.copies_per_level, card.ability.extra.copies_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            card.ability.extra.used_this_blind = false
        end

        if context.before and not context.blueprint and not card.ability.extra.used_this_blind then
            if context.scoring_hand and #context.scoring_hand >= 2 then
                card.ability.extra.used_this_blind = true
                local target = context.scoring_hand[2]
                local effective_copies = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.copies, card.ability.extra.copies_per_level, card.ability.extra.copies_per_ilvl))

                G.E_MANAGER:add_event(Event({
                    func = function()
                        for i = 1, effective_copies do
                            local copy = copy_card(target, nil, nil, G.playing_card)
                            copy.shattered = nil
                            copy.destroyed = nil
                            copy:add_to_deck()
                            G.deck.config.card_limit = G.deck.config.card_limit + 1
                            table.insert(G.playing_cards, copy)
                            G.deck:emplace(copy)
                            copy:juice_up()
                        end
                        card_eval_status_text(card, 'extra', nil, nil, nil, {
                            message = "Stolen!",
                            colour = G.C.PURPLE
                        })
                        return true
                    end
                }))

                return {
                    message = "I'll Take That!",
                    colour = G.C.PURPLE,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "King Llane Wrynn",
    faction = {"Alliance"},
    race = {"Human"},
    class = {"Warrior"},
    weapon = {"Sword", "Shield"},
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {},
    combo = {"Anduin Wrynn", "Varian Wrynn", "Medivh", "Anduin Lothar", "Blackhand", "Garona Halforcen"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 6,
    index = 329,
    config = { extra = {
        mult = 0, chips = 0,
        mult_gain = 4, mult_gain_per_level = 0.5, mult_gain_per_ilvl = 0.3,
        chips_gain = 15, chips_gain_per_level = 3, chips_gain_per_ilvl = 2
    } },
    loc_txt = {
        "{C:mult}+#1#{} Mult, {C:chips}+#2#{} Chips",
        "Each time a {C:attention}King{} scores,",
        "permanently gain {C:mult}+#3#{} Mult",
        "and {C:chips}+#4#{} Chips.",
        "{C:inactive}(Currently {C:mult}+#1#{C:inactive} Mult, {C:chips}+#2#{C:inactive} Chips){}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.mult,
            card.ability.extra.chips,
            Warcraft.get_scaled_gain(card, card.ability.extra.mult_gain, card.ability.extra.mult_gain_per_level, card.ability.extra.mult_gain_per_ilvl),
            Warcraft.get_scaled_gain(card, card.ability.extra.chips_gain, card.ability.extra.chips_gain_per_level, card.ability.extra.chips_gain_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            if context.other_card:get_id() == 13 then
                local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.mult_gain, card.ability.extra.mult_gain_per_level, card.ability.extra.mult_gain_per_ilvl)
                local effective_chips = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.chips_gain, card.ability.extra.chips_gain_per_level, card.ability.extra.chips_gain_per_ilvl))
                card.ability.extra.mult = card.ability.extra.mult + effective_mult
                card.ability.extra.chips = card.ability.extra.chips + effective_chips
                return {
                    message = "For Stormwind!",
                    colour = G.C.BLUE,
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
    name = "Hagatha the Witch",
    faction = {"Horde"},
    race = {"Troll"},
    class = {"Shaman"},
    weapon = {"Staff"},
    damage = {"Nature"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Dr. Boom", "Shudderwock", "King Togwaggle", "Queen Wagtoggle", "Arch-Thief Rafaam"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 6,
    index = 330,
    config = { extra = { cards_per_tarot = 1, cards_per_tarot_per_level = 0.2, cards_per_tarot_per_ilvl = 0.1 } },
    loc_txt = {
        "Each time a {C:tarot}Tarot Card{}",
        "is used, transform {C:attention}#1#{}",
        "random card(s) in your deck",
        "into {C:attention}Wild Cards{}"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_wild
        return { Warcraft.get_scaled_gain(card, card.ability.extra.cards_per_tarot, card.ability.extra.cards_per_tarot_per_level, card.ability.extra.cards_per_tarot_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.using_consumeable and not context.blueprint then
            if context.consumeable and context.consumeable.ability.set == 'Tarot' then
                local effective_count = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.cards_per_tarot, card.ability.extra.cards_per_tarot_per_level, card.ability.extra.cards_per_tarot_per_ilvl))

                -- Collect non-wild cards from deck
                local valid_targets = {}
                if G.playing_cards then
                    for _, c in ipairs(G.playing_cards) do
                        if c.config.center ~= G.P_CENTERS.m_wild then
                            table.insert(valid_targets, c)
                        end
                    end
                end

                if #valid_targets > 0 then
                    local to_convert = math.min(effective_count, #valid_targets)
                    for i = 1, to_convert do
                        local target = pseudorandom_element(valid_targets, pseudoseed('hagatha_' .. i .. '_' .. G.GAME.round))
                        -- Remove from pool to avoid duplicates
                        for j = #valid_targets, 1, -1 do
                            if valid_targets[j] == target then
                                table.remove(valid_targets, j)
                                break
                            end
                        end
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                target:set_ability(G.P_CENTERS.m_wild, nil, true)
                                target:juice_up()
                                return true
                            end
                        }))
                    end
                    return {
                        message = "Witchwood!",
                        colour = G.C.PURPLE,
                        card = card
                    }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "King Togwaggle",
    race = {"Kobold"},
    class = {"Rogue"},
    weapon = {"Torch", "Fist"},
    damage = {"Fire"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Dr. Boom", "Shudderwock", "Hagatha the Witch", "Queen Wagtoggle", "Arch-Thief Rafaam"},
    role = {"Tank"},
    rarity = 2,
    cost = 5,
    index = 331,
    config = { extra = { chance = 3, chance_per_level = -0.2, chance_per_ilvl = -0.1, chosen_card = nil } },
    loc_txt = {
        "One card is always {C:attention}selected{}.",
        "When it scores, {C:green}1 in #1#{} chance",
        "to gain {C:dark_edition}Polychrome{} edition."
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.e_polychrome
        return { Warcraft.get_scaled_gain(card, card.ability.extra.chance, card.ability.extra.chance_per_level, card.ability.extra.chance_per_ilvl) }
    end,
    calculate = function(self, card, context)
        -- Pick a new chosen card at start of each blind
        if context.setting_blind and not context.blueprint then
            if G.playing_cards and #G.playing_cards > 0 then
                local target = pseudorandom_element(G.playing_cards, pseudoseed('togwaggle_' .. G.GAME.round))
                card.ability.extra.chosen_card = target
                G.E_MANAGER:add_event(Event({
                    func = function()
                        -- Highlight the chosen card
                        if target and target.area then
                            target:juice_up()
                            card_eval_status_text(card, 'extra', nil, nil, nil, {
                                message = "You No Take Candle!",
                                colour = G.C.GOLD
                            })
                        end
                        return true
                    end
                }))
            end
        end

        -- Keep the chosen card always selected/highlighted in hand
        if context.hand_drawn and not context.blueprint then
            local chosen = card.ability.extra.chosen_card
            if chosen and G.hand and G.hand.cards then
                for _, c in ipairs(G.hand.cards) do
                    if c == chosen then
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                chosen:juice_up()
                                return true
                            end
                        }))
                        break
                    end
                end
            end
        end

        -- Check if chosen card scored and roll for polychrome
        if context.individual and context.cardarea == G.play and not context.blueprint then
            local chosen = card.ability.extra.chosen_card
            if chosen and context.other_card == chosen then
                local effective_chance = math.max(1, Warcraft.get_scaled_gain(card, card.ability.extra.chance, card.ability.extra.chance_per_level, card.ability.extra.chance_per_ilvl))
                if pseudorandom('togwaggle_poly') < G.GAME.probabilities.normal / effective_chance then
                    if not (chosen.edition and chosen.edition.polychrome) then
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                chosen:set_edition({polychrome = true}, true)
                                chosen:juice_up()
                                card_eval_status_text(card, 'extra', nil, nil, nil, {
                                    message = "Shiny!",
                                    colour = G.C.DARK_EDITION
                                })
                                return true
                            end
                        }))
                        return {
                            message = "Mine Now!",
                            colour = G.C.GOLD,
                            card = card
                        }
                    end
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Archbishop Benedictus",
    faction = {"Alliance"},
    race = {"Human"},
    class = {"Priest"},
    weapon = {"Staff"},
    damage = {"Shadow"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Alonsus Faol", "Cho'gall", "Gul'dan", "Thrall"},
    role = {"Healer"},
    rarity = 2,
    cost = 6,
    index = 332,
    config = { extra = { used_this_blind = false, copies = 1, copies_per_level = 0.2, copies_per_ilvl = 0.1 } },
    loc_txt = {
        "Once per {C:attention}Blind{}, {C:attention}#1#{} copy/copies of",
        "the first {C:attention}non-scoring card{}",
        "played is added to your deck."
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.copies, card.ability.extra.copies_per_level, card.ability.extra.copies_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            card.ability.extra.used_this_blind = false
        end

        if context.before and not context.blueprint and not card.ability.extra.used_this_blind then
            if context.full_hand and context.scoring_hand then
                -- Find cards in full_hand that are NOT in scoring_hand
                local non_scoring = {}
                local scoring_set = {}
                for _, v in ipairs(context.scoring_hand) do
                    scoring_set[v] = true
                end
                for _, v in ipairs(context.full_hand) do
                    if not scoring_set[v] then
                        table.insert(non_scoring, v)
                    end
                end

                if #non_scoring > 0 then
                    card.ability.extra.used_this_blind = true
                    local target = non_scoring[1]
                    local effective_copies = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.copies, card.ability.extra.copies_per_level, card.ability.extra.copies_per_ilvl))

                    G.E_MANAGER:add_event(Event({
                        func = function()
                            for i = 1, effective_copies do
                                local copy = copy_card(target, nil, nil, G.playing_card)
                                copy.shattered = nil
                                copy.destroyed = nil
                                copy:add_to_deck()
                                G.deck.config.card_limit = G.deck.config.card_limit + 1
                                table.insert(G.playing_cards, copy)
                                G.deck:emplace(copy)
                                copy:juice_up()
                            end
                            card_eval_status_text(card, 'extra', nil, nil, nil, {
                                message = "Corrupted!",
                                colour = G.C.DARK_EDITION
                            })
                            return true
                        end
                    }))

                    return {
                        message = "False Piety!",
                        colour = G.C.DARK_EDITION,
                        card = card
                    }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Harth Stonebrew",
    faction = {"Horde", "Alliance"},
    race = {"Dwarf"},
    damage = {"Nature"},
    armor = {"Leather"},
    profession = {"Alchemist"},
    combo = {"Bartender Bob", "The Great Akazamzarak", "Silas Darkmoon", "Tickatus"},
    role = {"Healer"},
    rarity = 2,
    cost = 6,
    index = 333,
    config = { extra = { packs_per_trigger = 4, packs_per_trigger_per_level = -0.2, packs_per_trigger_per_ilvl = -0.1, packs_opened = 0 } },
    loc_txt = {
        "Every {C:attention}#1#{} Packs opened,",
        "open a random {C:attention}Warcraft Joker Pack{}.",
        "All Jokers from it are {C:dark_edition}Negative{}.",
        "{C:inactive}(Packs opened: #2#/#1#){}"
    },
    loc_vars = function(self, info_queue, card)
        local effective_threshold = math.max(1, math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.packs_per_trigger, card.ability.extra.packs_per_trigger_per_level, card.ability.extra.packs_per_trigger_per_ilvl)))
        return { effective_threshold, card.ability.extra.packs_opened }
    end,
    calculate = function(self, card, context)
        if context.open_pack and not context.blueprint then
            card.ability.extra.packs_opened = card.ability.extra.packs_opened + 1

            local effective_threshold = math.max(1, math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.packs_per_trigger, card.ability.extra.packs_per_trigger_per_level, card.ability.extra.packs_per_trigger_per_ilvl)))

            if card.ability.extra.packs_opened >= effective_threshold then
                card.ability.extra.packs_opened = 0

                -- Store flag so faction pack know to make all jokers negative
                G.GAME.harth_negative_pack = true

                G.E_MANAGER:add_event(Event({
                    func = function()
                        if #G.consumeables.cards < G.consumeables.config.card_limit then
                            local pack = create_card('Booster', G.consumeables, nil, nil, nil, nil, 'p_war_warcraft_tavern_pack_1', 'harth')
                            pack:add_to_deck()
                            G.consumeables:emplace(pack)
                            pack:juice_up()
                            card_eval_status_text(card, 'extra', nil, nil, nil, {
                                message = "Last Call!",
                                colour = G.C.GOLD
                            })
                        end
                        return true
                    end
                }))

                return {
                    message = "Round on Me!",
                    colour = G.C.GOLD,
                    card = card
                }
            else
                return {
                    message = (effective_threshold - card.ability.extra.packs_opened) .. " More!",
                    colour = G.C.GOLD,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Kurdran Wildhammer",
    faction = {"Alliance"},
    race = {"Dwarf"},
    class = {"Warrior"},
    weapon = {"Hammer"},
    damage = {"Physical"},
    armor = {"Mail"},
    profession = {},
    combo = {"Falstad Wildhammer", "Khadgar", "Turalyon", "Alleria Windrunner","Danath Trollbane"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 5,
    index = 334,
    config = { extra = { chance = 3, chance_per_level = -0.2, chance_per_ilvl = -0.1 } },
    loc_txt = {
        "Scoring {C:spades}Spades{} and {C:clubs}Clubs{}",
        "have a {C:green}1 in #1#{} chance to",
        "become {C:attention}Wild Cards{}"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_wild
        return { Warcraft.get_scaled_gain(card, card.ability.extra.chance, card.ability.extra.chance_per_level, card.ability.extra.chance_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            local other = context.other_card
            if other:is_suit('Spades') or other:is_suit('Clubs') then
                if other.config.center ~= G.P_CENTERS.m_wild then
                    local effective_chance = math.max(1, Warcraft.get_scaled_gain(card, card.ability.extra.chance, card.ability.extra.chance_per_level, card.ability.extra.chance_per_ilvl))
                    if pseudorandom('kurdran') < G.GAME.probabilities.normal / effective_chance then
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                other:set_ability(G.P_CENTERS.m_wild, nil, true)
                                other:juice_up()
                                return true
                            end
                        }))
                        return {
                            message = "Sky Hammer!",
                            colour = G.C.ORANGE,
                            card = card
                        }
                    end
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Lord Darius Crowley",
    faction = {"Alliance"},
    race = {"Human"},
    class = {"Warrior"},
    weapon = {"Sword", "Gun"},
    damage = {"Piercing"},
    armor = {"Plate"},
    profession = {},
    combo = {"Genn Greymane", "Sylvanas Windrunner", "Anduin Lothar", "Tess Greymane"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 6,
    index = 335,
    config = { extra = {
        chips_per_debuff = 50, chips_per_debuff_per_level = 10, chips_per_debuff_per_ilvl = 8,
        x_chips_per_debuff = 0.15, x_chips_per_debuff_per_level = 0.03, x_chips_per_debuff_per_ilvl = 0.02
    } },
    loc_txt = {
        "At start of each {C:attention}Blind{},",
        "permanently {C:red}Debuff{} a random",
        "{C:attention}Face Card{} in your deck.",
        "{C:chips}+#1#{} Chips and {X:chips,C:white} X#2# {}",
        "Chips per {C:attention}Debuffed{} card in deck.",
        "{C:inactive}(Currently {C:chips}+#3#{C:inactive}, {X:chips,C:white} X#4# {C:inactive}){}"
    },
    loc_vars = function(self, info_queue, card)
        local debuff_count = 0
        if G.playing_cards then
            for _, c in ipairs(G.playing_cards) do
                -- CHANGED: Now reliably checks perma_debuffs even when out of a round!
                if c.debuff or (c.ability and c.ability.perma_debuff) then 
                    debuff_count = debuff_count + 1 
                end
            end
        end
        local effective_chips = Warcraft.get_scaled_gain(card, card.ability.extra.chips_per_debuff, card.ability.extra.chips_per_debuff_per_level, card.ability.extra.chips_per_debuff_per_ilvl)
        local effective_x_chips = Warcraft.get_scaled_gain(card, card.ability.extra.x_chips_per_debuff, card.ability.extra.x_chips_per_debuff_per_level, card.ability.extra.x_chips_per_debuff_per_ilvl)
        return {
            effective_chips,
            effective_x_chips,
            math.floor(debuff_count * effective_chips),
            1 + (debuff_count * effective_x_chips)
        }
    end,
    calculate = function(self, card, context)
        -- Debuff a random face card at start of blind
        if context.setting_blind and not context.blueprint then
            local valid_targets = {}
            if G.playing_cards then
                for _, c in ipairs(G.playing_cards) do
                    -- CHANGED: Make sure it isn't already perma-debuffed!
                    if c:is_face() and not c.debuff and not (c.ability and c.ability.perma_debuff) then
                        table.insert(valid_targets, c)
                    end
                end
            end

            if #valid_targets > 0 then
                local target = pseudorandom_element(valid_targets, pseudoseed('crowley_' .. G.GAME.round))
                G.E_MANAGER:add_event(Event({
                    func = function()
                        -- THE FIX: Hardcode it into the card's permanent ability table
                        target.ability.perma_debuff = true
                        target:set_debuff(true) 
                        
                        target:juice_up()
                        card_eval_status_text(card, 'extra', nil, nil, nil, {
                            message = "Resistance!",
                            colour = G.C.RED
                        })
                        return true
                    end
                }))
            end
        end

        -- Apply chips and xchips per debuffed card
        if context.joker_main then
            local debuff_count = 0
            if G.playing_cards then
                for _, c in ipairs(G.playing_cards) do
                    if c.debuff or (c.ability and c.ability.perma_debuff) then 
                        debuff_count = debuff_count + 1 
                    end
                end
            end

            if debuff_count > 0 then
                local effective_chips = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.chips_per_debuff, card.ability.extra.chips_per_debuff_per_level, card.ability.extra.chips_per_debuff_per_ilvl))
                local effective_x_chips = Warcraft.get_scaled_gain(card, card.ability.extra.x_chips_per_debuff, card.ability.extra.x_chips_per_debuff_per_level, card.ability.extra.x_chips_per_debuff_per_ilvl)
                local total_x_chips = 1 + (debuff_count * effective_x_chips)
                return {
                    chips = debuff_count * effective_chips,
                    x_chips = total_x_chips > 1 and total_x_chips or nil,
                    message = "Gilneas Rises!",
                    colour = G.C.RED,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "The Headless Horseman",
    race = {"Undead"},
    class = {"Warrior"},
    weapon = {"Sword"},
    damage = {"Fire"},
    armor = {"Plate"},
    profession = {},
    combo = {"Uther the Lightbringer", "Baron Rivendare", "Jaine Proudmoore", "Arthas Menethil"},
    role = {"Ranged DPS"},
    rarity = 3,
    cost = 8,
    index = 336,
    config = { extra = {
        discards_count = 0,
        discards_per_head = 3,
        head_detached = false,
        x_chips = 1,
        x_mult = 1,
        x_chips_gain = 0.3, x_chips_gain_per_level = 0.05, x_chips_gain_per_ilvl = 0.03,
        x_mult_gain = 0.3, x_mult_gain_per_level = 0.05, x_mult_gain_per_ilvl = 0.03
    } },
    loc_txt = {
        "{X:chips,C:white} X#1# {} Chips {X:mult,C:white} X#2# {} Mult",
        "Every {C:attention}#3#{} discards, spawn",
        "{C:attention}Head of the Horseman{}",
        "if head is {C:red}detached{}.",
        "Gains {X:chips,C:white} X#4# {}{X:mult,C:white} X#4# {} when",
        "head is {C:attention}reattached{}.",
        -- Fixed formatting tag: using {V:1} to pull from the dynamic colours array
        "{C:inactive}(Discards: #5#/#3#, Head: {V:1}#6#{C:inactive}){}"
    },
    loc_vars = function(self, info_queue, card)
        local head_status = card.ability.extra.head_detached and "Detached" or "Attached"
        local head_color = card.ability.extra.head_detached and G.C.RED or G.C.GREEN
        -- Returning the exact structure SMODS needs for dynamic colors
        return {
            vars = {
                card.ability.extra.x_chips,
                card.ability.extra.x_mult,
                card.ability.extra.discards_per_head,
                Warcraft.get_scaled_gain(card, card.ability.extra.x_chips_gain, card.ability.extra.x_chips_gain_per_level, card.ability.extra.x_chips_gain_per_ilvl),
                card.ability.extra.discards_count,
                head_status,
                colours = { head_color }
            }
        }
    end,
    calculate = function(self, card, context)
        -- Track discards
        if context.discard and not context.blueprint then
            -- ONLY run if head is not currently detached, and trigger once per discard action
            if context.other_card == context.full_hand[1] and not card.ability.extra.head_detached then
                -- Increment by 1 discard action, not # of cards
                card.ability.extra.discards_count = card.ability.extra.discards_count + 1

                if card.ability.extra.discards_count >= card.ability.extra.discards_per_head then
                    card.ability.extra.head_detached = true

                    G.E_MANAGER:add_event(Event({
                        func = function()
                            if #G.jokers.cards < G.jokers.config.card_limit then
                                local head = create_card('Joker', G.jokers, nil, nil, nil, nil, 'j_war_head_of_the_horseman', 'headless_horseman')
                                head:set_edition({negative = true}, true)
                                head:add_to_deck()
                                G.jokers:emplace(head)
                                head:start_materialize()
                                card_eval_status_text(card, 'extra', nil, nil, nil, {
                                    message = "Head Thrown!",
                                    colour = G.C.RED
                                })
                            end
                            return true
                        end
                    }))

                    return {
                        message = "CATCH!",
                        colour = G.C.RED,
                        card = card
                    }
                end
            end
        end

        -- Apply XChips and XMult
        if context.joker_main then
            local result = {}
            if card.ability.extra.x_chips > 1 then result.x_chips = card.ability.extra.x_chips end
            if card.ability.extra.x_mult > 1 then result.Xmult_mod = card.ability.extra.x_mult end
            if result.x_chips or result.Xmult_mod then
                result.message = "Hallow's End!"
                result.colour = G.C.ORANGE
                result.card = card
                return result
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Tarecgosa",
    faction = {"Alliance"},
    race = {"Dragon", "Blood Elf"},
    class = {"Mage"},
    weapon = {"Staff", "Fist"},
    damage = {"Arcane"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Kalecgos", "Deathwing", "Malygos"},
    role = {"Ranged DPS"},
    rarity = 3,
    cost = 8,
    index = 337,
    config = { extra = { chips = 0, gain_multiplier = 1, gain_multiplier_per_level = 0.1, gain_multiplier_per_ilvl = 0.05 } },
    loc_txt = {
        "{C:chips}+#1#{} Chips",
        "Each time a card scores,",
        "gain its total {C:chips}Chip{} value",
        "x{C:attention}#2#{} permanently.",
        "{C:inactive}(Currently {C:chips}+#1#{C:inactive} Chips){}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.chips,
            Warcraft.get_scaled_gain(card, card.ability.extra.gain_multiplier, card.ability.extra.gain_multiplier_per_level, card.ability.extra.gain_multiplier_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            local other = context.other_card

            -- Calculate total chips of this card
            local total_chips = other.base.nominal or 0
            if other.ability.perma_bonus then
                total_chips = total_chips + other.ability.perma_bonus
            end
            if other.ability.bonus then
                total_chips = total_chips + other.ability.bonus
            end
            -- Add stone card bonus
            if other.config.center.key == 'm_stone' then
                total_chips = total_chips + 50
            end

            if total_chips > 0 then
                local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.gain_multiplier, card.ability.extra.gain_multiplier_per_level, card.ability.extra.gain_multiplier_per_ilvl)
                local gain = math.floor(total_chips * effective_mult)
                card.ability.extra.chips = card.ability.extra.chips + gain
                return {
                    message = "Siphoned!",
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
    name = "Pepe",
    faction = {"Horde", "Alliance"},
    race = {"Beast"},
    damage = {"Nature"},
    armor = {"Leather"},
    profession = {},
    combo = {"Illidan Stormrage", "Sire Denathrius", "Kyrestia", "Edwin VanCleef", "Arthas Menethil", "Sylvanas Windrunner"},
    role = {"Ranged DPS"},
    rarity = 1,
    cost = 3,
    index = 338,
    config = { extra = { level_gain = 2, level_gain_per_level = 0.3, level_gain_per_ilvl = 0.2 } },
    loc_txt = {
        "At end of each {C:attention}Blind{},",
        "give {C:attention}+#1#{} Level(s){} to",
        "the Joker to the {C:attention}left{}"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.level_gain, card.ability.extra.level_gain_per_level, card.ability.extra.level_gain_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.repetition and not context.individual and not context.blueprint then
            local my_pos = nil
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then my_pos = i; break end
            end

            if my_pos and my_pos > 1 then
                local target = G.jokers.cards[my_pos - 1]
                if target and target.ability.extra and target.ability.extra.level then
                    local effective_gain = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.level_gain, card.ability.extra.level_gain_per_level, card.ability.extra.level_gain_per_ilvl))
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            target.ability.extra.level = (target.ability.extra.level or 1) + effective_gain
                            if target.ability.extra.max_level and target.ability.extra.level > target.ability.extra.max_level then
                                target.ability.extra.max_level = target.ability.extra.level
                            end
                            card_eval_status_text(target, 'extra', nil, nil, nil, {
                                message = "PEPE!",
                                colour = G.C.GREEN
                            })
                            target:juice_up()
                            return true
                        end
                    }))
                    return {
                        message = "PEPE!",
                        colour = G.C.GREEN,
                        card = card
                    }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Runas the Shamed",
    faction = {"Horde"},
    race = {"Night Elf"},
    class = {"Mage"},
    weapon = {"Staff"},
    damage = {"Arcane"},
    armor = {"Unarmored"},
    profession = {},
    combo = {"Thalyssra", "Grand Magistrix Elisande", "Star Augur Etraeus"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 6,
    index = 339,
    config = { extra = {
        x_chips = 3,
        x_chips_decay = 0.2, x_chips_decay_per_ilvl = -0.02,
        x_chips_restore = 0.5, x_chips_restore_per_level = 0.1, x_chips_restore_per_ilvl = 0.05
    } },
    loc_txt = {
        "{X:chips,C:white} X#1# {} Chips",
        "Loses {X:chips,C:white} X#2# {} Chips each",
        "hand played (min {X:chips,C:white} X1 {}).",
        "Gains {X:chips,C:white} X#3# {} Chips each",
        "time a {C:attention}Glass Card{} breaks."
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_glass
        return {
            card.ability.extra.x_chips,
            Warcraft.get_scaled_gain(card, card.ability.extra.x_chips_decay, 0, card.ability.extra.x_chips_decay_per_ilvl),
            Warcraft.get_scaled_gain(card, card.ability.extra.x_chips_restore, card.ability.extra.x_chips_restore_per_level, card.ability.extra.x_chips_restore_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        -- Decay XChips after each hand
        if context.after and not context.blueprint then
            local effective_decay = Warcraft.get_scaled_gain(card, card.ability.extra.x_chips_decay, 0, card.ability.extra.x_chips_decay_per_ilvl)
            card.ability.extra.x_chips = math.max(1, card.ability.extra.x_chips - effective_decay)
            return {
                message = "Withdrawal...",
                colour = G.C.RED,
                card = card
            }
        end

        -- Restore XChips when a glass card breaks
        if context.remove_playing_cards and not context.blueprint then
            if context.removed and #context.removed > 0 then
                local glass_broken = false
                for _, c in ipairs(context.removed) do
                    if c.shattered then
                        glass_broken = true
                        break
                    end
                end
                if glass_broken then
                    local effective_restore = Warcraft.get_scaled_gain(card, card.ability.extra.x_chips_restore, card.ability.extra.x_chips_restore_per_level, card.ability.extra.x_chips_restore_per_ilvl)
                    card.ability.extra.x_chips = card.ability.extra.x_chips + effective_restore
                    return {
                        message = "Arcwine!",
                        colour = G.C.BLUE,
                        card = card
                    }
                end
            end
        end

        -- Apply XChips during scoring
        if context.joker_main then
            if card.ability.extra.x_chips > 1 then
                return {
                    x_chips = card.ability.extra.x_chips,
                    message = "Nightwell...",
                    colour = G.C.BLUE,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Jani",
    faction = {"Horde"},
    race = {"Loa"},
    class = {"Rogue"},
    weapon = {"Fist"},
    damage = {"Physical"},
    armor = {"Leather"},
    profession = {},
    combo = {"Hir'eek", "Rezan", "King Rastakhan", "Bwonsamdi", "Princess Talanji"},
    role = {"Melee DPS"},
    rarity = 1,
    cost = 4,
    index = 340,
    config = { extra = { mult = 0, mult_gain = 3, mult_gain_per_level = 0.5, mult_gain_per_ilvl = 0.3 } },
    loc_txt = {
        "{C:mult}+#1#{} Mult",
        "Gains {C:mult}+#2#{} Mult each",
        "time you {C:attention}sell{} anything.",
        "{C:inactive}(Currently {C:mult}+#1#{C:inactive} Mult){}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.mult,
            Warcraft.get_scaled_gain(card, card.ability.extra.mult_gain, card.ability.extra.mult_gain_per_level, card.ability.extra.mult_gain_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.selling_card and not context.blueprint then
            local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.mult_gain, card.ability.extra.mult_gain_per_level, card.ability.extra.mult_gain_per_ilvl)
            card.ability.extra.mult = card.ability.extra.mult + effective_gain
            return {
                message = "Dis is Junk!",
                colour = G.C.GOLD,
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
    name = "Zephrys the Great",
    faction = {"Horde", "Alliance"},
    race = {"Elemental"},
    class = {"Mage"},
    weapon = {"Staff"},
    damage = {"Nature"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Bartender Bob", "Harth Stonebrew", "Reno Jackson"},
    role = {"Healer"},
    rarity = 3,
    cost = 8,
    index = 341,
    config = { extra = { used_this_shop = {}, copies = 1, copies_per_level = 0.2, copies_per_ilvl = 0.1 } },
    loc_txt = {
        "Each {C:attention}Shop{}, if you use the",
        "same {C:attention}Consumable{} type twice,",
        "spawn {C:attention}#1#{} free copy/copies."
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.copies, card.ability.extra.copies_per_level, card.ability.extra.copies_per_ilvl) }
    end,
    calculate = function(self, card, context)
        -- Reset tracker at start of each shop
        if context.starting_shop and not context.blueprint then
            card.ability.extra.used_this_shop = {}
        end

        if context.using_consumeable and not context.blueprint then
            local source = context.consumeable
            if not source then return end

            local key = source.config.center.key
            local tracker = card.ability.extra.used_this_shop

            if not tracker[key] then
                -- First use of this consumable type this shop
                tracker[key] = 1
            elseif tracker[key] == 1 then
                -- Second use — spawn copies
                tracker[key] = 2
                local effective_copies = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.copies, card.ability.extra.copies_per_level, card.ability.extra.copies_per_ilvl))

                G.E_MANAGER:add_event(Event({
                    func = function()
                        for i = 1, effective_copies do
                            if #G.consumeables.cards < G.consumeables.config.card_limit then
                                local copy = create_card(
                                    source.ability.set,
                                    G.consumeables,
                                    nil, nil, nil, nil,
                                    source.config.center.key,
                                    'zephrys'
                                )
                                copy:add_to_deck()
                                G.consumeables:emplace(copy)
                                copy:juice_up()
                            end
                        end
                        card_eval_status_text(card, 'extra', nil, nil, nil, {
                            message = "Perfect!",
                            colour = G.C.FILTER
                        })
                        return true
                    end
                }))

                return {
                    message = "Three Wishes!",
                    colour = G.C.FILTER,
                    card = card
                }
            end
            -- Third+ use of same type does nothing
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Misha",
    faction = {"Horde"},
    race = {"Beast"},
    class = {"Hunter"},
    weapon = {"Fist"},
    damage = {"Physical"},
    armor = {"Leather"},
    profession = {},
    combo = {"Rexxar","Leokk","Huffer"},
    role = {"Tank"},
    rarity = 1,
    cost = 4,
    index = 342,
    config = { extra = { level_gain = 1, level_gain_per_level = 0.2, level_gain_per_ilvl = 0.1 } },
    loc_txt = {
        "Each time a {C:attention}Pair{} is played,",
        "give {C:attention}+#1#{} Level(s){} to",
        "the Joker to the {C:attention}right{}"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.level_gain, card.ability.extra.level_gain_per_level, card.ability.extra.level_gain_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            if context.scoring_name == "Pair" then

                local my_pos = nil
                for i = 1, #G.jokers.cards do
                    if G.jokers.cards[i] == card then my_pos = i; break end
                end

                if my_pos and G.jokers.cards[my_pos + 1] then
                    local target = G.jokers.cards[my_pos + 1]
                    if target and target.ability.extra and target.ability.extra.level then
                        local effective_gain = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.level_gain, card.ability.extra.level_gain_per_level, card.ability.extra.level_gain_per_ilvl))
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                target.ability.extra.level = (target.ability.extra.level or 1) + effective_gain
                                if target.ability.extra.max_level and target.ability.extra.level > target.ability.extra.max_level then
                                    target.ability.extra.max_level = target.ability.extra.level
                                end
                                card_eval_status_text(target, 'extra', nil, nil, nil, {
                                    message = "Good Girl!",
                                    colour = G.C.GREEN
                                })
                                target:juice_up()
                                return true
                            end
                        }))
                        return {
                            message = "MISHA!",
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
    name = "Flynn Fairwind",
    faction = {"Alliance","Pirate"},
    race = {"Human"},
    class = {"Rogue"},
    weapon = {"Sword", "Gun"},
    damage = {"Physical"},
    armor = {"Leather"},
    profession = {},
    combo = {"Mathias Shaw","Deathwing","Taelia Fordring", "Neltharion","Varian Wrynn","Harlan Sweete","Captain Eudora"},
    role = {"Melee DPS"},
    rarity = 1,
    cost = 5,
    index = 343,
    config = { extra = {
        mult = 0, chips = 0,
        mult_gain = 3, mult_gain_per_level = 0.5, mult_gain_per_ilvl = 0.3,
        chips_gain = 12, chips_gain_per_level = 2, chips_gain_per_ilvl = 1,
        money_loss = 1
    } },
    loc_txt = {
        "{C:mult}+#1#{} Mult, {C:chips}+#2#{} Chips",
        "Each time a {C:attention}Jack{} scores,",
        "lose {C:money}$#5#{} but permanently",
        "gain {C:mult}+#3#{} Mult and {C:chips}+#4#{} Chips.",
        "{C:inactive}(Currently {C:mult}+#1#{C:inactive} Mult, {C:chips}+#2#{C:inactive} Chips){}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.mult,
            card.ability.extra.chips,
            Warcraft.get_scaled_gain(card, card.ability.extra.mult_gain, card.ability.extra.mult_gain_per_level, card.ability.extra.mult_gain_per_ilvl),
            Warcraft.get_scaled_gain(card, card.ability.extra.chips_gain, card.ability.extra.chips_gain_per_level, card.ability.extra.chips_gain_per_ilvl),
            card.ability.extra.money_loss
        }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            if context.other_card:get_id() == 11 then
                local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.mult_gain, card.ability.extra.mult_gain_per_level, card.ability.extra.mult_gain_per_ilvl)
                local effective_chips = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.chips_gain, card.ability.extra.chips_gain_per_level, card.ability.extra.chips_gain_per_ilvl))
                card.ability.extra.mult = card.ability.extra.mult + effective_mult
                card.ability.extra.chips = card.ability.extra.chips + effective_chips
                ease_dollars(-card.ability.extra.money_loss)
                return {
                    message = "Worth It!",
                    colour = G.C.MULT,
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
    name = "Lord Kazzak",
    faction = {"Legion"},
    race = {"Demon"},
    class = {"Warrior"},
    weapon = {"Sword", "Fist"},
    damage = {"Fire"},
    armor = {"Plate"},
    profession = {},
    combo = {"Kel'Thuzad", "Mannoroth", "Archimonde", "Kil'Jaeden"},
    role = {"Tank"},
    rarity = 3,
    cost = 8,
    index = 344,
    config = { extra = {
        x_mult = 1,
        x_mult_gain = 0.5, x_mult_gain_per_level = 0.1, x_mult_gain_per_ilvl = 0.05,
        destroy_chance = 10, destroy_chance_per_level = -0.3, destroy_chance_per_ilvl = -0.2
    } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult",
        "Each hand, non-{C:attention}Legion{} Jokers",
        "have a {C:green}1 in #2#{} chance to",
        "be {C:red}destroyed{}.",
        "Gains {X:mult,C:white} X#3# {} per destruction."
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.x_mult,
            Warcraft.get_scaled_gain(card, card.ability.extra.destroy_chance, card.ability.extra.destroy_chance_per_level, card.ability.extra.destroy_chance_per_ilvl),
            Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_gain, card.ability.extra.x_mult_gain_per_level, card.ability.extra.x_mult_gain_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.after and not context.blueprint then
            local effective_chance = math.max(1, Warcraft.get_scaled_gain(card, card.ability.extra.destroy_chance, card.ability.extra.destroy_chance_per_level, card.ability.extra.destroy_chance_per_ilvl))
            local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_gain, card.ability.extra.x_mult_gain_per_level, card.ability.extra.x_mult_gain_per_ilvl)
            local destroyed_any = false

            for i = #G.jokers.cards, 1, -1 do
                local j = G.jokers.cards[i]
                if j ~= card
                and not Warcraft.is_faction(j, "Legion")
                and not j.ability.eternal
                and not j.getting_sliced then
                    if pseudorandom('kazzak_' .. i) < G.GAME.probabilities.normal / effective_chance then
                        j.getting_sliced = true
                        card.ability.extra.x_mult = card.ability.extra.x_mult + effective_gain
                        destroyed_any = true
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                card:juice_up(0.5, 0.5)
                                j:start_dissolve({remove_as_card = true})
                                card_eval_status_text(card, 'extra', nil, nil, nil, {
                                    message = "CONSUMED!",
                                    colour = G.C.RED
                                })
                                return true
                            end
                        }))
                    end
                end
            end

            if destroyed_any then
                return {
                    message = "Supreme Cleave!",
                    colour = G.C.RED,
                    card = card
                }
            end
        end

        if context.joker_main then
            if card.ability.extra.x_mult > 1 then
                return {
                    Xmult_mod = card.ability.extra.x_mult,
                    message = "Vanguard!",
                    colour = G.C.RED,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Zilliax",
    faction = {"Horde", "Alliance"},
    race = {"Robot"},
    weapon = {"Fist"},
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {},
    combo = {"Dr. Boom", "King Togwaggle", "Queen Wagtoggle", "Arch-Thief Rafaam", "Hagatha the Witch"},
    role = {"Tank"},
    rarity = 3,
    cost = 10,
    index = 345,
    config = { extra = {
        chips = 30, chips_per_level = 5, chips_per_ilvl = 3,
        mult = 8, mult_per_level = 1, mult_per_ilvl = 0.5,
        x_chips = 1.5, x_chips_per_level = 0.1, x_chips_per_ilvl = 0.05,
        x_mult = 1.5, x_mult_per_level = 0.1, x_mult_per_ilvl = 0.05
    } },
    loc_txt = {
        "If scoring hand has a {C:attention}Glass{},",
        "{C:attention}Steel{}, {C:money}Gold{} and {C:attention}Stone{} card,",
        "make them {C:dark_edition}Polychrome{}.",
        "Other unenhanced cards in",
        "scoring or held hand become",
        "one of the four enhancements.",
        "{C:chips}+#1#{} {C:mult}+#2#{} {X:chips,C:white}X#3#{} {X:mult,C:white}X#4#{}"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_glass
        info_queue[#info_queue+1] = G.P_CENTERS.m_steel
        info_queue[#info_queue+1] = G.P_CENTERS.m_gold
        info_queue[#info_queue+1] = G.P_CENTERS.m_stone
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.chips, card.ability.extra.chips_per_level, card.ability.extra.chips_per_ilvl),
            Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl),
            Warcraft.get_scaled_gain(card, card.ability.extra.x_chips, card.ability.extra.x_chips_per_level, card.ability.extra.x_chips_per_ilvl),
            Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local enhancements = {
                glass = G.P_CENTERS.m_glass,
                steel = G.P_CENTERS.m_steel,
                gold  = G.P_CENTERS.m_gold,
                stone = G.P_CENTERS.m_stone
            }

            -- Check if all four enhancements are present in scoring hand
            local found = { glass = false, steel = false, gold = false, stone = false }
            local enhanced_cards = {}
            for _, v in ipairs(context.scoring_hand) do
                local key = v.config.center.key
                if key == 'm_glass' then found.glass = true; table.insert(enhanced_cards, v)
                elseif key == 'm_steel' then found.steel = true; table.insert(enhanced_cards, v)
                elseif key == 'm_gold' then found.gold = true; table.insert(enhanced_cards, v)
                elseif key == 'm_stone' then found.stone = true; table.insert(enhanced_cards, v)
                end
            end

            local all_four = found.glass and found.steel and found.gold and found.stone

            -- Collect all cards to potentially enhance (scoring + held, unenhanced only)
            local all_cards = {}
            for _, v in ipairs(context.scoring_hand) do table.insert(all_cards, v) end
            if G.hand and G.hand.cards then
                for _, v in ipairs(G.hand.cards) do table.insert(all_cards, v) end
            end

            G.E_MANAGER:add_event(Event({
                func = function()
                    -- Make the four special cards polychrome
                    if all_four then
                        for _, v in ipairs(enhanced_cards) do
                            v:set_edition({polychrome = true}, true)
                            v:juice_up()
                        end
                    end

                    -- Convert unenhanced cards to random enhancement
                    local enhancement_keys = {'m_glass', 'm_steel', 'm_gold', 'm_stone'}
                    for _, v in ipairs(all_cards) do
                        if v.config.center == G.P_CENTERS.c_base then
                            local chosen_key = pseudorandom_element(enhancement_keys, pseudoseed('zilliax_enh_' .. v.sort_id .. '_' .. G.GAME.round))
                            v:set_ability(G.P_CENTERS[chosen_key], nil, true)
                            v:juice_up()
                        end
                    end
                    return true
                end
            }))

            local effective_chips = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.chips, card.ability.extra.chips_per_level, card.ability.extra.chips_per_ilvl))
            local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl)
            local effective_x_chips = Warcraft.get_scaled_gain(card, card.ability.extra.x_chips, card.ability.extra.x_chips_per_level, card.ability.extra.x_chips_per_ilvl)
            local effective_x_mult = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl)

            return {
                chips = effective_chips,
                mult = effective_mult,
                x_chips = effective_x_chips,
                Xmult_mod = effective_x_mult,
                message = all_four and "PERFECT FUSION!" or "Modular!",
                colour = all_four and G.C.DARK_EDITION or G.C.ORANGE,
                card = card
            }
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Azuregos",
    faction = {"Horde", "Alliance"},
    race = {"Dragon", "Blood Elf"},
    class = {"Mage"},
    weapon = {"Staff", "Fist"},
    damage = {"Arcane"},
    armor = {"Mail"},
    profession = {},
    combo = {"Nefarian", "Malygos", "Fandral Staghelm", "Deathwing", "Neltharion"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 7,
    index = 346,
    config = { extra = {
        mult_per_level = 3, mult_per_level_per_level = 0.5, mult_per_level_per_ilvl = 0.3,
        chips_per_level = 15, chips_per_level_per_level = 3, chips_per_level_per_ilvl = 2
    } },
    loc_txt = {
        "At end of {C:attention}Shop{}, drain {C:attention}1 Level{}",
        "from Joker to the {C:attention}left{},",
        "give {C:attention}2 Levels{} to Joker to the {C:attention}right{}.",
        "{C:mult}+#1#{} Mult and {C:chips}+#2#{} Chips",
        "per level of the Joker to the {C:attention}right{}.",
        "{C:inactive}(Currently {C:mult}+#3#{C:inactive} Mult, {C:chips}+#4#{C:inactive} Chips){}"
    },
    loc_vars = function(self, info_queue, card)
        local right_level = 0
        local my_pos = nil
        if G.jokers then
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then my_pos = i; break end
            end
            if my_pos and G.jokers.cards[my_pos + 1] then
                local right = G.jokers.cards[my_pos + 1]
                right_level = right.ability.extra and right.ability.extra.level or 0
            end
        end
        local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.mult_per_level, card.ability.extra.mult_per_level_per_level, card.ability.extra.mult_per_level_per_ilvl)
        local effective_chips = Warcraft.get_scaled_gain(card, card.ability.extra.chips_per_level, card.ability.extra.chips_per_level_per_level, card.ability.extra.chips_per_level_per_ilvl)
        return {
            effective_mult,
            effective_chips,
            math.floor(right_level * effective_mult),
            math.floor(right_level * effective_chips)
        }
    end,
    calculate = function(self, card, context)
        if context.ending_shop and not context.blueprint then
            local my_pos = nil
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then my_pos = i; break end
            end

            local left = my_pos and my_pos > 1 and G.jokers.cards[my_pos - 1] or nil
            local right = my_pos and G.jokers.cards[my_pos + 1] or nil

            -- Drain 1 level from left
            if left and left.ability.extra and left.ability.extra.level then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        left.ability.extra.level = math.max(1, (left.ability.extra.level or 1) - 1)
                        card_eval_status_text(left, 'extra', nil, nil, nil, {
                            message = "Drained!",
                            colour = G.C.RED
                        })
                        left:juice_up()
                        return true
                    end
                }))
            end

            -- Give 2 levels to right
            if right and right.ability.extra and right.ability.extra.level then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        right.ability.extra.level = (right.ability.extra.level or 1) + 2
                        if right.ability.extra.max_level and right.ability.extra.level > right.ability.extra.max_level then
                            right.ability.extra.max_level = right.ability.extra.level
                        end
                        card_eval_status_text(right, 'extra', nil, nil, nil, {
                            message = "+2 Levels!",
                            colour = G.C.GREEN
                        })
                        right:juice_up()
                        return true
                    end
                }))
                return {
                    message = "Mana Storm!",
                    colour = G.C.BLUE,
                    card = card
                }
            end
        end

        if context.joker_main then
            local my_pos = nil
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then my_pos = i; break end
            end
            if my_pos and G.jokers.cards[my_pos + 1] then
                local right = G.jokers.cards[my_pos + 1]
                local right_level = right.ability.extra and right.ability.extra.level or 0
                if right_level > 0 then
                    local effective_mult = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.mult_per_level, card.ability.extra.mult_per_level_per_level, card.ability.extra.mult_per_level_per_ilvl))
                    local effective_chips = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.chips_per_level, card.ability.extra.chips_per_level_per_level, card.ability.extra.chips_per_level_per_ilvl))
                    return {
                        mult = right_level * effective_mult,
                        chips = right_level * effective_chips,
                        message = "Crystal of Zin-Malor!",
                        colour = G.C.BLUE,
                        card = card
                    }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Shudderwock",
    faction = {"Horde"},
    race = {"Dragon"},
    class = {"Shaman"},
    weapon = {"Fist"},
    damage = {"Fire"},
    armor = {"Mail"},
    profession = {},
    combo = {"Hagatha the Witch", "Dr. Boom", "Zilliax"},
    role = {"Ranged DPS"},
    rarity = 3,
    cost = 8,
    index = 347,
    config = { extra = { retrigger = 1, retrigger_gain = 1, retrigger_gain_per_level = 0.2, retrigger_gain_per_ilvl = 0.1 } },
    loc_txt = {
        "The {C:attention}first scoring card{}",
        "retriggeres {C:attention}#1#{} time(s).",
        "Gains {C:attention}+#2#{} retrigger(s)",
        "each time a Joker is {C:attention}sold{}.",
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.retrigger,
            Warcraft.get_scaled_gain(card, card.ability.extra.retrigger_gain, card.ability.extra.retrigger_gain_per_level, card.ability.extra.retrigger_gain_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        -- Gain retrigger when a joker is sold
        if context.selling_card and not context.blueprint then
            if context.card and context.card ~= card and context.card.ability and context.card.ability.set == 'Joker' then
                local effective_gain = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.retrigger_gain, card.ability.extra.retrigger_gain_per_level, card.ability.extra.retrigger_gain_per_ilvl))
                card.ability.extra.retrigger = card.ability.extra.retrigger + effective_gain
                return {
                    message = "Battlecry!",
                    colour = G.C.SECONDARY_SET,
                    card = card
                }
            end
        end

        -- Retrigger first scoring card
        if context.repetition and context.cardarea == G.play then
            if context.scoring_hand and context.other_card == context.scoring_hand[1] then
                return {
                    message = "SHUDDERWOCK!",
                    repetitions = card.ability.extra.retrigger,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Sen'jin",
    faction = {"Horde"},
    race = {"Troll"},
    class = {"Priest"},
    weapon = {"Spear", "Fist"},
    damage = {"Physical"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Thrall", "Bwonsamdi", "Vol'jin", "Zalazane"},
    role = {"Healer"},
    rarity = 2,
    cost = 5,
    index = 348,
    config = { extra = {
        last_discard_count = 0,
        spectral_count = 1, spectral_count_per_level = 0.2, spectral_count_per_ilvl = 0.1
    } },
    loc_txt = {
        "If you discard exactly {C:attention}3 cards{}",
        "then play a {C:attention}Three of a Kind{},",
        "generate {C:attention}#1#{} random {C:spectral}Spectral{} card(s)."
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.spectral_count, card.ability.extra.spectral_count_per_level, card.ability.extra.spectral_count_per_ilvl) }
    end,
    calculate = function(self, card, context)
        -- Reset discard tracker at start of blind
        if context.setting_blind and not context.blueprint then
            card.ability.extra.last_discard_count = 0
        end

        -- Track number of cards discarded in this discard action
        if context.discard and not context.blueprint then
            -- Only process once per discard action using first card
            if context.other_card == context.full_hand[1] then
                card.ability.extra.last_discard_count = #context.full_hand
            end
        end

        -- Check if Three of a Kind was played after exactly 3 discards
        if context.before and not context.blueprint then
            if context.scoring_name == "Three of a Kind"
            and card.ability.extra.last_discard_count == 3 then
                -- Reset counter
                card.ability.extra.last_discard_count = 0
                local effective_count = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.spectral_count, card.ability.extra.spectral_count_per_level, card.ability.extra.spectral_count_per_ilvl))

                G.E_MANAGER:add_event(Event({
                    func = function()
                        for i = 1, effective_count do
                            if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                                local spectral = create_card('Spectral', G.consumeables, nil, nil, nil, nil, nil, 'senjin')
                                spectral:add_to_deck()
                                G.consumeables:emplace(spectral)
                                G.GAME.consumeable_buffer = 0
                                spectral:juice_up()
                            end
                        end
                        card_eval_status_text(card, 'extra', nil, nil, nil, {
                            message = "Spirit Walk!",
                            colour = G.C.PURPLE
                        })
                        return true
                    end
                }))

                return {
                    message = "Voodoo!",
                    colour = G.C.PURPLE,
                    card = card
                }
            end

            -- Reset if wrong hand played after discarding
            if card.ability.extra.last_discard_count ~= 0
            and context.scoring_name ~= "Three of a Kind" then
                card.ability.extra.last_discard_count = 0
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Bloodmage Thalnos",
    faction = {"Scourge"},
    race = {"Undead"},
    class = {"Mage", "Priest"},
    weapon = {"Staff"},
    damage = {"Fire"},
    armor = {"Plate"},
    profession = {},
    combo = {"Sally Whitemane", "Alexandros Mograine", "Arcanist Doan"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 5,
    index = 349,
    config = { extra = { hand_size_per_undead = 1, hand_size_per_undead_per_level = 0.1, hand_size_per_undead_per_ilvl = 0.05, current_bonus = 0 } },
    loc_txt = {
        "{C:attention}+#1#{} Hand Size per",
        "{C:attention}Undead{} Joker you own.",
        "{C:inactive}(Currently {C:attention}+#2#{C:inactive} Hand Size){}"
    },
    loc_vars = function(self, info_queue, card)
        local undead_count = 0
        if G.jokers then
            for _, j in ipairs(G.jokers.cards) do
                if j ~= card and Warcraft.is_race(j, "Undead") then
                    undead_count = undead_count + 1
                end
            end
        end
        local effective_per = Warcraft.get_scaled_gain(card, card.ability.extra.hand_size_per_undead, card.ability.extra.hand_size_per_undead_per_level, card.ability.extra.hand_size_per_undead_per_ilvl)
        return { effective_per, math.floor(undead_count * effective_per) }
    end,
    add_to_deck = function(self, card, from_debuff)
        local undead_count = 0
        if G.jokers then
            for _, j in ipairs(G.jokers.cards) do
                if j ~= card and Warcraft.is_race(j, "Undead") then
                    undead_count = undead_count + 1
                end
            end
        end
        local effective_per = Warcraft.get_scaled_gain(card, card.ability.extra.hand_size_per_undead, card.ability.extra.hand_size_per_undead_per_level, card.ability.extra.hand_size_per_undead_per_ilvl)
        local bonus = math.floor(undead_count * effective_per)
        card.ability.extra.current_bonus = bonus
        G.hand:change_size(bonus)
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.hand:change_size(-card.ability.extra.current_bonus)
    end,
    calculate = function(self, card, context)
        -- Recalculate hand size bonus when jokers change
        if context.setting_blind or context.buying_card or context.selling_card then
            local undead_count = 0
            for _, j in ipairs(G.jokers.cards) do
                if j ~= card and Warcraft.is_race(j, "Undead") then
                    undead_count = undead_count + 1
                end
            end
            local effective_per = Warcraft.get_scaled_gain(card, card.ability.extra.hand_size_per_undead, card.ability.extra.hand_size_per_undead_per_level, card.ability.extra.hand_size_per_undead_per_ilvl)
            local new_bonus = math.floor(undead_count * effective_per)
            local diff = new_bonus - (card.ability.extra.current_bonus or 0)
            if diff ~= 0 then
                G.hand:change_size(diff)
                card.ability.extra.current_bonus = new_bonus
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Emperor Dagran Thaurissan",
    faction = {"Horde"},
    race = {"Dwarf"},
    class = {"Mage", "Warrior"},
    weapon = {"Hammer", "Staff"},
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {},
    combo = {"Moira Thaurissan","Ragnaros","Majordomo Executus","Coren Direbrew"},
    role = {"Tank"},
    rarity = 2,
    cost = 7,
    index = 350,
    config = { extra = { cost_reduction = 1, cost_reduction_per_level = 0.2, cost_reduction_per_ilvl = 0.1 } },
    loc_txt = {
        "Jokers in the {C:attention}Shop{}",
        "cost {C:money}$#1#{} less.",
        "{C:inactive}(Minimum $1){}"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.cost_reduction, card.ability.extra.cost_reduction_per_level, card.ability.extra.cost_reduction_per_ilvl) }
    end,
    add_to_deck = function(self, card, from_debuff)
        G.E_MANAGER:add_event(Event({
            func = function()
                if G.shop_jokers then
                    for _, j in ipairs(G.shop_jokers.cards) do j:set_cost() end
                end
                return true
            end
        }))
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.E_MANAGER:add_event(Event({
            func = function()
                if G.shop_jokers then
                    for _, j in ipairs(G.shop_jokers.cards) do j:set_cost() end
                end
                return true
            end
        }))
    end,
    calculate = function(self, card, context)
        if context.reroll_shop or context.starting_shop then
            return {
                message = "Imperial Decree!",
                colour = G.C.MONEY,
                card = card
            }
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Herod",
    faction = {"Alliance"},
    race = {"Human"},
    class = {"Warrior"},
    weapon = {"Axe"},
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {},
    combo = {"Sally Whitemane","Bloodmage Thalnos", "Arcanist Doan"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 6,
    index = 351,
    config = { extra = {
        hands_played = 0,
        trigger_every = 3,
        retrigger = 2, retrigger_per_level = 0.2, retrigger_per_ilvl = 0.1,
        chips = 50, chips_per_level = 8, chips_per_ilvl = 5
    } },
    loc_txt = {
        "Every {C:attention}#1#rd{} hand played,",
        "all scoring cards retrigger",
        "{C:attention}#2#{} time(s) and give",
        "{C:chips}+#3#{} Chips.",
        "{C:inactive}(Hand #4#/#1#){}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.trigger_every,
            Warcraft.get_scaled_gain(card, card.ability.extra.retrigger, card.ability.extra.retrigger_per_level, card.ability.extra.retrigger_per_ilvl),
            Warcraft.get_scaled_gain(card, card.ability.extra.chips, card.ability.extra.chips_per_level, card.ability.extra.chips_per_ilvl),
            (card.ability.extra.hands_played % card.ability.extra.trigger_every) + 1
        }
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            card.ability.extra.hands_played = 0
        end

        if context.before and not context.blueprint then
            card.ability.extra.hands_played = card.ability.extra.hands_played + 1
        end

        -- Retrigger all scoring cards on every 3rd hand
        if context.repetition and context.cardarea == G.play then
            if card.ability.extra.hands_played % card.ability.extra.trigger_every == 0 then
                return {
                    message = "WHIRLWIND!",
                    repetitions = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.retrigger, card.ability.extra.retrigger_per_level, card.ability.extra.retrigger_per_ilvl)),
                    card = card
                }
            end
        end

        -- Bonus chips on every 3rd hand
        if context.individual and context.cardarea == G.play then
            if card.ability.extra.hands_played % card.ability.extra.trigger_every == 0 then
                return {
                    chips = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.chips, card.ability.extra.chips_per_level, card.ability.extra.chips_per_ilvl)),
                    card = context.other_card,
                    message = "BLADES OF LIGHT!",
                    colour = G.C.ORANGE
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Heigan the Unclean",
    faction = {"Scourge"},
    race = {"Undead"},
    class = {"Warlock"},
    weapon = {"Staff"},
    damage = {"Shadow"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Loatheb","Kel'Thuzad","Lich King"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 6,
    index = 352,
    config = { extra = {
        safe_suit_index = 1,
        suit_cycle = {"Spades", "Hearts", "Clubs", "Diamonds"},
        mult_per_debuffed = 4, mult_per_debuffed_per_level = 0.5, mult_per_debuffed_per_ilvl = 0.3
    } },
    loc_txt = {
        "All suits except {C:attention}#1#{}",
        "are {C:red}Debuffed{}. Cycles each hand.",
        "{C:mult}+#2#{} Mult per {C:attention}Debuffed{}",
        "card held in hand.",
        "{C:inactive}(Currently {C:mult}+#3#{C:inactive} Mult){}"
    },
    loc_vars = function(self, info_queue, card)
        local safe_suit = card.ability.extra.suit_cycle[card.ability.extra.safe_suit_index]
        local debuffed_count = 0
        if G.hand and G.hand.cards then
            for _, c in ipairs(G.hand.cards) do
                if not c:is_suit(safe_suit) then
                    debuffed_count = debuffed_count + 1
                end
            end
        end
        local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.mult_per_debuffed, card.ability.extra.mult_per_debuffed_per_level, card.ability.extra.mult_per_debuffed_per_ilvl)
        return { safe_suit, effective_mult, math.floor(debuffed_count * effective_mult) }
    end,
    calculate = function(self, card, context)
        -- Apply debuffs at start of blind and after each hand
        local function apply_debuffs()
            local safe_suit = card.ability.extra.suit_cycle[card.ability.extra.safe_suit_index]
            if G.playing_cards then
                for _, c in ipairs(G.playing_cards) do
                    if c:is_suit(safe_suit) then
                        if c.debuff and c.ability.heigan_debuffed then
                            c:set_debuff(false)
                            c.ability.heigan_debuffed = nil
                        end
                    else
                        if not c.debuff then
                            c:set_debuff(true)
                            c.ability.heigan_debuffed = true
                        end
                    end
                end
            end
        end

        if context.setting_blind and not context.blueprint then
            card.ability.extra.safe_suit_index = 1
            G.E_MANAGER:add_event(Event({
                func = function()
                    apply_debuffs()
                    return true
                end
            }))
            return {
                message = card.ability.extra.suit_cycle[1] .. " Safe!",
                colour = G.C.GREEN,
                card = card
            }
        end

        -- Cycle safe suit after each hand
        if context.after and not context.blueprint then
            local cycle = card.ability.extra.suit_cycle
            card.ability.extra.safe_suit_index = (card.ability.extra.safe_suit_index % #cycle) + 1
            G.E_MANAGER:add_event(Event({
                func = function()
                    -- Remove old heigan debuffs
                    if G.playing_cards then
                        for _, c in ipairs(G.playing_cards) do
                            if c.debuff and c.ability.heigan_debuffed then
                                c:set_debuff(false)
                                c.ability.heigan_debuffed = nil
                            end
                        end
                    end
                    apply_debuffs()
                    return true
                end
            }))
            return {
                message = card.ability.extra.suit_cycle[card.ability.extra.safe_suit_index] .. " Safe!",
                colour = G.C.GREEN,
                card = card
            }
        end

        -- Clean up debuffs when removed
        if context.remove_from_deck and not context.blueprint then
            G.E_MANAGER:add_event(Event({
                func = function()
                    if G.playing_cards then
                        for _, c in ipairs(G.playing_cards) do
                            if c.debuff and c.ability.heigan_debuffed then
                                c:set_debuff(false)
                                c.ability.heigan_debuffed = nil
                            end
                        end
                    end
                    return true
                end
            }))
        end

        -- +Mult per debuffed card held in hand
        if context.joker_main then
            local safe_suit = card.ability.extra.suit_cycle[card.ability.extra.safe_suit_index]
            local debuffed_count = 0
            if G.hand and G.hand.cards then
                for _, c in ipairs(G.hand.cards) do
                    if not c:is_suit(safe_suit) then
                        debuffed_count = debuffed_count + 1
                    end
                end
            end
            if debuffed_count > 0 then
                local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.mult_per_debuffed, card.ability.extra.mult_per_debuffed_per_level, card.ability.extra.mult_per_debuffed_per_ilvl)
                return {
                    mult = math.floor(debuffed_count * effective_mult),
                    message = "DANCE!",
                    colour = G.C.GREEN,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Chief Telemancer Oculeth",
    faction = {"Horde"},
    race = {"Night Elf"},
    class = {"Mage"},
    weapon = {"Staff"},
    damage = {"Arcane"},
    armor = {"Cloth"},
    profession = {"Engineer"},
    combo = {"Thalyssra", "Grand Magistrix Elisande","Star Augur Etraeus","Eitrigg"},
    role = {"Ranged DPS"},
    rarity = 3,
    cost = 8,
    index = 353,
    config = { extra = { retrigger_per_joker = 1, retrigger_per_joker_per_level = 0.1, retrigger_per_joker_per_ilvl = 0.05 } },
    loc_txt = {
        "Scoring cards retrigger",
        "{C:attention}#1#{} time(s) per Joker you own.",
        "Each time a card scores,",
        "shuffle all {C:attention}Joker{} positions."
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.retrigger_per_joker, card.ability.extra.retrigger_per_joker_per_level, card.ability.extra.retrigger_per_joker_per_ilvl) }
    end,
    calculate = function(self, card, context)
        -- Retrigger each scoring card by joker count
        if context.repetition and context.cardarea == G.play then
            local joker_count = #G.jokers.cards
            if joker_count > 0 then
                local effective_retrigger = math.floor(joker_count * Warcraft.get_scaled_gain(card, card.ability.extra.retrigger_per_joker, card.ability.extra.retrigger_per_joker_per_level, card.ability.extra.retrigger_per_joker_per_ilvl))
                if effective_retrigger > 0 then
                    return {
                        message = "Blink!",
                        repetitions = effective_retrigger,
                        card = card
                    }
                end
            end
        end

        -- Shuffle joker positions each time a card scores
        if context.individual and context.cardarea == G.play and not context.blueprint then
            G.E_MANAGER:add_event(Event({
                func = function()
                    if #G.jokers.cards > 1 then
                        -- Fisher-Yates shuffle
                        for i = #G.jokers.cards, 2, -1 do
                            local j = math.floor(pseudorandom('oculeth_shuffle_' .. i .. '_' .. G.GAME.round) * i) + 1
                            G.jokers.cards[i], G.jokers.cards[j] = G.jokers.cards[j], G.jokers.cards[i]
                        end
                        G.jokers:hard_set_T()
                        G.jokers:align_cards()
                    end
                    return true
                end
            }))
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Aggra",
    faction = {"Horde"},
    race = {"Orc"},
    class = {"Shaman"},
    weapon = {"Staff", "Fist"},
    damage = {"Nature"},
    armor = {"Mail"},
    profession = {},
    combo = {"Thrall","Durotan","Draka","Cairne Bloodhoof", "Gazlowe", "Garrosh Hellscream"},
    role = {"Healer"},
    rarity = 1,
    cost = 5,
    index = 354,
    config = { extra = {
        money = 3, money_per_level = 0.5, money_per_ilvl = 0.3,
        x_chips = 2, x_chips_per_level = 0.3, x_chips_per_ilvl = 0.2
    } },
    loc_txt = {
        "Playing a {C:attention}Three of a Kind{}",
        "gives {C:money}$#1#{} and",
        "{X:chips,C:white} X#2# {} Chips"
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.money, card.ability.extra.money_per_level, card.ability.extra.money_per_ilvl),
            Warcraft.get_scaled_gain(card, card.ability.extra.x_chips, card.ability.extra.x_chips_per_level, card.ability.extra.x_chips_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            if context.scoring_name == "Three of a Kind"
            or context.scoring_name == "Full House"
            or context.scoring_name == "Flush House"
            or context.scoring_name == "Five of a Kind" then
                local effective_money = Warcraft.get_scaled_gain(card, card.ability.extra.money, card.ability.extra.money_per_level, card.ability.extra.money_per_ilvl)
                local effective_x_chips = Warcraft.get_scaled_gain(card, card.ability.extra.x_chips, card.ability.extra.x_chips_per_level, card.ability.extra.x_chips_per_ilvl)
                ease_dollars(effective_money)
                return {
                    x_chips = effective_x_chips,
                    message = "Earthen Ring!",
                    colour = G.C.EARTH,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Archmage Vargoth",
    faction = {"Alliance"},
    race = {"Human"},
    class = {"Mage"},
    weapon = {"Staff"},
    damage = {"Arcane"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Khadgar","Kael'thas Sunstrider", "Krasus"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 6,
    index = 355,
    config = { extra = { levels = 3, levels_per_level = 0.3, levels_per_ilvl = 0.2 } },
    loc_txt = {
        "At end of {C:attention}Shop{},",
        "give a random Joker without",
        "an {C:attention}Edition{} a {C:dark_edition}Holographic{}",
        "edition and {C:attention}+#1#{} Level(s){}"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.e_holo
        return { Warcraft.get_scaled_gain(card, card.ability.extra.levels, card.ability.extra.levels_per_level, card.ability.extra.levels_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.ending_shop and not context.blueprint then
            -- Collect jokers without an edition
            local valid_targets = {}
            for _, j in ipairs(G.jokers.cards) do
                if j ~= card and (not j.edition or not next(j.edition)) then
                    table.insert(valid_targets, j)
                end
            end

            if #valid_targets > 0 then
                local target = pseudorandom_element(valid_targets, pseudoseed('vargoth_' .. G.GAME.round))
                local effective_levels = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.levels, card.ability.extra.levels_per_level, card.ability.extra.levels_per_ilvl))

                G.E_MANAGER:add_event(Event({
                    func = function()
                        -- Apply holographic edition
                        target:set_edition({holo = true}, true)
                        -- Give levels
                        if target.ability.extra and target.ability.extra.level then
                            target.ability.extra.level = (target.ability.extra.level or 1) + effective_levels
                            if target.ability.extra.max_level and target.ability.extra.level > target.ability.extra.max_level then
                                target.ability.extra.max_level = target.ability.extra.level
                            end
                        end
                        card_eval_status_text(target, 'extra', nil, nil, nil, {
                            message = "Empowered!",
                            colour = G.C.DARK_EDITION
                        })
                        target:juice_up()
                        return true
                    end
                }))

                return {
                    message = "Staff of Conjuration!",
                    colour = G.C.DARK_EDITION,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Annoy-o-Tron",
    race = {"Robot"},
    weapon = {"Fist"},
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {},
    combo = {"Alarm-o-Bot", "Bartender Bob", "Harth Stonebrew"},
    role = {"Tank"},
    rarity = 1,
    cost = 4,
    index = 356,
    config = { extra = { retrigger = 3, retrigger_per_level = 0.3, retrigger_per_ilvl = 0.2 } },
    loc_txt = {
        "If played hand is a",
        "{C:attention}Three of a Kind{},",
        "all scoring cards",
        "retrigger {C:attention}#1#{} time(s)"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.retrigger, card.ability.extra.retrigger_per_level, card.ability.extra.retrigger_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            if context.scoring_name == "Three of a Kind"
            or context.scoring_name == "Full House"
            or context.scoring_name == "Flush House"
            or context.scoring_name == "Five of a Kind" then
                return {
                    message = "BEEP BOOP!",
                    repetitions = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.retrigger, card.ability.extra.retrigger_per_level, card.ability.extra.retrigger_per_ilvl)),
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Prophet Zul",
    faction = {"Horde"},
    race = {"Troll"},
    class = {"Priest"},
    weapon = {"Staff"},
    damage = {"Shadow"},
    armor = {"Plate"},
    profession = {},
    combo = {"King Rastakhan", "G'huun", "Princess Talanji"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 6,
    index = 357,
    config = { extra = {
        x_chips = 1.3, x_chips_per_level = 0.1, x_chips_per_ilvl = 0.05,
        x_mult = 1.3, x_mult_per_level = 0.1, x_mult_per_ilvl = 0.05,
        revealed_card = nil
    } },
    loc_txt = {
        "Before scoring, reveal the",
        "{C:attention}top card{} of your deck.",
        "Scoring cards matching its",
        "{C:attention}Suit{} give {X:chips,C:white} X#1# {} Chips.",
        "Scoring cards matching its",
        "{C:attention}Rank{} give {X:mult,C:white} X#2# {} Mult."
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.x_chips, card.ability.extra.x_chips_per_level, card.ability.extra.x_chips_per_ilvl),
            Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        -- Reveal top card of deck before scoring
        if context.before and not context.blueprint then
            card.ability.extra.revealed_card = nil
            if G.deck and G.deck.cards and #G.deck.cards > 0 then
                local top_card = G.deck.cards[#G.deck.cards]
                card.ability.extra.revealed_suit = top_card.base.suit
                card.ability.extra.revealed_value = top_card.base.value
                G.E_MANAGER:add_event(Event({
                    func = function()
                        top_card:juice_up()
                        card_eval_status_text(card, 'extra', nil, nil, nil, {
                            message = top_card.base.value .. " of " .. top_card.base.suit .. "!",
                            colour = G.C.PURPLE
                        })
                        return true
                    end
                }))
                return {
                    message = "Prophecy!",
                    colour = G.C.PURPLE,
                    card = card
                }
            end
        end

        -- Apply XChips for matching suit, XMult for matching rank
        if context.individual and context.cardarea == G.play and not context.blueprint then
            local other = context.other_card
            local revealed_suit = card.ability.extra.revealed_suit
            local revealed_value = card.ability.extra.revealed_value

            if not revealed_suit and not revealed_value then return end

            local matches_suit = revealed_suit and other:is_suit(revealed_suit)
            local matches_rank = revealed_value and other.base.value == revealed_value

            if matches_suit and matches_rank then
                -- Matches both — give both bonuses
                return {
                    x_chips = Warcraft.get_scaled_gain(card, card.ability.extra.x_chips, card.ability.extra.x_chips_per_level, card.ability.extra.x_chips_per_ilvl),
                    x_mult = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
                    card = other,
                    message = "Perfect Vision!",
                    colour = G.C.PURPLE
                }
            elseif matches_suit then
                return {
                    x_chips = Warcraft.get_scaled_gain(card, card.ability.extra.x_chips, card.ability.extra.x_chips_per_level, card.ability.extra.x_chips_per_ilvl),
                    card = other,
                    message = "Foreseen!",
                    colour = G.C.CHIPS
                }
            elseif matches_rank then
                return {
                    x_mult = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
                    card = other,
                    message = "Foreseen!",
                    colour = G.C.MULT
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Sinestra",
    faction = {"Legion"},
    race = {"Dragon"},
    class = {"Warlock"},
    weapon = {"Fist"},
    damage = {"Fire"},
    armor = {"Plate"},
    profession = {},
    combo = {"Deathwing","Neltharion","Cho'gall","Wrathion","Nefarian","Onyxia"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 6,
    index = 358,
    config = { extra = { chance = 5, chance_per_level = -0.2, chance_per_ilvl = -0.1 } },
    loc_txt = {
        "When a hand is played,",
        "{C:green}1 in #1#{} chance to swap",
        "all card suits:",
        "{C:hearts}Hearts{} ↔ {C:spades}Spades{}",
        "{C:diamonds}Diamonds{} ↔ {C:clubs}Clubs{}"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.chance, card.ability.extra.chance_per_level, card.ability.extra.chance_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local effective_chance = math.max(1, Warcraft.get_scaled_gain(card, card.ability.extra.chance, card.ability.extra.chance_per_level, card.ability.extra.chance_per_ilvl))
            if pseudorandom('sinestra') < G.GAME.probabilities.normal / effective_chance then
                local suit_swap = {
                    Spades   = "Hearts",
                    Hearts   = "Spades",
                    Diamonds = "Clubs",
                    Clubs    = "Diamonds"
                }

                -- Collect all cards in played and held hand
                local all_cards = {}
                for _, v in ipairs(context.full_hand) do
                    table.insert(all_cards, v)
                end
                if G.hand and G.hand.cards then
                    for _, v in ipairs(G.hand.cards) do
                        table.insert(all_cards, v)
                    end
                end

                G.E_MANAGER:add_event(Event({
                    func = function()
                        for _, v in ipairs(all_cards) do
                            local new_suit = suit_swap[v.base.suit]
                            if new_suit then
                                v:change_suit(new_suit)
                                v:juice_up()
                            end
                        end
                        return true
                    end
                }))

                return {
                    message = "Twilight Shift!",
                    colour = G.C.PURPLE,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Loatheb",
    faction = {"Scourge"},
    race = {"Undead"},
    weapon = {"Fist"},
    damage = {"Nature"},
    armor = {"Leather"},
    profession = {},
    combo = {"Kel'Thuzad", "Heigan the Unclean", "Patchwerk"},
    role = {"Tank"},
    rarity = 2,
    cost = 6,
    index = 359,
    config = { extra = { chips = 0, chips_per_use = 25, chips_per_use_per_level = 5, chips_per_use_per_ilvl = 3, pack_cost_increase = 5 } },
    loc_txt = {
        "All {C:attention}Booster Packs{} cost",
        "{C:money}$#2#{} more.",
        "Each {C:attention}Consumable{} used gives",
        "{C:chips}+#3#{} permanent Chips.",
        "{C:inactive}(Currently {C:chips}+#1#{C:inactive} Chips){}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.chips,
            card.ability.extra.pack_cost_increase,
            Warcraft.get_scaled_gain(card, card.ability.extra.chips_per_use, card.ability.extra.chips_per_use_per_level, card.ability.extra.chips_per_use_per_ilvl)
        }
    end,
    add_to_deck = function(self, card, from_debuff)
        G.E_MANAGER:add_event(Event({
            func = function()
                if G.shop_jokers then
                    for _, c in ipairs(G.shop_jokers.cards) do c:set_cost() end
                end
                return true
            end
        }))
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.E_MANAGER:add_event(Event({
            func = function()
                if G.shop_jokers then
                    for _, c in ipairs(G.shop_jokers.cards) do c:set_cost() end
                end
                return true
            end
        }))
    end,
    calculate = function(self, card, context)
        -- Gain chips per consumable used
        if context.using_consumeable and not context.blueprint then
            local effective_chips = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.chips_per_use, card.ability.extra.chips_per_use_per_level, card.ability.extra.chips_per_use_per_ilvl))
            card.ability.extra.chips = card.ability.extra.chips + effective_chips
            return {
                message = "Spore Cloud!",
                colour = G.C.GREEN,
                card = card
            }
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
    name = "Rend Blackhand",
    faction = {"Horde"},
    race = {"Orc"},
    class = {"Warrior"},
    weapon = {"Sword", "Axe"},
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {},
    combo = {"Blackhand", "Thrall", "Nefarian"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 6,
    index = 360,
    config = { extra = { x_mult_per_dragon = 0.3, x_mult_per_dragon_per_level = 0.05, x_mult_per_dragon_per_ilvl = 0.03 } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult per",
        "{C:attention}Dragon{} Joker you own.",
        "{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult,",
        "{C:attention}#3#{C:inactive} Dragons){}"
    },
    loc_vars = function(self, info_queue, card)
        local dragon_count = 0
        if G.jokers then
            for _, j in ipairs(G.jokers.cards) do
                if j ~= card and Warcraft.is_race(j, "Dragon") then
                    dragon_count = dragon_count + 1
                end
            end
        end
        local effective_per = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_per_dragon, card.ability.extra.x_mult_per_dragon_per_level, card.ability.extra.x_mult_per_dragon_per_ilvl)
        return { effective_per, 1 + (dragon_count * effective_per), dragon_count }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local dragon_count = 0
            for _, j in ipairs(G.jokers.cards) do
                if j ~= card and Warcraft.is_race(j, "Dragon") then
                    dragon_count = dragon_count + 1
                end
            end
            if dragon_count > 0 then
                local effective_per = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_per_dragon, card.ability.extra.x_mult_per_dragon_per_level, card.ability.extra.x_mult_per_dragon_per_ilvl)
                return {
                    Xmult_mod = 1 + (dragon_count * effective_per),
                    message = "Warchief!",
                    colour = G.C.RED,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Alonsus Faol",
    faction = {"Alliance"},
    race = {"Human", "Undead"},
    class = {"Priest"},
    weapon = {"Staff"},
    damage = {"Holy"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Archbishop Benedictus", "Uther the Lightbringer", "Turalyon", "Tirion Fordring", "Calia Menethil"},
    role = {"Healer"},
    rarity = 2,
    cost = 6,
    index = 361,
    config = { extra = { money_per_gold = 1, money_per_gold_per_level = 0.2, money_per_gold_per_ilvl = 0.1 } },
    loc_txt = {
        "When {C:attention}sold{}, gain {C:money}$#1#{}",
        "per {C:money}Gold Card{} in your deck.",
        "Distribute {C:attention}+1 Level{} to random",
        "Jokers equal to your",
        "{C:money}Gold Card{} count."
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_gold
        local gold_count = 0
        if G.playing_cards then
            for _, c in ipairs(G.playing_cards) do
                if c.config.center == G.P_CENTERS.m_gold then gold_count = gold_count + 1 end
            end
        end
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.money_per_gold, card.ability.extra.money_per_gold_per_level, card.ability.extra.money_per_gold_per_ilvl),
            gold_count
        }
    end,
    calculate = function(self, card, context)
        if context.selling_self and not context.blueprint then
            -- Count gold cards
            local gold_count = 0
            if G.playing_cards then
                for _, c in ipairs(G.playing_cards) do
                    if c.config.center == G.P_CENTERS.m_gold then gold_count = gold_count + 1 end
                end
            end

            if gold_count == 0 then return end

            local effective_money = Warcraft.get_scaled_gain(card, card.ability.extra.money_per_gold, card.ability.extra.money_per_gold_per_level, card.ability.extra.money_per_gold_per_ilvl)

            -- Gain money
            ease_dollars(math.floor(gold_count * effective_money))

            -- Collect valid jokers to receive levels
            local valid_jokers = {}
            for _, j in ipairs(G.jokers.cards) do
                if j ~= card and j.ability.extra and j.ability.extra.level then
                    table.insert(valid_jokers, j)
                end
            end

            if #valid_jokers > 0 then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        -- Distribute gold_count levels randomly among other jokers
                        for i = 1, gold_count do
                            local target = pseudorandom_element(valid_jokers, pseudoseed('faol_level_' .. i .. '_' .. G.GAME.round))
                            target.ability.extra.level = (target.ability.extra.level or 1) + 1
                            if target.ability.extra.max_level and target.ability.extra.level > target.ability.extra.max_level then
                                target.ability.extra.max_level = target.ability.extra.level
                            end
                            card_eval_status_text(target, 'extra', nil, nil, nil, {
                                message = "Blessed!",
                                colour = G.C.GOLD
                            })
                            target:juice_up()
                        end
                        return true
                    end
                }))
            end

            return {
                message = "Last Rites!",
                colour = G.C.GOLD,
                card = card
            }
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Aya Blackpaw",
    faction = {"Horde"},
    race = {"Pandare0n"},
    class = {"Rogue"},
    weapon = {"Daggers"},
    damage = {"Physical"},
    armor = {"Leather"},
    profession = {},
    combo = {"Marin Noggenfogger", "Chen Stormstout", "Li Li Stormstout"},
    role = {"Melee DPS"},
    rarity = 3,
    cost = 8,
    index = 362,
    config = { extra = {
        mult = 0,
        current_rank_index = 1,
        rank_cycle = {2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14}, -- 14 = Ace
        mult_gain = 3, mult_gain_per_level = 0.5, mult_gain_per_ilvl = 0.3
    } },
    loc_txt = {
        "{C:mult}+#1#{} Mult",
        "When a {C:attention}#2#{} scores,",
        "gain {C:mult}+#3#{} Mult permanently.",
        "Target rank cycles after each trigger.",
        "{C:inactive}(Currently {C:mult}+#1#{C:inactive} Mult){}"
    },
    loc_vars = function(self, info_queue, card)
        local cycle = card.ability.extra.rank_cycle
        local idx = card.ability.extra.current_rank_index
        local rank_id = cycle[idx]
        local rank_names = {
            [2]="2",[3]="3",[4]="4",[5]="5",[6]="6",[7]="7",
            [8]="8",[9]="9",[10]="10",[11]="Jack",[12]="Queen",[13]="King",[14]="Ace"
        }
        return {
            card.ability.extra.mult,
            rank_names[rank_id] or tostring(rank_id),
            Warcraft.get_scaled_gain(card, card.ability.extra.mult_gain, card.ability.extra.mult_gain_per_level, card.ability.extra.mult_gain_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local cycle = card.ability.extra.rank_cycle
            local idx = card.ability.extra.current_rank_index
            local target_rank = cycle[idx]

            -- Check if any scoring card matches the current target rank
            local found = false
            for _, v in ipairs(context.scoring_hand) do
                if v:get_id() == target_rank then
                    found = true
                    break
                end
            end

            if found then
                local effective_gain = Warcraft.get_scaled_gain(card, card.ability.extra.mult_gain, card.ability.extra.mult_gain_per_level, card.ability.extra.mult_gain_per_ilvl)
                card.ability.extra.mult = card.ability.extra.mult + effective_gain

                -- Advance to next rank in cycle
                card.ability.extra.current_rank_index = (idx % #cycle) + 1

                local rank_names = {
                    [2]="2",[3]="3",[4]="4",[5]="5",[6]="6",[7]="7",
                    [8]="8",[9]="9",[10]="10",[11]="Jack",[12]="Queen",[13]="King",[14]="Ace"
                }
                local next_rank = cycle[card.ability.extra.current_rank_index]
                return {
                    message = "Next: " .. (rank_names[next_rank] or tostring(next_rank)) .. "!",
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
    name = "Chromaggus",
    race = {"Dragon"},
    class = {"Warrior"},
    weapon = {"Teeth"},
    damage = {"Fire"},
    armor = {"Leather"},
    profession = {},
    combo = {"Nefarian", "General Drakkisath", "The Beast"},
    role = {"Tank"},
    rarity = 3,
    cost = 9,
    index = 363,
    config = { extra = { copies_per_level = 0.1, copies_per_ilvl = 0.05, used_this_blind = false } },
    loc_txt = {
        "At the start of each {C:attention}Blind{},",
        "create {C:attention}#1#{} temporary copy/copies",
        "of each card drawn into",
        "your opening hand"
    },
    loc_vars = function(self, info_queue, card)
        local effective = math.max(1, math.floor(1 + Warcraft.get_scaled_gain(card, 0, card.ability.extra.copies_per_level, card.ability.extra.copies_per_ilvl)))
        return { effective }
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            card.ability.extra.used_this_blind = false
        end

        if context.first_hand_drawn and not context.blueprint and not card.ability.extra.used_this_blind then
            card.ability.extra.used_this_blind = true
            local effective_copies = math.max(1, math.floor(1 + Warcraft.get_scaled_gain(card, 0, card.ability.extra.copies_per_level, card.ability.extra.copies_per_ilvl)))

            G.E_MANAGER:add_event(Event({
                func = function()
                    -- Snapshot current hand cards before adding copies
                    local originals = {}
                    for _, c in ipairs(G.hand.cards) do
                        table.insert(originals, c)
                    end

                    for _, original in ipairs(originals) do
                        for i = 1, effective_copies do
                            local copy = copy_card(original, nil, nil, G.playing_card)
                            copy.is_temporary = true
                            copy.shattered = nil
                            copy.destroyed = nil
                            copy:add_to_deck()
                            G.deck.config.card_limit = G.deck.config.card_limit + 1
                            table.insert(G.playing_cards, copy)
                            G.hand:emplace(copy)
                        end
                    end

                    G.hand:sort()
                    card_eval_status_text(card, 'extra', nil, nil, nil, {
                        message = "Chromatic!",
                        colour = G.C.PURPLE
                    })
                    return true
                end
            }))

            return {
                message = "Five Heads!",
                colour = G.C.PURPLE,
                card = card
            }
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Maximillian of Northshire",
    faction = {"Alliance"},
    race = {"Human"},
    class = {"Warrior"},
    weapon = {"Sword", "Shield"},
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {},
    combo = {"Medivh", "Alexstrasza", "Alonsus Faol"},
    role = {"Tank"},
    rarity = 2,
    cost = 6,
    index = 364,
    config = { extra = { retrigger_per_dragon = 1, retrigger_per_dragon_per_level = 0.2, retrigger_per_dragon_per_ilvl = 0.1 } },
    loc_txt = {
        "When a {C:attention}Queen{} is {C:red}destroyed{},",
        "add {C:attention}Dragon{} race to a random",
        "non-Dragon Joker.",
        "Scored {C:attention}Queens{} retrigger",
        "{C:attention}#1#{} time(s) per {C:attention}Dragon{} Joker."
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.retrigger_per_dragon, card.ability.extra.retrigger_per_dragon_per_level, card.ability.extra.retrigger_per_dragon_per_ilvl) }
    end,
    calculate = function(self, card, context)
        -- Add Dragon race to a random joker when a Queen is destroyed
        if context.remove_playing_cards and not context.blueprint then
            if context.removed and #context.removed > 0 then
                local queen_destroyed = false
                for _, c in ipairs(context.removed) do
                    if c:get_id() == 12 then
                        queen_destroyed = true
                        break
                    end
                end

                if queen_destroyed then
                    local non_dragon_jokers = {}
                    for _, j in ipairs(G.jokers.cards) do
                        if j ~= card and not Warcraft.is_race(j, "Dragon") then
                            table.insert(non_dragon_jokers, j)
                        end
                    end

                    if #non_dragon_jokers > 0 then
                        local target = pseudorandom_element(non_dragon_jokers, pseudoseed('maximillian_' .. G.GAME.round))
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                if type(target.ability.extra.race) == "table" then
                                    table.insert(target.ability.extra.race, "Dragon")
                                elseif target.ability.extra.race then
                                    target.ability.extra.race = {target.ability.extra.race, "Dragon"}
                                else
                                    target.ability.extra.race = {"Dragon"}
                                end
                                card_eval_status_text(target, 'extra', nil, nil, nil, {
                                    message = "It's a Dragon!",
                                    colour = G.C.ORANGE
                                })
                                target:juice_up()
                                return true
                            end
                        }))
                        return {
                            message = "Dragon Slain!",
                            colour = G.C.ORANGE,
                            card = card
                        }
                    end
                end
            end
        end

        -- Retrigger Queens for each Dragon Joker
        if context.repetition and context.cardarea == G.play then
            if context.other_card:get_id() == 12 then
                local dragon_count = 0
                for _, j in ipairs(G.jokers.cards) do
                    if j ~= card and Warcraft.is_race(j, "Dragon") then
                        dragon_count = dragon_count + 1
                    end
                end
                if dragon_count > 0 then
                    local effective_retrigger = math.floor(dragon_count * Warcraft.get_scaled_gain(card, card.ability.extra.retrigger_per_dragon, card.ability.extra.retrigger_per_dragon_per_level, card.ability.extra.retrigger_per_dragon_per_ilvl))
                    return {
                        message = "For Northshire!",
                        repetitions = effective_retrigger,
                        card = card
                    }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "A.F. Kay",
    faction = {"Alliance"},
    race = {"Gnome"},
    class = {"Warrior"},
    weapon = {"Fist"},
    damage = {"Arcane"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Tirion Fordring", "Bartender Bob", "Harth Stonebrew"},
    role = {"Ranged DPS"},
    rarity = 3,
    cost = 8,
    index = 365,
    config = { extra = {
        x_chips = 3, x_chips_per_level = 0.5, x_chips_per_ilvl = 0.3,
        x_mult = 3, x_mult_per_level = 0.5, x_mult_per_ilvl = 0.3
    } },
    loc_txt = {
        "{X:chips,C:white} X#1# {} Chips and",
        "{X:mult,C:white} X#2# {} Mult if this is",
        "your {C:attention}last hand{} and you",
        "used {C:attention}0 Discards{} this Blind."
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.x_chips, card.ability.extra.x_chips_per_level, card.ability.extra.x_chips_per_ilvl),
            Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local hands_left = G.GAME.current_round and G.GAME.current_round.hands_left or 1
            local discards_used = G.GAME.current_round and G.GAME.current_round.discards_used or 0

            -- Last hand = hands_left is 1 (currently playing the last hand)
            if hands_left == 1 and discards_used == 0 then
                return {
                    x_chips = Warcraft.get_scaled_gain(card, card.ability.extra.x_chips, card.ability.extra.x_chips_per_level, card.ability.extra.x_chips_per_ilvl),
                    Xmult_mod = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
                    message = "AFK no more!",
                    colour = G.C.FILTER,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Mr. Smite",
    faction = {"Pirate"},
    race = {"Human"},
    class = {"Warrior"},
    weapon = {"Sword","Hammer","Axe"},
    damage = {"Physical"},
    armor = {"Leather"},
    profession = {},
    combo = {"Edwin VanCleef","Sneed","Captain Greenskin", "Vanessa VanCleef"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 6,
    index = 366,
    config = { extra = {
        chips = 60, chips_per_level = 8, chips_per_ilvl = 5,
        level_gain = 1, level_gain_per_level = 0.2, level_gain_per_ilvl = 0.1
    } },
    loc_txt = {
        "{C:chips}+#1#{} Chips.",
        "At start of each {C:attention}Blind{},",
        "all {C:attention}Pirate{} Jokers gain",
        "{C:attention}+#2#{} Level(s){}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.chips, card.ability.extra.chips_per_level, card.ability.extra.chips_per_ilvl),
            Warcraft.get_scaled_gain(card, card.ability.extra.level_gain, card.ability.extra.level_gain_per_level, card.ability.extra.level_gain_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            local effective_gain = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.level_gain, card.ability.extra.level_gain_per_level, card.ability.extra.level_gain_per_ilvl))
            local pirate_count = 0

            for _, j in ipairs(G.jokers.cards) do
                if j ~= card and Warcraft.is_faction(j, "Pirate") then
                    pirate_count = pirate_count + 1
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            if j.ability.extra and j.ability.extra.level then
                                j.ability.extra.level = (j.ability.extra.level or 1) + effective_gain
                                if j.ability.extra.max_level and j.ability.extra.level > j.ability.extra.max_level then
                                    j.ability.extra.max_level = j.ability.extra.level
                                end
                                card_eval_status_text(j, 'extra', nil, nil, nil, {
                                    message = "Yarr!",
                                    colour = G.C.ORANGE
                                })
                                j:juice_up()
                            end
                            return true
                        end
                    }))
                end
            end

            if pirate_count > 0 then
                return {
                    message = "All Hands!",
                    colour = G.C.ORANGE,
                    card = card
                }
            end
        end

        if context.joker_main then
            local effective_chips = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.chips, card.ability.extra.chips_per_level, card.ability.extra.chips_per_ilvl))
            return {
                chips = effective_chips,
                card = card
            }
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Princess Theradras",
    race = {"Elemental"},
    class = {"Warrior"},
    weapon = {"Fist"},
    damage = {"Nature"},
    armor = {"Leather"},
    profession = {},
    combo = {"Therazane", "Cenarius", "Magni Bronzebeard", "Garrosh Hellscream"},
    role = {"Tank"},
    rarity = 2,
    cost = 6,
    index = 367,
    config = { extra = { chance = 5, chance_per_level = -0.2, chance_per_ilvl = -0.1 } },
    loc_txt = {
        "Scoring cards have a {C:green}1 in #1#{}",
        "chance to become {C:diamonds}Diamonds{}.",
        "Scoring {C:diamonds}Diamonds{} have a",
        "{C:green}1 in #1#{} chance to become",
        "{C:attention}Stone Cards{}."
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_stone
        return { Warcraft.get_scaled_gain(card, card.ability.extra.chance, card.ability.extra.chance_per_level, card.ability.extra.chance_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            local other = context.other_card
            local effective_chance = math.max(1, Warcraft.get_scaled_gain(card, card.ability.extra.chance, card.ability.extra.chance_per_level, card.ability.extra.chance_per_ilvl))

            -- Diamond cards have chance to become Stone
            if other:is_suit('Diamonds') and other.config.center ~= G.P_CENTERS.m_stone then
                if pseudorandom('theradras_stone') < G.GAME.probabilities.normal / effective_chance then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            other:set_ability(G.P_CENTERS.m_stone, nil, true)
                            other:juice_up()
                            card_eval_status_text(card, 'extra', nil, nil, nil, {
                                message = "Petrified!",
                                colour = G.C.GREY
                            })
                            return true
                        end
                    }))
                    return {
                        message = "Earth's Embrace!",
                        colour = G.C.ORANGE,
                        card = card
                    }
                end
            -- Non-diamond cards have chance to become Diamonds
            elseif not other:is_suit('Diamonds') then
                if pseudorandom('theradras_diamond') < G.GAME.probabilities.normal / effective_chance then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            other:change_suit('Diamonds')
                            other:juice_up()
                            card_eval_status_text(card, 'extra', nil, nil, nil, {
                                message = "Earthen!",
                                colour = G.C.DIAMONDS
                            })
                            return true
                        end
                    }))
                    return {
                        message = "Stone Touch!",
                        colour = G.C.DIAMONDS,
                        card = card
                    }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Kologarn",
    faction = {"Horde", "Alliance"},
    race = {"Titan"},
    weapon = {"Fist"},
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {},
    combo = {"Mimiron", "Algalon the Observer", "Yogg Saron", "Hodir", "Thorim", "Freya", "Loken"},
    role = {"Tank"},
    rarity = 2,
    cost = 7,
    index = 368,
    config = { extra = {
        chips_per_rank = 5, chips_per_rank_per_level = 1, chips_per_rank_per_ilvl = 0.5,
        mult_per_rank = 2, mult_per_rank_per_level = 0.3, mult_per_rank_per_ilvl = 0.2
    } },
    loc_txt = {
        "If played hand has {C:attention}2+ cards{},",
        "the {C:attention}leftmost{} scoring card",
        "gives {C:chips}+#1#{} Chips per Rank.",
        "The {C:attention}rightmost{} scoring card",
        "gives {C:mult}+#2#{} Mult per Rank."
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.chips_per_rank, card.ability.extra.chips_per_rank_per_level, card.ability.extra.chips_per_rank_per_ilvl),
            Warcraft.get_scaled_gain(card, card.ability.extra.mult_per_rank, card.ability.extra.mult_per_rank_per_level, card.ability.extra.mult_per_rank_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            if not context.scoring_hand or #context.scoring_hand < 2 then return end

            local leftmost = context.scoring_hand[1]
            local rightmost = context.scoring_hand[#context.scoring_hand]
            local other = context.other_card
            local rank = other:get_id()

            if other == leftmost and other == rightmost then
                -- Edge case: only one card (shouldn't reach here due to < 2 check, but safety)
                return
            end

            if other == leftmost then
                local effective_chips = math.floor(rank * Warcraft.get_scaled_gain(card, card.ability.extra.chips_per_rank, card.ability.extra.chips_per_rank_per_level, card.ability.extra.chips_per_rank_per_ilvl))
                return {
                    chips = effective_chips,
                    card = other,
                    message = "Left Arm!",
                    colour = G.C.CHIPS
                }
            end

            if other == rightmost then
                local effective_mult = rank * Warcraft.get_scaled_gain(card, card.ability.extra.mult_per_rank, card.ability.extra.mult_per_rank_per_level, card.ability.extra.mult_per_rank_per_ilvl)
                return {
                    mult = effective_mult,
                    card = other,
                    message = "Right Arm!",
                    colour = G.C.MULT
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Mayla Highmountain",
    faction = {"Horde"},
    race = {"Tauren"},
    class = {"Warrior"},
    weapon = {"Hammer", "Fist"},
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {},
    combo = {"Baine Bloodhood", "Huln Highmountain", "Anduin Wrynn", "Dargrul"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 6,
    index = 369,
    config = { extra = {
        x_mult_per_tauren = 0.3, x_mult_per_tauren_per_level = 0.05, x_mult_per_tauren_per_ilvl = 0.03,
        ilvl_gain = 1, ilvl_gain_per_level = 0.2, ilvl_gain_per_ilvl = 0.1
    } },
    loc_txt = {
        "{X:mult,C:white} X#1# {} Mult per",
        "{C:attention}Tauren{} Joker you own.",
        "At end of {C:attention}Shop{}, all equipped",
        "Jokers gain {C:attention}+#2#{} Ilvl{}.",
        "{C:inactive}(Currently {X:mult,C:white} X#3# {C:inactive} Mult,",
        "{C:attention}#4#{C:inactive} Taurens){}"
    },
    loc_vars = function(self, info_queue, card)
        local tauren_count = 0
        if G.jokers then
            for _, j in ipairs(G.jokers.cards) do
                if j ~= card and Warcraft.is_race(j, "Tauren") then
                    tauren_count = tauren_count + 1
                end
            end
        end
        local effective_per = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_per_tauren, card.ability.extra.x_mult_per_tauren_per_level, card.ability.extra.x_mult_per_tauren_per_ilvl)
        local effective_ilvl = Warcraft.get_scaled_gain(card, card.ability.extra.ilvl_gain, card.ability.extra.ilvl_gain_per_level, card.ability.extra.ilvl_gain_per_ilvl)
        return { effective_per, effective_ilvl, 1 + (tauren_count * effective_per), tauren_count }
    end,
    calculate = function(self, card, context)
        -- Give ilvl to all equipped jokers at end of shop
        if context.ending_shop and not context.blueprint then
            local effective_ilvl = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.ilvl_gain, card.ability.extra.ilvl_gain_per_level, card.ability.extra.ilvl_gain_per_ilvl))
            local upgraded = false
            for _, j in ipairs(G.jokers.cards) do
                if j ~= card and j.ability.wow_equipment then
                    j.ability.wow_equipment.ilvl = (j.ability.wow_equipment.ilvl or 0) + effective_ilvl
                    j.ability.wow_equipment.ilvl_gained_this_round = 0
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            j:juice_up()
                            card_eval_status_text(j, 'extra', nil, nil, nil, {
                                message = "+Ilvl!",
                                colour = G.C.GOLD
                            })
                            return true
                        end
                    }))
                    upgraded = true
                end
            end
            if upgraded then
                return {
                    message = "Highmountain!",
                    colour = G.C.GOLD,
                    card = card
                }
            end
        end

        -- XMult per Tauren joker
        if context.joker_main then
            local tauren_count = 0
            for _, j in ipairs(G.jokers.cards) do
                if j ~= card and Warcraft.is_race(j, "Tauren") then
                    tauren_count = tauren_count + 1
                end
            end
            if tauren_count > 0 then
                local effective_per = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult_per_tauren, card.ability.extra.x_mult_per_tauren_per_level, card.ability.extra.x_mult_per_tauren_per_ilvl)
                return {
                    Xmult_mod = 1 + (tauren_count * effective_per),
                    message = "Highmountain Tribe!",
                    colour = G.C.GOLD,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Prince Keleseth",
    faction = {"Scourge"},
    race = {"Undead", "Blood Elf"},
    class = {"Death Knight"},
    weapon = {"Staff"},
    damage = {"Shadow"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Archmage Arugal", "Lich King", "Arthas Menethil", "King Ymiron"},
    role = {"Ranged DPS"},
    rarity = 3,
    cost = 8,
    index = 370,
    config = { extra = {
        mult = 20, mult_per_level = 3, mult_per_ilvl = 2,
        chips = 80, chips_per_level = 10, chips_per_ilvl = 8
    } },
    loc_txt = {
        "{C:mult}+#1#{} Mult and {C:chips}+#2#{} Chips.",
        "{C:red}Debuffed{} if your deck",
        "contains any {C:attention}2s{}."
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl),
            Warcraft.get_scaled_gain(card, card.ability.extra.chips, card.ability.extra.chips_per_level, card.ability.extra.chips_per_ilvl)
        }
    end,
    add_to_deck = function(self, card, from_debuff)
        -- Check on acquisition
        local has_two = false
        if G.playing_cards then
            for _, c in ipairs(G.playing_cards) do
                if c:get_id() == 2 then has_two = true; break end
            end
        end
        if has_two then card:set_debuff(true) end
    end,
    calculate = function(self, card, context)
        -- Continuously check for 2s and update debuff state
        if context.setting_blind or context.buying_card or context.selling_card then
            local has_two = false
            if G.playing_cards then
                for _, c in ipairs(G.playing_cards) do
                    if c:get_id() == 2 then has_two = true; break end
                end
            end
            G.E_MANAGER:add_event(Event({
                func = function()
                    if has_two and not card.debuff then
                        card:set_debuff(true)
                        card_eval_status_text(card, 'extra', nil, nil, nil, {
                            message = "Unworthy!",
                            colour = G.C.RED
                        })
                    elseif not has_two and card.debuff then
                        card:set_debuff(false)
                        card_eval_status_text(card, 'extra', nil, nil, nil, {
                            message = "Blood Pact!",
                            colour = G.C.DARK_EDITION
                        })
                    end
                    return true
                end
            }))
        end

        if context.joker_main and not card.debuff then
            return {
                mult = Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl),
                chips = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.chips, card.ability.extra.chips_per_level, card.ability.extra.chips_per_ilvl)),
                message = "San'layn!",
                colour = G.C.DARK_EDITION,
                card = card
            }
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Finkle Einhorn",
    faction = {"Alliance"},
    race = {"Gnome"},
    class = {"Hunter"},
    weapon = {"Gun", "Daggers"},
    damage = {"Piercing"},
    armor = {"Plate"},
    profession = {},
    combo = {"The Beast", "Mathias Shaw", "Nefarian"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 4,
    index = 371,
    config = { extra = { money = 5, money_per_level = 1, money_per_ilvl = 0.5, rounds_survived = 0 } },
    loc_txt = {
        "After {C:attention}1 Round{}, gain {C:money}$#1#{},",
        "destroy this Joker and",
        "spawn {C:attention}The Beast{}.",
        "{C:inactive}(Round: #2#/1){}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.money, card.ability.extra.money_per_level, card.ability.extra.money_per_ilvl),
            card.ability.extra.rounds_survived
        }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.repetition and not context.individual and not context.blueprint then
            card.ability.extra.rounds_survived = card.ability.extra.rounds_survived + 1

            if card.ability.extra.rounds_survived >= 1 then
                local effective_money = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.money, card.ability.extra.money_per_level, card.ability.extra.money_per_ilvl))
                G.E_MANAGER:add_event(Event({
                    func = function()
                        -- Gain money
                        ease_dollars(effective_money)

                        -- Spawn The Beast
                        local beast_key = Warcraft.secure_key("The Beast")
                        local beast = create_card('Joker', G.jokers, nil, nil, nil, nil, 'j_war_' .. beast_key, 'finkle')
                        beast:add_to_deck()
                        G.jokers:emplace(beast)
                        beast:start_materialize()
                        card_eval_status_text(card, 'extra', nil, nil, nil, {
                            message = "THE BEAST!",
                            colour = G.C.RED
                        })

                        -- Destroy Finkle
                        play_sound('tarot1')
                        card.T.r = -0.2
                        card:juice_up(0.3, 0.4)
                        card:start_dissolve({remove_as_card = true})
                        return true
                    end
                }))

                return {
                    message = "Found Him!",
                    colour = G.C.GREEN
                }
            else
                return {
                    message = "Almost...",
                    colour = G.C.GREEN,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Taelia Fordring",
    faction = {"Alliance"},
    race = {"Human"},
    class = {"Paladin"},
    weapon = {"Sword", "Shield"},
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {},
    combo = {"Tirion Fordring", "Bolvar Fordragon", "Daelin Proudmoore", "Jaina Proudmoore", "Flynn Fairwind"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 6,
    index = 372,
    config = { extra = { x_chips = 2, x_chips_per_level = 0.3, x_chips_per_ilvl = 0.2 } },
    loc_txt = {
        "The {C:attention}highest ranked{} card",
        "in your scoring hand",
        "gives {X:chips,C:white} X#1# {} Chips"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.x_chips, card.ability.extra.x_chips_per_level, card.ability.extra.x_chips_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            if not context.scoring_hand or #context.scoring_hand == 0 then return end

            -- Find highest ranked card in scoring hand
            local highest_id = -1
            local highest_card = nil
            for _, v in ipairs(context.scoring_hand) do
                local id = v:get_id()
                if id > highest_id then
                    highest_id = id
                    highest_card = v
                end
            end

            if context.other_card == highest_card then
                return {
                    x_chips = Warcraft.get_scaled_gain(card, card.ability.extra.x_chips, card.ability.extra.x_chips_per_level, card.ability.extra.x_chips_per_ilvl),
                    card = context.other_card,
                    message = "Champion!",
                    colour = G.C.GOLD
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Wilfred Fizzlebang",
    faction = {"Alliance"},
    race = {"Gnome"},
    class = {"Warlock"},
    weapon = {"Daggers"},
    damage = {"Shadow"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Lord Jaraxxus", "Tirion Fordring", "Anub'arak"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 5,
    index = 373,
    config = { extra = { count = 1, count_per_level = 0.2, count_per_ilvl = 0.1 } },
    loc_txt = {
        "At start of each {C:attention}Blind{},",
        "summon {C:attention}#1#{} random {C:attention}Demon{} Joker(s).",
        "If {C:attention}Lord Jaraxxus{} is summoned,",
        "make him {C:dark_edition}Negative{}."
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.count, card.ability.extra.count_per_level, card.ability.extra.count_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            local effective_count = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.count, card.ability.extra.count_per_level, card.ability.extra.count_per_ilvl))

            -- Collect all Demon jokers
            local demon_jokers = {}
            for k, v in pairs(G.P_CENTERS) do
                if v.set == "Joker"
                and v.config and v.config.extra
                and type(v.config.extra) == "table"
                and Warcraft.is_race_by_config(v.config.extra, "Demon")
                and not v.config.extra.is_other then
                    table.insert(demon_jokers, k)
                end
            end

            if #demon_jokers > 0 then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        for i = 1, effective_count do
                            -- Temporarily expand limit if needed
                            local over = #G.jokers.cards >= G.jokers.config.card_limit
                            if over then G.jokers.config.card_limit = G.jokers.config.card_limit + 1 end

                            local chosen_key = pseudorandom_element(demon_jokers, pseudoseed('fizzlebang_' .. i .. '_' .. G.GAME.round))
                            local summoned = create_card('Joker', G.jokers, nil, nil, nil, nil, chosen_key, 'fizzlebang')

                            -- If Jaraxxus, make negative
                            if summoned.ability and summoned.ability.name == "Lord Jaraxxus" then
                                summoned:set_edition({negative = true}, true)
                                card_eval_status_text(card, 'extra', nil, nil, nil, {
                                    message = "JARAXXUS!",
                                    colour = G.C.RED
                                })
                            end

                            summoned:add_to_deck()
                            G.jokers:emplace(summoned)
                            summoned:start_materialize()

                            if over then G.jokers.config.card_limit = G.jokers.config.card_limit - 1 end
                        end
                        return true
                    end
                }))

                return {
                    message = "I AM THE MASTER SUMMONER!",
                    colour = G.C.PURPLE,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Dranosh Saurfang",
    faction = {"Horde"},
    race = {"Orc"},
    class = {"Warrior", "Death Knight"},
    weapon = {"Axe"},
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {},
    combo = {"Varok Saurfang","Thrall","Bolvar Fordragon","Grand Apothecary Putress"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 6,
    index = 374,
    config = { extra = { mult = 0, mult_multiplier = 0.5, mult_multiplier_per_level = 0.1, mult_multiplier_per_ilvl = 0.05 } },
    loc_txt = {
        "{C:mult}+#1#{} Mult",
        "Gains {C:mult}+Mult{} permanently equal",
        "to {C:attention}#2#{} x the {C:attention}Rank{}",
        "of each scoring card.",
        "{C:inactive}(Currently {C:mult}+#1#{C:inactive} Mult){}"
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.mult,
            Warcraft.get_scaled_gain(card, card.ability.extra.mult_multiplier, card.ability.extra.mult_multiplier_per_level, card.ability.extra.mult_multiplier_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            local rank = context.other_card:get_id()
            if rank and rank > 0 then
                local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.mult_multiplier, card.ability.extra.mult_multiplier_per_level, card.ability.extra.mult_multiplier_per_ilvl)
                local gain = rank * effective_mult
                card.ability.extra.mult = card.ability.extra.mult + gain
                return {
                    message = "Deathbringer!",
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
    name = "Elite Tauren Chieftain",
    faction = {"Horde"},
    race = {"Tauren"},
    class = {"Warrior"},
    weapon = {"Axe", "Hammer"},
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {},
    combo = {"Silas Darkmoon","Tickatus","Bartender Bob","Harth Stonebrew"},
    role = {"Tank"},
    rarity = 2,
    cost = 6,
    index = 375,
    config = { extra = { count = 1, count_per_level = 0.2, count_per_ilvl = 0.1 } },
    loc_txt = {
        "At start of each {C:attention}Blind{},",
        "spawn {C:attention}#1#{} random",
        "{C:attention}Uncommon{} Joker(s)"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.count, card.ability.extra.count_per_level, card.ability.extra.count_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            local effective_count = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.count, card.ability.extra.count_per_level, card.ability.extra.count_per_ilvl))

            G.E_MANAGER:add_event(Event({
                func = function()
                    for i = 1, effective_count do
                        if #G.jokers.cards < G.jokers.config.card_limit then
                            -- Rarity 2 = uncommon
                            local new_joker = create_card('Joker', G.jokers, nil, 0.7, nil, nil, nil, 'etc')
                            new_joker:add_to_deck()
                            G.jokers:emplace(new_joker)
                            new_joker:start_materialize()
                        end
                    end
                    card_eval_status_text(card, 'extra', nil, nil, nil, {
                        message = "ROCK ON!",
                        colour = G.C.ORANGE
                    })
                    return true
                end
            }))

            return {
                message = "FOR THE HORDE!",
                colour = G.C.ORANGE,
                card = card
            }
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Prince Thunderaan",
    race = {"Elemental"},
    class = {"Shaman"},
    weapon = {"Sword"},
    damage = {"Nature"},
    armor = {"Plate"},
    profession = {},
    combo = {"Al'Akir", "Baron Geddon","Garr","Ragnaros"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 6,
    index = 376,
    config = { extra = { x_mult = 1.5, x_mult_per_level = 0.2, x_mult_per_ilvl = 0.1 } },
    loc_txt = {
        "Scoring cards with a {C:red}Red Seal{}",
        "gain a random {C:dark_edition}Edition{}",
        "and give {X:mult,C:white} X#1# {} Mult"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            -- 1. SAVE THE CARD TO A LOCAL VARIABLE FIRST!
            local played_card = context.other_card
            
            if played_card:get_seal() == 'Red' then
                -- Apply random edition if not already editioned
                if not played_card.edition or not next(played_card.edition) then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            -- 2. Safely use the local variable inside the event
                            local edition = poll_edition('thunderaan_' .. played_card.sort_id .. '_' .. G.GAME.round, nil, true, true)
                            if edition then
                                played_card:set_edition(edition, true)
                                played_card:juice_up()
                            end
                            return true
                        end
                    }))
                end

                return {
                    x_mult = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
                    card = played_card,
                    message = "Thunderfury!",
                    colour = G.C.YELLOW
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Ozruk",
    faction = {"Horde", "Alliance"},
    race = {"Elemental"},
    class = {"Warrior"},
    weapon = {"Fist"},
    damage = {"Nature"},
    armor = {"Plate"},
    profession = {},
    combo = {"Therazane","Millhouse Manastorm", "Princess Theradras"},
    role = {"Tank"},
    rarity = 2,
    cost = 6,
    index = 377,
    config = { extra = { x_mult = 3, x_mult_per_level = 0.5, x_mult_per_ilvl = 0.3, chance = 2, chance_per_level = -0.1, chance_per_ilvl = -0.05 } },
    loc_txt = {
        "Played {C:attention}Glass{} or {C:attention}Stone Cards{}",
        "have an additional {C:green}1 in #2#{}",
        "chance to {C:red}break{},",
        "giving {X:mult,C:white} X#1# {} Mult if destroyed."
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_glass
        info_queue[#info_queue+1] = G.P_CENTERS.m_stone
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
            Warcraft.get_scaled_gain(card, card.ability.extra.chance, card.ability.extra.chance_per_level, card.ability.extra.chance_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            local other = context.other_card
            local is_glass = other.config.center.key == 'm_glass'
            local is_stone = other.config.center.key == 'm_stone'

            if is_glass or is_stone then
                local effective_chance = math.max(1, Warcraft.get_scaled_gain(card, card.ability.extra.chance, card.ability.extra.chance_per_level, card.ability.extra.chance_per_ilvl))
                if pseudorandom('ozruk') < G.GAME.probabilities.normal / effective_chance then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            other.shattered = true
                            other:start_dissolve({remove_as_card = true})
                            card_eval_status_text(card, 'extra', nil, nil, nil, {
                                message = "Shatter!",
                                colour = G.C.GREY
                            })
                            return true
                        end
                    }))
                    return {
                        x_mult = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
                        card = card,
                        message = "SHATTER!",
                        colour = G.C.GREY
                    }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Bloodlord Mandokir",
    faction = {"Horde"},
    race = {"Troll"},
    class = {"Warrior"},
    weapon = {"Axe"},
    damage = {"Physical"},
    armor = {"Plate"},
    profession = {},
    combo = {"Hakkar the Soulflayer"," Jin'do the Hexxer", "Sen'jin"},
    role = {"Melee DPS"},
    rarity = 3,
    cost = 8,
    index = 378,
    config = { extra = {
        x_chips = 1,
        x_chips_per_rank = 0.1, x_chips_per_rank_per_level = 0.02, x_chips_per_rank_per_ilvl = 0.01,
        level_gain = 1, level_gain_per_level = 0.2, level_gain_per_ilvl = 0.1,
        ilvl_gain = 2, ilvl_gain_per_level = 0.3, ilvl_gain_per_ilvl = 0.2
    } },
    loc_txt = {
        "{X:chips,C:white} X#1# {} Chips",
        "Each time a playing card is {C:red}destroyed{},",
        "gain {C:attention}+#2#{} Level(s){},",
        "{C:attention}+#3#{} Ilvl{} and {X:chips,C:white} X#4# {}",
        "Chips per {C:attention}Rank{} of destroyed card."
    },
    loc_vars = function(self, info_queue, card)
        return {
            card.ability.extra.x_chips,
            Warcraft.get_scaled_gain(card, card.ability.extra.level_gain, card.ability.extra.level_gain_per_level, card.ability.extra.level_gain_per_ilvl),
            Warcraft.get_scaled_gain(card, card.ability.extra.ilvl_gain, card.ability.extra.ilvl_gain_per_level, card.ability.extra.ilvl_gain_per_ilvl),
            Warcraft.get_scaled_gain(card, card.ability.extra.x_chips_per_rank, card.ability.extra.x_chips_per_rank_per_level, card.ability.extra.x_chips_per_rank_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.remove_playing_cards and not context.blueprint then
            if context.removed and #context.removed > 0 then
                local effective_level = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.level_gain, card.ability.extra.level_gain_per_level, card.ability.extra.level_gain_per_ilvl))
                local effective_ilvl = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.ilvl_gain, card.ability.extra.ilvl_gain_per_level, card.ability.extra.ilvl_gain_per_ilvl))
                local effective_per_rank = Warcraft.get_scaled_gain(card, card.ability.extra.x_chips_per_rank, card.ability.extra.x_chips_per_rank_per_level, card.ability.extra.x_chips_per_rank_per_ilvl)

                for _, destroyed in ipairs(context.removed) do
                    local rank = destroyed:get_id() or 0

                    -- Level up
                    card.ability.extra.level = (card.ability.extra.level or 1) + effective_level
                    if card.ability.extra.max_level and card.ability.extra.level > card.ability.extra.max_level then
                        card.ability.extra.max_level = card.ability.extra.level
                    end

                    -- Ilvl up
                    if card.ability.wow_equipment then
                        card.ability.wow_equipment.ilvl = (card.ability.wow_equipment.ilvl or 1) + effective_ilvl
                        card.ability.wow_equipment.ilvl_gained_this_round = 0
                    end

                    -- XChips based on rank
                    card.ability.extra.x_chips = card.ability.extra.x_chips + (rank * effective_per_rank)
                end

                G.E_MANAGER:add_event(Event({
                    func = function()
                        card:juice_up()
                        card_eval_status_text(card, 'extra', nil, nil, nil, {
                            message = "DING!",
                            colour = G.C.GREEN
                        })
                        return true
                    end
                }))

                return {
                    message = "Level Up!",
                    colour = G.C.GREEN,
                    card = card
                }
            end
        end

        if context.joker_main then
            if card.ability.extra.x_chips > 1 then
                return {
                    x_chips = card.ability.extra.x_chips,
                    message = "Zul'Gurub!",
                    colour = G.C.ORANGE,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Thaddius",
    faction = {"Scourge"},
    race = {"Undead"},
    class = {"Warrior"},
    weapon = {"Fist"},
    damage = {"Nature"},
    armor = {"Unarmored"},
    profession = {},
    combo = {"Kel'Thuzad", "Professor Putricide", "Lich King"},
    role = {"Tank"},
    rarity = 3,
    cost = 8,
    index = 379,
    config = { extra = {
        mode = 1, -- 1 = Odd XChips, 2 = Even XChips, 3 = Odd XMult, 4 = Even XMult
        x_val = 2, x_val_per_level = 0.3, x_val_per_ilvl = 0.2
    } },
    loc_txt = {
        "Scored {C:attention}#1#{} cards give",
        -- {B:1,C:white} creates a dynamic background box with white text!
        "{B:1,C:white} X#2# {} {V:1}#3#{}",
        "Playing a hand swaps {C:attention}Odd/Even{}.",
        "Discarding swaps {C:chips}XChips{}/{C:mult}XMult{}."
    },
    loc_vars = function(self, info_queue, card)
        local mode = card.ability.extra.mode
        local rank_labels = {"Odd", "Even", "Odd", "Even"}
        local stat_labels = {"Chips", "Chips", "Mult", "Mult"}
        
        -- Determine the active color based on the current mode
        local active_colour = (mode == 1 or mode == 2) and G.C.CHIPS or G.C.MULT

        return {
            vars = {
                rank_labels[mode],
                Warcraft.get_scaled_gain(card, card.ability.extra.x_val, card.ability.extra.x_val_per_level, card.ability.extra.x_val_per_ilvl),
                stat_labels[mode],
                -- Passing the active color into the formatting tags
                colours = { active_colour }
            }
        }
    end,
    calculate = function(self, card, context)
        -- Swap Odd/Even after playing a hand
        if context.after and not context.blueprint then
            local mode = card.ability.extra.mode
            -- Toggle between odd/even within same type
            if mode == 1 then card.ability.extra.mode = 2
            elseif mode == 2 then card.ability.extra.mode = 1
            elseif mode == 3 then card.ability.extra.mode = 4
            elseif mode == 4 then card.ability.extra.mode = 3
            end
            return {
                message = "Polarity Shift!",
                colour = card.ability.extra.mode <= 2 and G.C.CHIPS or G.C.MULT,
                card = card
            }
        end

        -- Swap XChips/XMult after discarding
        if context.discard and not context.blueprint then
            if context.other_card == context.full_hand[1] then
                local mode = card.ability.extra.mode
                -- Toggle between chips/mult within same parity
                if mode == 1 then card.ability.extra.mode = 3
                elseif mode == 3 then card.ability.extra.mode = 1
                elseif mode == 2 then card.ability.extra.mode = 4
                elseif mode == 4 then card.ability.extra.mode = 2
                end
                return {
                    message = "Polarity Shift!",
                    colour = card.ability.extra.mode <= 2 and G.C.CHIPS or G.C.MULT,
                    card = card
                }
            end
        end

        -- Apply effect to scoring cards
        if context.individual and context.cardarea == G.play then
            local id = context.other_card:get_id()
            local mode = card.ability.extra.mode
            
            -- Ace (14) is Odd.
            local is_odd = (id % 2 == 1) or (id == 14)  
            local is_even = (id % 2 == 0) and (id ~= 14)

            local should_trigger = (mode == 1 and is_odd)
                                or (mode == 2 and is_even)
                                or (mode == 3 and is_odd)
                                or (mode == 4 and is_even)

            if should_trigger then
                local effective = Warcraft.get_scaled_gain(card, card.ability.extra.x_val, card.ability.extra.x_val_per_level, card.ability.extra.x_val_per_ilvl)
                local is_chips = mode <= 2

                if is_chips then
                    return {
                        x_chips = effective,
                        card = context.other_card,
                        message = "Polarity!",
                        colour = G.C.CHIPS
                    }
                else
                    return {
                        x_mult = effective,
                        card = context.other_card,
                        message = "Polarity!",
                        colour = G.C.MULT
                    }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Huffer",
    faction = {"Horde"},
    race = {"Beast"},
    class = {"Hunter"},
    weapon = {"Fist"},
    damage = {"Physical"},
    armor = {"Leather"},
    profession = {},
    combo = {"Rexxar","Leokk","Misha"},
    role = {"Melee DPS"},
    rarity = 2,
    cost = 5,
    index = 380,
    config = { extra = { convert_per_level = 0.1, convert_per_ilvl = 0.05 } },
    loc_txt = {
        "At start of each {C:attention}Blind{},",
        "convert all {C:red}Discards{} into",
        "additional {C:blue}Hands{}.",
        "{C:inactive}(x#1# multiplier){}"
    },
    loc_vars = function(self, info_queue, card)
        local effective_mult = math.max(1, math.floor(1 + Warcraft.get_scaled_gain(card, 0, card.ability.extra.convert_per_level, card.ability.extra.convert_per_ilvl)))
        return { effective_mult }
    end,
    add_to_deck = function(self, card, from_debuff)
        -- Apply immediately when acquired mid-run
        G.E_MANAGER:add_event(Event({
            func = function()
                local discards = G.GAME.current_round.discards_left or 0
                if discards > 0 then
                    G.GAME.current_round.hands_left = G.GAME.current_round.hands_left + discards
                    G.GAME.current_round.discards_left = 0
                    G.GAME.round_resets.hands = G.GAME.round_resets.hands + discards
                    G.GAME.round_resets.discards = 0
                end
                return true
            end
        }))
    end,
    remove_from_deck = function(self, card, from_debuff)
        -- Restore original discard count from round resets when removed
        G.E_MANAGER:add_event(Event({
            func = function()
                -- Restore base discards from game config
                local base_discards = G.GAME.starting_params and G.GAME.starting_params.discards or 3
                G.GAME.round_resets.discards = base_discards
                return true
            end
        }))
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            local effective_mult = math.max(1, math.floor(1 + Warcraft.get_scaled_gain(card, 0, card.ability.extra.convert_per_level, card.ability.extra.convert_per_ilvl)))
            local base_discards = G.GAME.round_resets.discards or 0

            if base_discards > 0 then
                local converted = base_discards * effective_mult
                G.E_MANAGER:add_event(Event({
                    func = function()
                        -- Convert all discards to hands
                        G.GAME.round_resets.hands = G.GAME.round_resets.hands + converted
                        G.GAME.round_resets.discards = 0
                        G.GAME.current_round.hands_left = G.GAME.current_round.hands_left + converted
                        G.GAME.current_round.discards_left = 0
                        card_eval_status_text(card, 'extra', nil, nil, nil, {
                            message = "CHARGE!",
                            colour = G.C.GREEN
                        })
                        return true
                    end
                }))
                return {
                    message = "Rush!",
                    colour = G.C.GREEN,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Leokk",
    faction = {"Horde"},
    race = {"Beast"},
    class = {"Hunter"},
    weapon = {"Fist"},
    damage = {"Physical"},
    armor = {"Leather"},
    profession = {},
    combo = {"Rexxar","Misha","Huffer"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 5,
    index = 381,
    config = { extra = { mult = 8, mult_per_level = 1, mult_per_ilvl = 0.5 } },
    loc_txt = {
        "{C:mult}+#1#{} Mult.",
        "While present during a {C:attention}Blind{},",
        "all {C:attention}Beast{} Jokers score",
        "as if their {C:attention}Level{} is doubled.",
        "{C:inactive}(Effect only active during Blind){}"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl) }
    end,
    add_to_deck = function(self, card, from_debuff)
        -- Apply level doubling when entering play during a blind
        if G.STATE ~= G.STATES.SHOP then
            Warcraft.leokk_apply(card, true)
        end
    end,
    remove_from_deck = function(self, card, from_debuff)
        -- Remove level doubling when leaving play
        Warcraft.leokk_apply(card, false)
    end,
    calculate = function(self, card, context)
        -- Apply doubling at start of blind
        if context.setting_blind and not context.blueprint then
            Warcraft.leokk_apply(card, true)
            return {
                message = "Pack Leader!",
                colour = G.C.GREEN,
                card = card
            }
        end

        -- Remove doubling at end of blind (entering shop)
        if context.end_of_round and not context.repetition and not context.individual and not context.blueprint then
            Warcraft.leokk_apply(card, false)
        end

        if context.joker_main then
            local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.mult, card.ability.extra.mult_per_level, card.ability.extra.mult_per_ilvl)
            return {
                mult = effective_mult,
                card = card
            }
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Merithra",
    faction = {"Horde", "Alliance"},
    race = {"Dragon","Night Elf"},
    class = {"Druid"},
    weapon = {"Fist"},
    damage = {"Nature"},
    armor = {"Mail"},
    profession = {},
    combo = {"Ysera", "Tyrande Whisperwind", "Malfurion Stormrage", "Alexstasza"},
    role = {"Healer"},
    rarity = 2,
    cost = 5,
    index = 382,
    config = { extra = {
        hands_trigger = 4, hands_trigger_per_level = -0.3, hands_trigger_per_ilvl = -0.2,
        hands_played = 0,
        cards_per_trigger = 1, cards_per_trigger_per_ilvl = 0.1
    } },
    loc_txt = {
        "Every {C:attention}#1#{} hands played,",
        "add {C:attention}#2#{} random card(s)",
        "of rank {C:attention}8 or higher{}",
        "to your deck.",
        "{C:inactive}(Hands: #3#/#1#){}"
    },
    loc_vars = function(self, info_queue, card)
        local effective_trigger = math.max(1, math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.hands_trigger, card.ability.extra.hands_trigger_per_level, card.ability.extra.hands_trigger_per_ilvl)))
        local effective_cards = math.max(1, math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.cards_per_trigger, 0, card.ability.extra.cards_per_trigger_per_ilvl)))
        return { effective_trigger, effective_cards, card.ability.extra.hands_played }
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            card.ability.extra.hands_played = 0
        end

        if context.after and not context.blueprint then
            card.ability.extra.hands_played = card.ability.extra.hands_played + 1
            local effective_trigger = math.max(1, math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.hands_trigger, card.ability.extra.hands_trigger_per_level, card.ability.extra.hands_trigger_per_ilvl)))

            if card.ability.extra.hands_played >= effective_trigger then
                card.ability.extra.hands_played = 0
                local effective_cards = math.max(1, math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.cards_per_trigger, 0, card.ability.extra.cards_per_trigger_per_ilvl)))

                -- Valid ranks: 8, 9, 10, J, Q, K, A
                local high_ranks = {"8", "9", "T", "J", "Q", "K", "A"}
                local suits = {"S", "H", "D", "C"}

                G.E_MANAGER:add_event(Event({
                    func = function()
                        for i = 1, effective_cards do
                            local rank = pseudorandom_element(high_ranks, pseudoseed('merithra_rank_' .. i .. '_' .. G.GAME.round))
                            local suit = pseudorandom_element(suits, pseudoseed('merithra_suit_' .. i .. '_' .. G.GAME.round))
                            local card_key = suit .. "_" .. rank
                            if G.P_CARDS[card_key] then
                                local new_card = create_card('Base', G.deck, nil, nil, nil, nil, nil, 'merithra')
                                new_card:set_base(G.P_CARDS[card_key])
                                new_card:add_to_deck()
                                G.deck.config.card_limit = G.deck.config.card_limit + 1
                                table.insert(G.playing_cards, new_card)
                                G.deck:emplace(new_card)
                                new_card:juice_up()
                            end
                        end
                        card_eval_status_text(card, 'extra', nil, nil, nil, {
                            message = "Dream Card!",
                            colour = G.C.GREEN
                        })
                        return true
                    end
                }))

                return {
                    message = "Emerald Dream!",
                    colour = G.C.GREEN,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Morchie",
    faction = {"Horde", "Alliance"},
    race = {"Dragon"},
    class = {"Mage"},
    weapon = {"Fist"},
    damage = {"Shadow"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Chromie","Nozdormu","Murozond"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 6,
    index = 383,
    config = { extra = { duration = 1, duration_per_level = 0.3, duration_per_ilvl = 0.2 } },
    loc_txt = {
        "At end of each {C:attention}Shop{},",
        "create a random {C:dark_edition}Negative{}",
        "{C:red}Perishable{} Joker with",
        "{C:attention}#1#{} Blind(s) of duration."
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_perishable
        return { math.max(1, math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.duration, card.ability.extra.duration_per_level, card.ability.extra.duration_per_ilvl))) }
    end,
    calculate = function(self, card, context)
        if context.ending_shop and not context.blueprint then
            local effective_duration = math.max(1, math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.duration, card.ability.extra.duration_per_level, card.ability.extra.duration_per_ilvl)))

            G.E_MANAGER:add_event(Event({
                func = function()
                    if #G.jokers.cards < G.jokers.config.card_limit then
                        local new_joker = create_card('Joker', G.jokers, nil, nil, nil, nil, nil, 'morchie')
                        -- Make negative
                        new_joker:set_edition({negative = true}, true)
                        -- Make perishable with custom duration
                        new_joker:set_perishable(true)
                        if new_joker.ability.perish then
                            new_joker.ability.perish.countdown = effective_duration
                            new_joker.ability.perish.dur = effective_duration
                        end
                        new_joker:add_to_deck()
                        G.jokers:emplace(new_joker)
                        new_joker:start_materialize()
                        card_eval_status_text(card, 'extra', nil, nil, nil, {
                            message = "Time Loop!",
                            colour = G.C.DARK_EDITION
                        })
                    end
                    return true
                end
            }))

            return {
                message = "Infinite!",
                colour = G.C.DARK_EDITION,
                card = card
            }
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Ambassador Faelin",
    faction = {"Horde"},
    race = {"Night Elf"},
    class = {"Warrior"},
    weapon = {"Sword", "Fist"},
    damage = {"Physical"},
    armor = {"Leather"},
    profession = {},
    combo = {"Bartender Bob", "Harth Stonebrew", "Reno Jackson"},
    role = {"Tank"},
    rarity = 2,
    cost = 6,
    index = 384,
    config = { extra = {
        triggered_this_blind = false,
        money = 8, money_per_level = 1, money_per_ilvl = 0.5,
        jokers = 1, jokers_per_level = 0.2, jokers_per_ilvl = 0.1
    } },
    loc_txt = {
        "If you draw your entire",
        "{C:attention}deck{} during a {C:attention}Blind{},",
        "gain {C:money}$#1#{} and create",
        "{C:attention}#2#{} random {C:red}Rare{} Joker(s)."
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.money, card.ability.extra.money_per_level, card.ability.extra.money_per_ilvl),
            Warcraft.get_scaled_gain(card, card.ability.extra.jokers, card.ability.extra.jokers_per_level, card.ability.extra.jokers_per_ilvl)
        }
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            card.ability.extra.triggered_this_blind = false
        end

        if context.hand_drawn and not context.blueprint and not card.ability.extra.triggered_this_blind then
            -- Check if the deck is now empty (all cards drawn)
            if G.deck and #G.deck.cards == 0 then
                card.ability.extra.triggered_this_blind = true

                local effective_money = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.money, card.ability.extra.money_per_level, card.ability.extra.money_per_ilvl))
                local effective_jokers = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.jokers, card.ability.extra.jokers_per_level, card.ability.extra.jokers_per_ilvl))

                ease_dollars(effective_money)

                G.E_MANAGER:add_event(Event({
                    func = function()
                        for i = 1, effective_jokers do
                            if #G.jokers.cards < G.jokers.config.card_limit then
                                local new_joker = create_card('Joker', G.jokers, nil, 0.99, nil, nil, nil, 'faelin')
                                new_joker:add_to_deck()
                                G.jokers:emplace(new_joker)
                                new_joker:start_materialize()
                            end
                        end
                        card_eval_status_text(card, 'extra', nil, nil, nil, {
                            message = "Deep Treasure!",
                            colour = G.C.GOLD
                        })
                        return true
                    end
                }))

                return {
                    message = "Sunken Riches!",
                    colour = G.C.GOLD,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Arana Starseeker",
    faction = {"Alliance"},
    race = {"Night Elf"},
    class = {"Hunter"},
    weapon = {"Bow", "Daggers"},
    damage = {"Fire"},
    armor = {"Leather"},
    profession = {},
    combo = {"Elise Starseeker", "Reno Jackson", "Illidan Stormrage", "Sin Finley Mrrgglton"},
    role = {"Melee DPS"},
    rarity = 3,
    cost = 8,
    index = 385,
    config = { extra = {
        h_size = -1,
        x_mult = 5, x_mult_per_level = 1, x_mult_per_ilvl = 0.5,
        target_cards = 7
    } },
    loc_txt = {
        "{C:attention}#3#{} Hand Size.",
        "{X:mult,C:white} X#1# {} Mult if you have",
        "exactly {C:attention}#2#{} total cards{}",
        "played and held combined."
    },
    loc_vars = function(self, info_queue, card)
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
            card.ability.extra.target_cards,
            card.ability.extra.h_size
        }
    end,
    add_to_deck = function(self, card, from_debuff)
        G.hand:change_size(card.ability.extra.h_size)
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.hand:change_size(-card.ability.extra.h_size)
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local played_count = context.full_hand and #context.full_hand or 0
            local held_count = G.hand and #G.hand.cards or 0
            local total = played_count + held_count

            if total == card.ability.extra.target_cards then
                return {
                    Xmult_mod = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
                    message = "Seven Stars!",
                    colour = G.C.FILTER,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Bru'kan",
    faction = {"Horde"},
    race = {"Troll"},
    class = {"Shaman"},
    weapon = {"Staff", "Fist"},
    damage = {"Nature"},
    armor = {"Mail"},
    profession = {},
    combo = {"Bartender Bob", "Harth Stonebrew", "Silas Darkmoon"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 6,
    index = 386,
    config = { extra = { total_retrigggers = 2, total_retrigggers_per_level = 0.3, total_retrigggers_per_ilvl = 0.2 } },
    loc_txt = {
        "Scoring cards collectively",
        "receive {C:attention}#1#{} retrigger(s)",
        "split randomly among them."
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.total_retrigggers, card.ability.extra.total_retrigggers_per_level, card.ability.extra.total_retrigggers_per_ilvl) }
    end,
    calculate = function(self, card, context)
        -- Distribute retrigggers before scoring
        if context.before and not context.blueprint then
            if not context.scoring_hand or #context.scoring_hand == 0 then return end
            local effective_total = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.total_retrigggers, card.ability.extra.total_retrigggers_per_level, card.ability.extra.total_retrigggers_per_ilvl))

            -- Randomly assign retrigggers to cards
            card.ability.extra.retrigger_map = {}
            for i = 1, effective_total do
                local idx = math.floor(pseudorandom('brukan_assign_' .. i .. '_' .. G.GAME.round) * #context.scoring_hand) + 1
                local target = context.scoring_hand[idx]
                if target then
                    local key = tostring(target)
                    card.ability.extra.retrigger_map[key] = (card.ability.extra.retrigger_map[key] or 0) + 1
                end
            end
        end

        -- Apply assigned retrigggers per card
        if context.repetition and context.cardarea == G.play and not context.blueprint then
            local map = card.ability.extra.retrigger_map
            if not map then return end
            local key = tostring(context.other_card)
            local assigned = map[key] or 0
            if assigned > 0 then
                return {
                    message = "Ancient Wisdom!",
                    repetitions = assigned,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Buttons",
    faction = {"Scourge"},
    race = {"Undead"},
    damage = {"Physical"},
    armor = {"Leather"},
    profession = {},
    combo = {"Zovaal", "Kel'Thuzad", "Lich King"},
    role = {"Tank"},
    rarity = 1,
    cost = 3,
    index = 387,
    config = { extra = {
        actions_count = 0,
        actions_trigger = 8, actions_trigger_per_level = -0.5, actions_trigger_per_ilvl = -0.3,
        consumables = 1, consumables_per_ilvl = 0.1
    } },
    loc_txt = {
        "Every {C:attention}#1#{} hands or discards,",
        "gain {C:attention}#2#{} random {C:attention}Consumable(s){}.",
        "{C:inactive}(Actions: #3#/#1#){}"
    },
    loc_vars = function(self, info_queue, card)
        local effective_trigger = math.max(1, math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.actions_trigger, card.ability.extra.actions_trigger_per_level, card.ability.extra.actions_trigger_per_ilvl)))
        local effective_consumables = math.max(1, math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.consumables, 0, card.ability.extra.consumables_per_ilvl)))
        return { effective_trigger, effective_consumables, card.ability.extra.actions_count }
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            card.ability.extra.actions_count = 0
        end

        local function try_trigger(card)
            local effective_trigger = math.max(1, math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.actions_trigger, card.ability.extra.actions_trigger_per_level, card.ability.extra.actions_trigger_per_ilvl)))
            if card.ability.extra.actions_count >= effective_trigger then
                card.ability.extra.actions_count = 0
                local effective_consumables = math.max(1, math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.consumables, 0, card.ability.extra.consumables_per_ilvl)))
                G.E_MANAGER:add_event(Event({
                    func = function()
                        for i = 1, effective_consumables do
                            if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                                local c_types = {'Tarot', 'Planet', 'Equipment', 'Spectral'}
                                local chosen = pseudorandom_element(c_types, pseudoseed('buttons_' .. i .. '_' .. G.GAME.round))
                                local new_card = create_card(chosen, G.consumeables, nil, nil, nil, nil, nil, 'buttons')
                                new_card:add_to_deck()
                                G.consumeables:emplace(new_card)
                                G.GAME.consumeable_buffer = 0
                                new_card:juice_up()
                            end
                        end
                        card_eval_status_text(card, 'extra', nil, nil, nil, {
                            message = "Buttons!",
                            colour = G.C.GREEN
                        })
                        return true
                    end
                }))
                return {
                    message = "Buttons!",
                    colour = G.C.GREEN,
                    card = card
                }
            end
        end

        -- Count hands
        if context.after and not context.blueprint then
            card.ability.extra.actions_count = card.ability.extra.actions_count + 1
            return try_trigger(card)
        end

        -- Count discards (once per discard action)
        if context.discard and not context.blueprint then
            if context.other_card == context.full_hand[1] then
                card.ability.extra.actions_count = card.ability.extra.actions_count + 1
                return try_trigger(card)
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Captain Hooktusk",
    faction = {"Horde", "Pirate"},
    race = {"Troll"},
    class = {"Rogue"},
    weapon = {"Sword", "Gun"},
    damage = {"Piercing"},
    armor = {"Leather"},
    profession = {},
    combo = {"Captain Eudora","Harlan Sweete","Fleet Admiral Tethys", "Gral"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 6,
    index = 388,
    config = { extra = {
        used_this_blind = false,
        money_multiplier = 1, money_multiplier_per_level = 0.2, money_multiplier_per_ilvl = 0.1
    } },
    loc_txt = {
        "Once per {C:attention}Blind{}, when a",
        "{C:attention}High Card{} is played,",
        "lower the scored card's rank by {C:attention}1{}",
        "and gain {C:money}$Rank x #1#{}"
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.money_multiplier, card.ability.extra.money_multiplier_per_level, card.ability.extra.money_multiplier_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            card.ability.extra.used_this_blind = false
        end

        if context.before and not context.blueprint and not card.ability.extra.used_this_blind then
            if context.scoring_name == "High Card" and context.scoring_hand and #context.scoring_hand > 0 then
                card.ability.extra.used_this_blind = true
                local target = context.scoring_hand[1]
                local current_id = target:get_id()
                local new_id = current_id - 1

                local rank_map = {
                    [2]="2",[3]="3",[4]="4",[5]="5",[6]="6",[7]="7",
                    [8]="8",[9]="9",[10]="T",[11]="J",[12]="Q",[13]="K",[14]="A"
                }

                local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.money_multiplier, card.ability.extra.money_multiplier_per_level, card.ability.extra.money_multiplier_per_ilvl)
                local money_gained = math.floor(current_id * effective_mult)

                if new_id >= 2 and rank_map[new_id] then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            local suit_prefix = string.sub(target.base.suit, 1, 1)
                            local new_key = suit_prefix .. "_" .. rank_map[new_id]
                            if G.P_CARDS[new_key] then
                                target:set_base(G.P_CARDS[new_key])
                                target:juice_up()
                            end
                            ease_dollars(money_gained)
                            card_eval_status_text(card, 'extra', nil, nil, nil, {
                                message = "$" .. money_gained .. "!",
                                colour = G.C.MONEY
                            })
                            return true
                        end
                    }))
                    return {
                        message = "Plunder!",
                        colour = G.C.MONEY,
                        card = card
                    }
                elseif new_id < 2 then
                    -- Below 2, destroy card
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            target:start_dissolve({remove_as_card = true})
                            ease_dollars(money_gained)
                            card_eval_status_text(card, 'extra', nil, nil, nil, {
                                message = "LOOTED!",
                                colour = G.C.MONEY
                            })
                            return true
                        end
                    }))
                    return {
                        message = "PLUNDER!",
                        colour = G.C.MONEY,
                        card = card
                    }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Cariel Roame",
    faction = {"Alliance"},
    race = {"Human"},
    class = {"Paladin"},
    weapon = {"Hammer"},
    damage = {"Holy"},
    armor = {"Plate"},
    profession = {},
    combo = {"Tamsin Roame", "Bartender Bob", "Harth Stonebrew"},
    role = {"Healer"},
    rarity = 2,
    cost = 6,
    index = 389,
    config = { extra = { chips_per_consumable = 2, chips_per_consumable_per_level = 0.3, chips_per_consumable_per_ilvl = 0.2 } },
    loc_txt = {
        "Scoring cards permanently gain",
        "{C:chips}+#1#{} Chips per {C:attention}Consumable{}",
        "currently held.",
        "{C:inactive}(Currently {C:attention}#2#{C:inactive} Consumables){}"
    },
    loc_vars = function(self, info_queue, card)
        local consumable_count = G.consumeables and #G.consumeables.cards or 0
        return {
            Warcraft.get_scaled_gain(card, card.ability.extra.chips_per_consumable, card.ability.extra.chips_per_consumable_per_level, card.ability.extra.chips_per_consumable_per_ilvl),
            consumable_count
        }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            local consumable_count = G.consumeables and #G.consumeables.cards or 0
            if consumable_count > 0 then
                local effective_chips = Warcraft.get_scaled_gain(card, card.ability.extra.chips_per_consumable, card.ability.extra.chips_per_consumable_per_level, card.ability.extra.chips_per_consumable_per_ilvl)
                local bonus = math.floor(consumable_count * effective_chips)
                context.other_card.ability.perma_bonus = (context.other_card.ability.perma_bonus or 0) + bonus
                G.E_MANAGER:add_event(Event({
                    func = function()
                        context.other_card:juice_up()
                        return true
                    end
                }))
                return {
                    message = "Conviction!",
                    colour = G.C.GOLD,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Greybough",
    faction = {"Horde", "Alliance"},
    race = {"Beast"},
    class = {"Druid"},
    weapon = {"Fist"},
    damage = {"Nature"},
    armor = {"Mail"},
    profession = {},
    combo = {"Malfurion Stormrage","Cenarius","Silas Darkmoon","Tickatus"},
    role = {"Healer"},
    rarity = 1,
    cost = 4,
    index = 390,
    config = { extra = { sell_gain = 1, sell_gain_per_level = 0.2, sell_gain_per_ilvl = 0.1 } },
    loc_txt = {
        "Each time a {C:attention}3{} scores,",
        "a random Joker permanently",
        "gains {C:money}$#1#{} Sell Value."
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.sell_gain, card.ability.extra.sell_gain_per_level, card.ability.extra.sell_gain_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            if context.other_card:get_id() == 3 then
                local valid_jokers = {}
                for _, j in ipairs(G.jokers.cards) do
                    table.insert(valid_jokers, j)
                end

                if #valid_jokers > 0 then
                    local target = pseudorandom_element(valid_jokers, pseudoseed('greybough_' .. G.GAME.round .. '_' .. (G.GAME.current_round.hands_played or 0)))
                    local effective_gain = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.sell_gain, card.ability.extra.sell_gain_per_level, card.ability.extra.sell_gain_per_ilvl))

                    G.E_MANAGER:add_event(Event({
                        func = function()
                            target.ability.extra_value = (target.ability.extra_value or 0) + effective_gain
                            target:set_cost()
                            card_eval_status_text(target, 'extra', nil, nil, nil, {
                                message = "+$" .. effective_gain .. " Value!",
                                colour = G.C.MONEY
                            })
                            target:juice_up()
                            return true
                        end
                    }))

                    return {
                        message = "Ancient Growth!",
                        colour = G.C.GREEN,
                        card = card
                    }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Guff Runetotem",
    faction = {"Horde"},
    race = {"Tauren"},
    class = {"Druid"},
    weapon = {"Staff"},
    damage = {"Nature"},
    armor = {"Leather"},
    profession = {},
    combo = {"Hamuul Runetotem", "Bartender Bob", "Harth Stonebrew"},
    role = {"Healer"},
    rarity = 2,
    cost = 6,
    index = 391,
    config = { extra = {
        gold_threshold = 20, 
        gold_threshold_per_level = -1, 
        gold_threshold_per_ilvl = -0.5,
        gold_spent = 0
    } },
    loc_txt = {
        "For every {C:money}$#1#{} spent in the",
        "{C:attention}Shop{}, gain a {C:attention}Hero's Tag{}.",
        "{C:inactive}(Spent: {C:money}$#2#{C:inactive}/{C:money}$#1#{C:inactive}){}"
    },
    loc_vars = function(self, info_queue, card)
        local effective_threshold = math.max(5, math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.gold_threshold, card.ability.extra.gold_threshold_per_level, card.ability.extra.gold_threshold_per_ilvl)))
        
        -- Add the Hero's Tag tooltip when hovering over Guff
        info_queue[#info_queue+1] = {set = 'Tag', key = 'tag_war_faction_pack'}
        
        return { effective_threshold, card.ability.extra.gold_spent }
    end,
    calculate = function(self, card, context)
        -- Reliably catch ANY money spent while in the shop
        if context.money_altered and context.amount < 0 and G.STATE == G.STATES.SHOP and not context.blueprint then
            local spent = math.abs(context.amount)
            card.ability.extra.gold_spent = card.ability.extra.gold_spent + spent
            
            local effective_threshold = math.max(5, math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.gold_threshold, card.ability.extra.gold_threshold_per_level, card.ability.extra.gold_threshold_per_ilvl)))
            
            -- If we passed the threshold, calculate how many tags to give
            if card.ability.extra.gold_spent >= effective_threshold then
                local tags_to_give = math.floor(card.ability.extra.gold_spent / effective_threshold)
                
                -- Keep the remainder
                card.ability.extra.gold_spent = card.ability.extra.gold_spent % effective_threshold
                
                G.E_MANAGER:add_event(Event({
                    func = function()
                        -- Give the calculated amount of Hero's Tags
                        for i = 1, tags_to_give do
                            local new_tag = Tag('tag_war_faction_pack')
                            add_tag(new_tag)
                        end
                        
                        card_eval_status_text(card, 'extra', nil, nil, nil, {
                            message = "Nature's Bounty!",
                            colour = G.C.GREEN
                        })
                        card:juice_up()
                        return true
                    end
                }))
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Jandice Barov",
    faction = {"Scourge"},
    race = {"Human", "Undead"},
    class = {"Mage"},
    weapon = {"Staff"},
    damage = {"Shadow"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Mathias Shaw", "Baron Rivendare", "Darkmaster Gandling"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 6,
    index = 392,
    config = { extra = { copies = 1, copies_per_level = 0.2, copies_per_ilvl = 0.1 } },
    loc_txt = {
        "When {C:attention}sold{} during the {C:attention}Shop{},",
        "add {C:attention}#1#{} free copy/copies of",
        "a random Joker in the shop."
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.copies, card.ability.extra.copies_per_level, card.ability.extra.copies_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.selling_self and not context.blueprint then
            if G.STATE ~= G.STATES.SHOP then return end
            if not G.shop_jokers or #G.shop_jokers.cards == 0 then return end

            local shop_jokers = {}
            for _, j in ipairs(G.shop_jokers.cards) do
                if j.config and j.config.center then
                    table.insert(shop_jokers, j.config.center.key)
                end
            end

            if #shop_jokers > 0 then
                local effective_copies = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.copies, card.ability.extra.copies_per_level, card.ability.extra.copies_per_ilvl))
                G.E_MANAGER:add_event(Event({
                    func = function()
                        for i = 1, effective_copies do
                            if #G.jokers.cards < G.jokers.config.card_limit then
                                local chosen_key = pseudorandom_element(shop_jokers, pseudoseed('jandice_' .. i .. '_' .. G.GAME.round))
                                local copy = create_card('Joker', G.jokers, nil, nil, nil, nil, chosen_key, 'jandice')
                                copy:add_to_deck()
                                G.jokers:emplace(copy)
                                copy:start_materialize()
                                card_eval_status_text(copy, 'extra', nil, nil, nil, {
                                    message = "Illusion!",
                                    colour = G.C.PURPLE
                                })
                            end
                        end
                        return true
                    end
                }))

                return {
                    message = "Spectral!",
                    colour = G.C.PURPLE
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Madam Goya",
    faction = {"Horde"},
    race = {"Pandaren"},
    class = {"Rogue"},
    weapon = {"Fist"},
    damage = {"Physical"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Bartender Bob", "Harth Stonebrew", "Chen Stormstout", "Aya Blackpaw", "Admiral Taylor"},
    role = {"Healer"},
    rarity = 2,
    cost = 5,
    index = 393,
    config = { extra = { x_chips = 1, interest_rate = 0.1, interest_rate_per_level = 0.01, interest_rate_per_ilvl = 0.005 } },
    loc_txt = {
        "{X:chips,C:white} X#1# {} Chips",
        "Each time you spend {C:money}money{}",
        "in the {C:attention}Shop{}, gain",
        "{C:attention}#2#%{} of it as permanent",
        "{X:chips,C:white} XChips{}."
    },
    loc_vars = function(self, info_queue, card)
        local effective_rate = Warcraft.get_scaled_gain(card, card.ability.extra.interest_rate, card.ability.extra.interest_rate_per_level, card.ability.extra.interest_rate_per_ilvl)
        return { card.ability.extra.x_chips, math.floor(effective_rate * 100) }
    end,
    calculate = function(self, card, context)
        local function process_spend(amount)
            if G.STATE ~= G.STATES.SHOP then return end
            if amount <= 0 then return end
            local effective_rate = Warcraft.get_scaled_gain(card, card.ability.extra.interest_rate, card.ability.extra.interest_rate_per_level, card.ability.extra.interest_rate_per_ilvl)
            local gain = amount * effective_rate
            if gain > 0 then
                card.ability.extra.x_chips = card.ability.extra.x_chips + gain
                return {
                    message = "Investment!",
                    colour = G.C.MONEY,
                    card = card
                }
            end
        end

        -- Track card purchases
        if context.buying_card and not context.blueprint then
            local cost = context.card and context.card.cost or 0
            return process_spend(cost)
        end

        -- Track rerolls
        if context.reroll_shop and not context.blueprint then
            return process_spend(G.GAME.reroll_cost or 1)
        end

        if context.joker_main then
            if card.ability.extra.x_chips > 1 then
                return {
                    x_chips = card.ability.extra.x_chips,
                    message = "Black Market!",
                    colour = G.C.MONEY,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Queen Wagtoggle",
    faction = {"Scourge"},
    race = {"Undead"},
    class = {"Warrior"},
    weapon = {"Fist"},
    damage = {"Fire"},
    armor = {"Leather"},
    profession = {},
    combo = {"Dr. Boom", "Shudderwock", "Hagatha the Witch", "King Togwaggle", "Arch-Thief Rafaam"},
    role = {"Healer"},
    rarity = 2,
    cost = 5,
    index = 394,
    config = { extra = {
        x_chips = 1,
        x_chips_per_race = 0.2, x_chips_per_race_per_level = 0.05, x_chips_per_race_per_ilvl = 0.03,
        seen_races = {}
    } },
    loc_txt = {
        "{X:chips,C:white} X#1# {} Chips",
        "Permanently gains {X:chips,C:white} X#2# {} Chips",
        "for each new {C:attention}Race{} among",
        "Jokers you {C:attention}buy{}.",
        "{C:inactive}(#3# unique races seen){}"
    },
    loc_vars = function(self, info_queue, card)
        local race_count = 0
        for _ in pairs(card.ability.extra.seen_races) do race_count = race_count + 1 end
        local effective_per = Warcraft.get_scaled_gain(card, card.ability.extra.x_chips_per_race, card.ability.extra.x_chips_per_race_per_level, card.ability.extra.x_chips_per_race_per_ilvl)
        return { card.ability.extra.x_chips, effective_per, race_count }
    end,
    calculate = function(self, card, context)
        if context.buying_card and not context.blueprint then
            local bought = context.card
            if not bought or not bought.ability or not bought.ability.extra then return end

            local races = bought.ability.extra.race
            if not races then return end
            if type(races) ~= "table" then races = {races} end

            local effective_per = Warcraft.get_scaled_gain(card, card.ability.extra.x_chips_per_race, card.ability.extra.x_chips_per_race_per_level, card.ability.extra.x_chips_per_race_per_ilvl)
            local new_races = false

            for _, race in ipairs(races) do
                if not card.ability.extra.seen_races[race] then
                    card.ability.extra.seen_races[race] = true
                    card.ability.extra.x_chips = card.ability.extra.x_chips + effective_per
                    new_races = true
                end
            end

            if new_races then
                return {
                    message = "New Friend!",
                    colour = G.C.GOLD,
                    card = card
                }
            end
        end

        if context.joker_main then
            if card.ability.extra.x_chips > 1 then
                return {
                    x_chips = card.ability.extra.x_chips,
                    message = "Menagerie!",
                    colour = G.C.GOLD,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Tamsin Roame",
    faction = {"Scourge"},
    race = {"Human", "Undead"},
    class = {"Warlock"},
    weapon = {"Staff"},
    damage = {"Shadow"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Cariel Roame","Bartender Bob", "Harth Stonebrew"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 6,
    index = 395,
    config = { extra = {
        target_joker_key = nil,
        target_start_level = nil,
        triggered_this_blind = false,
        bonus_levels = 1, bonus_levels_per_level = 0.2, bonus_levels_per_ilvl = 0.1
    } },
    loc_txt = {
        "At start of {C:attention}Blind{}, target",
        "your {C:attention}lowest level{} Joker.",
        "If it {C:attention}levels up{} before Blind ends,",
        "all other Jokers gain {C:attention}+#1#{} Level(s){}."
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.bonus_levels, card.ability.extra.bonus_levels_per_level, card.ability.extra.bonus_levels_per_ilvl) }
    end,
    calculate = function(self, card, context)
        -- Select lowest level joker at start of blind
        if context.setting_blind and not context.blueprint then
            card.ability.extra.triggered_this_blind = false
            card.ability.extra.target_joker_key = nil
            card.ability.extra.target_start_level = nil

            local lowest_level = math.huge
            local lowest_joker = nil
            for _, j in ipairs(G.jokers.cards) do
                if j ~= card and j.ability.extra and j.ability.extra.level then
                    if j.ability.extra.level < lowest_level then
                        lowest_level = j.ability.extra.level
                        lowest_joker = j
                    end
                end
            end

            if lowest_joker then
                card.ability.extra.target_joker_key = tostring(lowest_joker)
                card.ability.extra.target_start_level = lowest_level
                G.E_MANAGER:add_event(Event({
                    func = function()
                        card_eval_status_text(lowest_joker, 'extra', nil, nil, nil, {
                            message = "Targeted!",
                            colour = G.C.PURPLE
                        })
                        lowest_joker:juice_up()
                        return true
                    end
                }))
            end
        end

        -- Check if targeted joker leveled up
        if context.after and not context.blueprint and not card.ability.extra.triggered_this_blind then
            if not card.ability.extra.target_joker_key then return end

            -- Find the targeted joker
            local target = nil
            for _, j in ipairs(G.jokers.cards) do
                if tostring(j) == card.ability.extra.target_joker_key then
                    target = j
                    break
                end
            end

            if target and target.ability.extra and target.ability.extra.level then
                if target.ability.extra.level > card.ability.extra.target_start_level then
                    card.ability.extra.triggered_this_blind = true
                    local effective_bonus = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.bonus_levels, card.ability.extra.bonus_levels_per_level, card.ability.extra.bonus_levels_per_ilvl))

                    G.E_MANAGER:add_event(Event({
                        func = function()
                            for _, j in ipairs(G.jokers.cards) do
                                if j ~= card and j ~= target and j.ability.extra and j.ability.extra.level then
                                    j.ability.extra.level = (j.ability.extra.level or 1) + effective_bonus
                                    if j.ability.extra.max_level and j.ability.extra.level > j.ability.extra.max_level then
                                        j.ability.extra.max_level = j.ability.extra.level
                                    end
                                    card_eval_status_text(j, 'extra', nil, nil, nil, {
                                        message = "Empowered!",
                                        colour = G.C.PURPLE
                                    })
                                    j:juice_up()
                                end
                            end
                            return true
                        end
                    }))

                    return {
                        message = "Dark Ritual!",
                        colour = G.C.PURPLE,
                        card = card
                    }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "King Krush",
    faction = {"Horde"},
    race = {"Beast"},
    class = {"Hunter"},
    weapon = {"Fist"},
    damage = {"Physical"},
    armor = {"Mail"},
    profession = {},
    combo = {"Hemet Nesingwary", "Rezan", "Brann Bronzebeard"},
    role = {"Melee DPS"},
    rarity = 3,
    cost = 8,
    index = 396,
    config = { extra = { multiplier = 3, multiplier_per_level = 0.5, multiplier_per_ilvl = 0.3 } },
    loc_txt = {
        "The {C:attention}first scoring card{}",
        "scores {C:attention}#1#x{} its total {C:chips}Chips{}."
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.multiplier, card.ability.extra.multiplier_per_level, card.ability.extra.multiplier_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            if context.scoring_hand and context.other_card == context.scoring_hand[1] then
                local other = context.other_card
                -- Calculate total chips of this card
                local total_chips = other.base.nominal or 0
                if other.ability.perma_bonus then
                    total_chips = total_chips + other.ability.perma_bonus
                end
                if other.ability.bonus then
                    total_chips = total_chips + other.ability.bonus
                end
                if other.config.center.key == 'm_stone' then
                    total_chips = total_chips + 50
                end

                if total_chips > 0 then
                    local effective_mult = Warcraft.get_scaled_gain(card, card.ability.extra.multiplier, card.ability.extra.multiplier_per_level, card.ability.extra.multiplier_per_ilvl)
                    -- Add (multiplier - 1) times total chips as bonus on top of normal scoring
                    local bonus = math.floor(total_chips * (effective_mult - 1))
                    return {
                        chips = bonus,
                        card = context.other_card,
                        message = "CHARGE!",
                        colour = G.C.RED
                    }
                end
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Barnes",
    faction = {"Horde", "Alliance"},
    race = {"Human"},
    damage = {"Physical"},
    armor = {"Cloth"},
    profession = {},
    combo = {"Medivh","Khadgar","Moroes","The Curator"},
    role = {"Healer"},
    rarity = 2,
    cost = 6,
    index = 397,
    config = { extra = { count = 1, count_per_level = 0.2, count_per_ilvl = 0.1 } },
    loc_txt = {
        "At start of each {C:attention}Blind{},",
        "create a {C:dark_edition}Negative{} {C:red}Perishable{}",
        "copy of {C:attention}#1#{} random Joker(s).",
        "{C:inactive}(Destroyed at end of Blind){}"
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_perishable
        return { Warcraft.get_scaled_gain(card, card.ability.extra.count, card.ability.extra.count_per_level, card.ability.extra.count_per_ilvl) }
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            local effective_count = math.floor(Warcraft.get_scaled_gain(card, card.ability.extra.count, card.ability.extra.count_per_level, card.ability.extra.count_per_ilvl))

            -- Collect valid jokers to copy (exclude Barnes itself)
            local valid_jokers = {}
            for _, j in ipairs(G.jokers.cards) do
                if j ~= card then
                    table.insert(valid_jokers, j)
                end
            end

            if #valid_jokers > 0 then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        for i = 1, effective_count do
                            local target = pseudorandom_element(valid_jokers, pseudoseed('barnes_' .. i .. '_' .. G.GAME.round))
                            local copy = create_card('Joker', G.jokers, nil, nil, nil, nil, target.config.center.key, 'barnes')
                            -- Make negative
                            copy:set_edition({negative = true}, true)
                            -- Make perishable with 1 blind duration
                            copy:set_perishable(true)
                            if copy.ability.perish then
                                copy.ability.perish.countdown = 1
                                copy.ability.perish.dur = 1
                            end
                            copy:add_to_deck()
                            G.jokers:emplace(copy)
                            copy:start_materialize()
                        end
                        card_eval_status_text(card, 'extra', nil, nil, nil, {
                            message = "On Stage!",
                            colour = G.C.DARK_EDITION
                        })
                        return true
                    end
                }))

                return {
                    message = "Showtime!",
                    colour = G.C.DARK_EDITION,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_warcraft_joker({
    name = "Jin'do the Hexxer",
    faction = {"Horde"},
    race = {"Troll"},
    class = {"Warlock"},
    weapon = {"Staff"},
    damage = {"Shadow"},
    armor = {"Leather"},
    profession = {},
    combo = {"Hakkar the Soulflayer","Bloodlord Mandokir", "Zul'jin"},
    role = {"Ranged DPS"},
    rarity = 2,
    cost = 6,
    index = 398,
    config = { extra = {
        hexed_card = nil,
        x_mult = 2, x_mult_per_level = 0.3, x_mult_per_ilvl = 0.2
    } },
    loc_txt = {
        "At start of {C:attention}Blind{}, {C:red}Debuff{}",
        "a random card in hand.",
        "If it is played {C:attention}alone{},",
        "make it {C:dark_edition}Polychrome{}",
        "and give {X:mult,C:white} X#1# {} Mult."
    },
    loc_vars = function(self, info_queue, card)
        return { Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl) }
    end,
    calculate = function(self, card, context)
        -- Debuff a random card at start of blind
        if context.setting_blind and not context.blueprint then
            card.ability.extra.hexed_card = nil
            if G.hand and G.hand.cards and #G.hand.cards > 0 then
                local target = pseudorandom_element(G.hand.cards, pseudoseed('jindo_' .. G.GAME.round))
                card.ability.extra.hexed_card = tostring(target)
                G.E_MANAGER:add_event(Event({
                    func = function()
                        target.ability.jindo_hexed = true
                        target:set_debuff(true)
                        target:juice_up()
                        card_eval_status_text(card, 'extra', nil, nil, nil, {
                            message = "Hexed!",
                            colour = G.C.PURPLE
                        })
                        return true
                    end
                }))
            end
        end

        -- Check if hexed card is played alone
        if context.before and not context.blueprint then
            if #context.full_hand == 1 then
                local played = context.full_hand[1]
                if played.ability and played.ability.jindo_hexed then
                    -- Undbuff and make polychrome
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            played:set_debuff(false)
                            played.ability.jindo_hexed = nil
                            card.ability.extra.hexed_card = nil
                            played:set_edition({polychrome = true}, true)
                            played:juice_up()
                            card_eval_status_text(card, 'extra', nil, nil, nil, {
                                message = "Voodoo!",
                                colour = G.C.DARK_EDITION
                            })
                            return true
                        end
                    }))
                    return {
                        x_mult = Warcraft.get_scaled_gain(card, card.ability.extra.x_mult, card.ability.extra.x_mult_per_level, card.ability.extra.x_mult_per_ilvl),
                        message = "Juju!",
                        colour = G.C.PURPLE,
                        card = card
                    }
                end
            end
        end

        -- Clean up at end of blind if hex was never triggered
        if context.end_of_round and not context.repetition and not context.individual and not context.blueprint then
            if G.playing_cards then
                for _, c in ipairs(G.playing_cards) do
                    if c.ability and c.ability.jindo_hexed then
                        c:set_debuff(false)
                        c.ability.jindo_hexed = nil
                    end
                end
            end
            card.ability.extra.hexed_card = nil
        end
    end
})

sendDebugMessage("Azeroth Balatro Mod : Generating all Jokers done!")