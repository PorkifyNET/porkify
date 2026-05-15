SMODS.Joker{ -- Bulwark
    key = "bulwark",
    config = {
        extra = {
            chip_gain = 20
        }
    },
    loc_txt = {
        ['name'] = 'Bulwark',
        ['text'] = {
            [1] = 'Every played {C:enhanced}Stone{} card',
            [2] = 'permanently gains',
			[3] = '{C:blue}+#1#{} Chips when scored'
        },
        ['unlock'] = {
            [1] = 'Have {C:attention}8{} {C:enhanced}Stone{} cards in your deck'
        }
    },
    pos = {
        x = 0,
        y = 2
    },
    display_size = {
        w = 71,
        h = 95
    },
    cost = 5,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },
    unlock_condition = { type = 'modify_deck', extra = { enhancement = 'Stone Card', count = 8 } },

    in_pool = function(self, args)
        for _, playing_card in pairs(G.playing_cards or {}) do
            if playing_card and SMODS.get_enhancements(playing_card)["m_stone"] == true then
                return true
            end
        end
        return false
    end,

    loc_vars = function(self, info_queue, card)
        
		local info_queue_0 = G.P_CENTERS["m_stone"]
        if info_queue_0 then
            info_queue[#info_queue + 1] = info_queue_0
        else
            error("JOKERFORGE: Invalid key in infoQueues. \"m_stone\" isn't a valid Object key, Did you misspell it or forgot a modprefix?")
        end
		
        return {vars = {card.ability.extra.chip_gain}}
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if SMODS.get_enhancements(context.other_card)["m_stone"] == true then
                context.other_card.ability.perma_bonus = context.other_card.ability.perma_bonus or 0
                context.other_card.ability.perma_bonus = context.other_card.ability.perma_bonus + card.ability.extra.chip_gain
				return {
					message = localize('k_upgrade_ex'),
                    colour = G.C.CHIPS
				}
            end
        end
    end,
	
	joker_display_def = function(JokerDisplay)
	  return {
		reminder_text = {
			{ text = "(", colour = G.C.GREY},
			{ text = "Stone", colour = G.C.SECONDARY_SET["Enhanced"]},
			{ text = ")", colour = G.C.GREY}
		}
	  }
	end
}
