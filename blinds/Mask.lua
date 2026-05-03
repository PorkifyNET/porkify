SMODS.Blind{
    key = "mask",
    atlas = "CustomBlinds",
    pos = { x = 0, y = 6 },
    boss = { min = 2 },
    boss_colour = HEX("000055"),
    mult = 2,
    dollars = 5,
    loc_txt = {
        name = "The Mask",
        text = {
            [1] = "Hand must contain",
            [2] = "a Face card"
        }
    },

    debuff_hand = function(self, cards, hand, handname, check)
        for _, card in ipairs(cards or {}) do
            if card and card.is_face and card:is_face() then
                return false
            end
        end
        return true
    end,

    in_pool = function(self)
        local ante = (G and G.GAME and G.GAME.round_resets and G.GAME.round_resets.ante) or 1
        return ante >= ((self.boss and self.boss.min) or 1)
    end
}
