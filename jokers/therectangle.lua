SMODS.Joker{ --The Rectangle
    key = "therectangle",
    config = {
        extra = {
            Xmult = 1,
            Xmult_gain = 0.4
        }
    },
    loc_txt = {
        ['name'] = 'The Rectangle',
        ['text'] = {
            [1] = 'This Joker gains {X:mult,C:white}X#2#{} Mult',
            [2] = 'if played hand contains',
            [3] = 'a {C:attention}Four of a Kind{}',
            [4] = '{C:inactive}(Currently{} {X:mult,C:white}X#1#{} {C:inactive}Mult){}'
        },
        ['unlock'] = {
            [1] = 'Play a {C:attention}Four of a Kind{}'
        }
    },
    pos = {
        x = 6,
        y = 1
    },
    display_size = {
        w = 71,
        h = 95
    },
    cost = 6,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["porkify_porkify_jokers"] = true },
    unlock_condition = { type = 'hand', extra = 'Four of a Kind' },

    loc_vars = function(self, info_queue, card)
        local xm = (card and card.ability and card.ability.extra and card.ability.extra.Xmult) or 1
        local gain = (card and card.ability and card.ability.extra and card.ability.extra.Xmult_gain) or 0.4
        return { vars = { xm, string.format('%.1f', gain) } }
    end,

    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.joker_main then
            local ph = context.poker_hands or {}
            local has_four_kind = ph["Four of a Kind"] and next(ph["Four of a Kind"])

            if has_four_kind and not context.blueprint then
                card.ability.extra.Xmult = (card.ability.extra.Xmult or 1) + (card.ability.extra.Xmult_gain or 0.4)

                G.E_MANAGER:add_event(Event({
                    func = function()
                        card_eval_status_text(
                            card, 'extra', nil, nil, nil,
                            { message = "Upgrade!", colour = G.C.MULT }
                        )
                        return true
                    end
                }))
            end

            return {
                Xmult = card.ability.extra.Xmult or 1
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
		  },
		},

		calc_function = function(card)
		  local xm = (card.ability and card.ability.extra and card.ability.extra.Xmult) or 1
		  card.joker_display_values.x_mult = xm
		end
	  }
	end
}
