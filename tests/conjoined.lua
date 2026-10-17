local definition
local shuffled = false
local status_message

SMODS = {
    Consumable = function(value) definition = value end,
    is_eternal = function(card)
        return card.eternal or false
    end
}

local function joker(eternal)
    return {
        eternal = eternal,
        ability = { set = 'Joker' },
        start_dissolve = function(self)
            self.destroyed = true
        end
    }
end

local selected = {
    ability = {},
    flip = function() end,
    juice_up = function() end
}
local first_joker = joker(false)
local second_joker = joker(false)
local eternal_joker = joker(true)

G = {
    C = { IMPORTANT = {} },
    hand = {
        highlighted = { selected },
        unhighlight_all = function(self)
            self.highlighted = {}
        end
    },
    jokers = { cards = { eternal_joker, first_joker, second_joker } },
    E_MANAGER = {
        add_event = function(self, event)
            event.func()
        end
    }
}

to_big = function(value) return value end
Event = function(value) return value end
pseudoseed = function(seed)
    assert(seed == 'porkify_conjoined_joker')
    return seed
end
pseudoshuffle = function(cards)
    shuffled = true
    cards[1], cards[2] = cards[2], cards[1]
end
play_sound = function() end
card_eval_status_text = function(card, kind, a, b, c, details)
    status_message = details.message
end

dofile(TEST_ROOT .. '/consumables/conjoined.lua')

local source = { juice_up = function() end }
assert(definition:can_use(source),
    'Conjoined requires one selected card and a destructible Joker')
definition:use(source)

assert(selected.ability.perma_repetitions == 1,
    'Conjoined must permanently add one repetition to the selected card')
assert(status_message == '+1 Retrigger')
assert(shuffled and second_joker.destroyed and not first_joker.destroyed,
    'Conjoined must destroy one pseudorandom non-Eternal Joker')
assert(not eternal_joker.destroyed, 'Conjoined must not destroy Eternal Jokers')
assert(#G.hand.highlighted == 0, 'Conjoined must clear the card selection after use')

G.hand.highlighted = { selected, {} }
assert(not definition:can_use(source), 'Conjoined requires exactly one selected card')
G.hand.highlighted = { selected }
G.jokers.cards = { eternal_joker }
assert(not definition:can_use(source),
    'Conjoined cannot be used without a destructible Joker')

print('Conjoined repetition and random Joker destruction checks passed')
