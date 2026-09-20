SMODS.Blind {
    key = 'eco_warrior', atlas = 'CustomBlinds', pos = { x = 0, y = 16 },
    boss = { min = 2 }, boss_colour = HEX('4E9962'), mult = 2, dollars = 5,
    loc_txt = { name = 'The Eco-Warrior', text = {
        'Divide Mult by', 'remaining Discards',
    } },
    calculate = function(self, blind, context)
        if context.final_scoring_step and not blind.disabled then
            local divisor = math.max(1, G.GAME.current_round.discards_left or 0)
            return { x_mult = 1 / divisor }
        end
    end,
}
