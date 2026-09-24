local function is_secret_hand(name)
    return PORKIFY_SECRET_HANDS and PORKIFY_SECRET_HANDS[name] == true
end

SMODS.Joker {
    key = 'thebeyond',
    config = { extra = { x_mult = 4 } },
    loc_txt = { name = 'The Beyond', text = {
        '{X:mult,C:white}X#1#{} Mult if played hand',
        'is a {C:planet,E:1}secret hand{}',
        '{s:0.8}Excludes vanilla secret hands'
    } },
    atlas = 'CustomJokers', pos = { x = 2, y = 10 }, -- Placeholder artwork.
    cost = 8, rarity = 3,
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    unlocked = true, discovered = false,
    pools = { ['modprefix_porkify_jokers'] = true },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.x_mult } }
    end,
    in_pool = function(self)
        for name in pairs(PORKIFY_SECRET_HANDS or {}) do
            local hand = G and G.GAME and G.GAME.hands and G.GAME.hands[name]
            if hand and (hand.played or 0) > 0 then return true end
        end
        return false
    end,
    calculate = function(self, card, context)
        if context.joker_main and is_secret_hand(context.scoring_name) then
            return { x_mult = card.ability.extra.x_mult }
        end
    end,
    joker_display_def = function(JokerDisplay)
        return {
            text = {{ border_nodes = {
                { text = 'X' },
                { ref_table = 'card.joker_display_values', ref_value = 'x_mult', retrigger_type = 'exp' }
            } }},
            calc_function = function(card)
                local name = JokerDisplay.evaluate_hand()
                card.joker_display_values.x_mult = is_secret_hand(name) and card.ability.extra.x_mult or 1
            end
        }
    end
}
