local definition
SMODS = {
    Back = function(value) definition = value end
}

dofile(TEST_ROOT .. '/decks/white_deck.lua')

assert(definition, 'White Deck must register')
assert(definition.key == 'white_deck')
assert(definition.config.vouchers[1] == 'v_blank',
    'White Deck must start with the Blank Voucher')
assert(definition.pos.x == 7 and definition.pos.y == 1,
    'White Deck must use its custom deck-back sprite')

print('White Deck starting Voucher checks passed')
