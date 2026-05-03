
SMODS.Joker{ --Crashout
    key = "crashout",
    config = {
        extra = {
            ShredderMult = 1,
            consumablesheld = 0
        }
    },
    loc_txt = {
        ['name'] = 'Crashout',
        ['text'] = {
            [1] = 'This Joker gains {X:red,C:white}X0.25{} Mult',
            [2] = 'per owned {C:attention}consumable{} when',
            [3] = '{C:attention}Blind{} is selected',
            [4] = '{C:inactive}(Currently{} {X:red,C:white}X#1#{} {C:inactive}Mult){}'
        },
        ['unlock'] = {
            [1] = '{C:red}Discard{} {C:attention}250{} cards'
        }
    },
    pos = {
        x = 7,
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
    unlock_condition = { type = 'c_cards_discarded', extra = 250 },
    
    loc_vars = function(self, info_queue, card)
        
        return {vars = {card.ability.extra.ShredderMult, ((#(G.consumeables and G.consumeables.cards or {}) or 0)) * 0.25}}
    end,
    
    calculate = function(self, card, context)
        if context.setting_blind  then
            return {
                func = function()
                    card.ability.extra.ShredderMult = (card.ability.extra.ShredderMult) + (#(G.consumeables and G.consumeables.cards or {})) * 0.25
                    return true
                end
            }
        end
        if context.cardarea == G.jokers and context.joker_main  then
            return {
                Xmult = card.ability.extra.ShredderMult
            }
        end
    end,
	
	joker_display_def = function(JokerDisplay)
	  return {
		text = {
		  {
			border_nodes = {
			  { text = "X" },
			  { ref_table = "card.ability.extra", ref_value = "ShredderMult" }
			}
		  },
		  reminder_text = {
			{ ref_table = "card.joker_display_values", ref_value = "gain_text" }
		  }
		},

		calc_function = function(card)
		  local n = #(G.consumeables and G.consumeables.cards or {})
		  card.joker_display_values.gain_text = "+X" .. tostring(n * 0.25) .. " on blind"
		end
	  }
	end
}