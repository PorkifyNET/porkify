local definitions = {}

SMODS = {
    Joker = function(def) definitions[def.key] = def end
}

local function area(limit)
    return {
        cards = {},
        config = { card_limit = limit },
        change_size = function(self, amount)
            self.config.card_limit = self.config.card_limit + amount
        end
    }
end

local sleeve_card = {
    ability = { name = 'Card Sleeve' },
    config = { center = { key = 'j_porkify_cardsleeve' } }
}
G = {
    GAME = { joker_buffer = 0, consumeable_buffer = 0 },
    jokers = area(5),
    consumeables = area(2)
}
G.jokers.cards = { sleeve_card }

dofile(TEST_ROOT .. '/jokers/cardsleeve.lua')

local sleeve = assert(definitions.cardsleeve)
sleeve:add_to_deck(sleeve_card, false)
assert(G.jokers.config.card_limit == 7,
    'Empty Consumable slots must become available to Jokers')
assert(G.consumeables.config.card_limit == 6,
    'Empty Joker slots, excluding Card Sleeve itself, must become available to Consumables')

G.consumeables.cards = { {}, {}, {}, {} }
sleeve:update(sleeve_card, 0)
assert(G.jokers.config.card_limit == 3 and G.consumeables.config.card_limit == 6,
    'Consumables must consume capacity from the shared Joker limit')

G.jokers.cards[#G.jokers.cards + 1] = {}
G.jokers.cards[#G.jokers.cards + 1] = {}
sleeve:update(sleeve_card, 0)
assert(G.jokers.config.card_limit == 3 and G.consumeables.config.card_limit == 4,
    'A full shared pool must close both card areas')

table.remove(G.consumeables.cards)
sleeve:update(sleeve_card, 0)
assert(G.jokers.config.card_limit == 4 and G.consumeables.config.card_limit == 4,
    'Removing either card type must free a slot for both types')

G.jokers:change_size(1)
sleeve:update(sleeve_card, 0)
assert(G.jokers.config.card_limit == 5 and G.consumeables.config.card_limit == 5,
    'Native Joker slot upgrades must expand the combined pool')

G.GAME.consumeable_buffer = 1
sleeve:update(sleeve_card, 0)
assert(G.jokers.config.card_limit == 4,
    'Pending Consumables must reserve shared capacity')
G.GAME.consumeable_buffer = 0
sleeve:update(sleeve_card, 0)

local second_sleeve = {
    ability = { name = 'Card Sleeve' },
    config = { center = { key = 'j_porkify_cardsleeve' } }
}
G.jokers.cards[#G.jokers.cards + 1] = second_sleeve
sleeve:update(sleeve_card, 0)
assert(G.jokers.config.card_limit == 5 and G.consumeables.config.card_limit == 4,
    'Additional Card Sleeves must share slots without stacking the ability')

sleeve_card.debuff = true
sleeve:remove_from_deck(sleeve_card, true)
assert(Porkify_card_sleeve_shared_slots_active(),
    'One active copy must preserve shared slots')
second_sleeve.debuff = true
sleeve:remove_from_deck(second_sleeve, true)
assert(not Porkify_card_sleeve_shared_slots_active())
assert(G.jokers.config.card_limit == 6 and G.consumeables.config.card_limit == 2,
    'Disabling every copy must restore native area limits')

second_sleeve.debuff = nil
sleeve:add_to_deck(second_sleeve, true)
assert(Porkify_card_sleeve_shared_slots_active())
assert(G.jokers.config.card_limit == 5 and G.consumeables.config.card_limit == 4,
    'Removing a debuff must restore the shared pool')

assert(Porkify_card_sleeve_empty_slots(nil) == 1,
    'Shared empty-slot reporting must count the combined pool once')

print('Card Sleeve shared-slot lifecycle checks passed')
