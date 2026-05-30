SMODS.Challenge{
    key = "noheresy",
    loc_txt = { name = "No Heresy!" },

    rules = {
        custom = {
		
        },
    },

    jokers = {
    },
	vouchers = {
		
	},
	deck = {
		type = 'Challenge Deck'
	},

    restrictions = {
		banned_cards = {
			{ id = "j_sixth_sense" },
			{ id = "j_superposition" },
			{ id = "j_seance" },
			{ id = "j_vagabond" },
			{ id = "j_hallucination" },
			{ id = "j_fortune_teller" },
			{ id = "j_cartomancer" },
			{ id = "j_porkify_arcanaminor" },
			{ id = "j_porkify_firealarm" },
			{ id = "j_porkify_speedrun" },
			{ id = "j_porkify_summoningcircle" },
			{ id = "c_porkify_spiritbox" },
			{id = 'p_arcana_normal_1', ids = {
				'p_arcana_normal_1','p_arcana_normal_2','p_arcana_normal_3','p_arcana_normal_4','p_arcana_jumbo_1','p_arcana_jumbo_2','p_arcana_mega_1','p_arcana_mega_2',
			}},
			{id = 'p_spectral_normal_1', ids = {
				'p_spectral_normal_1','p_spectral_normal_2','p_spectral_jumbo_1','p_spectral_mega_1',
			}},
			{ id = "v_tarot_merchant" },
			{ id = "v_tarot_tycoon" },
			{ id = "v_omen_globe" },
		},
        banned_tags = {
			{ id = "tag_charm" },
			{ id = "tag_ethereal" },
        },
		banned_other = {
			{id = 'bl_porkify_rust', type = 'blind'},
		},
    },
	button_colour = HEX("FF0095"),
}
