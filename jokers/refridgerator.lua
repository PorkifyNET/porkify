SMODS.Joker{ --Refridgerator
    key = "refridgerator",
    config = {
        extra = {
            RefridgeratorXChips = 1
        }
    },
    loc_txt = {
        ['name'] = 'Refridgerator',
        ['text'] = {
            [1] = 'When {C:attention}Blind{} is selected, {C:red}destroy{} all',
            [2] = '{C:attention}Food Jokers{} and add {X:blue,C:white}X0.5{} Chips',
            [3] = 'for each one consumed',
            [4] = '{C:inactive}(Currently {}{X:blue,C:white}X#1#{} {C:inactive}Chips){}'
        },
        ['unlock'] = {
            [1] = 'Sell {C:attention}5{} Jokers'
        }
    },
    pos = {
        x = 4,
        y = 1
    },
    display_size = {
        w = 71,
        h = 95
    },
    cost = 8,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["porkify_porkify_jokers"] = true },
    unlock_condition = { type = 'c_jokers_sold', extra = 5 },
    
    loc_vars = function(self, info_queue, card)
        local xchips = 1
        if card and card.ability and card.ability.extra then
            xchips = card.ability.extra.RefridgeratorXChips or 1
        end
        return { vars = { xchips } }
    end,
    
    calculate = function(self, card, context)
        -- keys of all Food Jokers
        local food_keys = {
            j_gros_michel = true,
            j_egg = true,
            j_ice_cream = true,
            j_cavendish = true,
            j_turtle_bean = true,
            j_diet_cola = true,
            j_popcorn = true,
            j_ramen = true,
            j_selzer = true,
            j_porkify_cupofcoffee = true,
			j_porkify_hotdog = true,
			j_porkify_hamburger = true,
            j_porkify_taco = true,
            j_porkify_pizza = true,
            j_porkify_leek = true,
        }

        -- Consume all non-Eternal Food Jokers when blind is set
        if context.setting_blind and not context.blueprint then
            local valid_food_jokers = {}

            for _, v in pairs(G.jokers.cards or {}) do
                local key = v.config and v.config.center and v.config.center.key
                if key and food_keys[key] and not (v.ability and v.ability.eternal) then
                    valid_food_jokers[#valid_food_jokers + 1] = v
                end
            end

            if #valid_food_jokers == 0 then
                return
            end

            return {
                func = function()
                    local consumed = 0
                    local targets = {}

                    for _, target_joker in ipairs(valid_food_jokers) do
                        if target_joker and not target_joker.getting_sliced then
                            consumed = consumed + 1
                            targets[#targets + 1] = target_joker
                        end
                    end

                    if consumed == 0 then
                        return true
                    end

                    card.ability.extra.RefridgeratorXChips = (card.ability.extra.RefridgeratorXChips or 1) + (0.5 * consumed)

                    G.E_MANAGER:add_event(Event({
                        trigger = 'before',
                        delay = 0.75,
                        blocking = false,
                        func = function()
                            for _, target_joker in ipairs(targets) do
                                if target_joker and target_joker.start_dissolve then
                                    target_joker.getting_sliced = true
                                    target_joker:start_dissolve({ G.C.RED }, nil, 1.6)
                                    card_eval_status_text(
                                        target_joker, 'extra', nil, nil, nil,
                                        { message = "Consumed!", colour = G.C.RED }
                                    )
                                end
                            end
                            return true
                        end
                    }))

                    card_eval_status_text(
                        card, 'extra', nil, nil, nil,
                        { message = "Cooled!", colour = G.C.BLUE }
                    )
                    return true
                end
            }
        end

        -- Apply stored X Chips during scoring
        if context.cardarea == G.jokers and context.joker_main then
            return {
                x_chips = card.ability.extra.RefridgeratorXChips or 1
            }
        end
    end,
	
	joker_display_def = function(JokerDisplay)
	  return {
		text = {
		  {
			border_nodes = {
			  { text = "X", colour = G.C.WHITE },
			  { ref_table = "card.joker_display_values", ref_value = "chips_text", colour = G.C.WHITE }
			},
			colour = G.C.BLUE
		  }
		},
		reminder_text = {
			{ ref_table = "card.joker_display_values", ref_value = "gain_text", colour = G.C.BLUE }
		},
		style_function = function(card, text, reminder_text, extra)
		  if text and text.children and text.children[1] then
			text.children[1].config.colour = G.C.BLUE
		  end
		  return false
		end,

		calc_function = function(card)
		  local stored = (card.ability.extra and card.ability.extra.RefridgeratorXChips) or 1

		  local food_keys = {
			j_gros_michel = true, j_egg = true, j_ice_cream = true, j_cavendish = true,
			j_turtle_bean = true, j_diet_cola = true, j_popcorn = true, j_ramen = true,
			j_selzer = true,
			j_porkify_cupofcoffee = true, j_porkify_hotdog = true, j_porkify_hamburger = true,
		  }

		  local count = 0
		  for _, v in ipairs(G.jokers and G.jokers.cards or {}) do
			local key = v and v.config and v.config.center and v.config.center.key
			if key and food_keys[key] and not (v.ability and v.ability.eternal) then count = count + 1 end
		  end

		  card.joker_display_values.chips_text = tostring(stored)
		  card.joker_display_values.gain_text  = count > 0 and ("X" .. tostring(count * 0.5) .. " next blind") or "No food to consume"
		end
	  }
	end
}
