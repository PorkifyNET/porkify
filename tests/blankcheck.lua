local definition
local shuffle_after_flip = false
local random_seed

SMODS = {
    Consumable = function(def) definition = def end
}

local function joker(name)
    return {
        name = name,
        facing = 'front',
        flip = function(self)
            self.facing = self.facing == 'front' and 'back' or 'front'
        end
    }
end

local selected = {
    flip = function() end,
    juice_up = function() end,
    set_seal = function(self, seal)
        self.seal = seal
    end
}
local first_joker = joker('first')
local second_joker = joker('second')

G = {
    P_SEALS = { porkify_blank = {} },
    hand = {
        cards = { selected },
        highlighted = { selected },
        unhighlight_all = function(self)
            self.highlighted = {}
        end
    },
    jokers = {
        cards = { first_joker, second_joker },
        shuffle = function(self, seed)
            assert(seed == 'porkify_blank_jokers')
            shuffle_after_flip = second_joker.facing == 'back'
            self.cards[1], self.cards[2] = self.cards[2], self.cards[1]
        end
    },
    E_MANAGER = {
        add_event = function(self, event)
            event.func()
        end
    }
}

to_big = function(value) return value end
Event = function(value) return value end
pseudoseed = function(seed) return seed end
pseudorandom_element = function(cards, seed)
    random_seed = seed
    return cards[2]
end
play_sound = function() end

dofile(TEST_ROOT .. '/consumables/blankcheck.lua')

local source = { juice_up = function() end }
assert(definition:can_use(source), 'Blank requires one selected card and an owned Joker')
definition:use(source)

assert(selected.seal == 'porkify_blank', 'Blank must add a Blank Seal')
assert(random_seed == 'porkify_blank_joker' and second_joker.facing == 'back',
    'Blank must permanently flip one pseudorandom Joker face-down')
assert(first_joker.facing == 'front', 'Blank must flip only one Joker')
assert(shuffle_after_flip and G.jokers.cards[1] == second_joker,
    'Blank must shuffle Jokers after flipping its target')
assert(#G.hand.highlighted == 0, 'Blank must clear the playing-card selection')

G.hand.highlighted = { selected }
G.jokers.cards = {}
assert(not definition:can_use(source), 'Blank cannot be used without an owned Joker')
G.jokers.cards = { first_joker }
G.hand.highlighted = {}
assert(not definition:can_use(source), 'Blank requires exactly one selected playing card')

print('Blank Seal, permanent Joker flip, and shuffle checks passed')
