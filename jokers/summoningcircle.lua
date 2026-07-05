
SMODS.Joker{ --Summoning Circle
    key = "summoningcircle",
    config = {
        extra = {
            odds = 2
        }
    },
    loc_txt = {
        ['name'] = 'Summoning Circle',
        ['text'] = {
            [1] = 'Every played {C:attention}6{} has a',
            [2] = '{C:green}#1# in #2#{} chance to create',
            [3] = 'a random {C:purple}Porkify{} card',
            [4] = '{C:inactive}(Must have room){}'
        },
        ['unlock'] = {
            [1] = 'Have {C:attention}3{} {C:dark_edition}editioned{} Jokers'
        }
    },
    pos = {
        x = 9,
        y = 4
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
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
    unlock_condition = { type = 'have_edition', extra = 3 },

    loc_vars = function(self, info_queue, card)
        local extra = (card and card.ability and card.ability.extra) or self.config.extra
        local odds = (extra and extra.odds) or (self.config.extra and self.config.extra.odds) or 2
        local num, den = SMODS.get_probability_vars(card, 1, odds, 'j_porkify_summoningcircle')
        return { vars = { num, den } }
    end,
    
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            local odds = (card.ability and card.ability.extra and card.ability.extra.odds) or (self.config.extra and self.config.extra.odds) or 2
            if played_card
                and played_card.get_id
                and porkify_card_matches_rank(played_card, 6)
                and SMODS.pseudorandom_probability(
                    card,
                    'group_summoningcircle_porkify',
                    1,
                    odds,
                    'j_porkify_summoningcircle',
                    false
                ) then
                return {
                    func = function()
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            delay = 0.4,
                            func = function()
                                if #G.consumeables.cards < G.consumeables.config.card_limit then
                                    local created = SMODS.add_card({ set = 'porkify' })
                                    if created then
                                        play_sound('timpani')
                                        card:juice_up(0.3, 0.5)
                                        card_eval_status_text(
                                            created,
                                            'extra', nil, nil, nil,
                                            { message = "Summoned!", colour = G.C.PURPLE }
                                        )
                                    end
                                end
                                return true
                            end
                        }))
                        return true
                    end
                }
            end
        end
    end,
	
	joker_display_def = function(JokerDisplay)
	  return {
		text = {
		  { ref_table = "card.joker_display_values", scale = 0.3, ref_value = "odds_text", colour = G.C.GREEN }
        },

		calc_function = function(card)
		  local sixes = 0
          local odds = (card.ability.extra and card.ability.extra.odds) or 2
          local num, den = 1, odds
		  local text, _, scoring_hand = JokerDisplay.evaluate_hand()

          if SMODS.get_probability_vars then
            local nn, dd = SMODS.get_probability_vars(card, 1, odds, 'j_porkify_summoningcircle')
            num = nn or num
            den = dd or den
          end

		  if text ~= "Unknown" and scoring_hand then
			for _, c in pairs(scoring_hand) do
			  if porkify_card_matches_rank(c, 6) and not c.debuff and c.facing ~= 'back' then
				sixes = sixes + 1
			  end
			end
		  end

		  card.joker_display_values.odds_text = "(" .. tostring(num) .. " in " .. tostring(den) .. ")"
		end
	  }
	end
}
