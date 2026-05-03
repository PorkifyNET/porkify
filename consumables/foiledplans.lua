
SMODS.Consumable {
    key = 'foiledplans',
    set = 'porkify',
    pos = { x = 3, y = 1 },
    config = { 
        extra = {
            cardsinhand = 0   
        } 
    },
    loc_txt = {
        name = 'Foiled Plans',
        text = {
            [1] = 'Make {C:attention}all{} cards held in',
            [2] = 'hand {C:edition}Foil{}'
        }
    },
    cost = 3,
    unlocked = true,
    discovered = false,
    hidden = false,
    can_repeat_soul = false,
    atlas = 'CustomConsumables',

    loc_vars = function(self, info_queue, card)
        
        local info_queue_0 = G.P_CENTERS["e_foil"]
        if info_queue_0 then
            info_queue[#info_queue + 1] = info_queue_0
        else
            error("JOKERFORGE: Invalid key in infoQueues. \"e_foil\" isn't a valid Object key, Did you misspell it or forgot a modprefix?")
        end
        return {vars = {}}
    end,

    use = function(self, card, area, copier)
        local used_card = copier or card
        if G.hand and #G.hand.cards > 0 then
            local affected_cards = {}
            local temp_hand = {}
            
        for _, playing_card in ipairs(G.hand.cards) do temp_hand[#temp_hand + 1] = playing_card end
            table.sort(temp_hand,
                function(a, b)
                    return not a.playing_card or not b.playing_card or a.playing_card < b.playing_card
                end
            )
            
            pseudoshuffle(temp_hand, 12345)
            
            for i = 1, math.min(#(G.hand and G.hand.cards or {}), #temp_hand) do 
                affected_cards[#affected_cards + 1] = temp_hand[i] 
            end
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.4,
                func = function()
                    play_sound('tarot1')
                    used_card:juice_up(0.3, 0.5)
                    return true
                end
            }))
            for i = 1, #affected_cards do
                local percent = 1.15 - (i - 0.999) / (#affected_cards - 0.998) * 0.3
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.15,
                    func = function()
                        affected_cards[i]:flip()
                        play_sound('card1', percent)
                        affected_cards[i]:juice_up(0.3, 0.3)
                        return true
                    end
                }))
            end
            delay(0.2)
            for i = 1, #affected_cards do
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.1,
                    func = function()
                        affected_cards[i]:set_edition('e_foil', true)
                        return true
                    end
                }))
            end
            for i = 1, #affected_cards do
                local percent = 0.85 + (i - 0.999) / (#affected_cards - 0.998) * 0.3
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.15,
                    func = function()
                        affected_cards[i]:flip()
                        play_sound('tarot2', percent, 0.6)
                        affected_cards[i]:juice_up(0.3, 0.3)
                        return true
                    end
                }))
            end
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    G.hand:unhighlight_all()
                    return true
                end
            }))
            delay(0.5)
        end
    end,
    can_use = function(self, card)
        return (G.hand and #G.hand.cards > 0)
    end
}