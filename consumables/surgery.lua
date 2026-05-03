SMODS.Consumable {
    key = 'surgery',
    set = 'porkify',
    pos = { x = 7, y = 4 },
    loc_txt = {
        name = 'Surgery',
        text = {
            [1] = 'Select {C:attention}3{} cards',
            [2] = 'Put the {C:attention}rank{} of the',
            [3] = 'middle card and the {C:attention}suit{}',
            [4] = 'of the right card onto the left,',
            [5] = 'then {C:red}destroy{} the other 2'
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
        if not (G.hand and #G.hand.cards > 0 and G.playing_cards and to_big(#G.hand.highlighted) == to_big(3)) then return end

        local selected = {}
        for i = 1, #G.hand.highlighted do
            selected[i] = G.hand.highlighted[i]
        end

        table.sort(selected, function(a, b)
            local ax = (a.T and a.T.x) or 0
            local bx = (b.T and b.T.x) or 0
            if ax == bx then
                return tostring(a.sort_id or '') < tostring(b.sort_id or '')
            end
            return ax < bx
        end)

        local left = selected[1]
        local middle = selected[2]
        local right = selected[3]
        if not (left and middle and right and middle.base and right.base) then return end

        local function remove_from_playing_cards(pc)
            if not (G and G.playing_cards and pc) then return end
            for i = #G.playing_cards, 1, -1 do
                if G.playing_cards[i] == pc then
                    table.remove(G.playing_cards, i)
                    return
                end
            end
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

        for i = 1, #selected do
            local percent = 1.15 - (i - 0.999) / (#selected - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    selected[i]:flip()
                    play_sound('card1', percent)
                    selected[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.35,
            func = function()
                assert(SMODS.change_base(left, right.base.suit, nil))
                assert(SMODS.change_base(left, nil, middle.base.value))
                card_eval_status_text(left, 'extra', nil, nil, nil,
                    { message = "Operated!", colour = G.C.RED })
                return true
            end
        }))

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.55,
            func = function()
                left:flip()
                play_sound('tarot2', 1.0, 0.6)
                left:juice_up(0.3, 0.3)
                return true
            end
        }))

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.7,
            func = function()
                if middle.remove_from_deck then middle:remove_from_deck() end
                if right.remove_from_deck then right:remove_from_deck() end
                remove_from_playing_cards(middle)
                remove_from_playing_cards(right)
                SMODS.destroy_cards({ middle, right })
                G.hand:unhighlight_all()
                return true
            end
        }))
    end,

    can_use = function(self, card)
        return (G.hand and #G.hand.cards > 0 and G.playing_cards and to_big(#G.hand.highlighted) == to_big(3)) == true
    end
}
