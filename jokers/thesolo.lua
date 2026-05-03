SMODS.Joker{ --The Solo
    key = "thesolo",
    config = {
        extra = {}
    },
    loc_txt = {
        ['name'] = 'The Solo',
        ['text'] = {
            [1] = '{X:red,C:white}X5{} Mult if played hand',
            [2] = 'only has {C:attention}1{} card'
        },
        ['unlock'] = {
            [1] = 'Play a {C:blue}hand{} with only {C:attention}1{} card'
        }
    },
    pos = {
        x = 1,
        y = 2
    },
    display_size = {
        w = 71,
        h = 95
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
    check_for_unlock = function(self, args)
        return args.type == 'hand_contents' and args.cards and #args.cards == 1
    end,    
    calculate = function(self, card, context)
        -- Global Joker scoring stage
        if context.cardarea == G.jokers and context.joker_main then
            local full_hand = context.full_hand or G.play and G.play.cards or {}
            
            if #full_hand == 1 then
                return {
                    Xmult = 5
                }
            end
        end
    end,
	
	joker_display_def = function(JokerDisplay)
	  return {
		text = {
		  -- X5 line
		  {
			border_nodes = {
			  { text = "X" },
			  { text = "5" }
			}
		  }
		},
		reminder_text = {
			{ ref_table = "card.joker_display_values", ref_value = "status_text", colour = G.C.GREY }
		},

		calc_function = function(card)
		  local status = "OFF"
		  local text, _, scoring_hand = JokerDisplay.evaluate_hand()

		  if text ~= "Unknown" and scoring_hand and #scoring_hand == 1 then
			status = "ON"
		  else
			status = "OFF (need 1)"
		  end

		  card.joker_display_values.status_text = status
		end
	  }
	end
}
