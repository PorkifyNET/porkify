SMODS.Challenge{
    key = "greenworld",
    loc_txt = { name = "Green World" },

    rules = {
		modifiers = {
			{id = 'discards', value = 1},
		},
        custom = {
			{ id = "all_eternal", value = true },
			{ id = "discard_cost", value = 3 },
        },
    },

    jokers = {
		{ id = "j_green_joker", eternal = true },
		{ id = "j_porkify_recycler", eternal = true },
    },
	vouchers = {
		
	},

    restrictions = {
		banned_cards = {
			{ id = "j_ceremonial" },
			{ id = "j_madness" },
			{ id = "c_hanged_man" },
			{ id = "c_immolate" },
			{ id = "c_porkify_conjoined" },
			{ id = "c_porkify_sacrifice" },
			{ id = "c_porkify_sixthfinger" },
			{ id = "c_porkify_timemachine" },
			{ id = "c_porkify_trashmaster" },
			{ id = "c_porkify_trashtreasure" },
			{ id = "v_wasteful" },
			{ id = "v_recyclomancy" },
		},
        banned_tags = {
			{ id = "tag_garbage" },
        },
		banned_other = {
			{id = 'bl_hook', type = 'blind'},
			{id = 'bl_porkify_pyre', type = 'blind'},
		},
    },
	button_colour = HEX("FF0095"),
}
