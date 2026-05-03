
SMODS.Joker{ --Pencil
    key = "pencil",
    config = {
        extra = {
            PencilMult = 0,
            discardsremaining = 0
        }
    },
    loc_txt = {
        ['name'] = 'Pencil',
        ['text'] = {
            [1] = 'This Joker gains {C:red}+1{} Mult',
            [2] = 'for every unused {C:attention}discard{}',
            [3] = '{C:inactive}(Currently{} {C:red}+#1#{} {C:inactive}Mult){}'
        },
        ['unlock'] = {
            [1] = '{C:red}Discard{} {C:attention}150{} cards'
        }
    },
    pos = {
        x = 2,
        y = 1
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
    pools = { ["porkify_porkify_jokers"] = true },
    unlock_condition = { type = 'c_cards_discarded', extra = 150 },
    
    loc_vars = function(self, info_queue, card)
        
        return {vars = {card.ability.extra.PencilMult, (G.GAME.current_round.discards_left or 0)}}
    end,
    
    calculate = function(self, card, context)
        if context.end_of_round and context.game_over == false and context.main_eval  then
            return {
                func = function()
                    card.ability.extra.PencilMult = (card.ability.extra.PencilMult) + G.GAME.current_round.discards_left
                    return true
                end
            }
        end
        if context.cardarea == G.jokers and context.joker_main  then
            return {
                mult = card.ability.extra.PencilMult
            }
        end
    end,
	
	joker_display_def = function(JokerDisplay)
	  return {
		text = {
		  { ref_table = "card.joker_display_values", ref_value = "mult_text", colour = G.C.RED }
		},

		calc_function = function(card)
		  local stored = (card.ability.extra and card.ability.extra.PencilMult) or 0

		  card.joker_display_values.mult_text = "+" .. tostring(stored)
		end
	  }
	end
}
