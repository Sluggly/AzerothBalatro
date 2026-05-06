Warcraft = Warcraft or {}
Warcraft.Decks = {}

-- ============================================
-- FACTORY: Create a Deck
-- ============================================
function Warcraft.Decks.create_deck(args)
    assert(args.name, "create_deck: 'name' is required")
    
    local key = args.key or Warcraft.secure_key(args.name)
    local atlas_key, atlas_pos = Warcraft.Atlas.get_pos("decks", args.index or 1)

    SMODS.Back({
        key = key,
        name = args.name,
        atlas = atlas_key,
        pos = atlas_pos,
        config = args.config or {},
        loc_txt = args.loc_txt,
        loc_vars = args.loc_vars,
        apply = args.apply,
        calculate = args.calculate
    })
end

-- ============================================
-- POOL HOOK (Restrict Jokers Globally)
-- ============================================
local old_add_to_pool = SMODS.add_to_pool
function SMODS.add_to_pool(object, args)
    -- Call original SMODS logic first
    local res, t
    if old_add_to_pool then
        res, t = old_add_to_pool(object, args)
    else
        res = true
    end

    -- If already rejected by vanilla/other mods, stop here
    if not res then return res, t end

    -- ORC VS HUMAN RESTRICTION
    if G.GAME and G.GAME.modifiers.war_orc_vs_human and object.set == 'Joker' then
        
        -- SAFE CHECK: Make sure extra is actually a table (Vanilla Jokers often use extra = 4, etc!)
        local faction = nil
        if object.config and type(object.config.extra) == "table" then
            faction = object.config.extra.faction
        end
        
        -- If it doesn't have a faction (e.g. Vanilla Jokers), it's banned
        if not faction then return false end
        
        local valid = false
        local list = type(faction) == "table" and faction or {faction}
        for _, f in ipairs(list) do
            if f == "Horde" or f == "Alliance" then
                valid = true
                break
            end
        end
        
        if not valid then return false end
    end

    return res, t
end