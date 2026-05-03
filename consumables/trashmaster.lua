
SMODS.Consumable {
    key = 'trashmaster',
    set = 'porkify',
    pos = { x = 6, y = 3 },
    config = { 
        extra = {
            discards0 = 2,
            discard_size0 = 1   
        } 
    },
    loc_txt = {
        name = 'Trashmaster',
        text = {
            [1] = '{C:red}+2{} Discards,',
            [2] = '{C:red}-1{} Discard Size'
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
                card_eval_status_text(used_card, 'extra', nil, nil, nil, {message = "+"..tostring(2).." Discards", colour = G.C.GREEN})
                
                G.GAME.round_resets.discards = G.GAME.round_resets.discards + 2
                ease_discard(2)
                
                return true
            end
        }))
        delay(0.6)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                card_eval_status_text(used_card, 'extra', nil, nil, nil, {message = "-"..tostring(1).." Discard Size", colour = G.C.BLUE})
                
                SMODS.change_discard_limit(-1)
                return true
            end
        }))
        delay(0.6)
    end,
    can_use = function(self, card)
        return true
    end
}