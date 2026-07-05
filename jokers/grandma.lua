SMODS.Joker{ --Grandma
    key = "grandma",
    config = {
        extra = {
            dollars = 1
        }
    },
    loc_txt = {
        ['name'] = 'Grandma',
        ['text'] = {
            [1] = 'Scored {C:attention}8{}, {C:attention}9{}, {C:attention}10{},',
            [2] = 'and {C:attention}Ace{} cards',
            [3] = 'give {C:money}$1{} when scored'
        },
        ['unlock'] = {
            [1] = 'Play a hand where exactly {C:attention}2{} {C:attention}10s{} are scored'
        }
    },
    pos = {
        x = 5,
        y = 5
    },
    display_size = {
        w = 71 * 1,
        h = 95 * 1
    },
    cost = 4,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },
    check_for_unlock = function(self, args)
        if args.type ~= 'hand_contents' or not args.cards then
            return false
        end
        local tens = 0
        for _, c in ipairs(args.cards) do
            if porkify_card_matches_rank(c, 10) then
                tens = tens + 1
            end
        end
        return tens == 2
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local played_card = context.other_card
            if porkify_card_matches_rank(played_card, { 8, 9, 10, 14 }) then
                return {
                    dollars = (card.ability.extra and card.ability.extra.dollars) or 1
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
                { text = "(8, 9, 10, A)", colour = G.C.GREY }
            },

            calc_function = function(card)
                local hits = 0
                local per = (card.ability.extra and card.ability.extra.dollars) or 1
                local text, _, scoring_hand = JokerDisplay.evaluate_hand()

                if text ~= "Unknown" and scoring_hand then
                    for _, c in pairs(scoring_hand) do
                        if not c.debuff and c.facing ~= "back"
                            and porkify_card_matches_rank(c, { 8, 9, 10, 14 }) then
                            hits = hits + JokerDisplay.calculate_card_triggers(c, scoring_hand)
                        end
                    end
                end

                card.joker_display_values.money_text = "+$" .. tostring(hits * per)
            end
        }
    end
}
