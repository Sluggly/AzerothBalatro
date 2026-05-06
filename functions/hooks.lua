-- Spawn Enemy Joker at start of a Blind
local original_set_blind = Blind.set_blind
function Blind.set_blind(self, blind, reset, silent)
    original_set_blind(self, blind, reset, silent)

    if not blind then return end

    Warcraft.Enemies.remove_all()

    local b_type = "small"
    if self.name == "Big Blind" then b_type = "big"
    elseif self.boss then b_type = "boss" end

    Warcraft.Enemies.spawn_enemy(b_type)
end
-------------------------------------------

-- Remove Enemy Jokers and level up jokers at end of a Blind
local original_blind_defeat = Blind.defeat
function Blind:defeat(discard_cards)
    original_blind_defeat(self, discard_cards)
    if Warcraft.Enemies and Warcraft.Enemies.remove_all then
        Warcraft.Enemies.remove_all()
    end

    if G.jokers and G.jokers.cards then
        for _, card in ipairs(G.jokers.cards) do
            if card.ability and card.ability.extra and card.ability.extra.level then
                Warcraft.attempt_level_up(card)
            end
        end
    end
end

-- Tracking sold Jokers for Quests Conditions
local original_sell_card = Card.sell_card
function Card.sell_card(self)
    if self.ability and self.ability.extra then
        if Warcraft.Quests and Warcraft.Quests.on_joker_sold then
            Warcraft.Quests.on_joker_sold(self.ability.extra)
        end
    end
    original_sell_card(self)
end

-- Enemy Jokers and specific Jokers debuff checks
local base_debuff = Card.set_debuff
function Card:set_debuff(should_debuff)
    base_debuff(self, should_debuff)
    
    if G.jokers and G.jokers.cards then
        -- Restrict general enemy debuffs strictly to playing cards
        local is_playing_card = self.ability and (self.ability.set == 'Default' or self.ability.set == 'Enhanced')

        -- Existing Enemy Boss check
        if is_playing_card then
            for _, j in ipairs(G.jokers.cards) do
                local ex = j.ability.extra
                if ex and type(ex) == "table" and ex.blind_type == "boss" and ex.target_cat and ex.target_val and ex.target_cat ~= "hand_type" then
                    if Warcraft.Enemies.is_card_match(self, ex.target_cat, ex.target_val) then
                        self.debuff = true
                    end
                end
            end
        end

        -- Daelin Proudmoore Check (Debuffs Horde Jokers)
        if Warcraft.has_active_joker("Daelin Proudmoore") then
            if self.ability and self.ability.set == 'Joker' then
                if Warcraft.is_faction(self,"Horde") then
                    self.debuff = true
                end
            end
        end

        -- Sha of Fear: debuffs all Spades playing cards
        if self.config and self.config.center and self.config.center.set ~= "Joker" then
            if self:is_suit("Spades") then
                for _, j in ipairs(G.jokers.cards) do
                    if j.ability and j.ability.name == "Sha of Fear" and not j.debuff then
                        self.debuff = true
                        break
                    end
                end
            end
        end
    end
end

-- Hide Negative visuals from Enemy Jokers
local original_card_draw = Card.draw
function Card:draw(layer)
    
    local is_enemy = false
    if self.ability and type(self.ability.extra) == "table" and self.ability.extra.blind_type then
        is_enemy = true
    end
    
    local hidden_negative = false
    
    -- If it's an enemy and it's currently negative, temporarily remove it and draw
    if is_enemy and self.edition and self.edition.negative then
        self.edition.negative = false
        hidden_negative = true
    end
    original_card_draw(self, layer)
    if hidden_negative then
        self.edition.negative = true
    end
end

-- Alexstrasza check for face cards
local old_is_face = Card.is_face
function Card:is_face(from_boss)
    if G.GAME.velen_active then 
        return true 
    end
    if G.GAME and G.GAME.jokers then
        for _, v in ipairs(G.GAME.jokers.cards) do
            if v.ability.name == 'Alexstrasza' and not v.debuff then
                if self:is_suit('Hearts') then
                    return true
                end
            end
        end
    end
    return old_is_face(self, from_boss)
end

-- Balnazzar check (Jacks are considered Wild Cards and cannot be debuffed)
local old_get_id = Card.get_id
function Card:get_id()
    if self.ability.effect == 'Wild Card' then
        return old_get_id(self)
    end
    
    if G.GAME and G.GAME.jokers then
        local balnazzar_active = false
        for _, v in ipairs(G.GAME.jokers.cards) do
            if v.ability.name == 'Balnazzar' and not v.debuff then
                balnazzar_active = true
                break
            end
        end
        
        if balnazzar_active and old_get_id(self) == 11 then
        end
    end
    return old_get_id(self)
end

-- Balnazzar check (Jacks are considered Wild Cards and cannot be debuffed)
local old_is_suit = Card.is_suit
function Card:is_suit(suit, bypass_debuff, flush_calc)
    if old_is_suit(self, suit, bypass_debuff, flush_calc) then return true end
    if G.GAME and G.GAME.jokers then
        for _, v in ipairs(G.GAME.jokers.cards) do
            if v.ability.name == 'Balnazzar' and not v.debuff then
                if self.base.id == 11 then
                    return true
                end
            end
        end
    end

    return false
end

-- Permanent added stats evaluation
local old_eval_card = eval_card
function eval_card(card, context)
    local ret, ret_post = old_eval_card(card, context)
    
    local is_scoring_context = context.joker_main or context.main_scoring or (context.individual and context.cardarea == G.play)
    
    if is_scoring_context and card.ability and card.ability.perma_mult and card.ability.perma_mult > 0 then
        if ret and ret.mult then
            ret.mult = ret.mult + card.ability.perma_mult
        elseif ret and not ret.mult then
            ret.mult = card.ability.perma_mult
        else
            ret = {mult = card.ability.perma_mult}
        end
    end
    
    return ret, ret_post
end

-- Track total jokers sold across the run for retroactive effects
local old_eval_card = eval_card
eval_card = function(card, context)
    if context.selling_card and card.config and card.config.center and card.config.center.set == "Joker" then
        G.GAME.warcraft_jokers_sold = (G.GAME.warcraft_jokers_sold or 0) + 1
    end
    return old_eval_card(card, context)
end

-- Mal'Ganis cancel Enemy Joker effect
function Warcraft.Enemies.try_malganis_absorb(card)
    if not G.jokers then return false end
    for _, j in ipairs(G.jokers.cards) do
        if j.ability.name == "Mal'Ganis" then
            local chips_gain = math.floor(Warcraft.get_scaled_gain(j, j.ability.extra.chips_gain, 0, j.ability.extra.chips_gain_per_ilvl))
            local mult_gain = math.floor(Warcraft.get_scaled_gain(j, j.ability.extra.mult_gain, j.ability.extra.mult_gain_per_level, 0))
            j.ability.extra.chips = j.ability.extra.chips + chips_gain
            j.ability.extra.mult = j.ability.extra.mult + mult_gain
            ease_dollars(j.ability.extra.gold_gain)
            card_eval_status_text(j, 'extra', nil, nil, nil, {
                message = "Absorbed!",
                colour = G.C.PURPLE
            })
            return true
        end
    end
    return false
end

-- Aviana effect to make all joker cost $1, Thaurissan check to reduce cost, Loatheb pack cost increase
local old_set_cost = Card.set_cost
function Card.set_cost(self)
    old_set_cost(self)
    if self.config and self.config.center then
        local center_set = self.config.center.set

        -- Joker cost modifiers
        if center_set == "Joker" and G.jokers then
            -- Check for Aviana first (sets absolute cost, takes priority)
            for _, j in ipairs(G.jokers.cards) do
                if j.ability and j.ability.name == "Aviana" and not j.debuff then
                    local effective_cost = math.max(0, math.floor(Warcraft.get_scaled_gain(j, j.ability.extra.joker_cost, j.ability.extra.joker_cost_per_level, j.ability.extra.joker_cost_per_ilvl)))
                    self.cost = effective_cost
                    self.sell_cost = effective_cost
                    return
                end
            end
            -- Check for Thaurissan (reduces cost, applied after base cost)
            for _, j in ipairs(G.jokers.cards) do
                if j.ability and j.ability.name == "Emperor Dagran Thaurissan" and not j.debuff then
                    local reduction = math.floor(Warcraft.get_scaled_gain(j, j.ability.extra.cost_reduction, j.ability.extra.cost_reduction_per_level, j.ability.extra.cost_reduction_per_ilvl))
                    self.cost = math.max(1, self.cost - reduction)
                    return
                end
            end
        end

        -- Booster pack cost modifier
        if center_set == "Booster" and G.jokers then
            for _, j in ipairs(G.jokers.cards) do
                if j.ability and j.ability.name == "Loatheb" and not j.debuff then
                    self.cost = self.cost + j.ability.extra.pack_cost_increase
                    return
                end
            end
        end
    end
end

-- Override pack cost to make all Arcana packs free while Kalecgos is active
local old_set_cost_kalecgos = Card.set_cost
function Card.set_cost(self)
    old_set_cost_kalecgos(self)
    if self.config and self.config.center and self.config.center.set == "Booster" then
        if self.config.center.key and self.config.center.key:find("arcana") then
            if G.jokers then
                for _, j in ipairs(G.jokers.cards) do
                    if j.ability.name == "Kalecgos" then
                        self.cost = 0
                        return
                    end
                end
            end
        end
    end
end

-- Inject an extra Mega Arcana pack into the shop when Kalecgos is active
local old_game_store = Game.store
Game.store = function(self, ...)
    local result = old_game_store(self, ...)

    if not G.jokers then return result end

    local kalecgos = nil
    for _, j in ipairs(G.jokers.cards) do
        if j.ability.name == "Kalecgos" then
            kalecgos = j
            break
        end
    end

    if not kalecgos then return result end
    if not G.shop_booster then return result end

    -- Check we haven't already injected this visit
    for _, c in ipairs(G.shop_booster.cards) do
        if c.kalecgos_injected then return result end
    end

    local pack_count = math.floor(Warcraft.get_scaled_gain(kalecgos, kalecgos.ability.extra.packs, kalecgos.ability.extra.packs_per_level, kalecgos.ability.extra.packs_per_ilvl))

    for i = 1, pack_count do
        local pack = create_card('Booster', G.shop_booster, nil, nil, nil, nil, 'p_arcana_mega_1', 'kalecgos')
        pack.kalecgos_injected = true
        pack:set_cost()
        G.shop_booster:emplace(pack)
    end

    return result
end

-- Mount Pack injection when Mount Training voucher is active NEED TO MERGE WITH HOOK ABOVE
local old_game_store_mounts = Game.store
Game.store = function(self, ...)
    local result = old_game_store_mounts(self, ...)

    if not (G.GAME and G.GAME.war_mount_voucher_active) then return result end
    if not G.shop_booster then return result end

    -- Avoid injecting twice in the same shop visit
    for _, c in ipairs(G.shop_booster.cards) do
        if c.war_mount_injected then return result end
    end

    local pack = create_card('Booster', G.shop_booster, nil, nil, nil, nil,
                             'p_war_mount_pack', 'mount_voucher')
    pack.war_mount_injected = true
    pack:set_cost()
    G.shop_booster:emplace(pack)

    return result
end

-- Global cleanup for all temporary playing cards at end of blind
local old_end_round = end_round
end_round = function(...)
    -- Clean up any temporary cards that survived the blind
    if G.playing_cards then
        for i = #G.playing_cards, 1, -1 do
            local c = G.playing_cards[i]
            if c.is_temporary then
                c:remove_from_deck()
                c:start_dissolve()
            end
        end
    end
    -- Also check play area in case scoring was interrupted
    if G.play then
        for i = #G.play.cards, 1, -1 do
            local c = G.play.cards[i]
            if c.is_temporary then
                c:remove_from_deck()
                G.play:remove_card(c)
                c:remove()
            end
        end
    end
    return old_end_round(...)
end

-- Track total cards discarded across the run for retroactive effects
local old_eval_card_discard = eval_card
eval_card = function(card, context)
    if context.discard then
        G.GAME.warcraft_cards_discarded = (G.GAME.warcraft_cards_discarded or 0) + 1
    end
    return old_eval_card_discard(card, context)
end

-- Hook into deck drawing for Loken's effect to always put sealed cards on top
local old_draw_card = Game.draw_card
if old_draw_card then
    Game.draw_card = function(self, ...)
        -- Check if Loken is active
        if G.jokers then
            for _, j in ipairs(G.jokers.cards) do
                if j.ability.name == "Loken" then
                    -- Sort deck: sealed cards float to the top (end of array = top of deck)
                    if G.deck and G.deck.cards then
                        table.sort(G.deck.cards, function(a, b)
                            local a_sealed = a.seal and true or false
                            local b_sealed = b.seal and true or false
                            if a_sealed ~= b_sealed then
                                return not a_sealed
                            end
                            return false
                        end)
                    end
                    break
                end
            end
        end
        return old_draw_card(self, ...)
    end
end

-- Elune Effect Track Night Elf jokers added and sold/destroyed for retroactive effects
local old_eval_card_elune = eval_card
eval_card = function(card, context)
    if context and context.selling_card then
        local sold = context.card
        if sold and sold.config and sold.config.center and sold.config.center.set == "Joker" then
            if Warcraft.is_race(sold, "Night Elf") then
                G.GAME.warcraft_night_elf_sold = (G.GAME.warcraft_night_elf_sold or 0) + 1
            end
        end
    end
    return old_eval_card_elune(card, context)
end

-- Restore shop after opening pack
local old_game_update = Game.update
Game.update = function(self, dt)
    old_game_update(self, dt)
    -- Restore shop visibility when pack is closed and we return to shop
    if G.STATE == G.STATES.SHOP and G.shop and not G.shop.states.visible then
        G.shop.states.visible = true
    end
end

-- Sha of Doubt each second update
local old_game_update = Game.update
function Game.update(self, dt)
    old_game_update(self, dt)

    -- Only tick during an active blind
    if G.STATE == G.STATES.HAND_PLAYED or
       G.STATE == G.STATES.DRAW_TO_HAND or
       G.STATE == G.STATES.SELECTING_HAND or
       G.STATE == G.STATES.DISCARDING_HAND then
        if G.jokers and G.jokers.cards then
            for _, j in ipairs(G.jokers.cards) do
                if j.ability and j.ability.name == "Sha of Doubt" and not j.debuff then
                    j.ability.extra.timer = (j.ability.extra.timer or 0) + dt
                    -- Fire every full second
                    if j.ability.extra.timer >= 1 then
                        j.ability.extra.timer = j.ability.extra.timer - 1
                        local effective_decay = math.max(0.1, Warcraft.get_scaled_gain(j, j.ability.extra.decay_rate, 0, j.ability.extra.decay_rate_per_ilvl))
                        j.ability.extra.current_mult = j.ability.extra.current_mult - effective_decay
                    end
                end
            end
        end
    end
end

-- Fandral Staghelm additional choice in packs
local old_open_booster = G.FUNCS.use_card
G.FUNCS.use_card = function(e, ...)
    local card = e.config and e.config.ref_table
    if card and card.ability and card.ability.set == 'Booster' then
        if G.jokers then
            for _, j in ipairs(G.jokers.cards) do
                if j.ability and j.ability.name == "Fandral Staghelm" and not j.debuff then
                    local bonus = math.floor(Warcraft.get_scaled_gain(j, j.ability.extra.bonus_choose, j.ability.extra.bonus_choose_per_level, j.ability.extra.bonus_choose_per_ilvl))
                    card.ability.choose = (card.ability.choose or card.config.center.config.choose or 1) + bonus
                end
            end
        end
    end
    return old_open_booster(e, ...)
end

-- Clear negative jokers from packs for Harth Stonebrew
local old_close_booster = G.FUNCS.close_booster
G.FUNCS.close_booster = function(e, ...)
    G.GAME.harth_negative_pack = false
    return old_close_booster(e, ...)
end

-- ==========================================
-- UI SYNC HOOKS (Trigger drawing on load/create)
-- ==========================================
local old_set_ability = Card.set_ability
function Card:set_ability(center, initial, delay_sprites)
    old_set_ability(self, center, initial, delay_sprites)
    -- Trigger if it's a Warcraft Joker, OR if it's a playing card that has a Warcraft race/class
    if self.ability and type(self.ability.extra) == "table" and (self.ability.extra.is_warcraft or self.ability.extra.class or self.ability.extra.race) then
        Warcraft.sync_ui_elements(self)
    end
end

local old_card_load = Card.load
function Card:load(cardTable, other_card)
    old_card_load(self, cardTable, other_card)
    if self.ability and type(self.ability.extra) == "table" and (self.ability.extra.is_warcraft or self.ability.extra.class or self.ability.extra.race) then
        Warcraft.sync_ui_elements(self)
    end
end

local old_card_update = Card.update
function Card:update(dt)
    old_card_update(self, dt)
    
    -- MAGIC FIX: This updates the sprites every frame so they grab the 
    -- card's current X/Y coordinates instead of staying stuck at 0,0!
    if self.warcraft_icons then
        for _, icon in ipairs(self.warcraft_icons) do
            if icon.sprite and icon.sprite.update then
                icon.sprite:update(dt)
            end
        end
    end
    
    -- FIXED: Ensure self.ability.extra is a table! (Vanilla Vouchers sometimes make it a number)
    if self.ability and type(self.ability.extra) == "table" and self.ability.extra.war_stickers_dirty then
        if Warcraft.sync_ui_elements then
            Warcraft.sync_ui_elements(self)
        end
        self.ability.extra.war_stickers_dirty = false
    end
end

-- ==========================================
-- PLAYING CARD GENERATION & PRESERVATION
-- ==========================================

local old_set_base = Card.set_base
function Card:set_base(card_base, initial, manual_sprites)
    -- Safely pass ALL arguments back to the original vanilla function!
    old_set_base(self, card_base, initial, manual_sprites)
    
    -- Check if it's a playing card (it has a suit and value assigned)
    if self.base and self.base.suit and self.base.value then
        Warcraft.assign_playing_card_traits(self)
    end
end

-- Hook set_ability to PRESERVE our Warcraft stats when a Tarot card is used!
-- (Normally, becoming a Glass/Steel card wipes card.ability.extra)
local old_set_ability = Card.set_ability
function Card:set_ability(center, initial, delay_sprites)
    -- 1. Back up our custom stats before SMODS overwrites them
    local war_traits = {}
    if self.ability and type(self.ability.extra) == "table" and self.ability.extra.is_warcraft then
        for _, attr in ipairs({"race", "class", "faction", "damage", "armor", "role", "profession", "level", "is_warcraft"}) do
            war_traits[attr] = self.ability.extra[attr]
        end
    end
    
    -- 2. Call the base function (which applies the enhancement)
    old_set_ability(self, center, initial, delay_sprites)
    
    -- 3. Restore the backed-up stats and re-sync the UI
    if next(war_traits) then
        self.ability.extra = self.ability.extra or {}
        for k, v in pairs(war_traits) do
            self.ability.extra[k] = v
        end
        Warcraft.sync_ui_elements(self)
    end
end

-- Same for loading save files, ensuring stickers render when booting the game
local old_card_load = Card.load
function Card:load(cardTable, other_card)
    old_card_load(self, cardTable, other_card)
    if self.ability and type(self.ability.extra) == "table" and self.ability.extra.is_warcraft then
        Warcraft.sync_ui_elements(self)
    end
end

-- ==========================================
-- PLAYING CARD TOOLTIP INJECTION
-- ==========================================

-- Hook Card:hover to force tooltips to appear for Base Playing Cards
-- Vanilla Balatro completely aborts tooltip generation for playing cards without enhancements/seals/editions.
local old_hover = Card.hover
function Card:hover()
    old_hover(self)
    
    -- If vanilla aborted and didn't create a popup, but we are a Warcraft playing card:
    if not self.config.h_popup and self.ability and self.ability.set == 'Default' then
        if self.ability.extra and type(self.ability.extra) == 'table' and self.ability.extra.is_warcraft then
            -- Forcibly generate the popup!
            self.config.h_popup_config = {align = 'cl', offset = {x=-0.1, y=0}, major = self}
            
            -- SAFE CALL: The card object (self) MUST be the 9th argument in vanilla Balatro!
            self.config.h_popup = generate_card_ui(self.config.center, nil, nil, 'Default', nil, nil, nil, nil, self)
        end
    end
end

-- ============================================
-- GLOBAL TAG HOOKS
-- ============================================
-- We store the old calculate function in case you define it in another file later
local old_calculate = SMODS.current_mod.calculate
SMODS.current_mod.calculate = function(self, context)
    local ret = nil
    if old_calculate then ret = old_calculate(self, context) end

    -- 1. Fire specific tags automatically when you walk into the shop
    if context.starting_shop then
        if G.GAME.tags then
            for _, t in ipairs(G.GAME.tags) do
                if t.key == 'tag_war_faction_pack' then
                    t:apply_to_run({type = 'immediate'})
                end
            end
        end
    end

    -- 2. Catch playing cards the moment they are generated inside Standard Packs
    if context.modify_booster_card then
        local c = context.card
        if c and c.ability and (c.ability.set == "Default" or c.ability.set == "Enhanced") then
            -- Apply our 80% chance logic!
            if Warcraft.apply_booster_card_traits then
                Warcraft.apply_booster_card_traits(c)
            end
        end
    end
    
    return ret
end

-- ==========================================
-- MULTI-BOX TOOLTIP INJECTION
-- ==========================================
local old_desc_from_rows = desc_from_rows
function _G.desc_from_rows(desc_nodes, empty, maxw)
    if type(desc_nodes) ~= 'table' then
        return old_desc_from_rows(desc_nodes, empty, maxw)
    end

    -- SCENARIO 1: SMODS Center (Jokers, Consumables)
    -- Separator is at the top level of desc_nodes
    local has_top_sep = false
    for _, node in ipairs(desc_nodes) do
        if type(node) == 'table' and node.config and node.config.warcraft_box_separator then
            has_top_sep = true
            break
        end
    end

    if has_top_sep then
        local chunks = {}
        local current_chunk = {}
        for _, node in ipairs(desc_nodes) do
            if type(node) == 'table' and node.config and node.config.warcraft_box_separator then
                if #current_chunk > 0 then
                    table.insert(chunks, current_chunk)
                    current_chunk = {}
                end
            else
                table.insert(current_chunk, node)
            end
        end
        if #current_chunk > 0 then table.insert(chunks, current_chunk) end

        local stacked_boxes = {}
        for i, chunk in ipairs(chunks) do
            table.insert(stacked_boxes, old_desc_from_rows(chunk, empty, maxw))
            if i < #chunks then
                table.insert(stacked_boxes, { n = G.UIT.B, config = { h = 0.08 } }) -- Gap between boxes
            end
        end
        return {
            n = G.UIT.R, config = { align = "cm", padding = 0, filler = true },
            nodes = { { n = G.UIT.C, config = { align = "cm" }, nodes = stacked_boxes } }
        }
    end

    -- SCENARIO 2: Vanilla Playing Card
    -- Separator is nested inside the right column (desc_nodes[2].nodes)
    local has_nested_sep = false
    if desc_nodes[2] and type(desc_nodes[2].nodes) == 'table' then
        for _, node in ipairs(desc_nodes[2].nodes) do
            if type(node) == 'table' and node.config and node.config.warcraft_box_separator then
                has_nested_sep = true
                break
            end
        end
    end

    if has_nested_sep then
        local info_nodes = desc_nodes[2].nodes
        local chunks = {}
        local current_chunk = {}
        
        for _, node in ipairs(info_nodes) do
            if type(node) == 'table' and node.config and node.config.warcraft_box_separator then
                if #current_chunk > 0 then
                    table.insert(chunks, current_chunk)
                    current_chunk = {}
                end
            else
                table.insert(current_chunk, node)
            end
        end
        if #current_chunk > 0 then table.insert(chunks, current_chunk) end

        local stacked_boxes = {}
        local info_col_config = desc_nodes[2].config or {align="cm"}
        
        -- Box 1: Left column (Header) + Right column (Chunk 1)
        local box1_content = {
            desc_nodes[1],
            { n = G.UIT.C, config = info_col_config, nodes = chunks[1] }
        }
        table.insert(stacked_boxes, old_desc_from_rows(box1_content, empty, maxw))
        
        -- Box 2+: Just a centered column
        for i = 2, #chunks do
            if #chunks[i] > 0 then
                local boxN_content = {
                    { n = G.UIT.C, config = info_col_config, nodes = chunks[i] }
                }
                table.insert(stacked_boxes, { n = G.UIT.B, config = { h = 0.08 } })
                table.insert(stacked_boxes, old_desc_from_rows(boxN_content, empty, maxw))
            end
        end
        
        return {
            n = G.UIT.R, config = { align = "cm", padding = 0, filler = true },
            nodes = { { n = G.UIT.C, config = { align = "cm" }, nodes = stacked_boxes } }
        }
    end

    -- If no separator found in either place, fallback to vanilla single box
    return old_desc_from_rows(desc_nodes, empty, maxw)
end