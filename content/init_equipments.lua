sendDebugMessage("Azeroth Balatro Mod : Generating all Equipments...")
Warcraft.create_equipment({
    name = "Thunderfury",
    index = 1, 
    
    loc_text = {
        "Scored {C:attention}10s{} give {C:chips}#1#%{} of",
        "their Chips as extra {C:chips}Chips{}"
    },
    
    req_level = 6, 
    req_class = {"Warrior", "Rogue", "Paladin", "Hunter", "Death Knight"}, 
    req_race = {"Elemental"},
    req_weapon = {"Sword"},
    combo_joker = {"Baron Geddon", "Garr", "Al'Akir the Windlord"},

    config = { extra = { base_pct = 40, scale_pct = 10 } },

    calculate_stats = function(ilvl, extra)
        local current_pct = extra.base_pct + ((ilvl - 1) * extra.scale_pct)
        return { current_pct } 
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local total_extra_chips = 0
            local current_pct = stats[1] 
            local pct_multiplier = current_pct / 100

            if context.scoring_hand then
                for _, played_card in ipairs(context.scoring_hand) do
                    if played_card:get_id() == 10 then
                        local base_chips = played_card.base.nominal or 0
                        local bonus_chips = (played_card:get_chip_bonus() or 0) - base_chips
                        local total_card_chips = base_chips + bonus_chips
                        
                        total_extra_chips = total_extra_chips + math.floor(total_card_chips * pct_multiplier)
                    end
                end
            end

            if total_extra_chips > 0 then
                return {
                    chips = total_extra_chips,
                    message = "Thunderfury!"
                }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Frostmourne",
    index = 2, 
    
    config = { extra = { base_mult = 5, scale_mult = 5 } },
    
    loc_text = {
        "If attached to a {C:dark_edition}Scourge{} Joker,",
        "gives {C:mult}+#1#{} Mult."
    },
    
    req_level = 5, 
    req_class = {"Death Knight"},
    req_race = {"Undead", "Nathrezim"},
    req_faction = {"Scourge"},
    req_weapon = {"Sword"},
    combo_joker = {"Arthas Menethil", "Ner'zhul", "Zovaal"}, 

    calculate_stats = function(ilvl, extra)
        -- Math: base + (ilvl-1) * scale
        local current_mult = extra.base_mult + ((ilvl - 1) * extra.scale_mult)
        return { current_mult } 
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.joker_main then
            -- Safely access the Joker's extra data (the "Race" info)
            -- Note: Using 'faction' as per your Warcraft.create_warcraft_joker definition
            local faction = (card.ability.extra and card.ability.extra.faction) or "Unknown"
            
            -- Check if faction is a table (list) or single string
            local is_scourge = false
            if type(faction) == "table" then
                for _, f in ipairs(faction) do if f == "Scourge" then is_scourge = true end end
            elseif faction == "Scourge" then
                is_scourge = true
            end
            
            if is_scourge then
                return {
                    mult = stats[1],
                    message = "Soul Harvest!"
                }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Sulfuras, Hand of Ragnaros",
    index = 3, 
    
    loc_text = {
        "Scored {C:hearts}Hearts{} add {C:attention}#1#%{} of",
        "their Chips to {C:mult}Mult{}"
    },

    req_level = 6, 
    req_class = {"Shaman", "Warrior", "Paladin", "Death Knight", "Druid"},
    req_race = {"Elemental"},
    req_weapon = {"Hammer"},
    combo_joker = {"Ragnaros"},

    config = { extra = { base_pct = 40, scale_pct = 10 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_pct + ((ilvl - 1) * extra.scale_pct) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            
            if played_card:is_suit("Hearts") then
                local pct_multiplier = stats[1] / 100
                
                local total_card_chips = (played_card.base.nominal or 0) + (played_card:get_chip_bonus() or 0)
                local extra_mult = math.floor(total_card_chips * pct_multiplier)

                if extra_mult > 0 then
                    return {
                        mult = extra_mult,
                        message = "By Fire Be Purged!",
                        colour = G.C.MULT
                    }
                end
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Warglaives of Azzinoth",
    index = 4, 
    
    loc_text = {
        "Scored {C:attention}5s{} gain permanent",
        "{C:chips}+#1#{} Chips when scored."
    },

    req_level = 6, 
    req_class = {"Rogue", "Warrior", "Demon Hunter", "Death Knight", "Monk"},
    req_race = {"Demon", "Night Elf"},
    req_weapon = {"Glaives", "Daggers"},
    combo_joker = {"Illidan Stormrage", "Akama"},

    config = { extra = { base_chips = 10, scale_chips = 5 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_chips + ((ilvl - 1) * extra.scale_chips) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            
            if played_card:get_id() == 5 then
                local bonus_chips = stats[1]
                
                played_card.ability.perma_bonus = (played_card.ability.perma_bonus or 0) + bonus_chips
                
                return {
                    message = "Upgraded!",
                    colour = G.C.CHIPS
                }
            end
        end
    end,
})

Warcraft.create_equipment({
    name = "Atiesh",
    index = 5, 
    
    loc_text = {
        "{C:green}#1#% chance{} to generate a",
        "random {C:planet}Planet{} card when a",
        "{C:attention}King{} or {C:attention}Queen{} scores."
    },

    req_level = 6, 
    req_class = {"Mage", "Priest", "Warlock", "Druid"}, 
    req_race = {"Human", "Nathrezim"},
    req_weapon = {"Staff"},
    combo_joker = {"Medivh", "Khadgar", "Kel'Thuzad"},

    config = { extra = { base_chance = 20, scale_chance = 5 } },

    calculate_stats = function(ilvl, extra)
        return { math.min(100, extra.base_chance + ((ilvl - 1) * extra.scale_chance)) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            local id = played_card:get_id()
            
            if id == 12 or id == 13 then 
                if pseudorandom("atiesh") < (stats[1] / 100) then
                    
                    if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                        G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                        
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                local _card = create_card('Planet', G.consumeables, nil, nil, nil, nil, nil, 'atiesh_gen')
                                _card:add_to_deck()
                                G.consumeables:emplace(_card)
                                G.GAME.consumeable_buffer = 0
                                return true
                            end
                        }))
                        
                        return {
                            message = "Arcane Power!",
                            colour = G.C.PURPLE
                        }
                    end
                end
            end
        end
    end,
})

Warcraft.create_equipment({
    name = "Dragonwrath, Tarecgosa's Rest",
    index = 6, 
    
    loc_text = {
        "Scored {C:attention}Queens{} gain permanent",
        "{C:chips}+#1#{} Chips when scored."
    },

    req_level = 6, 
    req_class = {"Mage", "Warlock", "Priest", "Druid", "Shaman"},
    req_race = {"Dragon"},
    req_weapon = {"Staff"},
    combo_joker = {"Tarecgosa", "Kalecgos"},

    calculate_stats = function(ilvl)
        
        return 20 + (5 * ilvl)
    end,

    on_score = function(ilvl, context, card)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            
            
            if played_card:get_id() == 12 then
                local bonus_chips = 20 + (5 * ilvl)
                
                
                played_card.ability.perma_bonus = played_card.ability.perma_bonus or 0
                played_card.ability.perma_bonus = played_card.ability.perma_bonus + bonus_chips
                
                return {
                    message = "Tarecgosa's Wrath!",
                    colour = G.C.CHIPS
                }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Shadowmourne",
    index = 7, 
    
    loc_text = {
        "Scored {C:attention}Stone Cards{} give {C:chips}#1#%{} of",
        "their Chips as extra {C:chips}Chips{}"
    },

    req_level = 6, 
    req_class = {"Death Knight", "Warrior", "Paladin"},
    req_race = {"Human","Dwarf"},
    req_weapon = {"Axe"},
    combo_joker = {"Darion Mograine", "Arthas Menethil", "Tirion Fordring"},

    config = { extra = { base_chips = 20, scale_chips = 5 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_chips + ((ilvl - 1) * extra.scale_chips) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            
            if played_card:get_id() == 12 then
                local bonus_chips = stats[1]
                
                played_card.ability.perma_bonus = (played_card.ability.perma_bonus or 0) + bonus_chips
                
                return {
                    message = "Tarecgosa's Wrath!",
                    colour = G.C.CHIPS
                }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Val'anyr, Hammer of Ancient Kings",
    index = 8, 
    
    loc_text = {
        "Scored {C:attention}Gold Cards{} gain permanent",
        "{C:chips}+#1#{} Chips when scored."
    },

    req_level = 6, 
    req_class = {"Paladin", "Priest", "Shaman", "Druid", "Monk"},
    req_race = {"Titan"},
    req_weapon = {"Hammer"},
    combo_joker = {"Yogg-Saron","Loken","Thorim"},

    config = { extra = { base_chips = 25, scale_chips = 5 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_chips + ((ilvl - 1) * extra.scale_chips) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            
            if played_card.config.center.key == 'm_gold' then
                local bonus_chips = stats[1]
                
                played_card.ability.perma_bonus = (played_card.ability.perma_bonus or 0) + bonus_chips
                
                return {
                    message = "Ancient Blessing!",
                    colour = G.C.CHIPS
                }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Thori'dal, the Stars' Fury",
    index = 9, 
    
    loc_text = {
        "{C:green}#1#% chance{} to convert a",
        "scored card into a {C:attention}Lucky Card{}."
    },

    req_level = 6, 
    req_class = {"Hunter", "Warrior", "Rogue"}, 
    req_weapon = {"Bow"},
    combo_joker = {"Sylvanas Windrunner", "Alleria Windrunner", "Kil'Jaeden"},

    config = { extra = { base_chance = 10, scale_chance = 5 } },

    calculate_stats = function(ilvl, extra)
        return { math.min(100, extra.base_chance + ((ilvl - 1) * extra.scale_chance)) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            
            if played_card.config.center.key ~= 'm_lucky' then
                if pseudorandom("thoridal") < (stats[1] / 100) then
                    
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            played_card:set_ability(G.P_CENTERS.m_lucky, nil, true)
                            played_card:juice_up()
                            return true
                        end
                    }))
                    
                    return {
                        message = "Stars' Fury!",
                        colour = G.C.GREEN
                    }
                end
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Rae'shalare, Death's Whisper",
    index = 10, 
    
    loc_text = {
        "{C:green}#1#% chance{} to generate a",
        "random {C:dark_edition}Scourge{} Joker",
        "when this Joker triggers."
    },

    req_level = 6, 
    req_class = {"Hunter"}, 
    req_weapon = {"Bow"},
    combo_joker = {"Sylvanas Windrunner"},

    config = { extra = { base_chance = 10, scale_chance = 5 } },

    calculate_stats = function(ilvl, extra)
        return { math.min(100, extra.base_chance + ((ilvl - 1) * extra.scale_chance)) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.joker_main then
            if pseudorandom("raeshalare") < (stats[1] / 100) then
                
                if #G.jokers.cards < G.jokers.config.card_limit then
                    
                    local scourge_pool = {}
                    for k, v in pairs(G.P_CENTERS) do
                        -- Updated to be safer with config access
                        local j_extra = (v.config and v.config.extra) or {}
                        if v.set == "Joker" and v.is_warcraft and j_extra.race == "Scourge" then
                            table.insert(scourge_pool, k)
                        end
                    end
                    
                    if #scourge_pool > 0 then
                        local chosen_joker = pseudorandom_element(scourge_pool, pseudoseed("rae_gen"))
                        
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                local new_joker = create_card('Joker', G.jokers, nil, nil, nil, nil, chosen_joker)
                                new_joker:add_to_deck()
                                G.jokers:emplace(new_joker)
                                return true
                            end
                        }))
                        
                        return {
                            message = "Death's Whisper!",
                            colour = G.C.DARK_EDITION
                        }
                    end
                end
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Nasz'uro, the Unbound Legacy",
    index = 11, 
    
    loc_text = {
        "Scored {C:attention}Even Numbers{} gain permanent",
        "{C:chips}+#1#{} Chips when scored."
    },

    req_level = 6, 
    req_class = {"Evoker"}, 
    req_race = {"Dragon"},
    req_weapon = {"Fist Weapon"},
    combo_joker = {"Sarkareth", "Emberthal","Neltharion"},

    config = { extra = { base_chips = 15, scale_chips = 5 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_chips + ((ilvl - 1) * extra.scale_chips) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            local id = played_card:get_id()
            
            -- Checked rank 2 to 10 and even ID
            if id >= 2 and id <= 10 and id % 2 == 0 then
                local bonus_chips = stats[1]
                
                played_card.ability.perma_bonus = (played_card.ability.perma_bonus or 0) + bonus_chips
                
                return {
                    message = "Unbound!",
                    colour = G.C.CHIPS
                }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Fangs of the Father",
    index = 12, 
    
    loc_text = {
        "Scored {C:attention}2s{} gain permanent",
        "{C:mult}+#1#{} Mult when scored."
    },

    req_level = 6, 
    req_class = {"Rogue"},
    req_weapon = {"Daggers"},
    combo_joker = {"Wrathion", "Neltharion"},

    config = { extra = { base_mult = 2, scale_mult = 2 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_mult + ((ilvl - 1) * extra.scale_mult) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            
            if played_card:get_id() == 2 then
                local bonus_mult = stats[1]
                
                played_card.ability.perma_mult = (played_card.ability.perma_mult or 0) + bonus_mult
                
                return {
                    message = "Assassinate!",
                    colour = G.C.MULT
                }
            end
        end
    end,
})

Warcraft.create_equipment({
    name = "Ashjra'kamas, Shroud of Resolve",
    index = 13, 
    
    loc_text = {
        "{C:green}#1#% chance{} to generate a",
        "random {C:tarot}Tarot{} card",
        "when this Joker triggers."
    },

    req_level = 6, 
    combo_joker = {"Wrathion", "N'Zoth"},

    config = { extra = { base_chance = 5, scale_chance = 5 } },

    calculate_stats = function(ilvl, extra)
        return { math.min(100, extra.base_chance + ((ilvl - 1) * extra.scale_chance)) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.joker_main and card.ability.triggered_this_hand then
            if pseudorandom("ashjrakamas") < (stats[1] / 100) then
                if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                    G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                    
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            local _card = create_card('Tarot', G.consumeables, nil, nil, nil, nil, nil, 'ashjrakamas_gen')
                            _card:add_to_deck()
                            G.consumeables:emplace(_card)
                            G.GAME.consumeable_buffer = 0
                            return true
                        end
                    }))
                    
                    return {
                        message = "Draconic Resolve!",
                        colour = G.C.PURPLE
                    }
                end
            end
        end
    end,
})

Warcraft.create_equipment({
    name = "Maw of the Damned",
    index = 14, 
    
    loc_text = {
        "Scored {C:attention}Aces{} gain permanent",
        "{C:chips}+#1#{} Chips when scored."
    },

    req_level = 6, 
    req_class = {"Death Knight"},
    req_race = {"Demon"},
    req_weapon = {"Axe"},
    combo_joker = {"Teron Gorefiend"},

    config = { extra = { base_chips = 10, scale_chips = 5 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_chips + ((ilvl - 1) * extra.scale_chips) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            
            if played_card:get_id() == 14 then
                local bonus_chips = stats[1]
                
                played_card.ability.perma_bonus = (played_card.ability.perma_bonus or 0) + bonus_chips
                
                return {
                    message = "Feast of Souls!",
                    colour = G.C.CHIPS
                }
            end
        end
    end,
})

Warcraft.create_equipment({
    name = "Blades of the Fallen Prince",
    index = 15, 
    
    loc_text = {
        "Scored {C:attention}Glass Cards{} give {C:chips}#1#%{} of",
        "their Chips as extra {C:chips}Chips{}"
    },

    req_level = 6, 
    req_class = {"Death Knight"},
    req_weapon = {"Sword"},
    combo_joker = {"Arthas Menethil", "Bolvar Fordragon", "Ner'zhul"},

    config = { extra = { base_pct = 40, scale_pct = 10 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_pct + ((ilvl - 1) * extra.scale_pct) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            
            if played_card.config.center.key == 'm_glass' then
                local pct_multiplier = stats[1] / 100
                
                local base_chips = played_card.base.nominal or 0
                local bonus_chips = played_card:get_chip_bonus() or 0
                local total_card_chips = base_chips + bonus_chips
                
                local extra_chips = math.floor(total_card_chips * pct_multiplier)

                if extra_chips > 0 then
                    return {
                        chips = extra_chips,
                        message = "Shatter!",
                        colour = G.C.CHIPS
                    }
                end
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Apocalypse",
    index = 16, 
    
    loc_text = {
        "Scored {C:attention}Stone Cards{} gain permanent",
        "{C:mult}+#1#{} Mult when scored."
    },

    req_level = 6, 
    req_class = {"Death Knight"},
    req_weapon = {"Sword"},
    combo_joker = {"Medivh"},

    config = { extra = { base_mult = 4, scale_mult = 2 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_mult + ((ilvl - 1) * extra.scale_mult) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            
            if played_card.config.center.key == 'm_stone' then
                local bonus_mult = stats[1]
                
                played_card.ability.perma_mult = (played_card.ability.perma_mult or 0) + bonus_mult
                
                return {
                    message = "Apocalyptic!",
                    colour = G.C.MULT
                }
            end
        end
    end,
})

Warcraft.create_equipment({
    name = "Twinblades of the Deceiver",
    index = 17, 
    
    loc_text = {
        "Scored {C:attention}Lucky Cards{} gain permanent",
        "{C:chips}+#1#{} Chips when scored."
    },

    req_level = 6, 
    req_class = {"Demon Hunter"},
    req_race = {"Demon"},
    req_weapon = {"Glaives"},
    combo_joker = {"Kil'Jaeden", "Illidan Stormrage"},

    config = { extra = { base_chips = 20, scale_chips = 5 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_chips + ((ilvl - 1) * extra.scale_chips) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            
            if played_card.config.center.key == 'm_lucky' then
                local bonus_chips = stats[1]
                
                played_card.ability.perma_bonus = (played_card.ability.perma_bonus or 0) + bonus_chips
                
                return {
                    message = "Deceiver's Strike!",
                    colour = G.C.CHIPS
                }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Aldrachi Warblades",
    index = 18, 
    
    loc_text = {
        "{C:green}#1#% chance{} to permanently add",
        "{C:chips}+#2#{} Chips to the Joker to the right",
        "when this Joker triggers."
    },

    req_level = 6, 
    req_class = {"Demon Hunter"},
    req_weapon = {"Glaives"},
    combo_joker = {"Sargeras"},

    config = { extra = { chance = 25, base_bonus = 60, scale_bonus = 20 } },

    calculate_stats = function(ilvl, extra)
        return { extra.chance, extra.base_bonus + ((ilvl - 1) * extra.scale_bonus) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        -- stats[1] is chance, stats[2] is the bonus chips
        if context.joker_main and card.ability.triggered_this_hand then
            if pseudorandom("aldrachi") < (stats[1] / 100) then
                
                local my_pos = nil
                for i = 1, #G.jokers.cards do
                    if G.jokers.cards[i] == card then
                        my_pos = i
                        break
                    end
                end
                
                if my_pos and G.jokers.cards[my_pos + 1] then
                    local right_joker = G.jokers.cards[my_pos + 1]
                    local bonus_chips = stats[2]
                    
                    right_joker.ability.wow_bonus_chips = (right_joker.ability.wow_bonus_chips or 0) + bonus_chips
                    
                    right_joker:juice_up()
                    card_eval_status_text(right_joker, 'extra', nil, nil, nil, {
                        message = "+" .. bonus_chips .. " Chips!",
                        colour = G.C.CHIPS
                    })
                    
                    return {
                        message = "Soul Cleave!",
                        colour = G.C.GREEN
                    }
                end
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Scythe of Elune",
    index = 19, 
    
    loc_text = {
        "{C:green}#1#% chance{} to convert a",
        "scored card into a {C:attention}Wild Card{}."
    },

    req_level = 6, 
    req_class = {"Druid"},
    req_race = {"Night Elf", "Worgen"},
    req_weapon = {"Staff"},
    combo_joker = {"Elune", "Goldrinn", "Archmage Arugal"},

    config = { extra = { base_chance = 15, scale_chance = 5 } },

    calculate_stats = function(ilvl, extra)
        return { math.min(100, extra.base_chance + ((ilvl - 1) * extra.scale_chance)) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play and card.ability.triggered_this_hand then
            local played_card = context.other_card
            
            if played_card.config.center.key ~= 'm_wild' then
                if pseudorandom("elune") < (stats[1] / 100) then
                    
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            played_card:set_ability(G.P_CENTERS.m_wild, nil, true)
                            played_card:juice_up()
                            return true
                        end
                    }))
                    
                    return {
                        message = "Elune's Light!",
                        colour = G.C.GREEN
                    }
                end
            end
        end
    end,
})

Warcraft.create_equipment({
    name = "Fangs of Ashamane",
    index = 20, 
    
    loc_text = {
        "Scored {C:attention}Wild Cards{} add {C:attention}#1#%{} of",
        "their Chips to {C:mult}Mult{}"
    },

    req_level = 6, 
    req_class = {"Druid"}, 
    req_race = {"Night Elf","Troll"},
    req_weapon = {"Daggers"},
    combo_joker = {"Ashamane", "Xavius"},

    config = { extra = { base_pct = 20, scale_pct = 10 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_pct + ((ilvl - 1) * extra.scale_pct) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play and card.ability.triggered_this_hand then
            local played_card = context.other_card
            
            if played_card.config.center.key == 'm_wild' then
                local pct_multiplier = stats[1] / 100
                
                local total_card_chips = (played_card.base.nominal or 0) + (played_card:get_chip_bonus() or 0)
                local extra_mult = math.floor(total_card_chips * pct_multiplier)

                if extra_mult > 0 then
                    return {
                        mult = extra_mult,
                        message = "Feral Instinct!",
                        colour = G.C.MULT
                    }
                end
            end
        end
    end,
})

Warcraft.create_equipment({
    name = "Claws of Ursoc",
    index = 21, 
    
    loc_text = {
        "{C:green}#1#% chance{} to convert a scored",
        "{C:diamonds}Diamond{} into a {C:attention}Stone Card{}."
    },

    req_level = 6, 
    req_class = {"Druid"},
    req_race = {"Furbolg", "Titan"},
    req_weapon = {"Fist Weapon"},
    combo_joker = {"Ursoc", "Freya", "Hamuul Runetotem"},

    config = { extra = { base_chance = 25, scale_chance = 5 } },

    calculate_stats = function(ilvl, extra)
        return { math.min(100, extra.base_chance + ((ilvl - 1) * extra.scale_chance)) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play and card.ability.triggered_this_hand then
            local played_card = context.other_card
            
            if played_card:is_suit("Diamonds") and played_card.config.center.key ~= 'm_stone' then
                if pseudorandom("ursoc") < (stats[1] / 100) then
                    
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            played_card:set_ability(G.P_CENTERS.m_stone, nil, true)
                            played_card:juice_up()
                            return true
                        end
                    }))
                    
                    return {
                        message = "Ursoc's Might!",
                        colour = G.C.GREEN
                    }
                end
            end
        end
    end,
})

Warcraft.create_equipment({
    name = "G'Hanir, the Mother Tree",
    index = 22, 
    
    loc_text = {
        "Scored {C:clubs}Clubs{} have a {C:green}#1#% chance{}",
        "to upgrade a random {C:attention}Poker Hand{}."
    },

    req_level = 6, 
    req_class = {"Druid"},
    req_race = {"Dragon", "Night Elf"},
    req_weapon = {"Staff"},
    combo_joker = {"Aviana", "Ysera"},

    config = { extra = { base_chance = 20, scale_chance = 5 } },

    calculate_stats = function(ilvl, extra)
        return { math.min(100, extra.base_chance + ((ilvl - 1) * extra.scale_chance)) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play and card.ability.triggered_this_hand then
            local played_card = context.other_card
            
            if played_card:is_suit("Clubs") then
                if pseudorandom("ghanir") < (stats[1] / 100) then
                    
                    local hand_to_upgrade = pseudorandom_element(G.handlist, pseudoseed("ghanir_upg"))
                    
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.2,
                        func = function()
                            level_up_hand(card, hand_to_upgrade, false, 1)
                            return true
                        end
                    }))
                    
                    return {
                        message = "Growth!",
                        colour = G.C.GREEN
                    }
                end
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Titanstrike",
    index = 23, 
    
    loc_text = {
        "Scored {C:attention}Wild Cards{} gain permanent",
        "{C:mult}+#1#{} Mult when scored."
    },

    req_level = 6, 
    req_class = {"Hunter"},
    req_race = {"Human","Dwarf"},
    req_weapon = {"Gun"},
    combo_joker = {"Mimiron","Thorim","Brann Bronzebeard"},

    config = { extra = { base_mult = 2, scale_mult = 2 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_mult + ((ilvl - 1) * extra.scale_mult) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play and card.ability.triggered_this_hand then
            local played_card = context.other_card
            
            if played_card.config.center.key == 'm_wild' then
                local bonus_mult = stats[1]
                
                played_card.ability.perma_mult = (played_card.ability.perma_mult or 0) + bonus_mult
                
                return {
                    message = "Titan's Roar!",
                    colour = G.C.MULT
                }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Thas'dorah, Legacy of the Windrunners",
    index = 24, 
    
    loc_text = {
        "Scored {C:spades}Spades{} have a {C:green}#1#% chance{}",
        "to set the Joker to the right",
        "to {C:dark_edition}Holographic{} edition."
    },

    req_level = 6, 
    req_class = {"Hunter", "Ranger"},
    req_race = {"Blood Elf","Void Elf"},
    req_weapon = {"Bow"},
    combo_joker = {"Alleria Windrunner", "Sylvanas Windrunner", "Vereesa Windrunner"},

    config = { extra = { base_chance = 15, scale_chance = 5 } },

    calculate_stats = function(ilvl, extra)
        return { math.min(100, extra.base_chance + ((ilvl - 1) * extra.scale_chance)) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play and card.ability.triggered_this_hand then
            local played_card = context.other_card
            
            if played_card:is_suit('Spades') then
                if pseudorandom("thasdorah") < (stats[1] / 100) then
                    
                    local my_pos = nil
                    for i = 1, #G.jokers.cards do
                        if G.jokers.cards[i] == card then
                            my_pos = i
                            break
                        end
                    end
                    
                    if my_pos and G.jokers.cards[my_pos + 1] then
                        local right_joker = G.jokers.cards[my_pos + 1]
                        
                        if not right_joker.edition then
                            G.E_MANAGER:add_event(Event({
                                func = function()
                                    right_joker:set_edition({holo = true}, true)
                                    return true
                                end
                            }))
                            
                            return {
                                message = "Windrunner's Aim!",
                                colour = G.C.DARK_EDITION
                            }
                        end
                    end
                end
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Talonclaw",
    index = 25, 
    
    loc_text = {
        "Scored {C:attention}Odd Numbers{} gain permanent",
        "{C:chips}+#1#{} Chips when scored."
    },

    req_level = 6, 
    req_class = {"Hunter"},
    req_race = {"Tauren"},
    req_weapon = {"Polearm","Spear"},
    combo_joker = {"Huln Highmountain"},

    config = { extra = { base_chips = 10, scale_chips = 5 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_chips + ((ilvl - 1) * extra.scale_chips) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play and card.ability.triggered_this_hand then
            local played_card = context.other_card
            local id = played_card:get_id()
            
            -- Checked rank 3 to 9 and odd ID
            if id >= 3 and id <= 9 and id % 2 ~= 0 then
                local bonus_chips = stats[1]
                
                played_card.ability.perma_bonus = (played_card.ability.perma_bonus or 0) + bonus_chips
                
                return {
                    message = "Eagle's Strike!",
                    colour = G.C.CHIPS
                }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Aluneth",
    index = 26, 
    
    loc_text = {
        "{C:green}#1#% chance{} to turn a random held",
        "Consumable into a {C:dark_edition}Negative{} version",
        "when a card with a {C:purple}Purple Seal{} scores."
    },

    req_level = 6, 
    req_class = {"Mage"},
    req_weapon = {"Staff"},
    req_race = {"Human"},
    combo_joker = {"Aegwynn", "Malygos"},

    config = { extra = { base_chance = 6, scale_chance = 2 } },

    calculate_stats = function(ilvl, extra)
        return { math.min(100, extra.base_chance + ((ilvl - 1) * extra.scale_chance)) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        -- Using card.ability.triggered_this_hand flag for design consistency
        if context.individual and context.cardarea == G.play and card.ability.triggered_this_hand then
            local played_card = context.other_card
            
            if played_card:get_seal() == 'Purple' then
                
                if pseudorandom("aluneth") < (stats[1] / 100) then
                    
                    if G.consumeables and #G.consumeables.cards > 0 then
                        
                        local valid_consumables = {}
                        for _, cons in ipairs(G.consumeables.cards) do
                            if not cons.edition or not cons.edition.negative then
                                table.insert(valid_consumables, cons)
                            end
                        end
                        
                        if #valid_consumables > 0 then
                            local target_consumable = pseudorandom_element(valid_consumables, pseudoseed("aluneth_neg"))
                            
                            G.E_MANAGER:add_event(Event({
                                func = function()
                                    target_consumable:set_edition({negative = true}, true)
                                    return true
                                end
                            }))
                            
                            return {
                                message = "Infinite Power!",
                                colour = G.C.DARK_EDITION
                            }
                        end
                    end
                end
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Felo'melorn",
    index = 27, 
    
    loc_text = {
        "{C:green}#1#% chance{} to convert a",
        "scored card into a {C:attention}Glass Card{}."
    },

    req_level = 6, 
    req_class = {"Mage"},
    req_weapon = {"Sword"},
    req_race = {"Blood Elf"},
    combo_joker = {"Kael'thas Sunstrider"},

    config = { extra = { base_chance = 10, scale_chance = 5 } },

    calculate_stats = function(ilvl, extra)
        return { math.min(100, extra.base_chance + ((ilvl - 1) * extra.scale_chance)) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play and card.ability.triggered_this_hand then
            local played_card = context.other_card
            
            if played_card.config.center.key ~= 'm_glass' then
                if pseudorandom("felomelorn") < (stats[1] / 100) then
                    
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            played_card:set_ability(G.P_CENTERS.m_glass, nil, true)
                            played_card:juice_up()
                            return true
                        end
                    }))
                    
                    return {
                        message = "Flamestrike!",
                        colour = G.C.RED
                    }
                end
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Ebonchill",
    index = 28, 
    
    loc_text = {
        "Scored {C:attention}Glass Cards{} gain permanent",
        "{C:chips}+#1#{} Chips when scored."
    },

    req_level = 6, 
    req_class = {"Mage"},
    req_race = {"Human", "Nathrezim"},
    req_weapon = {"Staff"},
    combo_joker = {"Jaina Proudmoore"},

    config = { extra = { base_chips = 20, scale_chips = 5 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_chips + ((ilvl - 1) * extra.scale_chips) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play and card.ability.triggered_this_hand then
            local played_card = context.other_card
            
            if played_card.config.center.key == 'm_glass' then
                local bonus_chips = stats[1]
                
                played_card.ability.perma_bonus = (played_card.ability.perma_bonus or 0) + bonus_chips
                
                return {
                    message = "Glacial Spike!",
                    colour = G.C.CHIPS
                }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Fu Zan, the Wanderer's Companion",
    index = 29, 
    
    loc_text = {
        "Scored {C:attention}Lucky Cards{} give {C:chips}#1#%{} of",
        "their Chips as extra {C:chips}Chips{}"
    },

    req_level = 6, 
    req_class = {"Monk"},
    req_weapon = {"Staff"},
    req_race = {"Pandaren"},
    combo_joker = {"Yu'lon", "Chen Stormstout"},

    config = { extra = { base_pct = 80, scale_pct = 20 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_pct + ((ilvl - 1) * extra.scale_pct) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play and card.ability.triggered_this_hand then
            local played_card = context.other_card
            
            if played_card.config.center.key == 'm_lucky' then
                local pct_multiplier = stats[1] / 100
                
                local total_card_chips = (played_card.base.nominal or 0) + (played_card:get_chip_bonus() or 0)
                local extra_chips = math.floor(total_card_chips * pct_multiplier)

                if extra_chips > 0 then
                    return {
                        chips = extra_chips,
                        message = "Brewmaster!",
                        colour = G.C.CHIPS
                    }
                end
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Sheilun, Staff of the Mists",
    index = 30, 
    
    loc_text = {
        "Scored {C:attention}Lucky Cards{} gain permanent",
        "{C:mult}+#1#{} Mult when scored."
    },

    req_level = 6, 
    req_class = {"Monk"},
    req_weapon = {"Staff"},
    req_race = {"Pandaren"},
    combo_joker = {"Emperor Shaohao", "Taran Zhu"},

    config = { extra = { base_mult = 2, scale_mult = 1 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_mult + ((ilvl - 1) * extra.scale_mult) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play and card.ability.triggered_this_hand then
            local played_card = context.other_card
            
            if played_card.config.center.key == 'm_lucky' then
                local bonus_mult = stats[1]
                
                played_card.ability.perma_mult = (played_card.ability.perma_mult or 0) + bonus_mult
                
                return {
                    message = "Mistweaver!",
                    colour = G.C.MULT
                }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Fists of the Heavens",
    index = 31, 
    
    loc_text = {
        "Played {C:attention}6s{} give {C:mult}+#1#{} Mult",
        "when scored within a {C:attention}Pair{}."
    },

    req_level = 6, 
    req_class = {"Monk"}, 
    req_weapon = {"Fist Weapons"},
    req_race = {"Elemental"},
    combo_joker = {"Al'Akir the Windlord", "Li Li Stormstout"},

    config = { extra = { base_mult = 10, scale_mult = 5 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_mult + ((ilvl - 1) * extra.scale_mult) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play and card.ability.triggered_this_hand then
            
            if context.scoring_name == "Pair" then
                local played_card = context.other_card
                
                if played_card:get_id() == 6 then
                    return {
                        mult = stats[1],
                        message = "Windwalker!",
                        colour = G.C.MULT
                    }
                end
            end
        end
    end
})

Warcraft.create_equipment({
    name = "The Silver Hand",
    index = 32, 
    
    loc_text = {
        "Scored {C:attention}Gold Cards{} give",
        "{C:mult}+#1#{} Mult."
    },

    req_level = 6, 
    req_class = {"Paladin"}, 
    req_weapon = {"Hammer"},
    req_race = {"Human","Titan"},
    combo_joker = {"Tyr"},

    config = { extra = { base_mult = 6, scale_mult = 2 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_mult + ((ilvl - 1) * extra.scale_mult) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play and card.ability.triggered_this_hand then
            local played_card = context.other_card
            
            if played_card.config.center.key == 'm_gold' then
                return {
                    mult = stats[1],
                    message = "Holy Light!",
                    colour = G.C.MULT
                }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Truthguard",
    index = 33, 
    
    loc_text = {
        "Scored {C:attention}4s{} give {C:chips}+#1#{} Chips",
        "for each {C:diamonds}Diamond{} in your full deck."
    },

    req_level = 6, 
    req_class = {"Paladin"}, 
    req_weapon = {"Shield"},
    req_race = {"Titan"},
    combo_joker = {"Tyr", "Odyn"},

    config = { extra = { base_chips = 15, scale_chips = 5 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_chips + ((ilvl - 1) * extra.scale_chips) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play and card.ability.triggered_this_hand then
            local played_card = context.other_card
            
            if played_card:get_id() == 4 then
                local diamond_count = 0
                if G.playing_cards then
                    for _, v in ipairs(G.playing_cards) do
                        if v:is_suit("Diamonds") then diamond_count = diamond_count + 1 end
                    end
                end
                
                if diamond_count > 0 then
                    local total_chips = diamond_count * stats[1]
                    
                    return {
                        chips = total_chips,
                        message = "Aegis!",
                        colour = G.C.CHIPS
                    }
                end
            end
        end
    end,
})

Warcraft.create_equipment({
    name = "Ashbringer",
    index = 34, 
    
    loc_text = {
        "Scored {C:attention}Gold Cards{} add {C:mult}#1#%{}",
        "of their total Chips to {C:mult}Mult{}."
    },

    req_level = 6, 
    req_class = {"Paladin"}, 
    req_weapon = {"Sword"},
    combo_joker = {"Tirion Fordring", "Alexandros Mograine", "Darion Mograine", "Magni Bronzebeard"},

    config = { extra = { base_pct = 15, scale_pct = 5 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_pct + ((ilvl - 1) * extra.scale_pct) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play and card.ability.triggered_this_hand then
            local played_card = context.other_card
            
            if played_card.config.center.key == 'm_gold' then
                local pct_multiplier = stats[1] / 100
                
                local total_chips = (played_card.base.nominal or 0) + (played_card:get_chip_bonus() or 0)
                if played_card.ability.perma_bonus then 
                    total_chips = total_chips + played_card.ability.perma_bonus 
                end
                
                local converted_mult = math.floor(total_chips * pct_multiplier)

                if converted_mult > 0 then
                    return {
                        mult = converted_mult,
                        message = "The Ashbringer!",
                        colour = G.C.MULT
                    }
                end
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Corrupted Ashbringer",
    index = 35, 
    
    loc_text = {
        "Scored {C:attention}Stone Cards{} give {X:mult,C:white} X#1# {} Mult,",
        "but you lose {C:money}$1{} every time one scores."
    },

    req_level = 6, 
    req_class = {"Warrior","Paladin","Hunter","Death Knight"}, 
    req_weapon = {"Sword"},
    combo_joker = {"Alexandros Mograine", "Darion Mograine"},

    config = { extra = { base_xmult = 2.5, scale_xmult = 0.5, dollar_loss = 1 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_xmult + ((ilvl - 1) * extra.scale_xmult) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play and card.ability.triggered_this_hand then
            local played_card = context.other_card
            
            if played_card.config.center.key == 'm_stone' then
                ease_dollars(-extra.dollar_loss)
                
                return {
                    x_mult = stats[1],
                    message = "Despair!",
                    colour = G.C.DARK_EDITION
                }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Light's Wrath",
    index = 36, 
    
    loc_text = {
        "Scored {C:attention}Kings{} give {C:mult}+#1#{} Mult",
        "for each {C:attention}Gold Card{} in your full deck."
    },

    req_level = 6, 
    req_class = {"Priest"}, 
    req_weapon = {"Staff"},
    combo_joker = {"Whitemane"},

    config = { extra = { base_mult_per = 0, scale_mult_per = 5 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_mult_per + ((ilvl - 1) * extra.scale_mult_per) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play and card.ability.triggered_this_hand then
            local played_card = context.other_card
            
            if played_card:get_id() == 13 then
                local gold_count = 0
                if G.playing_cards then
                    for _, v in ipairs(G.playing_cards) do
                        if v.config.center.key == 'm_gold' then gold_count = gold_count + 1 end
                    end
                end
                
                if gold_count > 0 then
                    local total_mult = gold_count * stats[1]
                    
                    return {
                        mult = total_mult,
                        message = "Overloaded with Light!",
                        colour = G.C.MULT
                    }
                end
            end
        end
    end
})

Warcraft.create_equipment({
    name = "T'uure",
    index = 37, 
    
    loc_text = {
        "Scored {C:attention}Kings{} give {C:chips}+#1#{} Chips",
        "for each {C:planet}Planet card{} used this run.",
        "{C:inactive}(Currently {C:chips}+#2#{C:inactive} Chips)"
    },

    req_level = 6, 
    req_class = {"Priest"}, 
    req_weapon = {"Staff"},
    req_race = {"Draenei"},
    combo_joker = {"Prophet Velen"},

    config = { extra = { base_chips = 5, scale_chips = 5 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_chips + ((ilvl - 1) * extra.scale_chips) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play and card.ability.triggered_this_hand then
            local played_card = context.other_card
            
            if played_card:get_id() == 13 then
                local planet_count = 0
                if G.GAME and G.GAME.consumeable_usage_total then
                    for k, v in pairs(G.GAME.consumeable_usage_total) do
                        if v.set == 'Planet' then
                            planet_count = planet_count + (v.count or 0)
                        end
                    end
                end
                
                if planet_count > 0 then
                    local total_chips = planet_count * stats[1]
                    
                    return {
                        chips = total_chips,
                        message = "Holy Guidance!",
                        colour = G.C.CHIPS
                    }
                end
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Xal'atath",
    index = 38, 
    
    loc_text = {
        "Scored {C:attention}2s{} have a {C:green}#1#% chance{}",
        "to gain a {C:purple}Purple Seal{}."
    },

    req_level = 6, 
    req_class = {"Priest"},
    req_race = {"God"},
    req_weapon = {"Daggers"},
    combo_joker = {"Xal'atath"},

    config = { extra = { base_chance = 25, scale_chance = 5 } },

    calculate_stats = function(ilvl, extra)
        return { math.min(100, extra.base_chance + ((ilvl - 1) * extra.scale_chance)) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play and card.ability.triggered_this_hand then
            local played_card = context.other_card
            
            if played_card:get_id() == 2 and not played_card.seal then
                
                if pseudorandom("xalatath_equip") < (stats[1] / 100) then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            played_card:set_seal('Purple', nil, true)
                            played_card:juice_up()
                            return true
                        end
                    }))
                    
                    return {
                        message = "Whispers...",
                        colour = G.C.PURPLE
                    }
                end
            end
        end
    end
})

Warcraft.create_equipment({
    name = "The Kingslayers",
    index = 39, 
    
    loc_text = {
        "Scored {C:attention}2s{} give {X:mult,C:white} X#1# {} Mult",
        "for each {C:attention}King{} in your full deck.",
        "{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)"
    },

    req_level = 6, 
    req_class = {"Rogue"}, 
    req_weapon = {"Daggers"},
    req_race = {"Orc"},
    combo_joker = {"Garona Halforcen", "Gul'dan"},

    config = { extra = { base_mult_per = 0.1, scale_mult_per = 0.1 } },

    calculate_stats = function(ilvl, extra)
        local mult_per = extra.base_mult_per + ((ilvl - 1) * extra.scale_mult_per)
        
        local king_count = 0
        if G.playing_cards then
            for _, v in ipairs(G.playing_cards) do
                if v:get_id() == 13 then king_count = king_count + 1 end
            end
        end

        return { mult_per, 1 + (king_count * mult_per) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play and card.ability.triggered_this_hand then
            local played_card = context.other_card
            
            if played_card:get_id() == 2 then
                -- stats[2] is the total XMult pre-calculated in calculate_stats
                local total_xmult = stats[2] 
                
                if total_xmult > 1 then
                    return {
                        x_mult = total_xmult,
                        message = "Assassinate!",
                        colour = G.C.MULT
                    }
                end
            end
        end
    end,
})

Warcraft.create_equipment({
    name = "The Dreadblades",
    index = 40, 
    
    loc_text = {
        "Scored {C:attention}Pairs{} have a {C:green}#1#% chance{}",
        "to become {C:attention}Lucky Cards{} after scoring."
    },

    req_level = 6, 
    req_class = {"Rogue"}, 
    req_weapon = {"Sword"},
    combo_joker = {"Dread Admiral Eliza", "Fleet Admiral Tethys", "Helya"},

    config = { extra = { base_chance = 20, scale_chance = 5 } },

    calculate_stats = function(ilvl, extra)
        return { math.min(100, extra.base_chance + ((ilvl - 1) * extra.scale_chance)) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        -- Context check: only trigger during individual scoring if Joker has triggered
        if context.individual and context.cardarea == G.play and context.scoring_name == "Pair" and card.ability.triggered_this_hand then
            local played_card = context.other_card
            
            -- Only convert if it's currently a base card
            if played_card.config.center.key == 'c_base' then
                if pseudorandom("dreadblades") < (stats[1] / 100) then
                    
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            played_card:set_ability(G.P_CENTERS.m_lucky, nil, true)
                            played_card:juice_up()
                            return true
                        end
                    }))
                    
                    return {
                        message = "Fortune's Favor!",
                        colour = G.C.GREEN
                    }
                end
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Fangs of the Devourer",
    index = 41, 
    
    loc_text = {
        "Scored {C:attention}2s{} give {C:mult}+#1#{} Mult",
        "if played hand is a {C:attention}High Card{}."
    },

    req_level = 6, 
    req_class = {"Rogue"}, 
    req_weapon = {"Daggers"},
    req_race = {"Demon"},
    req_faction = {"Legion"},
    combo_joker = {"Taoshi"},

    config = { extra = { base_mult = 10, scale_mult = 10 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_mult + ((ilvl - 1) * extra.scale_mult) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play and card.ability.triggered_this_hand then
            
            if context.scoring_name == "High Card" then
                local played_card = context.other_card
                
                if played_card:get_id() == 2 then
                    return {
                        mult = stats[1],
                        message = "Goremaw's Bite!",
                        colour = G.C.MULT
                    }
                end
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Fist of Ra-den",
    index = 42, 
    
    loc_text = {
        "Scored {C:attention}6s{} of {C:clubs}Clubs{} give",
        "{X:mult,C:white} X#1# {} Mult."
    },

    req_level = 6, 
    req_class = {"Shaman"}, 
    req_weapon = {"Fist Weapon"},
    req_race = {"Pandaren","Titan"},
    combo_joker = {"Ra-den", "Lei Shen", "Xuen"},

    config = { extra = { base_xmult = 1.5, scale_xmult = 0.5 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_xmult + ((ilvl - 1) * extra.scale_xmult) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play and card.ability.triggered_this_hand then
            local played_card = context.other_card
            
            if played_card:get_id() == 6 and played_card:is_suit('Clubs') then
                return {
                    x_mult = stats[1],
                    message = "Stormkeeper!",
                    colour = G.C.BLUE
                }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Doomhammer",
    index = 43, 
    
    loc_text = {
        "Scored {C:attention}Bonus Cards{} have a {C:green}#1#% chance{}",
        "to gain a {C:red}Red Seal{}."
    },

    req_level = 6, 
    req_class = {"Shaman"}, 
    req_weapon = {"Hammer"},
    req_race = {"Orc"},
    combo_joker = {"Thrall", "Orgrim Doomhammer"},

    config = { extra = { base_chance = 45, scale_chance = 5 } },

    calculate_stats = function(ilvl, extra)
        return { math.min(100, extra.base_chance + ((ilvl - 1) * extra.scale_chance)) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play and card.ability.triggered_this_hand then
            local played_card = context.other_card
            
            if played_card.config.center.key == 'm_bonus' and not played_card.seal then
                
                if pseudorandom("doomhammer") < (stats[1] / 100) then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            played_card:set_seal('Red', nil, true)
                            played_card:juice_up()
                            return true
                        end
                    }))
                    
                    return {
                        message = "Windfury!",
                        colour = G.C.RED
                    }
                end
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Sharas'dal",
    index = 44, 
    
    loc_text = {
        "Scored {C:attention}Queens{} of {C:spades}Spades{}",
        "give {C:mult}+#1#{} Mult."
    },

    req_level = 6, 
    req_class = {"Shaman"},
    req_race = {"Night Elf", "Naga"},
    req_weapon = {"Staff"},
    combo_joker = {"Queen Azshara"},

    config = { extra = { base_mult = 5, scale_mult = 10 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_mult + ((ilvl - 1) * extra.scale_mult) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play and card.ability.triggered_this_hand then
            local played_card = context.other_card
            
            if played_card:get_id() == 12 and played_card:is_suit('Spades') then
                return {
                    mult = stats[1],
                    message = "Tidal Waves!",
                    colour = G.C.MULT
                }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Ulthalesh",
    index = 45, 
    
    loc_text = {
        "Scored {C:attention}Kings{} have a {C:green}#1#% chance{}",
        "to generate a random {C:spectral}Spectral Card{}."
    },

    req_level = 6, 
    req_class = {"Warlock"}, 
    req_weapon = {"Staff"},
    req_race = {"Demon"},
    req_faction = {"Legion"},
    combo_joker = {"Sargeras", "Medivh"},

    config = { extra = { base_chance = 15, scale_chance = 5 } },

    calculate_stats = function(ilvl, extra)
        return { math.min(100, extra.base_chance + ((ilvl - 1) * extra.scale_chance)) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        -- Checks triggered_this_hand to ensure it only fires once per hand played
        if context.individual and context.cardarea == G.play and card.ability.triggered_this_hand then
            local played_card = context.other_card
            
            if played_card:get_id() == 13 then
                if pseudorandom("ult_reap") < (stats[1] / 100) then
                    
                    if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                        G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                        
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                local _card = create_card('Spectral', G.consumeables, nil, nil, nil, nil, nil, 'ult_gen')
                                _card:add_to_deck()
                                G.consumeables:emplace(_card)
                                G.GAME.consumeable_buffer = 0
                                return true
                            end
                        }))
                        
                        return {
                            message = "Soul Harvested!",
                            colour = G.C.SPECTRAL
                        }
                    end
                end
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Skull of the Man'ari",
    index = 46, 
    
    loc_text = {
        "Scored {C:attention}Base Cards{} have a {C:green}#1#% chance{}",
        "to be {C:red}destroyed{}. If destroyed, this",
        "weapon gains permanent {C:mult}+#2#{} Mult.",
        "{C:inactive}(Currently {C:mult}+#3#{C:inactive} Mult){}"
    },

    req_level = 6, 
    req_class = {"Warlock"},
    req_race = {"Demon"},
    req_faction = {"Legion"},
    req_weapon = {"Shield"},
    combo_joker = {"Archimonde"},

    config = { extra = { base_chance = 8, scale_chance = 2, base_mult = 5, scale_mult = 5 } },

    calculate_stats = function(ilvl, extra)
        return { 
            math.min(100, extra.base_chance + ((ilvl - 1) * extra.scale_chance)), 
            extra.base_mult + ((ilvl - 1) * extra.scale_mult) 
        }
    end,

    -- Note: Removed loc_vars as the generic generate_ui now handles #1#, #2#, etc. 
    -- We just need to make sure the equipment data has the 'sacrificed_mult' in it.

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        local eq = card.ability.wow_equipment
        
        -- 1. Trigger phase: Chance to destroy
        if context.individual and context.cardarea == G.play and card.ability.triggered_this_hand then
            local played_card = context.other_card
            
            if played_card.config.center.key == 'c_base' then
                if pseudorandom("skull_manari") < (stats[1] / 100) then
                    local mult_gain = stats[2]
                    
                    eq.sacrificed_mult = (eq.sacrificed_mult or 0) + mult_gain
                    
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            played_card:start_dissolve()
                            return true
                        end
                    }))
                    
                    return {
                        message = "Sacrificed!",
                        colour = G.C.RED,
                        mult = mult_gain 
                    }
                end
            end
        end

        -- 2. Scoring phase: Apply the stored permanent mult
        if context.joker_main then
            local bonus = eq.sacrificed_mult or 0
            if bonus > 0 then
                return {
                    mult = bonus
                }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Scepter of Sargeras",
    index = 47, 
    
    loc_text = {
        "Scored {C:attention}Odd Ranked{} cards give",
        "{C:chips}+#1#{} Chips when scored."
    },

    req_level = 6, 
    req_class = {"Warlock"}, 
    req_weapon = {"Staff"},
    req_race = {"Demon"},
    req_faction = {"Legion", "Orc"},
    combo_joker = {"Sargeras", "Ner'zhul", "Gul'dan"},

    config = { extra = { base_chips = 15, scale_chips = 10 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_chips + ((ilvl - 1) * extra.scale_chips) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play and card.ability.triggered_this_hand then
            local played_card = context.other_card
            local id = played_card:get_id()
            
            -- Checks for Odd Ranks: 3, 5, 7, 9, 11 (Jack), 13 (King)
            -- Note: 'id' for Ace is 14 (even), so we don't include it unless you want to
            if (id > 0 and id < 11 and id % 2 ~= 0) or id == 11 or id == 13 then
                return {
                    chips = stats[1],
                    message = "Chaos Bolt!",
                    colour = G.C.CHIPS
                }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Strom'kar",
    index = 48, 
    
    loc_text = {
        "Scored {C:attention}10s{} and {C:attention}Bonus Cards{}",
        "give {C:chips}+#1#{} Chips when scored."
    },

    req_level = 6, 
    req_class = {"Warrior"}, 
    req_weapon = {"Sword"},
    req_race = {"Troll"},

    config = { extra = { base_chips = 30, scale_chips = 15 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_chips + ((ilvl - 1) * extra.scale_chips) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play and card.ability.triggered_this_hand then
            local played_card = context.other_card
            local is_10 = played_card:get_id() == 10
            local is_bonus = played_card.config.center.key == 'm_bonus'
            
            if is_10 or is_bonus then
                return {
                    chips = stats[1],
                    message = "Warbreaker!",
                    colour = G.C.CHIPS
                }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Warswords of the Valarjar",
    index = 49, 
    
    loc_text = {
        "Scored {C:attention}Bonus Cards{} with a {C:red}Red Seal{}",
        "give {X:mult,C:white} X#1# {} Mult when scored."
    },

    req_level = 6, 
    req_class = {"Warrior"},
    req_weapon = {"Sword"},
    req_race = {"Titan"},
    combo_joker = {"Odyn", "Helya"},

    config = { extra = { base_xmult = 3, scale_xmult = 1 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_xmult + ((ilvl - 1) * extra.scale_xmult) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play and card.ability.triggered_this_hand then
            local played_card = context.other_card
            
            if played_card.config.center.key == 'm_bonus' and played_card:get_seal() == 'Red' then
                return {
                    x_mult = stats[1],
                    message = "Raging Blow!",
                    colour = G.C.RED
                }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Scale of the Earth-Warder",
    index = 50, 
    
    loc_text = {
        "Scored {C:attention}4s{} and {C:diamonds}Diamonds{} give",
        "{C:chips}+#1#{} Chips when scored."
    },

    req_level = 6, 
    req_class = {"Warrior"}, 
    req_weapon = {"Shield"},
    req_race = {"Dragon"},
    combo_joker = {"Neltharion", "Huln Highmountain"},

    config = { extra = { base_chips = 40, scale_chips = 20 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_chips + ((ilvl - 1) * extra.scale_chips) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play and card.ability.triggered_this_hand then
            local played_card = context.other_card
            local is_4 = played_card:get_id() == 4
            local is_diamond = played_card:is_suit('Diamonds')
            
            if is_4 or is_diamond then
                return {
                    chips = stats[1],
                    message = "Iron Walls!",
                    colour = G.C.CHIPS
                }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Scythe of the Unmaker",
    index = 51, 
    
    loc_text = {
        "Whenever a playing card is {C:red}destroyed{},",
        "{C:green}#1#% chance{} to generate a random",
        "{C:planet}Planet{} card."
    },

    req_level = 6, 
    req_class = {"Warrior","Paladin","Hunter","Monk","Death Knight"}, 
    req_weapon = {"Polearm"},
    req_race = {"Titan"},
    combo_joker = {"Argus the Unmaker"},

    config = { extra = { base_chance = 30, scale_chance = 10 } },

    calculate_stats = function(ilvl, extra)
        return { math.min(100, extra.base_chance + ((ilvl - 1) * extra.scale_chance)) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        -- Context remove_playing_cards triggers globally when cards are destroyed
        if context.remove_playing_cards and not context.blueprint then
            local destroyed_count = #context.removed
            local generated = false

            if destroyed_count > 0 then
                for i = 1, destroyed_count do
                    -- stats[1] holds the clamped chance (30 + (ilvl-1)*10)
                    if pseudorandom("scythe_unmaker") < (stats[1] / 100) then
                        
                        if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                            generated = true
                            
                            G.E_MANAGER:add_event(Event({
                                func = function()
                                    local _card = create_card('Planet', G.consumeables, nil, nil, nil, nil, nil, 'scythe_gen')
                                    _card:add_to_deck()
                                    G.consumeables:emplace(_card)
                                    G.GAME.consumeable_buffer = 0
                                    return true
                                end
                            }))
                        end
                    end
                end
            end

            if generated then
                return {
                    message = "Soul Harvest!",
                    colour = G.C.PLANET
                }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Gavel of the First Arbiter",
    index = 52, 
    
    loc_text = {
        "Scored {C:attention}9s{} and {C:attention}Even Ranked{} cards",
        "give {C:chips}+#1#{} Chips when scored."
    },

    req_level = 6, 
    req_class = {"Priest"}, 
    req_weapon = {"Hammer"},
    req_race = {"God"},
    combo_joker = {"Zovaal"},

    config = { extra = { base_chips = 30, scale_chips = 15 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_chips + ((ilvl - 1) * extra.scale_chips) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play and card.ability.triggered_this_hand then
            local played_card = context.other_card
            local id = played_card:get_id()
            
            local is_9 = (id == 9)
            local is_even = (id > 0 and id % 2 == 0)

            if is_9 or is_even then
                return {
                    chips = stats[1],
                    message = "Judgement!",
                    colour = G.C.CHIPS
                }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Arcanite Reaper",
    index = 53, 
    
    loc_text = {
        "Scored {C:attention}7s{} with {C:attention}Bonus Enhancement{}",
        "give {X:mult,C:white} X#1# {} Mult."
    },

    req_level = 6, 
    req_class = {"Warrior","Paladin"}, 
    req_weapon = {"Axe"},
    req_faction = {"Horde","Alliance"},

    config = { extra = { base_xmult = 2.5, scale_xmult = 0.5 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_xmult + ((ilvl - 1) * extra.scale_xmult) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play and card.ability.triggered_this_hand then
            local played_card = context.other_card
            
            if played_card:get_id() == 7 and played_card.config.center.key == 'm_bonus' then
                return {
                    x_mult = stats[1],
                    message = "ARCANITE REAPER, HOOOOO!",
                    colour = G.C.RED
                }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Horde Insignia",
    index = 54, 
    
    loc_text = {
        "Scored {C:hearts}Hearts{} and {C:diamonds}Diamonds{} give",
        "{C:mult}+#1#{} Mult if played hand",
        "is a {C:attention}Full House{}."
    },

    req_level = 1, 
    req_class = {"Any"}, 
    req_faction = {"Horde"},
    combo_joker = {"Thrall", "Drek'Thar"},

    config = { extra = { base_mult = 10, scale_mult = 5 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_mult + ((ilvl - 1) * extra.scale_mult) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            if context.scoring_name == "Full House" then
                local played_card = context.other_card
                if played_card:is_suit('Hearts') or played_card:is_suit('Diamonds') then
                    return {
                        mult = stats[1],
                        message = "For the Horde!",
                        colour = G.C.RED
                    }
                end
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Alliance Insignia",
    index = 55, 
    
    loc_text = {
        "Scored {C:spades}Spades{} and {C:clubs}Clubs{} give",
        "{C:mult}+#1#{} Mult if played hand",
        "is a {C:attention}Full House{}."
    },

    req_level = 1, 
    req_class = {"Any"}, 
    req_faction = {"Alliance"},
    combo_joker = {"Anduin Wrynn", "Varian Wrynn", "Vanndar Stormpike"},

    config = { extra = { base_mult = 10, scale_mult = 5 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_mult + ((ilvl - 1) * extra.scale_mult) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            if context.scoring_name == "Full House" then
                local played_card = context.other_card
                if played_card:is_suit('Spades') or played_card:is_suit('Clubs') then
                    return {
                        mult = stats[1],
                        message = "For the Alliance!",
                        colour = G.C.BLUE
                    }
                end
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Benediction",
    index = 56, 
    
    loc_text = {
        "Scored {C:attention}Kings{} with {C:attention}Gold Enhancement{}",
        "give {C:chips}+#1#{} Chips and {C:mult}+#2#{} Mult."
    },

    req_level = 6, 
    req_class = {"Priest"}, 
    req_weapon = {"Staff"},
    combo_joker = {"Majordomo Executus"},

    config = { extra = { base_chips = 50, scale_chips = 25, base_mult = 15, scale_mult = 10 } },

    calculate_stats = function(ilvl, extra)
        return {
            extra.base_chips + ((ilvl - 1) * extra.scale_chips),
            extra.base_mult + ((ilvl - 1) * extra.scale_mult)
        }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if played_card:get_id() == 13 and played_card.config.center.key == 'm_gold' then
                return {
                    chips = stats[1],
                    mult = stats[2],
                    message = "The Light Sustains!",
                    colour = G.C.GOLD,
                    card = played_card
                }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Gorehowl",
    index = 57, 
    
    loc_text = {
        "Scored {C:attention}7s{} have a {C:green}#1#% chance{}",
        "to gain a {C:red}Red Seal{}."
    },

    req_level = 6, 
    req_class = {"Warrior","Paladin","Death Knight"}, 
    req_weapon = {"Axe"},
    req_race = {"Orc"},
    combo_joker = {"Grommash Hellscream", "Garrosh Hellscream", "Thrall"},

    config = { extra = { base_chance = 50, scale_chance = 10 } },

    calculate_stats = function(ilvl, extra)
        return { math.min(100, extra.base_chance + ((ilvl - 1) * extra.scale_chance)) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            
            if played_card:get_id() == 7 and not played_card.seal then
                local current_chance = stats[1]
                
                if pseudorandom("gorehowl") < (current_chance / 100) then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            played_card:set_seal('Red', nil, true)
                            played_card:juice_up()
                            return true
                        end
                    }))
                    
                    return {
                        message = "Bloodlust!",
                        colour = G.C.RED
                    }
                end
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Quel'Delar",
    index = 58, 
    
    loc_text = {
        "Scored {C:attention}10s{} of {C:spades}Spades{} or {C:clubs}Clubs{}",
        "give {C:mult}+#1#{} Mult."
    },

    req_level = 6, 
    req_class = {"Any"}, 
    req_weapon = {"Sword"},
    req_race = {"Blood Elf"},

    config = { extra = { base_mult = 10, scale_mult = 5 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_mult + ((ilvl - 1) * extra.scale_mult) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            
            if played_card:get_id() == 10 and (played_card:is_suit('Spades') or played_card:is_suit('Clubs')) then
                return {
                    mult = stats[1],
                    message = "Reforged Power!",
                    colour = G.C.MULT,
                    card = played_card
                }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Armageddon",
    index = 59, 
    
    loc_text = {
        "Scored {C:attention}Stone Cards{} give",
        "{C:chips}+#1#{} Chips when scored."
    },

    req_level = 6, 
    req_class = {"Death Knight", "Paladin", "Warrior"}, 
    req_weapon = {"Sword"},
    req_race = {"Undead"},
    combo_joker = {"Alexandros Mograine", "Kel'Thuzad"},

    config = { extra = { base_chips = 100, scale_chips = 50 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_chips + ((ilvl - 1) * extra.scale_chips) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            
            if played_card.config.center.key == 'm_stone' then
                return {
                    chips = stats[1],
                    message = "The End is Near!",
                    colour = G.C.CHIPS,
                    card = played_card
                }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Gurthalak",
    index = 60, 
    
    loc_text = {
        "Scored {C:attention}10s{} have a {C:green}#1#% chance{}",
        "to generate a random {C:spectral}Spectral Card{}."
    },

    req_level = 6, 
    req_class = {"Warrior","Paladin", "Death Knight"},
    req_race = {"Dragon"},
    req_weapon = {"Sword"},
    combo_joker = {"Neltharion","N'Zoth"},

    config = { extra = { base_chance = 20, scale_chance = 5 } },

    calculate_stats = function(ilvl, extra)
        return { math.min(100, extra.base_chance + ((ilvl - 1) * extra.scale_chance)) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            
            if played_card:get_id() == 10 then
                local current_chance = stats[1]
                
                if pseudorandom("gurthalak_void") < (current_chance / 100) then
                    if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                        G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                        
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                local _card = create_card('Spectral', G.consumeables, nil, nil, nil, nil, nil, 'gurth_gen')
                                _card:add_to_deck()
                                G.consumeables:emplace(_card)
                                G.GAME.consumeable_buffer = 0
                                return true
                            end
                        }))
                        
                        return {
                            message = "The Void Speaks!",
                            colour = G.C.SPECTRAL
                        }
                    end
                end
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Tusks of Mannoroth",
    index = 61, 
    
    loc_text = {
        "Scored {C:attention}Bonus Cards{} of {C:hearts}Hearts{}",
        "give {C:chips}+#1#{} Chips when scored."
    },

    req_level = 6, 
    req_class = {"Warrior","Paladin","Death Knight"}, 
    req_race = {"Orc"},
    combo_joker = {"Mannoroth","Grommash Hellscream","Garrosh Hellscream"},

    config = { extra = { base_chips = 30, scale_chips = 15 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_chips + ((ilvl - 1) * extra.scale_chips) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            
            if played_card.config.center.key == 'm_bonus' and played_card:is_suit('Hearts') then
                return {
                    chips = stats[1],
                    message = "True Horde!",
                    colour = G.C.CHIPS,
                    card = played_card
                }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "The Black Hand",
    index = 62, 
    
    loc_text = {
        "Scored {C:attention}Steel Cards{} give",
        "{X:mult,C:white} X#1# {} Mult if played hand",
        "is a {C:attention}Pair{}."
    },

    req_level = 6, 
    req_class = {"Warrior","Paladin","Death Knight"}, 
    req_weapon = {"Hammer"},
    req_race = {"Orc"},
    combo_joker = {"Blackhand","Garrosh Hellscream"},

    config = { extra = { base_xmult = 1.5, scale_xmult = 0.25 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_xmult + ((ilvl - 1) * extra.scale_xmult) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            if context.scoring_name == "Pair" then
                local played_card = context.other_card
                
                if played_card.config.center.key == 'm_steel' then
                    return {
                        x_mult = stats[1],
                        message = "Blackrock Might!",
                        colour = G.C.MULT,
                        card = played_card
                    }
                end
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Arcanocrystal",
    index = 63, 
    
    loc_text = {
        "Scored {C:purple}Purple Seals{} give",
        "{X:mult,C:white} X#1# {} Mult if played hand",
        "is a {C:attention}Straight{}."
    },

    req_level = 6, 
    req_class = {"Any"}, 
    combo_joker = {"Khadgar"},

    config = { extra = { base_xmult = 2.0, scale_xmult = 0.5 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_xmult + ((ilvl - 1) * extra.scale_xmult) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            if context.scoring_name == "Straight" then
                local played_card = context.other_card
                
                if played_card:get_seal() == 'Purple' then
                    return {
                        x_mult = stats[1],
                        message = "Unstable Power!",
                        colour = G.C.PURPLE,
                        card = played_card
                    }
                end
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Convergence of Fates",
    index = 64, 
    
    loc_text = {
        "Playing a {C:attention}Straight{} permanently",
        "adds {C:mult}+#1#{} Mult to this equipment.",
        "{C:inactive}(Currently {C:mult}+#2#{C:inactive} Mult){}"
    },

    req_level = 6, 
    req_class = {"Any"}, 
    combo_joker = {"Grand Magistrix Elisande"},

    config = { extra = { base_gain = 5, scale_gain = 3 } },

    calculate_stats = function(ilvl, extra)
        local current_gain = math.floor(extra.base_gain + ((ilvl - 1) * extra.scale_gain))
        return { current_gain }
    end,

    get_ui_stats = function(ilvl, extra, eq)
        local current_gain = math.floor(extra.base_gain + ((ilvl - 1) * extra.scale_gain))
        local current_mult = (eq and eq.fate_mult) or 0
        return { current_gain, current_mult }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        local eq = card.ability.wow_equipment

        -- 1. Trigger phase: Permanent Gain
        if context.before and context.scoring_name == "Straight" and not context.blueprint then
            local mult_gain = stats[1]
            eq.fate_mult = (eq.fate_mult or 0) + mult_gain
            
            return {
                message = "Fate Accelerated!",
                colour = G.C.MULT
            }
        end

        -- 2. Scoring phase: Apply the stored mult
        if context.joker_main then
            local bonus = eq.fate_mult or 0
            if bonus > 0 then
                return {
                    mult = bonus,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "First Satyr Spaulders",
    index = 65, 
    
    loc_text = {
        "Scored {C:attention}Wild Cards{} give",
        "{X:mult,C:white} X#1# {} Mult."
    },

    req_level = 6, 
    req_class = {"Druid","Rogue","Monk","Demon Hunter"}, 
    combo_joker = {"Xavius","Malfurion Stormrage"},

    config = { extra = { base_xmult = 2.5, scale_xmult = 0.5 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_xmult + ((ilvl - 1) * extra.scale_xmult) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            
            if played_card.config.center.key == 'm_wild' then
                return {
                    x_mult = stats[1],
                    message = "Nightmare Power!",
                    colour = G.C.MULT,
                    card = played_card
                }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Sephuz's Secret",
    index = 66, 
    
    loc_text = {
        "Scored {C:attention}Jacks{} give",
        "{C:chips}+#1#{} Chips when scored."
    },

    req_level = 6, 
    req_class = {"Any"}, 
    combo_joker = {"Khadgar"},

    config = { extra = { base_chips = 50, scale_chips = 25 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_chips + ((ilvl - 1) * extra.scale_chips) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            
            if played_card:get_id() == 11 then
                return {
                    chips = stats[1],
                    message = "Haste Proc!",
                    colour = G.C.CHIPS,
                    card = played_card
                }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Geti'ikku, Cut of Death",
    index = 67, 
    
    loc_text = {
        "Scored {C:attention}10s{} give {C:mult}+#1#{} Mult",
        "and {C:attention}permanently{} gain {C:mult}+#2#{} Mult",
        "every time they are scored."
    },

    req_level = 6, 
    req_class = {"Warrior","Paladin", "Death Knight"}, 
    req_weapon = {"Sword"},
    req_race = {"Troll"},
    combo_joker = {"Bwonsamdi"},

    config = { extra = { base_mult = 10, scale_mult = 5, base_gain = 2, scale_gain = 1 } },

    calculate_stats = function(ilvl, extra)
        return {
            extra.base_mult + ((ilvl - 1) * extra.scale_mult),
            extra.base_gain + ((ilvl - 1) * extra.scale_gain)
        }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            
            if played_card:get_id() == 10 then
                local flat_bonus = stats[1]
                local gain_amt = stats[2]
                
                -- Update the permanent bonus on the playing card itself
                played_card.ability.geti_bonus = (played_card.ability.geti_bonus or 0) + gain_amt
                
                return {
                    mult = flat_bonus + played_card.ability.geti_bonus,
                    message = "Bleed!",
                    colour = G.C.RED,
                    card = played_card
                }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Jaithys, the Prison Blade",
    index = 68, 
    
    loc_text = {
        "Scored {C:attention}Stone Cards{} give",
        "{C:chips}+#1#{} Chips when scored."
    },

    req_level = 6, 
    req_class = {"Death Knight","Paladin", "Warrior"}, 
    req_weapon = {"Sword"},
    combo_joker = {"Kel'Thuzad", "Zovaal", "The Primus"},
    per_card = true,

    config = { extra = { base_chips = 50, scale_chips = 25 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_chips + ((ilvl - 1) * extra.scale_chips) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            
            if played_card.config.center.key == 'm_stone' then
                return {
                    chips = stats[1],
                    message = "Feed Me!",
                    colour = G.C.CHIPS,
                    card = played_card
                }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Ashkandur, Fall of the Brotherhood",
    index = 69, 
    
    loc_text = {
        "Scored {C:attention}Bonus Cards{} give",
        "{X:mult,C:white} X#1# {} Mult if played hand",
        "is a {C:attention}Two Pair{}."
    },

    req_level = 6, 
    req_class = {"Warrior","Paladin", "Death Knight"}, 
    req_weapon = {"Sword"},
    req_race = {"Dragon"},
    combo_joker = {"Neltharion", "Sarkareth", "Nefarian"},

    config = { extra = { base_xmult = 2.0, scale_xmult = 0.5 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_xmult + ((ilvl - 1) * extra.scale_xmult) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            if context.scoring_name == "Two Pair" then
                local played_card = context.other_card
                
                if played_card.config.center.key == 'm_bonus' then
                    return {
                        x_mult = stats[1],
                        message = "Shadowflame Slice!",
                        colour = G.C.MULT,
                        card = played_card
                    }
                end
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Prydaz, Xavaric's Magnum Opus",
    index = 70, 
    
    loc_text = {
        "Scored {C:attention}4s{} permanently gain",
        "{C:chips}+#1#{} Chips every time they are scored."
    },

    req_level = 6, 
    req_class = {"Any"}, 
    combo_joker = {"Khadgar"},

    config = { extra = { base_gain = 10, scale_gain = 5 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_gain + ((ilvl - 1) * extra.scale_gain) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            
            if played_card:get_id() == 4 then
                local gain_chips = stats[1]
                
                -- Update the permanent chips on the playing card
                played_card.ability.perma_bonus = (played_card.ability.perma_bonus or 0) + gain_chips
                
                return {
                    message = "Hardened!",
                    colour = G.C.CHIPS,
                    card = played_card
                }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Kil'jaeden's Burning Wish",
    index = 71, 
    
    loc_text = {
        "Using a {C:spectral}Spectral Card{} grants {C:money}$#1#{}",
        "and permanently adds {C:mult}+#2#{} Mult to this equipment.",
        "{C:inactive}(Currently {C:mult}+#3#{C:inactive} Mult){}"
    },

    req_level = 6, 
    req_class = {"Any"}, 
    req_faction = {"Legion"},
    combo_joker = {"Kil'jaeden","Prophet Velen"},

    config = { extra = { base_money = 4, base_gain = 5, scale_gain = 1 } },

    calculate_stats = function(ilvl, extra)
        local current_gain = extra.base_gain + ((ilvl - 1) * extra.scale_gain)
        return { extra.base_money, current_gain }
    end,

    loc_vars = function(self, info_queue, card)
        local ilvl = (card and card.ability and card.ability.ilvl) or 1
        local extra = self.config.extra
        local stats = self:calculate_stats(ilvl, extra)
        
        local current_mult = 0
        if card and card.ability and card.ability.wow_equipment then
            current_mult = card.ability.wow_equipment.burning_mult or 0
        end

        return { vars = { stats[1], stats[2], current_mult, ilvl } }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        local eq = card.ability.wow_equipment

        -- 1. Trigger phase: Use Spectral to gain Money and permanent Mult
        if context.using_consumeable and context.consumeable.ability.set == 'Spectral' and not context.blueprint then
            local money_gain = stats[1]
            local mult_gain = stats[2]
            
            eq.burning_mult = (eq.burning_mult or 0) + mult_gain
            ease_dollars(money_gain)
            
            return {
                message = "The Deceiver's Gift!",
                colour = G.C.GOLD
            }
        end

        -- 2. Scoring phase: Apply the stored permanent mult
        if context.joker_main then
            local bonus = eq.burning_mult or 0
            if bonus > 0 then
                return {
                    mult = bonus,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Archimonde's Hatred Reborn",
    index = 72, 
    
    loc_text = {
        "{C:attention}Steel Cards{} held in hand",
        "passively grant {C:chips}+#1#{} Chips",
        "and {C:mult}+#2#{} Mult to your played hand."
    },

    req_level = 6, 
    req_class = {"Any"}, 
    req_faction = {"Legion"},
    combo_joker = {"Archimonde","Sargeras"},

    config = { extra = { base_chips = 15, scale_chips = 10, base_mult = 5, scale_mult = 5 } },

    calculate_stats = function(ilvl, extra)
        return {
            extra.base_chips + ((ilvl - 1) * extra.scale_chips),
            extra.base_mult + ((ilvl - 1) * extra.scale_mult)
        }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.joker_main then
            local chip_per = stats[1]
            local mult_per = stats[2]
            local steel_count = 0

            for _, held_card in ipairs(G.hand.cards) do
                if held_card.config.center.key == 'm_steel' and not held_card.debuff then
                    steel_count = steel_count + 1
                end
            end

            if steel_count > 0 then
                return {
                    chips = steel_count * chip_per,
                    mult = steel_count * mult_per,
                    message = "Vengeful Spite!",
                    colour = G.C.ORANGE
                }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Aman'Thul's Vision",
    index = 73, 
    
    loc_text = {
        "Scored {C:attention}Queens{} with a {C:blue}Blue Seal{}",
        "give {C:chips}+#1#{} Chips and {C:mult}+#2#{} Mult."
    },

    req_level = 6, 
    req_class = {"Any"},
    req_race = {"Titan"},
    combo_joker = {"Aman'Thul", "Argus the Unmaker", "Sargeras"},

    config = { extra = { base_chips = 40, scale_chips = 20, base_mult = 15, scale_mult = 10 } },

    calculate_stats = function(ilvl, extra)
        return {
            extra.base_chips + ((ilvl - 1) * extra.scale_chips),
            extra.base_mult + ((ilvl - 1) * extra.scale_mult)
        }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            
            if played_card:get_id() == 12 and played_card:get_seal() == 'Blue' then
                return {
                    chips = stats[1],
                    mult = stats[2],
                    message = "Temporal Vision!",
                    colour = G.C.BLUE,
                    card = played_card
                }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Qian-Le, Courage of Niuzao",
    index = 74, 
    
    loc_text = {
        "Scored {C:attention}4s{} of {C:diamonds}Diamonds{}",
        "give {C:chips}+#1#{} Chips when scored."
    },

    req_level = 6, 
    req_class = {"Warrior","Death Knight","Paladin","Monk","Druid"},
    req_race = {"Pandaren"},
    combo_joker = {"Wrathion", "Niuzao"},

    config = { extra = { base_chips = 60, scale_chips = 30 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_chips + ((ilvl - 1) * extra.scale_chips) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            
            if played_card:get_id() == 4 and played_card:is_suit('Diamonds') then
                return {
                    chips = stats[1],
                    message = "Wall of the Ox!",
                    colour = G.C.CHIPS,
                    card = played_card
                }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Xing-Ho, Breath of Yu'lon",
    index = 75, 
    
    loc_text = {
        "Scored {C:attention}Queens{} of {C:clubs}Clubs{}",
        "give {X:mult,C:white} X#1# {} Mult."
    },

    req_level = 6, 
    req_class = {"Mage","Shaman","Warlock","Priest","Druid","Hunter"},
    combo_joker = {"Yu'lon","Wrathion","Lei Shen"},

    config = { extra = { base_xmult = 2.0, scale_xmult = 0.5 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_xmult + ((ilvl - 1) * extra.scale_xmult) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            
            if played_card:get_id() == 12 and played_card:is_suit('Clubs') then
                return {
                    x_mult = stats[1],
                    message = "Jade Serpent's Breath!",
                    colour = G.C.MULT,
                    card = played_card
                }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Jina-Kang, Kindness of Chi-Ji",
    index = 76, 
    
    loc_text = {
        "Scored {C:attention}Gold Cards{} give",
        "{C:mult}+#1#{} Mult if played hand",
        "is a {C:attention}Pair{}."
    },

    req_level = 6, 
    req_class = {"Priest","Paladin","Demon Hunter","Monk","Druid","Shaman"}, 
    combo_joker = {"Chi-Ji","Wrathion"},

    config = { extra = { base_mult = 15, scale_mult = 10 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_mult + ((ilvl - 1) * extra.scale_mult) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            if context.scoring_name == "Pair" then
                local played_card = context.other_card
                if played_card.config.center.key == 'm_gold' then
                    return {
                        mult = stats[1],
                        message = "Crane's Blessing!",
                        colour = G.C.GOLD,
                        card = played_card
                    }
                end
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Fen-Yu, Fury of Xuen",
    index = 77, 
    
    loc_text = {
        "Scored {C:attention}Bonus Cards{} of {C:clubs}Clubs{}",
        "give {C:mult}+#1#{} Mult when scored."
    },

    req_level = 6, 
    req_class = {"Rogue","Monk","Druid","Shaman","Hunter"}, 
    combo_joker = {"Xuen","Wrathion"},

    config = { extra = { base_mult = 15, scale_mult = 10 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_mult + ((ilvl - 1) * extra.scale_mult) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            
            if played_card.config.center.key == 'm_bonus' and played_card:is_suit('Clubs') then
                return {
                    mult = stats[1],
                    message = "Tiger's Fury!",
                    colour = G.C.MULT,
                    card = played_card
                }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Taeshalach",
    index = 78, 
    
    loc_text = {
        "Scored {C:attention}10s{} of {C:hearts}Hearts{}",
        "give {X:mult,C:white} X#1# {} Mult."
    },

    req_level = 6, 
    req_class = {"Warrior","Death Knight","Hunter", "Paladin"}, 
    req_weapon = {"Sword"},
    combo_joker = {"Aggramar","Sargeras"},

    config = { extra = { base_xmult = 2.0, scale_xmult = 0.5 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_xmult + ((ilvl - 1) * extra.scale_xmult) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            
            if played_card:get_id() == 10 and played_card:is_suit('Hearts') then
                return {
                    x_mult = stats[1],
                    message = "Flame Rend!",
                    colour = G.C.RED,
                    card = played_card
                }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Underlight Angler",
    index = 79,

    loc_text = {
        "Each discarded card has a {C:green}#1#%{} chance",
        "to gain permanent {C:chips}+#2#{} Chips",
        "and a {C:green}#3#%{} chance to gain",
        "permanent {C:mult}+#4#{} Mult"
    },

    req_level = 6,
    req_class = {"Any"},
    req_race = {"Murloc"},
    combo_joker = {"Nat Pagle", "Khadgar"},

    config = { extra = {
        base_chip_chance = 25, scale_chip_chance = 2,
        base_chip_gain   = 5,  scale_chip_gain   = 2,
        base_mult_chance = 25, scale_mult_chance = 2,
        base_mult_gain   = 1,  scale_mult_gain   = 0.5
    }},

    calculate_stats = function(ilvl, extra)
        return {
            math.min(extra.base_chip_chance + ((ilvl - 1) * extra.scale_chip_chance), 100),
            extra.base_chip_gain   + ((ilvl - 1) * extra.scale_chip_gain),
            math.min(extra.base_mult_chance + ((ilvl - 1) * extra.scale_mult_chance), 100),
            extra.base_mult_gain   + ((ilvl - 1) * extra.scale_mult_gain)
        }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.discard then
            local discarded_card = context.other_card
            local chip_chance = stats[1] / 100.0
            local chip_gain   = stats[2]
            local mult_chance = stats[3] / 100.0
            local mult_gain   = stats[4]
            local triggered   = false

            if pseudorandom('angler_chips') < chip_chance then
                discarded_card.ability.bonus = (discarded_card.ability.bonus or 0) + chip_gain
                triggered = true
                G.E_MANAGER:add_event(Event({
                    func = function()
                        card_eval_status_text(discarded_card, 'extra', nil, nil, nil, {
                            message = "+" .. chip_gain .. " Chips!",
                            colour = G.C.CHIPS
                        })
                        discarded_card:juice_up()
                        return true
                    end
                }))
            end

            if pseudorandom('angler_mult') < mult_chance then
                discarded_card.ability.perma_mult = (discarded_card.ability.perma_mult or 0) + mult_gain
                triggered = true
                G.E_MANAGER:add_event(Event({
                    func = function()
                        card_eval_status_text(discarded_card, 'extra', nil, nil, nil, {
                            message = "+" .. mult_gain .. " Mult!",
                            colour = G.C.MULT
                        })
                        discarded_card:juice_up()
                        return true
                    end
                }))
            end

            if triggered then
                return {
                    message = "Enchanted!",
                    colour = G.C.BLUE,
                    card = card
                }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Hammer of the Naaru",
    index = 80, 
    
    loc_text = {
        "Scored {C:attention}9s{} with {C:attention}Gold Enhancement{}",
        "give {C:chips}+#1#{} Chips and {C:mult}+#2#{} Mult."
    },

    req_level = 6, 
    req_class = {"Paladin","Warrior","Death Knight"}, 
    req_weapon = {"Hammer"},
    req_race = {"Draenei"},
    combo_joker = {"Yrel"},

    config = { extra = { base_chips = 50, scale_chips = 25, base_mult = 15, scale_mult = 10 } },

    calculate_stats = function(ilvl, extra)
        return {
            extra.base_chips + ((ilvl - 1) * extra.scale_chips),
            extra.base_mult + ((ilvl - 1) * extra.scale_mult)
        }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            
            if played_card:get_id() == 9 and played_card.config.center.key == 'm_gold' then
                return {
                    chips = stats[1],
                    mult = stats[2],
                    message = "Justice of the Naaru!",
                    colour = G.C.GOLD,
                    card = played_card
                }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Dragon Soul",
    index = 81, 
    
    loc_text = {
        "Scored {C:attention}Face Cards{} of {C:diamonds}Diamonds{}",
        "give {X:mult,C:white} X#1# {}."
    },

    req_level = 6, 
    req_class = {"Any"},
    req_race = {"Dragon"},
    combo_joker = {"Neltharion", "Thrall", "Nozdormu"},

    config = { extra = { base_xmult = 2.0, scale_xmult = 0.5 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_xmult + ((ilvl - 1) * extra.scale_xmult) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            
            if played_card:is_face() and played_card:is_suit('Diamonds') then
                return {
                    x_mult = stats[1],
                    message = "Cataclysmic Might!",
                    colour = G.C.ORANGE,
                    card = played_card
                }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Bulwark of Azzinoth",
    index = 82, 
    
    loc_text = {
        "Scored {C:attention}4s{} with {C:attention}Steel Enhancement{}",
        "give {C:chips}+#1#{} Chips when scored."
    },

    req_level = 6, 
    req_class = {"Warrior","Paladin"}, 
    req_weapon = {"Shield"},
    req_faction = {"Legion"},
    combo_joker = {"Illidan Stormrage"},

    config = { extra = { base_chips = 60, scale_chips = 30 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_chips + ((ilvl - 1) * extra.scale_chips) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            
            if played_card:get_id() == 4 and played_card.config.center.key == 'm_steel' then
                return {
                    chips = stats[1],
                    message = "You are not prepared!",
                    colour = G.C.CHIPS,
                    card = played_card
                }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Runeblade of Baron Rivendare",
    index = 83, 
    
    loc_text = {
        "Scored {C:attention}10s{} with {C:attention}Lucky Enhancement{}",
        "give {C:chips}+#1#{} Chips and {X:mult,C:white} X#2# {} Mult."
    },

    req_level = 6, 
    req_class = {"Death Knight","Paladin", "Warrior"}, 
    req_weapon = {"Sword"},
    combo_joker = {"Baron Rivendare"},

    config = { extra = { base_chips = 40, scale_chips = 20, base_xmult = 1.5, scale_xmult = 0.25 } },

    calculate_stats = function(ilvl, extra)
        return {
            extra.base_chips + ((ilvl - 1) * extra.scale_chips),
            extra.base_xmult + ((ilvl - 1) * extra.scale_xmult)
        }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            
            if played_card:get_id() == 10 and played_card.config.center.key == 'm_lucky' then
                return {
                    chips = stats[1],
                    x_mult = stats[2],
                    message = "Unholy Haste!",
                    colour = G.C.LIME,
                    card = played_card
                }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Puzzle Box of Yogg-Saron",
    index = 84, 
    
    loc_text = {
        "Scored {C:attention}Odd Numbers{} with a {C:purple}Purple Seal{}",
        "give {X:mult,C:white} X#1# {} Mult."
    },

    req_level = 6, 
    req_class = {"Any"},
    req_race = {"God"},
    combo_joker = {"Yogg-Saron"},

    config = { extra = { base_xmult = 3.0, scale_xmult = 1.0 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_xmult + ((ilvl - 1) * extra.scale_xmult) }
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            local id = played_card:get_id()
            
            -- Checks for Odd Ranks: 3, 5, 7, 9, and Ace (14)
            local is_odd = (id == 3 or id == 5 or id == 7 or id == 9 or id == 14)
            
            if is_odd and played_card:get_seal() == 'Purple' then
                return {
                    x_mult = stats[1],
                    message = "LURKING MADNESS!",
                    colour = G.C.PURPLE,
                    card = played_card
                }
            end
        end
    end
})
sendDebugMessage("Azeroth Balatro Mod : Generating all Equipments done!")