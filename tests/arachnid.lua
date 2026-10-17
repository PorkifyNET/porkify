local definition
local conversions = 0

SMODS = {
    Consumable = function(value) definition = value end,
    change_base = function(card, suit, rank)
        card.base.value = rank
        conversions = conversions + 1
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
function to_big(value)
    return getmetatable(value) == Big and value or big(value)
end
function Big.__add(left, right)
    return big(to_number(left) + to_number(right))
end
function Big.__sub(left, right)
    return big(to_number(left) - to_number(right))
end

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
        playing_card('7'),
        playing_card('9'),
        playing_card('10'),
        playing_card('Jack'),
        playing_card('Queen'),
    }},
    E_MANAGER = {add_event = function(self, event) event.func() end},
}

Event = function(value) return value end
pseudoseed = function() return 0 end
pseudoshuffle = function() end
play_sound = function() end
delay = function() end
ease_dollars = function(amount)
    G.GAME.dollars = G.GAME.dollars + amount
end

dofile(TEST_ROOT .. '/consumables/arachnid.lua')

local source = {juice_up = function() end}
assert(definition:can_use(source), 'Arachnid must be usable with cards in hand')
assert(definition:loc_vars({}, source).vars[1] == 8)
assert(definition:loc_vars({}, source).vars[2] == 8)

definition:use(source)
assert(conversions == 8, 'Arachnid must convert at most eight cards')
for i = 1, 8 do
    assert(G.hand.cards[i].base.value == '8', 'Selected cards must become 8s')
end
assert(G.hand.cards[9].base.value == 'Jack' and G.hand.cards[10].base.value == 'Queen',
    'Cards beyond the eight-card limit must remain unchanged')
assert(to_number(G.GAME.dollars) == 8,
    'Arachnid must set a Talisman balance exactly to $8')

G.hand.cards = {
    playing_card('Ace'),
    playing_card('King'),
    playing_card('Queen'),
}
G.GAME.dollars = -5
definition:use(source)
assert(conversions == 11, 'Arachnid must convert every card when fewer than eight are eligible')
for _, card in ipairs(G.hand.cards) do
    assert(card.base.value == '8')
end
assert(to_number(G.GAME.dollars) == 8,
    'Arachnid must also raise an ordinary negative balance exactly to $8')

G.hand.cards = {}
assert(not definition:can_use(source), 'Arachnid requires at least one card in hand')

print('Arachnid converts up to eight cards to 8s and sets money to $8')
