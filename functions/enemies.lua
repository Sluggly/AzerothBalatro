Warcraft = Warcraft or {}
Warcraft.Enemies = Warcraft.Enemies or {}

-- Global arrays containing joker keys for each blind type
Warcraft.Enemies.Pools = {
    small = {},
    big = {},
    boss = {}
}

Warcraft.Enemies.HandContains = {
    ["High Card"]      = {"High Card", "Pair", "Two Pair", "Three of a Kind", "Straight", "Flush", "Full House", "Four of a Kind", "Straight Flush", "Royal Flush", "Five of a Kind", "Flush House", "Flush Five"},
    ["Pair"]           = {"Pair", "Two Pair", "Full House", "Flush House"},
    ["Two Pair"]       = {"Two Pair"},
    ["Three of a Kind"]= {"Three of a Kind", "Full House", "Five of a Kind", "Flush House", "Flush Five"},
    ["Straight"]       = {"Straight", "Straight Flush", "Royal Flush"},
    ["Flush"]          = {"Flush", "Straight Flush", "Royal Flush", "Flush House", "Flush Five"},
    ["Full House"]     = {"Full House", "Flush House"},
    ["Four of a Kind"] = {"Four of a Kind", "Five of a Kind", "Flush House", "Flush Five"},
    ["Straight Flush"] = {"Straight Flush", "Royal Flush"},
    ["Royal Flush"]    = {"Royal Flush"},
    ["Five of a Kind"] = {"Five of a Kind", "Flush Five"},
    ["Flush House"]    = {"Flush House"},
    ["Flush Five"]     = {"Flush Five"},
}

-- List of catagories that can be used to kill enemies
Warcraft.Enemies.KillPools = {
    rank = { pool = {"2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen", "King", "Ace"}, min_ante = -10 },
    suit = { pool = {"Hearts", "Clubs", "Diamonds", "Spades"}, min_ante = -10 },
    hand_type = { pool = {"High Card", "Pair", "Two Pair", "Three of a Kind", "Straight", "Flush", "Full House", "Four of a Kind", "Straight Flush"}, min_ante = -10 },
    enhancement = { pool = {"base_enhancement", "m_bonus", "m_mult", "m_wild", "m_glass", "m_steel", "m_stone", "m_gold", "m_lucky"}, min_ante = 3 },
    seal = { pool = {"no_seal", "Red", "Blue", "Gold", "Purple"}, min_ante = 4 },
    edition = { pool = {"base_edition", "foil", "holo", "polychrome"}, min_ante = 5 }
}

-- Function used to generate a Kill Condition on an Enemy
function Warcraft.Enemies.generate_kill_req(exclude_cat, exclude_val)
    local current_ante = G.GAME.round_resets.ante
    local seed = "enemy_kill_" .. (G.GAME and G.GAME.round or "init")
    
    local valid_cats = {}
    for cat_name, data in pairs(Warcraft.Enemies.KillPools) do
        if current_ante >= data.min_ante then
            table.insert(valid_cats, cat_name)
        end
    end
    if #valid_cats == 0 then valid_cats = {"rank"} end
    
    local chosen_cat = pseudorandom_element(valid_cats, pseudoseed(seed .. "_cat"))
    
    -- Build the value pool, excluding the penalty combination
    local value_pool = {}
    for _, v in ipairs(Warcraft.Enemies.KillPools[chosen_cat].pool) do
        if not (chosen_cat == exclude_cat and v == exclude_val) then
            table.insert(value_pool, v)
        end
    end
    
    -- If filtering emptied the pool (e.g. category only had one value),
    -- fall back to a different category entirely
    if #value_pool == 0 then
        local fallback_pool = {}
        for _, v in ipairs(Warcraft.Enemies.KillPools[chosen_cat].pool) do
            table.insert(fallback_pool, v)
        end
        -- Pick a different category
        local alt_cats = {}
        for cat_name, data in pairs(Warcraft.Enemies.KillPools) do
            if cat_name ~= chosen_cat and current_ante >= data.min_ante then
                table.insert(alt_cats, cat_name)
            end
        end
        if #alt_cats > 0 then
            chosen_cat = pseudorandom_element(alt_cats, pseudoseed(seed .. "_fallback_cat"))
            value_pool = Warcraft.Enemies.KillPools[chosen_cat].pool
        else
            value_pool = fallback_pool -- Last resort: same category, ignore exclusion
        end
    end
    
    local chosen_val = pseudorandom_element(value_pool, pseudoseed(seed .. "_val"))
    
    return { category = chosen_cat, value = chosen_val }
end

-- Function to convert Kill Condition variable to text
function Warcraft.Enemies.get_req_text(req)
    if not req then return "Unknown" end
    
    if req.category == "seal" and req.value ~= "no_seal" then
        return req.value .. " Seal"
    end
    
    local text_map = {
        m_bonus = "Bonus Card", m_mult = "Mult Card", m_wild = "Wild Card", m_glass = "Glass Card",
        m_steel = "Steel Card", m_stone = "Stone Card", m_gold = "Gold Card", m_lucky = "Lucky Card",
        base_edition = "Base Edition", base_enhancement = "No Enhancement", no_seal = "No Seal",
        foil = "Foil", holo = "Holographic", polychrome = "Polychrome"
    }
    
    return text_map[req.value] or req.value
end

-- Check if card matches the category and required value
function Warcraft.Enemies.is_card_match(card, category, value)
    if not card or not category or not value then return false end
    
    if category == "rank" and card.base.value == value then return true end
    if category == "suit" and card:is_suit(value) then return true end
    
    if category == "edition" then
        if value == "base_edition" and not card.edition then return true end
        if card.edition and card.edition[value] then return true end
    end
    
    if category == "seal" then
        if value == "no_seal" and not card.seal then return true end
        if card.seal == value then return true end
    end
    
    if category == "enhancement" then
        if value == "base_enhancement" and card.config.center == G.P_CENTERS.c_base then return true end
        if card.config.center.key == value then return true end
    end
    
    return false
end

-- Check if card or played hand fulfills Kill Condition
function Warcraft.Enemies.check_kill_condition(req, cards, poker_hands)
    if not req then return false end

    -- Handle Hand Type
    if req.category == "hand_type" then
        local satisfying_hands = Warcraft.Enemies.HandContains[req.value] or {req.value}
        for _, h_name in ipairs(satisfying_hands) do
            if poker_hands[h_name] and next(poker_hands[h_name]) then
                return true
            end
        end
        return false
    end

    -- Handle Card-specific checks
    if cards then
        for _, card in ipairs(cards) do
            if Warcraft.Enemies.is_card_match(card, req.category, req.value) then
                return true
            end
        end
    end

    return false
end

-- Calculate function used by ALL Enemy jokers
function Warcraft.Enemies.calculate(self, card, context)
    local ex = card.ability.extra

    if ex and ex.is_killed then return end

    local b_type = ex.blind_type or "small"
    local penalty = ex.penalty or (b_type == "boss" and 3 or (b_type == "big" and 2 or 1))

    -- =====================================
    -- KILL LOGIC, must be called before the penalty logic
    -- =====================================
    local try_kill = false
    if ex.kill_req and ex.kill_req.category == "hand_type" then
        if context.joker_main then try_kill = true end
    else
        if b_type == "small" and (context.discard or context.before) then try_kill = true end
        if b_type == "big" and context.before and not context.discard then try_kill = true end
        if b_type == "boss" and context.joker_main then try_kill = true end
    end

    if try_kill then
        local check_cards = context.full_hand
        if b_type == "boss" then check_cards = context.scoring_hand end

        local poker_hands = context.poker_hands
        if not poker_hands and check_cards then
            poker_hands = evaluate_poker_hand(check_cards)
        end

        if Warcraft.Enemies.check_kill_condition(ex.kill_req, check_cards, poker_hands) then
            ex.is_killed = true
            G.GAME.warcraft_kills_this_hand = (G.GAME.warcraft_kills_this_hand or 0) + 1
            G.E_MANAGER:add_event(Event({ func = function() card:start_dissolve(); return true end }))
            return { message = (b_type == "boss") and "Boss Defeated!" or "Killed!", colour = G.C.RED }
        end
    end

    -- =====================================
    -- PENALTY LOGIC (Either Hand Type or Specific Card Counting)
    -- =====================================
    if context.joker_main then

        -- Spawned by Alarm-o-bot, no effect
        if card.ability.extra.alarmobot_spawned then return end

        -- Mal'Ganis effect to cancel penalty
        if Warcraft.Enemies.try_malganis_absorb(card) then
            return { message = "Blocked!", colour = G.C.PURPLE }
        end
        
        -- Hand Type Check
        if ex.target_cat == "hand_type" then
            local contains_hand = false
            
            if b_type == "small" then
                -- Check if it's contained in the SCORING hand specifically
                local evaluated_hands = evaluate_poker_hand(context.scoring_hand)
                if evaluated_hands[ex.target_val] and next(evaluated_hands[ex.target_val]) then
                    contains_hand = true
                end
            else
                -- Check if it's contained in the PLAYED hand
                if context.poker_hands and context.poker_hands[ex.target_val] and next(context.poker_hands[ex.target_val]) then
                    contains_hand = true
                end
            end
            
            if contains_hand then
                ease_dollars(-penalty)
                
                local ret = {
                    mult_mod = -penalty,
                    chip_mod = -penalty,
                    message = "Hand Curse!",
                    colour = G.C.RED
                }
                
                -- Boss Blind sets Xmult to 0, completely wiping out the current Mult
                if b_type == "boss" then
                    ret.Xmult_mod = 0
                end
                
                return ret
            end

        -- Specific Card Check Counting
        else
            local count = 0
            
            local function count_zone(card_list)
                local c = 0
                if card_list then
                    for _, v in ipairs(card_list) do
                        if Warcraft.Enemies.is_card_match(v, ex.target_cat, ex.target_val) then c = c + 1 end
                    end
                end
                return c
            end
            
            -- Small Blind: Only counts the Played Hand
            count = count + count_zone(context.full_hand)
            
            -- Big Blind & Boss Blind: Adds the Held Hand
            if b_type == "big" or b_type == "boss" then
                count = count + count_zone(G.hand and G.hand.cards)
            end

            -- Boss Blind: Adds the Deck (Everywhere)
            if b_type == "boss" then 
                count = count + count_zone(G.deck and G.deck.cards) 
            end

            -- Apply the calculated penalty
            if count > 0 then
                ease_dollars(-penalty * count)
                return {
                    mult_mod = -(penalty * count),
                    chip_mod = -(penalty * count),
                    message = "Curse!", 
                    colour = G.C.RED
                }
            end
        end
    end
end

-- FACTORY: Create an Enemy Joker
function Warcraft.create_enemy(args)
    local atlas_key, atlas_pos = Warcraft.Atlas.get_pos("enemies", args.index or 1, false)

    local rarity = args.rarity or 3

    local generated_key = args.key or Warcraft.secure_key(args.name)
    local full_key = "j_war_" .. generated_key

    if rarity == 1 then table.insert(Warcraft.Enemies.Pools.small, full_key)
    elseif rarity == 2 then table.insert(Warcraft.Enemies.Pools.big, full_key)
    elseif rarity == 3 then table.insert(Warcraft.Enemies.Pools.boss, full_key) end

    -- =====================================
    -- AUTO-INJECT PENALTY AND BLIND TYPE
    -- =====================================
    args.config = args.config or {}
    args.config.extra = args.config.extra or {}
    
    if not args.config.extra.blind_type then
        if rarity == 1 then args.config.extra.blind_type = "small"
        elseif rarity == 2 then args.config.extra.blind_type = "big"
        elseif rarity == 3 then args.config.extra.blind_type = "boss" end
    end

    -- =====================================
    -- AUTO-GENERATE TEXT AND VARIABLES
    -- =====================================
    local b_type = args.config and args.config.extra and args.config.extra.blind_type or "small"
    local target_cat = args.config and args.config.extra and args.config.extra.target_cat or ""

    local auto_loc_text = args.loc_text
    if not auto_loc_text then
        if target_cat == "hand_type" then
            if b_type == "small" then
                auto_loc_text = {
                    "Lose {C:money}$#1#{}, {C:mult}-#1#{} Mult, and {C:chips}-#1#{} Chips",
                    "if scoring hand contains a {C:attention}#3#{}.",
                    " ",
                    "{C:red}Kill Condition:{}",
                    "Discard or Play a {C:attention}#2#{}"
                }
            elseif b_type == "big" then
                auto_loc_text = {
                    "Lose {C:money}$#1#{}, {C:mult}-#1#{} Mult, and {C:chips}-#1#{} Chips",
                    "if played hand contains a {C:attention}#3#{}.",
                    " ",
                    "{C:red}Kill Condition:{}",
                    "{C:attention}Play{} a {C:attention}#2#{}"
                }
            elseif b_type == "boss" then
                auto_loc_text = {
                    "Lose {C:money}$#1#{}, {C:mult}-#1#{} Mult, and {C:chips}-#1#{} Chips",
                    "if played hand contains a {C:attention}#3#{}.",
                    " ",
                    "{C:red}Kill Condition:{}",
                    "{C:attention}Score{} a {C:attention}#2#{}"
                }
            end
        else
            if b_type == "small" then
                auto_loc_text = {
                    "Lose {C:money}$#1#{}, {C:mult}-#1#{} Mult, and {C:chips}-#1#{} Chips",
                    "per {C:attention}#3#{} in played hand.",
                    " ",
                    "{C:red}Kill Condition:{}",
                    "Discard or Play a {C:attention}#2#{}"
                }
            elseif b_type == "big" then
                auto_loc_text = {
                    "Lose {C:money}$#1#{}, {C:mult}-#1#{} Mult, and {C:chips}-#1#{} Chips",
                    "per {C:attention}#3#{} in played or held hand.",
                    " ",
                    "{C:red}Kill Condition:{}",
                    "{C:attention}Play{} a {C:attention}#2#{}"
                }
            elseif b_type == "boss" then
                auto_loc_text = {
                    "Lose {C:money}$#1#{}, {C:mult}-#1#{} Mult, and {C:chips}-#1#{} Chips",
                    "per {C:attention}#3#{} in played hand, held hand, or deck.",
                    "All {C:attention}#3#{} cards are debuffed.",
                    " ",
                    "{C:red}Kill Condition:{}",
                    "{C:attention}Score{} a {C:attention}#2#{}"
                }
            end
        end
    end

    local auto_loc_vars = args.loc_vars or function(self, info_queue, card)
        local ex = card.ability.extra
        
        -- Store the variables so we can pass them to either text block
        local req_text = Warcraft.Enemies.get_req_text(ex.kill_req)
        local vars = { args.rarity, req_text, ex.target_name }
        
        -- If it was spawned by Alarm-o-Bot, override the description text but KEEP the vars!
        if ex and ex.alarmobot_spawned then
            return { key = 'alarmobot_safe', set = 'Other', vars = vars }
        end
        
        return { vars = vars }
    end

    SMODS.Joker {
        key = args.key or generated_key,
        name = args.name,
        atlas = atlas_key,
        pos = atlas_pos,
        rarity = rarity,
        cost = 0,
        
        in_pool = function(self) 
            return false
        end,
        discovered = true,
        
        eternal_compat = true,
        perishable_compat = false,
        blueprint_compat = false,
        
        config = args.config or {},
        loc_txt = {
            name = args.name,
            text = auto_loc_text
        },
        
        loc_vars = auto_loc_vars,
        calculate = args.calculate or Warcraft.Enemies.calculate,
        
        set_badges = function(self, card, badges)
            badges[#badges+1] = create_badge("Enemy", G.C.RED, G.C.BLACK, 1.2)
        end
    }
end

-- Function used to spawn an enemy at the start of a blind
function Warcraft.Enemies.spawn_enemy(blind_type)
    if not G.jokers then return end

    local pool = Warcraft.Enemies.Pools[blind_type]
    if not pool or #pool == 0 then return end
    
    -- Filter the pool based on current Ante
    local current_ante = G.GAME.round_resets.ante
    local valid_pool = {}
    
    for _, key in ipairs(pool) do
        local center = G.P_CENTERS[key]
        local min = (center and center.config.extra and center.config.extra.min_ante) or 1
        if current_ante >= min then
            table.insert(valid_pool, key)
        end
    end

    if #valid_pool == 0 then return end
    
    -- Pick from the VALIDATED pool
    local key_to_spawn = pseudorandom_element(valid_pool, pseudoseed("spawn_enemy_" .. G.GAME.round))
    
    local enemy = create_card('Joker', G.jokers, nil, nil, nil, nil, key_to_spawn)
    
    -- Make it an unsellable, pinned, negative
    enemy:set_edition({negative = true}, true, true)
    enemy:set_eternal(true)
    enemy.pinned = true
    enemy.sell_cost = 0
    enemy.ability.extinct = true 

    -- Generate and attach its specific kill requirement
    enemy.ability.extra.kill_req = Warcraft.Enemies.generate_kill_req(enemy.ability.extra.target_cat, enemy.ability.extra.target_val)
    enemy.ability.extra.blind_type = blind_type

    enemy:add_to_deck()
    G.jokers:emplace(enemy)
    enemy:start_materialize()
end

-- Function used to remove all Enemy Jokers currently spawned
function Warcraft.Enemies.remove_all()
    if not G.jokers then return end
    for i = #G.jokers.cards, 1, -1 do
        local card = G.jokers.cards[i]
        if card.ability and card.ability.extra and card.ability.extra.blind_type then
            card:start_dissolve()
        end
    end
end