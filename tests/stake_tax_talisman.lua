-- Run after stakes.lua, with Talisman's OmegaNum library and floor wrapper loaded.
function to_big(value) return Big:create(value) end
G.GAME.modifiers.porkify_ante_tax = true
G.GAME.blind.boss = true
G.playing_cards = {}
G.consumeables.cards = {}
for index, case in ipairs({{103, 78}, {3, 3}, {4, 3}, {0, 0}, {-5, -5}}) do
    G.GAME.round = 100 + index
    G.GAME.dollars = to_big(case[1])
    SMODS.calculate_context({end_of_round = true})
    assert(G.GAME.dollars == to_big(case[2]), 'Incorrect Talisman tax result')
    SMODS.calculate_context({end_of_round = true})
    assert(G.GAME.dollars == to_big(case[2]), 'Tax charged twice')
end
G.GAME.round = 200
G.GAME.dollars = to_big('1e400')
SMODS.calculate_context({end_of_round = true})
assert(G.GAME.dollars > to_big(0) and G.GAME.dollars < to_big('1e400'))
print('Sapphire tax passed with Talisman: rounding, zero, debt, repeated contexts and huge balances')
