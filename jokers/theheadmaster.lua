SMODS.Joker{ --The Headmaster
    key = "theheadmaster",
    config = {
        extra = {
            triggered_this_round = false
        }
    },
    loc_txt = {
        ['name'] = 'The Headmaster',
        ['text'] = {
            [1] = 'If the first played hand',
            [2] = 'of the round consists of',
            [3] = 'only {C:attention}1{} {C:attention}Ace{}, create',
            [4] = 'a {C:tarot}Hermit{} card',
            [5] = '{C:inactive}(Must have room){}'
        },
        ['unlock'] = {
            [1] = 'Play {C:attention}150{} {C:attention}face{} {C:attention}cards{}'
        }
    },
    pos = {
        x = 8,
        y = 1
    },
    display_size = {
        w = 71 * 1,
        h = 95 * 1
    },
    cost = 8,
    rarity = 2,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["porkify_porkify_jokers"] = true },
    unlock_condition = { type = 'c_face_cards_played', extra = 150 },

    loc_vars = function(self, info_queue, card)
        local hermit = G.P_CENTERS["c_hermit"]
        if hermit then
            info_queue[#info_queue + 1] = hermit
        end
        return { vars = {} }
    end,

    set_ability = function(self, card, initial)
        card.ability.extra.triggered_this_round = false
    end,

    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            card.ability.extra.triggered_this_round = false
            return
        end

        if context.before and context.cardarea == G.jokers and not context.blueprint then
            if card.ability.extra.triggered_this_round then
                return
            end

            card.ability.extra.triggered_this_round = true

            local full_hand = context.full_hand or {}
            if #full_hand ~= 1 then
                return
            end

            local played_card = full_hand[1]
            if not played_card or played_card:get_id() ~= 14 then
                return
            end

            if G.consumeables
                and G.consumeables.cards
                and G.consumeables.config
                and #G.consumeables.cards < G.consumeables.config.card_limit then
                return {
                    func = function()
                        local hermit = SMODS.add_card({
                            set = 'Tarot',
                            key = 'c_hermit',
                            area = G.consumeables
                        })

                        if hermit then
                            card_eval_status_text(
                                hermit, 'extra', nil, nil, nil,
                                { message = localize('k_plus_tarot'), colour = G.C.TAROT }
                            )
                            card:juice_up(0.3, 0.5)
                        end
                        return true
                    end
                }
            end
        end
    end
}
