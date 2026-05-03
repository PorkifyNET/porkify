
SMODS.Joker{ --:3
    key = "_3",
    config = {
        extra = {
            xmult0 = 3
        }
    },
    loc_txt = {
        ['name'] = ':3',
        ['text'] = {
            [1] = 'Every played {C:attention}3{}',
            [2] = 'grants {X:red,C:white}X3{} Mult'
        },
        ['unlock'] = {
            [1] = 'Play a {C:attention}Three of a Kind{} consisting of {C:attention}3{} {C:attention}3s{}'
        }
    },
    pos = {
        x = 7,
        y = 3
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 20,
    rarity = 4,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },
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
            if c and c.get_id and c:get_id() == 3 then
                count = count + 1
            end
        end
        return count >= 3
    end,    in_pool = function(self, args)
        return (
            not args 
            or args.source ~= 'sho' 
            or args.source == 'buf' or args.source == 'jud' or args.source == 'rif' or args.source == 'rta' or args.source == 'sou' or args.source == 'uta' or args.source == 'wra'
        )
        and true
    end,
    
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play  then
            if context.other_card:get_id() == 3 then
                return {
                    Xmult = 3
                }
            end
        end
    end,
	
	joker_display_def = function(JokerDisplay)
	  ---@type JDJokerDefinition
	  return {
		text = {
		  {
			border_nodes = {
			  { text = "X" },
			  -- Show the *computed* x_mult for the current scoring hand
			  { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
			}
		  }
		},

		calc_function = function(card)
		  local base = (card.ability.extra and card.ability.extra.xmult0) or 3
		  local count = 0

		  -- Evaluate what hand is currently being scored (JokerDisplay helper)
		  local text, _, scoring_hand = JokerDisplay.evaluate_hand()

		  if text ~= 'Unknown' and scoring_hand then
			for _, playing_card in pairs(scoring_hand) do
			  if playing_card:get_id() == 3 and not playing_card.debuff and playing_card.facing ~= 'back' then
				-- Count retriggers the way JokerDisplay expects
				count = count + JokerDisplay.calculate_card_triggers(playing_card, scoring_hand)
			  end
			end
		  end

		  -- If no 3s are scoring, display should be X1 (no effect)
		  card.joker_display_values.x_mult = (count > 0) and (base ^ count) or 1
		end
	  }
	end
}
