SMODS.Joker{ -- Hatched Egg
    key = "hatchedegg",
    config = {
        extra = {
            egg_odds = 2,  -- base 1 in 2 chance to become Chicken
        }
    },
    loc_txt = {
        ['name'] = 'Hatched Egg',
        ['text'] = {
            [1] = '{C:green}#1# in #2#{} chance to replace',
            [2] = 'this Joker with a {C:attention}Paul{}',
            [3] = 'Joker at end of round'
        },
        ['unlock'] = {
            [1] = 'Sell {C:attention}20{} cards'
        }
    },
    pos = {
        x = 7,
        y = 2
    },
    display_size = {
        w = 71,
        h = 95
    },
    cost = 1,
    rarity = 1,
    blueprint_compat = false,
    eternal_compat = false,
    perishable_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },
    unlock_condition = { type = 'c_cards_sold', extra = 20 },

    loc_vars = function(self, info_queue, card)
        -- Show the Chicken Joker in the info queue
        local info_queue_0 = G.P_CENTERS["j_porkify_paul"]
        if info_queue_0 then
            info_queue[#info_queue + 1] = info_queue_0
        else
            error('Invalid key "j_porkify_paul" in info_queue')
        end

        -- Probability display: #1# in #2#
        local num, den = SMODS.get_probability_vars(
            card,
            1,
            card.ability.extra.egg_odds,
            'j_porkify_chick_growup'
        )
        return { vars = { num, den } }
    end,

    calculate = function(self, card, context)
        if context.end_of_round
            and not context.game_over
            and context.main_eval
            and not context.blueprint then

            return {
                func = function()
                    -- Roll once for hatching into Chicken
                    if SMODS.pseudorandom_probability(
                        card,
                        'group_chick_growup',
                        1,
                        card.ability.extra.egg_odds,
                        'j_porkify_chick_growup',
                        false
                    ) then
                        -- Spawn Chicken Joker
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                local chicken = SMODS.add_card({
                                    set = 'Joker',
                                    key = 'j_porkify_paul'
                                })
                                if chicken then
                                    card_eval_status_text(
                                        chicken, 'extra', nil, nil, nil,
                                        { message = "Grown Up!", colour = G.C.GREEN }
                                    )
                                end
                                return true
                            end
                        }))

                        -- Destroy this Hatched Egg
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
                                    'extra', nil, nil, nil, {}
                                )
                            end
                            return true
                        end }, card)
                    end

                    return true
                end
            }
        end
    end,

    joker_display_def = function(JokerDisplay)
	  return {
		text = {
		  { text = "(1 in 2)", scale = 0.3, colour = G.C.GREEN }
		},
	  }
	end
}
