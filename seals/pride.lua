local function porkify_cards_share_rank_and_suit(a, b)
    if not (a and b and a.base and b.base and a.base.value and b.base.value) then
        return false
    end
    if a.base.value ~= b.base.value then
        return false
    end

    local suits = { "Spades", "Hearts", "Clubs", "Diamonds" }
    for i = 1, #suits do
        local suit = suits[i]
        if a:is_suit(suit) and b:is_suit(suit) then
            return true
        end
    end

    return false
end

SMODS.Seal {
    key = "pride",
    atlas = "CustomSeals",
    pos = { x = 1, y = 0 },
    badge_colour = HEX("F36AA5"),
    discovered = false,
    unlocked = true,
    loc_txt = {
        name = "Pride Seal",
        label = "Pride Seal",
        text = {
            [1] = "{X:red,C:white}X2{} Mult if a played",
            [2] = "card shares this card's ",
            [3] = "{C:attention}rank{} and {C:attention}suit{}",
            [4] = "{C:inactive}(Must be held in hand){}"
        }
    },

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.hand and not context.end_of_round then
            local held_card = context.other_card
            for _, played_card in ipairs(context.scoring_hand or {}) do
                if porkify_cards_share_rank_and_suit(held_card, played_card) then
                    return {
                        Xmult = 2
                    }
                end
            end
        end
    end
}
