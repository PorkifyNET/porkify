-- Minimal game fixtures; get_straight and get_X_same are loaded from the installation.
local hands, checks = {}, 0
G = { handlist = {}, playing_cards = {} }
local shortcut, wrap = false, false
SMODS = {
    Ranks = {}, Rank = { obj_buffer = {}, max_id = { value = 14 } },
    Suit = { obj_buffer = { 'Spades', 'Hearts', 'Clubs', 'Diamonds' } },
    shortcut = function() return shortcut end,
    wrap_around_straight = function() return wrap end,
    has_no_rank = function(card) return card.no_rank end,
    has_no_suit = function(card) return card.no_suit end,
    PokerHand = function(def)
        hands[def.key] = def
        G.handlist[#G.handlist + 1] = 'porkify_' .. def.key
    end,
    Seal = function() end,
}
for rank = 2, 14 do
    local key = tostring(rank)
    SMODS.Rank.obj_buffer[#SMODS.Rank.obj_buffer + 1] = key
    SMODS.Ranks[key] = { id = rank, next = { tostring(rank == 14 and 2 or rank + 1) }, straight_edge = rank == 14 }
end
Card = {}
function Card:get_id() return self.no_rank and -1 or self.base.id end
function Card:is_suit(suit)
    return not self.no_suit and (self.base.suit == suit or (self.wild and not self.debuff))
end
local function card(rank, suit, stone)
    return setmetatable({ base = { id = rank, suit = suit or 'Spades' }, no_rank = stone, no_suit = stone }, { __index = Card })
end
local function hand(ranks, flush)
    local result = {}
    for i, rank in ipairs(ranks) do
        result[i] = card(rank, flush and 'Spades' or SMODS.Suit.obj_buffer[(i - 1) % 4 + 1])
    end
    return result
end
local function check(key, cards, expected)
    local result = hands[key].evaluate({}, cards)
    local actual = result[1] and #result[1] or 0
    assert(actual == expected, key .. ': expected ' .. expected .. ', got ' .. actual)
    if result[1] then
        local allowed, seen = {}, {}
        for _, c in ipairs(cards) do allowed[c] = true end
        for _, c in ipairs(result[1]) do
            assert(allowed[c] and not seen[c], key .. ': invalid scoring card')
            seen[c] = true
        end
    end
    checks = checks + 1
end
dofile(TEST_ROOT .. '/poker_hands.lua')
assert(#G.handlist == 34)
local priorities = {}
for _, def in pairs(hands) do
    assert(def.visible == false and #def.example > 0 and def.l_chips > 0 and def.l_mult > 0)
    local priority = def.chips * def.mult
    assert(not priorities[priority], 'Ambiguous hand priority: ' .. def.key)
    priorities[priority] = true
    check(def.key, {}, 0)
end
check('double_trouble', hand({ 13, 13, 13, 9, 9, 9 }, false), 6)
check('double_trouble', hand({ 13, 13, 13, 9, 9 }, false), 0)
assert(PORKIFY_SECRET_HANDS['porkify_double_trouble'])
check('four_plus_two', hand({ 13, 13, 13, 13, 9, 9 }, false), 6)
check('four_plus_two', hand({ 13, 13, 13, 13, 9 }, false), 0)
assert(PORKIFY_SECRET_HANDS['porkify_four_plus_two'])
check('boarding_house', hand({ 13, 13, 13, 13, 9, 9, 9 }, false), 7)
check('boarding_house', hand({ 13, 13, 13, 13, 9, 9 }, false), 0)
assert(PORKIFY_SECRET_HANDS['porkify_boarding_house'])
check('five_plus_two', hand({ 13, 13, 13, 13, 13, 9, 9 }, false), 7)
check('five_plus_two', hand({ 13, 13, 13, 13, 13, 9 }, false), 0)
assert(PORKIFY_SECRET_HANDS['porkify_five_plus_two'])
check('apartment_block', hand({ 13, 13, 13, 13, 9, 9, 4, 4 }, false), 8)
check('apartment_block', hand({ 13, 13, 13, 13, 9, 9, 4 }, false), 0)
assert(PORKIFY_SECRET_HANDS['porkify_apartment_block'])
check('mansion', hand({ 13, 13, 13, 13, 13, 9, 9, 9 }, false), 8)
check('mansion', hand({ 13, 13, 13, 13, 13, 9, 9 }, false), 0)
assert(PORKIFY_SECRET_HANDS['porkify_mansion'])
check('six_plus_two', hand({ 13, 13, 13, 13, 13, 13, 9, 9 }, false), 8)
check('six_plus_two', hand({ 13, 13, 13, 13, 13, 13, 9 }, false), 0)
assert(PORKIFY_SECRET_HANDS['porkify_six_plus_two'])
check('flush_three_pair', hand({ 13, 13, 9, 9, 4, 4 }, true), 6)
check('flush_three_pair', hand({ 13, 13, 9, 9, 4 }, true), 0)
check('flush_three_pair', hand({ 13, 13, 9, 9, 4, 4 }, false), 0)
assert(PORKIFY_SECRET_HANDS['porkify_flush_three_pair'])
check('flush_four_pair', hand({ 13, 13, 9, 9, 4, 4, 2, 2 }, true), 8)
check('flush_four_pair', hand({ 13, 13, 9, 9, 4, 4, 2 }, true), 0)
check('flush_four_pair', hand({ 13, 13, 9, 9, 4, 4, 2, 2 }, false), 0)
assert(PORKIFY_SECRET_HANDS['porkify_flush_four_pair'])
check('flush_fuller_house', hand({ 13, 13, 13, 9, 9, 4, 4 }, true), 7)
check('flush_fuller_house', hand({ 13, 13, 13, 9, 9, 4 }, true), 0)
check('flush_fuller_house', hand({ 13, 13, 13, 9, 9, 4, 4 }, false), 0)
assert(PORKIFY_SECRET_HANDS['porkify_flush_fuller_house'])
check('flush_fullest_house', hand({ 13, 13, 13, 9, 9, 9, 4, 4 }, true), 8)
check('flush_fullest_house', hand({ 13, 13, 13, 9, 9, 9, 4 }, true), 0)
check('flush_fullest_house', hand({ 13, 13, 13, 9, 9, 9, 4, 4 }, false), 0)
assert(PORKIFY_SECRET_HANDS['porkify_flush_fullest_house'])
check('flush_two_by_fours', hand({ 13, 13, 13, 13, 9, 9, 9, 9 }, true), 8)
check('flush_two_by_fours', hand({ 13, 13, 13, 13, 9, 9, 9 }, true), 0)
check('flush_two_by_fours', hand({ 13, 13, 13, 13, 9, 9, 9, 9 }, false), 0)
assert(PORKIFY_SECRET_HANDS['porkify_flush_two_by_fours'])
check('three_pair', hand({ 2, 2, 3, 3, 4, 4, 9 }), 6)
check('three_pair', hand({ 2, 2, 2, 2, 3, 3 }), 0)
check('four_pair', hand({ 2, 2, 3, 3, 4, 4, 5, 5 }), 8)
check('four_pair', hand({ 2, 2, 3, 3, 4, 4, 5 }), 0)
check('fuller_house', hand({ 2, 2, 2, 3, 3, 4, 4, 9 }), 7)
check('fuller_house', hand({ 2, 2, 2, 3, 3, 3 }), 0)
check('fullest_house', hand({ 2, 2, 2, 3, 3, 3, 4, 4 }), 8)
check('fullest_house', hand({ 2, 2, 2, 3, 3, 4, 4, 9 }), 0)
check('two_by_fours', hand({ 2, 2, 2, 2, 9, 9, 9, 9 }), 8)
check('two_by_fours', hand({ 2, 2, 2, 2, 9, 9, 9, 9, 14 }), 8)
check('two_by_fours', hand({ 2, 2, 2, 2, 2, 9, 9, 9 }), 0)
check('two_by_fours', hand({ 2, 2, 2, 2, 2, 2, 2, 2 }), 0)
check('two_by_fours', hand({ 2, 2, 2, 2, 9, 9, 9 }), 0)
for i, key in ipairs({ 'flushier', 'flushiest', 'flushiester' }) do
    local cards = hand({ 2, 4, 6, 8, 10, 12, 14, 3 }, true)
    while #cards > i + 5 do table.remove(cards) end
    check(key, cards, i + 5)
    cards[#cards + 1] = card(9, 'Hearts')
    check(key, cards, i + 5)
    table.remove(cards, 1)
    check(key, cards, 0)
    cards[#cards].wild = true
    check(key, cards, i + 5)
    cards[#cards].debuff = true
    check(key, cards, 0)
    cards[#cards] = card(2, 'Spades', true)
    check(key, cards, 0)
end
assert(hands.straighter_flush.loc_txt.name == 'Straighter Flushier')
assert(hands.straightest_flush.loc_txt.name == 'Straightest Flushiest')
assert(hands.straighterest_flush.loc_txt.name == 'Straighterest Flushiester')
for i, key in ipairs({ 'straighter', 'straightest', 'straighterest' }) do
    local ranks = {}
    for r = 2, i + 6 do ranks[#ranks + 1] = r end
    check(key, hand(ranks), i + 5)
    check(key .. '_flush', hand(ranks, true), i + 5)
    check(key .. '_flush', hand(ranks), 0)
    ranks[#ranks] = nil
    check(key, hand(ranks), 0)
    check(key .. '_flush', hand(ranks, true), 0)
end
check('straighter', hand({ 14, 2, 3, 4, 5, 6 }), 6)
check('straighter', hand({ 9, 10, 11, 12, 13, 14 }), 6)
check('straighter', hand({ 12, 13, 14, 2, 3, 4 }), 0)
check('straighter', hand({ 2, 3, 4, 5, 6, 6 }), 0)
check('straighter', hand({ 2, 3, 4, 5, 6, 7, 7 }), 7)
shortcut = true
check('straighter', hand({ 2, 4, 6, 8, 10, 12 }), 6)
shortcut = false
wrap = true
check('straighter', hand({ 12, 13, 14, 2, 3, 4 }), 6)
wrap = false
local mismatched = hand({ 2, 3, 4, 5, 6, 7, 9 }, true)
mismatched[6].base.suit = 'Hearts'
check('straighter_flush', mismatched, 0)
mismatched[6].wild = true
check('straighter_flush', mismatched, 6)
mismatched[6].debuff = true
check('straighter_flush', mismatched, 0)
for i, key in ipairs({ 'six', 'seven', 'eight' }) do
    local ranks = {}
    for j = 1, i + 5 do ranks[j] = 14 end
    check(key .. '_of_a_kind', hand(ranks), i + 5)
    check('flush_' .. key, hand(ranks, true), i + 5)
    check('flush_' .. key, hand(ranks), 0)
    ranks[#ranks] = 13
    check(key .. '_of_a_kind', hand(ranks), 0)
    check('flush_' .. key, hand(ranks, true), 0)
end
local stones = {}
for i = 1, 6 do stones[i] = card(2, 'Spades', true) end
check('bulwark', stones, 6)
stones[6] = card(2)
check('bulwark', stones, 0)
stones[6] = nil
check('bulwark', stones, 5)
stones[5].no_suit = false
check('bulwark', stones, 0)
stones[5] = nil
check('bulwark', stones, 0)
local deck = hand({ 2, 3, 4, 5, 6, 7 })
G.playing_cards = deck
check('yes', deck, 6)
check('yes', { deck[1], deck[2], deck[3], deck[4], deck[5] }, 0)
check('yes', hand({ 2, 3, 4, 5, 6, 7 }), 0)
check('yes', { deck[1], deck[2], deck[3], deck[4], deck[5], deck[5] }, 0)
G.playing_cards = { deck[1] }
check('yes', G.playing_cards, 1)

-- Exercise the real Blank Seal wrapper with secret hands in the live hand order.
G.playing_cards = {}
table.sort(G.handlist, function(a, b)
    local x, y = hands[a:sub(9)], hands[b:sub(9)]
    return x.chips * x.mult > y.chips * y.mult
end)
function evaluate_poker_hand(cards)
    local results = {}
    for key, def in pairs(hands) do results['porkify_' .. key] = def.evaluate({}, cards) end
    return results
end
local function best(cards)
    local results = evaluate_poker_hand(cards)
    for _, key in ipairs(G.handlist) do
        if next(results[key]) then return key end
    end
end
assert(best(hand({ 2, 3, 4, 5, 6, 7, 8, 9 }, true)) == 'porkify_straighterest_flush')
assert(best(hand({ 2, 4, 6, 8, 10, 12, 14, 3 }, true)) == 'porkify_flushiester')
assert(best(hand({ 2, 2, 2, 2, 9, 9, 9, 9 })) == 'porkify_two_by_fours')
assert(best(hand({ 14, 14, 14, 14, 14, 14, 14, 14 }, true)) == 'porkify_flush_eight')
assert(best(hand({ 2, 2, 2, 3, 3, 3, 4, 4 })) == 'porkify_fullest_house')
G.playing_cards = hand({ 14, 14, 14, 14, 14, 14, 14, 14 }, true)
assert(best(G.playing_cards) == 'porkify_yes')
G.playing_cards = {}
function HEX(value) return value end
dofile(TEST_ROOT .. '/seals/blank.lua')
local blanks = hand({ 2, 3, 4, 5, 6, 10 })
blanks[6].seal = 'porkify_blank'
assert(#evaluate_poker_hand(blanks).porkify_straighter[1] == 6)
assert(blanks[6]:get_id() == 10, 'Blank Seal rank leaked outside evaluation')
blanks = hand({ 9, 9, 9, 9, 9, 2 }, true)
blanks[6].seal = 'porkify_blank'
assert(#evaluate_poker_hand(blanks).porkify_flush_six[1] == 6)
blanks[4].seal, blanks[5].seal = 'porkify_blank', 'porkify_blank'
local blocked = evaluate_poker_hand(blanks)
assert(blocked.porkify_too_many_blanks[1] == blanks)
for key in pairs(hands) do assert(#blocked['porkify_' .. key] == 0) end
print('Passed ' .. checks .. ' evaluator cases, 34 registrations, and Blank Seal integration checks.')
