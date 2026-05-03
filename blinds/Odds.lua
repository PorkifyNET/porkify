SMODS.Blind{
    key = "odds",
    atlas = "CustomBlinds",
    pos = { x = 0, y = 7 },
    boss = { min = 2 },
    boss_colour = HEX("0055AA"),
    mult = 2,
    dollars = 5,
    loc_txt = {
        name = "The Odds",
        text = {
            [1] = "Odd-ranked cards",
            [2] = "are debuffed"
        }
    },

    recalc_debuff = function(self, card, from_blind)
        local id = card and card.get_id and card:get_id()
        return id == 14 or id == 3 or id == 5 or id == 7 or id == 9
    end,

    set_blind = function(self, reset, silent)
        if not reset then
            Porkify_mark_boss_blind_seen(self.key)
        end
    end,

    in_pool = function(self)
        local ante = (G and G.GAME and G.GAME.round_resets and G.GAME.round_resets.ante) or 1
        return ante >= ((self.boss and self.boss.min) or 1)
            and Porkify_boss_blind_group_available(self.key)
    end
}
