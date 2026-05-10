
SMODS.Joker{ --Printed Joker
    key = "printedjoker",
    config = {
        extra = {
            PrintedJokerChips = 0
        }
    },
    loc_txt = {
        ['name'] = 'Printed Joker',
        ['text'] = {
            [1] = '{C:blue}+1{} Chips for every',
            [2] = 'card played',
            [3] = '{C:inactive}(Currently{} {C:blue}+#1#{} {C:inactive}Chips){}'
        },
        ['unlock'] = {
            [1] = 'Play {C:attention}250{} cards'
        }
    },
    pos = {
        x = 0,
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
    perishable_compat = false,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },
    unlock_condition = { type = 'c_cards_played', extra = 250 },

    credit_badges = {
        { text = "Art: AbelSketch", colour = "59A487" }
     },
    
    loc_vars = function(self, info_queue, card)
        
        return {vars = {card.ability.extra.PrintedJokerChips}}
    end,
    
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            card.ability.extra.PrintedJokerChips = (card.ability.extra.PrintedJokerChips) + 1
        end
        if context.cardarea == G.jokers and context.joker_main  then
            return {
                chips = card.ability.extra.PrintedJokerChips
            }
        end
    end,
	
	joker_display_def = function(JokerDisplay)
	  return {
		text = {
		  { ref_table = "card.joker_display_values", ref_value = "chips_text", colour = G.C.BLUE }
		},

		calc_function = function(card)
		  local chips = (card.ability.extra and card.ability.extra.PrintedJokerChips) or 0
		  card.joker_display_values.chips_text = "+" .. tostring(chips)
		end
	  }
	end
}