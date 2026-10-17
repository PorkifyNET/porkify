local definition
SMODS = {
    Back = function(value) definition = value end
}

G = {
    SETTINGS = { profile = 1 },
    PROFILES = {
        [1] = {
            hand_usage = {
                HighCard = { count = 20, order = 'High Card' },
                Pair = { count = 48, order = 'Pair' },
                Flush = { count = 31, order = 'Flush' }
            }
        }
    },
    GAME = {
        hands = {
            ['High Card'] = { level = 1 },
            Pair = { level = 1 },
            Flush = { level = 1 }
        }
    },
    E_MANAGER = {
        add_event = function(self, event) return event.func() end
    }
}

Event = function(event) return event end
local upgraded_hand, upgraded_by
level_up_hand = function(card, hand, instant, amount)
    upgraded_hand, upgraded_by = hand, amount
    G.GAME.hands[hand].level = G.GAME.hands[hand].level + amount
end

dofile(TEST_ROOT .. '/decks/braided_deck.lua')
assert(definition, 'Braided Deck must register')
assert(definition.loc_txt.text[2]:find('level 3', 1, true),
    'Braided Deck description must state the new effect')

definition:apply()
assert(upgraded_hand == 'Pair' and upgraded_by == 2 and G.GAME.hands.Pair.level == 3,
    'Braided Deck must set the all-time most played hand to level 3')

G.PROFILES[1].hand_usage = {
    Pair = { count = 10, order = 'Pair' },
    Flush = { count = 10, order = 'Flush' }
}
G.GAME.hands.Pair.level = 1
G.GAME.hands.Flush.level = 1
upgraded_hand, upgraded_by = nil, nil
definition:apply()
assert(upgraded_hand == 'Flush' and G.GAME.hands.Flush.level == 3,
    'Braided Deck must resolve tied usage deterministically')

G.PROFILES[1].hand_usage = {}
G.GAME.hands['High Card'].level = 1
upgraded_hand, upgraded_by = nil, nil
definition:apply()
assert(upgraded_hand == 'High Card' and G.GAME.hands['High Card'].level == 3,
    'Braided Deck must fall back to High Card on a fresh profile')

print('Braided Deck profile hand selection and level checks passed')
