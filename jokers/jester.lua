local function multiplier(card, preview)
    local count = 0
    local playing_hand = G.play and G.play.cards and next(G.play.cards)
    for _, held_card in ipairs(G.hand and G.hand.cards or {}) do
        if not preview or playing_hand or not held_card.highlighted then
            count = count + 1
        end
    end
    return ((card.ability.extra or {}).per_size or 0.25)
        * count + 1
end

SMODS.Joker {
    key = 'jester',
    config = { extra = { per_size = 0.25 } },
    loc_txt = { name = 'Jester', text = {
        '{X:chips,C:white}X#1#{} Chips per',
        'card {C:attention}held in hand{}'
    } },
    atlas = 'CustomJokers', pos = { x = 7, y = 9 }, -- Placeholder artwork.
    cost = 6, rarity = 2,
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    unlocked = true, discovered = false,
    pools = { ['modprefix_porkify_jokers'] = true },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.per_size, multiplier(card) } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then return { x_chips = multiplier(card) } end
    end,
    joker_display_def = function(JokerDisplay)
        return {
            text = {{ border_nodes = {
                { text = 'X' },
                { ref_table = 'card.joker_display_values', ref_value = 'x_chips' }
            }, border_colour = G.C.CHIPS }},
            calc_function = function(card) card.joker_display_values.x_chips = multiplier(card, true) end
        }
    end
}
