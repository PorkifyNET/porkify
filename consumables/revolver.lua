SMODS.Consumable {
    key = 'revolver',
    set = 'porkify',
    pos = { x = 6, y = 4 },
    loc_txt = {
        name = 'Revolver',
        text = {
            [1] = 'Enhance up to {C:attention}3{} selected',
            [2] = 'cards to {C:enhanced}Resolute{} cards'
        }
    },
    config = { min_highlighted = 1, max_highlighted = 3 },
    cost = 3,
    unlocked = true,
    discovered = false,
    hidden = false,
    can_repeat_soul = false,
    atlas = 'CustomConsumables',

    loc_vars = function(self, info_queue, card)
        local info_queue_0 = G.P_CENTERS["m_porkify_revolving"]
        if info_queue_0 then
            info_queue[#info_queue + 1] = info_queue_0
        end
        return { vars = {} }
    end,

    use = function(self, card, area, copier)
        local used_card = copier or card
        if not (G.hand and #G.hand.cards > 0 and to_big(#G.hand.highlighted) >= to_big(1) and to_big(#G.hand.highlighted) <= to_big(3)) then return end
        local selected_cards = {}
        for i = 1, #G.hand.highlighted do
            selected_cards[i] = {
                card = G.hand.highlighted[i],
                was_back = G.hand.highlighted[i].facing == 'back'
            }
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

        for i = 1, #G.hand.highlighted do
            local percent = 1.15 - (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    local entry = selected_cards[i]
                    if entry and entry.card and not entry.was_back then
                        entry.card:flip()
                    end
                    play_sound('card1', percent)
                    if entry and entry.card then
                        entry.card:juice_up(0.3, 0.3)
                    end
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
                    local entry = selected_cards[i]
                    if entry and entry.card then
                        entry.card:set_ability(G.P_CENTERS.m_porkify_revolving, nil, true)
                        entry.card.ability.wheel_flipped = nil
                    end
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
                    local entry = selected_cards[i]
                    if entry and entry.card and entry.card.facing == 'back' then
                        entry.card:flip()
                    end
                    play_sound('tarot2', percent, 0.6)
                    if entry and entry.card then
                        entry.card:juice_up(0.3, 0.3)
                    end
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
        return (G.hand and #G.hand.cards > 0 and to_big(#G.hand.highlighted) >= to_big(1) and to_big(#G.hand.highlighted) <= to_big(3)) == true
    end
}
