SMODS.Challenge{
    key = "pandemic",
    loc_txt = { name = "Pandemic" },

    rules = {
		modifiers = {
			
		},
        custom = {
			{ id = "porkify_pandemic", value = true },
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
            {id = 'v_directors_cut'},
            {id = 'v_retcon'},
            {id = 'c_porkify_fountainofyouth'},
            {id = 'j_chicot'},
            {id = 'j_luchador'},
            {id = 'c_porkify_tranquilizer'},
            {id = 'j_porkify_swoon'},
            {id = 'j_porkify_thehospital'},
		},
        banned_tags = {
			{id = 'tag_boss'},
        },
		banned_other = {
			{id = 'bl_final_vessel', type = 'blind'},
            {id = 'bl_final_bell', type = 'blind'},
		},
    },
	button_colour = HEX("FF0095"),
}

-- Boss selection also runs for rerolls. Hook its shared entry point so every
-- regular Boss route obeys Pandemic while Showdown Antes keep their pool.
if SMODS and type(SMODS.get_new_blind) == "function"
    and not Porkify_pandemic_get_new_blind_ref then
    Porkify_pandemic_get_new_blind_ref = SMODS.get_new_blind
    function SMODS.get_new_blind(blind_type)
        local pandemic = G and G.GAME and G.GAME.modifiers
            and G.GAME.modifiers.porkify_pandemic
        local showdown = type(SMODS.is_showdown_ante) == "function"
            and SMODS.is_showdown_ante()
        if pandemic and not showdown
            and string.lower(tostring(blind_type or "boss")) == "boss" then
            local key = "bl_porkify_virus"
            if type(SMODS.add_boss_to_used_table) == "function" then
                SMODS.add_boss_to_used_table(key, "boss")
            end
            return key
        end
        return Porkify_pandemic_get_new_blind_ref(blind_type)
    end
end
