SMODS.Challenge{
    key = "noastronomy",
    loc_txt = { name = "No Astronomy!" },

    rules = {
        custom = {
		
        },
    },

    jokers = {
    },
	vouchers = {
		
	},

    restrictions = {
		banned_cards = {
			{ id = "j_supernova" },
			{ id = "j_space" },
			{ id = "j_constellation" },
			{ id = "j_rocket" },
			{ id = "j_satellite" },
			{ id = "j_astronomer" },
			{ id = "j_burnt" },
			{ id = "c_high_priestess" },
			{ id = "c_black_hole" },
			{ id = "c_trance" },
			{ id = "c_porkify_meteor" },
			{ id = "c_porkify_estrogen" },
			{ id = "c_porkify_finalfrontier" },
			{ id = "j_porkify_discovery" },
			{id = 'p_celestial_normal_1', ids = {
				'p_celestial_normal_1','p_celestial_normal_2','p_celestial_normal_3','p_celestial_normal_4','p_celestial_jumbo_1','p_celestial_jumbo_2','p_celestial_mega_1','p_celestial_mega_2',
			}},
			{ id = "v_planet_merchant" },
			{ id = "v_planet_tycoon" },
			{ id = "v_telescope" },
			{ id = "v_observatory" },
		},
        banned_tags = {
			{ id = "tag_meteor" },
			{ id = "tag_orbital" },
        },
		banned_other = {
			{id = 'bl_arm', type = 'blind'},
		},
    },
	button_colour = HEX("FF0095"),
}
