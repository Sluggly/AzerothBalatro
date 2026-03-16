SMODS.Atlas({
    key = "booster_warcraft",
    path = "booster_warcraft.png",
    px = 57,
    py = 93
})

-- Quest Pack
SMODS.Booster({
    key = "quest_pack_jumbo",
    name = "Jumbo Quest Pack",
    atlas = "booster_warcraft",
    pos = { x = 0, y = 0 },
    cost = 6,
    weight = 1.2,
    
    config = { extra = 5, choose = 1 },
    
    loc_txt = {
        name = "Jumbo Quest Pack",
        text = {
            "Choose {C:attention}#1#{} of up to",
            "{C:attention}#2#{} Quest cards"
        }
    },
    
    loc_vars = function(self, info_queue, card)
        return { vars = { card.config.center.config.choose, card.config.center.config.extra } }
    end,
    
    create_card = function(self, card)
        return create_card("Quest", G.pack_cards, nil, nil, true, true, nil, "quest_pack")
    end
})

-- Equipment Pack
SMODS.Booster({
    key = "equipment_pack",
    name = "Equipment Pack",
    atlas = "booster_warcraft",
    pos = { x = 1, y = 0 },
    cost = 4,
    weight = 1.2,
    
    config = { extra = 3, choose = 1 },
    
    loc_txt = {
        name = "Equipment Pack",
        text = {
            "Choose {C:attention}#1#{} of up to",
            "{C:attention}#2#{} Equipment cards"
        }
    },
    
    loc_vars = function(self, info_queue, card)
        return { vars = { card.config.center.config.choose, card.config.center.config.extra } }
    end,
    
    create_card = function(self, card)
        return create_card("Equipment", G.pack_cards, nil, nil, true, true, nil, "equip_pack")
    end
})

-- Reward Packs
SMODS.Booster({
    key = "warcraft_faction_pack",
    name = "Warcraft Joker Pack",
    cost = 0,
    weight = 0, -- never appears in shop naturally
    size = 3,
    config = { extra = 1 },
    atlas = "booster_warcraft",
    pos = { x = 0, y = 0 },
    loc_txt = {
        name = "Warcraft Pack",
        text = { "Choose a {C:attention}Joker{}", "from the pack" }
    },
    create_card = function(self, card, i)
        -- Filter key stored on the booster card
        local attr_key = card.ability.extra.attr_key
        local target = card.ability.extra.target
        local valid_centers = {}
        for k, v in pairs(G.P_CENTERS) do
            if v.set == "Joker" and v.config and v.config.extra then
                local val = v.config.extra[attr_key]
                local list = type(val) == "table" and val or (val and {val} or {})
                for _, entry in ipairs(list) do
                    if entry == target then
                        table.insert(valid_centers, k)
                        break
                    end
                end
            end
        end
        if #valid_centers > 0 then
            local chosen_key = pseudorandom_element(valid_centers, pseudoseed("wfp_" .. i))
            return create_card("Joker", G.pack_cards, nil, nil, nil, nil, chosen_key, "warcraft_pack")
        end
        -- Fallback to random joker if no match found
        return create_card("Joker", G.pack_cards, nil, nil, nil, nil, nil, "warcraft_pack")
    end
})