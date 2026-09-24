local definition
SMODS = { Joker = function(d) definition = d end }
G = { GAME = { hands = {} } }
PORKIFY_SECRET_HANDS = { porkify_three_pair = true, porkify_yes = true }
dofile(TEST_ROOT .. '/jokers/thebeyond.lua')
local card = { ability = { extra = { x_mult = 4 } }, joker_display_values = {} }
assert(not definition:in_pool())
for _, name in ipairs({'Five of a Kind', 'Flush House', 'Flush Five', 'Pair',
    'porkify_too_many_blanks', 'othermod_secret'}) do
    G.GAME.hands[name] = {played = 3}
    assert(not definition:in_pool())
    assert(definition:calculate(card, {joker_main = true, scoring_name = name}) == nil)
end
G.GAME.hands.porkify_three_pair = {played = 0, visible = true}
assert(not definition:in_pool(), 'Revealing hands does not qualify')
G.GAME.hands.porkify_three_pair.played = 1
assert(definition:in_pool())
for name in pairs(PORKIFY_SECRET_HANDS) do
    assert(definition:calculate(card, {joker_main = true, scoring_name = name}).x_mult == 4)
    assert(definition:calculate(card, {joker_main = true, scoring_name = name, blueprint = true}).x_mult == 4)
    assert(definition:calculate(card, {before = true, scoring_name = name}) == nil)
end
local selected = 'porkify_yes'
local display = definition.joker_display_def({evaluate_hand = function() return selected end})
display.calc_function(card)
assert(card.joker_display_values.x_mult == 4)
selected = 'Flush Five'
display.calc_function(card)
assert(card.joker_display_values.x_mult == 1)
G.GAME = {hands = {}}
assert(not definition:in_pool(), 'Eligibility resets with a new run')
PORKIFY_SECRET_HANDS = nil
assert(not definition:in_pool())
print('The Beyond hand eligibility, scoring and display checks passed')
