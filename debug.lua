local conf = SMODS.current_mod.config
if not conf.debug_mode then return end

local game_init = Game.init_game_object
function Game:init_game_object()
    local game = game_init(self)
    game.shop.joker_max = 6

    return game
end

-- Make Rerolls Free
local calculate_reroll_cost_ref = G.FUNCS.calculate_reroll_cost
G.FUNCS.calculate_reroll_cost = function(silent)
    G.GAME.current_round.reroll_cost = 0
    calculate_reroll_cost_ref(silent)
    G.GAME.current_round.reroll_cost = 0
end

local game_start_run_ref = Game.start_run
function Game:start_run(args)
    game_start_run_ref(self, args)
    
    G.E_MANAGER:add_event(Event({
        func = function()
            G.GAME.dollars = 9999
            SMODS.change_booster_limit(10) 
            G.GAME.current_round.reroll_cost = 0
            return true
        end
    }))
end