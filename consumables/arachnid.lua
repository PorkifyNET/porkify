
SMODS.Consumable {
    key = 'arachnid',
    set = 'porkify',
    pos = { x = 0, y = 0 },
    config = { 
        extra = {
            hands0 = 1,
            play_size0 = 1   
        } 
    },
    loc_txt = {
        name = 'Arachnid',
        text = {
            [1] = '{C:attention}+1{} Play Size'
        }
    },
    cost = 3,
    unlocked = true,
    discovered = false,
    hidden = false,
    can_repeat_soul = false,
    atlas = 'CustomConsumables',
    use = function(self, card, area, copier)
        local used_card = copier or card
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                card_eval_status_text(used_card, 'extra', nil, nil, nil, {message = "+"..tostring(1).." Play Size", colour = G.C.BLUE})
                
                SMODS.change_play_limit(1)
                return true
            end
        }))
        delay(0.6)
    end,
    can_use = function(self, card)
        return true
    end
}