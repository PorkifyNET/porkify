SMODS.Challenge{
    key = "roadblocked",
    loc_txt = { name = "Roadblocked" },

    rules = {
		modifiers = {
			{ id = "joker_slots", value = 6 },
			{ id = "hands", value = 6 },
			{ id = "discards", value = 0 },
		},
        custom = {
			
        },
    },

    jokers = {
		{ id = "j_porkify_roadblock", eternal = true, pinned = true },
		{ id = "j_shortcut", eternal = true, edition = "negative" },
		{ id = "j_four_fingers", eternal = true, edition = "negative" },
    },
	vouchers = {
		
	},

    restrictions = {
		banned_cards = {
			{ id = "j_crazy" },
			{ id = "j_devious" },
			{ id = "j_runner" },
			{ id = "j_seance" },
			{ id = "j_shortcut" },
			{ id = "j_order" },
			{ id = "j_brainstorm" },
			{ id = "j_porkify_cairn" },
			{ id = "c_saturn" },
			{ id = "c_neptune" },
			{ id = "c_porkify_excalibur" },
		},
        banned_tags = {
			
        },
		banned_other = {
			{id = 'bl_porkify_ladder', type = 'blind'},
		},
    },
	button_colour = HEX("FF0095"),
}
