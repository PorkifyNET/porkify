SMODS.Voucher {
    key = 'electromagnet',
    pos = { x = 3, y = 0 },
    loc_txt = {
        name = 'Electromagnet',
        text = {
            [1] = 'Your favorite {C:attention}playing card{}',
            [2] = '{C:green}returns{} to {C:blue}hand{} after being',
            [3] = 'played {C:attention}once{} per round'
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
    requires = { 'v_porkify_magnet' },
    atlas = 'CustomVouchers',

    redeem = function(self, voucher)
        G.E_MANAGER:add_event(Event({
            func = function()
                if Porkify_refresh_favorite_stickers then
                    Porkify_refresh_favorite_stickers()
                end
                return true
            end
        }))
    end
}
