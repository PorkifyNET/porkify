SMODS.Enhancement {
    key = 'mimic',
    pos = { x = 1, y = 1 },
    loc_txt = {
        name = 'Mimic',
        text = {
            [1] = 'Retrigger full scoring of',
            [2] = 'the card to the {C:attention}left{}',
            [3] = '{C:inactive,s:0.75}(Always scores if possible){}'
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
        return
    end
}
