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
            [1] = '{X:red,C:white}X2{} Mult if this is the',
            [2] = '{C:attention}lowest{} rank in played hand',
            [3] = '{C:inactive}(Rightmost if tied){}'
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
            local lowest_rank = math.huge

            for i = 1, #scoring_hand do
                local scoring_card = scoring_hand[i]
                local rank = scoring_card and scoring_card.get_id and scoring_card:get_id()

                if rank and rank < lowest_rank then
                    lowest_rank = rank
                end
            end

            local target_card = nil

            for i = 1, #scoring_hand do
                local scoring_card = scoring_hand[i]
                local rank = scoring_card and scoring_card.get_id and scoring_card:get_id()
                local enhancements = (SMODS and SMODS.get_enhancements and SMODS.get_enhancements(scoring_card)) or {}

                if rank == lowest_rank and enhancements.m_porkify_dot then
                    target_card = scoring_card
                end
            end

            if target_card == card then
                return {
                    Xmult = (card.ability.extra and card.ability.extra.xmult) or 2
                }
            end
        end
    end
}
