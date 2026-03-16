sendDebugMessage("Azeroth Balatro Mod : Generating all Enemy Jokers...")
-- Format: { Small Name, Big Name, Boss Name, Category, Internal Value, Display Name, Minimum Ante }
local enemy_data = {
    -- Ranks
    {"Draenei Guardian", "Draenei Watcher", "Draenei Seer", "rank", "Ace", "Ace", 3},
    {"Kobold", "Kobold Geomancer", "Kobold Taskmaster", "rank", "2", "2", 3},
    {"Wildkin", "Enraged Wildkin", "Berserk Wildkin", "rank", "3", "3", 3},
    {"Murloc Tiderunner", "Murloc Huntsmen", "Murloc Mutant", "rank", "4", "4", 3},
    {"Centaur Drudge", "Centaur Impaler", "Centaur Khan", "rank", "5", "5", 3},
    {"Harpy Rogue", "Harpy Windwitch", "Harpy Queen", "rank", "6", "6", 3},
    {"Furbolg", "Furbolg Shaman", "Furbolg Ursa Warrior", "rank", "7", "7", 3},
    {"Ogre Warrior", "Ogre Magi", "Ogre Lord", "rank", "8", "8", 3},
    {"Gnoll", "Gnoll Warden", "Gnoll Overseer", "rank", "9", "9", 3},
    {"Timber Wolf", "Giant Wolf", "Dire Wolf", "rank", "10", "10", 3},
    {"Spider", "Giant Spider", "Brood Mother", "rank", "Jack", "Jack", 3},
    {"Satyr", "Satyr Soulstealer", "Satyr Hellcaller", "rank", "Queen", "Queen", 3},
    {"Lightning Lizard", "Thunder Lizard", "Storm Wyrm", "rank", "King", "King", 3},

    -- Editions
    {"Dragon Whelp", "Drake", "Dragon", "edition", "base_edition", "Base Edition", 7},
    {"Mud Golem", "Rock Golem", "Granite Golem", "edition", "foil", "Foil", 0},
    {"Skeleton Archer", "Skeletal Marskman", "Burning Archer", "edition", "holo", "Holographic", 0},
    {"Sasquatch", "Sasquatch Oracle", "Ancient Sasquatch", "edition", "polychrome", "Polychrome", 0},

    -- Suits
    {"Hydra", "Elder Hydra", "Ancient Hydra", "suit", "Hearts", "Heart", 5},
    {"Makrura Prawn", "Makrura Tidecaller", "Makrura Tidal Lord", "suit", "Diamonds", "Diamond", 5},
    {"Sea Giant", "Sea Giant Hunter", "Sea Giant Behemoth", "suit", "Spades", "Spade", 5},
    {"Voidwalker", "Greater Voidwalker", "Elder Voidwalker", "suit", "Clubs", "Club", 5},

    -- Seals
    {"Wendigo", "Elder Wendigo", "Ancient Wendigo", "seal", "no_seal", "No Seal", 7},
    {"Nerubian Spiderling", "Nerubian Seer", "Nerubian Queen", "seal", "Blue", "Blue Seal", 0},
    {"Troll", "Troll Trapper", "Troll Warlord", "seal", "Red", "Red Seal", 0},
    {"Tuskarr Fighter", "Tuskarr Spearman", "Tuskarr Chieftain", "seal", "Gold", "Gold Seal", 0},
    {"Faceless One Trickster", "Faceless One Terror", "Faceless One Deathbringer", "seal", "Purple", "Purple Seal", 0},

    -- Enhancements
    {"Crystal Arachnathid", "Warrior Arachnathid", "Overlord Arachnathid", "enhancement", "base_enhancement", "Base Enhancement", 7},
    {"Mammoth", "Icetusk Mammoth", "Dire Mammoth", "enhancement", "m_bonus", "Bonus", 0},
    {"Sludge Minion", "Sludge Flinger", "Sludge Monstrosity", "enhancement", "m_mult", "Mult", 0},
    {"Corrupted Treant", "Poison Treant", "Plague Treant", "enhancement", "m_wild", "Wild", 0},
    {"Fel Beast", "Fel Stalker", "Fel Ravager", "enhancement", "m_glass", "Glass", 0},
    {"Bandit", "Rogue Wizard", "Dark Wizard", "enhancement", "m_steel", "Steel", 0},
    {"Rogue", "Brigand", "Bandit Lord", "enhancement", "m_stone", "Stone", 0},
    {"Razormane Scout", "Razormane Brute", "Razormane Chieftain", "enhancement", "m_gold", "Gold", 0},
    {"Magnataur Warrior", "Magnataur Reaver", "Magnataur Destroyer", "enhancement", "m_lucky", "Lucky", 0},

    -- Hand Types
    {"Unbroken Darkhunter", "Unbroken Rager", "Unbroken Darkweaver", "hand_type", "High Card", "High Card", 0},
    {"Eredar Sorceror", "Eredar Diabolist", "Eredar Warlock", "hand_type", "Pair", "Pair", 0},
    {"Infernal Contraption", "Infernal Machine", "Infernal Juggernaut", "hand_type", "Two Pair", "Two Pair", 0},
    {"Succubus", "Vile Temptress", "Queen of Suffering", "hand_type", "Three of a Kind", "Three of a Kind", 0},
    {"Sea Turtle", "Giant Sea Turtle", "Dragon Turtle", "hand_type", "Four of a Kind", "Four of a Kind", 0},
    {"Spider Crab Shorecrawler", "Spider Crab Limbripper", "Spider Crab Behemoth", "hand_type", "Five of a Kind", "Five of a Kind", 0},
    {"Revenant of the Tides", "Revenant of the Depths", "Deeplord Revenant", "hand_type", "Flush", "Flush", 0},
    {"Chaos Peon", "Chaos Warlock", "Chaos Warlord", "hand_type", "Straight", "Straight", 0},
    {"Naga Myrmidon", "Naga Siren", "Naga Royal Guard", "hand_type", "Straight Flush", "Straight Flush", 0},
    {"Quillbeast", "Raging Quillbeast", "Berserker Quillbeast", "hand_type", "Royal Flush", "Royal Flush", 0},
    {"Skeleton Orc", "Skeleton Orc Grunt", "Skeleton Orc Champion", "hand_type", "Flush House", "Flush House", 0},
    {"Stormreaver Apprentice", "Stormreaver Hermit", "Stormreaver Necrolyte", "hand_type", "Full House", "Full House", 0}
}

-- Generate all Enemy Jokers
local current_index = 1
for _, data in ipairs(enemy_data) do
    local small_name, big_name, boss_name = data[1], data[2], data[3]
    local cat, val, d_name, d_ante = data[4], data[5], data[6], data[7]

    -- Create Small Blind Enemy
    Warcraft.create_enemy({
        name = small_name,
        index = current_index,
        rarity = 1,
        config = { extra = { target_cat = cat, target_val = val, target_name = d_name, min_ante = d_ante } }
    })
    current_index = current_index + 1

    -- Create Big Blind Enemy
    Warcraft.create_enemy({
        name = big_name,
        index = current_index,
        rarity = 2,
        config = { extra = { target_cat = cat, target_val = val, target_name = d_name, min_ante = d_ante } }
    })
    current_index = current_index + 1

    -- Create Boss Blind Enemy
    Warcraft.create_enemy({
        name = boss_name,
        index = current_index,
        rarity = 3,
        config = { extra = { target_cat = cat, target_val = val, target_name = d_name, min_ante = d_ante } }
    })
    current_index = current_index + 1
end
sendDebugMessage("Azeroth Balatro Mod : Generating all Enemy Jokers done!")