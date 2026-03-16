Warcraft = Warcraft or {}
Warcraft.Atlas = {}

-- CONFIGURATION
local LIMIT_PER_PAGE = 160 -- 16x10 grid
local ATLAS_WIDTH = 10     -- 10 columns
local JOKER_ATLAS_NUMBER = 2
local EQUIPMENTS_ATLAS_NUMBER = 1
local ENEMY_ATLAS_NUMBER = 1
local QUEST_ATLAS_NUMBER = 1

-- Function used to register all atlas .png files
function Warcraft.Atlas.register_all()
    for i = 1, JOKER_ATLAS_NUMBER do
        SMODS.Atlas({ 
            key = "jokers_" .. i, 
            path = "jokers_" .. i .. ".png", 
            px = 71, py = 95 
        })
    end

    for i = 1, EQUIPMENTS_ATLAS_NUMBER do
        SMODS.Atlas({ 
            key = "equipments_" .. i, 
            path = "equipments_" .. i .. ".png", 
            px = 71, py = 95 
        })
    end

    for i = 1, ENEMY_ATLAS_NUMBER do
        SMODS.Atlas({ 
            key = "enemies_" .. i, 
            path = "enemies_" .. i .. ".png", 
            px = 71, py = 95 
        })
    end

    for i = 1, QUEST_ATLAS_NUMBER do
        SMODS.Atlas({ 
            key = "quests_" .. i, 
            path = "quests_" .. i .. ".png", 
            px = 71, py = 95 
        })
    end
end

-- Function used to convert Index to Atlas Key & X/Y Position
-- @param type_prefix: "jokers", "equipments", "enemies", "quests"
-- @param index: The numeric index of the card
function Warcraft.Atlas.get_pos(type_prefix, index)
    local page = 1
    local local_index = 0

    page = math.ceil(index / LIMIT_PER_PAGE)
    local_index = (index - 1) % LIMIT_PER_PAGE

    local final_key = type_prefix .. "_" .. page
    
    -- Calculate Grid X/Y
    local pos_x = local_index % ATLAS_WIDTH
    local pos_y = math.floor(local_index / ATLAS_WIDTH)

    return final_key, { x = pos_x, y = pos_y }
end