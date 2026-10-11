local definitions, created_cards = {}, {}
SMODS = {
    Joker = function(d) definitions[d.key] = d end,
    add_card = function(args)
        created_cards[#created_cards + 1] = args
        return {}
    end
}
G = {
    C = {MONEY = {}, CHIPS = {}, PURPLE = {}, BLUE = {}, IMPORTANT = {}},
    consumeables = {cards = {}, config = {card_limit = 2}}
}
localize = function(key) return key end
play_sound = function() end
card_eval_status_text = function() end
local hands_gained = 0
ease_hands_played = function(amount) hands_gained = hands_gained + amount end
dofile(TEST_ROOT .. '/jokers/aquacard.lua')
dofile(TEST_ROOT .. '/jokers/blackcard.lua')
dofile(TEST_ROOT .. '/jokers/yellowcard.lua')
dofile(TEST_ROOT .. '/jokers/bluecard.lua')
dofile(TEST_ROOT .. '/jokers/greencard.lua')
dofile(TEST_ROOT .. '/jokers/pinkcard.lua')
local aqua, black = definitions.aquacard, definitions.blackcard
local yellow, blue, green, pink = definitions.yellowcard, definitions.bluecard,
    definitions.greencard, definitions.pinkcard
local a = {ability = {extra = {hands = 0, gain = 1}}}
local k = {ability = {extra = {reduction = 0, gain = 0.01, max_reduction = 0.99}}}
local y = {ability = {extra = {payout = 0, gain = 1}}}
local b = {ability = {extra = {chips = 0, gain = 10}}}
local g = {ability = {extra = {refund_rate = 0.5, pack_cost = 0}}}
local p = {ability = {extra = {}}, juice_up = function() end}
assert(aqua.porkify_color_card and black.porkify_color_card
    and yellow.porkify_color_card and blue.porkify_color_card
    and green.porkify_color_card and pink.porkify_color_card)
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

green:calculate(g, {open_booster = true, card = {cost = 5}})
local refund = green:calculate(g, {skipping_booster = true})
assert(refund.dollars == 2, 'Green Card rounds a 50% refund down')
assert(g.ability.extra.pack_cost == 0, 'Green Card consumes its recorded purchase price')
assert(green:calculate(g, {skipping_booster = true}) == nil, 'A pack can only be refunded once')
green:calculate(g, {open_booster = true, card = {cost = 0}})
assert(green:calculate(g, {skipping_booster = true}) == nil, 'Free packs do not create money')
green:calculate(g, {open_booster = true, card = {cost = 8}})
green:calculate(g, {ending_booster = true})
assert(g.ability.extra.pack_cost == 0, 'Taking a pack reward clears the pending refund')
green:calculate(g, {open_booster = true, card = {cost = 6}, blueprint = true})
assert(g.ability.extra.pack_cost == 0, 'Blueprint contexts cannot record a refund')
assert(green:loc_vars({}, g).vars[1] == 50)

for _ = 1, 3 do aqua:calculate(a, {skipping_booster = true}) end
assert(a.ability.extra.hands == 3)
local hand_effect = aqua:calculate(a, {setting_blind = true})
assert(a.ability.extra.hands == 0 and type(hand_effect.func) == 'function')
hand_effect.func()
assert(hands_gained == 3, 'Aqua Card banks Hands for the next Blind')
assert(aqua:calculate(a, {setting_blind = true}) == nil, 'Aqua Card spends its bank once')

for _ = 1, 10 do black:calculate(k, {skipping_booster = true}) end
local blind_effect = black:calculate(k, {setting_blind = true})
assert(math.abs(blind_effect.x_blind_size - 0.9) < 1e-9,
    'Black Card applies an additive 1% reduction per skipped pack')
assert(black:loc_vars({}, k).vars[2] == 10)
local black_display = black.joker_display_def({})
black_display.calc_function(k)
assert(k.joker_display_values.reduction_text == '-10%')
black:calculate(k, {skipping_booster = true, blueprint = true})
black:calculate(k, {skipping_booster = true, retrigger_joker = true})
assert(math.abs(k.ability.extra.reduction - 0.1) < 1e-9,
    'Black Card cannot scale from Blueprint or retriggers')

assert(pink:calculate(p, {open_booster = true}) == nil)
assert(pink:calculate(p, {skipping_booster = true, retrigger_joker = true}) == nil)
local create_effect = pink:calculate(p, {skipping_booster = true})
assert(type(create_effect.func) == 'function')
assert(create_effect.func() == true)
assert(#created_cards == 1 and created_cards[1].set == 'porkify',
    'Pink Card creates a Porkify consumable')
G.consumeables.cards = {{}, {}}
pink:calculate(p, {skipping_booster = true}).func()
assert(#created_cards == 1, 'Pink Card respects the consumable slot limit')
G.consumeables.cards = {}
pink:calculate(p, {skipping_booster = true, blueprint = true}).func()
assert(#created_cards == 2, 'Blueprint can copy Pink Card')

print('Color Card skip, payout, refund, creation, Blind and scoring checks passed')
