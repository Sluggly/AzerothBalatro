--- File: C:\Users\User\AppData\Roaming\Balatro\Mods\AzerothBalatro\functions\tags.lua ---

Warcraft = Warcraft or {}
Warcraft.Tags = Warcraft.Tags or {}

-- ============================================
-- FACTORY: Create a Custom Tag
-- ============================================
function Warcraft.Tags.create_tag(args)
    assert(args.name, "create_tag: 'name' is required")
    
    local key = args.key or Warcraft.secure_key(args.name)
    local atlas_key, atlas_pos
    local p_config = args.prefix_config or {}

    -- If an index is provided, use our custom Warcraft atlas
    if args.index then
        atlas_key, atlas_pos = Warcraft.Atlas.get_pos("tags", args.index)
    else
        -- Fallback to vanilla tags if no index is passed
        atlas_key = args.atlas or "tags"
        atlas_pos = args.pos or { x = 0, y = 0 }
        if not args.atlas then
            p_config.atlas = false
        end
    end

    SMODS.Tag({
        key = key,
        name = args.name,
        atlas = atlas_key,
        pos = atlas_pos,
        prefix_config = p_config,
        config = args.config or {},
        loc_txt = args.loc_txt or { name = args.name, text = { "Effect not found." } },
        loc_vars = args.loc_vars,
        apply = args.apply,
        in_pool = args.in_pool,
        min_ante = args.min_ante
    })
end