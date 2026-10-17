SMODS.Challenge {
    key = 'feedingfrenzy',
    loc_txt = { name = 'Feeding Frenzy' },

    rules = {
        modifiers = {},
        custom = {},
    },

    jokers = {
        { id = 'j_porkify_mallard', omega = true },
        { id = 'j_juggler' },
    },
    vouchers = {},
    deck = {
        type = 'Challenge Deck',
    },

    restrictions = {
        banned_cards = {
            { id = 'm_porkify_revolving' },
            { id = 'c_porkify_revolver' },
            { id = 'c_porkify_fountainofyouth' },
            { id = 'j_dna' },
            { id = 'j_certificate' },
            { id = 'j_marble' },
            { id = 'j_porkify_fissionjoker' },
        },
        banned_tags = {},
        banned_other = {},
    },
    button_colour = HEX('FF0095'),
}
