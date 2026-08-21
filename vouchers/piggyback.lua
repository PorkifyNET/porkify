
SMODS.Voucher {
    key = 'piggyback',
    pos = { x = 1, y = 0 },
    loc_txt = {
        name = 'Piggyback',
        text = {
            [1] = 'Always add a random',
            [2] = '{C:dark_edition}Negative{} {C:purple}Porkify{} Pack',
            [3] = 'to the {C:green}shop{}'
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

    credit_badges = {
        { text = "Art: Cebee", colour = "59A487" }
     },
    
    redeem = function(self, voucher)
        G.E_MANAGER:add_event(Event({
            func = function()
                G.GAME.modifiers = G.GAME.modifiers or {}
                SMODS.change_booster_limit(1)
                return true
            end
        }))
    end
}
