
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
            [2] = 'every {C:money}$3{} you have',
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

    credit_badges = {
        { text = "Art: ButterStutter", colour = "59A487" }
     },
    
    loc_vars = function(self, info_queue, card)
        return {vars = {math.floor((G.GAME.dollars or 0) / 3)}}
    end,
    calculate = function(self, card, context)
        if context.main_scoring and context.cardarea == G.play then
            return {
                mult = math.floor((G.GAME.dollars or 0) / 3)
            }
        end
    end
}