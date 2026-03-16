Warcraft = Warcraft or {}

function Warcraft.secure_key(name)
    return string.lower(name:gsub(" ", "_"):gsub("[^a-zA-Z0-9_]", ""))
end

function Warcraft.is_straight_hand(name)
    if not name then return false end
    return name:find("Straight") or name == "Royal Flush"
end

-- Helper: check if a joker has a specific race
function Warcraft.is_race(joker, race)
    if not joker or not joker.ability or not joker.ability.extra then return false end
    local r = joker.ability.extra.race
    local list = type(r) == "table" and r or { r }
    for _, v in ipairs(list) do
        if v == race then return true end
    end
    return false
end

-- Helper: check if a joker has a specific class
function Warcraft.is_class(joker, class)
    if not joker or not joker.ability or not joker.ability.extra then return false end
    local c = joker.ability.extra.class
    local list = type(c) == "table" and c or { c }
    for _, v in ipairs(list) do
        if v == class then return true end
    end
    return false
end

-- Helper: check if a joker has a specific faction
function Warcraft.is_faction(joker, faction)
    if not joker or not joker.ability or not joker.ability.extra then return false end
    local f = joker.ability.extra.faction
    local list = type(f) == "table" and f or { f }
    for _, v in ipairs(list) do
        if v == faction then return true end
    end
    return false
end

-- Helper: check if a joker is Demon race OR Legion faction (used by Archimonde/Malganis etc)
function Warcraft.is_demon_or_legion(joker)
    if not joker then return false end
    return Warcraft.is_race(joker, "Demon") or Warcraft.is_faction(joker, "Legion")
end