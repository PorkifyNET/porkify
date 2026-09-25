
SMODS.Consumable {
    key = 'steroids',
    set = 'porkify',
    pos = { x = 9, y = 2 },
    config = {
        extra = {
            points = 6,
            max_selected = 6
        }
    },
    loc_txt = {
        name = 'Steroids',
        text = {
            [1] = 'Distribute {C:attention}#1#{} rank increases',
            [2] = 'as evenly as possible among',
            [3] = 'up to {C:attention}#2#{} selected cards',
            [4] = '{C:inactive}(Leftmost cards receive extras){}'
        }
    },
    cost = 3,
    unlocked = true,
    discovered = false,
    hidden = false,
    can_repeat_soul = false,
    atlas = 'CustomConsumables',

    credit_badges = {
        { text = "Art: DeltonKeslar1206", colour = "00E59B" }
     },

    loc_vars = function(self, info_queue, card)
        local extra = (card and card.ability and card.ability.extra) or self.config.extra
        return {
            vars = {
                extra.points or 6,
                extra.max_selected or 6
            }
        }
    end,
    
    use = function(self, card, area, copier)
        local used_card = copier or card
        local extra = (used_card and used_card.ability and used_card.ability.extra) or self.config.extra
        local points = extra.points or 6
        local max_selected = extra.max_selected or 6

        if (G.hand and #G.hand.cards > 0 and to_big(#G.hand.highlighted) >= to_big(1) and to_big(#G.hand.highlighted) <= to_big(max_selected)) then
            local selected_cards = {}
            for _, selected_card in ipairs(G.hand.highlighted) do
                selected_cards[#selected_cards + 1] = selected_card
            end

            table.sort(selected_cards, function(a, b)
                local a_x = a.T and a.T.x or 0
                local b_x = b.T and b.T.x or 0
                return a_x < b_x
            end)

            local base_increase = math.floor(points / #selected_cards)
            local remainder = points % #selected_cards

            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.4,
                func = function()
                    play_sound('tarot1')
                    used_card:juice_up(0.3, 0.5)
                    return true
                end
            }))
            for i, selected_card in ipairs(selected_cards) do
                local target = selected_card
                local percent = 1.15 - (i - 0.999) / (#selected_cards - 0.998) * 0.3
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.15,
                    func = function()
                        target:flip()
                        play_sound('card1', percent)
                        target:juice_up(0.3, 0.3)
                        return true
                    end
                }))
            end
            delay(0.2)
            for i, selected_card in ipairs(selected_cards) do
                local target = selected_card
                local rank_increase = base_increase + (i <= remainder and 1 or 0)
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.1,
                    func = function()
                        assert(SMODS.modify_rank(target, rank_increase))
                        return true
                    end
                }))
            end
            for i, selected_card in ipairs(selected_cards) do
                local target = selected_card
                local percent = 0.85 + (i - 0.999) / (#selected_cards - 0.998) * 0.3
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.15,
                    func = function()
                        target:flip()
                        play_sound('tarot2', percent, 0.6)
                        target:juice_up(0.3, 0.3)
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
        local extra = (card and card.ability and card.ability.extra) or self.config.extra
        local max_selected = extra.max_selected or 6
        return (G.hand and #G.hand.cards > 0 and to_big(#G.hand.highlighted) >= to_big(1) and to_big(#G.hand.highlighted) <= to_big(max_selected)) == true
    end
}
