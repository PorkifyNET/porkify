local Big = {}
Big.__index = Big
function Big.__le(a, b) return a.value <= b.value end
function Big.__lt(a, b) return a.value < b.value end
local function big(value)
    if type(value) == 'table' then return value end
    return setmetatable({value = value}, Big)
end
to_big = big
G = {GAME = {blind = {chips = 8}}}
SMODS = {calculate_round_score = function() return big(10) end}
function evaluate_play_after()
    SMODS.last_hand_score = SMODS.calculate_round_score()
    SMODS.last_hand_oneshot = SMODS.last_hand_score >= G.GAME.blind.chips
    return SMODS.last_hand_oneshot
end
dofile('talisman_compat.lua')
assert(evaluate_play_after() == true)
assert(type(G.GAME.blind.chips) == 'table' and G.GAME.blind.chips.value == 8)
G.GAME.blind.chips = 12
assert(evaluate_play_after() == false)
print('Talisman post-score comparison compatibility passed')
