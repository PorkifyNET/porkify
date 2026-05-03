
SMODS.Enhancement {
    key = 'ancient',
    pos = { x = 5, y = 0 },
    config = {
        extra = {
            currentmoney = 0
        }
    },
    loc_txt = {
        name = 'Ancient',
        text = {
            [1] = '{C:red}+1{} Mult for',
            [2] = 'each {C:money}$1{} you have',
            [3] = '{C:inactive}(Currently{} {C:red}+#1#{} {C:inactive}Mult){}'
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
        return {vars = {(G.GAME.dollars or 0)}}
    end,
    calculate = function(self, card, context)
        if context.main_scoring and context.cardarea == G.play then
            return {
                mult = G.GAME.dollars
            }
        end
    end
}