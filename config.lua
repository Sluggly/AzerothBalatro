-- Load Config
warcraft_config = SMODS.current_mod.config
if not warcraft_config then
    warcraft_config = { remove_vanilla_jokers = false }
end

-- Config Tab
SMODS.current_mod.config_tab = function()
    return {
        n = G.UIT.ROOT,
        config = { align = "tm", padding = 0.1 },
        nodes = {
            {
                n = G.UIT.C,
                config = { align = "tm" },
                nodes = {
                    {
                        n = G.UIT.T,
                        config = { text = "Warcraft Settings", scale = 0.6, colour = G.C.UI.TEXT_LIGHT }
                    },
                    {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.1 },
                        nodes = {
                            create_toggle({
                                label = "Remove Vanilla Jokers",
                                ref_table = warcraft_config,
                                ref_value = "remove_vanilla_jokers"
                            })
                        }
                    }
                }
            }
        }
    }
end