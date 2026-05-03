SMODS.Blind{
    key = "ceiling",
    atlas = "CustomBlinds",
    pos = { x = 0, y = 1 },
    boss = { min = 0 },
    boss_colour = HEX("FFAA55"),
    mult = 2,
    dollars = 0,
    loc_txt = {
        name = "The Ceiling",
        text = {
            [1] = "No Blind Rewards",
            [2] = "and no Interest"
        }
    },

    set_blind = function(self, reset, silent)
        if reset or not (G and G.GAME) then
            return
        end

        G.GAME.modifiers = G.GAME.modifiers or {}
        if G.GAME.current_round and G.GAME.current_round.porkify_ceiling_no_interest_applied ~= nil then
            return
        end

        G.GAME.current_round = G.GAME.current_round or {}
        G.GAME.current_round.porkify_ceiling_no_interest_applied = not G.GAME.modifiers.no_interest
        G.GAME.modifiers.no_interest = true
    end,

    disable = function(self, silent)
        if not (G and G.GAME and G.GAME.modifiers and G.GAME.current_round) then
            return
        end

        local applied = G.GAME.current_round.porkify_ceiling_no_interest_applied
        if applied ~= nil then
            if applied then
                G.GAME.modifiers.no_interest = nil
            end
            G.GAME.current_round.porkify_ceiling_no_interest_applied = nil
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
