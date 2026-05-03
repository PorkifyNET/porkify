
SMODS.Voucher {
    key = 'piggyback',
    config = {
        extra = 4
    },
    pos = { x = 1, y = 0 },
    loc_txt = {
        name = 'Piggyback',
        text = {
            [1] = '{C:purple}Porkify {}cards may',
            [2] = 'appear in the {C:green}shop{}'
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
    requires = {'v_porkify_gluttony'},
    atlas = 'CustomVouchers',
    redeem = function(self, voucher)
        G.E_MANAGER:add_event(Event({
            func = function()
                G.GAME.porkify_rate = self.config.extra or 4
                return true
            end
        }))
    end
}
