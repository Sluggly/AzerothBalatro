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
        -- Existing Enemy Boss check
        for _, j in ipairs(G.jokers.cards) do
            local ex = j.ability.extra
            if ex and type(ex) == "table" and ex.blind_type == "boss" and ex.target_cat and ex.target_val and ex.target_cat ~= "hand_type" then
                if Warcraft.Enemies.is_card_match(self, ex.target_cat, ex.target_val) then
                    self.debuff = true
                end
            end
        end

        -- Daelin Proudmoore Check (Debuffs Horde Jokers)
        if self.ability and self.ability.set == 'Joker' then
            local my_faction = self.ability.extra and self.ability.extra.faction
            local is_horde = false
            
            if type(my_faction) == "table" then
                for _, f in ipairs(my_faction) do 
                    if f == "Horde" then is_horde = true; break end 
                end
            elseif my_faction == "Horde" then
                is_horde = true
            end

            if is_horde then
                for _, j in ipairs(G.jokers.cards) do
                    if j.ability.name == "Daelin Proudmoore" and not j.debuff then
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
    
    if card.ability and card.ability.perma_mult and card.ability.perma_mult > 0 then
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
            local chips_gain = j.ability.extra.chips_gain
            local mult_gain = j.ability.extra.mult_gain
            local gold_gain = j.ability.extra.gold_gain
            j.ability.extra.chips = j.ability.extra.chips + chips_gain
            j.ability.extra.mult = j.ability.extra.mult + mult_gain
            ease_dollars(gold_gain)
            card_eval_status_text(j, 'extra', nil, nil, nil, {
                message = "Absorbed!",
                colour = G.C.PURPLE
            })
            return true
        end
    end
    return false
end

-- Aviana effect to make all joker cost $1
local old_set_cost = Card.set_cost
function Card.set_cost(self)
    old_set_cost(self)
    if self.config and self.config.center and self.config.center.set == "Joker" then
        if G.jokers then
            for _, j in ipairs(G.jokers.cards) do
                if j.ability and j.ability.name == "Aviana" then
                    self.cost = 1
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

    local has_kalecgos = false
    for _, j in ipairs(G.jokers.cards) do
        if j.ability.name == "Kalecgos" then
            has_kalecgos = true
            break
        end
    end

    if not has_kalecgos then return result end
    if not G.shop_booster then return result end

    -- Check we haven't already injected this visit
    for _, c in ipairs(G.shop_booster.cards) do
        if c.kalecgos_injected then return result end
    end

    local pack = create_card('Booster', G.shop_booster, nil, nil, nil, nil, 'p_arcana_mega_1', 'kalecgos')
    pack.kalecgos_injected = true
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
                c:start_dissolve({remove_as_card = true})
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