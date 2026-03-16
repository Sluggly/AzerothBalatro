SMODS.Back {
    key = "test_deck",
    name = "Tester Deck",
    pos = { x = 0, y = 0 }, 
    
    loc_txt = {
        name = "Tester Deck",
        text = {
            "Start with {C:attention}Illidan{}",
            "and {C:attention}Thunderfury{}",
            "{C:red}For Testing Only{}"
        }
    },

    apply = function(self)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                
                SMODS.add_card({ key = 'j_war_' .. Warcraft.secure_key("Al'Akir the Windlord") })

                if G.P_CENTERS['c_war_thunderfury'] then
                    SMODS.add_card({ key = 'c_war_thunderfury' })
                else
                    sendDebugMessage("Warcraft Error: c_war_thunderfury does not exist!")
                end

                return true
            end
        }))
    end
}