SMODS.Joker{ --Cairn
    key = "cairn",
    config = {
        extra = {
            dollars = 0,
            odds = 2
        }
    },
    loc_txt = {
        ['name'] = 'Cairn',
        ['text'] = {
            [1] = 'Played {C:attention}Straights{} have a',
            [2] = '{C:green}#1# in #2#{} chance to increase',
            [3] = 'this Joker\'s payout by {C:money}$1{}',
            [4] = '{C:inactive}(Currently {C:money}$#3#{}{C:inactive}){}'
        },
        ['unlock'] = {
            [1] = 'Have at least {C:money}$150{}'
        }
    },
    pos = {
        x = 0,
        y = 6
    },
    display_size = {
        w = 71 * 1,
        h = 95 * 1
    },
    cost = 5,
    rarity = 1,
    blueprint_compat = false,
    eternal_compat = false,
    perishable_compat = false,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },
    unlock_condition = { type = 'money', extra = 150 },

    loc_vars = function(self, info_queue, card)
        local extra = (card and card.ability and card.ability.extra) or self.config.extra
        local num, den = SMODS.get_probability_vars(card, 1, extra.odds or 2, 'j_porkify_cairn')
        return { vars = { num, den, extra.dollars or 0 } }
    end,

    calc_dollar_bonus = function(self, card)
        local payout = tonumber(card.ability.extra.dollars) or 0
        if payout > 0 then return payout end
    end,

    calculate = function(self, card, context)
        if context.before and context.cardarea == G.jokers and not context.blueprint then
            local is_straight = context.poker_hands
                and context.poker_hands["Straight"]
                and next(context.poker_hands["Straight"])

            if is_straight and SMODS.pseudorandom_probability(
                card,
                'group_cairn_upgrade',
                1,
                card.ability.extra.odds,
                'j_porkify_cairn',
                false
            ) then
                return {
                    func = function()
                        card.ability.extra.dollars = (card.ability.extra.dollars or 0) + 1
                        card_eval_status_text(
                            context.blueprint_card or card,
                            'extra', nil, nil, nil,
                            { message = "+$1", colour = G.C.MONEY }
                        )
                        return true
                    end
                }
            end
        end
    end,

	joker_display_def = function(JokerDisplay)
	  return {
		text = {
		  { ref_table = "card.joker_display_values", ref_value = "payout_text", colour = G.C.MONEY }
		},
        reminder_text = {
           { text = "(Round)", colour = G.C.GREY }
        },
		extra = {
            {
                { ref_table = "card.joker_display_values", scale = 0.3, ref_value = "odds_text", colour = G.C.GREEN }
            }
		},

		calc_function = function(card)
		  local payout = (card.ability.extra and card.ability.extra.dollars) or 0
		  local odds = (card.ability.extra and card.ability.extra.odds) or 2
		  local num, den = 1, odds
		  if SMODS.get_probability_vars then
			local nn, dd = SMODS.get_probability_vars(card, 1, odds, 'j_porkify_cairn')
			num = nn or num
			den = dd or den
		  end

		  card.joker_display_values.payout_text = "+$" .. tostring(payout)
		  card.joker_display_values.odds_text = "(" .. tostring(num) .. " in " .. tostring(den) .. ")"
		end
	  }
	end
}
