SMODS.Joker{ --Spectrum
    key = "spectrum",
    config = {
        extra = {}
    },
    loc_txt = {
        ['name'] = 'Spectrum',
        ['text'] = {
            [1] = '{X:red,C:white}X1{} Mult for each ',
            [2] = '{C:attention}suit{} after the {C:attention}second{}',
            [3] = 'in the played {C:blue}hand{}'
        },
    },
    pos = {
        x = 4,
        y = 6
    },
    display_size = {
        w = 71,
        h = 95
    },
    cost = 6,
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
            local suits = {}

            for _, c in ipairs(scoring_hand) do
                if c and c.base and c.base.suit then
                    suits[c.base.suit] = true
                end
            end

            local suit_count = 0
            for _ in pairs(suits) do
                suit_count = suit_count + 1
            end

            if suit_count == 3 then
                return {
                    Xmult = 2
                }
            elseif suit_count >= 4 then
                return {
                    Xmult = 3
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
			  { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
			}
		  }
		},

		calc_function = function(card)
		  local x = 1
		  local suit_count = 0
		  local suits = {}
		  local text, _, scoring_hand = JokerDisplay.evaluate_hand()

		  if text ~= "Unknown" and scoring_hand then
			for _, c in pairs(scoring_hand) do
			  if c and not c.debuff and c.facing ~= 'back' and c.base and c.base.suit then
				suits[c.base.suit] = true
			  end
			end
		  end

		  for _ in pairs(suits) do
			suit_count = suit_count + 1
		  end

		  if suit_count == 3 then
			x = 2
		  elseif suit_count >= 4 then
			x = 3
		  end

		  card.joker_display_values.x_mult = x
		  card.joker_display_values.suits_text = "(" .. tostring(suit_count) .. " suits)"
		end
	  }
	end
}
