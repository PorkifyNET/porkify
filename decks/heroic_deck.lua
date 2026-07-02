SMODS.Back {
    key = 'heroic_deck',
    pos = { x = 7, y = 0 },
    config = {
        extra = {
            win_ante = 12
        }
    },
    loc_txt = {
        name = 'Heroic Deck',
        text = {
            [1] = 'Start with a random',
            [2] = '{C:legendary}Legendary{} Joker',
            [3] = '{C:green}Win{} at Ante {C:attention}12{}'
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
        G.E_MANAGER:add_event(Event({
            func = function()
                play_sound('timpani')

                local possible = {}
                for _, center in pairs(G.P_CENTER_POOLS.Joker or {}) do
                    local r = center and center.rarity
                    local is_legendary = (type(r) == "number" and r >= 4)
                    local is_ruleset = (r == "porkify_ruleset")

                    if center
                        and center.set == 'Joker'
                        and center.key
                        and center.unlocked
                        and not center.no_collection
                        and is_legendary
                        and not is_ruleset
                    then
                        possible[#possible + 1] = center.key
                    end
                end

                if #possible > 0 then
                    local joker_key = pseudorandom_element(possible, pseudoseed('porkify_heroic_deck_joker'))
                    SMODS.add_card({ set = 'Joker', key = joker_key })
                end

                return true
            end
        }))

        G.E_MANAGER:add_event(Event({
            func = function()
                if not (G and G.GAME) then
                    return true
                end

                local target_ante = (self.config.extra and self.config.extra.win_ante) or 12

                G.GAME.win_ante = target_ante

                G.GAME.round_resets = G.GAME.round_resets or {}
                G.GAME.round_resets.win_ante = target_ante

                G.GAME.modifiers = G.GAME.modifiers or {}
                G.GAME.modifiers.win_ante = target_ante

                return true
            end
        }))
    end
}
