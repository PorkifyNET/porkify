local function ready_to_shake(card)
    if not (G and G.GAME and G.hand and G.jokers and card.area == G.jokers
        and not card.debuff and not card.getting_sliced and not card.destroyed
        and not card.removed and G.STATE == G.STATES.SELECTING_HAND) then return false end
    local round = G.GAME.current_round or {}
    return round.hands_played == 0 and not card.ability.extra.triggered_this_round
end

SMODS.Joker{ --The Teacher (retain the original key for existing saves)
    key = 'theheadmaster',
    config = { extra = { triggered_this_round = false } },
    loc_txt = {
        name = 'The Teacher',
        text = {
            'If {C:attention}first hand{} of round is',
            'a single {C:attention}face card{}, {C:red}destroy{} it',
            'and create a {C:tarot}Fool{} card',
            '{C:inactive}(Must have room){}'
        },
        unlock = { 'Play {C:attention}150 face cards{}' }
    },
    pos = { x = 8, y = 1 },
    display_size = { w = 71, h = 95 },
    cost = 8,
    rarity = 2,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ['porkify_porkify_jokers'] = true },
    unlock_condition = { type = 'c_face_cards_played', extra = 150 },
    loc_vars = function(self, info_queue, card)
        if G.P_CENTERS.c_fool then info_queue[#info_queue + 1] = G.P_CENTERS.c_fool end
        return { vars = {} }
    end,
    set_ability = function(self, card, initial)
        card.ability.extra.triggered_this_round = false
    end,
    update = function(self, card, dt)
        if not card.porkify_ready_juice and ready_to_shake(card) then
            card.porkify_ready_juice = true
            juice_card_until(card, function()
                if ready_to_shake(card) then return true end
                card.porkify_ready_juice = nil
                return false
            end, true)
        end
    end,
    calculate = function(self, card, context)
        if context.blueprint or context.retrigger_joker then return end
        if context.setting_blind then
            card.ability.extra.triggered_this_round = false
            return
        end
        if not context.after or card.ability.extra.triggered_this_round then return end
        card.ability.extra.triggered_this_round = true
        if G.GAME.current_round.hands_played ~= 0 then return end
        local hand = context.full_hand or {}
        if #hand ~= 1 or not hand[1]:is_face() then return end
        local target = hand[1]
        return { func = function()
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.8,
                func = function()
                    if target.destroyed or target.shattered or target.getting_sliced or target.removed then return true end
                    if not G.consumeables or #G.consumeables.cards + (G.GAME.consumeable_buffer or 0)
                        >= G.consumeables.config.card_limit then return true end
                    local destroyed = false
                    SMODS.destroy_cards({target}, {
                        immediate = true,
                        destroy_func = function(played, args)
                            local result
                            if played.shattered then result = played:shatter(args)
                            else result = played:start_dissolve() end
                            if result == false then return false end
                            destroyed = true
                            return true
                        end
                    })
                    if destroyed then
                        local fool = SMODS.add_card({set = 'Tarot', key = 'c_fool', area = G.consumeables})
                        if fool then
                            card_eval_status_text(fool, 'extra', nil, nil, nil,
                                {message = localize('k_plus_tarot'), colour = G.C.TAROT})
                            card:juice_up(0.3, 0.5)
                        end
                    end
                    return true
                end
            }))
            return true
        end }
    end,
    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { text = '+' },
                { ref_table = 'card.joker_display_values', ref_value = 'count', retrigger_type = 'mult' }
            },
            reminder_text = {
                { text = '(' },
                { text = 'Face Cards', colour = G.C.IMPORTANT },
                { text = ')' }
            },
            calc_function = function(card)
                local _, _, scoring_hand = JokerDisplay.evaluate_hand()
                local teacher_eval = #scoring_hand == 1 and scoring_hand[1]:is_face()
                card.joker_display_values.active = G.GAME.current_round.hands_played == 0
                card.joker_display_values.count = teacher_eval and 1 or 0
            end,
            style_function = function(card, text, reminder_text, extra)
                if text and text.children[1] and text.children[2] then
                    local colour = card.joker_display_values.active and G.C.SECONDARY_SET.Tarot
                        or G.C.UI.TEXT_INACTIVE
                    text.children[1].config.colour = colour
                    text.children[2].config.colour = colour
                end
            end
        }
    end
}
