SMODS.Back {
    key = 'speedrunner_deck',
    pos = { x = 8, y = 0 },
    config = {},
    loc_txt = {
        name = 'Speedrunner Deck',
        text = {
            [1] = '{C:red}-2{} Joker Slots,',
            [2] = '{C:red}-1{} Consumable Slot,',
            [3] = '{X:attention,C:white}X0.5{} Blind Size'
        },
    },
    unlocked = true,
    discovered = true,
    no_collection = false,
    atlas = 'CustomDecks',

    apply = function(self, back)
        G.E_MANAGER:add_event(Event({
            func = function()
                if G and G.jokers and G.jokers.change_size then
                    G.jokers:change_size(-2)
                elseif G and G.jokers and G.jokers.config then
                    G.jokers.config.card_limit = math.max(0, (G.jokers.config.card_limit or 0) - 2)
                end

                if G and G.consumeables and G.consumeables.change_size then
                    G.consumeables:change_size(-1)
                elseif G and G.consumeables and G.consumeables.config then
                    G.consumeables.config.card_limit = math.max(0, (G.consumeables.config.card_limit or 0) - 1)
                end

                return true
            end
        }))
    end
}
