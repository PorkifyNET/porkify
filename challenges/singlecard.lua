SMODS.Challenge{
    key = "singlecard",
    loc_txt = { name = "Single Card" },

    rules = {
		modifiers = {
			{id = 'discards', value = 0},
		},
        custom = {
		
        },
    },

    jokers = {
		{ id = "j_popcorn", edition = "foil" },
    },
	vouchers = {
		{ id = "v_magic_trick" },
		{ id = "v_illusion" },
	},
	deck = {
            --enhancement = 'm_glass',
            --edition = 'foil',
            --gold_seal = true,
            --yes_ranks = {['3'] = true,T = true},
            --no_ranks = {['4'] = true},
            --yes_suits = {S=true},
            --no_suits = {D=true},
            cards = {{s='H',r='A',}},
            type = 'Challenge Deck'
        },
		
    restrictions = {
		banned_cards = {

		},
        banned_tags = {
			
        },
		banned_other = {
			{id = 'bl_psychic', type = 'blind'},
			{id = 'bl_pillar', type = 'blind'},
			{id = 'bl_hook', type = 'blind'},
		},
    },
	button_colour = HEX("FF0095"),
}
