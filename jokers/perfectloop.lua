SMODS.Joker{ -- Perfect Loop
    key = "perfectloop",
    config = {
        extra = {
            levels = 1,              -- not used right now, but handy if you want scaling later
            active_this_hand = false -- helper flag
        }
    },
    loc_txt = {
        ['name'] = 'Perfect Loop',
        ['text'] = {
            [1] = 'Retrigger every played card',
            [2] = 'if hand contains a {C:attention}#1#{}',
            [3] = '{C:inactive}(Hand changes every round){}'
        },
        ['unlock'] = {
            [1] = 'Play {C:attention}100{} {C:blue}hands{}'
        }
    },
    pos = { x = 0, y = 0 },
    display_size = { w = 71, h = 95 },
    cost = 5,
    rarity = 2,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["porkify_porkify_jokers"] = true },
    unlock_condition = { type = 'c_hands_played', extra = 100 },

    -- Show the currently selected target hand in the text
    loc_vars = function(self, info_queue, card)
        local hand_name = 'High Card'
        if G and G.GAME and G.GAME.PerfectLoopPokerHand_hand then
            hand_name = G.GAME.PerfectLoopPokerHand_hand
        end
        return { vars = { localize(hand_name, 'poker_hands') } }
    end,

    set_ability = function(self, card, initial)
        if not (G and G.GAME) then return end

        local function pick_initial()
            if not G.GAME.hands then return end
            local possible = {}
            for handname, hand in pairs(G.GAME.hands) do
                if hand.visible then
                    possible[#possible + 1] = handname
                end
            end
            if #possible > 0 then
                G.GAME.PerfectLoopPokerHand_hand = pseudorandom_element(possible)
            else
                G.GAME.PerfectLoopPokerHand_hand = 'High Card'
            end
        end

        if not G.GAME.PerfectLoopPokerHand_hand then
            pick_initial()
        end
    end,

    calculate = function(self, card, context)
        -- Helper to pick the next target hand at end of round
        local function pick_next_target()
            if not (G and G.GAME and G.GAME.hands) then return end
            local possible = {}
            for handname, hand in pairs(G.GAME.hands) do
                if hand.visible then
                    possible[#possible + 1] = handname
                end
            end
            if #possible > 0 then
                G.GAME.PerfectLoopPokerHand_hand = pseudorandom_element(possible)
            end
        end

        ----------------------------------------------------------------
        -- 1) BEFORE SCORING: decide if this hand "activates" the Joker
        --    ("contains" the selected poker hand).
        ----------------------------------------------------------------
        if context.before then
            card.ability.extra.active_this_hand = false

            if not (G and G.GAME and G.GAME.PerfectLoopPokerHand_hand) then
                return
            end

            local target = G.GAME.PerfectLoopPokerHand_hand
            local poker_hands = context.poker_hands or {}

            -- "Contains" = that hand key exists and has at least one card
            if target and poker_hands[target] and next(poker_hands[target]) then
                card.ability.extra.active_this_hand = true
            end
        end

        ----------------------------------------------------------------
        -- 2) REPETITIONS: if the hand was marked active, give reps to
        --    every played card.
        ----------------------------------------------------------------
        if context.repetition and context.cardarea == G.play then
            if card.ability.extra.active_this_hand then
                return {
                    repetitions = 1
                }
            end
        end

        ----------------------------------------------------------------
        -- 3) END OF ROUND: pick a new target hand
        ----------------------------------------------------------------
        if context.end_of_round and context.cardarea == G.jokers
            and not context.blueprint then

            pick_next_target()
        end
    end,
	
	joker_display_def = function(JokerDisplay)
	  return {
		text = {
		  { ref_table = "card.joker_display_values", ref_value = "hand_text", colour = G.C.IMPORTANT }
		},
		reminder_text = {
			{ ref_table = "card.joker_display_values", ref_value = "state_text", colour = G.C.GREY }
		},

		calc_function = function(card)
		  local target = (G and G.GAME and G.GAME.PerfectLoopPokerHand_hand) or "High Card"
		  local target_name = localize(target, "poker_hands")

		  local eval_text = "Unknown"
		  local t = JokerDisplay.evaluate_hand()
		  if t then eval_text = t end  -- some builds return just the text

		  -- If your JD returns (text, _, scoring_hand), handle that too:
		  if type(eval_text) == "table" then
			eval_text = eval_text[1] or "Unknown"
		  end

		  -- More robust: support both return shapes
		  local text1, _, _ = JokerDisplay.evaluate_hand()
		  if type(text1) == "string" then eval_text = text1 end

		  card.joker_display_values.hand_text = target_name
		  card.joker_display_values.state_text = (eval_text == target) and "ON" or "OFF"
		end
	  }
	end
}
