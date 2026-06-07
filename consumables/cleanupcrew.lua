SMODS.Consumable {
    key = 'cleanupcrew',
    set = 'porkify',
    pos = { x = 2, y = 5 },
    config = {
        extra = {
            discards = 4
        }
    },
    loc_txt = {
        name = 'Cleanup Crew',
        text = {
            [1] = '{C:red}+#1#{} Discards',
            [2] = 'during this round'
        }
    },
    cost = 3,
    unlocked = true,
    discovered = false,
    hidden = false,
    can_repeat_soul = false,
    atlas = 'CustomConsumables',

    loc_vars = function(self, info_queue, card)
        local extra = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { extra.discards or 4 } }
    end,

    use = function(self, card, area, copier)
        local used_card = copier or card
        local extra = (used_card and used_card.ability and used_card.ability.extra) or self.config.extra
        local amount = extra.discards or 4
        if not (G and G.GAME and G.GAME.blind and G.GAME.blind.in_blind and G.GAME.current_round) then return end

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                card_eval_status_text(used_card, 'extra', nil, nil, nil, { message = "+" .. tostring(amount) .. " Discards", colour = G.C.GREEN })
                ease_discard(amount)
                return true
            end
        }))

        delay(0.6)
    end,

    can_use = function(self, card)
        return G and G.GAME and G.GAME.blind and G.GAME.blind.in_blind and G.GAME.current_round
    end
}
