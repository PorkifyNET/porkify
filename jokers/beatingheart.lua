
SMODS.Joker{ --Beating Heart
    key = "beatingheart",
    config = {
        extra = {
            xmult0 = 1.5
        }
    },
    loc_txt = {
        ['name'] = 'Beating Heart',
        ['text'] = {
            [1] = '{C:hearts}Heart{} cards held in hand',
            [2] = 'each grant {X:red,C:white}X1.5{} Mult'
        },
        ['unlock'] = {
            [1] = 'Play every {C:hearts}Heart{} card in your deck'
        }
    },
    pos = {
        x = 3,
        y = 0
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 6,
    rarity = 3,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },
    unlock_condition = { type = 'play_all_hearts' },
    
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.hand and not context.end_of_round  then
            if context.other_card:is_suit("Hearts") then
                return {
                    Xmult = 1.5
                }
            end
        end
    end,
	
	joker_display_def = function(JokerDisplay)
	  return {
		text = {
		  {
			border_nodes = {
			  { text = "X" },
			  { ref_table = "card.joker_display_values", ref_value = "x_total" }
			}
		  }
		},
		reminder_text = {
			{ text = "(", colour = G.C.GREY },
			{ text = "Hearts", colour = G.C.SUITS["Hearts"] },
			{ text = ")", colour = G.C.GREY }
		},

		calc_function = function(card)
		  local per = (card.ability.extra and card.ability.extra.xmult0) or 1.5
		  local count = 0

		  for _, c in ipairs(G.hand and G.hand.cards or {}) do
			if c and c.is_suit and c:is_suit("Hearts") and not c.debuff and c.facing ~= "back" then
			  count = count + JokerDisplay.calculate_card_triggers(c, nil, true)
			end
		  end

		  local total = per ^ count
		  card.joker_display_values.x_total = string.format("%.2f", total)
		end
	  }
	end
}
