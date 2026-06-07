SMODS.Consumable {
    key = 'diamondhands',
    set = 'porkify',
    pos = { x = 1, y = 5 },
    loc_txt = {
        name = 'Diamond Hands',
        text = {
            [1] = 'Enhance up to {C:attention}2{} selected',
            [2] = 'cards to {C:enhanced}Diamond{} cards'
        }
    },
    config = { min_highlighted = 1, max_highlighted = 2 },
    cost = 3,
    unlocked = true,
    discovered = false,
    hidden = false,
    can_repeat_soul = false,
    atlas = 'CustomConsumables',

    loc_vars = function(self, info_queue, card)
        local info_queue_0 = G.P_CENTERS["m_porkify_diamond"]
        if info_queue_0 then
            info_queue[#info_queue + 1] = info_queue_0
        end
        return { vars = {} }
    end,

    use = function(self, card, area, copier)
        local used_card = copier or card
        if not (G.hand and #G.hand.cards > 0 and to_big(#G.hand.highlighted) >= to_big(1) and to_big(#G.hand.highlighted) <= to_big(2)) then return end

        local targets = {}
        for i = 1, #G.hand.highlighted do
            targets[i] = G.hand.highlighted[i]
        end

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                used_card:juice_up(0.3, 0.5)
                return true
            end
        }))

        for i = 1, #targets do
            local percent = 1.15 - (i - 0.999) / (#targets - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    targets[i]:flip()
                    play_sound('card1', percent)
                    targets[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end

        delay(0.2)

        for i = 1, #targets do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    targets[i]:set_ability(G.P_CENTERS.m_porkify_diamond, nil, true)
                    return true
                end
            }))
        end

        for i = 1, #targets do
            local percent = 0.85 + (i - 0.999) / (#targets - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    targets[i]:flip()
                    play_sound('tarot2', percent, 0.6)
                    targets[i]:juice_up(0.3, 0.3)
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
        return (G.hand and #G.hand.cards > 0 and to_big(#G.hand.highlighted) >= to_big(1) and to_big(#G.hand.highlighted) <= to_big(2)) == true
    end
}
