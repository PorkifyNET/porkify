SMODS.Joker{ -- Juice Box
    key = "juicebox",
    config = {
        extra = {
            xmult_per_diamond = 0.2
        }
    },
    loc_txt = {
        ['name'] = 'Juice Box',
        ['text'] = {
            [1] = '{X:red,C:white}X#1#{} Mult per',
            [2] = 'scoring {C:diamonds}Diamond{} card',
            [3] = 'in played hand'
        }
    },
    pos = {
        x = 1,
        y = 8
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
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },

    credit_badges = {
        { text = "Art: Rahmat", colour = "FF7900" }
     },

    loc_vars = function(self, info_queue, card)
        local extra = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { extra.xmult_per_diamond or 0.2 } }
    end,

    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.joker_main then
            local scoring_hand = context.scoring_hand or context.full_hand or {}
            local diamonds = 0

            for _, played_card in ipairs(scoring_hand) do
                if played_card
                    and played_card.is_suit
                    and played_card:is_suit("Diamonds")
                    and not played_card.debuff
                    and played_card.facing ~= "back" then
                    diamonds = diamonds + 1
                end
            end

            if diamonds > 0 then
                return {
                    Xmult = 1 + diamonds * ((card.ability.extra and card.ability.extra.xmult_per_diamond) or 0.2)
                }
            end
        end
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                {
                    border_nodes = {
                        { text = "X" },
                        { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
                    }
                }
            },
            reminder_text = {
                { text = "(", colour = G.C.GREY },
                { text = "Diamonds", colour = G.C.SUITS["Diamonds"] },
                { text = ")", colour = G.C.GREY }
            },

            calc_function = function(card)
                local extra = (card.ability and card.ability.extra) or { xmult_per_diamond = 0.2 }
                local per = extra.xmult_per_diamond or 0.2
                local diamonds = 0
                local text, _, scoring_hand = JokerDisplay.evaluate_hand()

                if text ~= "Unknown" and scoring_hand then
                    for _, c in pairs(scoring_hand) do
                        if c
                            and c.is_suit
                            and c:is_suit("Diamonds")
                            and not c.debuff
                            and c.facing ~= "back" then
                            diamonds = diamonds + JokerDisplay.calculate_card_triggers(c, scoring_hand)
                        end
                    end
                end

                card.joker_display_values.x_mult = 1 + diamonds * per
            end
        }
    end
}
