SMODS.Consumable {
    key = 'trainingwheels',
    set = 'porkify',
    pos = { x = 4, y = 3 },
    loc_txt = {
        name = 'Training Wheels',
        text = {
            [1] = '{B:blind,C:white}X0.5{} Blind Size'
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
        if not (G.GAME and G.GAME.blind and G.GAME.blind.in_blind) then return end

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                if not (G.GAME and G.GAME.blind and G.GAME.blind.in_blind) then return true end

                Porkify_scale_current_blind(0.5)

                play_sound("xblindsize")

                card_eval_status_text(card, "extra", nil, nil, nil, {
                    message = "X0.5 Blind Size",
                    colour = G.C.BLACK
                })

                return true
            end
        }))
    end,

    can_use = function(self, card)
        return (G.GAME and G.GAME.blind and G.GAME.blind.in_blind)
    end
}
