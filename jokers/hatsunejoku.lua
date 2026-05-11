SMODS.Joker{ --Hatsune Joku
    key = "hatsunejoku",
    config = {
        extra = {
            x_chips = 1.5
        }
    },
    loc_txt = {
        ['name'] = 'Hatsune Joku',
        ['text'] = {
            [1] = 'Every played {C:attention}3{} or {C:attention}9{}',
            [2] = 'gives {X:blue,C:white}X#1#{} Chips'
        }
    },
    pos = {
        x = 3,
        y = 6
    },
    display_size = {
        w = 71,
        h = 95
    },
    cost = 6,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },

    credit_badges = {
        { text = "Art: u/neatoqueen", colour = "FF4500" }
     },

    loc_vars = function(self, info_queue, card)
        local extra = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { (extra and extra.x_chips) or 1.5 } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            local extra = (card.ability and card.ability.extra) or self.config.extra
            local x_chips = (extra and extra.x_chips) or 1.5

            if played_card
                and played_card.get_id
                and (played_card:get_id() == 3 or played_card:get_id() == 9) then
                return {
                    x_chips = x_chips
                }
            end
        end
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                {
                    border_nodes = {
                        { text = "X", colour = G.C.WHITE },
                        { ref_table = "card.joker_display_values", ref_value = "x_chips_text", colour = G.C.WHITE, retrigger_type = "exp" }
                    },
                    colour = G.C.BLUE
                }
            },
            reminder_text = {
                { text = "(3, 9)", colour = G.C.GREY }
            },

            calc_function = function(card)
                local extra = (card.ability and card.ability.extra) or {}
                local x_chips = extra.x_chips or 1.5
                local matches = 0
                local text, _, scoring_hand = JokerDisplay.evaluate_hand()

                if text ~= "Unknown" and scoring_hand then
                    for _, c in pairs(scoring_hand) do
                        if (c:get_id() == 3 or c:get_id() == 9) and not c.debuff and c.facing ~= 'back' then
                            matches = matches + JokerDisplay.calculate_card_triggers(c, scoring_hand)
                        end
                    end
                end

                card.joker_display_values.x_chips_text = (matches > 0) and (x_chips ^ matches) or 1
            end
        }
    end
}
