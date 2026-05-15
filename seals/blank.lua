SMODS.Seal {
    key = "blank",
    atlas = "CustomSeals",
    pos = { x = 0, y = 0 },
    badge_colour = HEX("D8D8D8"),
    discovered = false,
    unlocked = true,
    loc_txt = {
        name = "Blank Seal",
        label = "Blank Seal",
        text = {
            [1] = "Can be used",
            [2] = "as any {C:attention}rank{}"
        }
    }
}

credit_badges = {
    { text = "Art: doggfly", colour = "59A487" }
}

local porkify_blank_card_get_id_ref = Card.get_id
local porkify_blank_eval_depth = 0
local porkify_blank_eval_map = nil
local porkify_blank_evaluate_poker_hand_ref = evaluate_poker_hand
local porkify_blank_hand_rank_order = {
    "Flush Five",
    "Flush House",
    "Five of a Kind",
    "Royal Flush",
    "Straight Flush",
    "Four of a Kind",
    "Full House",
    "Flush",
    "Straight",
    "Three of a Kind",
    "Two Pair",
    "Pair",
    "High Card"
}

local function porkify_is_blank_seal(card)
    if not card then
        return false
    end
    local seal = card.seal or (card.ability and card.ability.seal)
    return seal == "porkify_blank" or seal == "blank"
end

local function porkify_blank_best_hand_index(eval)
    if not eval then
        return #porkify_blank_hand_rank_order
    end

    for i, hand_name in ipairs(porkify_blank_hand_rank_order) do
        if eval[hand_name] and next(eval[hand_name]) then
            return i
        end
    end

    return #porkify_blank_hand_rank_order
end

function Card:get_id()
    if porkify_blank_eval_depth > 0 and porkify_blank_eval_map and porkify_blank_eval_map[self] then
        return porkify_blank_eval_map[self]
    end
    return porkify_blank_card_get_id_ref(self)
end

function evaluate_poker_hand(cards, ...)
    local extra_args = { ... }
    local blank_cards = {}

    for _, c in ipairs(cards or {}) do
        if porkify_is_blank_seal(c) then
            blank_cards[#blank_cards + 1] = c
        end
    end

    if #blank_cards == 0 then
        return porkify_blank_evaluate_poker_hand_ref(cards, unpack(extra_args))
    end

    local best_results = nil
    local best_index = #porkify_blank_hand_rank_order + 1
    local choices = { 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14 }

    local function try_assignments(i)
        if i > #blank_cards then
            porkify_blank_eval_depth = porkify_blank_eval_depth + 1
            local results = { pcall(porkify_blank_evaluate_poker_hand_ref, cards, unpack(extra_args)) }
            porkify_blank_eval_depth = math.max(porkify_blank_eval_depth - 1, 0)

            local ok = table.remove(results, 1)
            if not ok then
                error(results[1])
            end

            local eval = results[1]
            local hand_index = porkify_blank_best_hand_index(eval)
            if hand_index < best_index then
                best_index = hand_index
                best_results = results
            end
            return
        end

        local current_card = blank_cards[i]
        for _, mapped_id in ipairs(choices) do
            porkify_blank_eval_map[current_card] = mapped_id
            try_assignments(i + 1)
        end
        porkify_blank_eval_map[current_card] = nil
    end

    porkify_blank_eval_map = {}
    try_assignments(1)
    porkify_blank_eval_map = nil

    if best_results then
        return unpack(best_results)
    end

    return porkify_blank_evaluate_poker_hand_ref(cards, unpack(extra_args))
end
