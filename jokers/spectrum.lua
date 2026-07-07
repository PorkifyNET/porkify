SMODS.Joker{ --Spectrum
    key = "spectrum",
    config = {
        extra = {
            chips_per_suit = 80
        }
    },
    loc_txt = {
        ['name'] = 'Spectrum',
        ['text'] = {
            [1] = '{C:blue}+#1#{} Chips for every scored',
            [2] = '{C:attention}Suit{} in played hand'
        },
    },
    pos = {
        x = 4,
        y = 6
    },
    display_size = {
        w = 71,
        h = 95
    },
    cost = 6,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["porkify_porkify_jokers"] = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { (card.ability.extra and card.ability.extra.chips_per_suit) or 80 } }
    end,

    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.joker_main then
            local scoring_hand = context.scoring_hand or context.full_hand or {}
            local suits = {}

            for _, c in ipairs(scoring_hand) do
                if c and c.base and c.base.suit then
                    suits[c.base.suit] = true
                end
            end

            local suit_count = 0
            for _ in pairs(suits) do
                suit_count = suit_count + 1
            end

            local chips_per_suit = (card.ability.extra and card.ability.extra.chips_per_suit) or 80
            local chips = suit_count * chips_per_suit

            if chips > 0 then
                return {
                    chips = chips
                }
            end
        end
    end,
	
	joker_display_def = function(JokerDisplay)
	  return {
		text = {
		  { ref_table = "card.joker_display_values", ref_value = "chips_text", colour = G.C.BLUE }
		},

		calc_function = function(card)
		  local suit_count = 0
		  local suits = {}
		  local chips_per_suit = ((card.ability or {}).extra or {}).chips_per_suit or 80
		  local text, _, scoring_hand = JokerDisplay.evaluate_hand()

		  if text ~= "Unknown" and scoring_hand then
			for _, c in pairs(scoring_hand) do
			  if c and not c.debuff and c.facing ~= 'back' and c.base and c.base.suit then
				suits[c.base.suit] = true
			  end
			end
		  end

		  for _ in pairs(suits) do
			suit_count = suit_count + 1
		  end

		  card.joker_display_values.chips_text = "+" .. tostring(suit_count * chips_per_suit)
		  card.joker_display_values.suits_text = "(" .. tostring(suit_count) .. " suits)"
		end
	  }
	end
}
