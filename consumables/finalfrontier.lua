
SMODS.Consumable {
    key = 'finalfrontier',
    set = 'porkify',
    pos = { x = 2, y = 1 },
    loc_txt = {
        name = 'Final Frontier',
        text = {
            [1] = 'Upgrade a random {C:planet}poker{}',
            [2] = '{C:planet}hand{} {C:attention}3{} times'
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
        update_hand_text(
            { sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3 },
            { handname = '???', chips = '???', mult = '???', level = '' }
        )
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.8, 0.5)
                G.TAROT_INTERRUPT_PULSE = true
                return true
            end
        }))
        update_hand_text({ delay = 0 }, { mult = '+', StatusText = true })
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.9,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.8, 0.5)
                return true
            end
        }))
        update_hand_text({ delay = 0 }, { chips = '+', StatusText = true })
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.9,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.8, 0.5)
                G.TAROT_INTERRUPT_PULSE = nil
                return true
            end
        }))
        update_hand_text({ sound = 'button', volume = 0.7, pitch = 0.9, delay = 0 }, { level = '+'..tostring(3) })
        delay(1.3)            
        local hand_pool = {}
        for hand_key, _ in pairs(G.GAME.hands) do
            table.insert(hand_pool, hand_key)
        end
        local random_hand = pseudorandom_element(hand_pool, 'random_hand_levelup')
        level_up_hand(card, random_hand, true, 3)
        
        update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, 
            {handname=localize(random_hand, 'poker_hands'), 
                chips = G.GAME.hands[random_hand].chips, 
                mult = G.GAME.hands[random_hand].mult, 
            level=G.GAME.hands[random_hand].level})    
            delay(1.3)
        end,
        can_use = function(self, card)
            return true
        end
    }