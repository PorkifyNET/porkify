
SMODS.Consumable {
    key = 'trashtreasure',
    set = 'porkify',
    pos = { x = 7, y = 3 },
    config = { 
        extra = {
            cardsindiscard = 0   
        } 
    },
    loc_txt = {
        name = 'Trash Treasure',
        text = {
            [1] = 'Gain {C:money}$1{} for every card',
            [2] = 'in the {C:red}discard pile{}',
            [3] = '{C:inactive}(Will give{} {C:money}$#1#{}{C:inactive}){}'
        }
    },
    cost = 3,
    unlocked = true,
    discovered = false,
    hidden = false,
    can_repeat_soul = false,
    atlas = 'CustomConsumables',
    loc_vars = function(self, info_queue, card)
        return {vars = {#(G.discard and G.discard.cards or {})}}
    end,
    use = function(self, card, area, copier)
        local used_card = copier or card
        if G.GAME.blind.in_blind then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.4,
                func = function()
                    
                    local current_dollars = G.GAME.dollars
                    local target_dollars = G.GAME.dollars + #(G.discard and G.discard.cards or {})
                    local dollar_value = target_dollars - current_dollars
                    card_eval_status_text(used_card, 'extra', nil, nil, nil, {message = "+"..tostring(#(G.discard and G.discard.cards or {})).." $", colour = G.C.RED})
                    ease_dollars(dollar_value, true)
                    return true
                end
            }))
            delay(0.6)
        end
    end,
    can_use = function(self, card)
        return (G.GAME.blind.in_blind)
    end
}