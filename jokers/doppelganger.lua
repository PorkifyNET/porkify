SMODS.Joker{ --Doppelganger
    key = "doppelganger",
    config = {
        extra = { DoppelgangerJokerSlotToCopy = 1 }
    },
    loc_txt = {
        name = "Doppelganger",
        text = {
            [1] = "Copy the effects of",
            [2] = "{C:attention}#1#{}",
            [3] = "{s:0.75,C:inactive}Joker Slot changes every round{}"
        },
        unlock = { [1] = "Sell {C:attention}10{} Jokers" }
    },

    pos = { x = 0, y = 5 },
    display_size = { w = 71, h = 95 },
    cost = 5,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = false,
    discovered = false,
    atlas = "CustomJokers",
    pools = { ["modprefix_porkify_jokers"] = true },
    unlock_condition = { type = 'c_jokers_sold', extra = 10 },

    credit_badges = {
        { text = "Art: mrjames246", colour = "59A487" }
     },

    loc_vars = function(self, info_queue, card)
        local slot = card.ability.extra.DoppelgangerJokerSlotToCopy or 1
        local jokers = G.jokers and G.jokers.cards
        local name = localize('k_none')

        local j = jokers and jokers[slot]
        if j and j.config and j.config.center and j.config.center.key then
            name = localize({ type = 'name_text', key = j.config.center.key, set = 'Joker' })
        elseif j and j.ability and j.ability.name then
            name = j.ability.name
        elseif j and j.name then
            name = j.name
        end

        return { vars = { name } }
    end,

    calculate = function(self, card, context)
        -- Randomize slot at end of round
        if context.end_of_round and not context.game_over and context.main_eval and not context.blueprint then
            local n = (G.jokers and G.jokers.cards and #G.jokers.cards) or 0
            if n > 0 then
                card.ability.extra.DoppelgangerJokerSlotToCopy = math.random(1, n)
            end
            return { message = "Randomized!" }
        end

        -- Copy effects during all other eval contexts
        local slot = card.ability.extra.DoppelgangerJokerSlotToCopy or 1
        local target_joker = G.jokers and G.jokers.cards and G.jokers.cards[slot]

        -- Nothing to copy / don't copy itself
        if not target_joker or target_joker == card then return end

        -- Optional: avoid copying Blueprint itself (prevents recursion hell)
        if target_joker.config and target_joker.config.center and target_joker.config.center.key == "j_blueprint" then
            return
        end

        local ret = SMODS.blueprint_effect(card, target_joker, context)
        if ret then
            return ret  -- IMPORTANT: return the effect table, don't call calculate_effect manually
        end
    end,
	
	joker_display_def = function(JokerDisplay)
	  return {
		-- You can leave main text empty if you only want reminder text
		text = { 
			{ text = "Incompatible!", colour = G.C.RED },
		},

		reminder_text = {
		  { ref_table = "card.joker_display_values", ref_value = "copy_text", colour = G.C.IMPORTANT }
		},

		calc_function = function(card)
		  local slot = (card.ability.extra and card.ability.extra.DoppelgangerJokerSlotToCopy) or 1
		  local jokers = G and G.jokers and G.jokers.cards
		  local name = localize('k_none')

		  local j = jokers and jokers[slot]
		  if j and j.config and j.config.center and j.config.center.key then
			name = localize({ type = 'name_text', key = j.config.center.key, set = 'Joker' })
		  elseif j and j.ability and j.ability.name then
			name = j.ability.name
		  elseif j and j.name then
			name = j.name
		  end

		  if j == card then
			name = localize('k_none')
			j = nil
		  end

		  card.joker_display_values.copy_text = tostring(slot) .. ": " .. tostring(name)

		  -- Let JokerDisplay render the copied joker’s display if possible
		  local copied_joker, copied_debuff = JokerDisplay.calculate_blueprint_copy(card)
		  JokerDisplay.copy_display(card, copied_joker, copied_debuff)
		end,

		-- JD uses this in some setups to know what to "pretend copy" (safe + correct)
		get_blueprint_joker = function(card)
		  local slot = (card.ability.extra and card.ability.extra.DoppelgangerJokerSlotToCopy) or 1
		  local jokers = G and G.jokers and G.jokers.cards
		  local j = jokers and jokers[slot]
		  if j == card then return nil end
		  return j
		end
	  }
	end
}
