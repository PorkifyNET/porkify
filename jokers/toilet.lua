SMODS.Joker{ -- Toilet
    key = "toilet",
    config = {
        extra = {
            Xmult = 1
        }
    },
    loc_txt = {
        ['name'] = 'Toilet',
        ['text'] = {
            [1] = 'This Joker gains {X:mult,C:white}X0.1{} Mult',
            [2] = 'every time a played hand',
			[3] = 'contains a {C:attention}Flush{}',
			[4] = '{C:inactive}(Currently{} {X:mult,C:white}X#1#{} {C:inactive}Mult){}'
        },
        ['unlock'] = {
            [1] = 'Play a {C:attention}Flush{}'
        }
    },
    pos = {
        x = 2,
        y = 2
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
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },
    unlock_condition = { type = 'hand', extra = 'Flush' },

    loc_vars = function(self, info_queue, card)
        -- Show current Xmult with 1 decimal place
        local xm = card.ability.extra.Xmult or 1.0
        local shown = string.format('%.1f', xm)
        return { vars = { shown } }
    end,

    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.joker_main then
            local ph = context.poker_hands or {}
			
            -- Check if this scored hand is flush-like
            local is_flush_like =
                (ph.Flush and next(ph.Flush)) or
                (ph["Straight Flush"] and next(ph["Straight Flush"])) or
                (ph["Flush Five"] and next(ph["Flush Five"]))

            if is_flush_like and not context.blueprint then
                card.ability.extra.Xmult = (card.ability.extra.Xmult or 1.0) + 0.1
				
				G.E_MANAGER:add_event(Event({
                    func = function()
                        card_eval_status_text(
                            card, 'extra', nil, nil, nil,
                            { message = "Flushed!", colour = G.C.CHIPS }
                        )
                        return true
                    end
                }))
            end

            return {
                Xmult = card.ability.extra.Xmult or 1.0
            }
        end
    end,
	
	joker_display_def = function(JokerDisplay)
	  return {
		text = {
		  {
			border_nodes = {
			  { text = "X" },
			  { ref_table = "card.joker_display_values", ref_value = "x_mult" }
			}
		  }
		},
		reminder_text = {
			{ text = "(", colour = G.C.GREY },
			{ text = "Flush", colour = G.C.IMPORTANT },
			{ text = ")", colour = G.C.GREY }
		},

		calc_function = function(card)
		  local xm = (card.ability.extra and card.ability.extra.Xmult) or 1.0
		  card.joker_display_values.x_mult = string.format("%.1f", xm)
		end
	  }
	end
}
