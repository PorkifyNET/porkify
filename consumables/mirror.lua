SMODS.Consumable {
    key = 'mirror',
    set = 'porkify',
    pos = { x = 9, y = 1 },
    loc_txt = {
        name = 'Mirror',
        text = {
            [1] = 'Create a {C:gold}Double Tag{}'
        }
    },
    cost = 3,
    unlocked = true,
    discovered = false,
    hidden = false,
    can_repeat_soul = false,
    atlas = 'CustomConsumables',

    loc_vars = function(self, info_queue, card)
        local info_queue_0 = (G.P_TAGS and G.P_TAGS["tag_double"]) or (G.P_CENTERS and G.P_CENTERS["tag_double"])
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
                local tag = Tag("tag_double")
                tag:set_ability()
                add_tag(tag)

                card_eval_status_text(
                    used_card,
                    'extra',
                    nil, nil, nil,
                    { message = "!gaT detaerC", colour = G.C.GOLD }
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
