SMODS.Joker{ --Handbook
    key = "handbook",
    config = {
        extra = {
            mult = 0,
            mult_gain = 1
        }
    },
    loc_txt = {
        ['name'] = 'Handbook',
        ['text'] = {
            [1] = 'This Joker gains {C:red}+1{} Mult if',
            [2] = 'played {C:attention}Poker Hand{} has not',
            [3] = 'already been played this round',
            [4] = '{C:inactive}(Currently {C:red}+#1#{} {C:inactive}Mult){}'
        }
    },
    pos = {
        x = 6,
        y = 6
    },
    display_size = {
        w = 71,
        h = 95
    },
    cost = 4,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["porkify_porkify_jokers"] = true },

    loc_vars = function(self, info_queue, card)
        local mult = (card and card.ability and card.ability.extra and card.ability.extra.mult) or 0
        return { vars = { mult } }
    end,

    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            G.GAME.current_round = G.GAME.current_round or {}
            G.GAME.current_round.Handbook_played_hands = {}
            return
        end

        if context.before and context.cardarea == G.jokers and not context.blueprint then
            G.GAME.current_round = G.GAME.current_round or {}
            G.GAME.current_round.Handbook_played_hands = G.GAME.current_round.Handbook_played_hands or {}

            local hand_name = context.scoring_name
            if hand_name and not G.GAME.current_round.Handbook_played_hands[hand_name] then
                G.GAME.current_round.Handbook_played_hands[hand_name] = true
                card.ability.extra.mult = (card.ability.extra.mult or 0) + ((card.ability.extra.mult_gain) or 1)

                return {
                    message = "Studied!"
                }
            end
        end

        if context.cardarea == G.jokers and context.joker_main then
            local mult = (card.ability.extra and card.ability.extra.mult) or 0
            if mult > 0 then
                return {
                    mult = mult
                }
            end
        end
    end,
	
	joker_display_def = function(JokerDisplay)
	  return {
		text = {
		  { ref_table = "card.joker_display_values", ref_value = "mult_text", colour = G.C.RED }
		},
		reminder_text = {
			{ ref_table = "card.joker_display_values", ref_value = "state_text", colour = G.C.GREY }
		},

		calc_function = function(card)
		  local mult = (card.ability.extra and card.ability.extra.mult) or 0
		  local played_hands = (G and G.GAME and G.GAME.current_round and G.GAME.current_round.Handbook_played_hands) or {}
		  local eval_text = "Unknown"
		  local text = JokerDisplay.evaluate_hand()

		  if type(text) == "table" then
			eval_text = text[1] or "Unknown"
		  elseif type(text) == "string" then
			eval_text = text
		  end

		  local seen = eval_text ~= "Unknown" and played_hands[eval_text]
		  card.joker_display_values.mult_text = "+" .. tostring(mult)
		  card.joker_display_values.state_text = seen and "Seen this round" or "New this round"
		end
	  }
	end
}
