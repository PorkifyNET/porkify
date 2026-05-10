SMODS.Back {
    key = 'voucher_deck',
    pos = { x = 1, y = 0 },
    config = {},
    loc_txt = {
        name = 'Voucher Deck',
        text = {
            [1] = 'All {C:green}Shops{} have {C:attention}2{} Vouchers',
            [2] = 'Start run with an',
            [3] = '{C:attention,T:tag_investment}Investment Tag{}'
        },
    },
    unlocked = true,
    discovered = true,
    no_collection = false,
    atlas = 'CustomDecks',

    credit_badges = {
        { text = "Art: christopherjacobsanderson", colour = "59A487" }
     },

    apply = function(self, back)
        SMODS.change_voucher_limit(1)

        G.E_MANAGER:add_event(Event({
            func = function()
                local tag = Tag("tag_investment")
                tag:set_ability()
                add_tag(tag)
                play_sound('holo1', 1.2 + math.random() * 0.1, 0.4)
                return true
            end
        }))
    end
}
