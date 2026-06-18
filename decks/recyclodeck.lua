SMODS.Back {
    key = 'recyclodeck',
    pos = { x = 1, y = 1 },
    config = {},
    loc_txt = {
        name = 'Recyclodeck',
        text = {
            [1] = 'At end of each round, earn',
            [2] = '{C:money}$3{} per remaining {C:red}Discard{}',
            [3] = 'Extra {C:blue}Hands{} no longer earn money'
        },
    },
    unlocked = true,
    discovered = true,
    no_collection = false,
    atlas = 'CustomDecks',

    apply = function(self, back)
        G.E_MANAGER:add_event(Event({
            func = function()
                if G and G.GAME then
                    G.GAME.modifiers = G.GAME.modifiers or {}
                    G.GAME.modifiers.money_per_hand = 0
                    G.GAME.modifiers.money_per_discard = 3
                end
                return true
            end
        }))
    end
}
