SMODS.Joker {
    key = 'leitner',
    config = {
        extra = {
            chips = 0,
            chip_gain = 20
        }
    },
    loc_txt = {
        name = 'Leitner',
        text = {
            'This Joker gains {C:chips}+#1#{} Chips',
            'per {C:attention}reroll{} in the shop',
            '{C:inactive}(Currently {C:chips}+#2#{} {C:inactive}Chips){}'
        }
    },
    atlas = 'CustomJokers',
    pos = { x = 0, y = 11 },
    display_size = { w = 71, h = 95 },
    cost = 5,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false,
    unlocked = true,
    discovered = false,
    pools = { ['modprefix_porkify_jokers'] = true },

    credit_badges = {
        { text = "Art: kommit", colour = "59A487" }
     },

    loc_vars = function(self, info_queue, card)
        local extra = card and card.ability and card.ability.extra or self.config.extra
        return { vars = { extra.chip_gain or 20, extra.chips or 0 } }
    end,

    calculate = function(self, card, context)
        local extra = card.ability.extra

        if context.reroll_shop and not context.blueprint and not context.retrigger_joker then
            extra.chips = (extra.chips or 0) + (extra.chip_gain or 20)
            return { message = localize('k_upgrade_ex'), colour = G.C.CHIPS }
        end

        if context.joker_main then
            return { chips = extra.chips or 0 }
        end
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { ref_table = 'card.joker_display_values', ref_value = 'chips_text', colour = G.C.CHIPS }
            },
            calc_function = function(card)
                local extra = card.ability.extra or {}
                card.joker_display_values.chips_text = '+' .. tostring(extra.chips or 0)
            end
        }
    end
}
