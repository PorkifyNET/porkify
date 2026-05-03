SMODS.Challenge{
    key = "communism",
    loc_txt = { name = "Communism" },

    rules = {
		modifiers = {
			{id = 'dollars', value = 0},
			{id = 'hands', value = 5},
			{id = 'discards', value = 5},
			{id = 'reroll_cost', value = 0},
			{id = 'hand_size', value = 10},
		},
        custom = {
			{id = 'minus_hand_size_per_X_dollar', value = 10},
			{ id = "no_extra_hand_money", value = true },
            { id = "no_interest", value = true },
        },
    },

    jokers = {
		{ id = "j_raised_fist", eternal = true },
    },
	vouchers = {
		
	},
	deck = {
		cards = 
		{{s='D',r='2',},{s='D',r='3',},{s='D',r='4',},{s='D',r='5',},{s='D',r='6',},{s='D',r='7',},{s='D',r='8',},{s='D',r='9',},{s='D',r='T',},{s='H',r='J',},{s='D',r='A',},{s='C',r='2',},{s='C',r='3',},{s='C',r='4',},{s='C',r='5',},{s='C',r='6',},{s='C',r='7',},{s='C',r='8',},{s='C',r='9',},{s='C',r='T',},{s='H',r='J',},{s='C',r='A',},{s='H',r='2',},{s='H',r='3',},{s='H',r='4',},{s='H',r='5',},{s='H',r='6',},{s='H',r='7',},{s='H',r='8',},{s='H',r='9',},{s='H',r='T',},{s='H',r='J',},{s='H',r='J',},{s='H',r='J',},{s='H',r='A',},{s='S',r='2',},{s='S',r='3',},{s='S',r='4',},{s='S',r='5',},{s='S',r='6',},{s='S',r='7',},{s='S',r='8',},{s='S',r='9',},{s='S',r='T',},{s='H',r='J',},{s='S',r='A',},},
		type = 'Challenge Deck'
	},

    restrictions = {
		banned_cards = {
			{ id = "j_credit_card" },
			{ id = "j_to_the_moon" },
			{ id = "j_porkify_luckynumber7s" },
			{ id = "j_porkify_pacifist" },
			{ id = "c_porkify_jackpot" },
			{ id = 'c_porkify_trashtreasure' },
			{ id = "c_porkify_stockbroker" },
		},
        banned_tags = {
			{ id = "tag_investment" },
            { id = "tag_skip" },
            { id = "tag_economy" },
        },
		banned_other = {
			{id = 'bl_ox', type = 'blind'},
			{id = 'bl_tooth', type = 'blind'},
			{id = 'bl_porkify_tax', type = 'blind'},
		},
    },
	button_colour = HEX("FF0095"),
}
