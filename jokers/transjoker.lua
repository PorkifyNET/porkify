SMODS.Joker{ -- Trans Joker
    key = "transjoker",
    config = {
        extra = {
            Xmult = 1
        }
    },
    loc_txt = {
        ['name'] = 'Trans Joker',
        ['text'] = {
            [1] = 'This Joker gains {X:mult,C:white}X1{} Mult',
            [2] = 'whenever {C:tarot}Estrogen{} or',
            [3] = '{C:tarot}Testosterone{} is used',
            [4] = '{C:inactive}(Currently{} {X:mult,C:white}X#1#{} {C:inactive}Mult){}'
        }
    },
    pos = {
        x = 1,
        y = 6
    },
    display_size = {
        w = 71,
        h = 95
    },
    cost = 5,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["porkify_porkify_jokers"] = true },

    loc_vars = function(self, info_queue, card)
        local xm = (card and card.ability and card.ability.extra and card.ability.extra.Xmult) or 1

        local info_queue_0 = G.P_CENTERS["c_porkify_estrogen"]
        if info_queue_0 then
            info_queue[#info_queue + 1] = info_queue_0
        else
            error("JOKERFORGE: Invalid key in infoQueues. \"c_porkify_estrogen\" isn't a valid Object key, Did you misspell it or forgot a modprefix?")
        end

        local info_queue_1 = G.P_CENTERS["c_porkify_testosterone"]
        if info_queue_1 then
            info_queue[#info_queue + 1] = info_queue_1
        else
            error("JOKERFORGE: Invalid key in infoQueues. \"c_porkify_testosterone\" isn't a valid Object key, Did you misspell it or forgot a modprefix?")
        end

        return { vars = { xm } }
    end,

    calculate = function(self, card, context)
        if context.using_consumeable and not context.blueprint then
            local consumeable = context.consumeable
            local center = consumeable and consumeable.config and consumeable.config.center
            local consumeable_key = (center and (center.key or center.original_key))
                or (consumeable and consumeable.ability and consumeable.ability.name)

            local is_hormone =
                consumeable_key == 'c_porkify_estrogen' or
                consumeable_key == 'c_porkify_testosterone' or
                consumeable_key == 'estrogen' or
                consumeable_key == 'testosterone'

            if is_hormone then
                return {
                    func = function()
                        card.ability.extra.Xmult = (card.ability.extra.Xmult or 1) + 1
                        return true
                    end,
                    message = "Upgrade!",
                    colour = G.C.MULT
                }
            end
        end

        if context.cardarea == G.jokers and context.joker_main then
            return {
                Xmult = card.ability.extra.Xmult or 1
            }
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
                local xm = (card.ability.extra and card.ability.extra.Xmult) or 1
                card.joker_display_values.x_mult = xm
            end
        }
    end
}
