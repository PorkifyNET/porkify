SMODS.Blind{
    key = "bin",
    atlas = "CustomBlinds",
    pos = { x = 0, y = 0 },
    boss = { min = 2 },
    boss_colour = HEX("AAFFFF"),
    mult = 2,
    dollars = 5,
    loc_txt = {
        name = "The Bin",
        text = {
            [1] = "-2 Discard Size"
        }
    },

    set_blind = function(self, reset, silent)
        if reset then
            return
        end

        G.GAME.current_round = G.GAME.current_round or {}
        if G.GAME.current_round.porkify_bin_discard_backup ~= nil then
            return
        end

        G.GAME.current_round.porkify_bin_discard_backup = G.GAME.starting_params
            and G.GAME.starting_params.discard_limit or 0
        SMODS.change_discard_limit(-2)
    end,

    disable = function(self, silent)
        if not (G and G.GAME and G.GAME.current_round and G.GAME.starting_params) then
            return
        end

        local original_limit = G.GAME.current_round.porkify_bin_discard_backup
        if original_limit ~= nil then
            local current_limit = G.GAME.starting_params.discard_limit or 0
            SMODS.change_discard_limit(original_limit - current_limit)
            G.GAME.current_round.porkify_bin_discard_backup = nil
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
