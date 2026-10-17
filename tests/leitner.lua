local definition

SMODS = {
    Joker = function(def) definition = def end
}
G = {
    C = { CHIPS = {} }
}
localize = function(key) return key end

dofile(TEST_ROOT .. '/jokers/leitner.lua')

local leitner = assert(definition)
local card = {
    ability = { extra = { chips = 0, chip_gain = 20 } },
    joker_display_values = {}
}

assert(leitner:loc_vars({}, card).vars[1] == 20)
assert(leitner:loc_vars({}, card).vars[2] == 0)

for reroll = 1, 3 do
    local effect = leitner:calculate(card, { reroll_shop = true })
    assert(effect and card.ability.extra.chips == reroll * 20,
        'Each shop reroll must permanently add 20 Chips')
end

leitner:calculate(card, { reroll_shop = true, blueprint = true })
leitner:calculate(card, { reroll_shop = true, retrigger_joker = true })
assert(card.ability.extra.chips == 60,
    'Blueprint and retrigger contexts must not scale Leitner')

local scoring = leitner:calculate(card, { joker_main = true, blueprint = true })
assert(scoring and scoring.chips == 60,
    'Blueprint must copy Leitner\'s stored Chips during scoring')

local display = leitner.joker_display_def({})
display.calc_function(card)
assert(card.joker_display_values.chips_text == '+60')

print('Leitner shop reroll and scoring checks passed')
