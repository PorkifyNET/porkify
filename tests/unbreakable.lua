local definition
local queued_event
local wins = 0

SMODS = {
    Challenge = function(def) definition = def end,
    Joker = function(def) SMODS.tungsten = def end,
}
G = {
    GAME = {
        modifiers = {
            porkify_unbreakable_no_winning_ante = true,
            porkify_unbreakable_destroy_cube = true,
        },
        won = false,
    },
    jokers = { cards = {} },
    E_MANAGER = {
        add_event = function(self, event) queued_event = event end,
    },
}
function HEX(value) return value end
function Event(config) return { config = config } end
function win_game() wins = wins + 1 end

dofile(TEST_ROOT .. '/challenges/unbreakable.lua')
dofile(TEST_ROOT .. '/jokers/tungstencube.lua')

assert(definition and definition.key == 'unbreakable')
assert(definition.rules.custom[1].id == 'porkify_unbreakable_no_winning_ante')
assert(definition.rules.custom[2].id == 'porkify_unbreakable_destroy_cube')
assert(definition.jokers[1].id == 'j_porkify_tungstencube')

local cube = {
    ability = { extra = { dollars = 25 } },
    getting_sliced = true,
}
G.jokers.cards = { cube }
local result = SMODS.tungsten:calculate(cube, {
    joker_type_destroyed = true,
    card = cube,
})
assert(result.dollars == 25 and type(result.func) == 'function')
result.func()
assert(queued_event and queued_event.config.delay == 3)

queued_event.config.func()
assert(not G.GAME.won and wins == 0,
    'Cancelled destruction must not win Unbreakable')

result.func()
cube.getting_sliced = nil
G.jokers.cards = {}
queued_event.config.func()
assert(not G.GAME.won and wins == 0,
    'Selling after cancelled destruction must not win Unbreakable')

G.jokers.cards = { cube }
cube.getting_sliced = true
result.func()
G.jokers.cards = {}
queued_event.config.func()
assert(G.GAME.won and wins == 1,
    'Removing the Tungsten Cube by destruction must win Unbreakable')

local manifest = assert(io.open(TEST_ROOT .. '/lovely.toml', 'r')):read('*a')
assert(manifest:find('modifiers.porkify_unbreakable_no_winning_ante', 1, true),
    'Lovely patch must suppress the normal Ante victory')
assert(manifest:find("ref_value='win_ante'", 1, true),
    'Lovely patch must target the winning Ante HUD value')
assert(manifest:find("text = '--'", 1, true),
    'Unbreakable must display no winning Ante')

print('Unbreakable alternate victory checks passed')
