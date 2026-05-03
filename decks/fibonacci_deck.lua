SMODS.Back {
    key = 'fibonacci_deck',
    pos = { x = 2, y = 0 },
    config = {
    },
    loc_txt = {
        name = 'Fibonacci Deck',
        text = {
            [1] = '{C:attention}4s{} become {C:attention}3s{},',
            [2] = '{C:attention}6s{} and {C:attention}7s{} become {C:attention}5s{},',
            [3] = '{C:attention}9s{} and {C:attention}10s{} become {C:attention}8s{},',
            [4] = '{C:attention}Jacks{}, {C:attention}Queens{} and {C:attention}Kings{} become {C:attention}Aces{}'
        },
    },
    unlocked = true,
    discovered = true,
    no_collection = false,
    atlas = 'CustomDecks',
    apply = function(self, back)
        G.E_MANAGER:add_event(Event({
            func = function()
                local rank_map = {
                    [4] = '3',
                    [6] = '5',
                    [7] = '5',
                    [9] = '8',
                    [10] = '8',
                    [11] = 'Ace',
                    [12] = 'Ace',
                    [13] = 'Ace',
                }

                for _, playing_card in ipairs(G.playing_cards or {}) do
                    local target_rank = rank_map[playing_card:get_id()]
                    if target_rank then
                        assert(SMODS.change_base(playing_card, nil, target_rank))
                    end
                end

                G.GAME.starting_deck_size = #G.playing_cards
                return true
            end
        }))
    end
}
