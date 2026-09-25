
SMODS.Joker{ --Pyramid
    key = "pyramid",
    config = {
        extra = {
        }
    },
    loc_txt = {
        ['name'] = 'Pyramid',
        ['text'] = {
            [1] = 'Every played {C:attention}face card{}',
            [2] = 'becomes an {C:enhanced}Ancient{} card',
            [3] = 'when scored'
        },
        ['unlock'] = {
            [1] = 'Play {C:attention}150{} cards'
        }
    },
    pos = {
        x = 3,
        y = 5
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 5,
    rarity = 2,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },
    unlock_condition = { type = 'c_cards_played', extra = 150 },

    loc_vars = function(self, info_queue, card)
        local ancient_center = G.P_CENTERS["m_porkify_ancient"]
        if ancient_center then
            info_queue[#info_queue + 1] = ancient_center
        else
            error("PORKIFY: Missing Ancient enhancement center \"m_porkify_ancient\"")
        end
        return { vars = {} }
    end,
    
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            local scored_card = context.other_card
            local current_key = scored_card.config and scored_card.config.center and scored_card.config.center.key
            if porkify_card_is_face_or_blank(scored_card) and current_key ~= "m_porkify_ancient" then
                scored_card:set_ability(G.P_CENTERS.m_porkify_ancient, nil, true)
                return {
                    message = "Ancient!",
                    colour = G.C.SECONDARY_SET.Enhanced
                }
            end
        end
    end,
	
	joker_display_def = function(JokerDisplay)
	  return {
		reminder_text = {
			{ text = "(" },
			{ text = "Face Cards", colour = G.C.IMPORTANT },
			{ text = ")" },
		},
	  }
	end
}
