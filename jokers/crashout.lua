
SMODS.Joker{ --Crashout
    key = "crashout",
    config = {
        extra = {
            x_chips = 1,
            x_chips_gain = 0.4
        }
    },
    loc_txt = {
        ['name'] = 'Crashout',
        ['text'] = {
            [1] = 'This Joker gains {X:blue,C:white}X#2#{} Chips',
            [2] = 'every time a {C:spectral}Spectral{}',
            [3] = 'card is used',
            [4] = '{C:inactive}(Currently{} {X:blue,C:white}X#1#{} {C:inactive}Chips){}'
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
    perishable_compat = false,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },
    unlock_condition = { type = 'c_cards_discarded', extra = 250 },

    credit_badges = {
        { text = "Art: smoliconboi", colour = "59A487" }
     },
    
    loc_vars = function(self, info_queue, card)
        local extra = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { extra.x_chips or 1, extra.x_chips_gain or 0.4 } }
    end,
    
    calculate = function(self, card, context)
        if context.using_consumeable and not context.blueprint then
            local consumeable = context.consumeable
            local set = consumeable and consumeable.ability and consumeable.ability.set

            if set == 'Spectral' then
                card.ability.extra.x_chips = (card.ability.extra.x_chips or 1) + (card.ability.extra.x_chips_gain or 0.4)
                return {
                    message = "Crashout!",
                    colour = G.C.CHIPS
                }
            end
        end

        if context.cardarea == G.jokers and context.joker_main then
            return {
                x_chips = (card.ability.extra and card.ability.extra.x_chips) or 1
            }
        end
    end,
	
	joker_display_def = function(JokerDisplay)
	  return {
		text = {
		  {
			border_nodes = {
			  { text = "X", colour = G.C.WHITE },
			  { ref_table = "card.joker_display_values", ref_value = "x_chips_text", colour = G.C.WHITE }
			}
		  }
		},
		reminder_text = {
			{ text = "(", colour = G.C.GREY },
			{ text = "Spectral", colour = G.C.SECONDARY_SET.Spectral },
			{ text = ")", colour = G.C.GREY }
		},
		style_function = function(card, text, reminder_text, extra)
		  if text and text.children and text.children[1] then
			text.children[1].config.colour = G.C.CHIPS
		  end
		  return false
		  end,

		calc_function = function(card)
		  local extra = (card.ability and card.ability.extra) or {}
		  card.joker_display_values.x_chips_text = extra.x_chips or 1
		end
	  }
	end
}
