-- ---------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------

-- Prefer least-played among hands you've actually played (played > 0).
-- If none have been played yet, fall back to visible hands but exclude
-- super-rare ones so we don't always pick Straight Flush.
local function get_least_played_hand()
    if not (G and G.GAME and G.GAME.hands) then return 'High Card' end

    local rare_fallback_exclude = {
        ["Straight Flush"] = true,
        ["Five of a Kind"] = true,
        ["Flush House"]    = true,
        ["Flush Five"]     = true,
    }

    local function pick_from(predicate)
        local best_hand, best_played, best_order = nil, math.huge, math.huge
        for hand, data in pairs(G.GAME.hands) do
            local played = data.played or 0
            local order  = data.order or math.huge
            if predicate(hand, data, played) then
                if played < best_played or (played == best_played and order < best_order) then
                    best_hand, best_played, best_order = hand, played, order
                end
            end
        end
        return best_hand
    end

    local hand1 = pick_from(function(_, _, played) return played > 0 end)
    if hand1 then return hand1 end

    return 'High Card'
end

-- Find the Planet card key that levels a given poker hand
local function get_planet_key_for_hand(hand_name)
    if not (G and G.P_CENTERS) then return nil end
    for key, center in pairs(G.P_CENTERS) do
        if center and center.set == 'Planet' and center.config and center.config.hand_type == hand_name then
            return key
        end
    end
    return nil
end

-- ---------------------------------------------------------
-- Joker
-- ---------------------------------------------------------
SMODS.Joker{ -- Discovery
    key = "discovery",
    config = { extra = {} },
    loc_txt = {
        ['name'] = 'Discovery',
        ['text'] = {
            [1] = 'Create the {C:planet}Planet{} card for',
            [2] = 'your {C:attention}least played{} Poker Hand',
            [3] = 'when {C:attention}Blind{} is selected',
            [4] = '{C:inactive}(Currently {C:planet}#1#{C:inactive}){}'
        },
        ['unlock'] = { [1] = 'Discover {C:attention}8{} {C:planet}Planet{} cards' }
    },
    pos = { x = 8, y = 3 },
    display_size = { w = 71, h = 95 },
    cost = 5,
    rarity = 2,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },
    unlock_condition = { type = 'discover_amount', planet_count = 8 },

    -- Tooltip shows least played hand live
    loc_vars = function(self, info_queue, card)
        local hand = get_least_played_hand()
        if G and G.GAME then
            G.GAME.current_round = G.GAME.current_round or {}
            G.GAME.current_round.LeastPlayedPokerHand_hand = hand
        end
        return { vars = { localize(hand, 'poker_hands') } }
    end,

    set_ability = function(self, card, initial)
        if G and G.GAME then
            G.GAME.current_round = G.GAME.current_round or {}
            G.GAME.current_round.LeastPlayedPokerHand_hand = 'High Card'
        end
    end,

    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            local hand = get_least_played_hand()

            G.GAME.current_round = G.GAME.current_round or {}
            G.GAME.current_round.LeastPlayedPokerHand_hand = hand

            local planet_key = get_planet_key_for_hand(hand)
            if not planet_key then
                return { message = "No Planet!" } -- shouldn't happen, but safe
            end

            -- Spawn into consumables, respecting space
            if G.consumeables and #G.consumeables.cards < (G.consumeables.config.card_limit or 0) then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local created = SMODS.add_card({ set = 'Planet', key = planet_key })
                        if created then
                            card_eval_status_text(
                                card, 'extra', nil, nil, nil,
                                { message = localize('k_plus_planet'), colour = G.C.PLANET }
                            )
                        end
                        return true
                    end
                }))
            else
                card_eval_status_text(
                    card, 'extra', nil, nil, nil,
                    { message = "No space!", colour = G.C.RED }
                )
            end
        end
    end,
	
	joker_display_def = function(JokerDisplay)
	  return {
		text = {
		  { ref_table = "card.joker_display_values", ref_value = "planet_or_hand", colour = G.C.SECONDARY_SET["Planet"] }
		},

		calc_function = function(card)
		  local hand = get_least_played_hand()
		  local planet_key = get_planet_key_for_hand(hand)

		  local out = localize(hand, "poker_hands")
		  if planet_key and G and G.P_CENTERS and G.P_CENTERS[planet_key] then
			local center = G.P_CENTERS[planet_key]
			-- Most builds have center.name; use it if present
			out = center.name or out
		  end

		  card.joker_display_values.planet_or_hand = out
		end
	  }
	end
}
