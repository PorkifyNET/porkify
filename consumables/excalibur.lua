SMODS.Consumable {
    key = 'excalibur',
    set = 'porkify',
    pos = { x = 1, y = 1 },
    loc_txt = {
        name = 'Excalibur',
        text = {
            [1] = 'Remove {C:purple}Eternal{} from',
            [2] = '{C:attention}1{} selected {C:attention}card{}'
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

    credit_badges = {
        { text = "Art: munstudios", colour = "00E59B" }
     },

    loc_vars = function(self, info_queue, card)
        local info_queue_0 = (G.P_STICKERS and G.P_STICKERS["eternal"]) or (G.P_CENTERS and G.P_CENTERS["eternal"])
        if info_queue_0 then
            info_queue[#info_queue + 1] = info_queue_0
        end
        return {vars = {}}
    end,

    use = function(self, card, area, copier)
        local used_card = copier or card
        local j, target_area = Porkify_get_sticker_tool_target(card)
        if not (j.ability and j.ability.eternal) then return end

        -- use sfx/juice on the consumable
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('timpani')
                used_card:juice_up(0.3, 0.5)
                return true
            end
        }))

        -- flip joker
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.15,
            func = function()
                j:flip()
                play_sound('card1', 1.0)
                j:juice_up(0.3, 0.3)
                return true
            end
        }))

        delay(0.2)

        -- remove eternal (+ also clear other stickers you were clearing)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                j.ability.eternal = false
                if target_area == G.jokers then
                    check_for_unlock { type = 'porkify_joker_sticker_removed' }
                end
                return true
            end
        }))

        -- flip back
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.15,
            func = function()
                j:flip()
                play_sound('tarot2', 1.0, 0.6)
                j:juice_up(0.3, 0.3)
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
        return target and target.ability and target.ability.eternal or false
    end
}
