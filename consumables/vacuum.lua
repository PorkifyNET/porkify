
SMODS.Consumable {
    key = 'vacuum',
    set = 'porkify',
    pos = { x = 8, y = 3 },
    config = { 
        extra = {
            currenthandsize = 0   
        } 
    },
    loc_txt = {
        name = 'Vacuum',
        text = {
            [1] = 'Draw amount of cards',
            [2] = 'equal to current {C:attention}Hand Size{}',
            [3] = '{C:inactive}(Currently{} {C:attention}#1#{} {C:inactive}cards){}'
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
        if (G.GAME.blind.in_blind and G.hand and #G.hand.cards > 0) then
            if G.hand and #G.hand.cards > 0 then
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.4,
                    func = function()
                        card_eval_status_text(used_card, 'extra', nil, nil, nil, {message = "+"..tostring((G.hand and G.hand.config.card_limit or 0)).." Cards Drawn", colour = G.C.BLUE})
                        SMODS.draw_cards((G.hand and G.hand.config.card_limit or 0))
                        return true
                    end
                }))
                delay(0.6)
            end
        end
    end,
    can_use = function(self, card)
        return ((G.GAME.blind.in_blind and G.hand and #G.hand.cards > 0))
    end
}