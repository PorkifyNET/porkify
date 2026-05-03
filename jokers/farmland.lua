SMODS.Joker{ -- Farmland
    key = "farmland",
    config = {
        extra = {
            FarmerChips = 0
        }
    },
    loc_txt = {
        ['name'] = 'Farmland',
        ['text'] = {
            [1] = 'This Joker gains {C:blue}+4{} Chips',
            [2] = 'whenever a {C:attention}Jack{} is scored',
            [3] = '{C:inactive}(Currently {C:blue}+#1#{} {C:inactive}Chips){}'
        },
        ['unlock'] = {
            [1] = 'Play {C:attention}75{} {C:attention}face{} cards'
        }
    },
    pos = {
        x = 5,
        y = 2
    },
    display_size = {
        w = 71,
        h = 95
    },
    cost = 5,
    rarity = 1, -- Uncommon feels right
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },
    unlock_condition = { type = 'c_face_cards_played', extra = 75 },

    -- Show current stored Chips
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.FarmerChips or 0 } }
    end,

    calculate = function(self, card, context)
        ----------------------------------------------------------------
        -- 1) When individual cards are scored, look for Jacks
        ----------------------------------------------------------------
        if context.individual and context.cardarea == G.play and not context.blueprint then
            local c = context.other_card
            if c and c.get_id and c:get_id() == 11 then -- 11 = Jack
                card.ability.extra.FarmerChips = (card.ability.extra.FarmerChips or 0) + 4

                card_eval_status_text(
					card, 'extra', nil, nil, nil,
					{ message = "Harvest!", colour = G.C.BLUE }
				)
            end
        end

        ----------------------------------------------------------------
        -- 2) During Joker scoring, apply the stored Chip bonus
        ----------------------------------------------------------------
        if context.cardarea == G.jokers and context.joker_main then
            return {
                chips = card.ability.extra.FarmerChips or 0
            }
        end
    end,
	
	joker_display_def = function(JokerDisplay)
	  return {
		text = {
		  { ref_table = "card.joker_display_values", ref_value = "chips_text", colour = G.C.BLUE }
		},
		reminder_text = {
			{ text = "(", colour = G.C.GREY },
			{ text = "Jacks", colour = G.C.IMPORTANT },
			{ text = ")", colour = G.C.GREY }
		},

		calc_function = function(card)
		  local chips = (card.ability.extra and card.ability.extra.FarmerChips) or 0
		  card.joker_display_values.chips_text = "+" .. tostring(chips)
		end
	  }
	end
}
