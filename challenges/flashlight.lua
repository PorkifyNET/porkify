local flashlight_cards = {}
local face_ranks = { J = true, Q = true, K = true }

for _, suit in ipairs({ 'S', 'H', 'D', 'C' }) do
	for _, rank in ipairs({ '2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K', 'A' }) do
		flashlight_cards[#flashlight_cards + 1] = {
			s = suit,
			r = rank,
			e = face_ranks[rank] and 'm_porkify_revolving' or nil,
		}
	end
end

SMODS.Challenge{
    key = "flashlight",
    loc_txt = { name = "Flashlight" },

    rules = {
		modifiers = {
			{ id = "hands", value = 8 },
			{ id = "discards", value = 0 },
		},
        custom = {
			{id = 'flipped_cards', value = 1},
        },
    },

    jokers = {

    },
	consumeables = {
		{ id = "c_porkify_trainingwheels" },
		{ id = "c_porkify_revolver" },
	},
	vouchers = {

	},
	deck = {
		type = 'Challenge Deck',
		cards = flashlight_cards,
	},
		
    restrictions = {
		banned_cards = {
			
		},
        banned_tags = {
			
        },
		banned_other = {

		},
    },
	button_colour = HEX("FF0095"),
}
