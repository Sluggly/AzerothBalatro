-- File: C:\Users\User\AppData\Roaming\Balatro\Mods\AzerothBalatro\config.lua

local function get_conf()
    return SMODS.Mods["Warcraft"].config
end

-- ==========================================
-- PREVIEW CARD GENERATORS
-- ==========================================
local function update_previews()
    -- Re-sync the preview cards safely
    if G.warcraft_config_joker_area and G.warcraft_config_joker_area.cards and G.warcraft_config_joker_area.cards[1] then
        Warcraft.sync_ui_elements(G.warcraft_config_joker_area.cards[1])
    end
    if G.warcraft_config_pc_area and G.warcraft_config_pc_area.cards and G.warcraft_config_pc_area.cards[1] then
        Warcraft.sync_ui_elements(G.warcraft_config_pc_area.cards[1])
    end
    
    -- Safely update active cards in-game ONLY if the user is actively in a run
    if G.jokers and G.jokers.cards then 
        for _, j in ipairs(G.jokers.cards) do Warcraft.sync_ui_elements(j) end 
    end
    if G.playing_cards then 
        for _, c in ipairs(G.playing_cards) do Warcraft.sync_ui_elements(c) end 
    end
end

local function init_joker_preview()
    -- Clean up old instance if we are swapping tabs
    if G.warcraft_config_joker_area then G.warcraft_config_joker_area:remove() end

    G.warcraft_config_joker_area = CardArea(
        G.ROOM.T.x, G.ROOM.T.y, 1.03 * G.CARD_W, 1.03 * G.CARD_H, 
        { card_limit = 1, type = 'title', highlight_limit = 0 }
    )
    
    local center = G.P_CENTERS['j_war_illidan_stormrage'] or G.P_CENTERS['j_joker']
    local card = Card(G.warcraft_config_joker_area.T.x, G.warcraft_config_joker_area.T.y, G.CARD_W, G.CARD_H, nil, center)
    
    -- Load dummy traits
    card.ability = card.ability or {}
    card.ability.extra = card.ability.extra or {}
    card.ability.extra.is_warcraft = true
    card.ability.extra.level = 10
    card.ability.extra.race = "Night Elf"
    card.ability.extra.class = "Demon Hunter"
    card.ability.extra.faction = "Alliance"
    card.ability.extra.damage = "Shadow"
    card.ability.extra.armor = "Leather"
    card.ability.extra.role = "Melee DPS"
    card.ability.extra.profession = "Blacksmith"
    card.ability.extra.weapon = "Glaives"
    
    G.warcraft_config_joker_area:emplace(card)
    Warcraft.sync_ui_elements(card)
    
    return G.warcraft_config_joker_area
end

local function init_pc_preview()
    -- Clean up old instance if we are swapping tabs
    if G.warcraft_config_pc_area then G.warcraft_config_pc_area:remove() end

    G.warcraft_config_pc_area = CardArea(
        G.ROOM.T.x, G.ROOM.T.y, 1.03 * G.CARD_W, 1.03 * G.CARD_H, 
        { card_limit = 1, type = 'title', highlight_limit = 0 }
    )
    
    local card = Card(G.warcraft_config_pc_area.T.x, G.warcraft_config_pc_area.T.y, G.CARD_W, G.CARD_H, G.P_CARDS.S_A, G.P_CENTERS.c_base)
    
    -- Load dummy traits
    card.ability = card.ability or {}
    card.ability.extra = card.ability.extra or {}
    card.ability.extra.is_warcraft = true
    card.ability.extra.level = 5
    card.ability.extra.race = "Human"
    card.ability.extra.class = "Paladin"
    card.ability.extra.faction = "Alliance"
    card.ability.extra.damage = "Holy"
    card.ability.extra.armor = "Plate"
    card.ability.extra.role = "Tank"
    card.ability.extra.profession = "Miner"
    card.ability.extra.weapon = "Hammer"
    
    G.warcraft_config_pc_area:emplace(card)
    Warcraft.sync_ui_elements(card)
    
    return G.warcraft_config_pc_area
end

-- ==========================================
-- HELPER FOR GENERATING THE UI MATRICES
-- ==========================================
local function create_toggle_col(title, ref_target, value_suffix)
    local conf = get_conf()
    local attrs = {"race", "class", "faction", "damage", "armor", "role", "profession", "weapon"}
    
    local rows = {
        { n = G.UIT.R, config = { align = "cm", padding = 0.1 }, nodes = {
            { n = G.UIT.T, config = { text = title, scale = 0.45, colour = G.C.GOLD } }
        }}
    }
    
    for _, attr in ipairs(attrs) do
        table.insert(rows, {
            n = G.UIT.R, config = { align = "cr", padding = 0.02 }, nodes = {
                create_toggle({
                    label = attr:gsub("^%l", string.upper),
                    ref_table = conf[ref_target][attr],
                    ref_value = value_suffix,
                    w = 2.5,
                    -- Trigger live update when clicked!
                    callback = function(val) update_previews() end
                })
            }
        })
    end
    return { n = G.UIT.C, config = { align = "ct", padding = 0.1 }, nodes = rows }
end

-- ==========================================
-- 1. MAIN CONFIG TAB ("General")
-- ==========================================
SMODS.current_mod.config_tab = function()
    local conf = get_conf()
    return {
        n = G.UIT.ROOT,
        config = { align = "cm", padding = 0.1 },
        nodes = {
            { n = G.UIT.R, config = { padding = 0.1, align = "cl" }, nodes = {
                create_toggle({ label = "Remove Vanilla Jokers", ref_table = conf, ref_value = "remove_vanilla_jokers", w = 4 })
            }},
            { n = G.UIT.R, config = { padding = 0.1, align = "cl" }, nodes = {
                create_toggle({ label = "Gen Random Attrs for Vanilla", ref_table = conf, ref_value = "gen_random_attrs_for_vanilla", w = 4 })
            }},
            { n = G.UIT.R, config = { padding = 0.2, align = "cl" }, nodes = {
                create_slider({ label = "Level Cap", ref_table = conf, ref_value = "level_cap", min = 10, max = 100, inc = 5, w = 4 })
            }}
        }
    }
end

-- ==========================================
-- 2. ADDITIONAL TOP-LEVEL TABS
-- ==========================================
SMODS.current_mod.extra_tabs = function()
    return {
        -- GAMEPLAY TAB
        {
            label = 'Gameplay',
            tab_definition_function = function()
                local conf = get_conf()
                local attrs = {"race", "class", "faction", "damage", "armor", "role", "profession", "weapon"}
                local col1_rows = {}
                local col2_rows = {}
                
                for i, attr in ipairs(attrs) do
                    local node = { n = G.UIT.R, config = { align = "cr", padding = 0.02 }, nodes = {
                        create_toggle({ label = attr:gsub("^%l", string.upper), ref_table = conf.pc_start, ref_value = attr, w = 2.5 })
                    }}
                    if i <= 4 then table.insert(col1_rows, node) else table.insert(col2_rows, node) end
                end

                return {
                    n = G.UIT.ROOT,
                    config = { align = "cm", padding = 0.1 },
                    nodes = {
                        { n = G.UIT.R, config = { align = "cm", padding = 0.1 }, nodes = {
                            { n = G.UIT.T, config = { text = "Playing Card Starting Traits", scale = 0.5, colour = G.C.UI.TEXT_LIGHT } }
                        }},
                        { n = G.UIT.R, config = { align = "cm", padding = 0.1 }, nodes = {
                            { n = G.UIT.C, config = { align = "ct", padding = 0.1 }, nodes = col1_rows },
                            { n = G.UIT.C, config = { align = "ct", padding = 0.1 }, nodes = col2_rows }
                        }}
                    }
                }
            end,
        },
        
        -- JOKER UI TAB
        {
            label = 'Joker UI',
            tab_definition_function = function()
                return {
                    n = G.UIT.ROOT,
                    config = { align = "cm", padding = 0.1 },
                    nodes = {
                        { n = G.UIT.R, config = { align = "cm" }, nodes = {
                            -- Left side: Toggles
                            { n = G.UIT.C, config = { align = "cm" }, nodes = {
                                { n = G.UIT.R, config = { align = "cm" }, nodes = {
                                    create_toggle_col("Joker Badges", "ui_display", "badge_j"),
                                    { n = G.UIT.B, config = { w = 0.5, h = 0.1 } },
                                    create_toggle_col("Joker Stickers", "ui_display", "sticker_j")
                                }}
                            }},
                            { n = G.UIT.B, config = { w = 1.0, h = 0.1 } }, -- Spacer
                            -- Right side: Live Preview
                            { n = G.UIT.C, config = { align = "cm" }, nodes = {
                                { n = G.UIT.O, config = { object = init_joker_preview() } }
                            }}
                        }}
                    }
                }
            end,
        },
        
        -- CARD UI TAB
        {
            label = 'Card UI',
            tab_definition_function = function()
                return {
                    n = G.UIT.ROOT,
                    config = { align = "cm", padding = 0.1 },
                    nodes = {
                        { n = G.UIT.R, config = { align = "cm" }, nodes = {
                            -- Left side: Toggles
                            { n = G.UIT.C, config = { align = "cm" }, nodes = {
                                { n = G.UIT.R, config = { align = "cm" }, nodes = {
                                    create_toggle_col("Card Badges", "ui_display", "badge_p"),
                                    { n = G.UIT.B, config = { w = 0.5, h = 0.1 } },
                                    create_toggle_col("Card Stickers", "ui_display", "sticker_p")
                                }}
                            }},
                            { n = G.UIT.B, config = { w = 1.0, h = 0.1 } }, -- Spacer
                            -- Right side: Live Preview
                            { n = G.UIT.C, config = { align = "cm" }, nodes = {
                                { n = G.UIT.O, config = { object = init_pc_preview() } }
                            }}
                        }}
                    }
                }
            end,
        }
    }
end

-- ==========================================
-- DEFAULT CONFIGURATION DATA
-- ==========================================
return {
    -- General
    remove_vanilla_jokers = true,
    gen_random_attrs_for_vanilla = true,

    -- Gameplay
    level_cap = 5,
    pc_start = {
        race = true, class = false, faction = false, damage = false,
        armor = false, role = false, profession = false, weapon = false
    },

    -- UI (j = Joker, p = Playing Card)
    ui_display = {
        race       = { badge_j = true, sticker_j = true, badge_p = true, sticker_p = true },
        class      = { badge_j = true, sticker_j = true, badge_p = true, sticker_p = true },
        faction    = { badge_j = true, sticker_j = true, badge_p = true, sticker_p = true },
        damage     = { badge_j = true, sticker_j = true, badge_p = true, sticker_p = true },
        armor      = { badge_j = true, sticker_j = true, badge_p = true, sticker_p = true },
        role       = { badge_j = true, sticker_j = true, badge_p = true, sticker_p = true },
        profession = { badge_j = true, sticker_j = true, badge_p = true, sticker_p = true },
        weapon     = { badge_j = true, sticker_j = true, badge_p = true, sticker_p = true }
    },
    
    debug_mode = true
}