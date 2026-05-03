SMODS.Joker{ --The Rectangle
    key = "therectangle",
    config = {
        extra = {
            DiamondCards = 13,
            Xmult = 4
        }
    },
    loc_txt = {
        ['name'] = 'The Rectangle',
        ['text'] = {
            [1] = '{X:red,C:white}X4{} Mult if there are',
            [2] = '24 or more {C:diamonds}Diamond{} cards',
            [3] = 'in your entire Deck',
            [4] = '{C:inactive}(Currently {C:attention}#1#{}{C:inactive}){}'
        },
        ['unlock'] = {
            [1] = 'Have {C:attention}24{} {C:diamonds}Diamond{} cards in your deck'
        }
    },
    pos = {
        x = 6,
        y = 1
    },
    display_size = {
        w = 71,
        h = 95
    },
    cost = 6,
    rarity = 3,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["porkify_porkify_jokers"] = true },
    unlock_condition = { type = 'modify_deck', extra = { suit = 'Diamonds', count = 24 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.DiamondCards } }
    end,

    calculate = function(self, card, context)
        -- Recount Diamonds in the entire deck every time this Joker is evaluated
        local count = 0
        for _, playing_card in pairs(G.playing_cards or {}) do
            if playing_card:is_suit("Diamonds") then
                count = count + 1
            end
        end

        -- Store it so loc_vars can show the live value
        card.ability.extra.DiamondCards = count

        local enough = to_big(count) >= to_big(24)

        -- Main Joker scoring (during scoring phase)
        if context.cardarea == G.jokers and context.joker_main then
            if enough then
                return {
                    Xmult = 4
                }
            end
        end
    end,
	
	joker_display_def = function(JokerDisplay)
	  return {
		text = {
		  -- X4 line (authentic look)
		  {
			border_nodes = {
			  { text = "X" },
			  { ref_table = "card.ability.extra", ref_value = "Xmult" }
			}
		  },
		},
		reminder_text = {
			-- progress line
		    { ref_table = "card.joker_display_values", ref_value = "prog_text", colour = G.C.GREY }
		},

		calc_function = function(card)
		  local count = 0
		  for _, c in pairs(G.playing_cards or {}) do
			if c and c.is_suit and c:is_suit("Diamonds") then
			  count = count + 1
			end
		  end

		  -- keep your stored value in sync (nice for tooltip too)
		  if card.ability and card.ability.extra then
			card.ability.extra.DiamondCards = count
		  end

		  local ok = to_big(count) >= to_big(24)
		  card.joker_display_values.prog_text = "(" .. tostring(count) .. "/24)"
		end
	  }
	end
}
