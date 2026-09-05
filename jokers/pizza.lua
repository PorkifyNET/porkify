SMODS.Joker{ --Pizza
    key = "pizza",
    config = {
        extra = {
            odds = 4,
            applied_shop_slots = 0
        }
    },
    loc_txt = {
        ['name'] = 'Pizza',
        ['text'] = {
            [1] = '{C:green}#1# in #2#{} chance for each {C:green}Shop{}',
            [2] = 'to have {C:attention}1{} additional card slot,',
            [3] = '{C:red}-1{} card slot if it fails'
        },
        ['unlock'] = {
            [1] = 'Sell {C:attention}10{} cards'
        }
    },
    pos = {
        x = 1,
        y = 5
    },
    display_size = {
        w = 71 * 1,
        h = 95 * 1
    },
    cost = 6,
    rarity = 2,
    blueprint_compat = false,
    eternal_compat = false,
    perishable_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },
    unlock_condition = { type = 'c_cards_sold', extra = 10 },

    loc_vars = function(self, info_queue, card)
        local extra = (card and card.ability and card.ability.extra) or self.config.extra
        local numerator, denominator = SMODS.get_probability_vars(card, 3, extra.odds or 4, 'j_porkify_pizza')
        return { vars = { numerator, denominator } }
    end,

    set_ability = function(self, card, initial)
        card.ability.extra.applied_shop_slots = 0
    end,

    calculate = function(self, card, context)
        if context.starting_shop and not context.blueprint then
            local previous = card.ability.extra.applied_shop_slots or 0
            if previous ~= 0 then
                change_shop_size(-previous)
                card.ability.extra.applied_shop_slots = 0
            end

            local delta = SMODS.pseudorandom_probability(
                card,
                'group_pizza_shop_slots',
                3,
                card.ability.extra.odds or 4,
                'j_porkify_pizza',
                false
            ) and 1 or -1

            change_shop_size(delta)
            card.ability.extra.applied_shop_slots = delta

            return {
                message = delta > 0 and "+1 Slot" or "-1 Slot",
                colour = delta > 0 and G.C.GREEN or G.C.RED
            }
        end
    end,

    add_to_deck = function(self, card, from_debuff)
    end,

    remove_from_deck = function(self, card, from_debuff)
        local applied = (card and card.ability and card.ability.extra and card.ability.extra.applied_shop_slots) or 0
        if applied ~= 0 then
            change_shop_size(-applied)
            card.ability.extra.applied_shop_slots = 0
        end
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { ref_table = "card.joker_display_values", ref_value = "slot_text", colour = G.C.IMPORTANT }
            },
            extra = {
                {
                    { ref_table = "card.joker_display_values", scale = 0.3, ref_value = "odds_text", colour = G.C.CHANCE }
                }
            },

            calc_function = function(card)
                local applied = (card.ability.extra and card.ability.extra.applied_shop_slots) or 0
                if applied > 0 then
                    card.joker_display_values.slot_text = "+1 Slot"
                elseif applied < 0 then
                    card.joker_display_values.slot_text = "-1 Slot"
                else
                    card.joker_display_values.slot_text = "0 Slot"
                end

                local odds = (card.ability.extra and card.ability.extra.odds) or 4
                local n, d = 3, odds
                if SMODS and SMODS.get_probability_vars then
                    local nn, dd = SMODS.get_probability_vars(card, 3, odds, 'j_porkify_pizza')
                    n, d = nn or n, dd or d
                end
                card.joker_display_values.odds_text = "(" .. tostring(n) .. " in " .. tostring(d) .. ")"
            end
        }
    end
}
