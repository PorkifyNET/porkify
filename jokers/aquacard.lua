SMODS.Joker {
    key = 'aquacard',
    config = { extra = { hands = 0, gain = 1 } },
    loc_txt = { name = 'Aqua Card', text = {
        'Gain {C:blue}+#1#{} Hand for the',
        'next Blind when any',
        '{C:attention}Booster Pack{} is skipped',
        '{C:inactive}(Currently {C:blue}+#2#{C:inactive} Hands)'
    } },
    atlas = 'CustomJokers', pos = { x = 7, y = 10 }, -- Placeholder artwork.
    cost = 5, rarity = 1,
    porkify_color_card = true,
    blueprint_compat = false, eternal_compat = true, perishable_compat = true,
    unlocked = true, discovered = false,
    pools = { ['modprefix_porkify_jokers'] = true },
    loc_vars = function(self, info_queue, card)
        local extra = card.ability.extra
        return { vars = { extra.gain or 1, extra.hands or 0 } }
    end,
    calculate = function(self, card, context)
        local extra = card.ability.extra

        if context.skipping_booster and not context.blueprint and not context.retrigger_joker then
            extra.hands = (extra.hands or 0) + (extra.gain or 1)
            return { message = localize('k_upgrade_ex'), colour = G.C.BLUE }
        end

        if context.setting_blind and not context.blueprint and (extra.hands or 0) > 0 then
            local hands = extra.hands
            extra.hands = 0
            return {
                func = function()
                    ease_hands_played(hands)
                    return true
                end
            }
        end
    end
}
