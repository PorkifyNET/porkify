
SMODS.Enhancement {
    key = 'mirror',
    pos = { x = 4, y = 0 },
    config = {
        extra = {
            xchips0 = 2,
            odds = 7
        }
    },
    loc_txt = {
        name = 'Mirror',
        text = {
            [1] = '{X:blue,C:white}X2{} Chips',
            [2] = '{C:green}#1# in #2#{} chance to',
            [3] = 'destroy card'
        }
    },
    atlas = 'CustomEnhancements',
    any_suit = false,
    shatters = true,
    replace_base_card = false,
    no_rank = false,
    no_suit = false,
    always_scores = false,
    unlocked = true,
    discovered = false,
    no_collection = false,
    weight = 5,

    credit_badges = {
        { text = "Art: Revoo", colour = "59A487" }
     },
    
    loc_vars = function(self, info_queue, card)
        local extra = (card and card.ability and card.ability.extra) or (self.config and self.config.extra) or {}
        local odds = extra.odds or 4
        local numerator, denominator = SMODS.get_probability_vars(card, 1, odds, 'm_porkify_mirror')
        return {vars = {numerator, denominator}}
    end,
    calculate = function(self, card, context)
        if context.destroy_card and context.cardarea == G.play and context.destroy_card == card and card.should_destroy then
            return { remove = true }
        end
        if context.main_scoring and context.cardarea == G.play then
            card.should_destroy = false
            return {
                x_chips = 2
                ,
                func = function()
                    if SMODS.pseudorandom_probability(card, 'group_0_1512b452', 1, card.ability.extra.odds, 'j_mycustom_mirror', false) then
                        context.other_card.should_destroy = true
                        card.should_destroy = true
                        
                    end
                    return true
                end
            }
        end
    end
}
