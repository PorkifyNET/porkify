SMODS.Joker{ --Apple Tree
    key = "appletree",
    config = {
        extra = {
            hearts_destroyed = 0,
            hand_size = 0,
            hearts_needed = 3
        }
    },
    loc_txt = {
        ['name'] = 'Apple Tree',
        ['text'] = {
            [1] = 'Gain {C:attention}+1{} Hand Size',
            [2] = 'for every {C:attention}#3#{} {C:inactive}[#2#/#3#]{}',
            [3] = 'destroyed {C:hearts}Heart{} cards',
            [4] = '{C:inactive}(Currently{} {C:attention}+#1#{} {C:inactive}Hand Size){}'
        },
        ['unlock'] = { [1] = 'Reach {C:attention}Ante 8{}' }
    },
    pos = { x = 2, y = 0 },
    display_size = { w = 71, h = 95 },
    cost = 8,
    rarity = 3,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = false,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },
    unlock_condition = { type = 'ante_up', ante = 8 },

    loc_vars = function(self, info_queue, card)
        local extra = card.ability.extra or self.config.extra
        return {
            vars = {
                extra.hand_size or 0,
                extra.hearts_destroyed or 0,
                extra.hearts_needed or 3
            }
        }
    end,

    calculate = function(self, card, context)
        if context.remove_playing_cards then
            local removed = {}

            if type(context.removed) == "table" then
                removed = context.removed
            elseif type(context.remove_playing_cards) == "table" then
                removed = context.remove_playing_cards
            end

            local hearts_destroyed = 0
            for _, removed_card in ipairs(removed) do
                if removed_card and removed_card.is_suit and removed_card:is_suit("Hearts") then
                    hearts_destroyed = hearts_destroyed + 1
                end
            end

            if hearts_destroyed > 0 then
                local extra = card.ability.extra
                local needed = extra.hearts_needed or 3
                local total_hearts = (extra.hearts_destroyed or 0) + hearts_destroyed
                local hand_size_gain = math.floor(total_hearts / needed)

                extra.hearts_destroyed = total_hearts % needed

                if hand_size_gain > 0 then
                    extra.hand_size = (extra.hand_size or 0) + hand_size_gain

                    return {
                        func = function()
                            G.hand:change_size(hand_size_gain)
                            card_eval_status_text(card, 'extra', nil, nil, nil,
                                { message = "Grow!", colour = G.C.HEARTS })
                            return true
                        end
                    }
                end
            end
        end
    end,

    add_to_deck = function(self, card, from_debuff)
        if from_debuff then
            return
        end
        local applied = card.ability.extra.hand_size or 0
        if applied ~= 0 then G.hand:change_size(applied) end
    end,

    remove_from_deck = function(self, card, from_debuff)
        if from_debuff then
            return
        end
        local applied = card.ability.extra.hand_size or 0
        if applied ~= 0 then G.hand:change_size(-applied) end
        card.ability.extra.hand_size = 0
    end,

	joker_display_def = function(JokerDisplay)
	  return {
		text = {
		  { ref_table = "card.joker_display_values", ref_value = "hand_size_text", colour = G.C.IMPORTANT }
		},
		reminder_text = {
			{ text = "(", colour = G.C.GREY },
			{ ref_table = "card.joker_display_values", ref_value = "progress_text", colour = G.C.SUITS["Hearts"] },
			{ text = ")", colour = G.C.GREY }
		},

		calc_function = function(card)
		  local extra = card.ability.extra or {}
		  local hand_size = extra.hand_size or 0
		  local hearts_destroyed = extra.hearts_destroyed or 0
		  local hearts_needed = extra.hearts_needed or 3

		  card.joker_display_values.hand_size_text = "+" .. tostring(hand_size)
		  card.joker_display_values.progress_text = tostring(hearts_destroyed) .. "/" .. tostring(hearts_needed) .. " Hearts"
		end
	  }
	end
}
