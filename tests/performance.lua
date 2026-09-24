local mode = TEST_PERF_MODE
Card = {}
Card.__index = Card
function Card:get_id() return self.base.id end
local function card(id, suit)
    return setmetatable({base = {id = id, suit = suit or 'Spades'}, ability = {},
        config = {center = {key = 'c_base'}}}, Card)
end
G = {jokers = {cards = {}}, handlist = {'High Card'}}
local calls = 0
function evaluate_poker_hand(cards)
    calls = calls + 1
    return {['High Card'] = {cards}}
end
if mode == 'cerberus' then
    local owned = true
    SMODS = {
        Joker = function() end,
        find_card = function() return owned and {{}} or {} end,
    }
    dofile('jokers/cerberus.lua')
    local cards = {card(11), card(12), card(13)}
    evaluate_poker_hand(cards)
    assert(calls == 27, 'Cerberus should evaluate its 27 assignments once')
    evaluate_poker_hand(cards)
    assert(calls == 27, 'Cerberus repeated an unchanged evaluation')
    cards[1].base.id = 10
    evaluate_poker_hand(cards)
    assert(calls == 36, 'Cerberus cache did not invalidate after a rank change')
    owned = false
    evaluate_poker_hand(cards)
    assert(calls == 37, 'Cerberus should bypass its cache when no copy is owned')
    print('Cerberus evaluation cache passed')
else
    SMODS = {
        current_mod = {config = {unlimited_blanks = true}},
        Seal = function() end,
    }
    HEX = function(value) return value end
    porkify_blank_limit_disabled = function() return true end
    dofile('seals/blank.lua')
    local cards = {card(2), card(3), card(4), card(5), card(6), card(10)}
    cards[6].seal = 'porkify_blank'
    evaluate_poker_hand(cards)
    assert(calls == 13, 'Blank Seal should evaluate its 13 assignments once')
    evaluate_poker_hand(cards)
    assert(calls == 13, 'Blank Seal repeated an unchanged evaluation')
    cards[1].base.id = 7
    evaluate_poker_hand(cards)
    assert(calls == 26, 'Blank Seal cache did not invalidate after a rank change')
    PORKIFY_CLOUD9_COUNT_BLANKS = true
    assert(cards[6]:get_id() == 9, 'Cloud 9 did not count a Blank Seal as a 9')
    PORKIFY_CLOUD9_COUNT_BLANKS = nil
    assert(cards[6]:get_id() == 10, 'Cloud 9 rank override leaked')
    print('Blank Seal evaluation cache and Cloud 9 rank override passed')
end
