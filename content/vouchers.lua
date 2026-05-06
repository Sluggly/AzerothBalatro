sendDebugMessage("Azeroth Balatro Mod : Generating all Vouchers...")
-- ============================================
-- MOUNT TRAINING VOUCHER
-- Activates Mount Pack in the shop
-- ============================================
SMODS.Voucher({
    key  = "war_mount_training",
    name = "Mount Training",
    atlas = "war_vouchers_1",
    pos   = { x = 0, y = 0 },
    cost  = 10,

    loc_txt = {
        name = "Mount Training",
        text = {
            "Mounts can now appear",
            "in the {C:attention}Shop{}.",
            "A free {C:attention}Mount Pack{}",
            "appears each visit.",
        },
    },

    apply = function(self, card)
        G.GAME.war_mount_voucher_active = true
    end,

    in_pool = function(self)
        return not (G.GAME and G.GAME.war_mount_voucher_active)
    end,
})
sendDebugMessage("Azeroth Balatro Mod : Generating all Vouchers done!")