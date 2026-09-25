local function porkify_toilet_contains_flush(cards)
    if type(cards) ~= "table" or #cards < 5 then
        return false
    end

    local poker_hands = evaluate_poker_hand(cards) or {}
    for _, hand_name in ipairs({ "Flush", "Straight Flush", "Flush House", "Flush Five" }) do
        local matches = poker_hands[hand_name]
        if type(matches) == "table" and next(matches) then
            return true
        end
    end

    return false
end

SMODS.Joker{ -- Toilet
    key = "toilet",
    config = {
        extra = {
            Xmult = 1,
            Xmult_gain = 0.25
        }
    },
    loc_txt = {
        ['name'] = 'Toilet',
        ['text'] = {
            [1] = 'This Joker gains {X:mult,C:white}X#1#{} Mult',
            [2] = 'every time a {C:red}discarded{} hand',
            [3] = 'contains a {C:attention}Flush{}',
            [4] = '{C:inactive}(Currently{} {X:mult,C:white}X#2#{} {C:inactive}Mult){}'
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
    perishable_compat = false,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },
    unlock_condition = { type = 'hand', extra = 'Flush' },

    loc_vars = function(self, info_queue, card)
        local extra = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { extra.Xmult_gain or 0.25, extra.Xmult or 1 } }
    end,

    calculate = function(self, card, context)
        if context.pre_discard and not context.blueprint then
            local discarded_cards = (G and G.hand and G.hand.highlighted) or {}
            if porkify_toilet_contains_flush(discarded_cards) then
                local extra = card.ability.extra
                extra.Xmult = (extra.Xmult or 1) + (extra.Xmult_gain or 0.25)

                return {
                    message = "Upgrade!",
                    colour = G.C.MULT
                }
            end
        end

        if context.cardarea == G.jokers and context.joker_main then
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
		  }
		},
		reminder_text = {
			{ text = "(" },
			{ text = "Flush", colour = G.C.IMPORTANT },
			{ text = ")" }
		},

		calc_function = function(card)
		  local xm = (card.ability.extra and card.ability.extra.Xmult) or 1
		  card.joker_display_values.x_mult = xm
		end
	  }
	end
}
