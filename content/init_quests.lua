sendDebugMessage("Azeroth Balatro Mod : Generating all Quests...")
Warcraft.create_quest({
    name = "Stormwind City",
    index = 1,
    combo_character = {"Varian Wrynn", "Anduin Wrynn", "Bolvar Fordragon"},
    ally_faction = {"Alliance"},
    enemy_faction = {"Horde"},
    ally_race = {"Human", "Dwarf", "Night Elf", "Gnome", "Draenei", "Worgen"},
    enemy_race = {"Orc", "Tauren", "Troll", "Undead", "Blood Elf", "Goblin"},
    ally_class = {"Paladin", "Priest", "Warrior", "Mage", "Rogue", "Warlock"}
})
Warcraft.create_quest({
    name = "Ironforge",
    index = 2,
    combo_character = {"Magni Bronzebeard", "Muradin Bronzebeard", "Gelbin Mekkatorque"},
    ally_faction = {"Alliance"},
    enemy_faction = {"Horde"},
    ally_race = {"Dwarf", "Gnome", "Human"},
    enemy_race = {"Orc", "Troll", "Tauren"},
    ally_class = {"Hunter", "Warrior", "Paladin", "Mage", "Priest"}
})
Warcraft.create_quest({
    name = "Undercity",
    index = 3,
    combo_character = {"Sylvanas Windrunner", "Nathanos Blightcaller", "Varimathras", "Terenas Menethil II"},
    ally_faction = {"Horde"},
    enemy_faction = {"Alliance", "Scourge"},
    ally_race = {"Undead", "Blood Elf"},
    enemy_race = {"Human", "Worgen"},
    ally_class = {"Rogue", "Warlock", "Priest", "Mage"}
})
Warcraft.create_quest({
    name = "Silvermoon City",
    index = 4,
    combo_character = {"Kael'thas Sunstrider", "Lor'themar Theron", "Lady Liadrin"},
    ally_faction = {"Horde"},
    enemy_faction = {"Alliance", "Scourge"},
    ally_race = {"Blood Elf"},
    enemy_race = {"Undead", "Night Elf", "Troll"},
    ally_class = {"Mage", "Paladin", "Priest", "Warlock"},
    enemy_class = {"Hunter", "Rogue"}
})
Warcraft.create_quest({
    name = "Karazhan",
    index = 5,
    combo_character = {"Medivh", "Khadgar", "Moroes"},
    ally_faction = {"Alliance", "Horde"}, 
    enemy_faction = {"Demon", "Scourge"},
    ally_class = {"Mage", "Warlock", "Priest"},
    enemy_class = {"Warlock", "Warrior", "Rogue"}
})
Warcraft.create_quest({
    name = "Blackrock Mountain",
    index = 6,
    combo_character = {"Nefarian", "Ragnaros"},
    enemy_faction = {"Alliance", "Horde"},
    ally_race = {"Dwarf", "Orc", "Dragon", "Elemental"},
    enemy_race = {"Human", "Night Elf", "Gnome", "Tauren"},
    ally_class = {"Warrior", "Shaman", "Warlock", "Rogue"},
    enemy_class = {"Paladin", "Priest", "Mage"}
})
Warcraft.create_quest({
    name = "Orgrimmar",
    index = 7,
    combo_character = {"Thrall", "Garrosh Hellscream", "Vol'jin", "Varok Saurfang"},
    ally_faction = {"Horde"},
    enemy_faction = {"Alliance"},
    ally_race = {"Orc", "Tauren", "Troll", "Undead", "Blood Elf", "Goblin"},
    enemy_race = {"Human", "Dwarf", "Night Elf", "Gnome", "Draenei", "Worgen"},
    ally_class = {"Warrior", "Shaman", "Hunter", "Warlock", "Rogue"}
})
Warcraft.create_quest({
    name = "Thunder Bluff",
    index = 8,
    combo_character = {"Cairne Bloodhoof", "Baine Bloodhoof", "Hamuul Runetotem"},
    ally_faction = {"Horde"},
    enemy_faction = {"Alliance"},
    ally_race = {"Tauren", "Orc", "Troll"},
    enemy_race = {"Human", "Dwarf", "Night Elf", "Gnome"},
    ally_class = {"Shaman", "Druid", "Hunter", "Warrior"},
    enemy_class = {"Warlock", "Rogue"}
})
Warcraft.create_quest({
    name = "Darnassus",
    index = 9,
    combo_character = {"Tyrande Whisperwind", "Malfurion Stormrage"},
    ally_faction = {"Alliance"},
    enemy_faction = {"Horde", "Legion"},
    ally_race = {"Night Elf", "Worgen", "Draenei"},
    enemy_race = {"Orc", "Undead", "Troll", "Blood Elf"},
    ally_class = {"Druid", "Hunter", "Priest", "Rogue"},
    enemy_class = {"Warlock", "Death Knight"}
})
Warcraft.create_quest({
    name = "Exodar",
    index = 10,
    combo_character = {"Prophet Velen", "Farseer Nobundo"},
    ally_faction = {"Alliance"},
    enemy_faction = {"Horde", "Legion"},
    ally_race = {"Draenei", "Night Elf", "Human"},
    enemy_race = {"Orc", "Blood Elf", "Undead"},
    ally_class = {"Paladin", "Priest", "Shaman", "Mage"},
    enemy_class = {"Warlock", "Rogue"}
})
Warcraft.create_quest({
    name = "Ahn'Qiraj",
    index = 11,
    combo_character = {"C'Thun"},
    enemy_faction = {"Alliance", "Horde", "Dragon"},
    ally_race = {"God"},
    enemy_race = {"Human", "Orc", "Night Elf", "Tauren"},
    ally_class = {"Warrior", "Priest", "Warlock"},
    enemy_class = {"Paladin", "Druid", "Hunter"}
})
Warcraft.create_quest({
    name = "Onyxia's Lair",
    index = 12,
    combo_character = {"Onyxia", "Nefarian", "Deathwing"},
    enemy_faction = {"Alliance", "Horde"},
    ally_race = {"Dragon"},
    enemy_race = {"Human", "Orc", "Dwarf", "Gnome"},
    ally_class = {"Warrior", "Mage", "Warlock"},
    enemy_class = {"Hunter", "Rogue", "Paladin"}
})
Warcraft.create_quest({
    name = "Shattrath City",
    index = 13,
    combo_character = {"A'dal", "Khadgar"},
    ally_faction = {"Alliance", "Horde"},
    enemy_faction = {"Legion"},
    ally_race = {"Draenei", "Blood Elf", "Human", "Orc"},
    enemy_race = {"Demon"},
    ally_class = {"Paladin", "Priest", "Mage", "Shaman"},
    enemy_class = {"Warlock", "Rogue"}
})
Warcraft.create_quest({
    name = "Thrallmar",
    index = 14,
    combo_character = {"Nazgrel", "Thrall"},
    ally_faction = {"Horde"},
    enemy_faction = {"Alliance", "Legion"},
    ally_race = {"Orc", "Troll", "Tauren", "Blood Elf"},
    enemy_race = {"Human", "Dwarf", "Demon"},
    ally_class = {"Warrior", "Hunter", "Shaman", "Warlock"},
    enemy_class = {"Paladin", "Priest", "Mage"}
})
Warcraft.create_quest({
    name = "Black Temple",
    index = 15,
    combo_character = {"Illidan Stormrage", "Akama", "Teron Gorefiend"},
    ally_faction = {"Legion"},
    enemy_faction = {"Alliance", "Horde"},
    ally_race = {"Night Elf", "Blood Elf", "Demon"},
    enemy_race = {"Human", "Orc", "Draenei"},
    ally_class = {"Demon Hunter", "Warlock", "Rogue"},
    enemy_class = {"Paladin", "Priest", "Druid", "Shaman"}
})
Warcraft.create_quest({
    name = "Dalaran",
    index = 16,
    combo_character = {"Rhonin", "Jaina Proudmoore", "Khadgar"},
    ally_faction = {"Alliance", "Horde"},
    enemy_faction = {"Scourge", "Legion"},
    ally_race = {"Human", "Blood Elf", "Blood Elf", "Gnome"},
    enemy_race = {"Undead", "Demon", "Dragon"},
    ally_class = {"Mage", "Priest", "Warlock", "Paladin"},
    enemy_class = {"Death Knight", "Rogue"}
})
Warcraft.create_quest({
    name = "Wyrmrest Temple",
    index = 17,
    combo_character = {"Alexstrasza", "Krasus", "Chromie", "Kalecgos"},
    ally_faction = {"Alliance", "Horde"},
    enemy_faction = {"Scourge"},
    ally_race = {"Dragon", "Human", "Night Elf", "Blood Elf"},
    enemy_race = {"Undead", "Dragon"},
    ally_class = {"Druid", "Mage", "Shaman", "Priest"},
    enemy_class = {"Death Knight", "Warlock"}
})
Warcraft.create_quest({
    name = "Icecrown Citadel",
    index = 18,
    combo_character = {"Arthas Menethil", "Tirion Fordring", "Darion Mograine"},
    ally_faction = {"Scourge"},
    enemy_faction = {"Alliance", "Horde"},
    ally_race = {"Undead"},
    enemy_race = {"Human", "Blood Elf"},
    ally_class = {"Death Knight", "Warrior", "Warlock"},
    enemy_class = {"Paladin", "Priest"}
})
Warcraft.create_quest({
    name = "Ulduar",
    index = 19,
    combo_character = {"Algalon the Observer", "Brann Bronzebeard", "Yogg-Saron", "Mimiron"},
    ally_faction = {"Alliance", "Horde"},
    enemy_faction = {"Scourge"},
    ally_race = {"Dwarf", "Gnome", "Human", "God"},
    enemy_race = {"Undead"},
    ally_class = {"Hunter", "Warrior", "Mage", "Shaman"},
    enemy_class = {"Priest", "Warlock"}
})
Warcraft.create_quest({
    name = "Nordrassil",
    index = 20,
    combo_character = {"Malfurion Stormrage", "Tyrande Whisperwind", "Ysera", "Cenarius"},
    ally_faction = {"Alliance", "Horde"},
    enemy_faction = {"Legion"},
    ally_race = {"Night Elf", "Tauren", "Worgen", "Troll"},
    enemy_race = {"Demon", "Undead", "Orc"},
    ally_class = {"Druid", "Shaman", "Hunter", "Priest"},
    enemy_class = {"Warlock", "Death Knight"}
})
Warcraft.create_quest({
    name = "Ramkahen",
    index = 21,
    combo_character = {"Harrison Jones", "Brann Bronzebeard"},
    ally_faction = {"Alliance", "Horde"},
    ally_race = {"Human", "Dwarf"},
    enemy_race = {"Elemental"},
    ally_class = {"Hunter", "Warrior", "Priest", "Rogue"},
    enemy_class = {"Shaman", "Warlock"}
})
Warcraft.create_quest({
    name = "Firelands",
    index = 22,
    combo_character = {"Ragnaros", "Malfurion Stormrage"},
    enemy_faction = {"Alliance", "Horde"},
    ally_race = {"Elemental", "Night Elf", "Tauren"},
    enemy_race = {"Human", "Orc", "Dwarf", "Worgen"},
    ally_class = {"Druid", "Shaman", "Warlock", "Mage"},
    enemy_class = {"Paladin", "Warrior", "Hunter"}
})
Warcraft.create_quest({
    name = "Shrine of Two Moons",
    index = 23,
    combo_character = {"Garrosh Hellscream", "Vol'jin"},
    ally_faction = {"Horde"},
    enemy_faction = {"Alliance"},
    ally_race = {"Orc", "Tauren", "Troll", "Undead", "Blood Elf", "Goblin", "Pandaren"},
    enemy_race = {"Human", "Dwarf", "Night Elf"},
    ally_class = {"Warrior", "Monk", "Shaman", "Rogue"},
    enemy_class = {"Paladin", "Priest", "Mage"}
})
Warcraft.create_quest({
    name = "Shrine of Seven Stars",
    index = 24,
    combo_character = {"Anduin Wrynn", "Varian Wrynn"},
    ally_faction = {"Alliance"},
    enemy_faction = {"Horde"},
    ally_race = {"Human", "Dwarf", "Night Elf", "Gnome", "Draenei", "Worgen", "Pandaren"},
    enemy_race = {"Orc", "Tauren", "Troll"},
    ally_class = {"Paladin", "Priest", "Monk", "Mage"},
    enemy_class = {"Warrior", "Shaman", "Warlock"}
})
Warcraft.create_quest({
    name = "Halfhill",
    index = 25,
    combo_character = {"Chen Stormstout", "Nomi"},
    ally_faction = {"Alliance", "Horde"},
    ally_race = {"Pandaren", "Human", "Orc"},
    enemy_race = {"Beast"},
    ally_class = {"Monk", "Hunter", "Shaman"},
    enemy_class = {"Rogue", "Warrior"}
})
Warcraft.create_quest({
    name = "Lunarfall",
    index = 26,
    combo_character = {"Khadgar", "Yrel", "Varian Wrynn"},
    ally_faction = {"Alliance"},
    enemy_faction = {"Horde"},
    ally_race = {"Human", "Draenei", "Dwarf", "Worgen", "Night Elf"},
    enemy_race = {"Orc", "Ogre"},
    ally_class = {"Paladin", "Mage", "Priest", "Warrior"},
    enemy_class = {"Warrior", "Shaman", "Warlock"}
})
Warcraft.create_quest({
    name = "Frostwall",
    index = 27,
    combo_character = {"Durotan", "Thrall", "Gazlowe", "Vol'jin"},
    ally_faction = {"Horde"},
    enemy_faction = {"Alliance"},
    ally_race = {"Orc", "Tauren", "Troll", "Goblin", "Blood Elf"},
    enemy_race = {"Human", "Draenei", "Ogre"},
    ally_class = {"Shaman", "Warrior", "Hunter", "Rogue"},
    enemy_class = {"Paladin", "Priest", "Mage"}
})
Warcraft.create_quest({
    name = "Warspear",
    index = 28,
    combo_character = {"Vol'jin"},
    ally_faction = {"Horde"},
    enemy_faction = {"Alliance"},
    ally_race = {"Orc", "Troll", "Undead", "Blood Elf", "Tauren"},
    enemy_race = {"Human", "Dwarf", "Night Elf", "Draenei", "Gnome"},
    ally_class = {"Warrior", "Rogue", "Warlock", "Death Knight"},
    enemy_class = {"Paladin", "Priest", "Mage", "Hunter"}
})
Warcraft.create_quest({
    name = "Stormshield",
    index = 29,
    combo_character = {"Varian Wrynn"},
    ally_faction = {"Alliance"},
    enemy_faction = {"Horde"},
    ally_race = {"Human", "Dwarf", "Night Elf", "Gnome", "Draenei", "Worgen"},
    enemy_race = {"Orc", "Tauren", "Troll", "Undead", "Blood Elf"},
    ally_class = {"Paladin", "Priest", "Mage", "Hunter"},
    enemy_class = {"Warrior", "Rogue", "Warlock", "Death Knight"}
})
Warcraft.create_quest({
    name = "Highmaul",
    index = 30,
    combo_character = {"Kargath Bladefist", "Cho'gall"},
    enemy_faction = {"Alliance", "Horde"},
    ally_race = {"Ogre", "Orc"},
    enemy_race = {"Human", "Draenei", "Dwarf", "Tauren"},
    ally_class = {"Mage", "Warrior", "Rogue"},
    enemy_class = {"Paladin", "Priest", "Shaman"}
})
Warcraft.create_quest({
    name = "Hellfire Citadel",
    index = 31,
    combo_character = {"Archimonde", "Gul'dan", "Grommash Hellscream", "Khadgar"},
    ally_faction = {"Legion"},
    enemy_faction = {"Alliance", "Horde"},
    ally_race = {"Demon", "Orc"},
    enemy_race = {"Human", "Draenei", "Dwarf", "Night Elf"},
    ally_class = {"Warlock", "Warrior", "Rogue"},
    enemy_class = {"Paladin", "Priest", "Mage"}
})
Warcraft.create_quest({
    name = "Suramar City",
    index = 32,
    combo_character = {"Grand Magistrix Elisande", "First Arcanist Thalyssra"},
    ally_faction = {"Legion"},
    enemy_faction = {"Alliance", "Horde"},
    ally_race = {"Demon"},
    enemy_race = {"Night Elf", "Blood Elf", "Human"},
    ally_class = {"Mage", "Warlock", "Warrior"},
    enemy_class = {"Druid", "Paladin", "Priest"}
})
Warcraft.create_quest({
    name = "The Nighthold",
    index = 33,
    combo_character = {"Gul'dan", "Illidan Stormrage", "Khadgar", "Grand Magistrix Elisande"},
    ally_faction = {"Legion"},
    enemy_faction = {"Alliance", "Horde"},
    ally_race = {"Demon", "Orc"},
    enemy_race = {"Night Elf", "Blood Elf", "Human", "Tauren"},
    ally_class = {"Mage", "Warlock", "Demon Hunter"},
    enemy_class = {"Paladin", "Priest", "Shaman"}
})
Warcraft.create_quest({
    name = "Tomb of Sargeras",
    index = 34,
    combo_character = {"Kil'jaeden", "Prophet Velen", "Maiev Shadowsong"},
    ally_faction = {"Legion"},
    ally_race = {"Demon", "Naga"},
    enemy_race = {"Draenei", "Human", "Night Elf", "Orc"},
    ally_class = {"Warlock", "Death Knight", "Demon Hunter"},
    enemy_class = {"Paladin", "Priest", "Rogue"}
})
Warcraft.create_quest({
    name = "Boralus",
    index = 35,
    combo_character = {"Jaina Proudmoore", "Genn Greymane"},
    ally_faction = {"Alliance"},
    enemy_faction = {"Horde"},
    ally_race = {"Human", "Worgen", "Dwarf", "Gnome"},
    enemy_race = {"Orc", "Troll", "Undead", "Tauren"},
    ally_class = {"Rogue", "Mage", "Hunter", "Warrior"},
    enemy_class = {"Shaman", "Warlock", "Death Knight"}
})
Warcraft.create_quest({
    name = "Freehold",
    index = 36,
    combo_character = {"Captain Eudora"},
    enemy_faction = {"Alliance"},
    ally_race = {"Human", "Orc", "Troll", "Goblin"},
    enemy_race = {"Human", "Dwarf", "Worgen"},
    ally_class = {"Rogue", "Warrior", "Hunter"},
    enemy_class = {"Paladin", "Mage", "Priest"}
})
Warcraft.create_quest({
    name = "Dazar'alor",
    index = 37,
    combo_character = {"King Rastakhan", "Princess Talanji", "Bwonsamdi", "Jaina Proudmoore"},
    ally_faction = {"Horde"},
    enemy_faction = {"Alliance"},
    ally_race = {"Troll", "Orc", "Tauren", "Blood Elf", "Undead"},
    enemy_race = {"Human", "Dwarf", "Gnome", "Night Elf", "Draenei"},
    ally_class = {"Shaman", "Priest", "Paladin", "Druid"},
    enemy_class = {"Warrior", "Mage", "Rogue"}
})
Warcraft.create_quest({
    name = "Uldir",
    index = 38,
    combo_character = {"G'huun"},
    enemy_faction = {"Horde", "Alliance"},
    ally_race = {"Troll"},
    enemy_race = {"Human", "Orc", "Tauren", "Dwarf"},
    ally_class = {"Priest", "Warlock", "Death Knight"},
    enemy_class = {"Paladin", "Druid", "Shaman"}
})
Warcraft.create_quest({
    name = "Oribos",
    index = 39,
    combo_character = {"Bolvar Fordragon", "Pelagos"},
    ally_faction = {"Alliance", "Horde"},
    enemy_faction = {"Legion"},
    ally_race = {"Human", "Orc", "Night Elf", "Undead"},
    enemy_race = {"Demon", "Undead"},
    ally_class = {"Death Knight", "Paladin", "Priest", "Monk"},
    enemy_class = {"Warlock", "Rogue"}
})
Warcraft.create_quest({
    name = "Sinfall",
    index = 40,
    combo_character = {"Prince Renathal", "Theotar, the Mad Duke"},
    ally_faction = {"Alliance", "Horde"},
    ally_race = {"Human", "Blood Elf"},
    enemy_race = {"Undead"},
    ally_class = {"Rogue", "Priest", "Warlock", "Warrior"},
    enemy_class = {"Paladin", "Hunter"}
})
Warcraft.create_quest({
    name = "Elysian Hold",
    index = 41,
    combo_character = {"Kyrestia the Firstborne", "Uther the Lightbringer", "Kleia"},
    ally_faction = {"Alliance", "Horde"},
    ally_race = {"Human", "Draenei", "Blood Elf"},
    enemy_race = {"Undead"},
    ally_class = {"Paladin", "Priest", "Monk"},
    enemy_class = {"Death Knight", "Warlock", "Rogue"}
})
Warcraft.create_quest({
    name = "Heart of the Forest",
    index = 42,
    combo_character = {"The Winter Queen", "Ysera"},
    ally_faction = {"Alliance", "Horde"},
    ally_race = {"Night Elf", "Tauren"},
    enemy_race = {"Undead", "Orc"},
    ally_class = {"Druid", "Hunter", "Shaman"},
    enemy_class = {"Warlock", "Death Knight", "Rogue"}
})
Warcraft.create_quest({
    name = "Castle Nathria",
    index = 43,
    combo_character = {"Sire Denathrius", "Prince Renathal", "Remornia"},
    enemy_faction = {"Alliance", "Horde"},
    enemy_race = {"Human", "Orc", "Blood Elf", "Dwarf"},
    ally_class = {"Warlock", "Death Knight", "Rogue"},
    enemy_class = {"Paladin", "Priest", "Hunter"}
})
Warcraft.create_quest({
    name = "Sanctum of Domination",
    index = 44,
    combo_character = {"Sylvanas Windrunner", "Zovaal", "Kel'Thuzad", "Anduin Wrynn"},
    enemy_faction = {"Alliance", "Horde"},
    ally_race = {"Undead", "Human"},
    enemy_race = {"Human", "Orc", "Night Elf", "Tauren"},
    ally_class = {"Death Knight", "Warlock", "Hunter"},
    enemy_class = {"Paladin", "Priest", "Shaman", "Druid"}
})
Warcraft.create_quest({
    name = "Valdrakken",
    index = 45,
    combo_character = {"Alexstrasza", "Nozdormu", "Kalecgos", "Wrathion"},
    ally_faction = {"Alliance", "Horde"},
    ally_race = {"Dragon", "Human", "Orc"},
    enemy_race = {"Elemental", "Troll", "Tauren"},
    ally_class = {"Evoker", "Mage", "Warrior", "Shaman"},
    enemy_class = {"Shaman", "Rogue", "Warlock"}
})
Warcraft.create_quest({
    name = "Iskaara",
    index = 46,
    combo_character = {"Kalecgos"},
    ally_faction = {"Alliance", "Horde"},
    ally_race = {"Human", "Orc", "Dragon"},
    enemy_race = {"Gnoll", "Elemental", "Dragon"},
    ally_class = {"Shaman", "Hunter", "Warrior"},
    enemy_class = {"Mage", "Shaman", "Rogue"}
})
Warcraft.create_quest({
    name = "Aberrus",
    index = 47,
    combo_character = {"Scalecommander Sarkareth", "Neltharion"},
    enemy_faction = {"Alliance", "Horde"},
    ally_race = {"Dragon","Elemental"},
    enemy_race = {"Human", "Orc","Dwarf"},
    ally_class = {"Evoker", "Warlock", "Warrior"},
    enemy_class = {"Paladin", "Priest", "Shaman"}
})
Warcraft.create_quest({
    name = "Dornogal",
    index = 48,
    combo_character = {"Moira Thaurissan", "Magni Bronzebeard", "Brann Bronzebeard"},
    ally_faction = {"Alliance", "Horde"},
    ally_race = {"Dwarf", "Human", "Orc"},
    enemy_race = {"Void Elf", "Elemental"},
    ally_class = {"Warrior", "Paladin", "Shaman", "Hunter"},
    enemy_class = {"Warlock", "Rogue", "Priest"}
})
Warcraft.create_quest({
    name = "City of Threads",
    index = 49,
    combo_character = {"Queen Ansurek", "Queen Neferess"},
    enemy_faction = {"Alliance", "Horde"},
    ally_race = {"Goblin"},
    enemy_race = {"Human", "Dwarf", "Orc"},
    ally_class = {"Rogue", "Warlock", "Mage", "Death Knight"},
    enemy_class = {"Paladin", "Priest", "Warrior"}
})
Warcraft.create_quest({
    name = "Priory of the Sacred Flame",
    index = 50,
    combo_character = {"Xal'atath"},
    ally_faction = {"Alliance", "Horde"},
    ally_race = {"Human", "Blood Elf"},
    enemy_race = {"Human","Void Elf"},
    ally_class = {"Paladin", "Priest", "Warrior", "Mage"},
    enemy_class = {"Warlock", "Rogue", "Death Knight"}
})
Warcraft.create_quest({
    name = "Booty Bay",
    index = 51,
    combo_character = {"Baron Revilgaz"},
    ally_faction = {"Horde", "Alliance"},
    ally_race = {"Goblin", "Human", "Troll", "Orc", "Tauren"},
    enemy_race = {"Human", "Goblin", "Worgen"},
    ally_class = {"Rogue", "Hunter", "Warrior"},
    enemy_class = {"Rogue", "Mage"}
})
Warcraft.create_quest({
    name = "Naxxramas",
    index = 52,
    combo_character = {"Kel'Thuzad", "Patchwerk", "Saphiron", "Baron Rivendare"},
    ally_faction = {"Scourge"},
    enemy_faction = {"Alliance", "Horde"},
    ally_race = {"Undead", "Human"},
    enemy_race = {"Human", "Dwarf", "Orc", "Tauren"},
    ally_class = {"Death Knight", "Mage", "Warlock"},
    enemy_class = {"Paladin", "Priest", "Warrior"}
})
Warcraft.create_quest({
    name = "Gadgetzan",
    index = 53,
    combo_character = {"Marin Noggenfogger"},
    ally_faction = {"Alliance", "Horde"},
    ally_race = {"Goblin", "Gnome", "Human", "Orc"},
    enemy_race = {"Human", "Troll", "Goblin"},
    ally_class = {"Rogue", "Hunter", "Mage"},
    enemy_class = {"Rogue", "Warrior"}
})
Warcraft.create_quest({
    name = "Area 52",
    index = 54,
    combo_character = {"Millhouse Manastorm"},
    enemy_faction = {"Legion"},
    ally_race = {"Goblin", "Draenei", "Blood Elf"},
    enemy_race = {"Demon", "Blood Elf"},
    ally_class = {"Hunter", "Mage", "Warlock"},
    enemy_class = {"Warlock", "Mage", "Rogue"}
})
Warcraft.create_quest({
    name = "Torghast",
    index = 55,
    combo_character = {"Zovaal", "Sylvanas Windrunner"},
    enemy_faction = {"Alliance", "Horde"},
    ally_race = {"Undead", "Human", "Orc"},
    enemy_race = {"Human", "Orc", "Night Elf", "Tauren"},
    ally_class = {"Death Knight", "Warlock", "Rogue"},
    enemy_class = {"Paladin", "Priest", "Shaman", "Warrior"}
})
Warcraft.create_quest({
    name = "Seat of the Primus",
    index = 56,
    combo_character = {"The Primus", "Draka", "Alexandros Mograine"},
    ally_faction = {"Alliance", "Horde"},
    ally_race = {"Undead", "Human", "Orc", "Tauren"},
    enemy_race = {"Undead", "Demon", "Human"},
    ally_class = {"Death Knight", "Warrior", "Rogue", "Warlock"},
    enemy_class = {"Paladin", "Priest", "Mage"}
})
Warcraft.create_quest({
    name = "Loamm",
    index = 57,
    combo_character = {"Wrathion", "Sabellian"},
    ally_faction = {"Alliance", "Horde"},
    ally_race = {"Dragon", "Human", "Orc"},
    enemy_race = {"Elemental", "Dragon", "Troll"},
    ally_class = {"Hunter", "Rogue", "Shaman"},
    enemy_class = {"Warrior", "Mage", "Warlock"}
})
Warcraft.create_quest({
    name = "Undermine",
    index = 58,
    combo_character = {"Trade Prince Gallywix", "Gazlowe", "Baron Revilgaz"},
    ally_faction = {"Horde"},
    enemy_faction = {"Alliance"},
    ally_race = {"Goblin", "Orc", "Troll", "Ogre"},
    enemy_race = {"Human", "Gnome", "Worgen"},
    ally_class = {"Rogue", "Hunter", "Warlock", "Mage"},
    enemy_class = {"Paladin", "Priest"}
})
Warcraft.create_quest({
    name = "Kezan",
    index = 59,
    combo_character = {"Trade Prince Gallywix"},
    ally_faction = {"Horde"},
    enemy_faction = {"Alliance"},
    ally_race = {"Goblin", "Orc"},
    enemy_race = {"Human", "Gnome", "Night Elf"},
    ally_class = {"Rogue", "Warlock", "Shaman"},
    enemy_class = {"Paladin", "Warrior", "Druid"}
})
Warcraft.create_quest({
    name = "Gilneas",
    index = 60,
    combo_character = {"Genn Greymane"},
    ally_faction = {"Alliance"},
    enemy_faction = {"Horde", "Scourge"},
    ally_race = {"Worgen", "Human", "Night Elf"},
    enemy_race = {"Undead", "Orc", "Goblin"},
    ally_class = {"Rogue", "Hunter", "Warrior", "Druid"},
    enemy_class = {"Warlock", "Death Knight", "Mage"}
})
sendDebugMessage("Azeroth Balatro Mod : Generating all Quests done!")