SMODS.Blind {
    key = 'error', atlas = 'CustomBlinds', pos = { x = 0, y = 17 },
    boss = { min = 2 }, boss_colour = HEX('E44169'), mult = 2, dollars = 5,
    loc_txt = { name = 'The ERROR', text = {
        '??????????',
    } },
    set_blind = function(self)
        local blind = G.GAME.blind
        if blind.effect.porkify_error_rolled then return end
        blind.effect.porkify_error_rolled = true
        local percent = pseudorandom('porkify_error_requirement', 10, 200)
        blind.effect.porkify_error_percent = percent
        local minimum, maximum = math.ceil(blind.chips * 0.1), math.floor(blind.chips * 2)
        blind.chips = math.max(1, math.max(minimum, math.min(maximum, math.floor(blind.chips * percent / 100 + 0.5))))
        blind.chip_text = number_format(blind.chips)
        -- Whole-dollar payouts stay inside the percentage bounds; zero rewards stay zero.
        local low, high = math.ceil(blind.dollars * 0.1), math.floor(blind.dollars * 2)
        blind.dollars = pseudorandom('porkify_error_reward', low, high)
        blind.sound_pings = blind.dollars + 2
        G.GAME.current_round.dollars_to_be_earned = string.rep(localize('$'), blind.dollars)
    end,
}
