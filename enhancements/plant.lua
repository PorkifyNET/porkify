
SMODS.Enhancement {
    key = 'plant',
    pos = { x = 3, y = 0 },
    config = {
        extra = {
            currentante = 0
        }
    },
    loc_txt = {
        name = 'Plant',
        text = {
            [1] = '{C:blue}+10{} Chips per {C:attention}Ante{}',
            [2] = '{C:inactive}(Currently{} {C:blue}+#1#{} {C:inactive}Chips){}'
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
    loc_vars = function(self, info_queue, card)
        return {vars = {((G.GAME.round_resets.ante or 0)) * 10}}
    end,
    calculate = function(self, card, context)
        if context.main_scoring and context.cardarea == G.play then
            return {
                chips = (G.GAME.round_resets.ante) * 10
            }
        end
    end
}
