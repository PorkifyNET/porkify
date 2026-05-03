
SMODS.Consumable {
    key = 'doubleornothing',
    set = 'porkify',
    pos = { x = 7, y = 0 },
    loc_txt = {
        name = 'Double or Nothing',
        text = {
            [1] = 'Create 2 random',
            [2] = '{C:red}Red{} Seal {C:enhanced}Glass{} cards'
        }
    },
    cost = 3,
    unlocked = true,
    discovered = false,
    hidden = false,
    can_repeat_soul = false,
    atlas = 'CustomConsumables',

    loc_vars = function(self, info_queue, card)
        local info_queue_0 = G.P_CENTERS["m_glass"]
        if info_queue_0 then
            info_queue[#info_queue + 1] = info_queue_0
        end

        local info_queue_1 = G.P_SEALS and G.P_SEALS["Red"]
        if info_queue_1 then
            info_queue[#info_queue + 1] = info_queue_1
        end

        return {vars = {}}
    end,

    use = function(self, card, area, copier)
        local used_card = copier or card
        if G.hand and #G.hand.cards > 0 then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.7,
                func = function()
                    local cards = {}
                    for i = 1, 2 do
                        local _rank = pseudorandom_element(SMODS.Ranks, 'add_random_rank').card_key
                        local _suit = nil
                        local enhancement = G.P_CENTERS['m_glass']
                        local new_card_params = { set = "Base" }
                    if _rank then new_card_params.rank = _rank end
                    if _suit then new_card_params.suit = _suit end
                    if enhancement then new_card_params.enhancement = enhancement.key end
                        cards[i] = SMODS.add_card(new_card_params)
                        if cards[i] then
                            cards[i]:set_seal('Red', nil, true)
                        end
                    end
                    SMODS.calculate_context({ playing_card_added = true, cards = cards })
                    return true
                end
            }))
            delay(0.3)
        end
    end,
    can_use = function(self, card)
        return (G.hand and #G.hand.cards > 0)
    end
}
