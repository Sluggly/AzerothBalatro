-- AzerothBalatro (C) 2026 Sluggly
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License.

SMODS.current_mod.process_loc_text = function()
    local ten_vars = "{V:1}#1#{}{V:2}#2#{}{V:3}#3#{}{V:4}#4#{}{V:5}#5#{}{V:6}#6#{}{V:7}#7#{}{V:8}#8#{}{V:9}#9#{}{V:10}#10#{}"
    
    SMODS.process_loc_text(G.localization.descriptions.Other, 'war_faction', { name = "Faction", text = {ten_vars} })
    SMODS.process_loc_text(G.localization.descriptions.Other, 'war_race', { name = "Race", text = {ten_vars} })
    SMODS.process_loc_text(G.localization.descriptions.Other, 'war_class', { name = "Class", text = {ten_vars} })
    SMODS.process_loc_text(G.localization.descriptions.Other, 'war_weapon', { name = "Weapon", text = {ten_vars} })
end

SMODS.current_mod.optional_features = function()
    return {
        post_trigger = true
    }
end

--- File: main.lua ---
if SMODS.current_mod then
    sendDebugMessage("Azeroth Balatro Mod : Loading all mod files...")
    Warcraft = Warcraft or {}

    local conf, err = SMODS.load_file("config.lua")
    if err then sendDebugMessage("ERROR loading config.lua: " .. tostring(err)) else conf() end

    local utils, err = SMODS.load_file("functions/utils.lua")
    if err then sendDebugMessage("ERROR loading utils.lua: " .. tostring(err)) else utils() end

    local badges, err = SMODS.load_file("functions/badges.lua")
    if err then sendDebugMessage("ERROR loading badges.lua: " .. tostring(err)) else badges() end

    local debug, err = SMODS.load_file("debug.lua")
    if err then sendDebugMessage("ERROR loading debug.lua: " .. tostring(err)) else debug() end

    assert(load(SMODS.load_file('functions/atlas.lua')))()
    Warcraft.Atlas.register_all()

    local packs, err = SMODS.load_file("content/packs.lua")
    if err then sendDebugMessage("ERROR loading packs.lua: " .. tostring(err)) else packs() end

    local equip_logic, err = SMODS.load_file("functions/equipment.lua")
    if err then sendDebugMessage("ERROR loading equipment.lua: " .. tostring(err)) else equip_logic() end

    local equipments, err = SMODS.load_file("content/init_equipments.lua")
    if err then sendDebugMessage("ERROR loading init_equipments.lua: " .. tostring(err)) else equipments() end

    local quest_logic, err = SMODS.load_file("functions/quests.lua")
    if err then sendDebugMessage("ERROR loading quests.lua: " .. tostring(err)) else quest_logic() end

    local quests, err = SMODS.load_file("content/init_quests.lua")
    if err then sendDebugMessage("ERROR loading init_quests.lua: " .. tostring(err)) else quests() end

    local joker_logic, err = SMODS.load_file("functions/jokers.lua")
    if err then sendDebugMessage("ERROR loading jokers.lua: " .. tostring(err)) else joker_logic() end

    local content, err = SMODS.load_file("content/init_jokers.lua")
    if err then sendDebugMessage("ERROR loading init_jokers.lua: " .. tostring(err)) else content() end

    local wrapper, err = SMODS.load_file("functions/enemies.lua")
    if err then sendDebugMessage("ERROR loading enemies.lua: " .. tostring(err)) else wrapper() end

    local enemies, err = SMODS.load_file("content/init_enemies.lua")
    if err then sendDebugMessage("ERROR loading init_enemies.lua: " .. tostring(err)) else enemies() end

    local wrapper, err = SMODS.load_file("functions/hooks.lua")
    if err then sendDebugMessage("ERROR loading hooks.lua: " .. tostring(err)) else wrapper() end

    local decks, err = SMODS.load_file("content/decks.lua")
    if err then sendDebugMessage("ERROR loading decks.lua: " .. tostring(err)) else decks() end
    
    sendDebugMessage("Azeroth Balatro Mod : Mod loading done !")
end