SMODS.Joker{ --Fortune Cookie
    key = "fortunecookie",
    config = {
        extra = {}
    },
    loc_txt = {
        ['name'] = 'Fortune Cookie',
        ['text'] = {
            [1] = 'Create a {C:tarot}Tarot{} card if',
            [2] = 'played hand contains no',
            [3] = '{C:attention}face{} cards',
            [4] = '{C:inactive}(Must have room){}'
        }
    },
    pos = {
        x = 7,
        y = 7
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
    discovered = true,
    atlas = 'CustomJokers',
    pools = { ["porkify_porkify_jokers"] = true },

    calculate = function(self, card, context)
        if context.before and context.cardarea == G.jokers and not context.blueprint then
            local full_hand = context.full_hand or {}
            local has_face_card = false

            for _, played_card in ipairs(full_hand) do
                if porkify_card_is_face_or_blank(played_card) then
                    has_face_card = true
                    break
                end
            end

            if has_face_card then
                return
            end

            if G.consumeables
                and G.consumeables.cards
                and G.consumeables.config
                and #G.consumeables.cards < G.consumeables.config.card_limit then
                return {
                    func = function()
                        local tarot = SMODS.add_card({
                            set = 'Tarot',
                            area = G.consumeables
                        })

                        if tarot then
                            card_eval_status_text(
                                tarot, 'extra', nil, nil, nil,
                                { message = localize('k_plus_tarot'), colour = G.C.TAROT }
                            )
                            card:juice_up(0.3, 0.5)
                        end
                        return true
                    end
                }
            end
        end
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { ref_table = "card.joker_display_values", ref_value = "status_text", colour = G.C.PURPLE }
            },

            calc_function = function(card)
                local text, _, scoring_hand = JokerDisplay.evaluate_hand()
                local active = false

                if text ~= "Unknown" and scoring_hand then
                    active = true
                    for _, scoring_card in ipairs(scoring_hand) do
                        if porkify_card_is_face_or_blank(scoring_card) and not scoring_card.debuff and scoring_card.facing ~= "back" then
                            active = false
                            break
                        end
                    end
                end

                card.joker_display_values.status_text = active and "+1" or "+0"
            end
        }
    end
}
