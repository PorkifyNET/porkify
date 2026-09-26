local definitions = {}
SMODS = {
    Consumable = function(definition) definitions.consumable = definition end,
    Joker = function(definition) definitions.joker = definition end,
}

local selected = {
    ability = {},
    flip = function() end,
    juice_up = function() end,
}

G = {
    C = {
        CHIPS = {}, MULT = {}, MONEY = {}, PURPLE = {}, IMPORTANT = {},
        DYN_UI = { DARK = {} },
    },
    hand = {
        cards = { selected },
        highlighted = { selected },
        unhighlight_all = function() end,
    },
    E_MANAGER = { add_event = function() end },
    GAME = { blind = { boss = true, chips = 1000 } },
}

Event = function(event) return event end
delay = function() end
to_big = function(value) return value end
to_number = function(value) return value end
pseudoseed = function(seed) return seed end

local candidate_count
pseudorandom_element = function(pool)
    candidate_count = #pool
    return pool[1]
end

assert(loadfile("consumables/casualwalk.lua"))()
local casual_walk = assert(definitions.consumable)
local used_card = { juice_up = function() end }

MP = { is_mp_or_ghost = function() return true end }
casual_walk.use(casual_walk, used_card)
assert(candidate_count == 16, "Multiplayer Casual Walk must omit four Blind Size bonuses")

MP.is_mp_or_ghost = function() return false end
casual_walk.use(casual_walk, used_card)
assert(candidate_count == 20, "Single-player Casual Walk must retain every bonus")

assert(loadfile("jokers/headstart.lua"))()
local headstart = assert(definitions.joker)
local joker_card = { ability = { extra = { score_percent = 0.1 } } }

MP.is_pvp_boss = function() return true end
assert(headstart.calculate(headstart, joker_card, { setting_blind = true }) == nil,
    "Headstart must not score against a Nemesis Blind")

MP.is_pvp_boss = function() return false end
local result = headstart.calculate(headstart, joker_card, { setting_blind = true })
assert(result and result.score == 100, "Headstart must retain its normal Boss Blind effect")

print("multiplayer Blind Size compatibility tests passed")
