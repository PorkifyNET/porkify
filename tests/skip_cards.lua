local definitions = {}
SMODS = {Joker = function(d) definitions[d.key] = d end}
G = {C = {MONEY = {}, CHIPS = {}}}
localize = function(key) return key end
dofile(TEST_ROOT .. '/jokers/yellowcard.lua')
dofile(TEST_ROOT .. '/jokers/bluecard.lua')
local yellow, blue = definitions.yellowcard, definitions.bluecard
local y = {ability = {extra = {payout = 0, gain = 1}}}
local b = {ability = {extra = {chips = 0, gain = 10}}}
assert(yellow:calc_dollar_bonus(y) == nil)
assert(blue:calculate(b, {joker_main = true}).chips == 0)
for _, context in ipairs({{open_booster = true}, {ending_shop = true},
    {skipping_booster = true, blueprint = true},
    {skipping_booster = true, retrigger_joker = true}}) do
    yellow:calculate(y, context)
    blue:calculate(b, context)
end
assert(y.ability.extra.payout == 0 and b.ability.extra.chips == 0)
for i = 1, 3 do
    yellow:calculate(y, {skipping_booster = true})
    blue:calculate(b, {skipping_booster = true})
    assert(yellow:calc_dollar_bonus(y) == i)
    assert(blue:calculate(b, {joker_main = true}).chips == i * 10)
end
assert(yellow:calc_dollar_bonus(y) == 3) -- Payout is retained for later rounds.
assert(blue:calculate(b, {joker_main = true, blueprint = true}).chips == 30)
assert(yellow:loc_vars({}, y).vars[1] == 3)
assert(blue:loc_vars({}, b).vars[2] == 30)
assert(yellow.joker_display_def({}).text[2].ref_value == 'payout')
assert(blue.joker_display_def({}).text[2].ref_value == 'chips')
print('Yellow Card and Blue Card skip, payout and scoring checks passed')
