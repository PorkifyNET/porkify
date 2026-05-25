SMODS.Joker{ --Headstart
    key = "headstart",
    config = {
        extra = {
            chips = 100
        }
    },
    loc_txt = {
        ['name'] = 'Headstart',
        ['text'] = {
            [1] = '{C:chips}+#1#{} Chips if playing',
            [2] = 'against a {C:attention}Boss Blind{}'
        }
    },
    pos = {
        x = 2,
        y = 7
    },
    display_size = {
        w = 71,
        h = 95
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
        local chips = (card and card.ability and card.ability.extra and card.ability.extra.chips) or 100
        return { vars = { chips } }
    end,

    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.joker_main then
            local blind = G and G.GAME and G.GAME.blind
            local is_boss_blind = not not (
                blind and not blind.disabled and (
                    blind.boss
                    or (blind.config and blind.config.blind and blind.config.blind.boss)
                )
            )

            if is_boss_blind then
                return {
                    chips = card.ability.extra.chips or 100
                }
            end
        end
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { ref_table = "card.joker_display_values", ref_value = "chip_text", colour = G.C.BLUE }
            },

            calc_function = function(card)
                local blind = G and G.GAME and G.GAME.blind
                local is_boss_blind = not not (
                    blind and not blind.disabled and (
                        blind.boss
                        or (blind.config and blind.config.blind and blind.config.blind.boss)
                    )
                )

                local chips = (card.ability.extra and card.ability.extra.chips) or 100
                card.joker_display_values.chip_text = is_boss_blind and ("+" .. tostring(chips)) or "+0"
                card.joker_display_values.status_text = is_boss_blind and "ON" or "OFF"
            end
        }
    end
}
