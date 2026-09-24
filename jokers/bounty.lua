local PORKIFY_BOUNTY_RANKS = {
    2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14
}

local function porkify_bounty_rank_label(rank)
    local labels = {
        [11] = "Jack",
        [12] = "Queen",
        [13] = "King",
        [14] = "Ace"
    }

    return labels[rank] or tostring(rank or 2)
end

local function porkify_bounty_pick_rank(round_index)
    local index = tonumber(round_index) or 0
    return pseudorandom_element(
        PORKIFY_BOUNTY_RANKS,
        pseudoseed("porkify_bounty_" .. tostring(index))
    ) or 2
end

SMODS.Joker{ -- Bounty
    key = "bounty",
    config = {
        extra = {
            target_rank = 2,
            dollars = 2
        }
    },
    loc_txt = {
        ["name"] = "Bounty",
        ["text"] = {
            [1] = "Earn {C:money}$#2#{} for every played",
            [2] = "{C:attention}#1#{} when scored",
            [3] = "{s:0.75}Rank changes every round{}",
        }
    },
    pos = { x = 3, y = 9 },
    display_size = { w = 71, h = 95 },
    cost = 6,
    rarity = 1,
    blueprint_compat = false,
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
                porkify_bounty_rank_label(extra.target_rank or 2),
                extra.dollars or 2
            }
        }
    end,

    set_ability = function(self, card, initial)
        local extra = card.ability.extra or {}
        extra.round_index = extra.round_index or 0
        extra.target_rank = extra.target_rank or porkify_bounty_pick_rank(extra.round_index)
        card.ability.extra = extra
    end,

    calculate = function(self, card, context)
        local extra = card.ability.extra
        if context.end_of_round and context.main_eval and not context.game_over and not context.blueprint then
            extra.round_index = (extra.round_index or 0) + 1
            extra.target_rank = porkify_bounty_pick_rank(extra.round_index)
        end

        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if porkify_card_matches_rank(played_card, extra.target_rank or 2) then
                return {
                    dollars = extra.dollars or 2
                }
            end
        end
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { ref_table = "card.joker_display_values", ref_value = "payout_text", colour = G.C.MONEY, retrigger_type = "mult" }
            },
            reminder_text = {
                { text = "(" },
                { ref_table = "card.joker_display_values", ref_value = "rank_text", colour = G.C.IMPORTANT },
                { text = ")" }
            },

            calc_function = function(card)
                local extra = (card.ability and card.ability.extra) or {}
                local hits = 0
                local text, _, scoring_hand = JokerDisplay.evaluate_hand()

                if text ~= "Unknown" and scoring_hand then
                    for _, c in pairs(scoring_hand) do
                        if not c.debuff and c.facing ~= "back"
                            and porkify_card_matches_rank(c, extra.target_rank or 2) then
                            hits = hits + JokerDisplay.calculate_card_triggers(c, scoring_hand)
                        end
                    end
                end

                card.joker_display_values.payout_text = "+$" .. tostring(hits * (extra.dollars or 2))
                card.joker_display_values.rank_text = porkify_bounty_rank_label(extra.target_rank or 2)
            end
        }
    end
}
