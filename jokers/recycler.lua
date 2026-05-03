SMODS.Joker{ --Recycler
    key = "recycler",
    config = {
        extra = {
            RecyclerDollars = 0,
            odds = 4,
            odds2 = 4
        }
    },
    loc_txt = {
        ['name'] = 'Recycler',
        ['text'] = {
            [1] = 'Every {C:attention}sold{} or {C:red}destroyed{}',
            [2] = 'card has a {C:green}#2# in #3#{}',
            [3] = 'chance to add {C:money}$1{} to this',
            [4] = 'Jokers {C:attention}Payout{}',
            [5] = '{C:inactive}(Currently{} {C:money}$#1#{}{C:inactive}){}'
        },
        ['unlock'] = { [1] = 'Sell {C:attention}20{} cards' }
    },
    pos = { x = 3, y = 2 },
    display_size = { w = 71, h = 95 },
    cost = 6,
    rarity = 1,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = false,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },
    unlock_condition = { type = 'c_cards_sold', extra = 20 },

    loc_vars = function(self, info_queue, card)
        local n1, d1 = SMODS.get_probability_vars(card, 1, card.ability.extra.odds,  'j_porkify_recycler_sold')
        return { vars = { card.ability.extra.RecyclerDollars or 0, n1, d1 } }
    end,

    -- ✅ this is what actually grants money at end of round
    calc_dollar_bonus = function(self, card)
        local payout = tonumber(card.ability.extra.RecyclerDollars) or 0
        if payout > 0 then return payout end
    end,

    calculate = function(self, card, context)
        local showed_recycled_message = false

        local function add_payout()
            card.ability.extra.RecyclerDollars = (card.ability.extra.RecyclerDollars or 0) + 1
            if not showed_recycled_message then
                showed_recycled_message = true
                card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil,
                    { message = "Recycled!", colour = G.C.GREEN })
            end
        end

        if context.selling_card then
            if SMODS.pseudorandom_probability(card, 'group_recycler_sold', 1, card.ability.extra.odds, 'j_porkify_recycler_sold', false) then
                SMODS.calculate_effect({ func = add_payout }, card)
            end
        end

        if context.remove_playing_cards then
            local destroyed_count = 1
            if type(context.removed) == "table" then
                destroyed_count = #context.removed
            elseif type(context.remove_playing_cards) == "table" then
                destroyed_count = #context.remove_playing_cards
            end

            for i = 1, destroyed_count do
                if SMODS.pseudorandom_probability(card, 'group_recycler_destroyed', 1, card.ability.extra.odds2, 'j_porkify_recycler_destroyed', false) then
                    SMODS.calculate_effect({ func = add_payout }, card)
                end
            end
        end
    end,
	
	joker_display_def = function(JokerDisplay)
	  return {
		text = {
		  { ref_table = "card.joker_display_values", ref_value = "payout_text", colour = G.C.MONEY }
		},
		reminder_text = {
			{ ref_table = "card.joker_display_values", ref_value = "chance_text", colour = G.C.CHANCE }
		},

		calc_function = function(card)
		  local payout = (card.ability.extra and card.ability.extra.RecyclerDollars) or 0
		  card.joker_display_values.payout_text = "+$" .. tostring(payout)

		  local odds = (card.ability.extra and card.ability.extra.odds) or 4
		  local n, d = 1, odds
		  if SMODS and SMODS.get_probability_vars then
			local nn, dd = SMODS.get_probability_vars(card, 1, odds, "j_porkify_recycler_sold")
			n, d = nn or n, dd or d
		  end
		  card.joker_display_values.chance_text = "(" .. tostring(n) .. " in " .. tostring(d) .. ")"
		end
	  }
	end
}
