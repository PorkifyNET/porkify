local debuffed_hands = {
    ['Pair'] = true,
    ['Two Pair'] = true,
    ['Three of a Kind'] = true,
    ['Four of a Kind'] = true,
    ['Five of a Kind'] = true,
    ['Full House'] = true,
    ['Flush House'] = true,
    ['Flush Five'] = true,
    porkify_three_pair = true,
    porkify_four_pair = true,
    porkify_fuller_house = true,
    porkify_fullest_house = true,
    porkify_two_by_fours = true,
    porkify_six_of_a_kind = true,
    porkify_seven_of_a_kind = true,
    porkify_eight_of_a_kind = true,
    porkify_flush_six = true,
    porkify_flush_seven = true,
    porkify_flush_eight = true,
}

SMODS.Blind{
    key = "twins",
    atlas = "CustomBlinds",
    pos = { x = 0, y = 13 },
    boss = { min = 5 },
    boss_colour = HEX("55AA55"),
    mult = 2,
    dollars = 5,
    loc_txt = {
        name = "The Twins",
        text = {
            [1] = "All played Pairs",
            [2] = "are debuffed"
        }
    },

    debuff_hand = function(self, cards, hand, handname, check)
        return debuffed_hands[handname] == true
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
