SMODS.Blind{
    key = "tax",
    atlas = "CustomBlinds",
    pos = { x = 0, y = 10 },
    boss = { min = 3 },
    boss_colour = HEX("FFFF00"),
    mult = 2,
    dollars = 5,
    loc_txt = {
        name = "The Tax",
        text = {
            [1] = "Discarding a hand costs",
            [2] = "both a Hand and a Discard"
        }
    },

    calculate = function(self, card, context)
        if not context.pre_discard then
            return
        end

        if context.blind_disabled or context.blind_defeated or (G and G.GAME and G.GAME.blind and G.GAME.blind.disabled) then
            return
        end

        local hands_left = (G.GAME and G.GAME.current_round and G.GAME.current_round.hands_left) or 0
        if hands_left > 0 then
            ease_hands_played(-1)
        end
    end,

    in_pool = function(self)
        local ante = (G and G.GAME and G.GAME.round_resets and G.GAME.round_resets.ante) or 1
        return ante >= ((self.boss and self.boss.min) or 1)
    end
}
