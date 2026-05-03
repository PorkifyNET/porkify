SMODS.Challenge{
    key = "oopsall6s",
    loc_txt = { name = "Oops, All Sixes!" },

    rules = {
		modifiers = {
			
		},
        custom = {
		
        },
    },

    jokers = {
		{ id = "j_oops", eternal = true, edition = "negative"},
		{ id = "j_sixth_sense" },
    },
	vouchers = {
		
	},
	deck = {
			cards = {{s='D',r='6',},{s='D',r='6',},{s='D',r='6',},{s='D',r='6',},{s='D',r='6',},{s='D',r='6',},{s='D',r='6',},{s='D',r='6',},{s='D',r='6',},{s='D',r='6',},{s='D',r='6',},{s='D',r='6',},{s='D',r='6',},{s='C',r='6',},{s='C',r='6',},{s='C',r='6',},{s='C',r='6',},{s='C',r='6',},{s='C',r='6',},{s='C',r='6',},{s='C',r='6',},{s='C',r='6',},{s='C',r='6',},{s='C',r='6',},{s='C',r='6',},{s='C',r='6',},{s='H',r='6',},{s='H',r='6',},{s='H',r='6',},{s='H',r='6',},{s='H',r='6',},{s='H',r='6',},{s='H',r='6',},{s='H',r='6',},{s='H',r='6',},{s='H',r='6',},{s='H',r='6',},{s='H',r='6',},{s='H',r='6',},{s='S',r='6',},{s='S',r='6',},{s='S',r='6',},{s='S',r='6',},{s='S',r='6',},{s='S',r='6',},{s='S',r='6',},{s='S',r='6',},{s='S',r='6',},{s='S',r='6',},{s='S',r='6',},{s='S',r='6',},{s='S',r='6',},},
			type = 'Challenge Deck',
        },
		
    restrictions = {
		banned_cards = {
			
		},
        banned_tags = {
			
        },
		banned_other = {
			{id = 'bl_porkify_evens', type = 'blind'},
			{id = 'bl_porkify_toll', type = 'blind'},
		},
    },
	button_colour = HEX("FF0095"),
}
