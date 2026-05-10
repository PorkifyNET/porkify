
SMODS.Consumable {
    key = 'sixthfinger',
    set = 'porkify',
    pos = { x = 6, y = 2 },
    config = { 
        extra = {
            cardsinhand = 0,
            hand_size0 = 1   
        } 
    },
    loc_txt = {
        name = 'Sixth Finger',
        text = {
            [1] = '{C:attention}+1{} Hand Size,',
            [2] = '{C:red}destroy{} all cards',
            [3] = 'currently in hand'
        }
    },
    cost = 3,
    unlocked = true,
    discovered = false,
    hidden = false,
    can_repeat_soul = false,
    atlas = 'CustomConsumables',

    credit_badges = {
        { text = "Art: u/HumungusDude", colour = "FF4500" }
    },

    use = function(self, card, area, copier)
        local used_card = copier or card
        if G.hand and #G.hand.cards > 0 then
            local destroyed_cards = {}
            local temp_hand = {}
            
        for _, playing_card in ipairs(G.hand.cards) do temp_hand[#temp_hand + 1] = playing_card end
            table.sort(temp_hand,
                function(a, b)
                    return not a.playing_card or not b.playing_card or a.playing_card < b.playing_card
                end
            )
            
            pseudoshuffle(temp_hand, 12345)
            
        for i = 1, #(G.hand and G.hand.cards or {}) do destroyed_cards[#destroyed_cards + 1] = temp_hand[i] end
            
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.4,
                func = function()
                    play_sound('tarot1')
                    card:juice_up(0.3, 0.5)
                    for _, destroyed in ipairs(destroyed_cards) do
                        if destroyed and destroyed.remove_from_deck then
                            destroyed:remove_from_deck()
                        end
                    end
                    SMODS.destroy_cards(destroyed_cards)
                    return true
                end
            }))
            
            delay(0.5)
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.4,
                func = function()
                    card_eval_status_text(used_card, 'extra', nil, nil, nil, {message = "+"..tostring(1).." Hand Limit", colour = G.C.BLUE})
                    
                    G.hand:change_size(1)
                    return true
                end
            }))
            delay(0.6)
        end
    end,
    can_use = function(self, card)
        if not (G.hand and #G.hand.cards > 0 and G.playing_cards) then
            return false
        end
        return (#G.playing_cards - #G.hand.cards) >= 5
    end
}
