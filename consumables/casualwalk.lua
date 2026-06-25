SMODS.Consumable {
    key = 'casualwalk',
    set = 'porkify',
    pos = { x = 3, y = 0 },
    loc_txt = {
        name = 'Casual Walk',
        text = {
            [1] = 'Permanently add a random',
            [2] = 'bonus to {C:attention}1{} selected card'
        }
    },
    cost = 3,
    unlocked = true,
    discovered = false,
    hidden = false,
    can_repeat_soul = false,
    atlas = 'CustomConsumables',

    use = function(self, card, area, copier)
        local used_card = copier or card
        if not (G.hand and #G.hand.cards > 0 and to_big(#G.hand.highlighted) == to_big(1)) then
            return
        end

        local target = G.hand.highlighted[1]
        if not (target and target.ability) then
            return
        end

        local buffs = {
            {
                apply = function(c)
                    c.ability.perma_bonus = (c.ability.perma_bonus or 0) + 30
                end,
                message = "+30 Chips",
                colour = G.C.CHIPS
            },
            {
                apply = function(c)
                    c.ability.perma_mult = (c.ability.perma_mult or 0) + 4
                end,
                message = "+4 Mult",
                colour = G.C.MULT
            },
            {
                apply = function(c)
                    c.ability.perma_x_mult = (c.ability.perma_x_mult or 0) + 0.5
                end,
                message = "X1.5 Mult",
                colour = G.C.MULT
            },
            {
                apply = function(c)
                    c.ability.perma_h_x_mult = (c.ability.perma_h_x_mult or 0) + 0.25
                end,
                message = "X1.25 Mult Held",
                colour = G.C.MULT
            },
            {
                apply = function(c)
                    c.ability.perma_bonus = (c.ability.perma_bonus or 0) + 50
                end,
                message = "+50 Chips",
                colour = G.C.CHIPS
            },
            {
                apply = function(c)
                    c.ability.perma_h_dollars = (c.ability.perma_h_dollars or 0) + 3
                end,
                message = "$3 Held",
                colour = G.C.MONEY
            },
            {
                apply = function(c)
                    c.ability.perma_mult = (c.ability.perma_mult or 0) + 2
                    c.ability.perma_p_dollars = (c.ability.perma_p_dollars or 0) + 2
                end,
                message = "+2 Mult, +$2",
                colour = G.C.MONEY
            },
            {
                apply = function(c)
                    c.ability.perma_x_chips = (c.ability.perma_x_chips or 0) + 0.5
                end,
                message = "X1.5 Chips",
                colour = G.C.CHIPS
            }
        }

        local chosen_buff = pseudorandom_element(buffs, pseudoseed('porkify_casualwalk'))

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                used_card:juice_up(0.3, 0.5)
                return true
            end
        }))

        for i = 1, #G.hand.highlighted do
            local percent = 1.15 - (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('card1', percent)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end

        delay(0.2)

        for i = 1, #G.hand.highlighted do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    chosen_buff.apply(G.hand.highlighted[i])
                    card_eval_status_text(
                        G.hand.highlighted[i],
                        'extra', nil, nil, nil,
                        { message = chosen_buff.message, colour = chosen_buff.colour }
                    )
                    return true
                end
            }))
        end

        for i = 1, #G.hand.highlighted do
            local percent = 0.85 + (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('tarot2', percent, 0.6)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all()
                return true
            end
        }))

        delay(0.5)
    end,

    can_use = function(self, card)
        return (G.hand and #G.hand.cards > 0 and to_big(#G.hand.highlighted) == to_big(1))
    end
}
