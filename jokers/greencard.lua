local function porkify_green_card_sync_debt(card, desired)
    desired = math.max(0, desired or 0)
    local applied = card.porkify_green_card_applied_debt or 0
    local change = desired - applied

    if change ~= 0 and G and G.GAME then
        G.GAME.bankrupt_at = (G.GAME.bankrupt_at or 0) - change
        card.porkify_green_card_applied_debt = desired
    end
end


SMODS.Joker {
    key = 'greencard',
    config = { extra = { debt = 0, debt_gain = 2 } },
    loc_txt = { name = 'Green Card', text = {
        'Go up to {C:red}-$#2#{} in debt',
        'Increases by {C:red}-$#1#{} when any',
        '{C:attention}Booster Pack{} is skipped'
    } },
    atlas = 'CustomJokers', pos = { x = 6, y = 10 }, -- Placeholder artwork.
    cost = 5, rarity = 1,
    porkify_color_card = true,
    blueprint_compat = false, eternal_compat = true, perishable_compat = true,
    unlocked = true, discovered = false,
    pools = { ['modprefix_porkify_jokers'] = true },

    loc_vars = function(self, info_queue, card)
        local extra = card and card.ability and card.ability.extra or self.config.extra
        return { vars = { extra.debt_gain or 2, extra.debt or 0 } }
    end,

    add_to_deck = function(self, card, from_debuff)
        porkify_green_card_sync_debt(card, card.ability.extra.debt or 0)
    end,

    remove_from_deck = function(self, card, from_debuff)
        porkify_green_card_sync_debt(card, 0)
        card.porkify_green_card_applied_debt = nil
    end,

    calculate = function(self, card, context)
        if context.skipping_booster and not context.blueprint and not context.retrigger_joker then
            local extra = card.ability.extra
            extra.debt = (extra.debt or 0) + (extra.debt_gain or 2)
            porkify_green_card_sync_debt(card, extra.debt)

            return { message = localize('k_upgrade_ex'), colour = G.C.MONEY }
        end
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { ref_table = 'card.joker_display_values', ref_value = 'debt_text', colour = G.C.RED }
            },
            calc_function = function(card)
                local extra = card.ability.extra or {}
                card.joker_display_values.debt_text = '-$' .. tostring(extra.debt or 0)
            end
        }
    end
}
