sendDebugMessage("Azeroth Balatro Mod : Generating all Atlases...")
Warcraft = Warcraft or {}
Warcraft.Atlas = {}

-- CONFIGURATION
local LIMIT_PER_PAGE = 160 -- 16x10 grid
local ATLAS_WIDTH = 10     -- 10 columns

local ATLAS_DEFINITIONS = {
    -- Jokers
    { key = "jokers",        count = 3, px = 71, py = 95 },
    { key = "enemies",       count = 1, px = 71, py = 95 },
    { key = "other_jokers",  count = 1, px = 71, py = 95 },
    -- Consumables
    { key = "equipments",    count = 1, px = 71, py = 95 },
    { key = "quests",        count = 1, px = 71, py = 95 },
    { key = "mounts",        count = 1, px = 71, py = 95 },
    { key = "spells",        count = 1, px = 71, py = 95 },
    -- Tags, Decks, Pack, Vouchers
    { key = "tags",          count = 1, px = 32, py = 32 },
    { key = "decks",          count = 1, px = 69, py = 93 },
    { key = "vouchers",          count = 1, px = 32, py = 32 },
    { key = "packs",          count = 1, px = 57, py = 93 },
    { key = "jumbo_packs",          count = 1, px = 57, py = 93 },
    { key = "mega_packs",          count = 1, px = 57, py = 93 },
    -- Stickers
    { key = "races",         count = 1, px = 64, py = 64 },
    { key = "factions",         count = 1, px = 64, py = 64 },
    { key = "classes",         count = 1, px = 64, py = 64 },
    { key = "weapons",         count = 1, px = 32, py = 32 },
    { key = "damages",         count = 1, px = 64, py = 64 },
    { key = "armors",         count = 1, px = 64, py = 64 },
    { key = "roles",         count = 1, px = 16, py = 16 },
    { key = "professions",         count = 1, px = 64, py = 64 }
}

-- Function used to register all atlas .png files
function Warcraft.Atlas.register_all()
    for _, atlas in ipairs(ATLAS_DEFINITIONS) do
        for i = 1, atlas.count do
            SMODS.Atlas({ 
                key = atlas.key .. "_" .. i, 
                path = atlas.key .. "_" .. i .. ".png", 
                px = atlas.px, 
                py = atlas.py 
            })
        end
    end
end

-- Function used to convert Index to Atlas Key & X/Y Position
-- @param type_prefix: The key defined in ATLAS_DEFINITIONS (e.g., "jokers")
-- @param index: The 1-based index of the specific card
function Warcraft.Atlas.get_pos(type_prefix, index)
    local page = math.ceil(index / LIMIT_PER_PAGE)
    local local_index = (index - 1) % LIMIT_PER_PAGE

    local final_key = type_prefix .. "_" .. page
    
    return final_key, { 
        x = local_index % ATLAS_WIDTH, 
        y = math.floor(local_index / ATLAS_WIDTH) 
    }
end

Warcraft.Atlas.register_all()
sendDebugMessage("Azeroth Balatro Mod : Generating all Atlases done!")