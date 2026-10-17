local function porkify_unbreakable_cube_present(card)
    for _, joker in ipairs(G and G.jokers and G.jokers.cards or {}) do
        if joker == card then return true end
    end
    return false
end


function Porkify_unbreakable_check_cube_destroyed(card)
    local active = G and G.GAME and G.GAME.modifiers
        and G.GAME.modifiers.porkify_unbreakable_destroy_cube
    if not active or G.GAME.won or G.GAME.porkify_unbreakable_win_pending then
        return
    end

    G.GAME.porkify_unbreakable_win_pending = true
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 3,
        blockable = false,
        func = function()
            G.GAME.porkify_unbreakable_win_pending = nil
            local destruction_finished = card and (
                card.getting_sliced or card.shattered or card.destroyed
            )
            if porkify_unbreakable_cube_present(card) or not destruction_finished then
                return true
            end

            G.GAME.won = true
            if type(win_game) == 'function' then win_game() end
            return true
        end
    }))
end


SMODS.Challenge {
    key = 'unbreakable',
    loc_txt = { name = 'Unbreakable' },

    rules = {
        modifiers = {},
        custom = {
            { id = 'porkify_unbreakable_no_winning_ante', value = true },
            { id = 'porkify_unbreakable_destroy_cube', value = true },
        },
    },

    jokers = {
        { id = 'j_porkify_tungstencube' },
    },
    vouchers = {},
    deck = {
        type = 'Challenge Deck',
    },

    restrictions = {
        banned_cards = {},
        banned_tags = {},
        banned_other = {},
    },
    button_colour = HEX('FF0095'),
}
