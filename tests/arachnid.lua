local definition
SMODS = {
    Consumable = function(value) definition = value end,
    Ranks = {{card_key = 'A'}},
    change_base = function(card, suit, rank)
        card.base.value = rank
        return true
    end,
}

local Big = {}
Big.__index = Big
local function big(value)
    return setmetatable({value = value}, Big)
end
function to_number(value)
    return getmetatable(value) == Big and value.value or value
end

local conversions = 0
local function playing_card(rank)
    return {
        base = {value = rank},
        flip = function() end,
        juice_up = function() end,
    }
end

G = {
    GAME = {dollars = big(28)},
    hand = {cards = {
        playing_card('2'),
        playing_card('3'),
        playing_card('4'),
        playing_card('5'),
        playing_card('6'),
    }},
    E_MANAGER = {add_event = function(self, event) event.func() end},
}

Event = function(value) return value end
pseudorandom_element = function(values) return values[1] end
pseudoseed = function() return 0 end
pseudoshuffle = function() end
play_sound = function() end
delay = function() end
ease_dollars = function(amount)
    G.GAME.dollars = big(to_number(G.GAME.dollars) + amount)
    conversions = conversions + 1
end

dofile(TEST_ROOT .. '/consumables/arachnid.lua')

local source = {juice_up = function() end}
assert(definition:can_use(source), 'Arachnid should accept a Talisman balance of $28')
definition:use(source)
assert(conversions == 3, 'A $28 balance should afford exactly three conversions')
assert(to_number(G.GAME.dollars) == 4, 'Arachnid should charge $8 per converted card')

G.GAME.dollars = big(7)
assert(not definition:can_use(source), 'Arachnid should reject a Talisman balance below $8')

G.GAME.dollars = 8
assert(definition:can_use(source), 'Arachnid should continue to accept ordinary numeric balances')

print('Arachnid supports ordinary and Talisman dollar values')
