SMODS.Consumable {
    key = 'stockbroker',
    set = 'porkify',
    pos = { x = 0, y = 3 },
    loc_txt = {
        name = 'Stock Broker',
        text = {
            [1] = 'Create an {C:gold}Investment{}',
            [2] = '{C:gold}Tag{}'
        }
    },
    cost = 3,
    unlocked = true,
    discovered = false,
    hidden = false,
    can_repeat_soul = false,
    atlas = 'CustomConsumables',

    loc_vars = function(self, info_queue, card)
        local info_queue_0 = (G.P_TAGS and G.P_TAGS["tag_investment"]) or (G.P_CENTERS and G.P_CENTERS["tag_investment"])
        if info_queue_0 then
            info_queue[#info_queue + 1] = info_queue_0
        end
        return {vars = {}}
    end,

    use = function(self, card, area, copier)
        local used_card = copier or card

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                local tag = Tag("tag_investment")
                tag:set_ability()
                add_tag(tag)

                card_eval_status_text(
                    used_card,
                    'extra',
                    nil, nil, nil,
                    { message = "Invested!", colour = G.C.GOLD }
                )

                play_sound('holo1', 1.2 + math.random() * 0.1, 0.4)
                used_card:juice_up(0.3, 0.5)
                return true
            end
        }))
    end,

    can_use = function(self, card)
        return true
    end
}
