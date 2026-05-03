SMODS.Challenge{
    key = "pridemonth",
    loc_txt = { name = "Pride Month" },

    rules = {
		modifiers = {
			
		},
        custom = {
			
        },
    },

    jokers = {
		{ id = "j_pareidolia", eternal = true, edition = "negative" },
		{ id = "j_porkify_pridebanner", eternal = true },
		{ id = "j_porkify_pacifist" },
    },
	vouchers = {
		
	},
	deck = {
		no_ranks = {['A'] = true, ['2'] = true, ['3'] = true, ['4'] = true, ['5'] = true, ['6'] = true, ['7'] = true, ['8'] = true, ['9'] = true, ['T'] = true},
		type = 'Challenge Deck'
	},

    restrictions = {
		banned_cards = {

		},
        banned_tags = {
			
        },
		banned_other = {
			{id = 'bl_plant', type = 'blind'},
			{id = 'bl_mark', type = 'blind'},
			{id = 'bl_porkify_mask', type = 'blind'},
		},
    },
	button_colour = HEX("FF0095"),
}
