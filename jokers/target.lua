local TARGET_RANKS = {
    "2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen", "King", "Ace"
}

local function choose_target_rank(seed_suffix)
    return pseudorandom_element(TARGET_RANKS, pseudoseed("porkify_target_" .. tostring(seed_suffix or 0)))
end

local function get_target_rank(card)
    return (card and card.ability and card.ability.extra and card.ability.extra.target_rank) or "Ace"
end

local function get_target_rank_display(rank)
    return tostring(rank or "Ace")
end

SMODS.Joker{ -- Target
    key = "target",
    config = {
        extra = {
            target_rank = "Ace"
        }
    },
    loc_txt = {
        ['name'] = 'Target',
        ['text'] = {
            [1] = 'Retrigger every played {C:attention}#1#{}',
            [2] = '{C:attention}2{} additional times',
            [3] = '{C:inactive}(Rank changes every round){}'
        },
        ['unlock'] = {
            [1] = 'Play a {C:attention}Four of a Kind{}'
        }
    },
    pos = {
        x = 7,
        y = 1
    },
    display_size = {
        w = 71,
        h = 95
    },
    cost = 5,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },
    unlock_condition = { type = 'hand', extra = 'Four of a Kind' },

    loc_vars = function(self, info_queue, card)
        return { vars = { get_target_rank_display(get_target_rank(card)) } }
    end,

    set_ability = function(self, card, initial)
        if card and card.ability and card.ability.extra then
            card.ability.extra.target_rank = choose_target_rank(
                ((G.GAME and G.GAME.round_resets and G.GAME.round_resets.ante) or 0) ..
                "_" ..
                ((G.GAME and G.GAME.round) or 0) ..
                "_init"
            )
        end
    end,
    
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            card.ability.extra.target_rank = choose_target_rank((G.GAME.round_resets.ante or 0) .. "_" .. (G.GAME.round or 0))
            return {
                message = get_target_rank_display(card.ability.extra.target_rank) .. "!"
            }
        end

        if context.repetition and context.cardarea == G.play then
            local target_rank = get_target_rank(card)
            if context.other_card and context.other_card.base and context.other_card.base.value == target_rank then
                return {
                    repetitions = 2,
                    message = "Again!"
                }
            end
        end
    end,
	
	joker_display_def = function(JokerDisplay)
	  return {
		text = {
		  { ref_table = "card.joker_display_values", ref_value = "target_text", colour = G.C.IMPORTANT }
		},

		calc_function = function(card)
		  card.joker_display_values.target_text = get_target_rank_display(get_target_rank(card))
		end
	  }
	end
}
