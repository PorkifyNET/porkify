SMODS.Joker {
    key = 'blackcard',
    config = { extra = { reduction = 0, gain = 0.01, max_reduction = 0.99 } },
    loc_txt = { name = 'Black Card', text = {
        'Reduces the size of',
        'all {C:attention}Blinds{} by {B:blind,C:white}#1#%{}',
        'per {C:attention}Booster Pack{} skipped',
        '{C:inactive}(Currently {B:blind,C:white}#2#%{C:inactive})'
    } },
    atlas = 'CustomJokers', pos = { x = 8, y = 10 }, -- Placeholder artwork.
    cost = 6, rarity = 2,
    porkify_color_card = true,
    blueprint_compat = false, eternal_compat = true, perishable_compat = false,
    unlocked = true, discovered = false,
    pools = { ['modprefix_porkify_jokers'] = true },
    loc_vars = function(self, info_queue, card)
        local extra = card.ability.extra
        return { vars = {
            math.floor((extra.gain or 0.01) * 100 + 0.5),
            math.floor((extra.reduction or 0) * 100 + 0.5)
        } }
    end,
    calculate = function(self, card, context)
        local extra = card.ability.extra

        if context.skipping_booster and not context.blueprint and not context.retrigger_joker then
            extra.reduction = math.min(
                extra.max_reduction or 0.99,
                (extra.reduction or 0) + (extra.gain or 0.01)
            )
            return { message = localize('k_upgrade_ex'), colour = G.C.IMPORTANT }
        end

        if context.setting_blind and not context.blueprint and (extra.reduction or 0) > 0 then
            return { x_blind_size = math.max(0.01, 1 - extra.reduction) }
        end
    end,
    joker_display_def = function(JokerDisplay)
        return {
            text = {
                {
                    ref_table = 'card.joker_display_values',
                    ref_value = 'reduction_text',
                    colour = G.C.DYN_UI.DARK
                }
            },
            calc_function = function(card)
                local extra = (card.ability and card.ability.extra) or {}
                local reduction = math.floor((extra.reduction or 0) * 100 + 0.5)
                card.joker_display_values = card.joker_display_values or {}
                card.joker_display_values.reduction_text = '-' .. tostring(reduction) .. '%'
            end
        }
    end
}
