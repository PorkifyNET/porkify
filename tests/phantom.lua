local definition
SMODS = {Joker = function(d) definition = d end}
localize = function() return 'Negative' end
G = {C = {CHIPS = {}}, jokers = {cards = {}}}
dofile(TEST_ROOT .. '/jokers/phantom.lua')
local card = {ability = {extra = {x_chips = 2}}, joker_display_values = {}}
local negative = {edition = {negative = true}}
local keyed = {edition = {key = 'e_negative'}}
assert(definition.in_pool == nil)
assert(definition:calculate(card, {other_joker = negative}).x_chips == 2)
assert(definition:calculate(card, {other_joker = keyed, blueprint = true}).x_chips == 2)
assert(definition:calculate(card, {other_joker = {}}) == nil)
assert(definition:calculate(card, {joker_main = true}) == nil)
assert(definition:calculate(card, {individual = true, other_card = negative}) == nil)
assert(negative.edition.negative)
negative.destroyed = true
assert(definition:calculate(card, {other_joker = negative}) == nil)
negative.destroyed = nil
local display = definition.joker_display_def({calculate_joker_triggers = function() return 1 end})
display.calc_function(card)
assert(card.joker_display_values.count == 0)
G.jokers.cards = {negative, keyed, {}}
display.calc_function(card)
assert(card.joker_display_values.count == 2)
card.edition = {negative = true}
assert(definition:calculate(card, {other_joker = card}).x_chips == 2)
local old_save = {ability = {extra = {x_mult = 1.5, gain = 0.1}}}
assert(definition:calculate(old_save, {other_joker = keyed}).x_chips == 2)
print('Phantom Negative Joker scoring, pool and display checks passed')

assert(display.mod_function(negative, card).x_chips == 2)
assert(display.mod_function({}, card).x_chips == nil)
local copied = definition.joker_display_def({calculate_joker_triggers = function() return 2 end})
assert(copied.mod_function(negative, card).x_chips == 4)
