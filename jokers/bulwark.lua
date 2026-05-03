SMODS.Joker{ -- Bulwark
    key = "bulwark",
    config = {
        extra = {
            BulwarkMult = 1
        }
    },
    loc_txt = {
        ['name'] = 'Bulwark',
        ['text'] = {
            [1] = 'This Joker gains {X:red,C:white}X0.25{} Mult',
            [2] = 'whenever a {C:enhanced}Stone{} card is played',
			[3] = '{C:inactive}(Currently{} {X:red,C:white}X#1#{} {C:inactive}Mult){}'
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
		
        return {vars = {card.ability.extra.BulwarkMult}}
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play  then
            if SMODS.get_enhancements(context.other_card)["m_stone"] == true then
                card.ability.extra.BulwarkMult = (card.ability.extra.BulwarkMult) + 0.25
				return {
					message = "Bulwark!"
				}
            end
        end
        if context.cardarea == G.jokers and context.joker_main  then
            return {
                Xmult = card.ability.extra.BulwarkMult
            }
        end
    end,
	
	joker_display_def = function(JokerDisplay)
	  return {
		text = {
		  {
			border_nodes = {
			  { text = "X" },
			  { ref_table = "card.ability.extra", ref_value = "BulwarkMult", retrigger_type = "exp" }
			}
		  }
		},
		reminder_text = {
			{ text = "(", colour = G.C.GREY},
			{ text = "Stone", colour = G.C.SECONDARY_SET["Enhanced"]},
			{ text = ")", colour = G.C.GREY}
		}
	  }
	end
}
