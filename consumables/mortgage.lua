SMODS.Consumable {
    key = 'mortgage',
    set = 'porkify',
    pos = { x = 0, y = 2 },
    loc_txt = {
        name = 'Mortgage',
        text = {
            [1] = 'Remove {C:gold}Rental{} from',
            [2] = '{C:attention}1{} selected {C:attention}Joker{}'
        }
    },
    cost = 3,
    unlocked = true,
    discovered = false,
    hidden = false,
    can_repeat_soul = false,
    atlas = 'CustomConsumables',

    loc_vars = function(self, info_queue, card)
        local info_queue_0 = (G.P_STICKERS and G.P_STICKERS["rental"]) or (G.P_CENTERS and G.P_CENTERS["rental"])
        if info_queue_0 then
            info_queue[#info_queue + 1] = info_queue_0
        end
        return {vars = {}}
    end,

    use = function(self, card, area, copier)
        local used_card = copier or card
        if not (G.jokers and G.jokers.highlighted and #G.jokers.highlighted == 1) then return end

        local j = G.jokers.highlighted[1]
        if not (j and j.ability and j.ability.rental) then return end

        -- SFX / juice on use
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('timpani')
                used_card:juice_up(0.3, 0.5)
                return true
            end
        }))

        -- Flip
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.55,
            func = function()
                j:flip()
                play_sound('card1', 1.0)
                j:juice_up(0.3, 0.3)
                return true
            end
        }))

        -- Remove rental
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.70,
            func = function()
                j.ability.rental = false

                -- OPTIONAL: if rental is sticker-based in your build, remove it too
                if j.remove_sticker then
                    pcall(function() j:remove_sticker('rental') end)
                end

                card_eval_status_text(j, 'extra', nil, nil, nil,
                    { message = "Paid Off!", colour = G.C.GREEN })
                return true
            end
        }))

        -- Flip back + cleanup
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.90,
            func = function()
                j:flip()
                play_sound('tarot2', 1.0, 0.6)
                j:juice_up(0.3, 0.3)
                G.jokers:unhighlight_all()
                return true
            end
        }))
    end,

    can_use = function(self, card)
        return (G.jokers and G.jokers.highlighted and #G.jokers.highlighted == 1
            and G.jokers.highlighted[1]
            and G.jokers.highlighted[1].ability
            and G.jokers.highlighted[1].ability.rental) == true
    end
}
