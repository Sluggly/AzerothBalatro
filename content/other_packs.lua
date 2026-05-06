sendDebugMessage("Azeroth Balatro Mod : Generating special Packs...")

-- ============================================
-- WARCRAFT FACTION PACK (Quest tag reward)
-- Single version — no jumbo/mega variants
-- ============================================
SMODS.Booster({
    key    = "warcraft_faction_pack",
    name   = "Warcraft Joker Pack",
    atlas  = "war_packs_1",
    pos    = { x = 4, y = 0 },
    cost   = 0,
    weight = 0,
    config = { extra = 3, choose = 1 },
    loc_txt = {
        name = "Warcraft Joker Pack",
        text = {
            "Choose {C:attention}#1#{} of up to",
            "{C:attention}#2#{} Jokers"
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.config.center.config.choose,
                          card.config.center.config.extra } }
    end,
    create_card = function(self, card, i)
        local filter       = (card.ability and card.ability.warcraft_filter)
                          or Warcraft.pending_faction_pack_filter
                          or {}
        local attr_key     = filter.attr_key
        local target       = filter.target
        local already_shown = filter.already_shown or {}

        local valid_centers = {}
        for k, v in pairs(G.P_CENTERS) do
            if v.set == "Joker"
            and v.config and v.config.extra
            and type(v.config.extra) == "table"
            and not already_shown[k] then
                local val  = v.config.extra[attr_key]
                local list = type(val) == "table" and val or (val and { val } or {})
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
            already_shown[chosen_key] = true
            filter.already_shown = already_shown
            return create_card("Joker", G.pack_cards, nil, nil, nil, nil, chosen_key, "warcraft_pack")
        end

        return create_card("Joker", G.pack_cards, nil, nil, nil, nil, nil, "warcraft_pack")
    end,
    in_pool = function(self) return false end,
})

-- ============================================
-- HARTH'S TAVERN PACK (any Warcraft Joker)
-- Single version — no jumbo/mega variants
-- ============================================
SMODS.Booster({
    key    = "warcraft_tavern_pack",
    name   = "Tavern Joker Pack",
    atlas  = "war_packs_1",
    pos    = { x = 5, y = 0 },
    cost   = 0,
    weight = 0,
    config = { extra = 3, choose = 1 },
    loc_txt = {
        name = "Tavern Joker Pack",
        text = {
            "Choose {C:attention}#1#{} of up to",
            "{C:attention}#2#{} Warcraft Jokers"
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.config.center.config.choose,
                          card.config.center.config.extra } }
    end,
    create_card = function(self, card, i)
        local already_shown = (card.ability and card.ability.tavern_shown) or {}

        local valid_centers = {}
        for k, v in pairs(G.P_CENTERS) do
            if v.set == "Joker"
            and v.config and v.config.extra
            and type(v.config.extra) == "table"
            and v.config.extra.is_warcraft
            and not v.config.extra.is_other
            and not already_shown[k] then
                table.insert(valid_centers, k)
            end
        end

        if #valid_centers > 0 then
            local chosen_key = pseudorandom_element(
                valid_centers,
                pseudoseed("wtp_" .. i .. "_" .. G.GAME.round)
            )
            already_shown[chosen_key] = true
            if card.ability then card.ability.tavern_shown = already_shown end
            local new_joker = create_card("Joker", G.pack_cards, nil, nil, nil, nil,
                                          chosen_key, "warcraft_tavern")
            if G.GAME.harth_negative_pack then
                new_joker:set_edition({ negative = true }, true)
            end
            return new_joker
        end

        -- Fallback: ignore already_shown
        local fallback = {}
        for k, v in pairs(G.P_CENTERS) do
            if v.set == "Joker"
            and v.config and v.config.extra
            and type(v.config.extra) == "table"
            and v.config.extra.is_warcraft
            and not v.config.extra.is_other then
                table.insert(fallback, k)
            end
        end

        if #fallback > 0 then
            local chosen_key = pseudorandom_element(
                fallback,
                pseudoseed("wtp_fb_" .. i .. "_" .. G.GAME.round)
            )
            local new_joker = create_card("Joker", G.pack_cards, nil, nil, nil, nil,
                                          chosen_key, "warcraft_tavern")
            if G.GAME.harth_negative_pack then
                new_joker:set_edition({ negative = true }, true)
            end
            return new_joker
        end

        return create_card("Joker", G.pack_cards, nil, nil, nil, nil, nil, "warcraft_tavern")
    end,
    in_pool = function(self) return false end,
})

sendDebugMessage("Azeroth Balatro Mod : Generating special Packs done!")