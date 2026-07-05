SMODS.Joker{ -- Ace Joker
    key = "acejoker",
    config = {
        extra = {}
    },
    loc_txt = {
        ['name'] = 'Ace Joker',
        ['text'] = {
            [1] = '{X:red,C:white}X3{} Mult if played hand',
            [2] = 'contains an {C:attention}Ace{} of {C:spades}Spades{}'
        },
        ['unlock'] = {
            [1] = 'Play a hand containing an {C:attention}Ace{} of {C:spades}Spades{}'
        }
    },
    pos = { x = 6, y = 2 }, -- adjust as needed
    display_size = { w = 71, h = 95 },
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
        for _, c in ipairs(args.cards) do
            if porkify_card_matches_rank(c, 14) and c.is_suit and c:is_suit("Spades") then
                return true
            end
        end
        return false
    end,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.joker_main then
            local scoring_hand = context.scoring_hand or context.full_hand or {}
            local has_ace_spades = false

            for _, c in ipairs(scoring_hand) do
                -- In Balatro, Ace is rank 14, Jack 11, Queen 12, King 13
                if porkify_card_matches_rank(c, 14) and c:is_suit("Spades") then
                    has_ace_spades = true
                    break
                end
            end

            if has_ace_spades then
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
			  { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
			}
		  }
		},
		reminder_text = {
			{ text = "(", colour = G.C.GREY },
			{ text = "Ace of Spades", colour = lighten(G.C.SUITS["Spades"], 0.35) },
			{ text = ")", colour = G.C.GREY }
		},

		calc_function = function(card)
		  local x = 1

		  -- JokerDisplay helper: what hand is currently being evaluated?
		  local text, _, scoring_hand = JokerDisplay.evaluate_hand()
		  if text ~= 'Unknown' and scoring_hand then
			for _, c in pairs(scoring_hand) do
			  if porkify_card_matches_rank(c, 14) and c:is_suit("Spades") and not c.debuff and c.facing ~= 'back' then
				x = 3
				break
			  end
			end
		  end

		  card.joker_display_values.x_mult = x
		end
	  }
	end

}
