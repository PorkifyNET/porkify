SMODS.Joker{ --Hatsune Joku
    key = "hatsunejoku",
    config = {
        extra = {
            odds = 2,
            dollars = 2
        }
    },
    loc_txt = {
        ['name'] = 'Hatsune Joku',
        ['text'] = {
            [1] = 'Every played {C:clubs}Club{} card',
            [2] = 'has a {C:green}#1# in #2#{} chance',
            [3] = 'to give {C:money}$2{} when scored'
        }
    },
    pos = {
        x = 3,
        y = 6
    },
    display_size = {
        w = 71,
        h = 95
    },
    cost = 5,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },

    loc_vars = function(self, info_queue, card)
        local extra = (card and card.ability and card.ability.extra) or self.config.extra
        local num, den = SMODS.get_probability_vars(card, 1, (extra and extra.odds) or 2, 'j_porkify_hatsunejoku')
        return { vars = { num, den } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            local extra = (card.ability and card.ability.extra) or self.config.extra
            local odds = (extra and extra.odds) or 2
            local dollars = (extra and extra.dollars) or 2

            if played_card
                and played_card.is_suit
                and played_card:is_suit("Clubs")
                and SMODS.pseudorandom_probability(
                    card,
                    'group_hatsunejoku_clubs',
                    1,
                    odds,
                    'j_porkify_hatsunejoku',
                    false
                ) then
                return {
                    dollars = dollars
                }
            end
        end
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { ref_table = "card.joker_display_values", ref_value = "money_text", colour = G.C.MONEY, retrigger_type = "mult" }
            },
            reminder_text = {
                { ref_table = "card.joker_display_values", ref_value = "chance_text", colour = G.C.GREEN }
            },

            calc_function = function(card)
                local clubs = 0
                local extra = (card.ability and card.ability.extra) or {}
                local odds = extra.odds or 2
                local dollars = extra.dollars or 2
                local n, d = 1, odds
                local text, _, scoring_hand = JokerDisplay.evaluate_hand()

                if SMODS.get_probability_vars then
                    local nn, dd = SMODS.get_probability_vars(card, 1, odds, 'j_porkify_hatsunejoku')
                    n, d = nn or n, dd or d
                end

                if text ~= "Unknown" and scoring_hand then
                    for _, c in pairs(scoring_hand) do
                        if c:is_suit("Clubs") and not c.debuff and c.facing ~= 'back' then
                            clubs = clubs + JokerDisplay.calculate_card_triggers(c, scoring_hand)
                        end
                    end
                end

                card.joker_display_values.money_text = "+$" .. tostring(clubs * dollars)
                card.joker_display_values.chance_text = "(" .. tostring(n) .. " in " .. tostring(d) .. ")"
            end
        }
    end
}
