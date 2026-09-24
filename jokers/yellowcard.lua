SMODS.Joker {
    key = 'yellowcard',
    config = { extra = { payout = 0, gain = 1 } },
    loc_txt = { name = 'Yellow Card', text = {
        'Earn {C:money}$#1#{} at end of round',
        'Payout increases by {C:money}$#2#{} when',
        'any {C:attention}Booster Pack{} is skipped'
    } },
    atlas = 'CustomJokers', pos = { x = 0, y = 10 }, -- Placeholder artwork.
    cost = 5, rarity = 1,
    blueprint_compat = false, eternal_compat = true, perishable_compat = false,
    unlocked = true, discovered = false,
    pools = { ['modprefix_porkify_jokers'] = true },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.payout, card.ability.extra.gain } }
    end,
    calculate = function(self, card, context)
        if context.skipping_booster and not context.blueprint and not context.retrigger_joker then
            card.ability.extra.payout = card.ability.extra.payout + card.ability.extra.gain
            return { message = localize('k_upgrade_ex'), colour = G.C.MONEY }
        end
    end,
    calc_dollar_bonus = function(self, card)
        if card.ability.extra.payout > 0 then return card.ability.extra.payout end
    end,
    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { text = '+$', colour = G.C.MONEY },
                { ref_table = 'card.ability.extra', ref_value = 'payout', colour = G.C.MONEY }
            },
            reminder_text = {
                { text = '(Round)'}
            }
        }
    end
}
