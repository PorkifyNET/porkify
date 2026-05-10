SMODS.Back {
    key = 'jimbo_deck',
    pos = { x = 6, y = 0 },
    config = {},
    loc_txt = {
        name = 'Jimbo Deck',
        text = {
            [1] = '{C:attention}+2{} Joker Slots,',
            [2] = 'No {C:purple}Consumable{} Slots'
        },
    },
    unlocked = true,
    discovered = true,
    no_collection = false,
    atlas = 'CustomDecks',

    credit_badges = {
        { text = "Art: ButterStutter", colour = "59A487" }
     },

    apply = function(self, back)
        G.E_MANAGER:add_event(Event({
            func = function()
                if G and G.jokers then
                    if G.jokers.change_size then
                        G.jokers:change_size(2)
                    elseif G.jokers.config then
                        G.jokers.config.card_limit = (G.jokers.config.card_limit or 0) + 2
                    end
                end

                if G and G.consumeables and G.consumeables.config then
                    local current_limit = G.consumeables.config.card_limit or 0
                    if current_limit > 0 then
                        if G.consumeables.change_size then
                            G.consumeables:change_size(-current_limit)
                        else
                            G.consumeables.config.card_limit = 0
                        end
                    end
                end

                return true
            end
        }))
    end
}
