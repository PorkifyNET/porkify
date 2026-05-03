SMODS.Back {
    key = 'bankrupt_deck',
    pos = { x = 9, y = 0 },
    config = {},
    loc_txt = {
        name = 'Bankrupt Deck',
        text = {
            [1] = 'Lose {C:money}$1{} per',
            [2] = '{C:attention}Ante{} at end of',
            [3] = 'each round'
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
                    G.GAME.modifiers.bankrupt_deck = true
                    G.GAME.porkify_bankrupt_last_round = nil
                end
                return true
            end
        }))
    end,

    calculate = function(self, back, context)
        if not (context and context.end_of_round and not context.game_over and G and G.GAME) then
            return
        end

        local round_id = tostring((G.GAME.round_resets and G.GAME.round_resets.ante) or 0)
            .. ":"
            .. tostring(G.GAME.round or 0)

        if G.GAME.porkify_bankrupt_last_round == round_id then
            return
        end

        G.GAME.porkify_bankrupt_last_round = round_id

        return {
            func = function()
                local current_dollars = G.GAME and G.GAME.dollars or 0
                local ante = (G.GAME.round_resets and G.GAME.round_resets.ante) or 0
                local tax_amount = math.min(current_dollars, ante)
                local delta = -tax_amount

                if delta ~= 0 then
                    ease_dollars(delta)
                end

                return true
            end,
            message = "Tax Time!",
            colour = G.C.MONEY
        }
    end
}
