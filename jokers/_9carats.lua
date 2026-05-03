
SMODS.Joker{ --9-Carats
    key = "_9carats",
    config = {
        extra = {
        }
    },
    loc_txt = {
        ['name'] = '9-Carats',
        ['text'] = {
            [1] = 'Played {C:attention}7{}, {C:attention}9{}, and',
            [2] = '{C:attention}Ace{} cards give {C:attention}double{} their',
            [3] = '{C:attention}rank{} in {C:red}Mult{} when scored'
        },
        ['unlock'] = {
            [1] = 'Play a {C:attention}Three of a Kind{} consisting of {C:attention}3{} {C:attention}9s{}'
        }
    },
    pos = {
        x = 1,
        y = 0
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 5,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["porkify_porkify_jokers"] = true },
    check_for_unlock = function(self, args)
        if args.type ~= 'hand_contents' or not args.cards then
            return false
        end
        local eval = evaluate_poker_hand(args.cards)
        if not (eval and next(eval["Three of a Kind"])) or (eval["Four of a Kind"] and next(eval["Four of a Kind"])) or (eval["Full House"] and next(eval["Full House"])) then
            return false
        end
        local count = 0
        for _, c in ipairs(args.cards) do
            if c and c.get_id and c:get_id() == 9 then
                count = count + 1
            end
        end
        return count >= 3
    end,
    
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local id = context.other_card:get_id()
            if id == 7 or id == 9 or id == 14 then
                return {
                    mult = (id == 14) and 22 or (id * 2)
                }
            end
        end
    end,
	
	joker_display_def = function(JokerDisplay)
	  return {
		text = {
		  { ref_table = "card.joker_display_values", ref_value = "mult_text", colour = G.C.RED, retrigger_type = "mult" }
		},
		reminder_text = {
			{ text = "(", colour = G.C.GREY },
            { text = "7, 9, Ace", colour = G.C.IMPORTANT },
            { text = ")", colour = G.C.GREY },
		},

		calc_function = function(card)
		  local total_mult = 0
		  local text, _, scoring_hand = JokerDisplay.evaluate_hand()

		  if text ~= "Unknown" and scoring_hand then
			for _, c in pairs(scoring_hand) do
			  if not c.debuff and c.facing ~= 'back' then
				local id = c:get_id()
				if id == 7 or id == 9 or id == 14 then
				  local base_mult = (id == 14) and 22 or (id * 2)
				  total_mult = total_mult + (base_mult * JokerDisplay.calculate_card_triggers(c, scoring_hand))
				end
			  end
			end
		  end

		  card.joker_display_values.mult_text = "+" .. tostring(total_mult)
		end
	  }
	end
}
