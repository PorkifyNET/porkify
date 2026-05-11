
SMODS.Back {
    key = 'porkify_deck',
    pos = { x = 0, y = 0 },
    config = {
        vouchers = {
            'v_porkify_gluttony',
            'v_porkify_piggyback'
        }
    },
    loc_txt = {
        name = 'Porkify Deck',
        text = {
            [1] = 'Start run with the',
            [2] = '{C:attention,T:v_porkify_gluttony}Gluttony{} and',
            [3] = '{C:attention,T:v_porkify_piggyback}Piggyback{} Vouchers'
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
