SMODS.Enhancement {
    key = 'exclaim',
    pos = { x = 0, y = 1 },
    loc_txt = {
        name = 'Exclaim',
        text = {
            [1] = 'Gives {X:red,C:white}X1{} Mult',
            [2] = 'per card held in hand',
            [3] = 'if this is the {C:attention}last{}',
            [4] = 'scoring card'
        }
    },
    atlas = 'CustomEnhancements',
    any_suit = false,
    replace_base_card = true,
    no_rank = true,
    no_suit = true,
    always_scores = true,
    unlocked = true,
    discovered = false,
    no_collection = false,
    weight = 5,

    loc_vars = function(self, info_queue, card)
        local held_in_hand = #(G and G.hand and G.hand.cards or {})
        return { vars = { held_in_hand } }
    end,

    calculate = function(self, card, context)
        if context.main_scoring and context.cardarea == G.play then
            local scoring_hand = context.scoring_hand or {}
            if scoring_hand[#scoring_hand] ~= card then
                return
            end

            local held_in_hand = #(G and G.hand and G.hand.cards or {})
            return {
                Xmult = held_in_hand
            }
        end
    end
}
