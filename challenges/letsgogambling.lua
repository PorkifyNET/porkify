SMODS.Challenge{
    key = "letsgogambling",
    loc_txt = { name = "Let's Go Gambling!" },

    rules = {
		modifiers = {
			{ id = "dollars", value = 0 },
		},
        custom = {
			{ id = "no_extra_hand_money" },
			{ id = "no_interest" },
			{id = 'no_reward_specific', value = 'Small'},
            {id = 'no_reward_specific', value = 'Big'},
        },
    },

    jokers = {
		{ id = "j_lucky_cat", eternal = true },
    },
	vouchers = {
		
	},
	deck = {
		enhancement = 'm_lucky',
		type = 'Challenge Deck'
    },
		
    restrictions = {
		banned_cards = {
			{id = 'j_marble'},
			{id = 'j_vampire'},
			{id = 'j_midas_mask'},
			{id = 'j_certificate'},
			{id = 'j_oops'},
			{id = 'j_delayed_grat'},
			{id = 'j_business'},
			{id = 'j_faceless'},
			{id = 'j_todo_list'},
			{id = 'j_cloud_9'},
			{id = 'j_rocket'},
			{id = 'j_gift'},
			{id = 'j_reserved_parking'},
			{id = 'j_mail'},
			{id = 'j_golden'},
			{id = 'j_trading'},
			{id = 'j_ticket'},
			{id = 'j_rough_gem'},
			{id = 'j_satellite'},
			{id = 'j_porkify_bailout'},
			{id = 'j_porkify_cairn'},
			{id = 'j_porkify_coupon'},
			{id = 'j_porkify_luckynumber7s'},
			{id = 'j_porkify_overspeed'},
			{id = 'j_porkify_recycler'},
			{id = 'c_justice'},
			{id = 'c_empress'},
			{id = 'c_heirophant'},
			{id = 'c_chariot'},
			{id = 'c_devil'},
			{id = 'c_tower'},
			{id = 'c_lovers'},
			{id = 'c_incantation'},
			{id = 'c_grim'},
			{id = 'c_familiar'},
			{id = 'c_hermit'},
			{id = 'c_temperance'},
			{id = 'c_talisman'},
			{id = 'c_immolate'},
			{id = 'c_porkify_cleptomane'},
			{id = 'c_porkify_trashtreasure'},
			{id = 'c_porkify_sacrifice'},
			{id = 'c_porkify_stockbroker'},
			{id = 'c_porkify_doubleornothing'},
			{id = 'c_porkify_electron'},
			{id = 'c_porkify_medusa'},
			{id = 'p_standard_normal_1', ids = {
				'p_standard_normal_1','p_standard_normal_2','p_standard_normal_3','p_standard_normal_4','p_standard_jumbo_1','p_standard_jumbo_2','p_standard_mega_1','p_standard_mega_2',
			}},
			{id = 'v_magic_trick'},
			{id = 'v_illusion'},
			{id = 'v_clearance_sale'},
			{id = 'v_liquidation'},
		},
        banned_tags = {
			{ id = "tag_standard" },
        },
		banned_other = {
			{id = 'bl_porkify_rust', type = 'blind'},
		},
    },
	button_colour = HEX("FF0095"),
}
