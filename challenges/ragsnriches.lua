SMODS.Challenge{
    key = "ragsnriches",
    loc_txt = { name = "Rags 'n Riches" },

    rules = {
		modifiers = {
			{ id = "dollars", value = 44 },
			{ id = "hand_size", value = 52 },
		},
        custom = {
			{id = 'minus_hand_size_per_X_dollar', value = 1},
        },
    },

    jokers = {
		
    },
	vouchers = {
		
	},
	deck = {
		enhancement = 'm_gold',
		seal = "Gold",
	},
		
    restrictions = {
		banned_cards = {
			{id = 'j_juggler'},
			{id = 'j_troubadour'},
			{id = 'j_turtle_bean'},
			{id = 'j_porkify_appletree'},
			{id = 'c_ouija'},
			{id = 'c_ectoplasm'},
			{id = 'c_porkify_delegation'},
			{id = 'c_porkify_sixthfinger'},
			{id = 'v_paint_brush'},
			{id = 'v_palette'},
		},
        banned_tags = {
			{ id = "tag_juggle" },
        },
		banned_other = {
			{ id = 'bl_manacle', type = 'blind' },
			{id = 'bl_porkify_rust', type = 'blind'},
		},
    },
	button_colour = HEX("FF0095"),
}
