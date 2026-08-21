SMODS.Voucher {
    key = 'silverspoon',
    pos = { x = 6, y = 0 },
    loc_txt = {
        name = 'Silver Spoon',
        text = {
            [1] = 'Earn {C:money}$5{} extra when',
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
    atlas = 'CustomVouchers',

    calc_dollar_bonus = function(self, voucher)
        local used_vouchers = G and G.GAME and G.GAME.used_vouchers or {}
        if used_vouchers.v_porkify_heirloom then
            return
        end

        local blind = G and G.GAME and G.GAME.blind
        local is_boss_blind = not not (
            blind and (
                blind.boss
                or (blind.config and blind.config.blind and blind.config.blind.boss)
            )
        )

        if is_boss_blind then
            return 5
        end
    end
}
