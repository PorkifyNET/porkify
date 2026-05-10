
SMODS.Joker{ --Arcana Minor
    key = "arcanaminor",
    config = {
        extra = {
        }
    },
    loc_txt = {
        ['name'] = 'Arcana Minor',
        ['text'] = {
            [1] = 'Create a {C:tarot}Tarot{} card',
            [2] = 'for every played {C:attention}face{}',
            [3] = 'card with {V:1}#1#{} suit',
            [4] = '{C:inactive}(Suit changes every round){}',
            [5] = '{C:inactive}(Must have room){}'
        },
        ['unlock'] = {
            [1] = 'Discover {C:attention}12{} {C:tarot}Tarot{} cards'
        }
    },
    pos = {
        x = 2,
        y = 4
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 6,
    rarity = 3,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },
    unlock_condition = { type = 'discover_amount', tarot_count = 12 },

    credit_badges = {
        { text = "Art: cebeedrawz", colour = "59A487" }
     },
    
    loc_vars = function(self, info_queue, card)
		local suit = (G.GAME.current_round.ArcanaMinorSuit_card or {}).suit or 'Spades'
		return {
			vars = {
				localize(suit, 'suits_singular'),
				colours = { G.C.SUITS[suit] }  -- <- important: nested inside vars
			}
		}
	end,
    
    set_ability = function(self, card, initial)
        G.GAME.current_round.ArcanaMinorSuit_card = { suit = 'Spades' }
    end,
    
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play  then
            if context.other_card:is_face() and context.other_card:is_suit(G.GAME.current_round.ArcanaMinorSuit_card.suit) then
			  G.E_MANAGER:add_event(Event({
				trigger = 'after',
				delay = 0.4,
				func = function()
				  if #G.consumeables.cards < G.consumeables.config.card_limit then
					SMODS.add_card({ set = 'Tarot' })
					card:juice_up(0.3, 0.5)
				  end
				  return true
				end
			  }))
			  return { message = localize('k_plus_tarot') }
			end
        end
        if context.end_of_round and context.game_over == false and context.main_eval  then
            if G.playing_cards then
                local valid_ArcanaMinorSuit_cards = {}
                for _, v in ipairs(G.playing_cards) do
                    if not SMODS.has_no_suit(v) then
                        valid_ArcanaMinorSuit_cards[#valid_ArcanaMinorSuit_cards + 1] = v
                    end
                end
                if valid_ArcanaMinorSuit_cards[1] then
                    local ArcanaMinorSuit_card = pseudorandom_element(valid_ArcanaMinorSuit_cards, pseudoseed('ArcanaMinorSuit' .. G.GAME.round_resets.ante))
                    G.GAME.current_round.ArcanaMinorSuit_card.suit = ArcanaMinorSuit_card.base.suit
                end
            end
        end
    end,
	
	joker_display_def = function(JokerDisplay)
	  ---@type JDJokerDefinition
	  return {
			text = {
			  { ref_table = "G.GAME.current_round.ArcanaMinorSuit_card", ref_value = "suit" }
			},
			reminder_text = {
				{ text = "(", colour = G.C.GREY },
				{ text = "Face Cards", colour = G.C.IMPORTANT },
				{ text = ")", colour = G.C.GREY }
			},
		
			style_function = function(card, text, reminder_text, extra)
				if text and text.children[1] then
					text.children[1].config.colour = lighten(G.C.SUITS[G.GAME.current_round.ArcanaMinorSuit_card.suit], 0.35)
				end
				return false
			end
		}
	end
}