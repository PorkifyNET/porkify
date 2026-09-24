
SMODS.Back {
    key = 'porkify_deck',
    pos = { x = 0, y = 0 },
    config = {
        vouchers = {
            'v_porkify_gluttony'
        },
        consumables = {
            'c_porkify_casualwalk',
            'c_porkify_casualwalk'
        }
    },
    loc_txt = {
        name = 'Porkify Deck',
        text = {
            [1] = 'Start run with the {C:attention,T:v_porkify_gluttony}Gluttony{}',
            [2] = 'Voucher and {C:attention}2{} copies',
            [3] = 'of the {C:porkify,T:c_porkify_casualwalk}Casual Walk{}'
        },
    },
    unlocked = true,
    discovered = false,
    no_collection = false,
    atlas = 'CustomDecks',

    credit_badges = {
        { text = "Art: christopherjacobsanderson", colour = "59A487" }
     },
}
