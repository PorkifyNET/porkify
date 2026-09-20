local function clear_targets()
    G.GAME.blind.effect.porkify_bully_targets = nil
    for _, card in ipairs(G.playing_cards or {}) do SMODS.recalc_debuff(card) end
    Porkify_refresh_favorite_stickers()
end

SMODS.Blind {
    key = 'bully', atlas = 'CustomBlinds', pos = { x = 0, y = 15 },
    boss = { min = 2 }, boss_colour = HEX('A34C65'), mult = 2, dollars = 5,
    loc_txt = { name = 'The Bully', text = {
        'Your Favorite card', 'is debuffed',
    } },
    in_pool = function(self)
        return G.GAME.round_resets.ante >= self.boss.min
            and not not (G.GAME.used_vouchers or {}).v_porkify_magnet
    end,
    set_blind = function(self)
        local effect = G.GAME.blind.effect
        if effect.porkify_bully_targets then return end
        Porkify_refresh_favorite_stickers()
        local targets = {}
        for _, card in ipairs(G.playing_cards or {}) do
            if card.playing_card and (card.ability.favorite or card.ability.porkify_favorite) then
                targets[card.playing_card] = true
            end
        end
        effect.porkify_bully_targets = targets
        for _, card in ipairs(G.playing_cards or {}) do SMODS.recalc_debuff(card) end
        Porkify_refresh_favorite_stickers()
    end,
    recalc_debuff = function(self, card)
        local targets = G.GAME.blind.effect.porkify_bully_targets or {}
        return not G.GAME.blind.disabled and card.playing_card and targets[card.playing_card] == true or false
    end,
    disable = clear_targets,
    defeat = clear_targets,
}
