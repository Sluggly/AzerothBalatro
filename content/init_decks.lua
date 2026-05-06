sendDebugMessage("Azeroth Balatro Mod : Generating all Decks...")

Warcraft.Decks.create_deck({
    name = "Orc vs Human",
    index = 1,
    loc_txt = {
        name = "Orc vs Human Deck",
        text = {
            "All {V:1}Spades{} and {V:2}Clubs{} are",
            "{C:attention}Alliance Human Warriors{}",
            "All {V:3}Hearts{} and {V:4}Diamonds{} are",
            "{C:attention}Horde Orc Warriors{}",
            " ",
            "Only {C:attention}Horde{} and {C:attention}Alliance{}",
            "Jokers appear in the run."
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                "Spades", "Clubs", "Hearts", "Diamonds",
                colours = {
                    G.C.SUITS.Spades, G.C.SUITS.Clubs, 
                    G.C.SUITS.Hearts, G.C.SUITS.Diamonds
                }
            }
        }
    end,
    apply = function(self, back)
        -- Flag the modifier so our hooks know this deck's rules are active globally!
        G.GAME.modifiers.war_orc_vs_human = true
    end
})

Warcraft.Decks.create_deck({
    name = "Reign of Chaos",
    index = 2,
    loc_txt = {
        name = "Reign of Chaos Deck",
        text = {
            "{V:1}Spades{} are {C:dark_edition}Undead{} (DK or Rogue)",
            "{V:2}Clubs{} are {C:attention}Human{} (Warrior or Mage)",
            "{V:3}Hearts{} are {C:green}Night Elf{} (Druid or Hunter)",
            "{V:4}Diamonds{} are {C:red}Orc{} (Warlock or Shaman)."
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                "Spades", "Clubs", "Hearts", "Diamonds",
                colours = { G.C.SUITS.Spades, G.C.SUITS.Clubs, G.C.SUITS.Hearts, G.C.SUITS.Diamonds }
            }
        }
    end,
    apply = function(self, back)
        G.GAME.modifiers.war_reign_of_chaos = true
    end
})

sendDebugMessage("Azeroth Balatro Mod : Generating all Decks done!")