local debuffed_hands = {
    porkify_flush_three_pair = true,
    porkify_flush_four_pair = true,
    porkify_flush_fuller_house = true,
    porkify_flush_fullest_house = true,
    porkify_flush_two_by_fours = true,

    ['Flush'] = true,
    ['Straight Flush'] = true,
    ['Royal Flush'] = true,
    ['Flush House'] = true,
    ['Flush Five'] = true,
    porkify_flushier = true,
    porkify_flushiest = true,
    porkify_flushiester = true,
    porkify_straighter_flush = true,
    porkify_straightest_flush = true,
    porkify_straighterest_flush = true,
    porkify_flush_six = true,
    porkify_flush_seven = true,
    porkify_flush_eight = true,
}

SMODS.Blind{
    key = "plunger",
    atlas = "CustomBlinds",
    pos = { x = 0, y = 12 },
    boss = { min = 2 },
    boss_colour = HEX("5555AA"),
    mult = 2,
    dollars = 5,
    loc_txt = {
        name = "The Plunger",
        text = {
            [1] = "All played Flushes",
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
