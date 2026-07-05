SMODS.Joker{ --Poker Face
    key = "pokerface",
    config = {
        extra = {
            Xmult = 2
        }
    },
    loc_txt = {
        ['name'] = 'Poker Face',
        ['text'] = {
            [1] = '{X:red,C:white}X#1#{} Mult if played hand',
            [2] = 'contains no {C:attention}face{} cards'
        }
    },
    pos = {
        x = 3,
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
        local xmult = (card and card.ability and card.ability.extra and card.ability.extra.Xmult) or 2
        return { vars = { xmult } }
    end,

    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.joker_main then
            local scoring_hand = context.scoring_hand or context.full_hand or {}
            local has_face_card = false

            for _, scoring_card in ipairs(scoring_hand) do
                if porkify_card_is_face_or_blank(scoring_card) then
                    has_face_card = true
                    break
                end
            end

            if not has_face_card then
                return {
                    Xmult = card.ability.extra.Xmult or 2
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
                local xmult = 1
                local text, _, scoring_hand = JokerDisplay.evaluate_hand()

                if text ~= "Unknown" and scoring_hand then
                    local has_face_card = false

                    for _, scoring_card in ipairs(scoring_hand) do
                        if porkify_card_is_face_or_blank(scoring_card) and not scoring_card.debuff and scoring_card.facing ~= "back" then
                            has_face_card = true
                            break
                        end
                    end

                    if not has_face_card then
                        xmult = (card.ability.extra and card.ability.extra.Xmult) or 2
                    end
                end

                card.joker_display_values.x_mult = xmult
                card.joker_display_values.status_text = xmult > 1 and "ON" or "OFF"
            end
        }
    end
}
