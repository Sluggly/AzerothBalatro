Warcraft = Warcraft or {}
Warcraft.Packs = {}

-- ============================================
-- FACTORY: Create a Standard + Jumbo + Mega pack trio
-- args:
--   name         : display name for the standard pack
--   index        : 1-based position in the packs atlas strip
--   cost         : base cost (standard)
--   weight       : base spawn weight (standard); 0 = never random
--   config       : { extra = N, choose = M } for the standard pack
--   loc_txt_lines: array of text lines shared by all three variants
--   create_card  : function(self, card, i) → card object
--   in_pool      : optional override; defaults to weight > 0
-- ============================================
function Warcraft.Packs.create_pack(args)
    assert(args.name,        "create_pack: 'name' is required")
    assert(args.index,       "create_pack: 'index' is required")
    assert(args.config,      "create_pack: 'config' is required")
    assert(args.create_card, "create_pack: 'create_card' is required")

    local std_atlas,  atlas_pos = Warcraft.Atlas.get_pos("packs",       args.index)
    local jumbo_atlas,_         = Warcraft.Atlas.get_pos("jumbo_packs",  args.index)
    local mega_atlas, _         = Warcraft.Atlas.get_pos("mega_packs",   args.index)

    local base_extra  = args.config.extra  or 3
    local base_choose = args.config.choose or 1
    local base_cost   = args.cost   or 4
    local base_weight = args.weight or 0

    local desc = args.loc_txt_lines or {
        "Choose {C:attention}#1#{} of up to",
        "{C:attention}#2#{} cards"
    }

    local function make_loc_vars(self, info_queue, card)
        return { vars = { card.config.center.config.choose,
                          card.config.center.config.extra } }
    end

    local function default_in_pool(self)
        return base_weight > 0
    end

    local in_pool_fn = args.in_pool or default_in_pool

    -- ---- Standard ----
    SMODS.Booster({
        key         = Warcraft.secure_key(args.name),
        name        = args.name,
        atlas       = std_atlas,
        pos         = atlas_pos,
        cost        = base_cost,
        weight      = base_weight,
        config      = { extra = base_extra, choose = base_choose },
        loc_txt     = { name = args.name, text = desc },
        loc_vars    = make_loc_vars,
        create_card = args.create_card,
        in_pool     = in_pool_fn,
    })

    -- ---- Jumbo ----
    SMODS.Booster({
        key         = Warcraft.secure_key("Jumbo " .. args.name),
        name        = "Jumbo " .. args.name,
        atlas       = jumbo_atlas,
        pos         = atlas_pos,
        cost        = base_cost + 2,
        weight      = math.max(0, base_weight - 0.2),
        config      = { extra = base_extra + 1, choose = base_choose },
        loc_txt     = { name = "Jumbo " .. args.name, text = desc },
        loc_vars    = make_loc_vars,
        create_card = args.create_card,
        in_pool     = in_pool_fn,
    })

    -- ---- Mega ----
    SMODS.Booster({
        key         = Warcraft.secure_key("Mega " .. args.name),
        name        = "Mega " .. args.name,
        atlas       = mega_atlas,
        pos         = atlas_pos,
        cost        = base_cost + 4,
        weight      = math.max(0, base_weight - 0.4),
        config      = { extra = base_extra + 2, choose = base_choose + 1 },
        loc_txt     = { name = "Mega " .. args.name, text = desc },
        loc_vars    = make_loc_vars,
        create_card = args.create_card,
        in_pool     = in_pool_fn,
    })
end
