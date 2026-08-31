local function porkify_pairing_test_has_pair(context)
    local scoring_hand = context and (context.scoring_hand or context.full_hand) or {}
    local rank_counts = {}

    for _, played_card in ipairs(scoring_hand) do
        if played_card and not played_card.debuff and played_card.get_id then
            local rank = played_card:get_id()
            if rank then
                rank_counts[rank] = (rank_counts[rank] or 0) + 1
                if rank_counts[rank] >= 2 then
                    return true
                end
            end
        end
    end

    return false
end

SMODS.Joker{ -- Memory
    key = "memory",
    config = {
        extra = {
            chips = 0,
            chip_gain = 4
        }
    },
    loc_txt = {
        ["name"] = "Memory",
        ["text"] = {
            [1] = "This Joker gains {C:chips}+#2#{} Chips if",
            [2] = "played hand contains a {C:attention}Pair{}",
            [3] = "{C:red}-#2#{} Chips if it does not",
            [4] = "{C:inactive}(Currently {C:chips}+#1#{} {C:inactive}Chips){}"
        }
    },
    pos = { x = 2, y = 9 },
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
                extra.chips or 0,
                extra.chip_gain or 4
            }
        }
    end,

    calculate = function(self, card, context)
        local extra = card.ability.extra or {}

        if context.before and context.cardarea == G.jokers and not context.blueprint then
            if porkify_pairing_test_has_pair(context) then
                extra.chips = (extra.chips or 0) + (extra.chip_gain or 4)
                card.ability.extra = extra
                return {
                    message = "Upgrade!",
                    colour = G.C.CHIPS
                }
            end

            local new_chips = math.max(0, (extra.chips or 0) - (extra.chip_gain or 4))
            if new_chips ~= (extra.chips or 0) then
                extra.chips = new_chips
                card.ability.extra = extra
                return {
                    message = "Downgrade",
                    colour = G.C.GREY
                }
            end
        end

        if context.cardarea == G.jokers and context.joker_main then
            local chips = extra.chips or 0
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
            reminder_text = {
                { text = "(", colour = G.C.GREY },
                { ref_table = "card.joker_display_values", ref_value = "status_text", colour = G.C.IMPORTANT },
                { text = ")", colour = G.C.GREY }
            },

            calc_function = function(card)
                local extra = (card.ability and card.ability.extra) or {}
                card.joker_display_values.chips_text = "+" .. tostring(extra.chips or 0)
                card.joker_display_values.status_text = "Need Pair"
            end
        }
    end
}
