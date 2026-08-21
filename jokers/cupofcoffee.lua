
SMODS.Joker{ --Cup of Coffee
    key = "cupofcoffee",
    config = {
        extra = {
            CupOfCoffeeMult = 0
        }
    },
    loc_txt = {
        ['name'] = 'Cup of Coffee',
        ['text'] = {
            [1] = 'This Joker gains {C:red}+3{} Mult',
            [2] = 'every time a {C:attention}Blind{} is selected',
            [3] = '{C:inactive}(Currently{} {C:red}+#1#{} {C:inactive}Mult){}'
        },
        ['unlock'] = {
            [1] = 'Play {C:attention}50{} {C:blue}hands{}'
        }
    },
    pos = {
        x = 5,
        y = 0
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
    pools = { ["porkify_porkify_jokers"] = true },
    unlock_condition = { type = 'c_hands_played', extra = 50 },
    
    loc_vars = function(self, info_queue, card)
        
        return {vars = {card.ability.extra.CupOfCoffeeMult}}
    end,
    
    calculate = function(self, card, context)
        if context.setting_blind  then
            return {
                func = function()
                    card.ability.extra.CupOfCoffeeMult = (card.ability.extra.CupOfCoffeeMult) + 3
                    return true
                end,
                message = "Caffeinated!"
            }
        end
        if context.cardarea == G.jokers and context.joker_main  then
            return {
                mult = card.ability.extra.CupOfCoffeeMult
            }
        end
    end,
	
	joker_display_def = function(JokerDisplay)
		---@type JDJokerDefinition
		return {
			text = {
				{ text = "+", colour = G.C.RED },
				{ ref_table = "card.ability.extra", ref_value = "CupOfCoffeeMult", retrigger_type = "mult", colour = G.C.RED }
			}
		}
	end
}
