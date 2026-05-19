SMODS.Blind{
    key = "finger",
    atlas = "CustomBlinds",
    pos = { x = 0, y = 4 },
    boss = { min = 5 },
    boss_colour = HEX("FF55AA"),
    mult = 2,
    dollars = 5,
    loc_txt = {
        name = "The Finger",
        text = {
            [1] = "-1 Play Size"
        }
    },

    set_blind = function(self, reset, silent)
        if reset then
            return
        end

        G.GAME.current_round = G.GAME.current_round or {}
        if G.GAME.current_round.porkify_finger_play_size_applied then
            return
        end

        G.GAME.current_round.porkify_finger_play_size_applied = true
        SMODS.change_play_limit(-1)
    end,

    disable = function(self, silent)
        if not (G and G.GAME and G.GAME.current_round) then
            return
        end

        if G.GAME.current_round.porkify_finger_play_size_applied then
            SMODS.change_play_limit(1)
            G.GAME.current_round.porkify_finger_play_size_applied = nil
        end
    end,

    calculate = function(self, card, context)
        if context.blind_disabled or context.blind_defeated then
            self:disable()
        end
    end,

    in_pool = function(self)
        local ante = (G and G.GAME and G.GAME.round_resets and G.GAME.round_resets.ante) or 1
        return ante >= ((self.boss and self.boss.min) or 1)
    end
}
