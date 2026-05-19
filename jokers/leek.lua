SMODS.Joker{ --Leek
    key = "leek",
    config = {
        extra = {
            x_chips = 1,
            x_chips_gain = 0.03
        }
    },
    loc_txt = {
        ['name'] = 'Leek',
        ['text'] = {
            [1] = 'This Joker gains {X:blue,C:white}X0.03{} Chips',
            [2] = 'for every scored {C:clubs}Club{} card',
            [3] = '{C:inactive}(Currently {X:blue,C:white}X#1#{} {C:inactive}Chips){}'
        }
    },
    pos = {
        x = 2,
        y = 6
    },
    display_size = {
        w = 71,
        h = 95
    },
    cost = 9,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },

    loc_vars = function(self, info_queue, card)
        local runtime_extra = card and card.ability and card.ability.extra
        local extra = type(runtime_extra) == "table" and runtime_extra or self.config.extra
        return { vars = { extra.x_chips or 1 } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            local played_card = context.other_card
            if played_card and played_card.is_suit and played_card:is_suit("Clubs") then
                card.ability.extra.x_chips = (card.ability.extra.x_chips or 1) + ((card.ability.extra.x_chips_gain) or 0.03)
                return {
                    message = "Leek!",
                    colour = G.C.GREEN
                }
            end
        end

        if context.cardarea == G.jokers and context.joker_main then
            return {
                x_chips = (card.ability.extra and card.ability.extra.x_chips) or 1
            }
        end
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                {
                    border_nodes = {
                        { text = "X", colour = G.C.WHITE },
                        { ref_table = "card.joker_display_values", ref_value = "x_chips_text", colour = G.C.WHITE }
                    },
                    border_colour = G.C.CHIPS
                }
            },
            reminder_text = {
                { text = "(", colour = G.C.GREY },
                { text = "Clubs", colour = G.C.SUITS["Clubs"] },
                { text = ")", colour = G.C.GREY }
            },

            calc_function = function(card)
                local runtime_extra = card and card.ability and card.ability.extra
                local extra = type(runtime_extra) == "table" and runtime_extra or { x_chips = 1, x_chips_gain = 0.03 }
                local x_chips = extra.x_chips or 1
                local gain = extra.x_chips_gain or 0.03
                local clubs = 0
                local text, _, scoring_hand = JokerDisplay.evaluate_hand()

                if text ~= "Unknown" and scoring_hand then
                    for _, c in pairs(scoring_hand) do
                        if c:is_suit("Clubs") and not c.debuff and c.facing ~= 'back' then
                            clubs = clubs + JokerDisplay.calculate_card_triggers(c, scoring_hand)
                        end
                    end
                end

                card.joker_display_values.x_chips_text = x_chips
            end
        }
    end
}
