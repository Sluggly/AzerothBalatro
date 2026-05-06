sendDebugMessage("Azeroth Balatro Mod : Generating all Packs...")

-- ============================================
-- QUEST PACK
-- ============================================
Warcraft.Packs.create_pack({
    name   = "Quest Pack",
    index  = 1,
    cost   = 6,
    weight = 1.2,
    config = { extra = 5, choose = 1 },
    loc_txt_lines = {
        "Choose {C:attention}#1#{} of up to",
        "{C:attention}#2#{} Quest cards"
    },
    create_card = function(self, card, i)
        return create_card("Quest", G.pack_cards, nil, nil, true, true, nil, "quest_pack")
    end
})

-- ============================================
-- EQUIPMENT PACK
-- ============================================
Warcraft.Packs.create_pack({
    name   = "Equipment Pack",
    index  = 2,
    cost   = 4,
    weight = 1.2,
    config = { extra = 3, choose = 1 },
    loc_txt_lines = {
        "Choose {C:attention}#1#{} of up to",
        "{C:attention}#2#{} Equipment cards"
    },
    create_card = function(self, card, i)
        return create_card("Equipment", G.pack_cards, nil, nil, true, true, nil, "equip_pack")
    end
})

-- ============================================
-- MOUNT PACK
-- ============================================
Warcraft.Packs.create_pack({
    name   = "Mount Pack",
    index  = 3,
    cost   = 5,
    weight = 1.2,
    config = { extra = 3, choose = 1 },
    loc_txt_lines = {
        "Choose {C:attention}#1#{} of up to",
        "{C:attention}#2#{} Mounts"
    },
    create_card = function(self, card, i)
        return create_card("Mount", G.pack_cards, nil, nil, nil, nil, nil, "mount_pack")
    end
})

-- ============================================
-- Spell PACK
-- ============================================
Warcraft.Packs.create_pack({
    name   = "Spell Pack",
    index  = 4,
    cost   = 5,
    weight = 1.2,
    config = { extra = 3, choose = 1 },
    loc_txt_lines = {
        "Choose {C:attention}#1#{} of up to",
        "{C:attention}#2#{} Spells"
    },
    create_card = function(self, card, i)
        return create_card("Spell", G.pack_cards, nil, nil, nil, nil, nil, "spell_pack")
    end
})

sendDebugMessage("Azeroth Balatro Mod : Generating all Packs done!")