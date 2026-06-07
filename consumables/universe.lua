SMODS.Consumable {
    key = 'universe',
    set = 'porkify',
    pos = { x = 1, y = 4 },
    loc_txt = {
        name = 'Universe',
        text = {
            [1] = 'Enhance {C:attention}1{} selected',
            [2] = 'card to an {C:enhanced}Galaxy{} card'
        }
    },
    config = { min_highlighted = 1, max_highlighted = 1 },
    cost = 3,
    unlocked = true,
    discovered = false,
    hidden = false,
    can_repeat_soul = false,
    atlas = 'CustomConsumables',

    credit_badges = {
        { text = "Art: Camila Tagliabue", colour = "F72536" }
     },

    loc_vars = function(self, info_queue, card)
        local info_queue_0 = G.P_CENTERS["m_porkify_galaxy"]
        if info_queue_0 then
            info_queue[#info_queue + 1] = info_queue_0
        end
        return { vars = {} }
    end,

    use = function(self, card, area, copier)
        local used_card = copier or card
        if not (G.hand and #G.hand.cards > 0 and to_big(#G.hand.highlighted) == to_big(1)) then return end

        local target = G.hand.highlighted[1]
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                used_card:juice_up(0.3, 0.5)
                return true
            end
        }))

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.15,
            func = function()
                target:flip()
                play_sound('card1', 1.0)
                target:juice_up(0.3, 0.3)
                return true
            end
        }))

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.35,
            func = function()
                target:set_ability(G.P_CENTERS.m_porkify_galaxy, nil, true)
                return true
            end
        }))

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.55,
            func = function()
                target:flip()
                play_sound('tarot2', 1.0, 0.6)
                target:juice_up(0.3, 0.3)
                G.hand:unhighlight_all()
                return true
            end
        }))
    end,

    can_use = function(self, card)
        return (G.hand and #G.hand.cards > 0 and to_big(#G.hand.highlighted) == to_big(1)) == true
    end
}
