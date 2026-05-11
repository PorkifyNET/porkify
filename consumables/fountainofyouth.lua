SMODS.Consumable {
    key = 'fountainofyouth',
    set = 'porkify',
    pos = { x = 4, y = 1 },
    loc_txt = {
        name = 'Fountain of Youth',
        text = {
            [1] = 'Add {C:purple}Eternal{} to {C:attention}1{}',
            [2] = 'selected {C:attention}Joker{},',
            [3] = 'removes {C:dark_edition}Edition{}',
            [4] = '{C:inactive,s:0.75}(Cannot be put on{} {C:dark_edition,s:0.75}Negative{} {C:inactive,s:0.75}Jokers){}'
        }
    },
    cost = 3,
    unlocked = true,
    discovered = false,
    hidden = false,
    can_repeat_soul = false,
    atlas = 'CustomConsumables',

    loc_vars = function(self, info_queue, card)
        local info_queue_0 = (G.P_STICKERS and G.P_STICKERS["eternal"]) or (G.P_CENTERS and G.P_CENTERS["eternal"])
        if info_queue_0 then
            info_queue[#info_queue + 1] = info_queue_0
        end
        local info_queue_1 = (G.P_STICKERS and G.P_STICKERS["perishable"]) or (G.P_CENTERS and G.P_CENTERS["perishable"])
        if info_queue_1 then
            info_queue[#info_queue + 1] = info_queue_1
        end
        return {vars = {}}
    end,

    use = function(self, card, area, copier)
        local used_card = copier or card
        if not (G.jokers and G.jokers.highlighted and to_big(#G.jokers.highlighted) == to_big(1)) then return end

        local j = G.jokers.highlighted[1]
        if not (j and j.ability) then return end

        -- block if already eternal
        if j.ability.eternal then return end

        -- block if Negative (edition)
        -- (Negative is an EDITION; safest check is edition key)
        if j.edition and j.edition.key == 'e_negative' then return end

        -- little “use” feedback
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('timpani')
                used_card:juice_up(0.3, 0.5)
                return true
            end
        }))

        -- flip -> remove edition + add eternal -> flip back
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.15,
            func = function()
                j:flip()
                play_sound('card1', 1.0)
                j:juice_up(0.3, 0.3)
                return true
            end
        }))

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.35,
            func = function()
                j:set_edition(nil, true)
                if j.ability.perishable then
                    j.ability.perishable = false
                    if j.remove_sticker then
                        pcall(function() j:remove_sticker('perishable') end)
                    end
                end
                j:add_sticker('eternal', true)
                return true
            end
        }))

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.55,
            func = function()
                j:flip()
                play_sound('tarot2', 1.0, 0.6)
                j:juice_up(0.3, 0.3)
                return true
            end
        }))

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.7,
            func = function()
                G.jokers:unhighlight_all()
                return true
            end
        }))
    end,

    can_use = function(self, card)
        if not (G.jokers and G.jokers.highlighted and to_big(#G.jokers.highlighted) == to_big(1)) then
            return false
        end
        local j = G.jokers.highlighted[1]
        if not (j and j.ability) then return false end
        if j.ability.eternal then return false end
        if j.edition and j.edition.key == 'e_negative' then return false end
        return true
    end
}
