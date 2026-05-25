SMODS.Joker{ --Warmup
    key = "warmup",
    config = {
        extra = {
            chips = 0,
            chip_gain = 30
        }
    },
    loc_txt = {
        ['name'] = 'Warmup',
        ['text'] = {
            [1] = 'This Joker gains {C:chips}+#2#{} Chips',
            [2] = 'per {C:blue}hand{} played',
            [3] = 'Resets at end of round',
            [4] = '{C:inactive}(Currently {C:chips}+#1#{} {C:inactive}Chips){}'
        }
    },
    pos = {
        x = 6,
        y = 7
    },
    display_size = {
        w = 71,
        h = 95
    },
    cost = 6,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'CustomJokers',
    pools = { ["porkify_porkify_jokers"] = true },

    loc_vars = function(self, info_queue, card)
        local extra = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { extra.chips or 0, extra.chip_gain or 30 } }
    end,

    calculate = function(self, card, context)
        if context.after and context.cardarea == G.jokers and not context.blueprint then
            local extra = card.ability.extra or {}
            extra.chips = (extra.chips or 0) + (extra.chip_gain or 30)
            card.ability.extra = extra

                return {
                    message = "Upgrade!",
                    colour = G.C.IMPORTANT
                }
        end

        if context.end_of_round and context.main_eval and not context.blueprint then
            local extra = card.ability.extra or {}
            if (extra.chips or 0) > 0 then
                extra.chips = 0
                card.ability.extra = extra

                return {
                    message = "Reset",
                    colour = G.C.GREY
                }
            end
        end

        if context.cardarea == G.jokers and context.joker_main then
            local chips = (card.ability.extra and card.ability.extra.chips) or 0
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
                local extra = (card.ability and card.ability.extra) or {}
                local chips = extra.chips or 0
                local gain = extra.chip_gain or 30

                card.joker_display_values.chips_text = "+" .. tostring(chips)
                card.joker_display_values.status_text = "+" .. tostring(gain) .. " per hand"
            end
        }
    end
}
