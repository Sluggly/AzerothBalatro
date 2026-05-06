sendDebugMessage("Azeroth Balatro Mod : Generating all Equipments...")
Warcraft.create_equipment({
    name = "Thunderfury",
    index = 1, 
    
    req_level = 6, 
    req_class = {"Warrior", "Rogue", "Paladin", "Hunter", "Death Knight"}, 
    req_race = {"Elemental"},
    req_weapon = {"Sword"},
    combo_joker = {"Baron Geddon", "Garr", "Al'Akir the Windlord"},

    loc_text = {
        "Scored {C:attention}Nature{} or {C:attention}Tank{} cards",
        "give {C:chips}+#1#{} Chips"
    },

    config = { extra = { base_chips = 30, scale_chips = 10 } },

    calculate_stats = function(ilvl, extra)
        return { extra.base_chips + ((ilvl - 1) * extra.scale_chips) } 
    end,

    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_damage(played_card, "Nature") or Warcraft.is_role(played_card, "Tank") then
                return {
                    chips = stats[1],
                    message = "Thunderfury!",
                    colour = G.C.CHIPS
                }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Frostmourne",
    index = 2, 
    
    req_level = 5, 
    req_class = {"Death Knight"},
    req_race = {"Undead", "Nathrezim"},
    req_faction = {"Scourge"},
    req_weapon = {"Sword"},
    combo_joker = {"Arthas Menethil", "Ner'zhul", "Zovaal"}, 

    loc_text = {
        "Scored {C:dark_edition}Scourge{} or {C:attention}Frost{} cards",
        "gain permanent {C:chips}+#1#{} Chips"
    },
    config = { extra = { base_chips = 15, scale_chips = 5 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_chips + ((ilvl - 1) * extra.scale_chips) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_faction(played_card, "Scourge") or Warcraft.is_damage(played_card, "Frost") then
                played_card.ability.perma_bonus = (played_card.ability.perma_bonus or 0) + stats[1]
                return { message = "Soul Harvest!", colour = G.C.CHIPS }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Sulfuras, Hand of Ragnaros",
    index = 3, 

    req_level = 6, 
    req_class = {"Shaman", "Warrior", "Paladin", "Death Knight", "Druid"},
    req_race = {"Elemental"},
    req_weapon = {"Hammer"},
    combo_joker = {"Ragnaros"},

    loc_text = {
        "Scored {C:red}Fire{} or {C:attention}Elemental{} cards",
        "give {X:mult,C:white} X#1# {} Mult"
    },
    config = { extra = { base_xmult = 1.5, scale_xmult = 0.1 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_xmult + ((ilvl - 1) * extra.scale_xmult) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_damage(played_card, "Fire") or Warcraft.is_race(played_card, "Elemental") then
                return { x_mult = stats[1], message = "By Fire Be Purged!", colour = G.C.MULT }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Warglaives of Azzinoth",
    index = 4, 

    req_level = 6, 
    req_class = {"Rogue", "Warrior", "Demon Hunter", "Death Knight", "Monk"},
    req_race = {"Demon", "Night Elf"},
    req_weapon = {"Glaives", "Daggers"},
    combo_joker = {"Illidan Stormrage", "Akama"},

    loc_text = {
        "Scored {C:attention}Demon{} or {C:purple}Night Elf{} cards",
        "give {X:chips,C:white} X#1# {} Chips"
    },
    config = { extra = { base_xchips = 1.5, scale_xchips = 0.1 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_xchips + ((ilvl - 1) * extra.scale_xchips) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_race(played_card, "Demon") or Warcraft.is_race(played_card, "Night Elf") then
                return { x_chips = stats[1], message = "You Are Not Prepared!", colour = G.C.CHIPS }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Atiesh",
    index = 5, 

    req_level = 6, 
    req_class = {"Mage", "Priest", "Warlock", "Druid"}, 
    req_race = {"Human", "Nathrezim"},
    req_weapon = {"Staff"},
    combo_joker = {"Medivh", "Khadgar", "Kel'Thuzad"},

    loc_text = {
        "{C:green}#1#% chance{} to generate a",
        "consumable when an {C:attention}Arcane{} or",
        "{C:attention}Druid{} card scores"
    },
    config = { extra = { base_chance = 15, scale_chance = 5 } },
    calculate_stats = function(ilvl, extra)
        return { math.min(100, extra.base_chance + ((ilvl - 1) * extra.scale_chance)) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_damage(played_card, "Arcane") or Warcraft.is_class(played_card, "Druid") then
                if pseudorandom("atiesh") < (stats[1] / 100) then
                    if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                        G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                local _card = create_card('Consumeables', G.consumeables, nil, nil, nil, nil, nil, 'atiesh')
                                _card:add_to_deck()
                                G.consumeables:emplace(_card)
                                G.GAME.consumeable_buffer = 0
                                return true
                            end
                        }))
                        return { message = "Conjured!", colour = G.C.PURPLE }
                    end
                end
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Dragonwrath, Tarecgosa's Rest",
    index = 6, 

    req_level = 6, 
    req_class = {"Mage", "Warlock", "Priest", "Druid", "Shaman"},
    req_race = {"Dragon"},
    req_weapon = {"Staff"},
    combo_joker = {"Tarecgosa", "Kalecgos"},

    loc_text = {
        "Scored {C:attention}Ranged Dps{} or {C:attention}Dragon{} cards",
        "give {C:mult}+#1#{} Mult"
    },
    config = { extra = { base_mult = 15, scale_mult = 5 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_mult + ((ilvl - 1) * extra.scale_mult) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_role(played_card, "Ranged Dps") or Warcraft.is_race(played_card, "Dragon") then
                return { mult = stats[1], message = "Tarecgosa's Rest!", colour = G.C.MULT }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Shadowmourne",
    index = 7, 

    req_level = 6, 
    req_class = {"Death Knight", "Warrior", "Paladin"},
    req_race = {"Human","Dwarf"},
    req_weapon = {"Axe"},
    combo_joker = {"Darion Mograine", "Arthas Menethil", "Tirion Fordring"},

    loc_text = {
        "Scored {C:dark_edition}Shadow{} or {C:attention}Death Knight{} cards",
        "gain permanent {C:chips}+#1#{} Chips"
    },
    config = { extra = { base_chips = 15, scale_chips = 5 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_chips + ((ilvl - 1) * extra.scale_chips) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_damage(played_card, "Shadow") or Warcraft.is_class(played_card, "Death Knight") then
                played_card.ability.perma_bonus = (played_card.ability.perma_bonus or 0) + stats[1]
                return { message = "Soul Fragments!", colour = G.C.CHIPS }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Val'anyr, Hammer of Ancient Kings",
    index = 8, 

    req_level = 6, 
    req_class = {"Paladin", "Priest", "Shaman", "Druid", "Monk"},
    req_race = {"Titan"},
    req_weapon = {"Hammer"},
    combo_joker = {"Yogg-Saron","Loken","Thorim"},

    loc_text = {
        "Scored {C:attention}Healer{} or {C:attention}Titan{} cards",
        "give {C:money}$#1#{}"
    },
    config = { extra = { base_money = 2, scale_money = 1 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_money + ((ilvl - 1) * extra.scale_money) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_role(played_card, "Healer") or Warcraft.is_race(played_card, "Titan") then
                ease_dollars(stats[1])
                return { message = "+$" .. stats[1], colour = G.C.MONEY }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Thori'dal, the Stars' Fury",
    index = 9, 

    req_level = 6, 
    req_class = {"Hunter", "Warrior", "Rogue"}, 
    req_weapon = {"Bow"},
    combo_joker = {"Sylvanas Windrunner", "Alleria Windrunner", "Kil'Jaeden"},

    loc_text = {
        "Scored {C:green}Hunter{} or {C:attention}Blood Elf{} cards",
        "give {X:mult,C:white} X#1# {} Mult"
    },
    config = { extra = { base_xmult = 1.5, scale_xmult = 0.1 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_xmult + ((ilvl - 1) * extra.scale_xmult) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_class(played_card, "Hunter") or Warcraft.is_race(played_card, "Blood Elf") then
                return { x_mult = stats[1], message = "Stars' Fury!", colour = G.C.MULT }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Rae'shalare, Death's Whisper",
    index = 10, 

    req_level = 6, 
    req_class = {"Hunter"}, 
    req_weapon = {"Bow"},
    combo_joker = {"Sylvanas Windrunner"},

    loc_text = {
        "{C:green}#1#% chance{} to generate a",
        "consumable when a {C:dark_edition}Shadow{} or",
        "{C:purple}Night Elf{} card scores"
    },
    config = { extra = { base_chance = 15, scale_chance = 5 } },
    calculate_stats = function(ilvl, extra)
        return { math.min(100, extra.base_chance + ((ilvl - 1) * extra.scale_chance)) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_damage(played_card, "Shadow") or Warcraft.is_race(played_card, "Night Elf") then
                if pseudorandom("raeshalare") < (stats[1] / 100) then
                    if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                        G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                local _card = create_card('Consumeables', G.consumeables, nil, nil, nil, nil, nil, 'raeshalare')
                                _card:add_to_deck()
                                G.consumeables:emplace(_card)
                                G.GAME.consumeable_buffer = 0
                                return true
                            end
                        }))
                        return { message = "Death's Whisper!", colour = G.C.PURPLE }
                    end
                end
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Nasz'uro, the Unbound Legacy",
    index = 11, 

    req_level = 6, 
    req_class = {"Evoker"}, 
    req_race = {"Dragon"},
    req_weapon = {"Fist Weapon"},
    combo_joker = {"Sarkareth", "Emberthal","Neltharion"},
    per_card = true,

    loc_text = {
        "{C:green}#1#% chance{} to upgrade",
        "played hand level when an",
        "{C:attention}Evoker{} or {C:attention}Dragon{} card scores"
    },
    config = { extra = { base_chance = 10, scale_chance = 2 } },
    calculate_stats = function(ilvl, extra)
        return { math.min(100, extra.base_chance + ((ilvl - 1) * extra.scale_chance)) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_class(played_card, "Evoker") or Warcraft.is_race(played_card, "Dragon") then
                if pseudorandom("naszuro") < (stats[1] / 100) then
                    SMODS.upgrade_poker_hands({hands = {context.scoring_name}, level_up = 1, from = card})
                    return { message = "Level Up!", colour = G.C.RED }
                end
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Fangs of the Father",
    index = 12, 

    req_level = 6, 
    req_class = {"Rogue"},
    req_weapon = {"Daggers"},
    combo_joker = {"Wrathion", "Neltharion"},

    loc_text = {
        "Scored {C:attention}Rogue{} or {C:attention}Dragon{} cards",
        "give {C:money}$#1#{}"
    },
    config = { extra = { base_money = 2, scale_money = 1 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_money + ((ilvl - 1) * extra.scale_money) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_class(played_card, "Rogue") or Warcraft.is_race(played_card, "Dragon") then
                ease_dollars(stats[1])
                return { message = "+$" .. stats[1], colour = G.C.MONEY }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Ashjra'kamas, Shroud of Resolve",
    index = 13, 

    req_level = 6, 
    combo_joker = {"Wrathion", "N'Zoth"},

    loc_text = {
        "Scored {C:attention}Pantheon{} or {C:dark_edition}Shadow{} cards",
        "gain permanent {C:chips}+#1#{} Chips"
    },
    config = { extra = { base_chips = 15, scale_chips = 5 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_chips + ((ilvl - 1) * extra.scale_chips) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_faction(played_card, "Pantheon") or Warcraft.is_damage(played_card, "Shadow") then
                played_card.ability.perma_bonus = (played_card.ability.perma_bonus or 0) + stats[1]
                return { message = "Void Absorbed!", colour = G.C.CHIPS }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Maw of the Damned",
    index = 14, 

    req_level = 6, 
    req_class = {"Death Knight"},
    req_race = {"Demon"},
    req_weapon = {"Axe"},
    combo_joker = {"Teron Gorefiend"},

    loc_text = {
        "Scored {C:attention}Tank{} or {C:attention}Death Knight{} cards",
        "gain permanent {C:chips}+#1#{} Chips"
    },
    config = { extra = { base_chips = 15, scale_chips = 5 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_chips + ((ilvl - 1) * extra.scale_chips) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_role(played_card, "Tank") or Warcraft.is_class(played_card, "Death Knight") then
                played_card.ability.perma_bonus = (played_card.ability.perma_bonus or 0) + stats[1]
                return { message = "Feast!", colour = G.C.CHIPS }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Blades of the Fallen Prince",
    index = 15, 

    req_level = 6, 
    req_class = {"Death Knight"},
    req_weapon = {"Sword"},
    combo_joker = {"Arthas Menethil", "Bolvar Fordragon", "Ner'zhul"},

    loc_text = {
        "Scored {C:attention}Frost{} or {C:attention}Death Knight{} cards",
        "give {X:chips,C:white} X#1# {} Chips"
    },
    config = { extra = { base_xchips = 1.5, scale_xchips = 0.1 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_xchips + ((ilvl - 1) * extra.scale_xchips) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_damage(played_card, "Frost") or Warcraft.is_class(played_card, "Death Knight") then
                return { x_chips = stats[1], message = "Frozen!", colour = G.C.CHIPS }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Apocalypse",
    index = 16, 

    req_level = 6, 
    req_class = {"Death Knight"},
    req_weapon = {"Sword"},
    combo_joker = {"Medivh"},

    loc_text = {
        "{C:green}#1#% chance{} to upgrade",
        "played hand level when a {C:attention}Death Knight{}",
        "or {C:attention}Undead{} card scores"
    },
    config = { extra = { base_chance = 10, scale_chance = 2 } },
    calculate_stats = function(ilvl, extra)
        return { math.min(100, extra.base_chance + ((ilvl - 1) * extra.scale_chance)) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_class(played_card, "Death Knight") or Warcraft.is_race(played_card, "Undead") then
                if pseudorandom("apocalypse") < (stats[1] / 100) then
                    SMODS.upgrade_poker_hands({hands = {context.scoring_name}, level_up = 1, from = card})
                    return { message = "Plague!", colour = G.C.GREEN }
                end
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Twinblades of the Deceiver",
    index = 17, 

    req_level = 6, 
    req_class = {"Demon Hunter"},
    req_race = {"Demon"},
    req_weapon = {"Glaives"},
    combo_joker = {"Kil'Jaeden", "Illidan Stormrage"},

    loc_text = {
        "Scored {C:attention}Demon Hunter{} or {C:purple}Night Elf{} cards",
        "give {X:chips,C:white} X#1# {} Chips"
    },
    config = { extra = { base_xchips = 1.5, scale_xchips = 0.1 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_xchips + ((ilvl - 1) * extra.scale_xchips) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_class(played_card, "Demon Hunter") or Warcraft.is_race(played_card, "Night Elf") then
                return { x_chips = stats[1], message = "Fel Strike!", colour = G.C.CHIPS }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Aldrachi Warblades",
    index = 18, 

    req_level = 6, 
    req_class = {"Demon Hunter"},
    req_weapon = {"Glaives"},
    combo_joker = {"Sargeras"},

    loc_text = {
        "Scored {C:attention}Tank{} or {C:attention}Leather{} cards",
        "gain permanent {C:chips}+#1#{} Chips"
    },
    config = { extra = { base_chips = 15, scale_chips = 5 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_chips + ((ilvl - 1) * extra.scale_chips) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_role(played_card, "Tank") or Warcraft.is_armor(played_card, "Leather") then
                played_card.ability.perma_bonus = (played_card.ability.perma_bonus or 0) + stats[1]
                return { message = "Soul Cleave!", colour = G.C.CHIPS }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Scythe of Elune",
    index = 19, 

    req_level = 6, 
    req_class = {"Druid"},
    req_race = {"Night Elf", "Worgen"},
    req_weapon = {"Staff"},
    combo_joker = {"Elune", "Goldrinn", "Archmage Arugal"},

    loc_text = {
        "Scored {C:attention}Arcane{} or {C:attention}Nature{} cards",
        "give {X:mult,C:white} X#1# {} Mult"
    },
    config = { extra = { base_xmult = 1.5, scale_xmult = 0.1 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_xmult + ((ilvl - 1) * extra.scale_xmult) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_damage(played_card, "Arcane") or Warcraft.is_damage(played_card, "Nature") then
                return { x_mult = stats[1], message = "Eclipse!", colour = G.C.MULT }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Fangs of Ashamane",
    index = 20, 

    req_level = 6, 
    req_class = {"Druid"}, 
    req_race = {"Night Elf","Troll"},
    req_weapon = {"Daggers"},
    combo_joker = {"Ashamane", "Xavius"},

    loc_text = {
        "Scored {C:attention}Melee Dps{} or {C:attention}Druid{} cards",
        "give {C:mult}+#1#{} Mult"
    },
    config = { extra = { base_mult = 15, scale_mult = 5 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_mult + ((ilvl - 1) * extra.scale_mult) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_role(played_card, "Melee Dps") or Warcraft.is_class(played_card, "Druid") then
                return { mult = stats[1], message = "Feral Strike!", colour = G.C.MULT }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Claws of Ursoc",
    index = 21, 

    req_level = 6, 
    req_class = {"Druid"},
    req_race = {"Furbolg", "Titan"},
    req_weapon = {"Fist Weapon"},
    combo_joker = {"Ursoc", "Freya", "Hamuul Runetotem"},

    loc_text = {
        "Scored {C:attention}Tank{} or {C:attention}Beast{} cards",
        "gain permanent {C:chips}+#1#{} Chips"
    },
    config = { extra = { base_chips = 15, scale_chips = 5 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_chips + ((ilvl - 1) * extra.scale_chips) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_role(played_card, "Tank") or Warcraft.is_race(played_card, "Beast") then
                played_card.ability.perma_bonus = (played_card.ability.perma_bonus or 0) + stats[1]
                return { message = "Thick Hide!", colour = G.C.CHIPS }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "G'Hanir, the Mother Tree",
    index = 22, 

    req_level = 6, 
    req_class = {"Druid"},
    req_race = {"Dragon", "Night Elf"},
    req_weapon = {"Staff"},
    combo_joker = {"Aviana", "Ysera"},

    loc_text = {
        "{C:green}#1#% chance{} to upgrade",
        "played hand level when a {C:attention}Healer{}",
        "or {C:attention}Nature{} card scores"
    },
    config = { extra = { base_chance = 10, scale_chance = 2 } },
    calculate_stats = function(ilvl, extra)
        return { math.min(100, extra.base_chance + ((ilvl - 1) * extra.scale_chance)) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_role(played_card, "Healer") or Warcraft.is_damage(played_card, "Nature") then
                if pseudorandom("ghanir") < (stats[1] / 100) then
                    SMODS.upgrade_poker_hands({hands = {context.scoring_name}, level_up = 1, from = card})
                    return { message = "Flourish!", colour = G.C.GREEN }
                end
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Titanstrike",
    index = 23, 

    req_level = 6, 
    req_class = {"Hunter"},
    req_race = {"Human","Dwarf"},
    req_weapon = {"Gun"},
    combo_joker = {"Mimiron","Thorim","Brann Bronzebeard"},

    loc_text = {
        "Scored {C:attention}Hunter{} or {C:attention}Beast{} cards",
        "give {X:chips,C:white} X#1# {} Chips"
    },
    config = { extra = { base_xchips = 1.5, scale_xchips = 0.1 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_xchips + ((ilvl - 1) * extra.scale_xchips) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_class(played_card, "Hunter") or Warcraft.is_race(played_card, "Beast") then
                return { x_chips = stats[1], message = "Titanstrike!", colour = G.C.CHIPS }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Thas'dorah, Legacy of the Windrunners",
    index = 24, 

    req_level = 6, 
    req_class = {"Hunter", "Ranger"},
    req_race = {"Blood Elf","Void Elf"},
    req_weapon = {"Bow"},
    combo_joker = {"Alleria Windrunner", "Sylvanas Windrunner", "Vereesa Windrunner"},

    loc_text = {
        "Scored {C:attention}Hunter{} or {C:attention}Ranged Dps{} cards",
        "give {C:mult}+#1#{} Mult"
    },
    config = { extra = { base_mult = 15, scale_mult = 5 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_mult + ((ilvl - 1) * extra.scale_mult) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_class(played_card, "Hunter") or Warcraft.is_role(played_card, "Ranged Dps") then
                return { mult = stats[1], message = "Windburst!", colour = G.C.MULT }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Talonclaw",
    index = 25, 

    req_level = 6, 
    req_class = {"Hunter"},
    req_race = {"Tauren"},
    req_weapon = {"Polearm","Spear"},
    combo_joker = {"Huln Highmountain", "Ohn'ahra"},

    loc_text = {
        "Scored {C:attention}Hunter{} or {C:attention}Tauren{} cards",
        "gain permanent {C:chips}+#1#{} Chips"
    },
    config = { extra = { base_chips = 15, scale_chips = 5 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_chips + ((ilvl - 1) * extra.scale_chips) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_class(played_card, "Hunter") or Warcraft.is_race(played_card, "Tauren") then
                played_card.ability.perma_bonus = (played_card.ability.perma_bonus or 0) + stats[1]
                return { message = "Savage Strike!", colour = G.C.CHIPS }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Aluneth",
    index = 26, 

    req_level = 6, 
    req_class = {"Mage"},
    req_weapon = {"Staff"},
    req_race = {"Human"},
    combo_joker = {"Aegwynn", "Malygos"},

    loc_text = {
        "Scored {C:attention}Arcane{} or {C:attention}Mage{} cards",
        "give {X:mult,C:white} X#1# {} Mult"
    },
    config = { extra = { base_xmult = 1.5, scale_xmult = 0.1 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_xmult + ((ilvl - 1) * extra.scale_xmult) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_damage(played_card, "Arcane") or Warcraft.is_class(played_card, "Mage") then
                return { x_mult = stats[1], message = "Overload!", colour = G.C.MULT }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Felo'melorn",
    index = 27, 

    req_level = 6, 
    req_class = {"Mage"},
    req_weapon = {"Sword"},
    req_race = {"Blood Elf"},
    combo_joker = {"Kael'thas Sunstrider"},

    loc_text = {
        "Scored {C:attention}Mage{} or {C:red}Fire{} cards",
        "give {C:chips}+#1#{} Chips"
    },
    config = { extra = { base_chips = 30, scale_chips = 10 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_chips + ((ilvl - 1) * extra.scale_chips) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_class(played_card, "Mage") or Warcraft.is_damage(played_card, "Fire") then
                return { chips = stats[1], message = "Flamestrike!", colour = G.C.CHIPS }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Ebonchill",
    index = 28, 

    req_level = 6, 
    req_class = {"Mage"},
    req_race = {"Human", "Nathrezim"},
    req_weapon = {"Staff"},
    combo_joker = {"Jaina Proudmoore"},

    loc_text = {
        "Scored {C:attention}Frost{} or {C:attention}Cloth{} cards",
        "give {X:chips,C:white} X#1# {} Chips"
    },
    config = { extra = { base_xchips = 1.5, scale_xchips = 0.1 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_xchips + ((ilvl - 1) * extra.scale_xchips) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_damage(played_card, "Frost") or Warcraft.is_armor(played_card, "Cloth") then
                return { x_chips = stats[1], message = "Deep Freeze!", colour = G.C.CHIPS }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Fu Zan, the Wanderer's Companion",
    index = 29, 

    req_level = 6, 
    req_class = {"Monk"},
    req_weapon = {"Staff"},
    req_race = {"Pandaren"},
    combo_joker = {"Yu'lon", "Chen Stormstout"},

    loc_text = {
        "Scored {C:attention}Monk{} or {C:attention}Tank{} cards",
        "give {C:chips}+#1#{} Chips"
    },
    config = { extra = { base_chips = 30, scale_chips = 10 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_chips + ((ilvl - 1) * extra.scale_chips) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_class(played_card, "Monk") or Warcraft.is_role(played_card, "Tank") then
                return { chips = stats[1], message = "Keg Smash!", colour = G.C.CHIPS }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Sheilun, Staff of the Mists",
    index = 30, 

    req_level = 6, 
    req_class = {"Monk"},
    req_weapon = {"Staff"},
    req_race = {"Pandaren"},
    combo_joker = {"Emperor Shaohao", "Taran Zhu"},

    loc_text = {
        "{C:green}#1#% chance{} to generate a",
        "consumable when a {C:attention}Healer{} or",
        "{C:attention}Pandaren{} card scores"
    },
    config = { extra = { base_chance = 15, scale_chance = 5 } },
    calculate_stats = function(ilvl, extra)
        return { math.min(100, extra.base_chance + ((ilvl - 1) * extra.scale_chance)) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_role(played_card, "Healer") or Warcraft.is_race(played_card, "Pandaren") then
                if pseudorandom("sheilun") < (stats[1] / 100) then
                    if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                        G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                local _card = create_card('Consumeables', G.consumeables, nil, nil, nil, nil, nil, 'sheilun')
                                _card:add_to_deck()
                                G.consumeables:emplace(_card)
                                G.GAME.consumeable_buffer = 0
                                return true
                            end
                        }))
                        return { message = "Mists Gather!", colour = G.C.GREEN }
                    end
                end
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Fists of the Heavens",
    index = 31, 

    req_level = 6, 
    req_class = {"Monk"}, 
    req_weapon = {"Fist Weapons"},
    req_race = {"Elemental"},
    combo_joker = {"Al'Akir the Windlord", "Li Li Stormstout"},

    loc_text = {
        "Scored {C:attention}Melee Dps{} or {C:attention}Monk{} cards",
        "give {X:chips,C:white} X#1# {} Chips"
    },
    config = { extra = { base_xchips = 1.5, scale_xchips = 0.1 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_xchips + ((ilvl - 1) * extra.scale_xchips) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_role(played_card, "Melee Dps") or Warcraft.is_class(played_card, "Monk") then
                return { x_chips = stats[1], message = "Fists of Fury!", colour = G.C.CHIPS }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "The Silver Hand",
    index = 32, 

    req_level = 6, 
    req_class = {"Paladin"}, 
    req_weapon = {"Hammer"},
    req_race = {"Human","Titan"},
    combo_joker = {"Tyr"},

    loc_text = {
        "{C:green}#1#% chance{} to upgrade",
        "played hand level when a {C:attention}Paladin{}",
        "or {C:attention}Holy{} card scores"
    },
    config = { extra = { base_chance = 10, scale_chance = 2 } },
    calculate_stats = function(ilvl, extra)
        return { math.min(100, extra.base_chance + ((ilvl - 1) * extra.scale_chance)) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_class(played_card, "Paladin") or Warcraft.is_damage(played_card, "Holy") then
                if pseudorandom("silverhand") < (stats[1] / 100) then
                    SMODS.upgrade_poker_hands({hands = {context.scoring_name}, level_up = 1, from = card})
                    return { message = "Blessed!", colour = G.C.GOLD }
                end
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Truthguard",
    index = 33, 

    req_level = 6, 
    req_class = {"Paladin"}, 
    req_weapon = {"Shield"},
    req_race = {"Titan"},
    combo_joker = {"Tyr", "Odyn"},

    loc_text = {
        "Scored {C:attention}Tank{} or {C:attention}Plate{} cards",
        "gain permanent {C:chips}+#1#{} Chips"
    },
    config = { extra = { base_chips = 15, scale_chips = 5 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_chips + ((ilvl - 1) * extra.scale_chips) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_role(played_card, "Tank") or Warcraft.is_armor(played_card, "Plate") then
                played_card.ability.perma_bonus = (played_card.ability.perma_bonus or 0) + stats[1]
                return { message = "Bulwark!", colour = G.C.CHIPS }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Ashbringer",
    index = 34, 

    req_level = 6, 
    req_class = {"Paladin"}, 
    req_weapon = {"Sword"},
    combo_joker = {"Tirion Fordring", "Alexandros Mograine", "Darion Mograine", "Magni Bronzebeard"},

    loc_text = {
        "Scored {C:attention}Paladin{} or {C:attention}Human{} cards",
        "give {X:chips,C:white} X#1# {} Chips"
    },
    config = { extra = { base_xchips = 1.5, scale_xchips = 0.1 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_xchips + ((ilvl - 1) * extra.scale_xchips) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_class(played_card, "Paladin") or Warcraft.is_race(played_card, "Human") then
                return { x_chips = stats[1], message = "Ashbringer!", colour = G.C.CHIPS }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Corrupted Ashbringer",
    index = 35, 

    req_level = 6, 
    req_class = {"Warrior","Paladin","Hunter","Death Knight"}, 
    req_weapon = {"Sword"},
    combo_joker = {"Alexandros Mograine", "Darion Mograine"},

    loc_text = {
        "Scored {C:attention}Death Knight{} or {C:dark_edition}Shadow{} cards",
        "gain permanent {C:chips}+#1#{} Chips"
    },
    config = { extra = { base_chips = 15, scale_chips = 5 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_chips + ((ilvl - 1) * extra.scale_chips) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_class(played_card, "Death Knight") or Warcraft.is_damage(played_card, "Shadow") then
                played_card.ability.perma_bonus = (played_card.ability.perma_bonus or 0) + stats[1]
                return { message = "Corrupted!", colour = G.C.CHIPS }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Light's Wrath",
    index = 36, 

    req_level = 6, 
    req_class = {"Priest"}, 
    req_weapon = {"Staff"},
    combo_joker = {"Sally Whitemane"},

    loc_text = {
        "Scored {C:attention}Priest{} or {C:attention}Holy{} cards",
        "give {X:mult,C:white} X#1# {} Mult"
    },
    config = { extra = { base_xmult = 1.5, scale_xmult = 0.1 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_xmult + ((ilvl - 1) * extra.scale_xmult) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_class(played_card, "Priest") or Warcraft.is_damage(played_card, "Holy") then
                return { x_mult = stats[1], message = "Light's Wrath!", colour = G.C.MULT }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "T'uure",
    index = 37, 

    req_level = 6, 
    req_class = {"Priest"}, 
    req_weapon = {"Staff"},
    req_race = {"Draenei", "Naaru"},
    combo_joker = {"Prophet Velen"},

    loc_text = {
        "Scored {C:attention}Draenei{} or {C:attention}Naaru{} cards",
        "give {C:mult}+#1#{} Mult"
    },
    config = { extra = { base_mult = 15, scale_mult = 5 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_mult + ((ilvl - 1) * extra.scale_mult) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_race(played_card, "Draenei") or Warcraft.is_race(played_card, "Naaru") then
                return { mult = stats[1], message = "Beacon of Light!", colour = G.C.MULT }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Xal'atath",
    index = 38, 

    req_level = 6, 
    req_class = {"Priest"},
    req_race = {"God"},
    req_weapon = {"Daggers"},
    combo_joker = {"Xal'atath"},

    loc_text = {
        "Scored {C:dark_edition}Shadow{} or {C:attention}Priest{} cards",
        "give {X:mult,C:white} X#1# {} Mult"
    },
    config = { extra = { base_xmult = 1.5, scale_xmult = 0.1 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_xmult + ((ilvl - 1) * extra.scale_xmult) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_damage(played_card, "Shadow") or Warcraft.is_class(played_card, "Priest") then
                return { x_mult = stats[1], message = "Madness!", colour = G.C.MULT }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "The Kingslayers",
    index = 39, 

    req_level = 6, 
    req_class = {"Rogue"}, 
    req_weapon = {"Daggers"},
    req_race = {"Orc"},
    combo_joker = {"Garona Halforcen", "Gul'dan"},

    loc_text = {
        "Scored {C:attention}Rogue{} or {C:attention}Physical{} cards",
        "give {X:chips,C:white} X#1# {} Chips"
    },
    config = { extra = { base_xchips = 1.5, scale_xchips = 0.1 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_xchips + ((ilvl - 1) * extra.scale_xchips) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_class(played_card, "Rogue") or Warcraft.is_damage(played_card, "Physical") then
                return { x_chips = stats[1], message = "Assassinate!", colour = G.C.CHIPS }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "The Dreadblades",
    index = 40, 

    req_level = 6, 
    req_class = {"Rogue"}, 
    req_weapon = {"Sword"},
    combo_joker = {"Dread Admiral Eliza", "Fleet Admiral Tethys", "Helya"},

    loc_text = {
        "Scored {C:attention}Rogue{} or {C:attention}Pirate{} cards",
        "give {C:money}$#1#{}"
    },
    config = { extra = { base_money = 2, scale_money = 1 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_money + ((ilvl - 1) * extra.scale_money) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_class(played_card, "Rogue") or Warcraft.is_faction(played_card, "Pirate") then
                ease_dollars(stats[1])
                return { message = "+$" .. stats[1], colour = G.C.MONEY }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Fangs of the Devourer",
    index = 41, 

    req_level = 6, 
    req_class = {"Rogue"}, 
    req_weapon = {"Daggers"},
    req_race = {"Demon"},
    req_faction = {"Legion"},
    combo_joker = {"Taoshi"},

    loc_text = {
        "Scored {C:dark_edition}Shadow{} or {C:attention}Physical{} cards",
        "gain permanent {C:chips}+#1#{} Chips"
    },
    config = { extra = { base_chips = 15, scale_chips = 5 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_chips + ((ilvl - 1) * extra.scale_chips) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_damage(played_card, "Shadow") or Warcraft.is_damage(played_card, "Physical") then
                played_card.ability.perma_bonus = (played_card.ability.perma_bonus or 0) + stats[1]
                return { message = "Devoured!", colour = G.C.CHIPS }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Fist of Ra-den",
    index = 42, 

    req_level = 6, 
    req_class = {"Shaman"}, 
    req_weapon = {"Fist Weapon"},
    req_race = {"Pandaren","Titan"},
    combo_joker = {"Ra-den", "Lei Shen", "Xuen", "Morgl the Oracle"},

    loc_text = {
        "Scored {C:attention}Nature{} or {C:attention}Shaman{} cards",
        "give {X:chips,C:white} X#1# {} Chips"
    },
    config = { extra = { base_xchips = 1.5, scale_xchips = 0.1 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_xchips + ((ilvl - 1) * extra.scale_xchips) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_damage(played_card, "Nature") or Warcraft.is_class(played_card, "Shaman") then
                return { x_chips = stats[1], message = "Lightning!", colour = G.C.CHIPS }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Doomhammer",
    index = 43, 

    req_level = 6, 
    req_class = {"Shaman"}, 
    req_weapon = {"Hammer"},
    req_race = {"Orc"},
    combo_joker = {"Thrall", "Orgrim Doomhammer", "Morgl the Oracle"},

    loc_text = {
        "Scored {C:attention}Shaman{} or {C:attention}Orc{} cards",
        "give {X:mult,C:white} X#1# {} Mult"
    },
    config = { extra = { base_xmult = 1.5, scale_xmult = 0.1 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_xmult + ((ilvl - 1) * extra.scale_xmult) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_class(played_card, "Shaman") or Warcraft.is_race(played_card, "Orc") then
                return { x_mult = stats[1], message = "Doomwinds!", colour = G.C.MULT }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Sharas'dal",
    index = 44, 

    req_level = 6, 
    req_class = {"Shaman"},
    req_race = {"Night Elf", "Naga"},
    req_weapon = {"Staff"},
    combo_joker = {"Queen Azshara", "Morgl the Oracle"},

    loc_text = {
        "{C:green}#1#% chance{} to generate a",
        "consumable when a {C:attention}Frost{} or",
        "{C:attention}Healer{} card scores"
    },
    config = { extra = { base_chance = 15, scale_chance = 5 } },
    calculate_stats = function(ilvl, extra)
        return { math.min(100, extra.base_chance + ((ilvl - 1) * extra.scale_chance)) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_damage(played_card, "Frost") or Warcraft.is_role(played_card, "Healer") then
                if pseudorandom("sharasdal") < (stats[1] / 100) then
                    if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                        G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                local _card = create_card('Consumeables', G.consumeables, nil, nil, nil, nil, nil, 'sharasdal')
                                _card:add_to_deck()
                                G.consumeables:emplace(_card)
                                G.GAME.consumeable_buffer = 0
                                return true
                            end
                        }))
                        return { message = "Tides!", colour = G.C.BLUE }
                    end
                end
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Ulthalesh",
    index = 45, 

    req_level = 6, 
    req_class = {"Warlock"}, 
    req_weapon = {"Staff"},
    req_race = {"Demon"},
    req_faction = {"Legion"},
    combo_joker = {"Sargeras", "Medivh"},

    loc_text = {
        "Scored {C:attention}Warlock{} or {C:dark_edition}Shadow{} cards",
        "gain permanent {C:chips}+#1#{} Chips"
    },
    config = { extra = { base_chips = 15, scale_chips = 5 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_chips + ((ilvl - 1) * extra.scale_chips) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_class(played_card, "Warlock") or Warcraft.is_damage(played_card, "Shadow") then
                played_card.ability.perma_bonus = (played_card.ability.perma_bonus or 0) + stats[1]
                return { message = "Reaped!", colour = G.C.CHIPS }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Skull of the Man'ari",
    index = 46, 

    req_level = 6, 
    req_class = {"Warlock"},
    req_race = {"Demon"},
    req_faction = {"Legion"},
    req_weapon = {"Shield"},
    combo_joker = {"Archimonde"},

    loc_text = {
        "Scored {C:attention}Legion{} or {C:attention}Demon{} cards",
        "give {C:mult}+#1#{} Mult"
    },
    config = { extra = { base_mult = 15, scale_mult = 5 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_mult + ((ilvl - 1) * extra.scale_mult) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_faction(played_card, "Legion") or Warcraft.is_race(played_card, "Demon") then
                return { mult = stats[1], message = "Consumed!", colour = G.C.MULT }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Scepter of Sargeras",
    index = 47, 

    req_level = 6, 
    req_class = {"Warlock"}, 
    req_weapon = {"Staff"},
    req_race = {"Demon"},
    req_faction = {"Legion", "Orc"},
    combo_joker = {"Sargeras", "Ner'zhul", "Gul'dan"},

    loc_text = {
        "Scored {C:red}Fire{} or {C:attention}Warlock{} cards",
        "give {X:mult,C:white} X#1# {} Mult"
    },
    config = { extra = { base_xmult = 1.5, scale_xmult = 0.1 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_xmult + ((ilvl - 1) * extra.scale_xmult) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_damage(played_card, "Fire") or Warcraft.is_class(played_card, "Warlock") then
                return { x_mult = stats[1], message = "Rift!", colour = G.C.MULT }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Strom'kar",
    index = 48, 

    req_level = 6, 
    req_class = {"Warrior"}, 
    req_weapon = {"Sword"},
    req_race = {"Troll"},

    loc_text = {
        "Scored {C:attention}Warrior{} or {C:attention}Human{} cards",
        "give {X:chips,C:white} X#1# {} Chips"
    },
    config = { extra = { base_xchips = 1.5, scale_xchips = 0.1 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_xchips + ((ilvl - 1) * extra.scale_xchips) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_class(played_card, "Warrior") or Warcraft.is_race(played_card, "Human") then
                return { x_chips = stats[1], message = "Warbreaker!", colour = G.C.CHIPS }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Warswords of the Valarjar",
    index = 49, 

    req_level = 6, 
    req_class = {"Warrior"},
    req_weapon = {"Sword"},
    req_race = {"Titan"},
    combo_joker = {"Odyn", "Helya"},

    loc_text = {
        "Scored {C:attention}Physical{} or {C:attention}Plate{} cards",
        "give {X:mult,C:white} X#1# {} Mult"
    },
    config = { extra = { base_xmult = 1.5, scale_xmult = 0.1 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_xmult + ((ilvl - 1) * extra.scale_xmult) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_damage(played_card, "Physical") or Warcraft.is_armor(played_card, "Plate") then
                return { x_mult = stats[1], message = "Odyn's Fury!", colour = G.C.MULT }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Scale of the Earth-Warder",
    index = 50, 

    req_level = 6, 
    req_class = {"Warrior"}, 
    req_weapon = {"Shield"},
    req_race = {"Dragon"},
    combo_joker = {"Neltharion", "Huln Highmountain"},

    loc_text = {
        "Scored {C:attention}Tank{} or {C:red}Fire{} cards",
        "gain permanent {C:chips}+#1#{} Chips"
    },
    config = { extra = { base_chips = 15, scale_chips = 5 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_chips + ((ilvl - 1) * extra.scale_chips) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_role(played_card, "Tank") or Warcraft.is_damage(played_card, "Fire") then
                played_card.ability.perma_bonus = (played_card.ability.perma_bonus or 0) + stats[1]
                return { message = "Earth-Warder!", colour = G.C.CHIPS }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Scythe of the Unmaker",
    index = 51, 

    req_level = 6, 
    req_class = {"Warrior","Paladin","Hunter","Monk","Death Knight"}, 
    req_weapon = {"Polearm"},
    req_race = {"Titan"},
    combo_joker = {"Argus the Unmaker"},

    loc_text = {
        "{C:green}#1#% chance{} to upgrade",
        "played hand level when a {C:attention}Titan{}",
        "or {C:attention}Arcane{} card scores"
    },
    config = { extra = { base_chance = 10, scale_chance = 2 } },
    calculate_stats = function(ilvl, extra)
        return { math.min(100, extra.base_chance + ((ilvl - 1) * extra.scale_chance)) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_race(played_card, "Titan") or Warcraft.is_damage(played_card, "Arcane") then
                if pseudorandom("scythe_unmaker") < (stats[1] / 100) then
                    SMODS.upgrade_poker_hands({hands = {context.scoring_name}, level_up = 1, from = card})
                    return { message = "Unmade!", colour = G.C.PURPLE }
                end
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Gavel of the First Arbiter",
    index = 52, 

    req_level = 6, 
    req_class = {"Priest"}, 
    req_weapon = {"Hammer"},
    req_race = {"God"},
    combo_joker = {"Zovaal"},

    loc_text = {
        "Scored {C:attention}Pantheon{} or {C:attention}God{} cards",
        "give {X:chips,C:white} X#1# {} Chips"
    },
    config = { extra = { base_xchips = 1.5, scale_xchips = 0.1 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_xchips + ((ilvl - 1) * extra.scale_xchips) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_faction(played_card, "Pantheon") or Warcraft.is_race(played_card, "God") then
                return { x_chips = stats[1], message = "Judgement!", colour = G.C.CHIPS }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Arcanite Reaper",
    index = 53, 

    req_level = 6, 
    req_class = {"Warrior","Paladin"}, 
    req_weapon = {"Axe"},
    req_faction = {"Horde","Alliance"},

    loc_text = {
        "Scored {C:attention}Warrior{} or {C:attention}Blacksmith{} cards",
        "give {X:chips,C:white} X#1# {} Chips"
    },
    config = { extra = { base_xchips = 1.5, scale_xchips = 0.1 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_xchips + ((ilvl - 1) * extra.scale_xchips) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_class(played_card, "Warrior") or Warcraft.is_profession(played_card, "Blacksmith") then
                return { x_chips = stats[1], message = "Execute!", colour = G.C.CHIPS }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Horde Insignia",
    index = 54, 

    req_level = 1, 
    req_class = {"Any"}, 
    req_faction = {"Horde"},
    combo_joker = {"Thrall", "Drek'Thar"},

    loc_text = {
        "Scored {C:red}Horde{} or {C:attention}Orc{} cards",
        "give {C:money}$#1#{}"
    },
    config = { extra = { base_money = 2, scale_money = 1 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_money + ((ilvl - 1) * extra.scale_money) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_faction(played_card, "Horde") or Warcraft.is_race(played_card, "Orc") then
                ease_dollars(stats[1])
                return { message = "+$" .. stats[1], colour = G.C.MONEY }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Alliance Insignia",
    index = 55, 

    req_level = 1, 
    req_class = {"Any"}, 
    req_faction = {"Alliance"},
    combo_joker = {"Anduin Wrynn", "Varian Wrynn", "Vanndar Stormpike"},

    loc_text = {
        "Scored {C:blue}Alliance{} or {C:attention}Human{} cards",
        "give {C:money}$#1#{}"
    },
    config = { extra = { base_money = 2, scale_money = 1 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_money + ((ilvl - 1) * extra.scale_money) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_faction(played_card, "Alliance") or Warcraft.is_race(played_card, "Human") then
                ease_dollars(stats[1])
                return { message = "+$" .. stats[1], colour = G.C.MONEY }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Benediction",
    index = 56, 

    req_level = 6, 
    req_class = {"Priest"}, 
    req_weapon = {"Staff"},
    combo_joker = {"Majordomo Executus"},

    loc_text = {
        "Scored {C:attention}Priest{} or {C:attention}Holy{} cards",
        "give {X:mult,C:white} X#1# {} Mult"
    },
    config = { extra = { base_xmult = 1.5, scale_xmult = 0.1 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_xmult + ((ilvl - 1) * extra.scale_xmult) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_class(played_card, "Priest") or Warcraft.is_damage(played_card, "Holy") then
                return { x_mult = stats[1], message = "Holy Light!", colour = G.C.MULT }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Gorehowl",
    index = 57, 

    req_level = 6, 
    req_class = {"Warrior","Paladin","Death Knight"}, 
    req_weapon = {"Axe"},
    req_race = {"Orc"},
    combo_joker = {"Grommash Hellscream", "Garrosh Hellscream", "Thrall"},

    loc_text = {
        "Scored {C:attention}Orc{} or {C:attention}Warrior{} cards",
        "gain permanent {C:chips}+#1#{} Chips"
    },
    config = { extra = { base_chips = 15, scale_chips = 5 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_chips + ((ilvl - 1) * extra.scale_chips) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_race(played_card, "Orc") or Warcraft.is_class(played_card, "Warrior") then
                played_card.ability.perma_bonus = (played_card.ability.perma_bonus or 0) + stats[1]
                return { message = "Warsong!", colour = G.C.CHIPS }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Quel'Delar",
    index = 58, 

    req_level = 6, 
    req_class = {"Any"}, 
    req_weapon = {"Sword"},
    req_race = {"Blood Elf"},

    loc_text = {
        "Scored {C:attention}Blood Elf{} or {C:attention}Arcane{} cards",
        "give {X:mult,C:white} X#1# {} Mult"
    },
    config = { extra = { base_xmult = 1.5, scale_xmult = 0.1 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_xmult + ((ilvl - 1) * extra.scale_xmult) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_race(played_card, "Blood Elf") or Warcraft.is_damage(played_card, "Arcane") then
                return { x_mult = stats[1], message = "Sunwell!", colour = G.C.MULT }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Armageddon",
    index = 59, 

    req_level = 6, 
    req_class = {"Death Knight", "Paladin", "Warrior"}, 
    req_weapon = {"Sword"},
    req_race = {"Undead"},
    combo_joker = {"Alexandros Mograine", "Kel'Thuzad"},

    loc_text = {
        "Scored {C:attention}Death Knight{} or {C:attention}Warrior{} cards",
        "give {X:chips,C:white} X#1# {} Chips"
    },
    config = { extra = { base_xchips = 1.5, scale_xchips = 0.1 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_xchips + ((ilvl - 1) * extra.scale_xchips) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_class(played_card, "Death Knight") or Warcraft.is_class(played_card, "Warrior") then
                return { x_chips = stats[1], message = "Apocalypse!", colour = G.C.CHIPS }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Gurthalak",
    index = 60, 

    req_level = 6, 
    req_class = {"Warrior","Paladin", "Death Knight"},
    req_race = {"Dragon"},
    req_weapon = {"Sword"},
    combo_joker = {"Neltharion","N'Zoth"},

    loc_text = {
        "{C:green}#1#% chance{} to generate a",
        "consumable when a {C:dark_edition}Shadow{} or",
        "{C:attention}Dragon{} card scores"
    },
    config = { extra = { base_chance = 15, scale_chance = 5 } },
    calculate_stats = function(ilvl, extra)
        return { math.min(100, extra.base_chance + ((ilvl - 1) * extra.scale_chance)) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_damage(played_card, "Shadow") or Warcraft.is_race(played_card, "Dragon") then
                if pseudorandom("gurthalak") < (stats[1] / 100) then
                    if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                        G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                local _card = create_card('Consumeables', G.consumeables, nil, nil, nil, nil, nil, 'gurthalak')
                                _card:add_to_deck()
                                G.consumeables:emplace(_card)
                                G.GAME.consumeable_buffer = 0
                                return true
                            end
                        }))
                        return { message = "Tentacle!", colour = G.C.DARK_EDITION }
                    end
                end
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Tusks of Mannoroth",
    index = 61, 

    req_level = 6, 
    req_class = {"Warrior","Paladin","Death Knight"}, 
    req_race = {"Orc"},
    combo_joker = {"Mannoroth","Grommash Hellscream","Garrosh Hellscream"},

    loc_text = {
        "Scored {C:attention}Demon{} or {C:attention}Orc{} cards",
        "gain permanent {C:chips}+#1#{} Chips"
    },
    config = { extra = { base_chips = 15, scale_chips = 5 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_chips + ((ilvl - 1) * extra.scale_chips) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_race(played_card, "Demon") or Warcraft.is_race(played_card, "Orc") then
                played_card.ability.perma_bonus = (played_card.ability.perma_bonus or 0) + stats[1]
                return { message = "Conqueror!", colour = G.C.CHIPS }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "The Black Hand",
    index = 62, 

    req_level = 6, 
    req_class = {"Warrior","Paladin","Death Knight"}, 
    req_weapon = {"Hammer"},
    req_race = {"Orc"},
    combo_joker = {"Blackhand","Garrosh Hellscream"},

    loc_text = {
        "Scored {C:red}Fire{} or {C:attention}Physical{} cards",
        "give {X:chips,C:white} X#1# {} Chips"
    },
    config = { extra = { base_xchips = 1.5, scale_xchips = 0.1 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_xchips + ((ilvl - 1) * extra.scale_xchips) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_damage(played_card, "Fire") or Warcraft.is_damage(played_card, "Physical") then
                return { x_chips = stats[1], message = "Shattered!", colour = G.C.CHIPS }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Arcanocrystal",
    index = 63, 

    req_level = 6, 
    req_class = {"Any"}, 
    combo_joker = {"Khadgar", "Runas the Shamed"},

    loc_text = {
        "Scored {C:attention}Arcane{} or {C:attention}Ranged Dps{} cards",
        "give {X:mult,C:white} X#1# {} Mult"
    },
    config = { extra = { base_xmult = 1.5, scale_xmult = 0.1 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_xmult + ((ilvl - 1) * extra.scale_xmult) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_damage(played_card, "Arcane") or Warcraft.is_role(played_card, "Ranged Dps") then
                return { x_mult = stats[1], message = "Unstable!", colour = G.C.MULT }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Convergence of Fates",
    index = 64, 

    req_level = 6, 
    req_class = {"Any"}, 
    combo_joker = {"Grand Magistrix Elisande"},

    loc_text = {
        "{C:green}#1#% chance{} to upgrade",
        "played hand level when a {C:purple}Night Elf{}",
        "or {C:attention}Melee Dps{} card scores"
    },
    config = { extra = { base_chance = 10, scale_chance = 2 } },
    calculate_stats = function(ilvl, extra)
        return { math.min(100, extra.base_chance + ((ilvl - 1) * extra.scale_chance)) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_race(played_card, "Night Elf") or Warcraft.is_role(played_card, "Melee Dps") then
                if pseudorandom("convergence") < (stats[1] / 100) then
                    SMODS.upgrade_poker_hands({hands = {context.scoring_name}, level_up = 1, from = card})
                    return { message = "Fate Aligned!", colour = G.C.PURPLE }
                end
            end
        end
    end
})

Warcraft.create_equipment({
    name = "First Satyr Spaulders",
    index = 65, 

    req_level = 6, 
    req_class = {"Druid","Rogue","Monk","Demon Hunter"}, 
    combo_joker = {"Xavius","Malfurion Stormrage"},

    loc_text = {
        "Scored {C:attention}Leather{} or {C:attention}Demon{} cards",
        "gain permanent {C:chips}+#1#{} Chips"
    },
    config = { extra = { base_chips = 15, scale_chips = 5 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_chips + ((ilvl - 1) * extra.scale_chips) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_armor(played_card, "Leather") or Warcraft.is_race(played_card, "Demon") then
                played_card.ability.perma_bonus = (played_card.ability.perma_bonus or 0) + stats[1]
                return { message = "Nightmare!", colour = G.C.CHIPS }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Sephuz's Secret",
    index = 66, 

    req_level = 6, 
    req_class = {"Any"}, 
    combo_joker = {"Khadgar"},

    loc_text = {
        "Scored {C:attention}Tank{} or {C:attention}Healer{} cards",
        "give {X:mult,C:white} X#1# {} Mult"
    },
    config = { extra = { base_xmult = 1.5, scale_xmult = 0.1 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_xmult + ((ilvl - 1) * extra.scale_xmult) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_role(played_card, "Tank") or Warcraft.is_role(played_card, "Healer") then
                return { x_mult = stats[1], message = "Secret!", colour = G.C.MULT }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Geti'ikku, Cut of Death",
    index = 67, 

    req_level = 6, 
    req_class = {"Warrior","Paladin", "Death Knight"}, 
    req_weapon = {"Sword"},
    req_race = {"Troll"},
    combo_joker = {"Bwonsamdi"},

    loc_text = {
        "Scored {C:attention}Physical{} or {C:attention}Troll{} cards",
        "gain permanent {C:chips}+#1#{} Chips"
    },
    config = { extra = { base_chips = 15, scale_chips = 5 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_chips + ((ilvl - 1) * extra.scale_chips) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_damage(played_card, "Physical") or Warcraft.is_race(played_card, "Troll") then
                played_card.ability.perma_bonus = (played_card.ability.perma_bonus or 0) + stats[1]
                return { message = "Cut of Death!", colour = G.C.CHIPS }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Jaithys, the Prison Blade",
    index = 68, 

    req_level = 6, 
    req_class = {"Death Knight","Paladin", "Warrior"}, 
    req_weapon = {"Sword"},
    combo_joker = {"Kel'Thuzad", "Zovaal", "The Primus"},
    per_card = true,

    loc_text = {
        "Scored {C:dark_edition}Shadow{} or {C:dark_edition}Scourge{} cards",
        "gain permanent {C:chips}+#1#{} Chips"
    },
    config = { extra = { base_chips = 15, scale_chips = 5 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_chips + ((ilvl - 1) * extra.scale_chips) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_damage(played_card, "Shadow") or Warcraft.is_faction(played_card, "Scourge") then
                played_card.ability.perma_bonus = (played_card.ability.perma_bonus or 0) + stats[1]
                return { message = "Devoured!", colour = G.C.CHIPS }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Ashkandur, Fall of the Brotherhood",
    index = 69, 

    req_level = 6, 
    req_class = {"Warrior","Paladin", "Death Knight"}, 
    req_weapon = {"Sword"},
    req_race = {"Dragon"},
    combo_joker = {"Neltharion", "Sarkareth", "Nefarian"},

    loc_text = {
        "Scored {C:attention}Dragon{} or {C:attention}Warrior{} cards",
        "give {X:mult,C:white} X#1# {} Mult"
    },
    config = { extra = { base_xmult = 1.5, scale_xmult = 0.1 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_xmult + ((ilvl - 1) * extra.scale_xmult) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_race(played_card, "Dragon") or Warcraft.is_class(played_card, "Warrior") then
                return { x_mult = stats[1], message = "Brotherhood!", colour = G.C.MULT }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Prydaz, Xavaric's Magnum Opus",
    index = 70, 

    req_level = 6, 
    req_class = {"Any"}, 
    combo_joker = {"Khadgar"},

    loc_text = {
        "Scored {C:attention}Tank{} or {C:attention}Healer{} cards",
        "gain permanent {C:chips}+#1#{} Chips"
    },
    config = { extra = { base_chips = 15, scale_chips = 5 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_chips + ((ilvl - 1) * extra.scale_chips) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_role(played_card, "Tank") or Warcraft.is_role(played_card, "Healer") then
                played_card.ability.perma_bonus = (played_card.ability.perma_bonus or 0) + stats[1]
                return { message = "Shielded!", colour = G.C.CHIPS }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Kil'jaeden's Burning Wish",
    index = 71, 

    req_level = 6, 
    req_class = {"Any"}, 
    req_faction = {"Legion"},
    combo_joker = {"Kil'jaeden","Prophet Velen"},

    loc_text = {
        "Scored {C:red}Fire{} or {C:attention}Demon{} cards",
        "give {X:chips,C:white} X#1# {} Chips"
    },
    config = { extra = { base_xchips = 1.5, scale_xchips = 0.1 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_xchips + ((ilvl - 1) * extra.scale_xchips) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_damage(played_card, "Fire") or Warcraft.is_race(played_card, "Demon") then
                return { x_chips = stats[1], message = "Burning Wish!", colour = G.C.CHIPS }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Archimonde's Hatred Reborn",
    index = 72, 

    req_level = 6, 
    req_class = {"Any"}, 
    req_faction = {"Legion"},
    combo_joker = {"Archimonde","Sargeras"},

    loc_text = {
        "Scored {C:attention}Tank{} or {C:attention}Legion{} cards",
        "give {X:mult,C:white} X#1# {} Mult"
    },
    config = { extra = { base_xmult = 1.5, scale_xmult = 0.1 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_xmult + ((ilvl - 1) * extra.scale_xmult) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_role(played_card, "Tank") or Warcraft.is_faction(played_card, "Legion") then
                return { x_mult = stats[1], message = "Hatred Reborn!", colour = G.C.MULT }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Aman'Thul's Vision",
    index = 73, 

    req_level = 6, 
    req_class = {"Any"},
    req_race = {"Titan"},
    combo_joker = {"Aman'Thul", "Argus the Unmaker", "Sargeras"},

    loc_text = {
        "{C:green}#1#% chance{} to upgrade",
        "played hand level when a {C:attention}Titan{}",
        "or {C:attention}Arcane{} card scores"
    },
    config = { extra = { base_chance = 10, scale_chance = 2 } },
    calculate_stats = function(ilvl, extra)
        return { math.min(100, extra.base_chance + ((ilvl - 1) * extra.scale_chance)) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_race(played_card, "Titan") or Warcraft.is_damage(played_card, "Arcane") then
                if pseudorandom("amanthul") < (stats[1] / 100) then
                    SMODS.upgrade_poker_hands({hands = {context.scoring_name}, level_up = 1, from = card})
                    return { message = "Vision!", colour = G.C.BLUE }
                end
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Qian-Le, Courage of Niuzao",
    index = 74, 

    req_level = 6, 
    req_class = {"Warrior","Death Knight","Paladin","Monk","Druid"},
    req_race = {"Pandaren"},
    combo_joker = {"Wrathion", "Niuzao"},

    loc_text = {
        "Scored {C:attention}Tank{} or {C:attention}Pandaren{} cards",
        "gain permanent {C:chips}+#1#{} Chips"
    },
    config = { extra = { base_chips = 15, scale_chips = 5 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_chips + ((ilvl - 1) * extra.scale_chips) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_role(played_card, "Tank") or Warcraft.is_race(played_card, "Pandaren") then
                played_card.ability.perma_bonus = (played_card.ability.perma_bonus or 0) + stats[1]
                return { message = "Courage!", colour = G.C.CHIPS }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Xing-Ho, Breath of Yu'lon",
    index = 75, 

    req_level = 6, 
    req_class = {"Mage","Shaman","Warlock","Priest","Druid","Hunter"},
    combo_joker = {"Yu'lon","Wrathion","Lei Shen"},

    loc_text = {
        "Scored {C:attention}Ranged Dps{} or {C:red}Fire{} cards",
        "give {X:mult,C:white} X#1# {} Mult"
    },
    config = { extra = { base_xmult = 1.5, scale_xmult = 0.1 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_xmult + ((ilvl - 1) * extra.scale_xmult) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_role(played_card, "Ranged Dps") or Warcraft.is_damage(played_card, "Fire") then
                return { x_mult = stats[1], message = "Breath!", colour = G.C.MULT }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Jina-Kang, Kindness of Chi-Ji",
    index = 76, 

    req_level = 6, 
    req_class = {"Priest","Paladin","Demon Hunter","Monk","Druid","Shaman"}, 
    combo_joker = {"Chi-Ji","Wrathion"},

    loc_text = {
        "Scored {C:attention}Healer{} or {C:attention}Holy{} cards",
        "give {C:money}$#1#{}"
    },
    config = { extra = { base_money = 2, scale_money = 1 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_money + ((ilvl - 1) * extra.scale_money) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_role(played_card, "Healer") or Warcraft.is_damage(played_card, "Holy") then
                ease_dollars(stats[1])
                return { message = "+$" .. stats[1], colour = G.C.MONEY }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Fen-Yu, Fury of Xuen",
    index = 77, 

    req_level = 6, 
    req_class = {"Rogue","Monk","Druid","Shaman","Hunter"}, 
    combo_joker = {"Xuen","Wrathion"},

    loc_text = {
        "Scored {C:attention}Melee Dps{} or {C:attention}Nature{} cards",
        "give {X:chips,C:white} X#1# {} Chips"
    },
    config = { extra = { base_xchips = 1.5, scale_xchips = 0.1 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_xchips + ((ilvl - 1) * extra.scale_xchips) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_role(played_card, "Melee Dps") or Warcraft.is_damage(played_card, "Nature") then
                return { x_chips = stats[1], message = "Fury!", colour = G.C.CHIPS }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Taeshalach",
    index = 78, 

    req_level = 6, 
    req_class = {"Warrior","Death Knight","Hunter", "Paladin"}, 
    req_weapon = {"Sword"},
    combo_joker = {"Aggramar","Sargeras"},

    loc_text = {
        "{C:green}#1#% chance{} to upgrade",
        "played hand level when a {C:attention}Titan{}",
        "or {C:red}Fire{} card scores"
    },
    config = { extra = { base_chance = 10, scale_chance = 2 } },
    calculate_stats = function(ilvl, extra)
        return { math.min(100, extra.base_chance + ((ilvl - 1) * extra.scale_chance)) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_race(played_card, "Titan") or Warcraft.is_damage(played_card, "Fire") then
                if pseudorandom("taeshalach") < (stats[1] / 100) then
                    SMODS.upgrade_poker_hands({hands = {context.scoring_name}, level_up = 1, from = card})
                    return { message = "Shattered!", colour = G.C.RED }
                end
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Underlight Angler",
    index = 79,

    req_level = 6,
    req_class = {"Any"},
    req_race = {"Murloc"},
    combo_joker = {"Nat Pagle", "Khadgar"},

    loc_text = {
        "Scored {C:attention}Fisher{} or {C:attention}Murloc{} cards",
        "give {C:money}$#1#{}"
    },
    config = { extra = { base_money = 2, scale_money = 1 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_money + ((ilvl - 1) * extra.scale_money) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_profession(played_card, "Fisher") or Warcraft.is_race(played_card, "Murloc") then
                ease_dollars(stats[1])
                return { message = "+$" .. stats[1], colour = G.C.MONEY }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Hammer of the Naaru",
    index = 80,

    req_level = 6, 
    req_class = {"Paladin","Warrior","Death Knight"}, 
    req_weapon = {"Hammer"},
    req_race = {"Draenei"},
    combo_joker = {"Yrel"},

    loc_text = {
        "{C:green}#1#% chance{} to upgrade",
        "played hand level when a {C:attention}Naaru{}",
        "or {C:attention}Draenei{} card scores"
    },
    config = { extra = { base_chance = 10, scale_chance = 2 } },
    calculate_stats = function(ilvl, extra)
        return { math.min(100, extra.base_chance + ((ilvl - 1) * extra.scale_chance)) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_race(played_card, "Naaru") or Warcraft.is_race(played_card, "Draenei") then
                if pseudorandom("hammer_naaru") < (stats[1] / 100) then
                    SMODS.upgrade_poker_hands({hands = {context.scoring_name}, level_up = 1, from = card})
                    return { message = "Holy Light!", colour = G.C.GOLD }
                end
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Dragon Soul",
    index = 81, 

    req_level = 6, 
    req_class = {"Any"},
    req_race = {"Dragon"},
    combo_joker = {"Neltharion", "Thrall", "Nozdormu"},
    per_card = true,

    loc_text = {
        "Scored {C:attention}Dragon{} or {C:attention}Shaman{} cards",
        "give {X:mult,C:white} X#1# {} Mult"
    },
    config = { extra = { base_xmult = 1.5, scale_xmult = 0.1 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_xmult + ((ilvl - 1) * extra.scale_xmult) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_race(played_card, "Dragon") or Warcraft.is_class(played_card, "Shaman") then
                return { x_mult = stats[1], message = "Dragon Soul!", colour = G.C.MULT }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Bulwark of Azzinoth",
    index = 82, 

    req_level = 6, 
    req_class = {"Warrior","Paladin"}, 
    req_weapon = {"Shield"},
    req_faction = {"Legion"},
    combo_joker = {"Illidan Stormrage"},

    loc_text = {
        "Scored {C:attention}Tank{} or {C:attention}Demon{} cards",
        "gain permanent {C:chips}+#1#{} Chips"
    },
    config = { extra = { base_chips = 15, scale_chips = 5 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_chips + ((ilvl - 1) * extra.scale_chips) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_role(played_card, "Tank") or Warcraft.is_race(played_card, "Demon") then
                played_card.ability.perma_bonus = (played_card.ability.perma_bonus or 0) + stats[1]
                return { message = "Bulwark!", colour = G.C.CHIPS }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Runeblade of Baron Rivendare",
    index = 83, 

    req_level = 6, 
    req_class = {"Death Knight","Paladin", "Warrior"}, 
    req_weapon = {"Sword"},
    combo_joker = {"Baron Rivendare"},

    loc_text = {
        "Scored {C:attention}Undead{} or {C:dark_edition}Scourge{} cards",
        "give {C:mult}+#1#{} Mult"
    },
    config = { extra = { base_mult = 15, scale_mult = 5 } },
    calculate_stats = function(ilvl, extra)
        return { extra.base_mult + ((ilvl - 1) * extra.scale_mult) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_race(played_card, "Undead") or Warcraft.is_faction(played_card, "Scourge") then
                return { mult = stats[1], message = "Unholy!", colour = G.C.MULT }
            end
        end
    end
})

Warcraft.create_equipment({
    name = "Puzzle Box of Yogg-Saron",
    index = 84, 

    req_level = 6, 
    req_class = {"Any"},
    req_race = {"God"},
    combo_joker = {"Yogg-Saron"},

    loc_text = {
        "{C:green}#1#% chance{} to generate a",
        "consumable when an {C:attention}Archaeologist{} or",
        "{C:attention}God{} card scores"
    },
    config = { extra = { base_chance = 15, scale_chance = 5 } },
    calculate_stats = function(ilvl, extra)
        return { math.min(100, extra.base_chance + ((ilvl - 1) * extra.scale_chance)) }
    end,
    on_score = function(ilvl, context, card, stats, extra, joker_ret)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if Warcraft.is_profession(played_card, "Archaeologist") or Warcraft.is_race(played_card, "God") then
                if pseudorandom("puzzlebox") < (stats[1] / 100) then
                    if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                        G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                local _card = create_card('Consumeables', G.consumeables, nil, nil, nil, nil, nil, 'puzzlebox')
                                _card:add_to_deck()
                                G.consumeables:emplace(_card)
                                G.GAME.consumeable_buffer = 0
                                return true
                            end
                        }))
                        return { message = "Madness!", colour = G.C.PURPLE }
                    end
                end
            end
        end
    end
})
sendDebugMessage("Azeroth Balatro Mod : Generating all Equipments done!")