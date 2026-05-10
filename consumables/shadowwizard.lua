SMODS.Consumable{
    key = 'shadowwizard',
    set = 'porkify',
    pos = { x = 5, y = 2 },
    loc_txt = {
        name = 'Shadow Wizard',
        text = {
            [1] = '{C:attention}+1{} Consumable Slot'
        }
    },
    cost = 3,
    unlocked = true,
    discovered = false,
    hidden = false,
    can_repeat_soul = false,
    atlas = 'CustomConsumables',

    credit_badges = {
        { text = "Art: Vroska", colour = "00E59B" }
     },

    use = function(self, card, area, copier)
        local used_card = copier or card

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                -- Balatro uses "consumeables"
                if G and G.consumeables and G.consumeables.change_size then
                    G.consumeables:change_size(1)

                    card_eval_status_text(
                        used_card, 'extra', nil, nil, nil,
                        { message = "Spell Cast!", colour = G.C.IMPORTANT }
                    )
                else
                    card_eval_status_text(
                        used_card, 'extra', nil, nil, nil,
                        { message = "No consumeables area!", colour = G.C.RED }
                    )
                end
                return true
            end
        }))
    end,

    can_use = function(self, card)
        return true
    end
}
