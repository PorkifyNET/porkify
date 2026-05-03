SMODS.Blind{
    key = "snakepit",
    atlas = "CustomBlinds",
    pos = { x = 0, y = 14 },
    boss = { min = 2 },
    boss_colour = HEX("55AA00"),
    mult = 2,
    dollars = 5,
    loc_txt = {
        name = "The Snakepit",
        text = {
            [1] = "{C:attention}+2{} Hand Size,",
            [2] = "{C:red}-1{} Hand Size per played hand"
        }
    },

    set_blind = function(self, reset, silent)
        if reset or not (G and G.GAME and G.hand and G.GAME.current_round) then
            return
        end

        if G.GAME.current_round.porkify_snakepit_hand_delta ~= nil then
            return
        end

        G.GAME.current_round.porkify_snakepit_hand_delta = 2
        G.GAME.current_round.porkify_snakepit_last_hands_left = G.GAME.current_round.hands_left or 0
        G.hand:change_size(2)
    end,

    disable = function(self, silent)
        if not (G and G.GAME and G.hand and G.GAME.current_round) then
            return
        end

        local applied_delta = G.GAME.current_round.porkify_snakepit_hand_delta
        if applied_delta ~= nil and applied_delta ~= 0 then
            G.hand:change_size(-applied_delta)
        end

        G.GAME.current_round.porkify_snakepit_hand_delta = nil
        G.GAME.current_round.porkify_snakepit_last_hands_left = nil
    end,

    calculate = function(self, card, context)
        if not (G and G.GAME and G.GAME.current_round) then
            return
        end

        if context.blind_disabled or context.blind_defeated or context.end_of_round then
            self:disable()
            return
        end

        local current_delta = G.GAME.current_round.porkify_snakepit_hand_delta
        if current_delta == nil then
            return
        end

        local hands_left = G.GAME.current_round.hands_left or 0
        local last_hands_left = G.GAME.current_round.porkify_snakepit_last_hands_left

        if last_hands_left == nil then
            G.GAME.current_round.porkify_snakepit_last_hands_left = hands_left
            return
        end

        local hands_played = last_hands_left - hands_left
        if hands_played > 0 and G.hand then
            G.hand:change_size(-hands_played)
            G.GAME.current_round.porkify_snakepit_hand_delta = current_delta - hands_played
            G.GAME.current_round.porkify_snakepit_last_hands_left = hands_left
        elseif hands_left ~= last_hands_left then
            G.GAME.current_round.porkify_snakepit_last_hands_left = hands_left
        end
    end,

    in_pool = function(self)
        local ante = (G and G.GAME and G.GAME.round_resets and G.GAME.round_resets.ante) or 1
        return ante >= ((self.boss and self.boss.min) or 1)
    end
}
