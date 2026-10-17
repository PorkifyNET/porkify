local definition
local pick_count = 0
local hands_refunded = 0

SMODS = {
    Joker = function(def) definition = def end
}
G = {
    C = { BLUE = {}, IMPORTANT = {} },
    GAME = {
        round = 1,
        round_resets = { ante = 1 },
        current_round = { hands_played = 0 },
        hands = {
            ['High Card'] = { visible = true },
            Pair = { visible = true },
            ['Flush Five'] = { visible = false }
        }
    },
    jokers = {}
}

pseudoseed = function(seed) return seed end
pseudorandom_element = function(values, seed)
    pick_count = pick_count + 1
    return values[((pick_count - 1) % #values) + 1]
end
localize = function(value) return 'Localized ' .. value end
ease_hands_played = function(amount)
    hands_refunded = hands_refunded + amount
end
card_eval_status_text = function() end

dofile(TEST_ROOT .. '/jokers/sleightofhand.lua')

local sleight = assert(definition)
local card = {
    ability = { extra = {} },
    joker_display_values = {}
}

sleight:set_ability(card, true)
assert(card.ability.extra.target_hand == 'High Card',
    'Sleight of Hand must choose from visible poker hands')
assert(sleight:loc_vars({}, card).vars[1] == 'Localized High Card')

G.GAME.round = 2
sleight:calculate(card, { setting_blind = true })
assert(card.ability.extra.target_hand == 'Pair' and not card.ability.extra.checked_this_round,
    'Sleight of Hand must choose a new target each round')

local refund = sleight:calculate(card, {
    after = true,
    cardarea = G.jokers,
    scoring_name = 'Pair'
})
assert(refund and refund.func and refund.func() and hands_refunded == 1,
    'A matching first hand must refund exactly one hand')
assert(card.ability.extra.checked_this_round)
assert(sleight:calculate(card, {
    after = true,
    cardarea = G.jokers,
    scoring_name = 'Pair'
}) == nil, 'Sleight of Hand must trigger at most once per round')

G.GAME.round = 3
G.GAME.current_round.hands_played = 0
sleight:calculate(card, { setting_blind = true })
assert(card.ability.extra.target_hand == 'High Card')
assert(sleight:calculate(card, {
    after = true,
    cardarea = G.jokers,
    scoring_name = 'Pair'
}) == nil, 'A non-matching first hand must not be refunded')
assert(card.ability.extra.checked_this_round,
    'A non-matching first hand must consume the round opportunity')

local target_before_blueprint = card.ability.extra.target_hand
sleight:calculate(card, { setting_blind = true, blueprint = true })
assert(card.ability.extra.target_hand == target_before_blueprint,
    'Blueprint contexts must not reroll Sleight of Hand')

local display = sleight.joker_display_def({})
display.calc_function(card)
assert(card.joker_display_values.target_text == 'Localized High Card')

print('Sleight of Hand target and first-hand refund checks passed')
