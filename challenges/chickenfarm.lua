SMODS.Challenge{
    key = "chickenfarm",
    loc_txt = { name = "Chicken Farm" },

    rules = {
		modifiers = {
			dollars = 0,
		},
        custom = {
            { id = "no_extra_hand_money", value = true },
            { id = "no_interest", value = true },
            { id = "no_reward", value = true },
        },
    },

    jokers = {
        { id = "j_porkify_farmland", eternal = true },
        { id = "j_porkify_paul" },
        { id = "j_porkify_paul" },
        { id = "j_porkify_hatchedegg" },
        { id = "j_egg" },
    },

    restrictions = {
		banned_cards = {
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
			{id = 'j_porkify_mikujoker'},
			{id = 'j_porkify_overspeed'},
			{id = 'j_porkify_recycler'},
			{id = 'c_hermit'},
			{id = 'c_temperance'},
			{id = 'c_talisman'},
			{id = 'c_immolate'},
			{id = 'c_porkify_cleptomane'},
			{id = 'c_porkify_trashtreasure'},
			{id = 'c_porkify_stockbroker'},
		},
        banned_tags = {
            { id = "tag_investment" },
            { id = "tag_handy" },
            { id = "tag_garbage" },
            { id = "tag_skip" },
            { id = "tag_economy" },
        },
		banned_other = {
		},
    },
	button_colour = HEX("FF0095"),
}
