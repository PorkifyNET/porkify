SMODS.Challenge{
    key = "flashlight",
    loc_txt = { name = "Flashlight" },

    rules = {
		modifiers = {
			{ id = "hands", value = 8 },
			{ id = "discards", value = 0 },
		},
        custom = {
			{id = 'flipped_cards', value = 1},
        },
    },

    jokers = {
		{ id = "j_ring_master" }, 
    },
	consumeables = {
		{ id = "c_porkify_trainingwheels" },
		{ id = "c_porkify_trainingwheels" },
	},
	vouchers = {
		{ id = "v_grabber" },
		{ id = "v_nacho_tong" },
	},
	deck = {
		type = 'Challenge Deck'
	},
		
    restrictions = {
		banned_cards = {
			
		},
        banned_tags = {
			
        },
		banned_other = {
			{id = 'bl_house', type = 'blind'},
			{id = 'bl_wheel', type = 'blind'},
			{id = 'bl_fish', type = 'blind'},
			{id = 'bl_mark', type = 'blind'},
		},
    },
	button_colour = HEX("FF0095"),
}
