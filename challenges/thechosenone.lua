SMODS.Challenge{
    key = "thechosenone",
    loc_txt = { name = "The Chosen One" },

    rules = {
		modifiers = {
			{id = 'joker_slots', value = 0},
		},
        custom = {
			{id = "no_shop_jokers"},
        },
    },

    jokers = {
		{ id = "j_porkify_joker2", eternal = true },
    },
	vouchers = {
		
	},
	deck = {
			type = 'Challenge Deck'
        },
		
    restrictions = {
		banned_cards = {
			{id = 'j_riff_raff'},
			{id = 'j_invisible'},
			{id = 'c_judgement'},
			{id = 'c_wraith'},
			{id = 'c_soul'},
			{id = 'p_buffoon_normal_1', ids = {
				'p_buffoon_normal_1','p_buffoon_normal_2','p_buffoon_jumbo_1','p_buffoon_mega_1',
			}},
			{id = 'c_porkify_excalibur'},
		},
        banned_tags = {
			
        },
		banned_other = {
			{id = 'bl_final_heart', type = 'blind'},
            {id = 'bl_final_leaf', type = 'blind'}
		},
    },
	button_colour = HEX("FF0095"),
}
