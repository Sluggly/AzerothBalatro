--- File: functions/badges.lua ---
Warcraft = Warcraft or {}
Warcraft.Badges = {}

for category, entries in pairs(Warcraft.Constants.Colors) do
    for name, hex_str in pairs(entries) do
        local upper_key = "WAR_" .. string.upper(name)
        local lower_key = "war_" .. string.lower(name)
        local color = HEX(hex_str)
        if not G.C[upper_key] then G.C[upper_key] = color end
        if not G.C[lower_key] then G.C[lower_key] = color end
    end
end

-- ============================================
-- BADGE LOCALIZATION INJECTION
-- ============================================
function Warcraft.Badges.register_loc_text()
    local ten_vars = "{V:1}#1#{}{V:2}#2#{}{V:3}#3#{}{V:4}#4#{}{V:5}#5#{}{V:6}#6#{}{V:7}#7#{}{V:8}#8#{}{V:9}#9#{}{V:10}#10#{}"
    
    -- Dynamically generate all 8 attributes
    local attrs = {
        {key = "war_faction", name = "Faction"},
        {key = "war_race", name = "Race"},
        {key = "war_class", name = "Class"},
        {key = "war_weapon", name = "Weapon"},
        {key = "war_damage", name = "Damage"},
        {key = "war_armor", name = "Armor"},
        {key = "war_role", name = "Role"},
        {key = "war_profession", name = "Profession"}
    }

    for _, attr in ipairs(attrs) do
        SMODS.process_loc_text(G.localization.descriptions.Other, attr.key, { name = attr.name, text = {ten_vars} })
    end

    SMODS.process_loc_text(G.localization.descriptions.Other, 'war_combo_req', { name = "Combo", text = {ten_vars} })
end

-- ============================================
-- BADGE RENDER PIPELINE
-- ============================================
function Warcraft.Badges.append_tooltips(info_queue, card)
    if not card.ability or type(card.ability.extra) ~= "table" then return end
    local ex = card.ability.extra

    -- Identify card type and grab UI config
    local is_joker = card.ability.set == "Joker"
    local is_playing_card = card.ability.set == "Default" or card.ability.set == "Enhanced"
    local conf = SMODS.Mods and SMODS.Mods["Warcraft"] and SMODS.Mods["Warcraft"].config
    local ui_conf = conf and conf.ui_display or {}

    local function add_tooltip(category, loc_key, val, config_key)
        -- 1. Check Config to see if this badge should be shown!
        local show_badge = true
        if ui_conf[config_key] then
            if is_joker then
                show_badge = ui_conf[config_key].badge_j
            elseif is_playing_card then
                show_badge = ui_conf[config_key].badge_p
            end
        end

        if not show_badge then return end

        -- 2. Validate empty/null attributes
        if not val or val == "None" or val == "Unknown" or val == "Normal" then return end
        
        -- Ensure val is a table so we can loop through it
        local val_list = type(val) == "table" and val or {val}

        -- Abort if the table is empty, or if the first entry is a placeholder
        if #val_list == 0 or val_list[1] == "None" or val_list[1] == "Unknown" or val_list[1] == "Neutral" then return end
        
        -- Prepare 10 empty text variables and 10 invisible colors (G.C.CLEAR)
        local str_vars = {"", "", "", "", "", "", "", "", "", ""}
        local col_vars = {
            G.C.CLEAR, G.C.CLEAR, G.C.CLEAR, G.C.CLEAR, G.C.CLEAR, 
            G.C.CLEAR, G.C.CLEAR, G.C.CLEAR, G.C.CLEAR, G.C.CLEAR
        }

        for i, v in ipairs(val_list) do
            if i > 10 then break end -- Hard limit expanded to 10

            local lookup_key = v:gsub(" ", "_")
            local hex_code = Warcraft.Constants.Colors[category] and Warcraft.Constants.Colors[category][lookup_key]
            
            -- Add the comma directly to the text if it's not the last item
            local display_str = v
            if i < #val_list and i < 10 then
                display_str = display_str .. ", "
            end
            
            -- Slot the text and the color into their respective arrays
            str_vars[i] = display_str
            col_vars[i] = hex_code and HEX(hex_code) or G.C.BLACK
        end

        -- Push all 10 variables and the dedicated colours table to the UI engine
        info_queue[#info_queue+1] = {
            set = 'Other',
            key = loc_key,
            vars = { 
                str_vars[1], str_vars[2], str_vars[3], str_vars[4], str_vars[5], 
                str_vars[6], str_vars[7], str_vars[8], str_vars[9], str_vars[10], 
                colours = col_vars 
            }
        }
    end

    -- Pass the UI Config key as the 4th argument
    add_tooltip("Faction", "war_faction", ex.faction, "faction")
    add_tooltip("Race", "war_race", ex.race, "race")
    add_tooltip("Class", "war_class", ex.class, "class")
    add_tooltip("Weapon", "war_weapon", ex.weapon, "weapon")
    add_tooltip("Damage", "war_damage", ex.damage, "damage")
    add_tooltip("Armor", "war_armor", ex.armor, "armor")
    add_tooltip("Role", "war_role", ex.role, "role")
    add_tooltip("Profession", "war_profession", ex.profession, "profession")
end