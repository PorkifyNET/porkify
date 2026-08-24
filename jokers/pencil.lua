
SMODS.Joker{ --Pencil
    key = "pencil",
    config = {
        extra = {
            PencilMult = 0
        }
    },
    loc_txt = {
        ['name'] = 'Pencil',
        ['text'] = {
            [1] = '{C:red}+1{} Mult per unused',
            [2] = '{C:attention}discard{} this run',
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
    perishable_compat = false,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["porkify_porkify_jokers"] = true },
    unlock_condition = { type = 'c_cards_discarded', extra = 150 },
    
    loc_vars = function(self, info_queue, card)
        local total = (porkify_get_pencil_unused_discards_total and porkify_get_pencil_unused_discards_total())
            or ((card and card.ability and card.ability.extra and card.ability.extra.PencilMult) or 0)
        return {vars = {total}}
    end,
    
    calculate = function(self, card, context)
        if context.end_of_round and context.game_over == false and context.main_eval  then
            return {
                func = function()
                    local total = (porkify_get_pencil_unused_discards_total and porkify_get_pencil_unused_discards_total())
                        or ((card.ability.extra and card.ability.extra.PencilMult) or 0)
                    card.ability.extra.PencilMult = total
                    return true
                end
            }
        end
        if context.cardarea == G.jokers and context.joker_main  then
            local total = (porkify_get_pencil_unused_discards_total and porkify_get_pencil_unused_discards_total())
                or ((card.ability.extra and card.ability.extra.PencilMult) or 0)
            return {
                mult = total
            }
        end
    end,
	
	joker_display_def = function(JokerDisplay)
	  return {
		text = {
		  { ref_table = "card.joker_display_values", ref_value = "mult_text", colour = G.C.RED }
		},

		calc_function = function(card)
		  local stored = (porkify_get_pencil_unused_discards_total and porkify_get_pencil_unused_discards_total())
              or ((card.ability.extra and card.ability.extra.PencilMult) or 0)
          if card.ability and card.ability.extra then
              card.ability.extra.PencilMult = stored
          end

		  card.joker_display_values.mult_text = "+" .. tostring(stored)
		end
	  }
	end
}
