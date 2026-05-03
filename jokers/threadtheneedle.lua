SMODS.Joker{ -- Thread (The Needle)
    key = "threadtheneedle",
    config = {
        extra = {
            start_size = 52
        }
    },
    loc_txt = {
        ['name'] = 'Thread The Needle',
        ['text'] = {
            [1] = 'This Joker gains {X:mult,C:white}X0.1{} Mult',
            [2] = 'for each card below the',
            [3] = 'starting {C:attention}Deck{} size',
			[4] = '{C:inactive}(Currently{} {X:red,C:white}X#1#{} {C:inactive}Mult){}'
        },
        ['unlock'] = {
            [1] = 'Sell {C:attention}10{} cards'
        }
    },
    pos = {
        x = 1,
        y = 3
    },
    display_size = {
        w = 71,
        h = 95
    },
    cost = 6,
    rarity = 2,              -- Uncommon/rare, tweak as you like
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },
    unlock_condition = { type = 'c_cards_sold', extra = 10 },

    -- Show current Xmult in text
    loc_vars = function(self, info_queue, card)
        if not card or not card.ability or not card.ability.extra then
            return { vars = { "1.0" } }
        end

        local extra = card.ability.extra
        local start_size = extra.start_size or 52
        local current_size = #(G.playing_cards or {})
        local diff = 0

        if start_size > 0 then
            diff = math.max(0, start_size - current_size)
        end

        local xm = 1 + 0.1 * diff
        local shown = string.format('%.1f', xm)

        return { vars = { shown } }
    end,

    -- Capture starting deck size when the Joker enters the deck
    set_ability = function(self, card, initial)
        if G and G.playing_cards and #G.playing_cards > 0 then
            -- Only set once, don’t overwrite if it already exists
            if not card.ability.extra.start_size or card.ability.extra.start_size == 0 then
                card.ability.extra.start_size = #G.playing_cards
            end
        end
    end,

    calculate = function(self, card, context)
        -- Standard Joker scoring context
        if context.cardarea == G.jokers and context.joker_main then
            local extra = card.ability.extra or {}
            local start_size = extra.start_size or 0
            local current_size = #(G.playing_cards or {})
            local diff = 0

            if start_size > 0 then
                diff = math.max(0, start_size - current_size)
            end

            local xm = 1 + 0.1 * diff

            return {
                Xmult = xm
            }
        end
    end,
	
	joker_display_def = function(JokerDisplay)
	  return {
		text = {
		  {
			border_nodes = {
			  { text = "X" },
			  { ref_table = "card.joker_display_values", ref_value = "x_mult" }
			}
		  }
		},

		calc_function = function(card)
		  local start_size = (card.ability.extra and card.ability.extra.start_size) or 0
		  local current_size = #(G.playing_cards or {})
		  local diff = 0
		  if start_size > 0 then diff = math.max(0, start_size - current_size) end

		  local xm = 1 + 0.1 * diff

		  -- format to 1 decimal like your tooltip
		  card.joker_display_values.x_mult = xm
		  card.joker_display_values.prog_text = tostring(current_size) .. "/" .. tostring(start_size)
		end
	  }
	end
}
