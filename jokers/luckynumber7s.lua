SMODS.Joker{ -- Lucky Number 7s
    key = "luckynumber7s",
    config = {
        extra = {}
    },
    loc_txt = {
        ['name'] = 'Lucky Number 7s',
        ['text'] = {
            [1] = 'Every played {C:attention}7{} grants',
            [2] = '{C:red}+7{} Mult and {C:money}$3{}'
        },
        ['unlock'] = {
            [1] = 'Play a {C:attention}Three of a Kind{}',
            [2] = 'consisting of {C:attention}3{} {C:attention}7s{}'
        }
    },
    pos = {
        x = 9,
        y = 0
    },
    display_size = {
        w = 71,
        h = 95
    },
    cost = 5,
    rarity = 1,
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
        if not (eval and next(eval["Three of a Kind"]))
            or (eval["Four of a Kind"] and next(eval["Four of a Kind"]))
            or (eval["Full House"] and next(eval["Full House"])) then
            return false
        end

        local sevens = 0
        for _, c in ipairs(args.cards) do
            if c and c.get_id and c:get_id() == 7 then
                sevens = sevens + 1
            end
        end

        return sevens >= 3
    end,
    
    loc_vars = function(self, info_queue, card)
        -- no extra vars needed, but kept for consistency
        return { vars = {} }
    end,
    
    calculate = function(self, card, context)
        -- Individual card scoring context for played cards
        if context.individual and context.cardarea == G.play then
            local c = context.other_card
            if c and c:get_id() == 7 then
                return {
                    mult = 7,
                    dollars = 3
                }
            end
        end
    end,
	
	joker_display_def = function(JokerDisplay)
	  return {
		text = {
		  { ref_table = "card.joker_display_values", ref_value = "mult_text", colour = G.C.RED, retrigger_type = "mult" },
		  { text = " " },
		  { ref_table = "card.joker_display_values", ref_value = "money_text", colour = G.C.MONEY, retrigger_type = "mult" }
		},
		reminder_text = {
			{ text = "(7)", colour = G.C.GREY }
		},

		calc_function = function(card)
		  local sevens = 0

		  local text, _, scoring_hand = JokerDisplay.evaluate_hand()
		  if text ~= "Unknown" and scoring_hand then
			for _, c in pairs(scoring_hand) do
			  if c:get_id() == 7 and not c.debuff and c.facing ~= 'back' then
				sevens = sevens + JokerDisplay.calculate_card_triggers(c, scoring_hand)
			  end
			end
		  end

		  card.joker_display_values.mult_text  = "+" .. tostring(sevens * 7)
		  card.joker_display_values.money_text = "+$" .. tostring(sevens * 3)
		end
	  }
	end
}
