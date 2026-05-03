SMODS.Blind{
    key = "rust",
    atlas = "CustomBlinds",
    pos = { x = 0, y = 9 },
    boss = { min = 2 },
    boss_colour = HEX("AA5500"),
    mult = 2,
    dollars = 5,
    loc_txt = {
        name = "The Rust",
        text = {
            [1] = "All Enhanced cards",
            [2] = "are debuffed"
        }
    },

    recalc_debuff = function(self, card, from_blind)
        if not card then
            return false
        end
        if SMODS and SMODS.get_enhancements then
            local enhancements = SMODS.get_enhancements(card) or {}
            return next(enhancements) ~= nil
        end
        return card.config and card.config.center and card.config.center.set == 'Enhanced'
    end,

    in_pool = function(self)
        local ante = (G and G.GAME and G.GAME.round_resets and G.GAME.round_resets.ante) or 1
        return ante >= ((self.boss and self.boss.min) or 1)
    end
}
