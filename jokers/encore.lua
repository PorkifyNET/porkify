SMODS.Joker{ --Encore
    key = "encore",
    config = {
        extra = {
            Xmult = 10
        }
    },
    loc_txt = {
        ['name'] = 'Encore',
        ['text'] = {
            [1] = '{X:red,C:white}X#1#{} Mult if this is',
            [2] = 'your only {C:attention}Joker{}'
        }
    },
    pos = {
        x = 4,
        y = 7
    },
    display_size = {
        w = 71,
        h = 95
    },
    cost = 10,
    rarity = 3,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'CustomJokers',
    pools = { ["porkify_porkify_jokers"] = true },

    credit_badges = {
        { text = "Art: badloom888", colour = "FDA238" }
     },

    loc_vars = function(self, info_queue, card)
        local xmult = (card and card.ability and card.ability.extra and card.ability.extra.Xmult) or 10
        return { vars = { xmult } }
    end,

    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.joker_main then
            local joker_count = (G and G.jokers and G.jokers.cards and #G.jokers.cards) or 0

            if joker_count == 1 then
                return {
                    Xmult = card.ability.extra.Xmult or 10
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

            calc_function = function(card)
                local joker_count = (G and G.jokers and G.jokers.cards and #G.jokers.cards) or 0
                local xmult = joker_count == 1 and ((card.ability.extra and card.ability.extra.Xmult) or 10) or 1

                card.joker_display_values.x_mult = xmult
            end
        }
    end
}
