local function arachnid_set_dollars(target)
    local target_value = type(to_big) == 'function' and to_big(target) or target
    ease_dollars(target_value - G.GAME.dollars, true)
end

SMODS.Consumable {
    key = 'arachnid',
    set = 'porkify',
    pos = { x = 0, y = 0 },
    config = {
        extra = {
            dollars = 8,
            max_cards = 8
        }
    },
    loc_txt = {
        name = 'Arachnid',
        text = {
            [1] = 'Convert up to {C:attention}#2#{} random',
            [2] = 'cards in hand to {C:attention}8s{},',
            [3] = 'set money to {C:money}$#1#{}'
        }
    },
    cost = 3,
    unlocked = true,
    discovered = false,
    hidden = false,
    can_repeat_soul = false,
    atlas = 'CustomConsumables',

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                (self.config.extra and self.config.extra.dollars) or 8,
                (self.config.extra and self.config.extra.max_cards) or 8
            }
        }
    end,

    use = function(self, card, area, copier)
        if not (G.hand and G.GAME and #G.hand.cards > 0) then return end

        local used_card = copier or card
        local target_dollars = (self.config.extra and self.config.extra.dollars) or 8
        local max_cards = (self.config.extra and self.config.extra.max_cards) or 8
        local target_rank = '8'
        local eligible_cards = {}

        for _, playing_card in ipairs(G.hand.cards) do
            if playing_card.base and playing_card.base.value ~= target_rank then
                eligible_cards[#eligible_cards + 1] = playing_card
            end
        end

        pseudoshuffle(eligible_cards, pseudoseed('porkify_arachnid_order'))

        local converted_cards = {}
        for i = 1, math.min(max_cards, #eligible_cards) do
            converted_cards[#converted_cards + 1] = eligible_cards[i]
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

        for i, target in ipairs(converted_cards) do
            local pitch = 1.15 - (i - 0.999) / (#converted_cards - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    target:flip()
                    play_sound('card1', pitch)
                    target:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end

        delay(0.2)

        for _, target in ipairs(converted_cards) do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    assert(SMODS.change_base(target, nil, target_rank))
                    return true
                end
            }))
        end

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                arachnid_set_dollars(target_dollars)
                return true
            end
        }))

        for i, target in ipairs(converted_cards) do
            local pitch = 0.85 + (i - 0.999) / (#converted_cards - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    target:flip()
                    play_sound('tarot2', pitch, 0.6)
                    target:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end

        delay(0.5)
    end,

    can_use = function(self, card)
        return G.hand
            and G.GAME
            and #G.hand.cards > 0
    end
}
