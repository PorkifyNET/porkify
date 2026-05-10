SMODS.Back {
    key = 'microdeck',
    pos = { x = 5, y = 0 },
    config = {
        extra = {
            cards_removed = 26
        }
    },
    loc_txt = {
        name = 'Microdeck',
        text = {
            [1] = 'Remove {C:red}26{} random',
            [2] = 'playing cards'
        },
    },
    unlocked = true,
    discovered = true,
    no_collection = false,
    atlas = 'CustomDecks',

    credit_badges = {
        { text = "Art: Cavo", colour = "59A487" }
     },
    
    apply = function(self, back)
        local destroyed_cards = {}
        local temp_hand = {}
        G.E_MANAGER:add_event(Event({
            func = function()
            for _, playing_card in ipairs(G.deck.cards) do temp_hand[#temp_hand + 1] = playing_card end
                table.sort(temp_hand,
                    function(a, b)
                        return not a.playing_card or not b.playing_card or a.playing_card < b.playing_card
                    end
                )
                pseudoshuffle(temp_hand, 12345)    
                return true
            end,
        })) 
        
        G.E_MANAGER:add_event(Event({
            func = function()
                for i = 1, 26 do destroyed_cards[#destroyed_cards + 1] = temp_hand[i]:remove()
                end
                G.GAME.starting_deck_size = #G.playing_cards
                return true
            end
        }))
    end
}
