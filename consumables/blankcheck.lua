SMODS.Consumable {
    key = 'blankcheck',
    set = 'porkify',
    pos = { x = 8, y = 4 },
    loc_txt = {
        name = 'Blank Check',
        text = {
            [1] = 'Add a {C:attention}Blank Seal{} to',
            [2] = '{C:attention}1{} selected card'
        }
    },
    config = { min_highlighted = 1, max_highlighted = 1 },
    cost = 3,
    unlocked = true,
    discovered = false,
    hidden = false,
    can_repeat_soul = false,
    atlas = 'CustomConsumables',

    loc_vars = function(self, info_queue, card)
        local info_queue_0 = G.P_SEALS and (G.P_SEALS["porkify_blank"] or G.P_SEALS["blank"])
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
                target:set_seal("porkify_blank", nil, true)
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
