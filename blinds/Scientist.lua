SMODS.Blind {
    key = 'scientist', atlas = 'CustomBlinds', pos = { x = 0, y = 18 },
    boss = { min = 2 }, boss_colour = HEX('509BAC'), mult = 2, dollars = 5,
    loc_txt = { name = 'The Scientist', text = {
        'Divide Mult by level', 'of played poker hand',
    } },
    calculate = function(self, blind, context)
        if context.final_scoring_step and not blind.disabled then
            local hand = G.GAME.hands[context.scoring_name]
            local divisor = math.max(1, hand and hand.level or 1)
            return { x_mult = 1 / divisor }
        end
    end,
}
