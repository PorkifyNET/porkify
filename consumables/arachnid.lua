SMODS.Consumable {
    key = 'arachnid',
    set = 'porkify',
    pos = { x = 0, y = 0 },
    config = {
        extra = {
            dollars = 8
        }
    },
    loc_txt = {
        name = 'Arachnid',
        text = {
            [1] = 'Convert cards in',
            [2] = 'hand to a single',
            [3] = 'random {C:attention}rank{},',
            [4] = '{C:red}-$#1#{} for each card',
            [5] = 'converted',
            [6] = "{s:0.7}Stops if you don't have{} {C:money,s:0.7}$#1#{}"
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
                (self.config.extra and self.config.extra.dollars) or 8
            }
        }
    end,

    use = function(self, card, area, copier)
        if not (G.hand and G.GAME and #G.hand.cards > 0) then return end

        local used_card = copier or card
        local dollar_cost = (self.config.extra and self.config.extra.dollars) or 8
        local target_rank = pseudorandom_element(SMODS.Ranks, pseudoseed('porkify_arachnid_rank')).card_key
        local affordable = math.floor(math.max(0, tonumber(G.GAME.dollars) or 0) / dollar_cost)
        local eligible_cards = {}

        for _, playing_card in ipairs(G.hand.cards) do
            if playing_card.base and playing_card.base.value ~= target_rank then
                eligible_cards[#eligible_cards + 1] = playing_card
            end
        end

        pseudoshuffle(eligible_cards, pseudoseed('porkify_arachnid_order'))

        local converted_cards = {}
        for i = 1, math.min(affordable, #eligible_cards) do
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
                    ease_dollars(-dollar_cost, true)
                    return true
                end
            }))
        end

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
        local dollar_cost = (self.config.extra and self.config.extra.dollars) or 8
        return G.hand
            and G.GAME
            and #G.hand.cards > 0
            and (tonumber(G.GAME.dollars) or 0) >= dollar_cost
    end
}
