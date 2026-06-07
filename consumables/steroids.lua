
SMODS.Consumable {
    key = 'steroids',
    set = 'porkify',
    pos = { x = 9, y = 2 },
    loc_txt = {
        name = 'Steroids',
        text = {
            [1] = 'Increases rank of up',
            [2] = 'to {C:attention}3{} selected',
            [3] = 'cards by {C:attention}2{}'
        }
    },
    cost = 3,
    unlocked = true,
    discovered = false,
    hidden = false,
    can_repeat_soul = false,
    atlas = 'CustomConsumables',

    credit_badges = {
        { text = "Art: DeltonKeslar1206", colour = "00E59B" }
     },
    
    use = function(self, card, area, copier)
        local used_card = copier or card
        if (G.hand and #G.hand.cards > 0 and to_big(#G.hand.highlighted) >= to_big(1) and to_big(#G.hand.highlighted) <= to_big(3)) then
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
                        assert(SMODS.modify_rank(G.hand.highlighted[i], 2))
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
        end
    end,
    can_use = function(self, card)
        return (G.hand and #G.hand.cards > 0 and to_big(#G.hand.highlighted) >= to_big(1) and to_big(#G.hand.highlighted) <= to_big(3)) == true
    end
}
