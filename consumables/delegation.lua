
SMODS.Consumable {
    key = 'delegation',
    set = 'porkify',
    pos = { x = 6, y = 0 },
    config = { 
        extra = {
            currenthandsize = 0,
            hand_size0 = 1,
            hands0 = 1   
        } 
    },
    loc_txt = {
        name = 'Delegation',
        text = {
            [1] = '{C:red}-1{} Hand Size, {C:blue}+1{} Hand'
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
        if to_big((G.hand and G.hand.config.card_limit or 0)) > to_big(0) then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.4,
                func = function()
                    card_eval_status_text(used_card, 'extra', nil, nil, nil, {message = "-"..tostring(1).." Hand Limit", colour = G.C.BLUE})

                    if Porkify_safe_change_hand_size then
                        Porkify_safe_change_hand_size(-1)
                    else
                        G.hand:change_size(-1)
                    end
                    return true
                end
            }))
            delay(0.6)
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.4,
                
                func = function()
                    card_eval_status_text(used_card, 'extra', nil, nil, nil, {message = "+"..tostring(1).." Hands", colour = G.C.GREEN})
                    
                    G.GAME.round_resets.hands = G.GAME.round_resets.hands + 1
                    ease_hands_played(1)
                    
                    return true
                end
            }))
            delay(0.6)
        end
    end,
    can_use = function(self, card)
        return (to_big((G.hand and G.hand.config.card_limit or 0)) > to_big(0))
    end
}
