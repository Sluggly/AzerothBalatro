Warcraft = Warcraft or {}
Warcraft.Stickers = {}

-- ============================================
-- LAYOUT CONFIGURATION
-- ============================================
Warcraft.Stickers.Layout = {
    { attr = "class",      corner = "tr", dir = "left",  shown_on = "both" },
    { attr = "faction",    corner = "tl", dir = "right", shown_on = "both" },
    { attr = "race",       corner = "tl", dir = "right", shown_on = "joker", offset_after = "faction" },
    { attr = "race",       corner = "tm", dir = "right", shown_on = "playing" },
    { attr = "damage",     corner = "bl", dir = "right", shown_on = "both" },
    { attr = "armor",      corner = "br", dir = "left",  shown_on = "both" },
    { attr = "profession", corner = "bm", dir = "right", shown_on = "joker" },
}

-- ============================================
-- HELPERS
-- ============================================
local function as_list(val)
    if not val then return {} end
    if type(val) == "table" then return val end
    return { val }
end

local function card_applicable(card, shown_on)
    if shown_on == "both" then return true end
    local set = card.ability and card.ability.set
    if shown_on == "joker" then return set == "Joker" end
    if shown_on == "playing" then
        return set == "Default" or set == "Enhanced"
    end
    return false
end

-- ============================================
-- SYNC UI ELEMENTS (stores sprites + offsets)
-- ============================================
function Warcraft.sync_ui_elements(card)
    if not (card.ability and type(card.ability.extra) == "table") then return end
    if not Warcraft.Stickers.Layout then return end  -- safety guard

    local ex = card.ability.extra

    -- Identify card type and grab our UI config
    local is_joker = card.ability.set == "Joker"
    local is_playing_card = card.ability.set == "Default" or card.ability.set == "Enhanced"
    local conf = SMODS.Mods and SMODS.Mods["Warcraft"] and SMODS.Mods["Warcraft"].config
    local ui_conf = conf and conf.ui_display or {}

    -- 1. Initialize Canvas Text SAFELY using Event Queue and Dynamic Refs
    if not card.war_canvas_initialized then
        card.war_canvas_initialized = true
        G.E_MANAGER:add_event(Event({
            func = function()
                local canvas_list = card.canvas_text or {}
                
                -- Level indicator (auto-updates when ex.level changes)
                if ex.level then
                    table.insert(canvas_list, SMODS.CanvasSprite({
                        ref_table = ex,
                        ref_value = "level",
                        text_colour = G.C.WHITE,
                        text_offset = {x = 10, y = 85},
                        text_width = 15, text_height = 15
                    }))
                end
                
                -- iLvl indicator (auto-updates when ilvl changes)
                if card.ability.wow_equipment and card.ability.wow_equipment.ilvl then
                    card.war_ilvl_initialized = true
                    table.insert(canvas_list, SMODS.CanvasSprite({
                        ref_table = card.ability.wow_equipment,
                        ref_value = "ilvl",
                        text_colour = G.C.GOLD,
                        text_offset = {x = 56, y = 85},
                        text_width = 15, text_height = 15
                    }))
                end
                
                if #canvas_list > 0 then
                    card.canvas_text = canvas_list
                end
                return true
            end
        }))
    end

    -- 2. Dynamically add the Equipment Canvas if it gets equipped later
    if card.war_canvas_initialized and card.ability.wow_equipment and not card.war_ilvl_initialized then
        card.war_ilvl_initialized = true
        G.E_MANAGER:add_event(Event({
            func = function()
                local canvas_list = card.canvas_text or {}
                table.insert(canvas_list, SMODS.CanvasSprite({
                    ref_table = card.ability.wow_equipment,
                    ref_value = "ilvl",
                    text_colour = G.C.GOLD,
                    text_offset = {x = 56, y = 85},
                    text_width = 15, text_height = 15
                }))
                card.canvas_text = canvas_list
                return true
            end
        }))
    end

    -- 3. Clean up old standard sprites
    if card.warcraft_icons then
        for _, icon in ipairs(card.warcraft_icons) do
            if icon.sprite and icon.sprite.remove then icon.sprite:remove() end
        end
    end

    local icons = {}
    local corner_counts = { tl = 0, tr = 0, bl = 0, br = 0, bm = 0, tm = 0 }

    local cw = G.CARD_W
    local ch = G.CARD_H
    local iw = cw * 0.25      -- smaller icons
    local ih = iw
    local pad = 0.05 * cw

    for _, layout in ipairs(Warcraft.Stickers.Layout) do
        if card_applicable(card, layout.shown_on) then
            
            -- Check the config to see if we should draw this sticker!
            local show_sticker = true
            if ui_conf[layout.attr] then
                if is_joker then
                    show_sticker = ui_conf[layout.attr].sticker_j
                elseif is_playing_card then
                    show_sticker = ui_conf[layout.attr].sticker_p
                end
            end

            if show_sticker then
                local values = as_list(ex[layout.attr])
                local pos_map = Warcraft.Constants.StickerPositions[layout.attr]
                local atlas_prefix = Warcraft.Constants.StickerAtlasMap[layout.attr]

                if pos_map and atlas_prefix then
                    for _, v in ipairs(values) do
                        local linear_index = pos_map[v]
                        if linear_index ~= nil then
                            local atlas_key, pos2d = Warcraft.Atlas.get_pos(atlas_prefix, linear_index + 1)
                            atlas_key = "war_" .. atlas_key
                            
                            local bx, by
                            if layout.corner == "tl" then
                                bx = pad
                                by = pad * 0.5    -- higher
                            elseif layout.corner == "tr" then
                                bx = cw - iw - pad
                                by = pad * 0.5
                            elseif layout.corner == "bl" then
                                bx = pad
                                by = ch - ih - pad
                            elseif layout.corner == "br" then
                                bx = cw - iw - pad
                                by = ch - ih - pad
                            elseif layout.corner == "bm" then
                                bx = (cw - iw) / 2
                                by = ch - ih - pad
                            elseif layout.corner == "tm" then
                                bx = (cw - iw) / 2
                                by = pad * 0.5
                            end

                            local step = iw * 0.45
                            if layout.dir == "right" then
                                bx = bx + corner_counts[layout.corner] * step
                            elseif layout.dir == "left" then
                                bx = bx - corner_counts[layout.corner] * step
                            end

                            local sprite = SMODS.create_sprite(0, 0, iw, ih, atlas_key, pos2d)
                            local ox = bx + iw/2 - cw/2
                            local oy = by + ih/2 - ch/2

                            table.insert(icons, {
                                sprite = sprite,
                                offset_x = ox,     -- now relative to card center
                                offset_y = oy,
                                half_w   = iw/2,   -- cached for the draw step
                                half_h   = ih/2,
                            })
                            corner_counts[layout.corner] = corner_counts[layout.corner] + 1
                        end
                    end
                end
            end
        end
    end

    -- Equipment sticker
    if card.ability.wow_equipment then
        local eq_key = card.ability.wow_equipment.key
        local eq_def = Warcraft.Equipment.items[eq_key]
        if eq_def then
            local atlas_key, pos2d = Warcraft.Atlas.get_pos("equipments", eq_def.index or 1)
            atlas_key = "war_" .. atlas_key
            local bx = cw - iw - pad
            local by = ch - ih - pad
            bx = bx - corner_counts["br"] * (iw * 0.45)

            local sprite = SMODS.create_sprite(0, 0, iw, ih, atlas_key, pos2d)
            local ox = bx + iw/2 - cw/2
            local oy = by + ih/2 - ch/2

            table.insert(icons, {
                sprite   = sprite,
                offset_x = ox,
                offset_y = oy,
                half_w   = iw/2,
                half_h   = ih/2,
            })
        end
    end

    card.warcraft_icons = icons
end

-- ============================================
-- DRAW STEP – positions sprites every frame
-- ============================================
SMODS.DrawStep({
    key = "war_stickers",
    order = 50,
    conditions = { facing = "front" },
    func = function(card, layer)
        if layer ~= "card" and layer ~= "both" then return end
        if not card.warcraft_icons then return end

        local cx = card.VT.x + card.VT.w/2   -- card's center in world coords
        local cy = card.VT.y + card.VT.h/2
        local angle = card.VT.r or 0
        local c, s = math.cos(angle), math.sin(angle)

        for _, icon in ipairs(card.warcraft_icons) do
            -- Rotate the offset around the card's center
            local rx = icon.offset_x * c - icon.offset_y * s
            local ry = icon.offset_x * s + icon.offset_y * c

            local nx = cx + rx - icon.half_w
            local ny = cy + ry - icon.half_h

            -- Write T (logical) AND VT (visual) so the sprite snaps without easing
            icon.sprite.T.x = nx
            icon.sprite.T.y = ny
            icon.sprite.T.r = angle

            if icon.sprite.VT then
                icon.sprite.VT.x = nx
                icon.sprite.VT.y = ny
                icon.sprite.VT.r = angle
            end

            icon.sprite:draw_shader('dissolve')
            icon.sprite:draw()
        end
    end
})