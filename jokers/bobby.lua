SMODS.Joker{ -- Bobby
    key = "bobby",
    config = {
        extra = {
            hand_loss = 2,
            discard_gain = 4
        }
    },
    loc_txt = {
        ['name'] = 'Bobby',
        ['text'] = {
            [1] = 'When {C:attention}Blind{} is selected,',
            [2] = 'lose {C:blue}#1#{} Hands',
            [3] = 'and gain {C:red}#2#{} Discards'
        }
    },
    pos = { x = 6, y = 8 },
    display_size = { w = 71, h = 95 },
    cost = 5,
    rarity = 2,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["porkify_porkify_jokers"] = true },

    credit_badges = {
        { text = "Art: u/Top-Sky4811", colour = "FF4500" }
     },

    loc_vars = function(self, info_queue, card)
        local extra = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { extra.hand_loss or 2, extra.discard_gain or 4 } }
    end,

    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint and G and G.GAME then
            return {
                func = function()
                    local extra = card.ability.extra or {}
                    local hand_loss = extra.hand_loss or 2
                    local discard_gain = extra.discard_gain or 4

                    G.GAME.current_round = G.GAME.current_round or {}

                    local current_hands_left = G.GAME.current_round.hands_left or 0
                    local current_hands = G.GAME.current_round.hands or current_hands_left
                    local lost_hands = math.min(hand_loss, math.max(0, current_hands_left))

                    G.GAME.current_round.hands_left = math.max(0, current_hands_left - hand_loss)
                    G.GAME.current_round.hands = math.max(0, current_hands - hand_loss)
                    G.GAME.current_round.discards_left = (G.GAME.current_round.discards_left or 0) + discard_gain
                    G.GAME.current_round.discards = (G.GAME.current_round.discards or 0) + discard_gain

                    card_eval_status_text(
                        card,
                        'extra',
                        nil,
                        nil,
                        nil,
                        {
                            message = "-" .. tostring(lost_hands) .. " Hands, +" .. tostring(discard_gain) .. " Discards",
                            colour = G.C.ORANGE
                        }
                    )
                    return true
                end
            }
        end
    end
}
