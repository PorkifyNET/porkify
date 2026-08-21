SMODS.Voucher {
    key = 'heirloom',
    pos = { x = 7, y = 0 },
    loc_txt = {
        name = 'Heirloom',
        text = {
            [1] = 'Earn {C:money}$15{} extra when',
            [2] = 'defeating any {C:attention}Boss Blind{}'
        },
        unlock = {
            [1] = 'Unlocked by default.'
        }
    },
    cost = 10,
    unlocked = true,
    discovered = false,
    no_collection = false,
    can_repeat_soul = false,
    requires = { 'v_porkify_silverspoon' },
    atlas = 'CustomVouchers',

    calc_dollar_bonus = function(self, voucher)
        local blind = G and G.GAME and G.GAME.blind
        local is_boss_blind = not not (
            blind and (
                blind.boss
                or (blind.config and blind.config.blind and blind.config.blind.boss)
            )
        )

        if is_boss_blind then
            return 15
        end
    end
}
