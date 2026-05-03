SMODS.Consumable {
    key = 'carteblanche',
    set = 'porkify',
    pos = { x = 2, y = 0 },
    loc_txt = {
        name = 'Carte Blanche',
        text = {
            [1] = 'Gives the amount',
            [2] = 'of total {C:attention}deck size{} in {C:money}${},',
            [3] = 'makes {C:attention}2{} owned Jokers',
            [4] = '{C:gold}Rental{}'
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

        -- money = current deck size
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                local deck_size = #(G.playing_cards or {})
                card_eval_status_text(used_card, 'extra', nil, nil, nil,
                    {message = "+"..tostring(deck_size).." $", colour = G.C.RED})
                ease_dollars(deck_size, true)
                return true
            end
        }))
        delay(0.6)

        -- no jokers? nothing to rental-ify
        if not (G.jokers and G.jokers.cards and #G.jokers.cards > 0) then return end

        -- pick up to 2 distinct indexes
        local count = math.min(2, #G.jokers.cards)
        local idx1 = math.random(1, #G.jokers.cards)
        local idx2 = idx1
        if #G.jokers.cards > 1 then
            while idx2 == idx1 do
                idx2 = math.random(1, #G.jokers.cards)
            end
        end

        local targets = {}
        targets[1] = G.jokers.cards[idx1]
        if count == 2 then targets[2] = G.jokers.cards[idx2] end

        -- apply rental to each target with a little animation
        for t = 1, #targets do
            local j = targets[t]

            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.25,
                func = function()
                    play_sound('timpani')
                    used_card:juice_up(0.3, 0.5)
                    return true
                end
            }))

            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    j:flip()
                    play_sound('card1', 1.0) -- constant, no i math
                    j:juice_up(0.3, 0.3)
                    return true
                end
            }))

            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.10,
                func = function()
                    j:add_sticker('rental', true)
                    return true
                end
            }))

            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    j:flip()
                    play_sound('tarot2', 1.0, 0.6) -- constant
                    j:juice_up(0.3, 0.3)
                    return true
                end
            }))

            delay(0.35)
        end

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                G.jokers:unhighlight_all()
                return true
            end
        }))
    end,

    can_use = function(self, card)
        return true
    end
}
