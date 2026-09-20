SMODS.Joker{ --Recycler
    key = "recycler",
    config = {
        extra = {
            chips = 0
        }
    },
    loc_txt = {
        ['name'] = 'Recycler',
        ['text'] = {
            [1] = 'Gains {C:chips}Chips{} equal to',
            [2] = '{X:attention,C:white}4X{} the sell value',
            [3] = 'of every {C:attention}Joker{} and',
            [4] = '{C:attention}Consumable{} sold',
            [5] = '{C:inactive}(Currently {C:chips}+#1#{}{C:inactive} Chips){}'
        },
        ['unlock'] = { [1] = 'Sell {C:attention}20{} cards' }
    },
    pos = { x = 3, y = 2 },
    display_size = { w = 71, h = 95 },
    cost = 6,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },
    unlock_condition = { type = 'c_cards_sold', extra = 20 },

    loc_vars = function(self, info_queue, card)
        local extra = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { extra.chips or 0 } }
    end,

    calculate = function(self, card, context)
        local extra = card.ability.extra

        if context.selling_card and not context.blueprint and not context.retrigger_joker then
            local sold_card = context.card or context.other_card or context.sold_card
            local ability = sold_card and sold_card.ability or {}
            local center = sold_card and sold_card.config and sold_card.config.center or {}
            local sold_set = center.set or ability.set

            if sold_card and sold_card ~= card
                and (sold_set == 'Joker' or ability.consumeable or center.consumeable) then
                local gain = 4 * (tonumber(sold_card.sell_cost) or 0)
                if gain > 0 then
                    extra.chips = (extra.chips or 0) + gain
                    return {
                        message = 'Recycled!',
                        colour = G.C.CHIPS
                    }
                end
            end
        end

        if context.joker_main then
            local chips = extra.chips or 0
            if chips > 0 then
                return { chips = chips }
            end
        end
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { ref_table = "card.joker_display_values", ref_value = "chips_text", colour = G.C.CHIPS }
            },
            calc_function = function(card)
                local extra = (card.ability and card.ability.extra) or {}
                card.joker_display_values.chips_text = "+" .. tostring(extra.chips or 0)
            end
        }
    end
}
