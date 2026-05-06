--- File: C:\Users\User\AppData\Roaming\Balatro\Mods\AzerothBalatro\content\init_tags.lua ---

sendDebugMessage("Azeroth Balatro Mod : Generating all Tags...")

Warcraft.Tags.create_tag({
    name = "Hero's Tag",
    key = "faction_pack",
    index = 1,
    config = { type = 'immediate' },
    loc_txt = {
        name = "Hero's Tag",
        text = {
            "Gives a free",
            "{C:attention}#1#{} Joker Pack",
            "when in the {C:attention}Shop{}"
        }
    },
    loc_vars = function(self, info_queue, card)
        local target = (card and card.ability and card.ability.warcraft_filter and card.ability.warcraft_filter.target) or "Warcraft"
        return { vars = { target } }
    end,
    apply = function(self, tag, context)
        if context.type == 'immediate' then
            tag:yep('Pack!', G.C.PURPLE, function()
                
                -- QUEUE A CONDITION EVENT SO IT WAITS ITS TURN
                G.E_MANAGER:add_event(Event({
                    trigger = 'condition',
                    blocking = true,
                    func = function()
                        -- WAIT until we are safely idling in the shop
                        if G.STATE == G.STATES.SHOP then
                            
                            local pack = create_card('Booster', G.pack_cards, nil, nil, nil, nil, 'p_war_warcraft_faction_pack', 'quest_tag')
                            
                            -- Safely center the pack
                            if G.ROOM and G.ROOM.T then
                                pack.T.x = G.ROOM.T.w / 2
                                pack.T.y = G.ROOM.T.h / 2
                            end
                            
                            -- Hand off the filter memory from the Tag to the Pack
                            pack.ability.warcraft_filter = tag.ability and tag.ability.warcraft_filter
                            pack:start_materialize()
                            
                            -- Hide the shop UI
                            if G.shop then
                                G.shop.states.visible = false
                            end
                            
                            -- Open the pack
                            G.FUNCS.use_card({config = {ref_table = pack}})
                            
                            return true
                        end
                        return false
                    end
                }))
                return true
            end)
            tag.triggered = true
        end
    end
})

sendDebugMessage("Azeroth Balatro Mod : Generating all Tags done!")