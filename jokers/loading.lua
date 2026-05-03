SMODS.Joker{ -- Patience / Loading
    key = "loading",
    config = {
        extra = {
            CurrentJoker = 'j_joker',
            CurrentJokerName = 'Joker',
        }
    },
    loc_txt = {
        ['name'] = 'Loading...',
        ['text'] = {
            [1] = 'Sell this Joker to gain a',
            [2] = '{C:attention}#1#{}',
            [3] = '{C:inactive}(Joker changes every Hand){}'
        },
        ['unlock'] = {
            [1] = 'Sell {C:attention}15{} cards'
        }
    },
    pos = { x = 7, y = 0 },
    display_size = { w = 71, h = 95 },
    cost = 5,
    rarity = 1,
    blueprint_compat = false,
    eternal_compat = false,
    perishable_compat = false,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["porkify_porkify_jokers"] = true },
    unlock_condition = { type = 'c_cards_sold', extra = 15 },

    loc_vars = function(self, info_queue, card)
		-- 1) Determine which joker key we should show
		local key = (self.config and self.config.extra and self.config.extra.CurrentJoker) or 'j_joker'
		local name = (self.config and self.config.extra and self.config.extra.CurrentJokerName) or 'Joker'

		if card and card.ability and card.ability.extra then
			key  = card.ability.extra.CurrentJoker     or key
			name = card.ability.extra.CurrentJokerName or name
		end

		-- 2) Push that Joker into the info queue (so it shows its tooltip/details)
		if G and G.P_CENTERS and key then
			local center = G.P_CENTERS[key]
			if center then
				info_queue[#info_queue + 1] = center
			else
				-- Optional: safer than hard error if you don't want crashes
				-- print(("Loading Joker: invalid key in info_queue: %s"):format(tostring(key)))
				error(("Loading Joker: invalid key in info_queue: %s"):format(tostring(key)))
			end
		end

		-- 3) Provide vars for your loc text (#1#)
		return { vars = { name } }
	end,

    calculate = function(self, card, context)
        ----------------------------------------------------------------
        -- Change target Joker every hand (after a hand resolves)
        ----------------------------------------------------------------
        if context.after and context.cardarea == G.jokers and not context.blueprint then
            local possible = {}

            for _, center in pairs(G.P_CENTER_POOLS.Joker or {}) do
                local r = center.rarity

                local is_ruleset = (r == "porkify_ruleset")
                local is_legendary = (type(r) == "number" and r >= 4)

                if center.unlocked
                    and not is_ruleset
                    and not is_legendary
                    and not center.no_collection -- optional: don't roll rule jokers / special hidden ones
                then
                    possible[#possible + 1] = center
                end
            end

            if #possible > 0 then
                local chosen = pseudorandom_element(possible, 'patience_random_joker')
                card.ability.extra.CurrentJoker = chosen.key

                local display_name = nil
                if chosen.loc_txt and chosen.loc_txt.name then
                    display_name = chosen.loc_txt.name
                elseif chosen.name then
                    display_name = chosen.name
                else
                    display_name = chosen.key
                end

                card.ability.extra.CurrentJokerName = display_name
            end
        end

        ----------------------------------------------------------------
        -- When sold, spawn the currently selected Joker
        ----------------------------------------------------------------
        if context.selling_self and not context.blueprint then
            local key_to_spawn = (card.ability and card.ability.extra and card.ability.extra.CurrentJoker) or 'j_joker'

            return {
                func = function()
                    -- spawn AFTER the sell resolves
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.0,
                        func = function()
                            SMODS.add_card({
                                set = 'Joker',
                                key = key_to_spawn
                            })
                            card_eval_status_text(card, 'extra', nil, nil, nil,
                                { message = localize('k_plus_joker'), colour = G.C.BLUE })
                            return true
                        end
                    }))
                    return true
                end
            }
        end
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { ref_table = "card.joker_display_values", ref_value = "target_name", colour = G.C.IMPORTANT }
            },
            calc_function = function(card)
                card.joker_display_values = card.joker_display_values or {}

                local name = "Joker"
                if card and card.ability and card.ability.extra then
                    name = card.ability.extra.CurrentJokerName or name

                    -- If CurrentJokerName missing but key exists, try to resolve
                    if (not card.ability.extra.CurrentJokerName) and card.ability.extra.CurrentJoker and G and G.P_CENTERS then
                        local c = G.P_CENTERS[card.ability.extra.CurrentJoker]
                        if c then
                            if c.loc_txt and c.loc_txt.name then name = c.loc_txt.name
                            elseif c.name then name = c.name end
                        end
                    end
                end

                card.joker_display_values.target_name = name
            end
        }
    end
}
