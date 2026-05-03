
SMODS.Consumable {
    key = 'primate',
    set = 'porkify',
    pos = { x = 1, y = 2 },
    loc_txt = {
        name = 'Primate',
        text = {
            [1] = 'Create a {C:dark_edition}Negative{}',
            [2] = '{C:attention}Gros Michel{}'
        }
    },
    cost = 3,
    unlocked = true,
    discovered = false,
    hidden = false,
    can_repeat_soul = false,
    atlas = 'CustomConsumables',

    loc_vars = function(self, info_queue, card)
        
        local info_queue_0 = G.P_CENTERS["j_gros_michel"]
        if info_queue_0 then
            info_queue[#info_queue + 1] = info_queue_0
        else
            error("JOKERFORGE: Invalid key in infoQueues. \"j_gros_michel\" isn't a valid Object key, Did you misspell it or forgot a modprefix?")
        end
        return {vars = {}}
    end,

    use = function(self, card, area, copier)
        local used_card = copier or card
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('timpani')
                local new_joker = SMODS.add_card({ set = 'Joker', key = 'j_gros_michel' })
                if new_joker then
                    new_joker:set_edition("e_negative", true)
                end
                used_card:juice_up(0.3, 0.5)
                return true
            end
        }))
        delay(0.6)
    end,
    can_use = function(self, card)
        return true
    end
}