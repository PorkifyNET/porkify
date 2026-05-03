SMODS.Joker{ -- Chicken
    key = "paul",
    config = {
        extra = {
            egg_odds     = 2,  -- base 1 in 2 chance to create Egg
            hatched_odds = 4,  -- base 1 in 4 chance to create Hatched Egg
            destroy_odds = 10, -- 1 in 10 to destroy self
        }
    },
    loc_txt = {
        ['name'] = 'Paul',
        ['text'] = {
            [1] = '{C:green}#1# in #2#{} chance to create',
            [2] = 'an {C:attention}Egg{} Joker at end of round',
            [3] = '{C:green}#3# in #4#{} chance to create',
            [4] = 'a {C:attention}Hatched Egg{} Joker',
            [5] = '{C:green}#5# in #6#{} chance this Joker',
            [6] = 'is {C:red}destroyed{} at end of round'
        },
        ['unlock'] = {
            [1] = 'Sell {C:attention}10{} cards'
        }
    },
    pos = {
        x = 4,
        y = 2
    },
    display_size = {
        w = 71,
        h = 95
    },
    cost = 5,
    rarity = 2,
    blueprint_compat = false,
    eternal_compat = false,
    perishable_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },
    unlock_condition = { type = 'c_cards_sold', extra = 10 },

    -- Show Egg, Hatched Egg, and destroy odds + show Egg / Hatched Egg in info queue
    loc_vars = function(self, info_queue, card)
		-- Only show Egg in info queue to avoid circular reference with Hatched Egg
		local egg_center = G.P_CENTERS["j_egg"]
		if egg_center then
			info_queue[#info_queue + 1] = egg_center
		end

		-- SAFE access to odds: fall back to config.extra if ability.extra is missing
		local extra = (card and card.ability and card.ability.extra) or self.config.extra or {}

		local egg_odds     = extra.egg_odds     or 2
		local hatched_odds = extra.hatched_odds or 4
		local destroy_odds = extra.destroy_odds or 10

		local egg_num, egg_den = SMODS.get_probability_vars(
			card, 1, egg_odds, 'j_porkify_chicken_egg'
		)
		local hatch_num, hatch_den = SMODS.get_probability_vars(
			card, 1, hatched_odds, 'j_porkify_chicken_hatched'
		)
		local dest_num, dest_den = SMODS.get_probability_vars(
			card, 1, destroy_odds, 'j_porkify_chicken_destroy'
		)

		return {
			vars = {
				egg_num,   egg_den,
				hatch_num, hatch_den,
				dest_num,  dest_den
			}
		}
	end,

    calculate = function(self, card, context)
        -- End-of-round: Egg roll, Hatched Egg roll, then possible self-destruction
        if context.end_of_round
            and not context.game_over
            and context.main_eval
            and not context.blueprint then

            return {
                func = function()
                    ----------------------------------------------------
                    -- 1) Roll for Egg Joker (1 in egg_odds)
                    ----------------------------------------------------
                    if SMODS.pseudorandom_probability(
                        card,
                        'group_chicken_egg',
                        1,
                        card.ability.extra.egg_odds,
                        'j_porkify_chicken_egg',
                        false
                    ) then
						G.E_MANAGER:add_event(Event({
							func = function()
								local egg = SMODS.add_card({
									set = 'Joker',
									key = 'j_egg'
								})
								G.GAME.joker_buffer = 0
								if egg then
									card_eval_status_text(
										egg, 'extra', nil, nil, nil,
										{ message = "Laid Egg!", colour = G.C.GREEN }
									)
								end
								return true
							end
						}))
                    end

                    ----------------------------------------------------
                    -- 2) Roll for Hatched Egg Joker (1 in hatched_odds)
                    ----------------------------------------------------
                    if SMODS.pseudorandom_probability(
                        card,
                        'group_chicken_hatched',
                        1,
                        card.ability.extra.hatched_odds,
                        'j_porkify_chicken_hatched',
                        false
                    ) then
						G.E_MANAGER:add_event(Event({
							func = function()
								local hatch = SMODS.add_card({
									set = 'Joker',
									key = 'j_porkify_hatchedegg'
								})
								G.GAME.joker_buffer = 0
								if hatch then
									card_eval_status_text(
										hatch, 'extra', nil, nil, nil,
										{ message = "Grown Up!", colour = G.C.GREEN }
									)
								end
								return true
							end
						}))
                    end

                    ----------------------------------------------------
                    -- 3) Roll for self-destruction (1 in destroy_odds)
                    ----------------------------------------------------
                    if SMODS.pseudorandom_probability(
                        card,
                        'group_chicken_destroy',
                        1,
                        card.ability.extra.destroy_odds,
                        'j_porkify_chicken_destroy',
                        false
                    ) then
                        SMODS.calculate_effect({ func = function()
                            local target_joker = card
                            if target_joker then
                                if target_joker.ability.eternal then
                                    target_joker.ability.eternal = nil
                                end
                                target_joker.getting_sliced = true
                                G.E_MANAGER:add_event(Event({
                                    func = function()
                                        target_joker:start_dissolve({ G.C.RED }, nil, 1.6)
                                        return true
                                    end
                                }))
                                card_eval_status_text(
                                    context.blueprint_card or card,
                                    'extra', nil, nil, nil,
                                    { message = "Died!", colour = G.C.RED }
                                )
                            end
                            return true
                        end }, card)
                    end

                    return true
                end
            }
        end
    end
}
