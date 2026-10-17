local definition

SMODS = {
    Joker = function(def) definition = def end
}
G = {
    GAME = {
        joker_buffer = 0,
        consumeable_buffer = 0
    },
    C = { IMPORTANT = {} },
    jokers = {
        cards = {},
        config = { card_limit = 5 }
    },
    consumeables = {
        cards = {},
        config = { card_limit = 2 }
    },
    hand = {
        size_changes = {},
        change_size = function(self, amount)
            self.size_changes[#self.size_changes + 1] = amount
        end
    }
}

dofile(TEST_ROOT .. '/jokers/paint.lua')

local paint = assert(definition)
local card = {
    ability = { extra = { hand_size_per_slot = 1 } },
    joker_display_values = {}
}

assert(paint:loc_vars({}, card).vars[2] == 7,
    'An unowned Paint must preview all five empty Joker and two Consumable slots')

card.area = G.jokers
G.jokers.cards = { card }
paint:add_to_deck(card, false)
assert(G.hand.size_changes[1] == 7 and card.porkify_paint_hand_size == 7,
    'Paint must count itself as an empty Joker slot')

local other_joker = {}
G.jokers.cards[#G.jokers.cards + 1] = other_joker
paint:update(card, 0)
assert(G.hand.size_changes[2] == -1 and card.porkify_paint_hand_size == 6,
    'Filling a Joker slot must remove one Hand Size')

G.consumeables.cards[1] = {}
paint:update(card, 0)
assert(G.hand.size_changes[3] == -1 and card.porkify_paint_hand_size == 5,
    'Filling a Consumable slot must remove one Hand Size')

G.GAME.consumeable_buffer = 1
paint:update(card, 0)
assert(G.hand.size_changes[4] == -1 and card.porkify_paint_hand_size == 4,
    'A reserved Consumable slot must not count as empty')

G.GAME.consumeable_buffer = 0
G.jokers.config.card_limit = 6
paint:update(card, 0)
assert(G.hand.size_changes[5] == 2 and card.porkify_paint_hand_size == 6,
    'Opening slots must immediately increase Hand Size')

local display = paint.joker_display_def({})
display.calc_function(card)
assert(card.joker_display_values.hand_size_text == '+6')

paint:remove_from_deck(card, false)
assert(G.hand.size_changes[6] == -6 and card.porkify_paint_hand_size == nil,
    'Removing Paint must remove its entire applied Hand Size bonus')

print('Paint empty-slot Hand Size checks passed')
