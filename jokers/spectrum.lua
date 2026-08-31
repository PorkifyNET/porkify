local function porkify_is_pride_seal_card(playing_card)
    if not playing_card then
        return false
    end

    local seal = playing_card.seal or (playing_card.ability and playing_card.ability.seal)
    return seal == "porkify_pride"
end

local function porkify_count_pride_seals()
    local count = 0

    for _, playing_card in pairs(G.playing_cards or {}) do
        if porkify_is_pride_seal_card(playing_card) then
            count = count + 1
        end
    end

    return count
end

SMODS.Joker{ --Spectrum
    key = "spectrum",
    config = {
        extra = {
            mult_per_pride = 4
        }
    },
    loc_txt = {
        ['name'] = 'Spectrum',
        ['text'] = {
            [1] = 'Gives {C:red}+#1#{} Mult for',
            [2] = 'each {C:gold}Pride Seal{} card',
            [3] = 'in your {C:attention}full deck{}',
            [4] = '{C:inactive}(Currently {C:red}+#2#{} {C:inactive}Mult){}'
        },
    },
    pos = {
        x = 4,
        y = 6
    },
    display_size = {
        w = 71,
        h = 95
    },
    cost = 6,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["porkify_porkify_jokers"] = true },

    loc_vars = function(self, info_queue, card)
        local pride_seal = G.P_SEALS and (G.P_SEALS["porkify_pride"] or G.P_SEALS["pride"])
        if pride_seal then
            info_queue[#info_queue + 1] = pride_seal
        end

        local mult_per_pride = (card.ability.extra and card.ability.extra.mult_per_pride) or 4
        return { vars = { mult_per_pride, porkify_count_pride_seals() * mult_per_pride } }
    end,

    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.joker_main then
            local mult_per_pride = (card.ability.extra and card.ability.extra.mult_per_pride) or 4
            local mult = porkify_count_pride_seals() * mult_per_pride

            if mult > 0 then
                return {
                    mult = mult
                }
            end
        end
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { ref_table = "card.joker_display_values", ref_value = "mult_text", colour = G.C.MULT }
            },

            calc_function = function(card)
                local mult_per_pride = ((card.ability or {}).extra or {}).mult_per_pride or 4
                local pride_count = porkify_count_pride_seals()

                card.joker_display_values.mult_text = "+" .. tostring(pride_count * mult_per_pride)
            end
        }
    end
}
