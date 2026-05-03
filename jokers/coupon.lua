SMODS.Joker{ --Coupon
    key = "coupon",
    config = {
        extra = {
            dollars_per_voucher = 1
        }
    },
    loc_txt = {
        ['name'] = 'Coupon',
        ['text'] = {
            [1] = 'Earn {C:money}$1{} per redeemed',
            [2] = '{C:attention}Voucher{} at end of round',
            [3] = '{C:inactive}(Currently {C:money}$#1#{}{C:inactive}){}'
        },
        ['unlock'] = {
            [1] = 'Spend {C:money}$500{} in the shop'
        }
    },
    pos = {
        x = 5,
        y = 4
    },
    display_size = {
        w = 71 * 1,
        h = 95 * 1
    },
    cost = 5,
    rarity = 2,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = false,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },
    unlock_condition = { type = 'c_shop_dollars_spent', extra = 500 },

    loc_vars = function(self, info_queue, card)
        local per = ((card and card.ability and card.ability.extra) or self.config.extra).dollars_per_voucher or 1
        local used_vouchers = (G and G.GAME and G.GAME.used_vouchers) or {}
        local count = 0
        for _, redeemed in pairs(used_vouchers) do
            if redeemed then
                count = count + 1
            end
        end
        return { vars = { count * per } }
    end,

    calc_dollar_bonus = function(self, card)
        local per = ((card and card.ability and card.ability.extra) or self.config.extra).dollars_per_voucher or 1
        local used_vouchers = (G and G.GAME and G.GAME.used_vouchers) or {}
        local count = 0
        for _, redeemed in pairs(used_vouchers) do
            if redeemed then
                count = count + 1
            end
        end

        local payout = count * per
        if payout > 0 then
            return payout
        end
    end,

    calculate = function(self, card, context)
    end,

	joker_display_def = function(JokerDisplay)
	  return {
		text = {
		  { ref_table = "card.joker_display_values", ref_value = "money_text", colour = G.C.MONEY }
		},

		calc_function = function(card)
		  local per = ((card.ability and card.ability.extra) or {}).dollars_per_voucher or 1
		  local used_vouchers = (G and G.GAME and G.GAME.used_vouchers) or {}
		  local count = 0
		  for _, redeemed in pairs(used_vouchers) do
			if redeemed then
			  count = count + 1
			end
		  end

		  card.joker_display_values.money_text = "+$" .. tostring(count * per)
		end
	  }
	end
}
