local challenge

SMODS = {
    Challenge = function(def) challenge = def end,
}

function HEX(value) return value end

dofile(TEST_ROOT .. '/challenges/flashlight.lua')

assert(challenge and challenge.key == 'flashlight')
assert(challenge.deck and challenge.deck.type == 'Challenge Deck')
assert(#challenge.deck.cards == 52, 'Flashlight must retain a standard 52-card starting deck')

local seen = {}
local resolute_count = 0
for _, card in ipairs(challenge.deck.cards) do
    local card_key = card.s .. '_' .. card.r
    assert(not seen[card_key], 'Flashlight contains duplicate starting card ' .. card_key)
    seen[card_key] = true

    local is_face = card.r == 'J' or card.r == 'Q' or card.r == 'K'
    if is_face then
        assert(card.e == 'm_porkify_revolving', card_key .. ' must start Resolute')
        resolute_count = resolute_count + 1
    else
        assert(card.e == nil, card_key .. ' must not start Resolute')
    end
end

assert(resolute_count == 12, 'Flashlight must start with exactly 12 Resolute face cards')

print('Flashlight starting deck checks passed')
