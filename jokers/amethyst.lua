
SMODS.Joker{ --Amethyst
    key = "amethyst",
    config = {
        extra = {
            xmult0 = 1.75
        }
    },
    loc_txt = {
        ['name'] = 'Amethyst',
        ['text'] = {
            [1] = 'Played {C:enhanced}Steel{} cards',
            [2] = 'give {X:red,C:white}X1.75{} Mult when',
            [3] = 'scored'
        },
        ['unlock'] = {
            [1] = 'Have {C:attention}8{} {C:enhanced}Steel{} cards in your deck'
        }
    },
    pos = {
        x = 4,
        y = 4
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 4,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },
    unlock_condition = { type = 'modify_deck', extra = { enhancement = 'Steel Card', count = 8 } },

    in_pool = function(self, args)
        for _, playing_card in pairs(G.playing_cards or {}) do
            if playing_card and SMODS.get_enhancements(playing_card)["m_steel"] == true then
                return true
            end
        end
        return false
    end,
	
	loc_vars = function(self, info_queue, card)
        
        local info_queue_0 = G.P_CENTERS["m_steel"]
        if info_queue_0 then
            info_queue[#info_queue + 1] = info_queue_0
        else
            error("JOKERFORGE: Invalid key in infoQueues. \"m_steel\" isn't a valid Object key, Did you misspell it or forgot a modprefix?")
        end
        return {vars = {}}
    end,

    credit_badges = {
        { text = "Art: UnusedParadox", colour = "59A487" }
     },
    
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play  then
            if SMODS.get_enhancements(context.other_card)["m_steel"] == true then
                return {
                    Xmult = 1.75
                }
            end
        end
    end,
	
	joker_display_def = function(JokerDisplay)
	  ---@type JDJokerDefinition
	  return {
		text = {
		  {
			border_nodes = {
			  { text = "X" },
			  { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
			}
		  }
		},
		reminder_text = {
			{ text = "(", colour = G.C.GREY },
			{ text = "Steel", colour = G.C.SECONDARY_SET["Enhanced"] },
			{ text = ")", colour = G.C.GREY },
		},

		calc_function = function(card)
		  local base = (card.ability.extra and card.ability.extra.xmult0) or 1.75
		  local count = 0

		  local text, _, scoring_hand = JokerDisplay.evaluate_hand()

		  if text ~= 'Unknown' and scoring_hand then
			for _, playing_card in pairs(scoring_hand) do
			  if not playing_card.debuff
				and playing_card.facing ~= 'back'
				and SMODS.get_enhancements(playing_card)["m_steel"] == true
			  then
				count = count + JokerDisplay.calculate_card_triggers(playing_card, scoring_hand)
			  end
			end
		  end

		  -- No steel cards = no bonus
		  card.joker_display_values.x_mult = (count > 0) and (base ^ count) or 1
		end
	  }
	end
}
