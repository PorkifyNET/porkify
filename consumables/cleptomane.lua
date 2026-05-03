
SMODS.Consumable {
    key = 'cleptomane',
    set = 'porkify',
    pos = { x = 4, y = 0 },
    config = { 
        extra = {
            currenthandsize = 0   
        } 
    },
    loc_txt = {
        name = 'Cleptomane',
        text = {
            [1] = 'Gain {C:attention}Hand Size{} in {C:money}${}.',
            [2] = '{C:inactive}(Will give{} {C:money}$#1#{}{C:inactive}){}'
        }
    },
    cost = 3,
    unlocked = true,
    discovered = false,
    hidden = false,
    can_repeat_soul = false,
    atlas = 'CustomConsumables',
    loc_vars = function(self, info_queue, card)
        return {vars = {((G.hand and G.hand.config.card_limit or 0) or 0)}}
    end,
    use = function(self, card, area, copier)
        local used_card = copier or card
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                
                local current_dollars = G.GAME.dollars
                local target_dollars = G.GAME.dollars + (G.hand and G.hand.config.card_limit or 0)
                local dollar_value = target_dollars - current_dollars
                card_eval_status_text(used_card, 'extra', nil, nil, nil, {message = "+"..tostring((G.hand and G.hand.config.card_limit or 0)).." $", colour = G.C.RED})
                ease_dollars(dollar_value, true)
                return true
            end
        }))
        delay(0.6)
    end,
    can_use = function(self, card)
        return true
    end
}