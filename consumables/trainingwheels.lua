SMODS.Consumable {
    key = 'trainingwheels',
    set = 'porkify',
    pos = { x = 4, y = 3 },
    loc_txt = {
        name = 'Training Wheels',
        text = {
            [1] = '{C:attention}Halves{} score requirement',
            [2] = 'for current {C:attention}Blind{}'
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

                card_eval_status_text(
                    used_card,
                    'extra',
                    nil, nil, nil,
                    { message = "Halved Blind Size", colour = G.C.GREEN }
                )

                G.GAME.blind.chips = math.floor(G.GAME.blind.chips / 2)
                G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)

                if G.HUD_blind then G.HUD_blind:recalculate() end
                return true
            end
        }))
    end,

    can_use = function(self, card)
        return (G.GAME and G.GAME.blind and G.GAME.blind.in_blind)
    end
}
