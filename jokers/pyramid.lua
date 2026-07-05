
SMODS.Joker{ --Pyramid
    key = "pyramid",
    config = {
        extra = {
        }
    },
    loc_txt = {
        ['name'] = 'Pyramid',
        ['text'] = {
            [1] = 'Every played {C:attention}3{}, {C:attention}4{},',
            [2] = 'and {C:attention}5{} becomes a',
            [3] = '{C:attention}Wild Card{} when scored'
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
        local info_queue_0 = G.P_CENTERS["m_wild"]
        if info_queue_0 then
            info_queue[#info_queue + 1] = info_queue_0
        else
            error("JOKERFORGE: Invalid key in infoQueues. \"m_wild\" isn't a valid Object key, Did you misspell it or forgot a modprefix?")
        end
        return { vars = {} }
    end,
    
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            local scored_card = context.other_card
            local id = scored_card:get_id()
            local current_key = scored_card.config and scored_card.config.center and scored_card.config.center.key
            if porkify_card_matches_rank(scored_card, { 3, 4, 5 }) and current_key ~= "m_wild" then
                scored_card:set_ability(G.P_CENTERS.m_wild)
                return {
                    message = "Card Modified!"
                }
            end
        end
    end,
	
	joker_display_def = function(JokerDisplay)
	  return {
		reminder_text = {
			{ text = "(", colour = G.C.GREY },
			{ text = "3, 4, 5", colour = G.C.IMPORTANT },
			{ text = ")", colour = G.C.GREY },
		},
	  }
	end
}
