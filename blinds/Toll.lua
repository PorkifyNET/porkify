SMODS.Blind{
    key = "toll",
    atlas = "CustomBlinds",
    pos = { x = 0, y = 11 },
    boss = { min = 2 },
    boss_colour = HEX("555500"),
    mult = 2,
    dollars = 5,
    loc_txt = {
        name = "The Toll",
        text = {
            [1] = "All probabilities",
            [2] = "will fail"
        }
    },

    recalc_debuff = function(self, card, from_blind)
        if G and G.GAME and G.GAME.current_round and G.GAME.current_round.porkify_toll_probability_backup then
            return
        end
    end,

    set_blind = function(self, reset, silent)
        if reset or not (G and G.GAME and G.GAME.probabilities) then
            return
        end

        G.GAME.current_round = G.GAME.current_round or {}
        if G.GAME.current_round.porkify_toll_probability_backup then
            return
        end

        local backup = {}
        for k, v in pairs(G.GAME.probabilities) do
            backup[k] = v
            G.GAME.probabilities[k] = 0
        end
        G.GAME.current_round.porkify_toll_probability_backup = backup
    end,

    disable = function(self, silent)
        if not (G and G.GAME and G.GAME.probabilities and G.GAME.current_round) then
            return
        end

        local backup = G.GAME.current_round.porkify_toll_probability_backup
        if backup then
            for k, v in pairs(backup) do
                G.GAME.probabilities[k] = v
            end
            G.GAME.current_round.porkify_toll_probability_backup = nil
        end
    end,

    calculate = function(self, card, context)
        if context.blind_disabled or context.blind_defeated then
            if not (G and G.GAME and G.GAME.probabilities and G.GAME.current_round) then
                return
            end

            local backup = G.GAME.current_round.porkify_toll_probability_backup
            if not backup then
                return
            end

            for k, v in pairs(backup) do
                G.GAME.probabilities[k] = v
            end
            G.GAME.current_round.porkify_toll_probability_backup = nil
        end
    end,

    in_pool = function(self)
        local ante = (G and G.GAME and G.GAME.round_resets and G.GAME.round_resets.ante) or 1
        return ante >= ((self.boss and self.boss.min) or 1)
    end
}
