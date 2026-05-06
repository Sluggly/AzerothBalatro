Warcraft = Warcraft or {}
Warcraft.Constants = {}

-- Centralized HEX Color Definitions
Warcraft.Constants.Colors = {
    Faction = {
        Alliance = "4A90E2", Horde = "B83838", Scourge = "8E44Ad",
        Legion = "2ECC71", Pirate = "1088FF", Pantheon = "88FF88", Neutral = "888888"
    },
    Class = {
        Warrior = "C79C6E", Paladin = "F58CBA", Hunter = "ABD473", Rogue = "FFB569",
        Priest = "CFCFCF", ["Death Knight"] = "C41F3B", Shaman = "0070DE", Mage = "40C7EB",
        Warlock = "8787ED", Monk = "00FF96", Druid = "FF7D0A", ["Demon Hunter"] = "A330C9", Evoker = "33937F"
    },
    Race = {
        Human = "F0D3A6", Orc = "699635", Dwarf = "9D6B3C", ["Night Elf"] = "6B4C9A",
        Undead = "2F3029", Tauren = "6D4C2F", Gnome = "CD7F32", Troll = "209090",
        Goblin = "559E43", ["Blood Elf"] = "B3262B", Draenei = "26486B", Pandaren = "E6CC80",
        Dragon = "FFD700", Elemental = "00C0FF", Naga = "006666", Demon = "A330C9",
        God = "FFD700", Titan = "E5E4FF", Ogre = "D2B48C", Furbolg = "2ECC65",
        Murloc = "1010FF", Beast = "10FF05", Robot = "E5D2F1"
    },
    Weapon = {
        Sword = "829298", Axe = "A03C3C", Hammer = "998260", Staff = "734A29",
        Fist = "B87333", ["Fist Weapons"] = "B87333", Daggers = "425968", Spear = "6E8B74",
        Polearm = "6E8B74", Shield = "B8860B", Bow = "5A7D36", Gun = "4A4E53", Glaives = "34A56F"
    },
    Damage = {
        Physical = "C0C0C0", Piercing = "A0A0B0", Fire = "FF6A00", Frost = "69CCF0",
        Arcane = "B48AE8", Nature = "4DB800", Shadow = "7B5099", Holy = "FFD966",
    },
    Armor = {
        Cloth = "F0E68C", Leather = "A0522D", Mail = "7A9EB0", Plate = "9AAFCA", Unarmored = "888888",
    },
    Role = {
        ["Melee DPS"] = "E84848", ["Ranged DPS"] = "F5A623", Healer = "00E676", Tank = "4A90E2",
    },
    Profession = {
        Blacksmith = "8A7560", Engineer = "A8A878", Miner = "8B6914", Herbalist = "4CAF50",
        Leatherworker = "A0522D", Enchanter = "9C59D1", Jewelcrafter = "E91E63", Tailor = "E8D5B7",
        Skinner = "B07D50", Cook = "E8A87C", Fisher = "4FC3F7", Alchemist = "8BC34A",
        Inscriber = "90CAF9", Archaeologist = "D4A868", Aider = "80CBC4",
    }
}

-- Centralized Sticker Positions
Warcraft.Constants.StickerPositions = {
    faction    = { ["Horde"]=0, ["Alliance"]=1, ["Scourge"]=2, ["Legion"]=3, ["Pirate"]=4, ["Pantheon"]=5 },
    race       = {["Human"]=0, ["Orc"]=1, ["Dwarf"]=2, ["Night Elf"]=3, ["Undead"]=4, ["Tauren"]=5, ["Gnome"]=6, ["Troll"]=7, ["Goblin"]=8, ["Blood Elf"]=9, ["Draenei"]=10, ["Pandaren"]=11, ["Dragon"]=12, ["Elemental"]=13, ["Naga"]=14, ["Demon"]=15, ["God"]=16, ["Titan"]=17, ["Ogre"]=18, ["Furbolg"]=19, ["Murloc"]=20, ["Beast"]=21, ["Robot"]=22, ["Sha"]=23, ["Hozen"]=24, ["Quillboar"]=25, ["Loa"]=26, ["Naaru"]=27 },
    class      = { ["Warrior"]=0, ["Paladin"]=1, ["Hunter"]=2, ["Rogue"]=3,["Priest"]=4, ["Death Knight"]=5, ["Shaman"]=6, ["Mage"]=7, ["Warlock"]=8, ["Monk"]=9, ["Druid"]=10, ["Demon Hunter"]=11, ["Evoker"]=12 },
    weapon     = { ["Sword"]=0,["Axe"]=1, ["Hammer"]=2, ["Staff"]=3, ["Fist"]=4, ["Daggers"]=5, ["Spear"]=6, ["Polearm"]=7, ["Shield"]=8, ["Bow"]=9, ["Gun"]=10, ["Glaives"]=11 },
    damage     = { ["Physical"]=0,["Piercing"]=1, ["Fire"]=2, ["Frost"]=3, ["Arcane"]=4, ["Nature"]=5, ["Shadow"]=6, ["Holy"]=7 },
    armor      = {["Cloth"]=0, ["Leather"]=1, ["Mail"]=2, ["Plate"]=3, ["Unarmored"]=4 },
    role       = { ["Melee Dps"]=0, ["Ranged Dps"]=1, ["Healer"]=2, ["Tank"]=3 },
    profession = { ["Blacksmith"]=0, ["Engineer"]=1, ["Miner"]=2, ["Herbalist"]=3, ["Leatherworker"]=4, ["Enchanter"]=5, ["Jewelcrafter"]=6, ["Tailor"]=7, ["Skinner"]=8, ["Cook"]=9, ["Fisher"]=10, ["Alchemist"]=11, ["Inscriber"]=12, ["Archaeologist"]=13, ["Aider"]=14 }
}

-- Centralized Atlas Mapping
Warcraft.Constants.StickerAtlasMap = {
    faction = "factions", race = "races", class = "classes", weapon = "weapons",
    damage = "damages", armor = "armors", role = "roles", profession = "professions",
}

-- Class to armor type
Warcraft.Constants.ClassToArmor = {
    Warrior = "Plate", Paladin = "Plate", Hunter = "Mail", Rogue = "Leather",
    Priest = "Cloth", ["Death Knight"] = "Plate", Shaman = "Mail", Mage = "Cloth",
    Warlock = "Cloth", Monk = "Leather", Druid = "Leather", ["Demon Hunter"] = "Leather", Evoker = "Mail"
}

-- Class to roles
Warcraft.Constants.ClassToRole = {
    Warrior = {"Melee DPS", "Tank"}, Paladin = {"Melee DPS", "Tank", "Healer"}, Hunter = {"Melee DPS", "Ranged DPS"}, Rogue = {"Melee DPS"},
    Priest = {"Ranged DPS", "Healer"}, ["Death Knight"] = {"Melee DPS", "Tank"}, Shaman = {"Melee DPS", "Ranged DPS", "Healer"}, Mage = {"Ranged DPS"},
    Warlock = {"Ranged DPS"}, Monk = {"Melee DPS", "Tank", "Healer"}, Druid = {"Melee DPS", "Tank", "Ranged DPS", "Healer"}, ["Demon Hunter"] = {"Melee DPS", "Ranged DPS", "Tank"}, Evoker = {"Ranged DPS", "Healer"}
}

-- Class to damage type
Warcraft.Constants.ClassToDamage = {
    Warrior = {"Physical", "Piercing"}, Paladin = {"Physical", "Holy"}, Hunter = {"Physical", "Piercing", "Nature"}, Rogue = {"Physical", "Piercing", "Nature", "Shadow"},
    Priest = {"Shadow", "Holy"}, ["Death Knight"] = {"Physical", "Shadow"}, Shaman = {"Fire","Frost","Nature"}, Mage = {"Fire","Frost","Arcane"},
    Warlock = {"Shadow","Fire"}, Monk = {"Physical","Piercing"}, Druid = {"Physical","Piercing","Nature","Arcane"}, ["Demon Hunter"] = {"Physical","Fire","Arcane"}, Evoker = {"Arcane","Fire","Nature"}
}