SMODS.Consumable {
    key = 'cleanupcrew',
    set = 'porkify',
    pos = { x = 2, y = 5 },
    loc_txt = {
        name = 'Cleanup Crew',
        text = {
            [1] = 'Remove the {C:dark_edition}Edition{} from',
            [2] = '{C:attention}1{} selected card'
        }
    },
    cost = 3,
    unlocked = true,
    discovered = false,
    hidden = false,
    can_repeat_soul = false,
    atlas = 'CustomConsumables',

    update = function(self, card, dt)
        Porkify_update_sticker_tool_selection()
    end,

    use = function(self, card, area, copier)
        local used_card = copier or card
        local target = Porkify_get_sticker_tool_target(card)
        if not (target and target.edition) then return end

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

        delay(0.2)

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                target:set_edition(nil, true)
                return true
            end
        }))

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.15,
            func = function()
                target:flip()
                play_sound('tarot2', 1.0, 0.6)
                target:juice_up(0.3, 0.3)
                return true
            end
        }))

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                Porkify_clear_sticker_tool_selection()
                return true
            end
        }))

        delay(0.5)
    end,

    can_use = function(self, card)
        local target = Porkify_get_sticker_tool_target(card)
        return target and target.edition ~= nil or false
    end
}
