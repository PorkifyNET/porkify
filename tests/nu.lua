local definition
local rolls = {}

SMODS = {
    Joker = function(def) definition = def end,
    get_probability_vars = function(card, numerator, denominator, key)
        return numerator, denominator
    end,
    pseudorandom_probability = function(card, seed, numerator, denominator, key)
        rolls[#rolls + 1] = {
            seed = seed,
            numerator = numerator,
            denominator = denominator,
            key = key,
        }
        return seed == 'group_nu_left'
    end,
}

function localize(key) return key end

dofile(TEST_ROOT .. '/jokers/nu.lua')

assert(definition and definition.key == 'nu')
assert(definition.blueprint_compat,
    'N.U. must support Blueprint copies')

local left = {}
local nu = { ability = { extra = { odds = 2 } } }
local right = {}
local distant = {}
G = { jokers = { cards = { left, nu, right, distant } } }

local left_result = definition:calculate(nu, {
    retrigger_joker_check = true,
    other_card = left,
})
assert(left_result and left_result.repetitions == 1,
    'N.U. must retrigger the left Joker when its roll succeeds')
assert(left_result.message == 'k_again_ex')

local right_result = definition:calculate(nu, {
    retrigger_joker_check = true,
    other_card = right,
})
assert(not right_result,
    'N.U. must not retrigger the right Joker when its roll fails')

assert(not definition:calculate(nu, {
    retrigger_joker_check = true,
    other_card = distant,
}), 'N.U. must not retrigger non-adjacent Jokers')
assert(#rolls == 2,
    'N.U. must only roll for adjacent Jokers')
assert(rolls[1].seed == 'group_nu_left'
    and rolls[2].seed == 'group_nu_right',
    'N.U. must use independent rolls for its left and right Jokers')
for _, roll in ipairs(rolls) do
    assert(roll.numerator == 1 and roll.denominator == 2,
        'Each N.U. retrigger roll must have 1-in-2 odds')
    assert(roll.key == 'j_porkify_nu')
end

assert(not definition:calculate(nu, {
    individual = true,
    other_card = left,
}), 'N.U. must only act during Joker retrigger checks')

print('N.U. adjacent Joker retrigger checks passed')
