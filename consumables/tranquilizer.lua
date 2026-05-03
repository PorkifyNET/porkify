
SMODS.Consumable {
    key = 'tranquilizer',
    set = 'porkify',
    pos = { x = 5, y = 3 },
    loc_txt = {
        name = 'Tranquilizer',
        text = {
            [1] = 'Disable current',
            [2] = '{C:attention}Boss Blind{}'
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
        if (G.GAME.blind.boss and G.GAME.blind.in_blind) then
            if G.GAME.blind and G.GAME.blind.boss and not G.GAME.blind.disabled then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        G.GAME.blind:disable()
                        play_sound('timpani')
                        return true
                    end
                }))
                card_eval_status_text(used_card, 'extra', nil, nil, nil, {message = localize('ph_boss_disabled'), colour = G.C.GREEN})
            end
        end
    end,
    can_use = function(self, card)
        return ((G.GAME.blind.boss and G.GAME.blind.in_blind))
    end
}