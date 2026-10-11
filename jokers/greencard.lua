SMODS.Joker {
    key = 'greencard',
    config = { extra = { refund_rate = 0.5, pack_cost = 0 } },
    loc_txt = { name = 'Green Card', text = {
        'Refunds {C:money}#1#%{} of the',
        'purchase price when a',
        '{C:attention}Booster Pack{} is skipped'
    } },
    atlas = 'CustomJokers', pos = { x = 6, y = 10 }, -- Placeholder artwork.
    cost = 5, rarity = 1,
    porkify_color_card = true,
    blueprint_compat = false, eternal_compat = true, perishable_compat = true,
    unlocked = true, discovered = false,
    pools = { ['modprefix_porkify_jokers'] = true },
    loc_vars = function(self, info_queue, card)
        return { vars = { math.floor((card.ability.extra.refund_rate or 0.5) * 100) } }
    end,
    calculate = function(self, card, context)
        local extra = card.ability.extra

        if context.open_booster and not context.blueprint and not context.retrigger_joker then
            local paid = context.card and tonumber(context.card.cost) or 0
            extra.pack_cost = math.max(0, math.floor(paid))
        end

        if context.skipping_booster and not context.blueprint and not context.retrigger_joker then
            local refund = math.floor((extra.pack_cost or 0) * (extra.refund_rate or 0.5))
            extra.pack_cost = 0
            if refund > 0 then
                return { dollars = refund, colour = G.C.MONEY }
            end
        end

        if context.ending_booster and not context.blueprint then
            extra.pack_cost = 0
        end
    end
}
