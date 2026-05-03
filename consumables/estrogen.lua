
SMODS.Consumable {
    key = 'estrogen',
    set = 'porkify',
    pos = { x = 0, y = 1 },
    loc_txt = {
        name = 'Estrogen',
        text = {
            [1] = 'Turn {C:attention}1{} selected card',
            [2] = 'into a {C:attention}Queen{} and add',
            [3] = 'a {C:blue}Blue{} Seal'
        }
    },
    cost = 3,
    unlocked = true,
    discovered = false,
    hidden = false,
    can_repeat_soul = false,
    atlas = 'CustomConsumables',

    loc_vars = function(self, info_queue, card)
        local info_queue_0 = G.P_SEALS and G.P_SEALS["Blue"]
        if info_queue_0 then
            info_queue[#info_queue + 1] = info_queue_0
        end
        return {vars = {}}
    end,

    use = function(self, card, area, copier)
        local used_card = copier or card
        if (G.hand and #G.hand.cards > 0 and to_big(#G.hand.highlighted) == to_big(1)) then
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
                        G.hand.highlighted[i]:set_seal("Blue", nil, true)
                        return true
                    end
                }))
            end
            for i = 1, #G.hand.highlighted do
				local c = G.hand.highlighted[i]
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.1,
                    func = function()
                        assert(SMODS.change_base(G.hand.highlighted[i], nil, "Queen"))
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
        return ((G.hand and #G.hand.cards > 0 and to_big(#G.hand.highlighted) == to_big(1)))
    end
}
