
SMODS.Enhancement {
    key = 'crumpled',
    pos = { x = 1, y = 0 },
    config = {
        extra = {
            discardsremaining = 1
        }
    },
    loc_txt = {
        name = 'Crumpled',
        text = {
            [1] = '{X:red,C:white}X0.25{} Mult per',
            [2] = 'remaining {C:red}discard{}',
            [3] = '{C:inactive}(Currently{} {X:red,C:white}X#1#{} {C:inactive}Mult){}'
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
        { text = "Art: matressinmylung", colour = "59A487" }
     },
    
    loc_vars = function(self, info_queue, card)
        local extra = (card and card.ability and card.ability.extra) or (self.config and self.config.extra) or {}
        local base = extra.discardsremaining or 1
        return {vars = {base + ((G.GAME.current_round.discards_left or 0) * 0.25)}}
    end,
    calculate = function(self, card, context)
        if context.main_scoring and context.cardarea == G.play then
            local extra = (card and card.ability and card.ability.extra) or (self.config and self.config.extra) or {}
            local base = extra.discardsremaining or 1
            return {
                Xmult = base + ((G.GAME.current_round.discards_left or 0) * 0.25)
            }
        end
    end
}
