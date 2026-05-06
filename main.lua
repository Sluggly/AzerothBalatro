-- AzerothBalatro (C) 2026 Sluggly
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License.

SMODS.current_mod.process_loc_text = function()
    -- Safely call our newly refactored badges localization generator!
    if Warcraft and Warcraft.Badges and Warcraft.Badges.register_loc_text then
        Warcraft.Badges.register_loc_text()
    end

    -- Register booster pack names
    G.localization.descriptions.Booster = G.localization.descriptions.Booster or {}
    
    SMODS.process_loc_text(G.localization.descriptions.Booster, 'p_war_quest_pack_jumbo', {
        name = "Jumbo Quest Pack",
        text = { "Choose {C:attention}#1#{} of up to", "{C:attention}#2#{} Quest cards" }
    })
    
    SMODS.process_loc_text(G.localization.descriptions.Booster, 'p_war_equipment_pack', {
        name = "Equipment Pack",
        text = { "Choose {C:attention}#1#{} of up to", "{C:attention}#2#{} Equipment cards" }
    })
    
    SMODS.process_loc_text(G.localization.descriptions.Booster, 'p_war_warcraft_faction_pack', {
        name = "Warcraft Joker Pack",
        text = { "Choose {C:attention}#1#{} of up to", "{C:attention}#2#{} Jokers" }
    })

    SMODS.process_loc_text(G.localization.descriptions.Other, 'alarmobot_safe', {
        name = "Intruder Alert!",
        text = {
            "Spawned by {C:attention}Alarm-o-Bot{}",
            "{C:green}No penalty active!{}",
            " ",
            "{C:red}Kill Condition:{}",
            "Discard or Play a {C:attention}#2#{}"
        }
    })
end

SMODS.current_mod.optional_features = function()
    return {
        post_trigger = true
    }
end

local function load_mod_file(path)
    local fn, err = SMODS.load_file(path)
    if err then
        sendDebugMessage("ERROR loading " .. path .. ": " .. tostring(err))
        return
    end
    fn()
end

--- File: main.lua ---
if SMODS.current_mod then
    sendDebugMessage("Azeroth Balatro Mod : Loading all mod files...")
    Warcraft = Warcraft or {}

    warcraft_config = SMODS.current_mod.config

    load_mod_file("functions/utils.lua")
    load_mod_file("functions/constants.lua")
    load_mod_file("functions/badges.lua")
    load_mod_file("debug.lua")
    load_mod_file("functions/atlas.lua")
    load_mod_file("functions/packs.lua")
    load_mod_file("content/init_packs.lua")
    load_mod_file("content/other_packs.lua")
    load_mod_file("functions/tags.lua")
    load_mod_file("content/init_tags.lua")
    load_mod_file("functions/stickers.lua")
    load_mod_file("functions/equipment.lua")
    load_mod_file("content/init_equipments.lua")
    load_mod_file("functions/mounts.lua")
    load_mod_file("content/init_mounts.lua")
    load_mod_file("functions/spells.lua")
    load_mod_file("content/init_spells.lua")
    load_mod_file("functions/quests.lua")
    load_mod_file("content/init_quests.lua")
    load_mod_file("content/darkmoon_prizes.lua")
    load_mod_file("functions/jokers.lua")
    load_mod_file("content/init_jokers.lua")
    load_mod_file("content/other_jokers.lua")
    load_mod_file("functions/enemies.lua")
    load_mod_file("content/init_enemies.lua")
    load_mod_file("content/vouchers.lua")
    load_mod_file("functions/decks.lua")
    load_mod_file("content/init_decks.lua")
    load_mod_file("functions/hooks.lua")
    
    sendDebugMessage("Azeroth Balatro Mod : Mod loading done !")
end