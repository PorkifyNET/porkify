local hands, challenge = {}, nil

G = { playing_cards = {}, GAME = { modifiers = {} } }
SMODS = {
    Suit = { obj_buffer = {} },
    shortcut = function() return false end,
    wrap_around_straight = function() return false end,
    PokerHand = function(def) hands[def.key] = def end,
    Challenge = function(def) challenge = def end,
}
HEX = function(value) return value end

dofile(TEST_ROOT .. '/poker_hands.lua')
dofile(TEST_ROOT .. '/challenges/singlecard.lua')

local only_card = {}
G.playing_cards = { only_card }
assert(#hands.yes.evaluate({}, G.playing_cards) == 1)

G.GAME.modifiers.no_porkify_yes = true
assert(#hands.yes.evaluate({}, G.playing_cards) == 0)

local found_rule = false
for _, rule in ipairs(challenge.rules.custom) do
    if rule.id == 'no_porkify_yes' then found_rule = true end
end
assert(found_rule)

print('Single Card disables the Yes poker hand')
