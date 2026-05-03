SMODS.Challenge{
    key = "riffraffle",
    loc_txt = { name = "Riff-Raffle" },

    rules = {
		modifiers = {
			{ id = "dollars", value = 0 },
		},
        custom = {
			{ id = "no_extra_hand_money" },
			{ id = "no_interest" },
			{ id = "no_reward" },
			{ id = "no_shop_jokers" },
        },
    },

    jokers = {
		{ id = "j_riff_raff", eternal = true, edition = "negative" },
    },
	vouchers = {
		
	},

    restrictions = {
		banned_cards = {
			{id = 'j_invisible'},
			{id = 'c_judgement'},
			{id = 'c_wraith'},
			{id = 'c_soul'},
			{id = 'p_buffoon_normal_1', ids = {
				'p_buffoon_normal_1','p_buffoon_normal_2','p_buffoon_jumbo_1','p_buffoon_mega_1',
			}},
			{id = 'c_porkify_excalibur'},
			{id = 'c_porkify_mephiles'},
			{id = 'c_porkify_top_up_consumable'},
		},
        banned_tags = {
            { id = "tag_uncommon" },
            { id = "tag_rare" },
            { id = "tag_negative" },
            { id = "tag_foil" },
            { id = "tag_holo" },
            { id = "tag_polychrome" },
        },
		banned_other = {
			
		},
    },
	button_colour = HEX("FF0095"),
}
