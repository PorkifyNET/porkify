
SMODS.Consumable {
    key = 'bingo',
    set = 'porkify',
    pos = { x = 1, y = 0 },
    config = { 
        extra = {
            odds = 4   
        } 
    },
    loc_txt = {
        name = 'Bingo',
        text = {
            [1] = '{C:green}#1# in #2#{} chance to',
            [2] = 'redeem a random {C:attention}Voucher{}'
        }
    },
    cost = 3,
    unlocked = true,
    discovered = false,
    hidden = false,
    can_repeat_soul = false,
    atlas = 'CustomConsumables',
    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'c_modprefix_bingo')
        return {vars = {numerator, denominator}}
    end,
    use = function(self, card, area, copier)
		local used_card = copier or card

		local hit = SMODS.pseudorandom_probability(
			card,
			'group_0_ce35c3f5',
			1,
			card.ability.extra.odds,
			'j_modprefix_bingo',
			false
		)

		if hit then
			local voucher_key = pseudorandom_element(G.P_CENTER_POOLS.Voucher, "7b517a8b").key
			local voucher_card = SMODS.create_card{ area = G.play, key = voucher_key }

			voucher_card:start_materialize()
			voucher_card.cost = 0
			G.play:emplace(voucher_card)

			delay(0.8)
			voucher_card:redeem()

			G.E_MANAGER:add_event(Event({
				trigger = 'after',
				delay = 0.5,
				func = function()
					voucher_card:start_dissolve()
					return true
				end
			}))

			card_eval_status_text(
				used_card,
				'extra',
				nil, nil, nil,
				{ message = "BINGO!", colour = G.C.GREEN }
			)
		else
			card_eval_status_text(
				used_card,
				'extra',
				nil, nil, nil,
				{ message = "No luck", colour = G.C.RED }
			)
		end
	end,
    can_use = function(self, card)
        return true
    end
}