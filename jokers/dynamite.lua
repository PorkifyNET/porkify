local function queue_dynamite_shake(card)
    if not (card and card.ability and card.ability.extra) then
        return
    end
    if card.ability.extra.shake_queued then
        return
    end

    card.ability.extra.shake_queued = true

    local function pulse()
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 1.6,
            blocking = false,
            func = function()
                if not (card and card.ability and card.ability.extra) then
                    return true
                end

                if (card.ability.extra.hands_remaining or 10) == 1 and not card.getting_sliced then
                    if card.juice_up then
                        card:juice_up(0.08, 0.12)
                    end
                    pulse()
                else
                    card.ability.extra.shake_queued = false
                end
                return true
            end
        }))
    end

    pulse()
end

SMODS.Joker{ --Dynamite
    key = "dynamite",
    config = {
        extra = {
            hands_remaining = 10,
            x_chips = 3,
            Xmult = 3,
            shake_queued = false
        }
    },
    loc_txt = {
        ['name'] = 'Dynamite',
        ['text'] = {
            [1] = 'After {C:attention}10{} played hands,',
            [2] = 'give {X:blue,C:white}X#2#{} Chips and {X:red,C:white}X#3#{} Mult,',
            [3] = '{C:red,E:1}Self-Destructs{}',
            [4] = '{C:inactive}(#1# remaining){}'
        },
        ['unlock'] = {
            [1] = 'Discover {C:attention}10{} Blinds'
        }
    },
    pos = {
        x = 5,
        y = 1
    },
    display_size = {
        w = 71 * 1,
        h = 95 * 1
    },
    cost = 4,
    rarity = 1,
    blueprint_compat = false,
    eternal_compat = false,
    perishable_compat = false,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["porkify_porkify_jokers"] = true },
    unlock_condition = { type = 'blind_discoveries', extra = 10 },

    loc_vars = function(self, info_queue, card)
        local extra = card and card.ability and card.ability.extra or self.config.extra
        return { vars = { extra.hands_remaining or 10, extra.x_chips or 3, extra.Xmult or 3 } }
    end,

    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.joker_main then
            if (card.ability.extra.hands_remaining or 10) <= 1 then
                return {
                    x_chips = card.ability.extra.x_chips or 3,
                    Xmult = card.ability.extra.Xmult or 3
                }
            end
        end

        if context.after and context.cardarea == G.jokers and not context.blueprint then
            card.ability.extra.hands_remaining = math.max((card.ability.extra.hands_remaining or 10) - 1, 0)

            if card.ability.extra.hands_remaining == 1 then
                queue_dynamite_shake(card)
            end

            if card.ability.extra.hands_remaining <= 0 then
                return {
                    func = function()
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            delay = 0.2,
                            blocking = false,
                            func = function()
                                if card and card.start_dissolve and not card.getting_sliced then
                                    card.getting_sliced = true
                                    card:start_dissolve({ G.C.RED }, nil, 1.6)
                                end
                                return true
                            end
                        }))

                        card_eval_status_text(
                            context.blueprint_card or card, 'extra', nil, nil, nil,
                            { message = "BOOM!", colour = G.C.RED }
                        )
                        return true
                    end
                }
            else
                return {
                    message = tostring(card.ability.extra.hands_remaining) .. "!",
                    colour = G.C.FILTER
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
                        { ref_table = "card.joker_display_values", ref_value = "chips_text", colour = G.C.WHITE }
                    },
                    colour = G.C.BLUE
                },
                { text = " " },
                {
                    border_nodes = {
                        { text = "X", colour = G.C.WHITE },
                        { ref_table = "card.joker_display_values", ref_value = "mult_text", colour = G.C.WHITE }
                    },
                    colour = G.C.RED
                }
            },
            reminder_text = {
                { ref_table = "card.joker_display_values", ref_value = "remaining_text", colour = G.C.GREY }
            },
            style_function = function(card, text, reminder_text, extra)
                if text and text.children and text.children[1] then
                    text.children[1].config.colour = G.C.BLUE
                end
                if reminder_text and reminder_text.children and reminder_text.children[1] then
                    local hands_remaining = (card.ability and card.ability.extra and card.ability.extra.hands_remaining) or 10
                    reminder_text.children[1].config.colour = hands_remaining <= 1 and G.C.GREEN or G.C.GREY
                end
                return false
            end,
            calc_function = function(card)
                local extra = card.ability and card.ability.extra or {}
                local enabled = (extra.hands_remaining or 10) <= 1
                card.joker_display_values.chips_text = tostring(enabled and (extra.x_chips or 3) or 1)
                card.joker_display_values.mult_text = tostring(enabled and (extra.Xmult or 3) or 1)
                card.joker_display_values.remaining_text = enabled and "Active!" or (tostring(extra.hands_remaining or 10) .. " remaining")
            end
        }
    end
}
