-- Secret hands use the usual contained-hand rules: unrelated kickers do not score.
-- Bulwark and Yes deliberately require the entire played hand to qualify.
PORKIFY_SECRET_HANDS = {}
local rank_group_cache = setmetatable({}, {__mode = 'k'})

local function cached_rank_groups(hand)
    local signature = {}
    for i, card in ipairs(hand) do
        signature[i] = tostring(card:get_id()) .. ':' .. (card.debuff and '1' or '0')
    end
    signature = table.concat(signature, '|')
    local cached = rank_group_cache[hand]
    if cached and cached.signature == signature then return cached.groups end

    local groups = get_X_same(2, hand, true)
    table.sort(groups, function(a, b) return #a > #b end)
    rank_group_cache[hand] = {signature = signature, groups = groups}
    return groups
end

local function rank_groups(hand, sizes)
    local groups = cached_rank_groups(hand)
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

-- Mixed rank groups, and same-suit versions of the expanded vanilla hands.
local grouped_hands = {
    { 'double_trouble', 'Double Trouble', { 3, 3 }, 95, 7, 30, 3 },
    { 'four_plus_two', 'Four Plus Two', { 4, 2 }, 100, 8, 35, 3 },
    { 'boarding_house', 'Boarding House', { 4, 3 }, 130, 9, 40, 3 },
    { 'five_plus_two', 'Five Plus Two', { 5, 2 }, 155, 10, 45, 3 },
    { 'apartment_block', 'Apartment Block', { 4, 2, 2 }, 170, 11, 50, 4 },
    { 'mansion', 'Mansion', { 5, 3 }, 210, 12, 55, 4 },
    { 'six_plus_two', 'Six Plus Two', { 6, 2 }, 250, 13, 60, 4 },
    { 'flush_three_pair', 'Flush Three Pair', { 2, 2, 2 }, 140, 10, 40, 3 },
    { 'flush_four_pair', 'Flush Four Pair', { 2, 2, 2, 2 }, 230, 14, 55, 4 },
    { 'flush_fuller_house', 'Flush Fuller House', { 3, 2, 2 }, 240, 15, 60, 4 },
    { 'flush_fullest_house', 'Flush Fullest House', { 3, 3, 2 }, 320, 18, 70, 5 },
    { 'flush_two_by_fours', 'Flush Two By Fours', { 4, 4 }, 370, 20, 80, 5 },
}
for _, spec in ipairs(grouped_hands) do
    local key, name, sizes = spec[1], spec[2], spec[3]
    local flush = key:sub(1, 6) == 'flush_'
    local ranks, groups = {}, {}
    local example_ranks = { 'K', '9', '4', '2' }
    local group_names = { [2] = 'a Pair', [3] = 'Three of a Kind', [4] = 'Four of a Kind',
        [5] = 'Five of a Kind', [6] = 'Six of a Kind' }
    for i, size in ipairs(sizes) do
        groups[#groups + 1] = group_names[size]
        for j = 1, size do ranks[#ranks + 1] = example_ranks[i] end
    end
    local description = { table.concat(groups, ' + '), 'Each group has a different rank' }
    if flush then description[#description + 1] = 'All sharing the same suit' end
    register(key, name, spec[4], spec[5], spec[6], spec[7], description, example(ranks, flush),
        function(hand)
            if flush then
                return suited(hand, function(cards) return rank_groups(cards, sizes) end)
            end
            return rank_groups(hand, sizes)
        end)
end

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
