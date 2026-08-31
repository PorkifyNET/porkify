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
            round_index = 0,
            scored_matches = 0
        }
    },
    loc_txt = {
        ["name"] = "Bounty",
        ["text"] = {
            [1] = "Earn {C:money}$1{} for every scored",
            [2] = "{C:attention}#1#{} at end of round",
            [3] = "{s:0.75}Rank changes every round{}",
            [4] = "{C:inactive}(Currently {C:money}$#2#{}{C:inactive}){}",
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
                extra.scored_matches or 0
            }
        }
    end,

    set_ability = function(self, card, initial)
        local extra = card.ability.extra or {}
        extra.round_index = extra.round_index or 0
        extra.target_rank = extra.target_rank or porkify_bounty_pick_rank(extra.round_index)
        extra.scored_matches = extra.scored_matches or 0
        card.ability.extra = extra
    end,

    calc_dollar_bonus = function(self, card)
        local payout = tonumber(card.ability.extra and card.ability.extra.scored_matches) or 0
        if payout > 0 then
            return payout
        end
    end,

    calculate = function(self, card, context)
        local extra = card.ability.extra or {}

        if context.setting_blind and not context.blueprint then
            extra.round_index = (extra.round_index or 0) + 1
            extra.target_rank = porkify_bounty_pick_rank(extra.round_index)
            extra.scored_matches = 0
            card.ability.extra = extra
        end

        if context.individual
            and context.cardarea == G.play
            and context.other_card
            and not context.blueprint
            and porkify_card_matches_rank(context.other_card, extra.target_rank or 2)
        then
            extra.scored_matches = (extra.scored_matches or 0) + 1
            card.ability.extra = extra

            return {
                message = "+$1",
                colour = G.C.MONEY
            }
        end
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { ref_table = "card.joker_display_values", ref_value = "payout_text", colour = G.C.MONEY }
            },
            reminder_text = {
                { text = "(", colour = G.C.GREY },
                { ref_table = "card.joker_display_values", ref_value = "rank_text", colour = G.C.IMPORTANT },
                { text = ")", colour = G.C.GREY }
            },

            calc_function = function(card)
                local extra = (card.ability and card.ability.extra) or {}

                card.joker_display_values.payout_text = "+$" .. tostring(extra.scored_matches or 0)
                card.joker_display_values.rank_text = porkify_bounty_rank_label(extra.target_rank or 2)
            end
        }
    end
}
