SMODS.Challenge{
    key = "roadblocked",
    loc_txt = { name = "Roadblocked" },

    rules = {
		modifiers = {
			{ id = "hands", value = 6 },
			{ id = "discards", value = 0 },
		},
        custom = {
			
        },
    },

    jokers = {
		{ id = "j_porkify_roadblock", omega = true },
		{ id = "j_shortcut", omega = true, edition = "negative" },
		{ id = "j_four_fingers", omega = true, edition = "negative" },
    },
	vouchers = {
		
	},
	deck = {
		type = 'Challenge Deck'
	},

    restrictions = {
		banned_cards = {
			{ id = "j_crazy" },
			{ id = "j_devious" },
			{ id = "j_runner" },
			{ id = "j_seance" },
			{ id = "j_shortcut" },
			{ id = "j_order" },
			{ id = "j_porkify_cairn" },
			{ id = "c_saturn" },
			{ id = "c_neptune" },
		},
        banned_tags = {
			
        },
		banned_other = {
			{id = 'bl_porkify_prideful', type = 'blind'},
		},
    },
	button_colour = HEX("FF0095"),
}
