-- Secret hands use the usual contained-hand rules: unrelated kickers do not score.
-- Bulwark and Yes deliberately require the entire played hand to qualify.
PORKIFY_SECRET_HANDS = {}
local function rank_groups(hand, sizes)
    local groups = get_X_same(2, hand, true)
    table.sort(groups, function(a, b) return #a > #b end)
    if #groups < #sizes then return {} end

    local scoring = {}
    for i, size in ipairs(sizes) do
        if #groups[i] < size then return {} end
        for _, card in ipairs(groups[i]) do
            scoring[#scoring + 1] = card
        end
    end
    return { scoring }
end

local function straight(hand, length)
    -- Keep the requested six/seven/eight ranks even with Four Fingers.
    return get_straight(hand, length, SMODS.shortcut(), SMODS.wrap_around_straight())
end

local function suited(hand, evaluate)
    local results = {}
    for _, suit in ipairs(SMODS.Suit.obj_buffer) do
        local cards = {}
        for _, card in ipairs(hand) do
            if card:is_suit(suit, nil, true) then
                cards[#cards + 1] = card
            end
        end
        for _, match in ipairs(evaluate(cards)) do
            results[#results + 1] = match
        end
    end
    table.sort(results, function(a, b) return #a > #b end)
    return results
end

local function example(ranks, flush, stone)
    local cards, suits = {}, { 'S', 'H', 'C', 'D' }
    for i, rank in ipairs(ranks) do
        cards[i] = { (flush and 'S' or suits[(i - 1) % 4 + 1]) .. '_' .. rank, true }
        if stone then cards[i].enhancement = 'm_stone' end
    end
    return cards
end

local function register(key, name, chips, mult, l_chips, l_mult, description, cards, evaluate)
    PORKIFY_SECRET_HANDS['porkify_' .. key] = true
    SMODS.PokerHand {
        key = key,
        visible = false,
        chips = chips,
        mult = mult,
        l_chips = l_chips,
        l_mult = l_mult,
        example = cards,
        loc_txt = { name = name, description = description },
        evaluate = function(parts, hand) return evaluate(hand) end,
    }
end

register('three_pair', 'Three Pair', 50, 4, 25, 2,
    { '3 pairs of different ranks' },
    example({ 'K', 'K', '9', '9', '4', '4' }),
    function(hand) return rank_groups(hand, { 2, 2, 2 }) end)

register('four_pair', 'Four Pair', 80, 6, 35, 3,
    { '4 pairs of different ranks' },
    example({ 'K', 'K', '9', '9', '4', '4', '2', '2' }),
    function(hand) return rank_groups(hand, { 2, 2, 2, 2 }) end)

local straight_names = { 'Straighter', 'Straightest', 'Straighterest' }
local straight_keys = { 'straighter', 'straightest', 'straighterest' }
local flush_names = { 'Flushier', 'Flushiest', 'Flushiester' }
local flush_keys = { 'flushier', 'flushiest', 'flushiester' }
for i = 1, 3 do
    local length = i + 5
    local ranks = {}
    for rank = 2, length + 1 do ranks[#ranks + 1] = tostring(rank) end
    local flush_ranks, flush_example = { '2', '4', '6', '8', 'T', 'Q', 'A', '3' }, {}
    for j = 1, length do flush_example[j] = flush_ranks[j] end

    register(straight_keys[i], straight_names[i], 30 + 30 * i, 4 + i, 30 + 10 * i, 3 + i,
        { length .. ' consecutive ranks' }, example(ranks),
        function(hand) return straight(hand, length) end)

    register(flush_keys[i], flush_names[i], 35 + 35 * i, 4 + i, 15 + 10 * i, 2 + i,
        { length .. ' cards sharing the same suit' },
        example(flush_example, true),
        function(hand)
            return suited(hand, function(cards)
                if #cards >= length then return { cards } end
                return {}
            end)
        end)

    -- Keep the existing keys so hand levels and achievement history survive the rename.
    local flush_name = straight_names[i] .. ' ' .. flush_names[i]
    register(straight_keys[i] .. '_flush', flush_name, 100 + 50 * i, 8 + 2 * i, 40 + 20 * i, 4 + i,
        { length .. ' consecutive ranks,', 'all sharing the same suit' }, example(ranks, true),
        function(hand)
            return suited(hand, function(cards) return straight(cards, length) end)
        end)
end

register('two_by_fours', 'Two By Fours', 220, 12, 60, 4,
    { '2 Four of a Kinds', 'of different ranks' },
    example({ 'K', 'K', 'K', 'K', '9', '9', '9', '9' }),
    function(hand) return rank_groups(hand, { 4, 4 }) end)

register('fuller_house', 'Fuller House', 100, 9, 40, 3,
    { 'Three of a Kind and 2 pairs,', 'each of a different rank' },
    example({ 'K', 'K', 'K', '9', '9', '4', '4' }),
    function(hand) return rank_groups(hand, { 3, 2, 2 }) end)

register('fullest_house', 'Fullest House', 160, 10, 50, 4,
    { '2 Three of a Kinds and a pair,', 'each of a different rank' },
    example({ 'K', 'K', 'K', '9', '9', '9', '4', '4' }),
    function(hand) return rank_groups(hand, { 3, 3, 2 }) end)

local kind_names = { 'Six', 'Seven', 'Eight' }
local kind_keys = { 'six', 'seven', 'eight' }
for i = 1, 3 do
    local count = i + 5
    local ranks = {}
    for j = 1, count do ranks[j] = 'A' end

    register(kind_keys[i] .. '_of_a_kind', kind_names[i] .. ' of a Kind',
        120 + 60 * i, 12 + 4 * i, 35 + 15 * i, 3 + i,
        { count .. ' cards of the same rank' }, example(ranks),
        function(hand) return get_X_same(count, hand, true) end)

    register('flush_' .. kind_keys[i], 'Flush ' .. kind_names[i],
        160 + 100 * i, 16 + 4 * i, 50 + 20 * i, 3 + i,
        { count .. ' cards of the same rank and suit' }, example(ranks, true),
        function(hand)
            return suited(hand, function(cards) return get_X_same(count, cards, true) end)
        end)
end

register('bulwark', 'Bulwark', 100, 5, 30, 2,
    { 'Play at least 5 cards,', 'all without a suit or rank' },
    example({ 'K', '9', '7', '4', '2' }, false, true),
    function(hand)
        if #hand < 5 then return {} end
        for _, card in ipairs(hand) do
            if not SMODS.has_no_rank(card) or not SMODS.has_no_suit(card) then return {} end
        end
        return { hand }
    end)

register('yes', 'Yes', 1000, 100, 100, 10,
    { 'Play your entire deck', 'in a single hand' },
    example({ 'A', 'K', 'Q', 'J', 'T', '9', '8', '7' }),
    function(hand)
        local deck = G and G.playing_cards
        if not deck or #hand == 0 or #hand ~= #deck then return {} end
        local played = {}
        for _, card in ipairs(hand) do played[card] = true end
        for _, card in ipairs(deck) do
            if not played[card] then return {} end
            played[card] = nil
        end
        return { hand }
    end)
