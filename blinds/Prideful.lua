SMODS.Blind{
    key = "prideful",
    atlas = "CustomBlinds",
    pos = { x = 0, y = 5 },
    boss = { min = 2 },
    boss_colour = HEX("FF0095"),
    mult = 2,
    dollars = 5,
    loc_txt = {
        name = "The Prideful",
        text = {
            [1] = "All played Straights",
            [2] = "are debuffed"
        }
    },

    debuff_hand = function(self, cards, hand, handname, check)
        if handname == "Straight" or handname == "Straight Flush" or handname == "Royal Flush" then
            return true
        end
        return false
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
