SMODS.Blind{
    key = "evens",
    atlas = "CustomBlinds",
    pos = { x = 0, y = 3 },
    boss = { min = 2 },
    boss_colour = HEX("AA0000"),
    mult = 2,
    dollars = 5,
    loc_txt = {
        name = "The Evens",
        text = {
            [1] = "Even-ranked cards",
            [2] = "are debuffed"
        }
    },

    recalc_debuff = function(self, card, from_blind)
        local id = card and card.get_id and card:get_id()
        return id == 2 or id == 4 or id == 6 or id == 8 or id == 10
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
