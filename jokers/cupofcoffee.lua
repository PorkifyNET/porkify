SMODS.Joker{ -- Cup of Coffee
    key = "cupofcoffee",
    config = {
        extra = {
            mult = 15,
            mult_transfer = 1
        }
    },
    loc_txt = {
        ['name'] = 'Cup of Coffee',
        ['text'] = {
            [1] = 'Played cards steal {C:red}+#1#{} Mult',
            [2] = 'from this Joker when scored',
            [3] = '{C:inactive}(Currently {C:red}+#2#{} {C:inactive}Mult){}'
        },
        ['unlock'] = {
            [1] = 'Play {C:attention}50{} {C:blue}hands{}'
        }
    },
    pos = {
        x = 5,
        y = 0
    },
    display_size = {
        w = 71,
        h = 95
    },
    cost = 6,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = false,
    perishable_compat = false,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["porkify_porkify_jokers"] = true },
    unlock_condition = { type = 'c_hands_played', extra = 50 },

    loc_vars = function(self, info_queue, card)
        local extra = (card and card.ability and card.ability.extra) or self.config.extra
        return {
            vars = {
                extra.mult_transfer or 1,
                extra.mult or 15
            }
        }
    end,

    set_ability = function(self, card, initial)
        local extra = card.ability.extra or {}
        extra.mult = extra.mult or 15
        extra.mult_transfer = extra.mult_transfer or 1
        card.ability.extra = extra
    end,

    calculate = function(self, card, context)
        local extra = card.ability.extra or {}

        if context.individual and context.cardarea == G.play and not context.blueprint then
            local played_card = context.other_card
            local available_mult = extra.mult or 15
            local transfer = math.min(extra.mult_transfer or 1, available_mult)

            if played_card and played_card.ability and not played_card.debuff and transfer > 0 then
                played_card.ability.perma_mult = (played_card.ability.perma_mult or 0) + transfer
                extra.mult = available_mult - transfer
                card.ability.extra = extra

                local effect = {
                    message = "+" .. tostring(transfer) .. " Mult",
                    colour = G.C.MULT
                }

                if extra.mult <= 0 then
                    effect.func = function()
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            delay = 0.2,
                            blocking = false,
                            func = function()
                                if card and card.start_dissolve and not card.getting_sliced then
                                    card.getting_sliced = true
                                    card:start_dissolve({ G.C.RED }, nil, 1.6)
                                end
                                return true
                            end
                        }))

                        card_eval_status_text(
                            context.blueprint_card or card, 'extra', nil, nil, nil,
                            { message = "Out of Coffee!", colour = G.C.RED }
                        )
                        return true
                    end
                end

                return effect
            end
        end

        if context.cardarea == G.jokers and context.joker_main then
            return {
                mult = extra.mult or 15
            }
        end
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { ref_table = "card.joker_display_values", ref_value = "mult_text", colour = G.C.MULT }
            },
            calc_function = function(card)
                local extra = (card.ability and card.ability.extra) or {}
                card.joker_display_values.mult_text = "+" .. tostring(extra.mult or 15)
            end
        }
    end
}
