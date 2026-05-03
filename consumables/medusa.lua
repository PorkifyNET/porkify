
SMODS.Consumable {
    key = 'medusa',
    set = 'porkify',
    pos = { x = 7, y = 1 },
    loc_txt = {
        name = 'Medusa',
        text = {
            [1] = 'Create 4 {C:enhanced}Stone{} cards'
        }
    },
    cost = 3,
    unlocked = true,
    discovered = false,
    hidden = false,
    can_repeat_soul = false,
    atlas = 'CustomConsumables',

    loc_vars = function(self, info_queue, card)
        
        local info_queue_0 = G.P_CENTERS["m_stone"]
        if info_queue_0 then
            info_queue[#info_queue + 1] = info_queue_0
        else
            error("JOKERFORGE: Invalid key in infoQueues. \"m_stone\" isn't a valid Object key, Did you misspell it or forgot a modprefix?")
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
                    for i = 1, 4 do
                        local faces = {}
                        for _, rank_key in ipairs(SMODS.Rank.obj_buffer) do
                            local rank = SMODS.Ranks[rank_key]
                        if rank.face then table.insert(faces, rank) end
                        end
                        local _rank = pseudorandom_element(faces, 'add_face_cards').card_key
                        local _suit = nil
                        local enhancement = G.P_CENTERS['m_stone']
                        local new_card_params = { set = "Base" }
                    if _rank then new_card_params.rank = _rank end
                    if _suit then new_card_params.suit = _suit end
                    if enhancement then new_card_params.enhancement = enhancement.key end
                        cards[i] = SMODS.add_card(new_card_params)
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