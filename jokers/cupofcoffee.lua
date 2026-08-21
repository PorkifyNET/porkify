local function porkify_coffee_format_xmult(value)
    local amount = tonumber(value) or 1
    return amount
end

SMODS.Joker{ --Cup of Coffee
    key = "cupofcoffee",
    config = {
        extra = {
            Xmult = 3,
            Xmult_loss = 0.2,
            Xmult_min = 1,
            pending_break = false
        }
    },
    loc_txt = {
        ['name'] = 'Cup of Coffee',
        ['text'] = {
            [1] = '{X:mult,C:white}X#4#{} Mult,',
            [2] = 'loses {X:mult,C:white}X#2#{} Mult',
            [3] = 'per played {C:attention}hand{}',
            [4] = '{s:0.7}Resets after defeating{} {C:attention,s:0.7}Boss Blind{}'
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
    rarity = 2,
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
                porkify_coffee_format_xmult(extra.Xmult_start or 3),
                porkify_coffee_format_xmult(extra.Xmult_loss or 0.2),
                porkify_coffee_format_xmult(extra.Xmult_min or 1),
                porkify_coffee_format_xmult(extra.Xmult or 3)
            }
        }
    end,

    set_ability = function(self, card, initial)
        local extra = card.ability.extra or {}
        extra.Xmult_start = extra.Xmult_start or 3
        extra.Xmult = extra.Xmult or extra.Xmult_start
        extra.Xmult_loss = extra.Xmult_loss or 0.2
        extra.Xmult_min = extra.Xmult_min or 1
        extra.pending_break = false
        card.ability.extra = extra
    end,

    calculate = function(self, card, context)
        local extra = card.ability.extra or {}

        if context.cardarea == G.jokers and context.joker_main then
            return {
                Xmult = extra.Xmult or extra.Xmult_start or 3
            }
        end

        if context.after and context.cardarea == G.jokers and not context.blueprint then
            local current = extra.Xmult or extra.Xmult_start or 3
            local next_value = current - (extra.Xmult_loss or 0.2)
            extra.Xmult = math.max(next_value, extra.Xmult_min or 1)
            extra.pending_break = (extra.Xmult <= (extra.Xmult_min or 1))
            card.ability.extra = extra

            return {
                message = extra.pending_break and "Empty!" or "Sipped...",
                colour = extra.pending_break and G.C.RED or G.C.FILTER
            }
        end

        if context.end_of_round and context.main_eval and not context.blueprint then
            local blind = G and G.GAME and G.GAME.blind
            local is_boss_blind = not not (
                blind and (
                    blind.boss
                    or (blind.config and blind.config.blind and blind.config.blind.boss)
                )
            )

            if is_boss_blind then
                extra.Xmult = extra.Xmult_start or 3
                extra.pending_break = false
                card.ability.extra = extra

                return {
                    message = "Refilled!",
                    colour = G.C.MULT
                }
            end

            if extra.pending_break then
                return {
                    func = function()
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
                }
            end
        end
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                {
                    border_nodes = {
                        { text = "X" },
                        { ref_table = "card.joker_display_values", ref_value = "x_mult" }
                    }
                }
            },
            calc_function = function(card)
                local extra = (card.ability and card.ability.extra) or {}
                card.joker_display_values.x_mult = porkify_coffee_format_xmult(
                    extra.Xmult or extra.Xmult_start or 3
                )
            end
        }
    end
}
