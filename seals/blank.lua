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
            [2] = "as any {C:attention}rank{}",
            [3] = "{C:inactive,s:0.75}(Max. 2 Blank Seals{}",
            [4] = "{C:inactive,s:0.75}per Hand){}"
        }
    },
    credit_badges = {
        { text = "Art: doggfly", colour = "59A487" }
    }
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
local porkify_blank_rank_choices = { 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14 }

local function porkify_is_blank_seal(card)
    if not card then
        return false
    end
    if card.debuff then
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

local function porkify_blank_card_suit(card)
    return (card and card.base and card.base.suit) or "_"
end

local function porkify_blank_all_same_suit(cards)
    local first_suit = nil

    for _, card in ipairs(cards or {}) do
        local suit = porkify_blank_card_suit(card)
        if not first_suit then
            first_suit = suit
        elseif suit ~= first_suit then
            return false
        end
    end

    return first_suit ~= nil
end

local function porkify_blank_get_fixed_rank_counts(cards)
    local counts = {}

    for _, card in ipairs(cards or {}) do
        if not porkify_is_blank_seal(card) then
            local rank = card and card.get_id and porkify_blank_card_get_id_ref(card)
            if rank then
                counts[rank] = (counts[rank] or 0) + 1
            end
        end
    end

    return counts
end

local function porkify_blank_apply_target_counts(blank_cards, fixed_counts, target_counts)
    local deficits = {}
    local needed = 0

    for rank, count in pairs(fixed_counts) do
        if count > (target_counts[rank] or 0) then
            return false
        end
    end

    for rank, count in pairs(target_counts) do
        local deficit = count - (fixed_counts[rank] or 0)
        if deficit < 0 then
            return false
        end
        if deficit > 0 then
            deficits[#deficits + 1] = { rank = rank, count = deficit }
            needed = needed + deficit
        end
    end

    if needed ~= #blank_cards then
        return false
    end

    local blank_index = 1
    for _, deficit in ipairs(deficits) do
        for _ = 1, deficit.count do
            porkify_blank_eval_map[blank_cards[blank_index]] = deficit.rank
            blank_index = blank_index + 1
        end
    end

    return true
end

local function porkify_blank_clear_assignments(blank_cards)
    for i = 1, #blank_cards do
        porkify_blank_eval_map[blank_cards[i]] = nil
    end
end

local function porkify_blank_copy_counts(counts)
    local copy = {}
    for rank, count in pairs(counts or {}) do
        copy[rank] = count
    end
    return copy
end

local function porkify_blank_too_many_hand_name()
    return rawget(_G, "PORKIFY_TOO_MANY_BLANKS_HAND_KEY") or "porkify_too_many_blanks"
end

local function porkify_blank_make_safe_eval_table(cards)
    local eval = {}

    for i = 1, #porkify_blank_hand_rank_order do
        eval[porkify_blank_hand_rank_order[i]] = {}
    end

    eval[porkify_blank_too_many_hand_name()] = { cards or {} }
    return eval
end

local function porkify_blank_max_selected()
    return rawget(_G, "PORKIFY_MAX_SELECTED_BLANK_SEALS") or 2
end

local function porkify_blank_limit_is_disabled()
    local fn = rawget(_G, "porkify_blank_limit_disabled")
    if type(fn) == "function" then
        return fn() == true
    end
    return false
end

function Card:get_id()
    if porkify_blank_eval_depth > 0 and porkify_blank_eval_map and porkify_blank_eval_map[self] then
        return porkify_blank_eval_map[self]
    end
    local runtime_override = rawget(_G, "porkify_blank_runtime_rank_override")
    if type(runtime_override) == "function" then
        local overridden_id = runtime_override(self)
        if overridden_id ~= nil then
            return overridden_id
        end
    end
    return porkify_blank_card_get_id_ref(self)
end

function evaluate_poker_hand(cards, ...)
    local extra_args = { ... }
    local blank_cards = {}
    local total_cards = #(cards or {})

    for _, c in ipairs(cards or {}) do
        if porkify_is_blank_seal(c) then
            blank_cards[#blank_cards + 1] = c
        end
    end

    if #blank_cards == 0 then
        return porkify_blank_evaluate_poker_hand_ref(cards, unpack(extra_args))
    end

    if #blank_cards > porkify_blank_max_selected() and not porkify_blank_limit_is_disabled() then
        return porkify_blank_make_safe_eval_table(cards)
    end

    if total_cards ~= 5 then
        local best_results = nil
        local best_index = #porkify_blank_hand_rank_order + 1

        local function try_assignments(i)
            if i > #blank_cards then
                porkify_blank_eval_depth = porkify_blank_eval_depth + 1
                local results = { pcall(porkify_blank_evaluate_poker_hand_ref, cards, unpack(extra_args)) }
                porkify_blank_eval_depth = math.max(porkify_blank_eval_depth - 1, 0)

                local ok = table.remove(results, 1)
                if not ok then
                    error(results[1])
                end

                local hand_index = porkify_blank_best_hand_index(results[1])
                if hand_index < best_index then
                    best_index = hand_index
                    best_results = results
                end
                return
            end

            local current_card = blank_cards[i]
            for _, mapped_id in ipairs(porkify_blank_rank_choices) do
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

    local fixed_counts = porkify_blank_get_fixed_rank_counts(cards)
    local all_same_suit = porkify_blank_all_same_suit(cards)

    local function evaluate_current_assignment()
        porkify_blank_eval_depth = porkify_blank_eval_depth + 1
        local results = { pcall(porkify_blank_evaluate_poker_hand_ref, cards, unpack(extra_args)) }
        porkify_blank_eval_depth = math.max(porkify_blank_eval_depth - 1, 0)

        local ok = table.remove(results, 1)
        if not ok then
            error(results[1])
        end

        return results
    end

    local function try_target_counts(target_counts, desired_hand_name)
        if not porkify_blank_apply_target_counts(blank_cards, fixed_counts, target_counts) then
            porkify_blank_clear_assignments(blank_cards)
            return nil
        end

        local results = evaluate_current_assignment()
        local eval = results[1]
        local hand_index = porkify_blank_best_hand_index(eval)
        porkify_blank_clear_assignments(blank_cards)

        if hand_index <= #porkify_blank_hand_rank_order and porkify_blank_hand_rank_order[hand_index] == desired_hand_name then
            return results
        end

        return nil
    end

    porkify_blank_eval_map = {}

    for _, rank in ipairs(porkify_blank_rank_choices) do
        local target_counts = { [rank] = #cards }
        local result = try_target_counts(target_counts, all_same_suit and "Flush Five" or "Five of a Kind")
        if result then
            porkify_blank_eval_map = nil
            return unpack(result)
        end
    end

    if all_same_suit then
        for _, trip_rank in ipairs(porkify_blank_rank_choices) do
            for _, pair_rank in ipairs(porkify_blank_rank_choices) do
                if trip_rank ~= pair_rank then
                    local result = try_target_counts({
                        [trip_rank] = 3,
                        [pair_rank] = 2
                    }, "Flush House")
                    if result then
                        porkify_blank_eval_map = nil
                        return unpack(result)
                    end
                end
            end
        end
    end

    local straight_sequences = {
        { 10, 11, 12, 13, 14 },
        { 9, 10, 11, 12, 13 },
        { 8, 9, 10, 11, 12 },
        { 7, 8, 9, 10, 11 },
        { 6, 7, 8, 9, 10 },
        { 5, 6, 7, 8, 9 },
        { 4, 5, 6, 7, 8 },
        { 3, 4, 5, 6, 7 },
        { 2, 3, 4, 5, 6 },
        { 14, 2, 3, 4, 5 }
    }

    if all_same_suit then
        for _, straight in ipairs(straight_sequences) do
            local target_counts = {}
            for _, rank in ipairs(straight) do
                target_counts[rank] = (target_counts[rank] or 0) + 1
            end
            local desired_hand = (straight[1] == 10 and straight[5] == 14) and "Royal Flush" or "Straight Flush"
            local result = try_target_counts(target_counts, desired_hand)
            if result then
                porkify_blank_eval_map = nil
                return unpack(result)
            end
        end
    end

    for _, quad_rank in ipairs(porkify_blank_rank_choices) do
        for _, kicker_rank in ipairs(porkify_blank_rank_choices) do
            if quad_rank ~= kicker_rank then
                local result = try_target_counts({
                    [quad_rank] = 4,
                    [kicker_rank] = 1
                }, "Four of a Kind")
                if result then
                    porkify_blank_eval_map = nil
                    return unpack(result)
                end
            end
        end
    end

    for _, trip_rank in ipairs(porkify_blank_rank_choices) do
        for _, pair_rank in ipairs(porkify_blank_rank_choices) do
            if trip_rank ~= pair_rank then
                local result = try_target_counts({
                    [trip_rank] = 3,
                    [pair_rank] = 2
                }, "Full House")
                if result then
                    porkify_blank_eval_map = nil
                    return unpack(result)
                end
            end
        end
    end

    if all_same_suit then
        local target_counts = porkify_blank_copy_counts(fixed_counts)
        target_counts[2] = (target_counts[2] or 0) + #blank_cards
        local result = try_target_counts(target_counts, "Flush")
        if result then
            porkify_blank_eval_map = nil
            return unpack(result)
        end
    end

    if not all_same_suit then
        for _, straight in ipairs(straight_sequences) do
            local target_counts = {}
            for _, rank in ipairs(straight) do
                target_counts[rank] = (target_counts[rank] or 0) + 1
            end
            local result = try_target_counts(target_counts, "Straight")
            if result then
                porkify_blank_eval_map = nil
                return unpack(result)
            end
        end
    end

    for _, trip_rank in ipairs(porkify_blank_rank_choices) do
        for i = 1, #porkify_blank_rank_choices do
            local kicker_a = porkify_blank_rank_choices[i]
            if kicker_a ~= trip_rank then
                for j = i + 1, #porkify_blank_rank_choices do
                    local kicker_b = porkify_blank_rank_choices[j]
                    if kicker_b ~= trip_rank then
                        local result = try_target_counts({
                            [trip_rank] = 3,
                            [kicker_a] = 1,
                            [kicker_b] = 1
                        }, "Three of a Kind")
                        if result then
                            porkify_blank_eval_map = nil
                            return unpack(result)
                        end
                    end
                end
            end
        end
    end

    for i = 1, #porkify_blank_rank_choices do
        local pair_a = porkify_blank_rank_choices[i]
        for j = i + 1, #porkify_blank_rank_choices do
            local pair_b = porkify_blank_rank_choices[j]
            for _, kicker_rank in ipairs(porkify_blank_rank_choices) do
                if kicker_rank ~= pair_a and kicker_rank ~= pair_b then
                    local result = try_target_counts({
                        [pair_a] = 2,
                        [pair_b] = 2,
                        [kicker_rank] = 1
                    }, "Two Pair")
                    if result then
                        porkify_blank_eval_map = nil
                        return unpack(result)
                    end
                end
            end
        end
    end

    for _, pair_rank in ipairs(porkify_blank_rank_choices) do
        for i = 1, #porkify_blank_rank_choices do
            local kicker_a = porkify_blank_rank_choices[i]
            if kicker_a ~= pair_rank then
                for j = i + 1, #porkify_blank_rank_choices do
                    local kicker_b = porkify_blank_rank_choices[j]
                    if kicker_b ~= pair_rank then
                        for k = j + 1, #porkify_blank_rank_choices do
                            local kicker_c = porkify_blank_rank_choices[k]
                            if kicker_c ~= pair_rank then
                                local result = try_target_counts({
                                    [pair_rank] = 2,
                                    [kicker_a] = 1,
                                    [kicker_b] = 1,
                                    [kicker_c] = 1
                                }, "Pair")
                                if result then
                                    porkify_blank_eval_map = nil
                                    return unpack(result)
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    for a = 1, #porkify_blank_rank_choices do
        for b = a + 1, #porkify_blank_rank_choices do
            for c = b + 1, #porkify_blank_rank_choices do
                for d = c + 1, #porkify_blank_rank_choices do
                    for e = d + 1, #porkify_blank_rank_choices do
                        local distinct = {
                            porkify_blank_rank_choices[a],
                            porkify_blank_rank_choices[b],
                            porkify_blank_rank_choices[c],
                            porkify_blank_rank_choices[d],
                            porkify_blank_rank_choices[e]
                        }
                        local target_counts = {}
                        for _, rank in ipairs(distinct) do
                            target_counts[rank] = 1
                        end
                        local result = try_target_counts(target_counts, "High Card")
                        if result then
                            porkify_blank_eval_map = nil
                            return unpack(result)
                        end
                    end
                end
            end
        end
    end

    porkify_blank_eval_map = nil
    return porkify_blank_evaluate_poker_hand_ref(cards, unpack(extra_args))
end
