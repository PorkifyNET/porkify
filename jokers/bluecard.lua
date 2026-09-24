SMODS.Joker {
    key = 'bluecard',
    config = { extra = { chips = 0, gain = 15 } },
    loc_txt = { name = 'Blue Card', text = {
        'This Joker gains',
        '{C:chips}+#1#{} Chips when any',
        '{C:attention}Booster Pack{} is skipped',
        '{C:inactive}(Currently {C:chips}+#2#{}{C:inactive} Chips)'
    } },
    atlas = 'CustomJokers', pos = { x = 1, y = 10 }, -- Placeholder artwork.
    cost = 5, rarity = 1,
    blueprint_compat = true, eternal_compat = true, perishable_compat = false,
    unlocked = true, discovered = false,
    pools = { ['modprefix_porkify_jokers'] = true },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.gain, card.ability.extra.chips } }
    end,
    calculate = function(self, card, context)
        if context.skipping_booster and not context.blueprint and not context.retrigger_joker then
            card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.gain
            return { message = localize('k_upgrade_ex'), colour = G.C.CHIPS }
        end
        if context.joker_main then return { chips = card.ability.extra.chips } end
    end,
    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { text = '+' },
                { ref_table = 'card.ability.extra', ref_value = 'chips', retrigger_type = 'mult' }
            },
            text_config = { colour = G.C.CHIPS }
        }
    end
}
