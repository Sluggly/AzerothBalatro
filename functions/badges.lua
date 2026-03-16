Warcraft = Warcraft or {}
Warcraft.Badges = {}

-- HEX Color Definitions
Warcraft.Badges.Colors = {
    Faction = {
        Alliance = "4A90E2",
        Horde = "B83838",
        Scourge = "8E44Ad",
        Legion = "2ECC71",
        Neutral = "888888"
    },
    
    Class = {
        Warrior = "C79C6E",
        Paladin = "F58CBA",
        Hunter = "ABD473",
        Rogue = "FFB569",
        Priest = "88F0FF",
        Death_Knight = "C41F3B",
        Shaman = "0070DE",
        Mage = "40C7EB",
        Warlock = "8787ED",
        Monk = "00FF96",
        Druid = "FF7D0A",
        Demon_Hunter = "A330C9",
        Evoker = "33937F"
    },
    
    Race = {
        Human = "F0D3A6",
        Orc = "699635",
        Dwarf = "9D6B3C",
        Night_Elf = "6B4C9A",
        Undead = "2F3029",
        Tauren = "6D4C2F",
        Gnome = "CD7F32",
        Troll = "209090",
        Goblin = "559E43",
        Blood_Elf = "B3262B",
        Draenei = "26486B",
        Pandaren = "E6CC80",
        Dragon = "FFD700",
        Elemental = "00C0FF",
        Naga = "006666",
        Demon = "A330C9",
        God = "FFD700",
        Titan = "E5E4FF",
        Ogre = "D2B48C",
        Furbolg = "2ECC65",
        Murloc = "1010FF",
        Beast = "10FF05",
        Robot = "E5D2F1"
    },

    Weapon = {
        Sword = "829298",
        Axe = "A03C3C",
        Hammer = "998260",
        Staff = "734A29",
        Fist = "B87333",
        Fist_Weapons = "B87333",
        Daggers = "425968",
        Spear = "6E8B74",
        Polearm = "6E8B74",
        Shield = "B8860B",
        Bow = "5A7D36",
        Gun = "4A4E53",
        Glaives = "34A56F"
    }
}

for category, entries in pairs(Warcraft.Badges.Colors) do
    for name, hex_str in pairs(entries) do
        local upper_key = "WAR_" .. string.upper(name)
        local lower_key = "war_" .. string.lower(name)
        local color = HEX(hex_str)
        if not G.C[upper_key] then G.C[upper_key] = color end
        if not G.C[lower_key] then G.C[lower_key] = color end
    end
end

-- Helper: Get list from input (handles string or table)
local function get_list(input)
    if not input then return {} end
    if type(input) == "table" then return input end
    return { input } -- Wrap single string in a table
end

function Warcraft.Badges.append_tooltips(info_queue, card)
    if not card.ability or not card.ability.extra then return end
    local extra = card.ability.extra

    local function add_tooltip(category, loc_key, val)
        if not val or val == "None" or val == "Unknown" or val == "Normal" then return end
        
        -- Ensure val is a table so we can loop through it
        local val_list = type(val) == "table" and val or {val}
        
        -- Prepare 10 empty text variables and 10 invisible colors (G.C.CLEAR)
        local str_vars = {"", "", "", "", "", "", "", "", "", ""}
        local col_vars = {
            G.C.CLEAR, G.C.CLEAR, G.C.CLEAR, G.C.CLEAR, G.C.CLEAR, 
            G.C.CLEAR, G.C.CLEAR, G.C.CLEAR, G.C.CLEAR, G.C.CLEAR
        }

        for i, v in ipairs(val_list) do
            if i > 10 then break end -- Hard limit expanded to 10

            local lookup_key = v:gsub(" ", "_")
            local hex_code = Warcraft.Badges.Colors[category] and Warcraft.Badges.Colors[category][lookup_key]
            
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

    add_tooltip("Faction", "war_faction", extra.faction)
    add_tooltip("Race", "war_race", extra.race)
    add_tooltip("Class", "war_class", extra.class)
    add_tooltip("Weapon", "war_weapon", extra.weapon)
end