local jokers = {}
SMODS = { Joker = function(def) jokers[def.key] = def end }
G = { jokers = { config = { card_limit = 5 } } }
dofile(TEST_ROOT .. '/jokers/kitty.lua')
dofile(TEST_ROOT .. '/jokers/tungstencube.lua')

local kitty = { ability = { extra = { slots = 1 } } }
local def = jokers.kitty
def:add_to_deck(kitty)
def:add_to_deck(kitty) -- A second copy stacks.
assert(G.jokers.config.card_limit == 7, 'Kitty copies should each add a slot')
def:remove_from_deck(kitty, true)
assert(G.jokers.config.card_limit == 6, 'Debuff should remove one slot')
def:add_to_deck(kitty, true)
assert(G.jokers.config.card_limit == 7, 'Clearing debuff should restore the slot')
def:remove_from_deck(kitty)
def:remove_from_deck(kitty)
assert(G.jokers.config.card_limit == 5, 'Removing both copies should restore the original limit')

local cube = { ability = { extra = { dollars = 25 } } }
def = jokers.tungstencube
assert(def:calculate(cube, { joker_type_destroyed = true, card = cube }).dollars == 25,
    'Destroying Tungsten Cube should pay $25')
assert(def:calculate(cube, { joker_type_destroyed = true, card = cube, shatters = true }).dollars == 25,
    'Shattering Tungsten Cube should also pay')
for _, context in ipairs({
    { selling_self = true },
    { selling_card = true, card = cube },
    { joker_type_destroyed = true, card = kitty },
    { joker_type_destroyed = true, card = cube, blueprint = true },
    { joker_type_destroyed = true, card = cube, retrigger_joker = true },
    { end_of_round = true },
}) do
    assert(def:calculate(cube, context) == nil, 'Only its own destruction should pay once')
end
print('Passed Kitty slot lifecycle and Tungsten Cube destruction checks.')
