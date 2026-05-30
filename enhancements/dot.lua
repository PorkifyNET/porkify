SMODS.Enhancement {
    key = 'dot',
    pos = { x = 7, y = 0 },
    config = {
        extra = {
            xmult = 2
        }
    },
    loc_txt = {
        name = 'Dot',
        text = {
            [1] = '{X:red,C:white}X2{} Mult if this card is',
            [2] = 'the {C:attention}last{} one scored',
            [3] = 'in played hand'
        }
    },
    atlas = 'CustomEnhancements',
    any_suit = false,
    replace_base_card = false,
    no_rank = false,
    no_suit = false,
    always_scores = false,
    unlocked = true,
    discovered = false,
    no_collection = false,
    weight = 5,

    calculate = function(self, card, context)
        if context.main_scoring and context.cardarea == G.play then
            local scoring_hand = context.scoring_hand or {}
            if scoring_hand[#scoring_hand] == card then
                return {
                    Xmult = (card.ability.extra and card.ability.extra.xmult) or 2
                }
            end
        end
    end
}
