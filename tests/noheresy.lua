local challenge

SMODS = {
    Challenge = function(def) challenge = def end,
}

G = {
    GAME = {
        tarot_rate = 4,
        spectral_rate = 2,
        planet_rate = 4,
    },
}

function HEX(value) return value end

dofile(TEST_ROOT .. '/challenges/noheresy.lua')

assert(challenge and challenge.key == 'noheresy')
assert(type(challenge.apply) == 'function')

challenge:apply()

assert(G.GAME.tarot_rate == 0,
    'No Heresy must disable Tarot cards in the shop')
assert(G.GAME.spectral_rate == 0,
    'No Heresy must disable Spectral cards in the shop')
assert(G.GAME.planet_rate == 4,
    'No Heresy must preserve unrelated shop rates')

print('No Heresy disables Tarot and Spectral shop rates')
