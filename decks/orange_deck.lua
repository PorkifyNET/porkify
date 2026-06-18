SMODS.Back {
    key = 'orange_deck',
    pos = { x = 0, y = 1 },
    config = {},
    loc_txt = {
        name = 'Orange Deck',
        text = {
            [1] = '{C:attention}+1{} Hand Size'
        },
    },
    unlocked = true,
    discovered = true,
    no_collection = false,
    atlas = 'CustomDecks',

    apply = function(self, back)
        G.E_MANAGER:add_event(Event({
            func = function()
                if G and G.GAME and G.GAME.starting_params then
                    G.GAME.starting_params.hand_size = (G.GAME.starting_params.hand_size or 8) + 1
                end

                if Porkify_safe_change_hand_size then
                    Porkify_safe_change_hand_size(1)
                elseif G and G.hand then
                    G.hand:change_size(1)
                end

                return true
            end
        }))
    end
}
