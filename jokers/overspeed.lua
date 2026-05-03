SMODS.Joker{ -- Overspeed
    key = "overspeed",
    config = {},
    loc_txt = {
        ['name'] = 'Overspeed',
        ['text'] = {
            [1] = '{C:money}$8{} if score is {X:attention,C:white}X2{} the',
            [2] = 'Blind Score Requirement',
            [3] = '{C:inactive}(Required:{} {C:attention}#2#{}{C:inactive}){}'
        },
        ['unlock'] = { [1] = 'Score {C:attention}50,000{} chips in one hand' }
    },
    pos = { x = 9, y = 3 },
    display_size = { w = 71, h = 95 },
    cost = 5,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },
    unlock_condition = { type = 'chip_score', chips = 50000 },

    -- Safe tooltip in Collection (no run / no blind)
    loc_vars = function(self, info_queue, card)
        local req_text = "0"

        if G and G.GAME then
            if G.GAME.blind then
                local blind_chips = G.GAME.blind.chips or 0
                local req = to_big(blind_chips) * to_big(2)
                req_text = number_format(req)
            end
        end

        return { vars = { 0, req_text } }
    end,

    -- This is used by the game for "$ bonus" jokers; MUST be safe too
    calc_dollar_bonus = function(card)
        if not (G and G.GAME and G.GAME.blind) then return nil end

        local chips = G.GAME.chips or 0
        local req = to_big(G.GAME.blind.chips or 0) * to_big(2)

        if to_big(chips) >= to_big(req) then
            return 8
        end
        return nil
    end,

    calculate = function(self, card, context)
        -- Nothing needed here unless you want extra messages/juice/etc.
        -- Keep it safe anyway:
        if not (G and G.GAME and G.GAME.blind) then return end
    end,
	
	joker_display_def = function(JokerDisplay)
	  return {
		text = {
		  { ref_table = "card.joker_display_values", ref_value = "reward_text", colour = G.C.MONEY }
		},
		reminder_text = {
			{ ref_table = "card.joker_display_values", ref_value = "req_text", colour = G.C.FILTER }
		},
		
		calc_function = function(card)
		  card.joker_display_values = card.joker_display_values or {}
		  card.joker_display_values.reward_text = "$8"

		  local chips = (G and G.GAME and G.GAME.chips) or 0
		  local blind_chips = (G and G.GAME and G.GAME.blind and G.GAME.blind.chips) or 0
		  local req = to_big(blind_chips) * to_big(2)

		  -- Show requirement; if no blind (collection/shop), still show something sensible
		  if to_big(req) > to_big(0) then
			card.joker_display_values.req_text = number_format(chips) .. " / " .. number_format(req)
		  else
			card.joker_display_values.req_text = "Req: ?"
		  end
		end
	  }
	end
}
