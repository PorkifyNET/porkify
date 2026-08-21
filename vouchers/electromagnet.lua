SMODS.Voucher {
    key = 'electromagnet',
    pos = { x = 3, y = 0 },
    loc_txt = {
        name = 'Electromagnet',
        text = {
            [1] = 'Your {C:attention}3{} most played cards',
            [2] = 'are always drawn {C:attention}first{}'
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
