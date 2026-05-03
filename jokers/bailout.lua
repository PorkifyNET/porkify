
SMODS.Joker{ --Bailout
    key = "bailout",
    config = {
        extra = {
            dollars = 4
        }
    },
    loc_txt = {
        ['name'] = 'Bailout',
        ['text'] = {
            [1] = 'All {C:attention}Aces{} grant {C:money}$4{}',
            [2] = 'when held in hand at',
            [3] = 'end of round'
        },
        ['unlock'] = {
            [1] = 'Have at least {C:money}$100{}'
        }
    },
    pos = {
        x = 8,
        y = 0
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 8,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["porkify_porkify_jokers"] = true },
    unlock_condition = { type = 'money', extra = 100 },
    
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.hand and context.end_of_round  then
            if context.other_card:get_id() == 14 then
                return {
                    
                    func = function()
                        
                        local current_dollars = G.GAME.dollars
                        local target_dollars = G.GAME.dollars + card.ability.extra.dollars
                        local dollar_value = target_dollars - current_dollars
                        ease_dollars(dollar_value)
                        card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = "$"..tostring(card.ability.extra.dollars), colour = G.C.MONEY})
                        return true
                    end
                }
            end
        end
    end,
	
	joker_display_def = function(JokerDisplay)
	  return {
		text = {
		  { ref_table = "card.joker_display_values", ref_value = "money_text", colour = G.C.MONEY, retrigger_type = "mult" }
		},
		reminder_text = {
			{ text = "(", colour = G.C.GREY },
			{ text = "Aces", colour = G.C.IMPORTANT },
			{ text = ")", colour = G.C.GREY }
		},

		calc_function = function(card)
		  local per = (card.ability.extra and card.ability.extra.dollars) or 4
		  local aces = 0

		  if G and G.hand and G.hand.cards then
			for _, c in ipairs(G.hand.cards) do
			  if c and c.get_id and c:get_id() == 14 and not c.debuff and c.facing ~= 'back' then
				aces = aces + 1
			  end
			end
		  end

		  local total = per * aces
		  card.joker_display_values.money_text = "+$" .. tostring(total)
		end
	  }
	end,
}
