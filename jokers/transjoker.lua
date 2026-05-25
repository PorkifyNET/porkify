local function get_hormone_uses()
    if not (G and G.GAME) then
        return 0
    end

    return G.GAME.porkify_transjoker_hormone_uses or 0
end

local function sync_transjoker_xmult(card)
    if not (card and card.ability and card.ability.extra) then
        return 1
    end

    local xmult = 1 + get_hormone_uses()
    card.ability.extra.Xmult = xmult
    return xmult
end

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
        h = 64
    },
    cost = 5,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false,
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

    add_to_deck = function(self, card, from_debuff)
        if from_debuff then
            return
        end

        sync_transjoker_xmult(card)
    end,

    calculate = function(self, card, context)
        sync_transjoker_xmult(card)

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
                        sync_transjoker_xmult(card)
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
                local xm = sync_transjoker_xmult(card)
                card.joker_display_values.x_mult = xm
            end
        }
    end
}
