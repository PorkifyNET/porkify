SMODS.Joker{ --Pantry
    key = "pantry",
    config = {
        extra = {
            mult_gain = 10
        }
    },
    loc_txt = {
        ['name'] = 'Pantry',
        ['text'] = {
            [1] = 'Each owned {C:tarot}consumable{}',
            [2] = 'gives {C:red}+#1#{} Mult'
        }
    },
    pos = {
        x = 5,
        y = 7
    },
    display_size = {
        w = 49,
        h = 57
    },
    cost = 5,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'CustomJokers',
    pools = { ["porkify_porkify_jokers"] = true },

    loc_vars = function(self, info_queue, card)
        local mult_gain = (card and card.ability and card.ability.extra and card.ability.extra.mult_gain) or 10
        return { vars = { mult_gain } }
    end,

    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.joker_main then
            local mult_gain = (card.ability.extra and card.ability.extra.mult_gain) or 10
            local consumable_count = #(G.consumeables and G.consumeables.cards or {})
            local mult = consumable_count * mult_gain

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

            calc_function = function(card)
                local mult_gain = (card.ability.extra and card.ability.extra.mult_gain) or 10
                local consumable_count = #(G.consumeables and G.consumeables.cards or {})
                local mult = consumable_count * mult_gain

                card.joker_display_values.mult_text = "+" .. tostring(mult)
                card.joker_display_values.status_text = tostring(consumable_count) .. " consumables"
            end
        }
    end
}
