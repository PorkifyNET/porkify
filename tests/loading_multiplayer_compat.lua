local loading
SMODS = {
    Joker = function(definition) loading = definition end,
    add_to_pool = function(center)
        return center.pool_enabled ~= false
    end,
}

local valid = { key = "j_valid", name = "Valid", rarity = 1, unlocked = true }
local mp_disabled = { key = "j_mp_disabled", name = "Disabled", rarity = 1, unlocked = true }
local banned = { key = "j_banned", name = "Banned", rarity = 1, unlocked = true }
local out_of_pool = {
    key = "j_out_of_pool", name = "Out of pool", rarity = 1, unlocked = true,
    pool_enabled = false,
}

G = {
    jokers = {},
    GAME = { banned_keys = { j_banned = true } },
    P_CENTER_POOLS = { Joker = { mp_disabled, banned, out_of_pool, valid } },
}

MP = {
    should_exclude_from_pool = function(center)
        return center.key == "j_mp_disabled"
    end,
}

local rolled_pool
pseudorandom_element = function(pool)
    rolled_pool = pool
    return pool[1]
end

assert(loadfile("jokers/loading.lua"))()
assert(loading)

local card = { ability = { extra = {} } }
loading.calculate(loading, card, { after = true, cardarea = G.jokers })

assert(#rolled_pool == 1, "Loading must only roll currently available Jokers")
assert(rolled_pool[1].key == "j_valid")
assert(card.ability.extra.CurrentJoker == "j_valid")
assert(card.ability.extra.CurrentJokerName == "Valid")

print("Loading Multiplayer compatibility tests passed")
