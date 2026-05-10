SMODS.Joker{ --Cerberus
    key = "cerberus",
    config = {
        extra = {}
    },
    loc_txt = {
        ['name'] = 'Cerberus',
        ['text'] = {
            [1] = '{C:attention}Kings{}, {C:attention}Queens{}, and {C:attention}Jacks{}',
            [2] = 'can be used {C:attention}interchangeably{}'
        }
    },
    pos = {
        x = 7,
        y = 6
    },
    display_size = {
        w = 71,
        h = 95
    },
    cost = 6,
    rarity = 2,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["porkify_porkify_jokers"] = true },

    credit_badges = {
        { text = "Art: u/Ghhnu_", colour = "FF4500" }
     },

    calculate = function(self, card, context)
    end,

	joker_display_def = function(JokerDisplay)
	  return {
		reminder_text = {
			{ text = "(J, Q, K)", colour = G.C.GREY }
		}
	  }
	end
}

local porkify_card_get_id_ref = Card.get_id
local porkify_royalcourt_eval_depth = 0
local porkify_royalcourt_eval_map = nil

function Card:get_id()
    local id = porkify_card_get_id_ref(self)
    if porkify_royalcourt_eval_depth > 0 and porkify_royalcourt_eval_map and porkify_royalcourt_eval_map[self] then
        return porkify_royalcourt_eval_map[self]
    end
    return id
end

local porkify_evaluate_poker_hand_ref = evaluate_poker_hand
local porkify_hand_rank_order = {
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

local function porkify_best_hand_index(eval)
    if not eval then
        return #porkify_hand_rank_order
    end

    for i, hand_name in ipairs(porkify_hand_rank_order) do
        if eval[hand_name] and next(eval[hand_name]) then
            return i
        end
    end

    return #porkify_hand_rank_order
end

function evaluate_poker_hand(cards, ...)
    local extra_args = { ... }
    if next(SMODS.find_card("j_porkify_cerberus")) then
        local face_cards = {}
        for _, c in ipairs(cards or {}) do
            local id = c and c.get_id and porkify_card_get_id_ref(c)
            if id == 11 or id == 12 or id == 13 then
                face_cards[#face_cards + 1] = c
            end
        end

        if #face_cards > 0 then
            local best_results = nil
            local best_index = #porkify_hand_rank_order + 1
            local choices = { 11, 12, 13 }

            local function try_assignments(i)
                if i > #face_cards then
                    porkify_royalcourt_eval_depth = porkify_royalcourt_eval_depth + 1
                    local results = { pcall(porkify_evaluate_poker_hand_ref, cards, unpack(extra_args)) }
                    porkify_royalcourt_eval_depth = math.max(porkify_royalcourt_eval_depth - 1, 0)

                    local ok = table.remove(results, 1)
                    if not ok then
                        error(results[1])
                    end

                    local eval = results[1]
                    local hand_index = porkify_best_hand_index(eval)
                    if hand_index < best_index then
                        best_index = hand_index
                        best_results = results
                    end
                    return
                end

                local current_card = face_cards[i]
                for _, mapped_id in ipairs(choices) do
                    porkify_royalcourt_eval_map[current_card] = mapped_id
                    try_assignments(i + 1)
                end
            end

            porkify_royalcourt_eval_map = {}
            try_assignments(1)
            porkify_royalcourt_eval_map = nil

            if best_results then
                return unpack(best_results)
            end
        end
    end

    return porkify_evaluate_poker_hand_ref(cards, unpack(extra_args))
end
