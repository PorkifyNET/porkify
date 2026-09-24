local function printed_chips(card, include_current)
    local hands = G and G.GAME and G.GAME.hands_played or 0
    return (hands + (include_current and 1 or 0)) * (card.ability.extra.chips_per_hand or 4)
end


SMODS.Joker{ --Printed Joker
    key = "printedjoker",
    config = {
        extra = {
            chips_per_hand = 3
        }
    },
    loc_txt = {
        ['name'] = 'Printed Joker',
        ['text'] = {
            [1] = '{C:chips}+#2#{} Chips per',
            [2] = 'played {C:blue}hand{} this run',
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
        
        return {vars = {printed_chips(card), card.ability.extra.chips_per_hand or 3}}
    end,
    
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.joker_main then
            -- Balatro increments hands_played only after the current hand finishes.
            return { chips = printed_chips(card, true) }
        end
    end,
	
	joker_display_def = function(JokerDisplay)
	  return {
		text = {
		  { ref_table = "card.joker_display_values", ref_value = "chips_text", colour = G.C.BLUE }
		},

		calc_function = function(card)
		  local chips = printed_chips(card)
		  card.joker_display_values.chips_text = "+" .. tostring(chips)
		end
	  }
	end
}
