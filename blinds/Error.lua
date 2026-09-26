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
        local original_chips = to_big(blind.chips or 1)
        local minimum = math.ceil(original_chips * to_big(0.1))
        local maximum = math.floor(original_chips * to_big(2))
        local adjusted = math.floor(
            original_chips * to_big(percent) / to_big(100) + to_big(0.5)
        )
        if adjusted < minimum then adjusted = minimum end
        if adjusted > maximum then adjusted = maximum end
        if adjusted < to_big(1) then adjusted = to_big(1) end
        blind.chips = adjusted
        blind.chip_text = number_format(blind.chips)
        -- Whole-dollar payouts stay inside the percentage bounds; zero rewards stay zero.
        local low, high = math.ceil(blind.dollars * 0.1), math.floor(blind.dollars * 2)
        blind.dollars = pseudorandom('porkify_error_reward', low, high)
        blind.sound_pings = blind.dollars + 2
        G.GAME.current_round.dollars_to_be_earned = string.rep(localize('$'), blind.dollars)
    end,
}
