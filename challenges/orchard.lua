SMODS.Challenge{
    key = "orchard",
    loc_txt = { name = "The Orchard" },

    rules = {
		modifiers = {
			{id = 'joker_slots', value = 0},
		},
        custom = {
            -- This is OUR flag the Orchard Spirit checks
            { id = "porkify_orchard_challenge", value = true },

            -- Base-game rule: shop cannot sell Jokers
            {id = "no_shop_jokers"},
        },
    },

    -- Start with the Orchard Spirit (eternal+pinned so it can’t be removed)
    jokers = {
        { id = "j_porkify_orchard_spirit", eternal = true, pinned = true },
    },

    -- Try hard to ensure “no other ways to obtain Jokers”
    -- (You can add more banned tags/cards as you discover other joker sources you care about.)
    restrictions = {
		banned_cards = {
			{id = 'j_riff_raff'},
			{id = 'j_invisible'},
			{id = 'j_brainstorm'},
			{id = 'c_judgement'},
			{id = 'c_wraith'},
			{id = 'c_soul'},
			{id = 'v_antimatter'},
			{id = 'p_buffoon_normal_1', ids = {
				'p_buffoon_normal_1','p_buffoon_normal_2','p_buffoon_jumbo_1','p_buffoon_mega_1',
			}},
			{id = 'j_porkify_hatchedegg'},
			{id = 'j_porkify_paul'},
			{id = 'j_porkify_doppelganger'},
			{id = 'c_porkify_excalibur'},
			{id = 'c_porkify_freezer'},
			{id = 'c_porkify_fountainofyouth'},
            {id = 'c_porkify_mephiles'},
            {id = 'c_porkify_primate'},
            {id = 'c_porkify_top_up_consumable'},
		},
        banned_tags = {
            { id = "tag_joker" },
            { id = "tag_uncommon" },
            { id = "tag_rare" },
            { id = "tag_negative" },
            { id = "tag_foil" },
            { id = "tag_holo" },
            { id = "tag_polychrome" },
            { id = "tag_topup" },
        },
		banned_other = {
			{id = 'bl_final_heart', type = 'blind'},
            {id = 'bl_final_leaf', type = 'blind'}
		},
    },
	button_colour = HEX("FF0095"),
}
