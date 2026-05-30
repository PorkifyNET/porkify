SMODS.Enhancement {
    key = 'emerald',
    pos = { x = 8, y = 0 },
    config = {
        extra = {
            xmult = 3,
            odds = 4
        }
    },
    loc_txt = {
        name = 'Emerald',
        text = {
            [1] = '{C:green}#1# in #2#{} chance to',
            [2] = 'get {X:red,C:white}X#3#{} Mult'
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
        local extra = (card and card.ability and card.ability.extra) or (self.config and self.config.extra) or {}
        local odds = extra.odds or 4
        local xmult = extra.xmult or 3
        local numerator, denominator = SMODS.get_probability_vars(card, 1, odds, 'm_porkify_emerald')
        return { vars = { numerator, denominator, xmult } }
    end,

    calculate = function(self, card, context)
        if context.main_scoring and context.cardarea == G.play then
            local extra = (card and card.ability and card.ability.extra) or (self.config and self.config.extra) or {}
            if SMODS.pseudorandom_probability(card, 'group_emerald_enhancement', 1, extra.odds or 4, 'm_porkify_emerald', false) then
                return {
                    Xmult = extra.xmult or 3
                }
            end
        end
    end
}
