
SMODS.Enhancement {
    key = 'galaxy',
    pos = { x = 6, y = 0 },
    config = {
        extra = {
            handlevelsaboveone = 0
        }
    },
    loc_txt = {
        name = 'Galaxy',
        text = {
            [1] = '{C:red}+1{} Mult for every',
            [2] = '{C:planet}Planet{} card used',
            [3] = 'this run',
            [4] = '{C:inactive}(Currently{} {C:red}+#1#{} {C:inactive}Mult){}'
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
    return {vars = {(((function() local total_levels = 0; local total_hands = 0; for hand, data in pairs(G.GAME.hands) do if data.level >= to_big(1) then total_hands = total_hands + 1; total_levels = total_levels + data.level end end; return total_levels - total_hands end)() or 0))}}
    end,
    calculate = function(self, card, context)
        if context.main_scoring and context.cardarea == G.play then
            return {
            mult = ((function() local total_levels = 0; local total_hands = 0; for hand, data in pairs(G.GAME.hands) do if data.level >= to_big(1) then total_hands = total_hands + 1; total_levels = total_levels + data.level end end; return total_levels - total_hands end)())
            }
        end
    end
}