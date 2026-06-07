SMODS.Blind{
    key = "pyre",
    atlas = "CustomBlinds",
    pos = { x = 0, y = 8 },
    boss = { min = 4 },
    boss_colour = HEX("FFAA00"),
    mult = 2,
    dollars = 5,
    loc_txt = {
        name = "The Pyre",
        text = {
            [1] = "All cards in the first hand",
            [2] = "of the round are destroyed"
        }
    },

    set_blind = function(self, reset, silent)
        if not reset then
            self.triggered_this_round = false
        end
    end,

    press_play = function(self)
        if self.triggered_this_round then
            return
        end
        self.triggered_this_round = true

        local doomed = {}
        for _, card in ipairs((G.hand and G.hand.highlighted) or {}) do
            local center = card and card.config and card.config.center
            local center_key = (center and center.key) or (card and card.config and card.config.center_key)
            if center_key ~= "m_porkify_revolving" then
                doomed[#doomed + 1] = card
            end
        end
        if #doomed == 0 then
            return
        end

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.8,
            func = function()
                for _, card in ipairs(doomed) do
                    if card and card.remove_from_deck then
                        card:remove_from_deck()
                    end
                end
                SMODS.destroy_cards(doomed)
                return true
            end
        }))
    end,

    in_pool = function(self)
        local ante = (G and G.GAME and G.GAME.round_resets and G.GAME.round_resets.ante) or 1
        return ante >= ((self.boss and self.boss.min) or 1)
    end
}
