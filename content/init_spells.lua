sendDebugMessage("Azeroth Balatro Mod : Generating all Spells...")
Warcraft.Spells.create_spell({
    name = "Polymorph",
    index = 1,
    rarity = 1,
    damage = {"Arcane"},
    req_level = 6,
    target_type = "any_card", -- Requires 1 card to be highlighted
    loc_text = {
        "Replace the {C:attention}Race{} of",
        "a selected Joker or",
        "Playing Card with {C:attention}Beast{}"
    },
    on_cast = function(card, area, copier)
        local target = (G.jokers and G.jokers.highlighted[1]) or (G.hand and G.hand.highlighted[1])
        if target and target.ability then
            Warcraft.modify_race(target, "Beast", false)
            
            card_eval_status_text(target, 'extra', nil, nil, nil, {
                message = "Baa!",
                colour = HEX(Warcraft.Constants.Colors.Race.Beast or "FFFFFF")
            })
            target:juice_up()
        end
    end
})
Warcraft.Spells.create_spell({
    name = "Fireball",
    index = 2,
    rarity = 1,
    damage = {"Fire"},
    req_level = 6,
    target_type = "any_card",
    loc_text = {
        "Replace the {C:attention}Damage{} of",
        "a selected Joker or",
        "Playing Card with {C:#FF6A00}Fire{}"
    },
    on_cast = function(card, area, copier)
        local target = (G.jokers and G.jokers.highlighted[1]) or (G.hand and G.hand.highlighted[1])
        if target and target.ability then
            Warcraft.modify_damage(target, "Fire", false)
            
            card_eval_status_text(target, 'extra', nil, nil, nil, {
                message = "Fire!",
                colour = HEX(Warcraft.Constants.Colors.Damage.Fire)
            })
            target:juice_up()
        end
    end
})
Warcraft.Spells.create_spell({
    name = "Frost Bolt",
    index = 3,
    rarity = 1,
    damage = {"Frost"},
    req_level = 6,
    target_type = "any_card",
    loc_text = {
        "Replace the {C:attention}Damage{} of",
        "a selected Joker or",
        "Playing Card with {C:#69CCF0}Frost{}"
    },
    on_cast = function(card, area, copier)
        local target = (G.jokers and G.jokers.highlighted[1]) or (G.hand and G.hand.highlighted[1])
        if target and target.ability then
            Warcraft.modify_damage(target, "Frost", false)
            
            card_eval_status_text(target, 'extra', nil, nil, nil, {
                message = "Frost!",
                colour = HEX(Warcraft.Constants.Colors.Damage.Frost)
            })
            target:juice_up()
        end
    end
})
Warcraft.Spells.create_spell({
    name = "Arcane Blast",
    index = 4,
    rarity = 1,
    damage = {"Arcane"},
    req_level = 6,
    target_type = "any_card",
    loc_text = {
        "Replace the {C:attention}Damage{} of",
        "a selected Joker or",
        "Playing Card with {C:#B48AE8}Arcane{}"
    },
    on_cast = function(card, area, copier)
        local target = (G.jokers and G.jokers.highlighted[1]) or (G.hand and G.hand.highlighted[1])
        if target and target.ability then
            Warcraft.modify_damage(target, "Arcane", false)
            
            card_eval_status_text(target, 'extra', nil, nil, nil, {
                message = "Arcane!",
                colour = HEX(Warcraft.Constants.Colors.Damage.Arcane)
            })
            target:juice_up()
        end
    end
})
Warcraft.Spells.create_spell({
    name = "Smite",
    index = 5,
    rarity = 1,
    damage = {"Holy"},
    req_level = 6,
    target_type = "any_card",
    loc_text = {
        "Replace the {C:attention}Damage{} of",
        "a selected Joker or",
        "Playing Card with {C:#FFD966}Holy{}"
    },
    on_cast = function(card, area, copier)
        local target = (G.jokers and G.jokers.highlighted[1]) or (G.hand and G.hand.highlighted[1])
        if target and target.ability then
            Warcraft.modify_damage(target, "Holy", false)
            
            card_eval_status_text(target, 'extra', nil, nil, nil, {
                message = "Holy!",
                colour = HEX(Warcraft.Constants.Colors.Damage.Holy)
            })
            target:juice_up()
        end
    end
})
Warcraft.Spells.create_spell({
    name = "Shadow Bolt",
    index = 6,
    rarity = 1,
    damage = {"Shadow"},
    req_level = 6,
    target_type = "any_card",
    loc_text = {
        "Replace the {C:attention}Damage{} of",
        "a selected Joker or",
        "Playing Card with {C:#7B5099}Shadow{}"
    },
    on_cast = function(card, area, copier)
        local target = (G.jokers and G.jokers.highlighted[1]) or (G.hand and G.hand.highlighted[1])
        if target and target.ability then
            Warcraft.modify_damage(target, "Shadow", false)
            
            card_eval_status_text(target, 'extra', nil, nil, nil, {
                message = "Shadow!",
                colour = HEX(Warcraft.Constants.Colors.Damage.Shadow)
            })
            target:juice_up()
        end
    end
})
Warcraft.Spells.create_spell({
    name = "Heroic Strike",
    index = 7,
    rarity = 1,
    damage = {"Physical"},
    req_level = 6,
    target_type = "any_card",
    loc_text = {
        "Replace the {C:attention}Damage{} of",
        "a selected Joker or",
        "Playing Card with {C:#C0C0C0}Physical{}"
    },
    on_cast = function(card, area, copier)
        local target = (G.jokers and G.jokers.highlighted[1]) or (G.hand and G.hand.highlighted[1])
        if target and target.ability then
            Warcraft.modify_damage(target, "Physical", false)
            
            card_eval_status_text(target, 'extra', nil, nil, nil, {
                message = "Physical!",
                colour = HEX(Warcraft.Constants.Colors.Damage.Physical)
            })
            target:juice_up()
        end
    end
})
Warcraft.Spells.create_spell({
    name = "Steady Shot",
    index = 8,
    rarity = 1,
    damage = {"Piercing"},
    req_level = 6,
    target_type = "any_card",
    loc_text = {
        "Replace the {C:attention}Damage{} of",
        "a selected Joker or",
        "Playing Card with {C:#A0A0B0}Piercing{}"
    },
    on_cast = function(card, area, copier)
        local target = (G.jokers and G.jokers.highlighted[1]) or (G.hand and G.hand.highlighted[1])
        if target and target.ability then
            Warcraft.modify_damage(target, "Piercing", false)
            
            card_eval_status_text(target, 'extra', nil, nil, nil, {
                message = "Piercing!",
                colour = HEX(Warcraft.Constants.Colors.Damage.Piercing)
            })
            target:juice_up()
        end
    end
})
Warcraft.Spells.create_spell({
    name = "Wrath",
    index = 9,
    rarity = 1,
    damage = {"Nature"},
    req_level = 6,
    target_type = "any_card",
    loc_text = {
        "Replace the {C:attention}Damage{} of",
        "a selected Joker or",
        "Playing Card with {C:#4DB800}Nature{}"
    },
    on_cast = function(card, area, copier)
        local target = (G.jokers and G.jokers.highlighted[1]) or (G.hand and G.hand.highlighted[1])
        if target and target.ability then
            Warcraft.modify_damage(target, "Nature", false)
            
            card_eval_status_text(target, 'extra', nil, nil, nil, {
                message = "Nature!",
                colour = HEX(Warcraft.Constants.Colors.Damage.Nature)
            })
            target:juice_up()
        end
    end
})
Warcraft.Spells.create_spell({
    name = "Banish",
    index = 10,
    rarity = 3,
    damage = {"Shadow"},
    req_level = 15,
    target_type = "joker",
    -- The "Use" button will ONLY light up if the selected Joker is Negative!
    custom_can_cast = function(selected_cards)
        local target = selected_cards[1]
        return target and target.edition and target.edition.negative
    end,
    loc_text = {
        "Destroy a {C:dark_edition}Negative{} Joker",
        "and gain {C:attention}+1{} Joker slot"
    },
    on_cast = function(card, area, copier)
        local target = G.jokers.highlighted[1]
        if target and target.edition and target.edition.negative then
            G.E_MANAGER:add_event(Event({
                func = function()
                    target:start_dissolve({remove_as_card = true})
                    G.jokers.config.card_limit = G.jokers.config.card_limit + 1
                    return true
                end
            }))
        end
    end
})
Warcraft.Spells.create_spell({
    name = "Cleave",
    index = 11,
    rarity = 1,
    damage = {"Physical"},
    req_level = 3,
    loc_text = {
        "Upgrade the {C:attention}Level{} of all",
        "Jokers and Playing Cards",
        "with {C:#" .. (Warcraft.Constants.Colors.Damage.Physical or "C0C0C0") .. "}Physical{} damage by {C:attention}1{}"
    },
    on_cast = function(card, area, copier)
        local leveled_any = false
        
        -- Local helper to check and level up a card safely
        local function try_level_up(c)
            if Warcraft.is_damage(c, "Physical") then
                c.ability.extra.level = (c.ability.extra.level or 1) + 1
                c.ability.extra.max_level = (c.ability.extra.max_level or 10) + 1
                Warcraft.sync_ui_elements(c)
                if c.juice_up then c:juice_up() end
                leveled_any = true
            end
        end

        -- Check all Jokers
        if G.jokers and G.jokers.cards then
            for _, c in ipairs(G.jokers.cards) do try_level_up(c) end
        end
        
        -- Check all Playing Cards
        if G.playing_cards then
            for _, c in ipairs(G.playing_cards) do try_level_up(c) end
        end
        
        if leveled_any then play_sound('tarot1') end
    end
})
Warcraft.Spells.create_spell({
    name = "Multi-Shot",
    index = 12,
    rarity = 1,
    damage = {"Piercing"},
    req_level = 3,
    loc_text = {
        "Upgrade the {C:attention}Level{} of all",
        "Jokers and Playing Cards",
        "with {C:#" .. (Warcraft.Constants.Colors.Damage.Piercing or "A0A0B0") .. "}Piercing{} damage by {C:attention}1{}"
    },
    on_cast = function(card, area, copier)
        local leveled_any = false
        
        -- Local helper to check and level up a card safely
        local function try_level_up(c)
            if Warcraft.is_damage(c, "Piercing") then
                c.ability.extra.level = (c.ability.extra.level or 1) + 1
                c.ability.extra.max_level = (c.ability.extra.max_level or 10) + 1
                Warcraft.sync_ui_elements(c)
                if c.juice_up then c:juice_up() end
                leveled_any = true
            end
        end

        -- Check all Jokers
        if G.jokers and G.jokers.cards then
            for _, c in ipairs(G.jokers.cards) do try_level_up(c) end
        end
        
        -- Check all Playing Cards
        if G.playing_cards then
            for _, c in ipairs(G.playing_cards) do try_level_up(c) end
        end
        
        if leveled_any then play_sound('tarot1') end
    end
})
Warcraft.Spells.create_spell({
    name = "Flamestrike",
    index = 13,
    rarity = 1,
    damage = {"Fire"},
    req_level = 3,
    loc_text = {
        "Upgrade the {C:attention}Level{} of all",
        "Jokers and Playing Cards",
        "with {C:#" .. (Warcraft.Constants.Colors.Damage.Fire or "FF6A00") .. "}Fire{} damage by {C:attention}1{}"
    },
    on_cast = function(card, area, copier)
        local leveled_any = false
        
        -- Local helper to check and level up a card safely
        local function try_level_up(c)
            if Warcraft.is_damage(c, "Fire") then
                c.ability.extra.level = (c.ability.extra.level or 1) + 1
                c.ability.extra.max_level = (c.ability.extra.max_level or 10) + 1
                Warcraft.sync_ui_elements(c)
                if c.juice_up then c:juice_up() end
                leveled_any = true
            end
        end

        -- Check all Jokers
        if G.jokers and G.jokers.cards then
            for _, c in ipairs(G.jokers.cards) do try_level_up(c) end
        end
        
        -- Check all Playing Cards
        if G.playing_cards then
            for _, c in ipairs(G.playing_cards) do try_level_up(c) end
        end
        
        if leveled_any then play_sound('tarot1') end
    end
})
Warcraft.Spells.create_spell({
    name = "Blizzard",
    index = 14,
    rarity = 1,
    damage = {"Frost"},
    req_level = 3,
    loc_text = {
        "Upgrade the {C:attention}Level{} of all",
        "Jokers and Playing Cards",
        "with {C:#" .. (Warcraft.Constants.Colors.Damage.Frost or "69CCF0") .. "}Frost{} damage by {C:attention}1{}"
    },
    on_cast = function(card, area, copier)
        local leveled_any = false
        
        -- Local helper to check and level up a card safely
        local function try_level_up(c)
            if Warcraft.is_damage(c, "Frost") then
                c.ability.extra.level = (c.ability.extra.level or 1) + 1
                c.ability.extra.max_level = (c.ability.extra.max_level or 10) + 1
                Warcraft.sync_ui_elements(c)
                if c.juice_up then c:juice_up() end
                leveled_any = true
            end
        end

        -- Check all Jokers
        if G.jokers and G.jokers.cards then
            for _, c in ipairs(G.jokers.cards) do try_level_up(c) end
        end
        
        -- Check all Playing Cards
        if G.playing_cards then
            for _, c in ipairs(G.playing_cards) do try_level_up(c) end
        end
        
        if leveled_any then play_sound('tarot1') end
    end
})
Warcraft.Spells.create_spell({
    name = "Arcane Explosion",
    index = 15,
    rarity = 1,
    damage = {"Arcane"},
    req_level = 3,
    loc_text = {
        "Upgrade the {C:attention}Level{} of all",
        "Jokers and Playing Cards",
        "with {C:#" .. (Warcraft.Constants.Colors.Damage.Arcane or "B48AE8") .. "}Arcane{} damage by {C:attention}1{}"
    },
    on_cast = function(card, area, copier)
        local leveled_any = false
        
        -- Local helper to check and level up a card safely
        local function try_level_up(c)
            if Warcraft.is_damage(c, "Arcane") then
                c.ability.extra.level = (c.ability.extra.level or 1) + 1
                c.ability.extra.max_level = (c.ability.extra.max_level or 10) + 1
                Warcraft.sync_ui_elements(c)
                if c.juice_up then c:juice_up() end
                leveled_any = true
            end
        end

        -- Check all Jokers
        if G.jokers and G.jokers.cards then
            for _, c in ipairs(G.jokers.cards) do try_level_up(c) end
        end
        
        -- Check all Playing Cards
        if G.playing_cards then
            for _, c in ipairs(G.playing_cards) do try_level_up(c) end
        end
        
        if leveled_any then play_sound('tarot1') end
    end
})
Warcraft.Spells.create_spell({
    name = "Starfall",
    index = 16,
    rarity = 1,
    damage = {"Nature"},
    req_level = 3,
    loc_text = {
        "Upgrade the {C:attention}Level{} of all",
        "Jokers and Playing Cards",
        "with {C:#" .. (Warcraft.Constants.Colors.Damage.Nature or "4DB800") .. "}Nature{} damage by {C:attention}1{}"
    },
    on_cast = function(card, area, copier)
        local leveled_any = false
        
        -- Local helper to check and level up a card safely
        local function try_level_up(c)
            if Warcraft.is_damage(c, " Nature") then
                c.ability.extra.level = (c.ability.extra.level or 1) + 1
                c.ability.extra.max_level = (c.ability.extra.max_level or 10) + 1
                Warcraft.sync_ui_elements(c)
                if c.juice_up then c:juice_up() end
                leveled_any = true
            end
        end

        -- Check all Jokers
        if G.jokers and G.jokers.cards then
            for _, c in ipairs(G.jokers.cards) do try_level_up(c) end
        end
        
        -- Check all Playing Cards
        if G.playing_cards then
            for _, c in ipairs(G.playing_cards) do try_level_up(c) end
        end
        
        if leveled_any then play_sound('tarot1') end
    end
})
Warcraft.Spells.create_spell({
    name = "Hand of Gul'dan",
    index = 17,
    rarity = 1,
    damage = {"Shadow"},
    req_level = 3,
    loc_text = {
        "Upgrade the {C:attention}Level{} of all",
        "Jokers and Playing Cards",
        "with {C:#" .. (Warcraft.Constants.Colors.Damage.Shadow or "7B5099") .. "}Shadow{} damage by {C:attention}1{}"
    },
    on_cast = function(card, area, copier)
        local leveled_any = false
        
        -- Local helper to check and level up a card safely
        local function try_level_up(c)
            if Warcraft.is_damage(c, "Shadow") then
                c.ability.extra.level = (c.ability.extra.level or 1) + 1
                c.ability.extra.max_level = (c.ability.extra.max_level or 10) + 1
                Warcraft.sync_ui_elements(c)
                if c.juice_up then c:juice_up() end
                leveled_any = true
            end
        end

        -- Check all Jokers
        if G.jokers and G.jokers.cards then
            for _, c in ipairs(G.jokers.cards) do try_level_up(c) end
        end
        
        -- Check all Playing Cards
        if G.playing_cards then
            for _, c in ipairs(G.playing_cards) do try_level_up(c) end
        end
        
        if leveled_any then play_sound('tarot1') end
    end
})
Warcraft.Spells.create_spell({
    name = "Divine Hymn",
    index = 18,
    rarity = 1,
    damage = {"Holy"},
    req_level = 3,
    loc_text = {
        "Upgrade the {C:attention}Level{} of all",
        "Jokers and Playing Cards",
        "with {C:#" .. (Warcraft.Constants.Colors.Damage.Holy or "FFD966") .. "}Holy{} damage by {C:attention}1{}"
    },
    on_cast = function(card, area, copier)
        local leveled_any = false
        
        -- Local helper to check and level up a card safely
        local function try_level_up(c)
            if Warcraft.is_damage(c, "Holy") then
                c.ability.extra.level = (c.ability.extra.level or 1) + 1
                c.ability.extra.max_level = (c.ability.extra.max_level or 10) + 1
                Warcraft.sync_ui_elements(c)
                if c.juice_up then c:juice_up() end
                leveled_any = true
            end
        end

        -- Check all Jokers
        if G.jokers and G.jokers.cards then
            for _, c in ipairs(G.jokers.cards) do try_level_up(c) end
        end
        
        -- Check all Playing Cards
        if G.playing_cards then
            for _, c in ipairs(G.playing_cards) do try_level_up(c) end
        end
        
        if leveled_any then play_sound('tarot1') end
    end
})
Warcraft.Spells.create_spell({
    name = "Mirror Image",
    index = 19,
    rarity = 3,
    damage = {"Arcane"},
    req_level = 25,
    target_type = "any_card",
    loc_text = {
        "Make a {C:attention}temporary{} copy of",
        "a Joker (destroyed after 1 round),",
        "or a {C:attention}permanent{} copy",
        "of a Playing Card"
    },
    on_cast = function(card, area, copier)
        local target = (G.jokers and G.jokers.highlighted[1]) or (G.hand and G.hand.highlighted[1])
        if target then
            if target.ability and target.ability.set == 'Joker' then
                if G.jokers and #G.jokers.cards < G.jokers.config.card_limit then
                    local new_joker = copy_card(target, nil, nil, nil, target.edition)
                    new_joker:add_to_deck()
                    G.jokers:emplace(new_joker)
                    
                    -- Dynamically wrap calculate to self-destruct at the end of the round
                    local old_calc = new_joker.calculate
                    new_joker.calculate = function(self, _c, context)
                        local ret = nil
                        if old_calc then ret = old_calc(self, _c, context) end
                        
                        if context.end_of_round and not context.repetition and not context.blueprint then
                            G.E_MANAGER:add_event(Event({
                                func = function()
                                    _c:start_dissolve({remove_as_card = true})
                                    return true
                                end
                            }))
                        end
                        return ret
                    end
                    
                    card_eval_status_text(new_joker, 'extra', nil, nil, nil, {
                        message = "Mirror Image!",
                        colour = G.C.PURPLE
                    })
                end
            else
                -- Playing Card (Permanent)
                local new_card = copy_card(target, nil, nil, G.playing_card)
                new_card:add_to_deck()
                table.insert(G.playing_cards, new_card)
                G.deck:emplace(new_card)
                
                card_eval_status_text(new_card, 'extra', nil, nil, nil, {
                    message = "Copied!",
                    colour = G.C.PURPLE
                })
            end
        end
    end
})
Warcraft.Spells.create_spell({
    name = "Aura of Devotion",
    index = 20,
    rarity = 1,
    damage = {"Holy"},
    req_level = 5,
    target_type = "any_card",
    loc_text = {
        "Replace the {C:attention}Role{} of",
        "a selected Joker or",
        "Playing Card with {C:#" .. (Warcraft.Constants.Colors.Role.Tank or "4A90E2") .. "}Tank{}"
    },
    on_cast = function(card, area, copier)
        local target = (G.jokers and G.jokers.highlighted[1]) or (G.hand and G.hand.highlighted[1])
        if target and target.ability then
            Warcraft.modify_role(target, "Tank", false)
            card_eval_status_text(target, 'extra', nil, nil, nil, {
                message = "Tank!",
                colour = HEX(Warcraft.Constants.Colors.Role.Tank or "4A90E2")
            })
            target:juice_up()
        end
    end
})
Warcraft.Spells.create_spell({
    name = "Shadow Form",
    index = 21,
    rarity = 1,
    damage = {"Shadow"},
    req_level = 5,
    target_type = "any_card",
    loc_text = {
        "Replace the {C:attention}Role{} of",
        "a selected Joker or Playing",
        "Card with {C:#" .. (Warcraft.Constants.Colors.Role.Ranged_Dps or "F5A623") .. "}Ranged Dps{}"
    },
    on_cast = function(card, area, copier)
        local target = (G.jokers and G.jokers.highlighted[1]) or (G.hand and G.hand.highlighted[1])
        if target and target.ability then
            Warcraft.modify_role(target, "Ranged DPS", false)
            card_eval_status_text(target, 'extra', nil, nil, nil, {
                message = "Ranged Dps!",
                colour = HEX(Warcraft.Constants.Colors.Role.Ranged_Dps or "F5A623")
            })
            target:juice_up()
        end
    end
})
Warcraft.Spells.create_spell({
    name = "Berserker Stance",
    index = 22,
    rarity = 1,
    damage = {"Physical"},
    req_level = 5,
    target_type = "any_card",
    loc_text = {
        "Replace the {C:attention}Role{} of",
        "a selected Joker or Playing",
        "Card with {C:#" .. (Warcraft.Constants.Colors.Role.Melee_Dps or "E84848") .. "}Melee Dps{}"
    },
    on_cast = function(card, area, copier)
        local target = (G.jokers and G.jokers.highlighted[1]) or (G.hand and G.hand.highlighted[1])
        if target and target.ability then
            Warcraft.modify_role(target, "Melee DPS", false)
            card_eval_status_text(target, 'extra', nil, nil, nil, {
                message = "Melee Dps!",
                colour = HEX(Warcraft.Constants.Colors.Role.Melee_Dps or "E84848")
            })
            target:juice_up()
        end
    end
})
Warcraft.Spells.create_spell({
    name = "Tree of Life",
    index = 23,
    rarity = 1,
    damage = {"Nature"},
    req_level = 5,
    target_type = "any_card",
    loc_text = {
        "Replace the {C:attention}Role{} of",
        "a selected Joker or",
        "Playing Card with {C:#" .. (Warcraft.Constants.Colors.Role.Healer or "00E676") .. "}Healer{}"
    },
    on_cast = function(card, area, copier)
        local target = (G.jokers and G.jokers.highlighted[1]) or (G.hand and G.hand.highlighted[1])
        if target and target.ability then
            Warcraft.modify_role(target, "Healer", false)
            card_eval_status_text(target, 'extra', nil, nil, nil, {
                message = "Healer!",
                colour = HEX(Warcraft.Constants.Colors.Role.Healer or "00E676")
            })
            target:juice_up()
        end
    end
})
Warcraft.Spells.create_spell({
    name = "Battle Stance",
    index = 24,
    rarity = 2,
    damage = {"Physical"},
    req_level = 11,
    target_type = "any_card",
    loc_text = {
        "Replace the {C:attention}Class{} of",
        "a selected Joker or",
        "Playing Card with {C:#" .. (Warcraft.Constants.Colors.Class.Warrior or "C79C6E") .. "}Warrior{}"
    },
    on_cast = function(card, area, copier)
        local target = (G.jokers and G.jokers.highlighted[1]) or (G.hand and G.hand.highlighted[1])
        if target and target.ability then
            Warcraft.modify_class(target, "Warrior", false)
            card_eval_status_text(target, 'extra', nil, nil, nil, {
                message = "Warrior!",
                colour = HEX(Warcraft.Constants.Colors.Class.Warrior or "C79C6E")
            })
            target:juice_up()
        end
    end
})
Warcraft.Spells.create_spell({
    name = "Aspect of the Hawk",
    index = 25,
    rarity = 2,
    damage = {"Piercing"},
    req_level = 11,
    target_type = "any_card",
    loc_text = {
        "Replace the {C:attention}Class{} of",
        "a selected Joker or",
        "Playing Card with {C:#" .. (Warcraft.Constants.Colors.Class.Hunter or "ABD473") .. "}Hunter{}"
    },
    on_cast = function(card, area, copier)
        local target = (G.jokers and G.jokers.highlighted[1]) or (G.hand and G.hand.highlighted[1])
        if target and target.ability then
            Warcraft.modify_class(target, "Hunter", false)
            card_eval_status_text(target, 'extra', nil, nil, nil, {
                message = "Hunter!",
                colour = HEX(Warcraft.Constants.Colors.Class.Hunter or "ABD473")
            })
            target:juice_up()
        end
    end
})
Warcraft.Spells.create_spell({
    name = "Mark of the Wild",
    index = 26,
    rarity = 2,
    damage = {"Nature"},
    req_level = 11,
    target_type = "any_card",
    loc_text = {
        "Replace the {C:attention}Class{} of",
        "a selected Joker or",
        "Playing Card with {C:#" .. (Warcraft.Constants.Colors.Class.Druid or "FF7D0A") .. "}Druid{}"
    },
    on_cast = function(card, area, copier)
        local target = (G.jokers and G.jokers.highlighted[1]) or (G.hand and G.hand.highlighted[1])
        if target and target.ability then
            Warcraft.modify_class(target, "Druid", false)
            card_eval_status_text(target, 'extra', nil, nil, nil, {
                message = "Druid!",
                colour = HEX(Warcraft.Constants.Colors.Class.Druid or "FF7D0A")
            })
            target:juice_up()
        end
    end
})
Warcraft.Spells.create_spell({
    name = "Ice Barrier",
    index = 27,
    rarity = 2,
    damage = {"Frost"},
    req_level = 11,
    target_type = "any_card",
    loc_text = {
        "Replace the {C:attention}Class{} of",
        "a selected Joker or",
        "Playing Card with {C:#" .. (Warcraft.Constants.Colors.Class.Mage or "40C7EB") .. "}Mage{}"
    },
    on_cast = function(card, area, copier)
        local target = (G.jokers and G.jokers.highlighted[1]) or (G.hand and G.hand.highlighted[1])
        if target and target.ability then
            Warcraft.modify_class(target, "Mage", false)
            card_eval_status_text(target, 'extra', nil, nil, nil, {
                message = "Mage!",
                colour = HEX(Warcraft.Constants.Colors.Class.Mage or "40C7EB")
            })
            target:juice_up()
        end
    end
})
Warcraft.Spells.create_spell({
    name = "Demon Skin",
    index = 28,
    rarity = 2,
    damage = {"Shadow"},
    req_level = 11,
    target_type = "any_card",
    loc_text = {
        "Replace the {C:attention}Class{} of",
        "a selected Joker or",
        "Playing Card with {C:#" .. (Warcraft.Constants.Colors.Class.Warlock or "8787ED") .. "}Warlock{}"
    },
    on_cast = function(card, area, copier)
        local target = (G.jokers and G.jokers.highlighted[1]) or (G.hand and G.hand.highlighted[1])
        if target and target.ability then
            Warcraft.modify_class(target, "Warlock", false)
            card_eval_status_text(target, 'extra', nil, nil, nil, {
                message = "Warlock!",
                colour = HEX(Warcraft.Constants.Colors.Class.Warlock or "8787ED")
            })
            target:juice_up()
        end
    end
})
Warcraft.Spells.create_spell({
    name = "Zen Meditation",
    index = 29,
    rarity = 2,
    damage = {"Piercing"},
    req_level = 11,
    target_type = "any_card",
    loc_text = {
        "Replace the {C:attention}Class{} of",
        "a selected Joker or",
        "Playing Card with {C:#" .. (Warcraft.Constants.Colors.Class.Monk or "00FF96") .. "}Monk{}"
    },
    on_cast = function(card, area, copier)
        local target = (G.jokers and G.jokers.highlighted[1]) or (G.hand and G.hand.highlighted[1])
        if target and target.ability then
            Warcraft.modify_class(target, "Monk", false)
            card_eval_status_text(target, 'extra', nil, nil, nil, {
                message = "Monk!",
                colour = HEX(Warcraft.Constants.Colors.Class.Monk or "00FF96")
            })
            target:juice_up()
        end
    end
})
Warcraft.Spells.create_spell({
    name = "Blessing of the Bronze",
    index = 30,
    rarity = 2,
    damage = {"Fire"},
    req_level = 11,
    target_type = "any_card",
    loc_text = {
        "Replace the {C:attention}Class{} of",
        "a selected Joker or",
        "Playing Card with {C:#" .. (Warcraft.Constants.Colors.Class.Evoker or "33937F") .. "}Evoker{}"
    },
    on_cast = function(card, area, copier)
        local target = (G.jokers and G.jokers.highlighted[1]) or (G.hand and G.hand.highlighted[1])
        if target and target.ability then
            Warcraft.modify_class(target, "Evoker", false)
            card_eval_status_text(target, 'extra', nil, nil, nil, {
                message = "Evoker!",
                colour = HEX(Warcraft.Constants.Colors.Class.Evoker or "33937F")
            })
            target:juice_up()
        end
    end
})
Warcraft.Spells.create_spell({
    name = "Metamorphosis",
    index = 31,
    rarity = 2,
    damage = {"Shadow"},
    req_level = 11,
    target_type = "any_card",
    loc_text = {
        "Replace the {C:attention}Class{} of",
        "a selected Joker or Playing",
        "Card with {C:#" .. (Warcraft.Constants.Colors.Class.Demon_Hunter or "A330C9") .. "}Demon Hunter{}"
    },
    on_cast = function(card, area, copier)
        local target = (G.jokers and G.jokers.highlighted[1]) or (G.hand and G.hand.highlighted[1])
        if target and target.ability then
            Warcraft.modify_class(target, "Demon Hunter", false)
            card_eval_status_text(target, 'extra', nil, nil, nil, {
                message = "Demon Hunter!",
                colour = HEX(Warcraft.Constants.Colors.Class.Demon_Hunter or "A330C9")
            })
            target:juice_up()
        end
    end
})
Warcraft.Spells.create_spell({
    name = "Frost Presence",
    index = 32,
    rarity = 2,
    damage = {"Frost"},
    req_level = 11,
    target_type = "any_card",
    loc_text = {
        "Replace the {C:attention}Class{} of",
        "a selected Joker or Playing",
        "Card with {C:#" .. (Warcraft.Constants.Colors.Class.Death_Knight or "C41F3B") .. "}Death Knight{}"
    },
    on_cast = function(card, area, copier)
        local target = (G.jokers and G.jokers.highlighted[1]) or (G.hand and G.hand.highlighted[1])
        if target and target.ability then
            Warcraft.modify_class(target, "Death Knight", false)
            card_eval_status_text(target, 'extra', nil, nil, nil, {
                message = "Death Knight!",
                colour = HEX(Warcraft.Constants.Colors.Class.Death_Knight or "C41F3B")
            })
            target:juice_up()
        end
    end
})
Warcraft.Spells.create_spell({
    name = "Blessing of might",
    index = 33,
    rarity = 2,
    damage = {"Holy"},
    req_level = 11,
    target_type = "any_card",
    loc_text = {
        "Replace the {C:attention}Class{} of",
        "a selected Joker or",
        "Playing Card with {C:#" .. (Warcraft.Constants.Colors.Class.Paladin or "F58CBA") .. "}Paladin{}"
    },
    on_cast = function(card, area, copier)
        local target = (G.jokers and G.jokers.highlighted[1]) or (G.hand and G.hand.highlighted[1])
        if target and target.ability then
            Warcraft.modify_class(target, "Paladin", false)
            card_eval_status_text(target, 'extra', nil, nil, nil, {
                message = "Paladin!",
                colour = HEX(Warcraft.Constants.Colors.Class.Paladin or "F58CBA")
            })
            target:juice_up()
        end
    end
})
Warcraft.Spells.create_spell({
    name = "Power Word: Fortitude",
    index = 34,
    rarity = 2,
    damage = {"Holy"},
    req_level = 11,
    target_type = "any_card",
    loc_text = {
        "Replace the {C:attention}Class{} of",
        "a selected Joker or",
        "Playing Card with {C:#" .. (Warcraft.Constants.Colors.Class.Priest or "CFCFCF") .. "}Priest{}"
    },
    on_cast = function(card, area, copier)
        local target = (G.jokers and G.jokers.highlighted[1]) or (G.hand and G.hand.highlighted[1])
        if target and target.ability then
            Warcraft.modify_class(target, "Priest", false)
            card_eval_status_text(target, 'extra', nil, nil, nil, {
                message = "Priest!",
                colour = HEX(Warcraft.Constants.Colors.Class.Priest or "CFCFCF")
            })
            target:juice_up()
        end
    end
})
Warcraft.Spells.create_spell({
    name = "Totem of Wrath",
    index = 35,
    rarity = 2,
    damage = {"Nature"},
    req_level = 11,
    target_type = "any_card",
    loc_text = {
        "Replace the {C:attention}Class{} of",
        "a selected Joker or",
        "Playing Card with {C:#" .. (Warcraft.Constants.Colors.Class.Shaman or "0070DE") .. "}Shaman{}"
    },
    on_cast = function(card, area, copier)
        local target = (G.jokers and G.jokers.highlighted[1]) or (G.hand and G.hand.highlighted[1])
        if target and target.ability then
            Warcraft.modify_class(target, "Shaman", false)
            card_eval_status_text(target, 'extra', nil, nil, nil, {
                message = "Shaman!",
                colour = HEX(Warcraft.Constants.Colors.Class.Shaman or "0070DE")
            })
            target:juice_up()
        end
    end
})
Warcraft.Spells.create_spell({
    name = "Tricks of the Trade",
    index = 36,
    rarity = 2,
    damage = {"Piercing"},
    req_level = 11,
    target_type = "any_card",
    loc_text = {
        "Replace the {C:attention}Class{} of",
        "a selected Joker or",
        "Playing Card with {C:#" .. (Warcraft.Constants.Colors.Class.Rogue or "FFB569") .. "}Rogue{}"
    },
    on_cast = function(card, area, copier)
        local target = (G.jokers and G.jokers.highlighted[1]) or (G.hand and G.hand.highlighted[1])
        if target and target.ability then
            Warcraft.modify_class(target, "Rogue", false)
            card_eval_status_text(target, 'extra', nil, nil, nil, {
                message = "Rogue!",
                colour = HEX(Warcraft.Constants.Colors.Class.Rogue or "FFB569")
            })
            target:juice_up()
        end
    end
})
Warcraft.Spells.create_spell({
    name = "Vanish",
    index = 37,
    rarity = 1,
    damage = {"Physical"},
    req_level = 3,
    loc_text = {
        "Sell all your Jokers for",
        "{C:attention}double{} their sell value"
    },
    on_cast = function(card, area, copier)
        if G.jokers and G.jokers.cards then
            -- Iterate backwards because cards are being removed
            for i = #G.jokers.cards, 1, -1 do
                local j = G.jokers.cards[i]
                G.E_MANAGER:add_event(Event({
                    func = function()
                        -- Double the sell cost and natively sell it!
                        j.sell_cost = (j.sell_cost or 0) * 2
                        j:sell_card()
                        return true
                    end
                }))
            end
        end
    end
})
Warcraft.Spells.create_spell({
    name = "Conjure Refreshment",
    index = 38,
    rarity = 3,
    damage = {"Frost"},
    req_level = 15,
    custom_can_cast = function(selected_cards)
        -- Must be inside the shop to spawn a booster pack
        return G.STATE == G.STATES.SHOP
    end,
    loc_text = {
        "Add a random {C:attention}Booster Pack{}",
        "into the {C:attention}Shop{}"
    },
    on_cast = function(card, area, copier)
        G.E_MANAGER:add_event(Event({
            func = function()
                if SMODS.add_booster_to_shop then
                    -- Safely adds a booster and expands shop capacity if full
                    SMODS.change_booster_limit(1)
                    SMODS.add_booster_to_shop()
                    play_sound('tarot1')
                end
                return true
            end
        }))
    end
})
Warcraft.Spells.create_spell({
    name = "Rebirth",
    index = 39,
    rarity = 3,
    damage = {"Nature"},
    req_level = 15,
    target_type = "joker", -- Require exactly 1 Joker to be highlighted
    loc_text = {
        "Destroy a selected {C:attention}Joker{},",
        "and create a perfect copy",
        "without {C:attention}Eternal{}, {C:attention}Perishable{},",
        "or {C:attention}Rental{} stickers"
    },
    on_cast = function(card, area, copier)
        local target = G.jokers.highlighted[1]
        if target then
            -- Copy first to grab exact stats before destroying the original
            local new_joker = copy_card(target, nil, nil, nil, target.edition)
            
            -- Cleanse stickers and pins
            new_joker:set_eternal(false)
            new_joker:set_perishable(false)
            new_joker:set_rental(false)
            new_joker.pinned = false
            new_joker.is_temporary = false
            
            -- If it was a revived enemy joker, remove the killed state
            if new_joker.ability and type(new_joker.ability.extra) == "table" then
                new_joker.ability.extra.is_killed = false
            end
            
            G.E_MANAGER:add_event(Event({
                func = function()
                    target:start_dissolve({remove_as_card = true})
                    
                    new_joker:add_to_deck()
                    G.jokers:emplace(new_joker)
                    
                    card_eval_status_text(new_joker, 'extra', nil, nil, nil, {
                        message = "Reborn!",
                        colour = G.C.GREEN
                    })
                    return true
                end
            }))
        end
    end
})
Warcraft.Spells.create_spell({
    name = "Pick Pocket",
    index = 40,
    rarity = 1,
    damage = {"Physical"},
    req_level = 3,
    loc_text = {
        "Gain {C:money}$1{} for every level of",
        "your {C:attention}highest level{} Joker"
    },
    on_cast = function(card, area, copier)
        local max_lvl = 0
        if G.jokers and G.jokers.cards then
            for _, j in ipairs(G.jokers.cards) do
                if j.ability and type(j.ability.extra) == "table" then
                    local lvl = j.ability.extra.level or 1
                    if lvl > max_lvl then
                        max_lvl = lvl
                    end
                end
            end
        end
        
        if max_lvl > 0 then
            ease_dollars(max_lvl)
            play_sound('coin1')
        else
            card_eval_status_text(card, 'extra', nil, nil, nil, {
                message = "Nothing to steal!",
                colour = G.C.RED
            })
        end
    end
})
Warcraft.Spells.create_spell({
    name = "Trueshot Aura",
    index = 41,
    rarity = 3,
    damage = {"Piercing"},
    req_level = 15,
    loc_text = {
        "Upgrade the {C:attention}Level{} of {C:attention}all{}",
        "Jokers and Playing Cards by {C:attention}1{}"
    },
    on_cast = function(card, area, copier)
        local leveled_any = false
        
        local function lvl_up_card(c)
            if c.ability and type(c.ability.extra) == "table" then
                -- Give them a level regardless of current attributes
                c.ability.extra.level = (c.ability.extra.level or 1) + 1
                c.ability.extra.max_level = (c.ability.extra.max_level or 10) + 1
                c.ability.extra.war_stickers_dirty = true
                if c.juice_up then c:juice_up() end
                leveled_any = true
            end
        end
        
        if G.jokers and G.jokers.cards then
            for _, c in ipairs(G.jokers.cards) do lvl_up_card(c) end
        end
        if G.playing_cards then
            for _, c in ipairs(G.playing_cards) do lvl_up_card(c) end
        end
        
        if leveled_any then play_sound('tarot1') end
    end
})
Warcraft.Spells.create_spell({
    name = "Summon Dreadsteed",
    index = 42,
    rarity = 2,
    damage = {"Shadow"},
    req_level = 10,
    loc_text = {
        "Create a random",
        "{C:attention}Mount{} consumable"
    },
    on_cast = function(card, area, copier)
        if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            G.E_MANAGER:add_event(Event({
                func = function()
                    local new_card = create_card('Mount', G.consumeables, nil, nil, nil, nil, nil, 'dreadsteed')
                    new_card:add_to_deck()
                    G.consumeables:emplace(new_card)
                    G.GAME.consumeable_buffer = 0
                    return true
                end
            }))
        else
            card_eval_status_text(card, 'extra', nil, nil, nil, {
                message = "No Space!",
                colour = G.C.RED
            })
        end
    end
})
Warcraft.Spells.create_spell({
    name = "Power Infusion",
    index = 43,
    rarity = 2,
    damage = {"Holy"},
    req_level = 15,
    target_type = "joker", -- Require exactly 1 Joker to be highlighted
    loc_text = {
        "Increase the {C:attention}iLvl{} of the",
        "selected Joker by {C:attention}3{}"
    },
    on_cast = function(card, area, copier)
        local target = G.jokers.highlighted[1]
        if target and target.ability and type(target.ability.extra) == "table" then
            -- Apply directly to Equipment if they have it, else buffer it as a mount bonus!
            if target.ability.wow_equipment then
                target.ability.wow_equipment.ilvl = (target.ability.wow_equipment.ilvl or 1) + 3
            else
                target.ability.extra.mount_ilvl_bonus = (target.ability.extra.mount_ilvl_bonus or 0) + 3
            end
            
            target.ability.extra.war_stickers_dirty = true
            
            card_eval_status_text(target, 'extra', nil, nil, nil, {
                message = "+3 iLvl!",
                colour = G.C.GOLD
            })
            target:juice_up()
        end
    end
})
sendDebugMessage("Azeroth Balatro Mod : Generating all Spells done!")