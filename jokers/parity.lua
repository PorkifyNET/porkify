SMODS.Joker{ --Parity
    key = "parity",
    config = {
        extra = {
            Xmult = 2.5
        }
    },
    loc_txt = {
        ['name'] = 'Parity',
        ['text'] = {
            [1] = '{X:red,C:white}X2.5{} Mult if played hand',
            [2] = 'contains both a scoring',
            [3] = '{C:attention}odd{} and {C:attention}even{} card'
        }
    },
    pos = {
        x = 5,
        y = 6
    },
    display_size = {
        w = 71,
        h = 95
    },
    cost = 5,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["porkify_porkify_jokers"] = true },

    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.joker_main then
            local scoring_hand = context.scoring_hand or context.full_hand or {}
            local has_odd = false
            local has_even = false

            for _, c in ipairs(scoring_hand) do
                local id = c and c.get_id and c:get_id()
                if id == 14 or id == 3 or id == 5 or id == 7 or id == 9 then
                    has_odd = true
                elseif id == 2 or id == 4 or id == 6 or id == 8 or id == 10 then
                    has_even = true
                end

                if has_odd and has_even then
                    return {
                        Xmult = card.ability.extra.Xmult or 2.5
                    }
                end
            end
        end
    end,
	
	joker_display_def = function(JokerDisplay)
	  return {
		text = {
		  {
			border_nodes = {
			  { text = "X" },
			  { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
			}
		  }
		},
		reminder_text = {
			{ ref_table = "card.joker_display_values", ref_value = "state_text", colour = G.C.GREY }
		},

		calc_function = function(card)
		  local x = 1
		  local has_odd = false
		  local has_even = false
		  local text, _, scoring_hand = JokerDisplay.evaluate_hand()

		  if text ~= "Unknown" and scoring_hand then
			for _, c in pairs(scoring_hand) do
			  if c and not c.debuff and c.facing ~= 'back' then
				local id = c:get_id()
				if id == 14 or id == 3 or id == 5 or id == 7 or id == 9 then
				  has_odd = true
				elseif id == 2 or id == 4 or id == 6 or id == 8 or id == 10 then
				  has_even = true
				end
			  end
			end
		  end

		  if has_odd and has_even then
			x = (card.ability.extra and card.ability.extra.Xmult) or 2.5
		  end

		  card.joker_display_values.x_mult = x
		  card.joker_display_values.state_text = has_odd and has_even and "(odd + even)" or "(need odd + even)"
		end
	  }
	end
}
