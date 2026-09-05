local function porkify_is_glass_card(playing_card)
    local center = playing_card and playing_card.config and playing_card.config.center
    return center and center.key == "m_glass"
end

SMODS.Joker{ -- Potion
    key = "potion",
    config = {
        extra = {
            destroy_odds = 16
        }
    },
    loc_txt = {
        ['name'] = 'Potion',
        ['text'] = {
            [1] = '{C:attention}Retrigger{} all played',
            [2] = '{C:enhanced}Glass{} cards',
            [3] = '{C:green}#1# in #2#{} chance this',
            [4] = 'card is {C:red}destroyed{}',
            [5] = 'at end of round'
        }
    },
    pos = {
        x = 4,
        y = 8
    },
    display_size = {
        w = 71,
        h = 95
    },
    cost = 5,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = false,
    perishable_compat = true,
    unlocked = true,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["porkify_porkify_jokers"] = true },

    credit_badges = {
        { text = "Art: danidoespixels", colour = "4A5DF9" }
     },

    in_pool = function(self, args)
        for _, playing_card in pairs(G.playing_cards or {}) do
            if playing_card and SMODS.get_enhancements(playing_card)["m_glass"] == true then
                return true
            end
        end
        return false
    end,

    loc_vars = function(self, info_queue, card)
        local glass_center = G.P_CENTERS["m_glass"]
        if glass_center then
            info_queue[#info_queue + 1] = glass_center
        end

        local extra = (card and card.ability and card.ability.extra) or self.config.extra or {}
        local destroy_odds = extra.destroy_odds or 16
        local num, den = SMODS.get_probability_vars(card, 1, destroy_odds, 'j_porkify_potion_destroy')

        return { vars = { num, den } }
    end,

    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play and context.other_card then
            if porkify_is_glass_card(context.other_card) then
                return {
                    repetitions = 1,
                    message = "Again!"
                }
            end
        end

        if context.end_of_round
            and context.main_eval
            and not context.game_over
            and not context.blueprint then
            return {
                func = function()
                    local extra = (card.ability and card.ability.extra) or {}
                    local destroy_odds = extra.destroy_odds or 16

                    if SMODS.pseudorandom_probability(
                        card,
                        'group_potion_destroy',
                        1,
                        destroy_odds,
                        'j_porkify_potion_destroy',
                        false
                    ) then
                        if card.ability.eternal then
                            card.ability.eternal = nil
                        end
                        card.getting_sliced = true
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                card:start_dissolve({ G.C.RED }, nil, 1.6)
                                return true
                            end
                        }))
                        card_eval_status_text(
                            context.blueprint_card or card,
                            'extra',
                            nil,
                            nil,
                            nil,
                            { message = "Shattered!", colour = G.C.RED }
                        )
                    end

                    return true
                end
            }
        end
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { ref_table = "card.joker_display_values", ref_value = "odds_text", colour = G.C.GREEN, scale = 0.3 }
            },
            reminder_text = {
                { text = "(", colour = G.C.GREY },
                { text = "Glass", colour = G.C.SECONDARY_SET["Enhanced"] },
                { text = ")", colour = G.C.GREY },
            },

            calc_function = function(card)
                local extra = (card.ability and card.ability.extra) or {}
                local destroy_odds = extra.destroy_odds or 16
                local num, den = 1, destroy_odds

                if SMODS.get_probability_vars then
                    local nn, dd = SMODS.get_probability_vars(card, 1, destroy_odds, 'j_porkify_potion_destroy')
                    num = nn or num
                    den = dd or den
                end

                card.joker_display_values.odds_text = "(" .. tostring(num) .. " in " .. tostring(den) .. ")"
            end
        }
    end
}
