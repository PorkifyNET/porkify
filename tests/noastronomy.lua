local challenge

SMODS = {
    Challenge = function(def) challenge = def end,
}

G = {
    GAME = {
        planet_rate = 4,
        tarot_rate = 4,
    },
}

function HEX(value) return value end

dofile(TEST_ROOT .. '/challenges/noastronomy.lua')

assert(challenge and challenge.key == 'noastronomy')
assert(type(challenge.apply) == 'function')

challenge:apply()

assert(G.GAME.planet_rate == 0,
    'No Astronomy must disable Planet cards in the shop')
assert(G.GAME.tarot_rate == 4,
    'No Astronomy must preserve unrelated shop rates')

print('No Astronomy disables the Planet shop rate')
