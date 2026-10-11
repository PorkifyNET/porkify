SMODS.Challenge{
    key = "forcedvariety",
    loc_txt = { name = "Forced Variety" },

    rules = {
		modifiers = {
			{ id = "joker_slots", value = 6 },
		},
        custom = {
			
        },
    },

    jokers = {
		{ id = "j_porkify_forced_variety", omega = true, pinned = true },
    },
	vouchers = {
		
	},
	deck = {
		type = 'Challenge Deck'
	},

    restrictions = {
		banned_cards = {
			{ id = "j_brainstorm" },
		},
        banned_tags = {
			
        },
		banned_other = {
			{id = 'bl_porkify_ladder', type = 'blind'},
		},
    },
	button_colour = HEX("FF0095"),
}
