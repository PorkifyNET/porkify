SMODS.Back {
    key = 'metal_deck',
    pos = { x = 4, y = 0 },
    config = {
        extra = {
            steel_cards_count = 6
        },
    },
    loc_txt = {
        name = 'Metal Deck',
        text = {
            [1] = 'Start with a random {C:attention}Joker{}',
            [2] = '{C:attention}6{} random playing cards',
            [3] = 'become {C:enhanced,T:m_steel}Steel{} cards'
        },
    },
    unlocked = true,
    discovered = true,
    no_collection = false,
    atlas = 'CustomDecks',
    apply = function(self, back)
        G.E_MANAGER:add_event(Event({
            func = function()
                play_sound('timpani')

                local possible = {}
                for _, center in pairs(G.P_CENTER_POOLS.Joker or {}) do
                    local r = center and center.rarity
                    local is_ruleset = (r == "porkify_ruleset")
                    local is_legendary = (type(r) == "number" and r >= 4)

                    if center
                        and center.set == 'Joker'
                        and center.key
                        and center.unlocked
                        and not center.no_collection
                        and not is_ruleset
                        and not is_legendary
                    then
                        possible[#possible + 1] = center.key
                    end
                end

                if #possible > 0 then
                    local joker_key = pseudorandom_element(possible, pseudoseed('porkify_metal_deck_joker'))
                    SMODS.add_card({ set = 'Joker', key = joker_key })
                end

                return true
            end
        }))

        G.E_MANAGER:add_event(Event({
            func = function()
                local deck_cards = {}
                for _, playing_card in ipairs(G.playing_cards or {}) do
                    deck_cards[#deck_cards + 1] = playing_card
                end

                pseudoshuffle(deck_cards, pseudoseed('porkify_metal_deck_steel'))

                local steel_center = G.P_CENTERS['m_steel']
                if not steel_center then
                    return true
                end

                local count = math.min((self.config.extra and self.config.extra.steel_cards_count) or 6, #deck_cards)
                for i = 1, count do
                    local target = deck_cards[i]
                    if target then
                        target:set_ability(steel_center, true)
                    end
                end

                G.GAME.starting_deck_size = #G.playing_cards
                return true
            end
        }))
    end
}
