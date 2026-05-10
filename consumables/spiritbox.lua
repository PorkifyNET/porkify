
SMODS.Consumable {
    key = 'spiritbox',
    set = 'porkify',
    pos = { x = 7, y = 2 },
    loc_txt = {
        name = 'Spirit Box',
        text = {
            [1] = 'Create {C:attention}2{} random',
            [2] = '{C:spectral}Spectral{} cards',
            [3] = '{C:inactive}(Must have room){}'
        }
    },
    cost = 3,
    unlocked = true,
    discovered = false,
    hidden = false,
    can_repeat_soul = false,
    atlas = 'CustomConsumables',

    credit_badges = {
        { text = "Art: u/ji0na", colour = "FF4500" }
    },

    use = function(self, card, area, copier)
        local used_card = copier or card
        for i = 1, math.min(2, G.consumeables.config.card_limit - #G.consumeables.cards) do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.4,
                func = function()
                    
                    play_sound('timpani')
                    SMODS.add_card({ set = 'Spectral', })                            
                    used_card:juice_up(0.3, 0.5)
                    return true
                end
            }))
        end
        delay(0.6)
        
        if created_consumable then
            card_eval_status_text(used_card, 'extra', nil, nil, nil, {message = "Afterlife Reached!", colour = G.C.SECONDARY_SET.Spectral})
        end
        return true
    end,
    can_use = function(self, card)
        return true
    end
}