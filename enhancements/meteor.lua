
SMODS.Enhancement {
    key = 'meteor',
    pos = { x = 0, y = 0 },
    config = {
        extra = {
            levels0 = 1
        }
    },
    loc_txt = {
        name = 'Meteor',
        text = {
            [1] = 'Increase {C:planet}level{} of played',
            [2] = '{C:purple}Poker Hand{}',
            [3] = '{C:inactive}(Always scores){}'
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
    calculate = function(self, card, context)
        if context.main_scoring and context.cardarea == G.play then
            local target_hand
            target_hand = context.scoring_name or "High Card"
            return {
                level_up = 1,
                level_up_hand = target_hand,
                message = localize('k_level_up_ex')
            }
        end
    end
}
