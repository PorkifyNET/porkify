local PORKIFY_STEP_LADDER_RANKS = {
    2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14
}

local function porkify_step_ladder_rank_label(rank)
    local labels = {
        [11] = "Jack",
        [12] = "Queen",
        [13] = "King",
        [14] = "Ace"
    }

    return labels[rank] or tostring(rank or 2)
end

local function porkify_step_ladder_next_rank(rank)
    for i = 1, #PORKIFY_STEP_LADDER_RANKS do
        if PORKIFY_STEP_LADDER_RANKS[i] == rank then
            return PORKIFY_STEP_LADDER_RANKS[(i % #PORKIFY_STEP_LADDER_RANKS) + 1]
        end
    end

    return 2
end

local function porkify_step_ladder_hand_has_rank(context, rank)
    local hand = context and (context.full_hand or context.scoring_hand) or {}

    for _, played_card in ipairs(hand) do
        if porkify_card_matches_rank(played_card, rank) then
            return true
        end
    end

    return false
end

SMODS.Joker{ -- Step Ladder
    key = "stepladder",
    config = {
        extra = {
            required_rank = 2,
            mult = 0,
            mult_gain = 5
        }
    },
    loc_txt = {
        ["name"] = "Step Ladder",
        ["text"] = {
            [1] = "This Joker gains {C:red}+#2#{} Mult if",
            [2] = "played hand contains a {C:attention}#1#{}",
            [3] = "Resets if played hand does not",
            [4] = "{C:inactive}(Currently {C:red}+#3#{} {C:inactive}Mult){}"
        }
    },
    pos = { x = 0, y = 9 },
    display_size = { w = 71, h = 95 },
    cost = 6,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false,
    unlocked = true,
    discovered = false,
    atlas = "CustomJokers",
    pools = { ["modprefix_porkify_jokers"] = true },

    loc_vars = function(self, info_queue, card)
        local extra = (card and card.ability and card.ability.extra) or self.config.extra
        return {
            vars = {
                porkify_step_ladder_rank_label(extra.required_rank or 2),
                extra.mult_gain or 5,
                extra.mult or 0
            }
        }
    end,

    set_ability = function(self, card, initial)
        local extra = card.ability.extra or {}
        extra.required_rank = extra.required_rank or 2
        extra.mult = extra.mult or 0
        extra.mult_gain = extra.mult_gain or 5
        card.ability.extra = extra
    end,

    calculate = function(self, card, context)
        local extra = card.ability.extra or {}

        if context.before and context.cardarea == G.jokers then
            local required_rank = extra.required_rank or 2
            local matched = porkify_step_ladder_hand_has_rank(context, required_rank)

            if not context.blueprint then
                if matched then
                    extra.mult = (extra.mult or 0) + (extra.mult_gain or 5)
                    extra.required_rank = porkify_step_ladder_next_rank(required_rank)
                    card.ability.extra = extra

                    return {
                        message = "Climbed!",
                        colour = G.C.MULT
                    }
                end

                if (extra.mult or 0) > 0 or required_rank ~= 2 then
                    extra.mult = 0
                    extra.required_rank = 2
                    card.ability.extra = extra

                    return {
                        message = "Reset",
                        colour = G.C.GREY
                    }
                end
            end
        end

        if context.cardarea == G.jokers and context.joker_main then
            local mult = (extra.mult or 0)
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
                { text = "(", colour = G.C.GREY },
                { ref_table = "card.joker_display_values", ref_value = "rank_text", colour = G.C.IMPORTANT },
                { text = ")", colour = G.C.GREY }
            },

            calc_function = function(card)
                local extra = (card.ability and card.ability.extra) or {}
                local required_rank = extra.required_rank or 2
                local mult = extra.mult or 0

                card.joker_display_values.mult_text = "+" .. tostring(mult)
                card.joker_display_values.rank_text = porkify_step_ladder_rank_label(required_rank)
            end
        }
    end
}
