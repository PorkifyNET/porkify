SMODS.Consumable {
    key = 'freezer',
    set = 'porkify',
    pos = { x = 5, y = 1 },
    loc_txt = {
        name = 'Freezer',
        text = {
            [1] = 'Remove {C:spades}Perishable{} from',
            [2] = '{C:attention}1{} selected {C:attention}Joker{}',
            [3] = '{C:inactive}(Does not rebuff Joker){}'
        }
    },
    cost = 3,
    unlocked = true,
    discovered = false,
    hidden = false,
    can_repeat_soul = false,
    atlas = 'CustomConsumables',

    loc_vars = function(self, info_queue, card)
        local info_queue_0 = (G.P_STICKERS and G.P_STICKERS["perishable"]) or (G.P_CENTERS and G.P_CENTERS["perishable"])
        if info_queue_0 then
            info_queue[#info_queue + 1] = info_queue_0
        end
        return {vars = {}}
    end,

    use = function(self, card, area, copier)
        local used_card = copier or card
        if not (G.jokers and G.jokers.highlighted and #G.jokers.highlighted == 1) then return end

        local j = G.jokers.highlighted[1]
        if not (j and j.ability and j.ability.perishable) then return end

        -- Use consumable SFX
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('timpani')
                used_card:juice_up(0.3, 0.5)
                return true
            end
        }))

        -- Flip joker
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

        -- Remove perishable
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.70,
            func = function()
                j.ability.perishable = false

                -- OPTIONAL: if your build uses stickers for this, remove it too
                -- (safe-guarded so it won't crash if the function doesn't exist)
                if j.remove_sticker then
                    pcall(function() j:remove_sticker('perishable') end)
                end

                card_eval_status_text(j, 'extra', nil, nil, nil,
                    { message = "Kept cool!", colour = G.C.GREEN })
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
            and G.jokers.highlighted[1].ability.perishable) == true
    end
}
