SMODS.Joker{ -- Majora
    key = "majora",
    config = {
        extra = {
            Xmult = 1,
            Xmult_gain = 0.25
        }
    },
    loc_txt = {
        ['name'] = 'Majora',
        ['text'] = {
            [1] = '{C:red}Decrease{} level of played',
            [2] = '{C:planet}Poker Hand{}, then add',
            [3] = '{X:mult,C:white}X#2#{} Mult to this {C:attention}Joker{}',
            [4] = '{C:inactive}(Currently{} {X:mult,C:white}X#1#{} {C:inactive}Mult){}'
        }
    },
    pos = {
        x = 5,
        y = 8
    },
    display_size = {
        w = 71,
        h = 95
    },
    cost = 7,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },

    credit_badges = {
        { text = "Art: wanyo", colour = "00E59B" }
     },

    loc_vars = function(self, info_queue, card)
        local extra = (card and card.ability and card.ability.extra) or {}
        local xm = extra.Xmult or 1
        local gain = extra.Xmult_gain or 0.25
        return { vars = { xm, gain } }
    end,

    calculate = function(self, card, context)
        local extra = card.ability.extra or {}

        if context.before and context.cardarea == G.jokers and context.scoring_name then
            local hand_name = context.scoring_name
            local hand_data = G.GAME and G.GAME.hands and G.GAME.hands[hand_name]
            local hand_level = hand_data and hand_data.level or (to_big and to_big(1) or 1)
            local blind = G and G.GAME and G.GAME.blind
            local blind_key = blind and (
                blind.original_key
                or blind.key
                or (blind.config and blind.config.blind and blind.config.blind.key)
            )
            local arm_active = blind_key == "bl_arm"

            if to_big then
                if to_big(hand_level or 1) <= to_big(1) then
                    return
                end
            elseif (hand_level or 1) <= 1 then
                return
            end

            -- if not context.blueprint then
            extra.Xmult = (extra.Xmult or 1) + (extra.Xmult_gain or 0.25)
            -- end

            if arm_active then
                return {
                    message = localize('k_upgrade_ex')
                }
            end

            return {
                level_up = -1,
                level_up_hand = hand_name,
                message = localize('k_upgrade_ex')
            }
        end

        if context.cardarea == G.jokers and context.joker_main then
            return {
                Xmult = extra.Xmult or 1
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
                local extra = (card.ability and card.ability.extra) or {}
                card.joker_display_values.x_mult = extra.Xmult or 1
            end
        }
    end
}
