SMODS.Blind {
    key = 'wipe', atlas = 'CustomBlinds', pos = { x = 0, y = 22 },
    boss = { min = 3 }, boss_colour = HEX('BBBDB9'), mult = 2, dollars = 5,
    loc_txt = { name = 'The Wipe', text = {
        'Remove enhancements from', 'played cards before scoring',
    } },
    press_play = function(self)
        if G.GAME.blind.disabled then return end
        for _, card in ipairs(G.hand.highlighted or {}) do
            if card.config.center.set == 'Enhanced' then
                card:set_ability(G.P_CENTERS.c_base, nil, true)
            end
        end
    end,
}
