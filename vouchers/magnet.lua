SMODS.Voucher {
    key = 'magnet',
    pos = { x = 2, y = 0 },
    loc_txt = {
        name = 'Magnet',
        text = {
            [1] = 'Your {C:attention}1{} most played card',
            [2] = 'is always drawn {C:attention}first{}'
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
