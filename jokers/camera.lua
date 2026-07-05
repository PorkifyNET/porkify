
SMODS.Joker{ --Camera
    key = "camera",
    config = {
        extra = {
            chips0 = 100
        }
    },
    loc_txt = {
        ['name'] = 'Camera',
        ['text'] = {
            [1] = 'First played {C:attention}face{} card',
            [2] = 'grants {C:blue}+100{} Chips when',
            [3] = 'scored'
        },
        ['unlock'] = {
            [1] = 'Play {C:attention}100{} {C:attention}face{} cards'
        }
    },
    pos = {
        x = 8,
        y = 4
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 4,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },
    unlock_condition = { type = 'c_face_cards_played', extra = 100 },
    
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play  then
            if (function()
                for i = 1, #context.scoring_hand do
                    local scoring_card = context.scoring_hand[i]
                    if porkify_card_is_face_or_blank(scoring_card) then
                        return scoring_card == context.other_card
                    end
                end
                return false
            end)() then
                return {
                    chips = 100
                }
            end
        end
    end,
	
	joker_display_def = function(JokerDisplay)
	  return {
		text = {
		  { ref_table = "card.joker_display_values", ref_value = "chips", retrigger_type = "mult", colour = G.C.BLUE }
		},
		reminder_text = {
			{ text = "(", colour = G.C.GREY },
			{ text = "Face Cards", colour = G.C.IMPORTANT },
			{ text = ")", colour = G.C.GREY }
		},

		calc_function = function(card)
		  local chips = 0
		  local base = (card.ability.extra and card.ability.extra.chips0) or 100

		  local text, _, scoring_hand = JokerDisplay.evaluate_hand()
		  if text ~= "Unknown" and scoring_hand then
			for _, c in ipairs(scoring_hand) do
			  if porkify_card_is_face_or_blank(c) and not c.debuff and c.facing ~= "back" then
				chips = base
				break
			  end
			end
		  end

		  card.joker_display_values.chips = "+" .. tostring(chips)
		end
	  }
	end
}
