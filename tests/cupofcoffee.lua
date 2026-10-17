local definition

SMODS = {
    Joker = function(def) definition = def end
}
G = {
    C = { MULT = {}, RED = {} },
    play = {},
    jokers = {},
    E_MANAGER = {}
}

local scheduled_event
G.E_MANAGER.add_event = function(self, event)
    scheduled_event = event
end
Event = function(definition) return definition end
card_eval_status_text = function() end

dofile(TEST_ROOT .. '/jokers/cupofcoffee.lua')

local coffee = assert(definition)
local card = {
    ability = { extra = {} },
    joker_display_values = {},
    start_dissolve = function(self)
        self.dissolved = true
    end
}

coffee:set_ability(card, true)
assert(card.ability.extra.mult == 15)
assert(card.ability.extra.mult_transfer == 1)
assert(coffee:loc_vars({}, card).vars[2] == 15)

local played_card = { ability = {} }
local stolen = coffee:calculate(card, {
    individual = true,
    cardarea = G.play,
    other_card = played_card
})
assert(stolen and played_card.ability.perma_mult == 1,
    'A scored card must permanently steal +1 Mult')
assert(card.ability.extra.mult == 14,
    'Cup of Coffee must lose the Mult stolen by a scored card')

coffee:calculate(card, {
    individual = true,
    cardarea = G.play,
    other_card = played_card,
    blueprint = true
})
assert(played_card.ability.perma_mult == 1 and card.ability.extra.mult == 14,
    'Blueprint evaluation must not transfer Mult')

local debuffed_card = { ability = {}, debuff = true }
coffee:calculate(card, {
    individual = true,
    cardarea = G.play,
    other_card = debuffed_card
})
assert(debuffed_card.ability.perma_mult == nil and card.ability.extra.mult == 14,
    'Debuffed cards must not steal Mult')

local final_transfer
for _ = 1, 14 do
    final_transfer = coffee:calculate(card, {
        individual = true,
        cardarea = G.play,
        other_card = played_card
    })
end
assert(card.ability.extra.mult == 0 and played_card.ability.perma_mult == 15)
assert(final_transfer and final_transfer.func,
    'The final Mult transfer must schedule Cup of Coffee for destruction')
assert(final_transfer.func() and scheduled_event,
    'Cup of Coffee must enqueue its destruction effect')
assert(scheduled_event.func() and card.dissolved and card.getting_sliced,
    'Cup of Coffee must dissolve after its final Mult is transferred')
assert(coffee:calculate(card, {
    individual = true,
    cardarea = G.play,
    other_card = played_card
}) == nil, 'Cards must not steal Mult after the Cup is empty')
assert(played_card.ability.perma_mult == 15)

local scoring = coffee:calculate(card, { cardarea = G.jokers, joker_main = true })
assert(scoring and scoring.mult == 0, 'An empty Cup must provide +0 Mult')

local display = coffee.joker_display_def({})
display.calc_function(card)
assert(card.joker_display_values.mult_text == '+0')

print('Cup of Coffee Mult transfer checks passed')
