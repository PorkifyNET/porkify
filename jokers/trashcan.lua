
SMODS.Joker{ --Trash Can
    key = "trashcan",
    config = {
        extra = {
            dollars = 1
        }
    },
    loc_txt = {
        ['name'] = 'Trash Can',
        ['text'] = {
            [1] = 'Unused {C:blue}hands{} and {C:red}discards{}',
            [2] = 'reward an extra {C:money}$1{} each',
            [3] = 'at end of round',
            [4] = '{C:inactive}(Currently{} {C:money}$#1#{}{C:inactive}){}'
        },
        ['unlock'] = {
            [1] = '{C:red}Discard{} {C:attention}100{} cards'
        }
    },
    pos = {
        x = 6,
        y = 5
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 6,
    rarity = 2,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },

    credit_badges = {
        { text = "Art: ToxicPlayer", colour = "59A487" }
     },
    
    loc_vars = function(self, info_queue, card)
        local current_round = G and G.GAME and G.GAME.current_round
        local hands_left = (current_round and current_round.hands_left) or 0
        local discards_left = (current_round and current_round.discards_left) or 0
        local per = (card and card.ability and card.ability.extra and card.ability.extra.dollars) or 1
        return { vars = { (hands_left + discards_left) * per } }
    end,

    calc_dollar_bonus = function(self, card)
        local current_round = G and G.GAME and G.GAME.current_round
        if not current_round then
            return nil
        end

        local hands_left = current_round.hands_left or 0
        local discards_left = current_round.discards_left or 0
        local per = (card and card.ability and card.ability.extra and card.ability.extra.dollars) or 1
        local total = (hands_left + discards_left) * per

        if total > 0 then
            return total
        end
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { ref_table = "card.joker_display_values", ref_value = "money_text", colour = G.C.MONEY }
            },

            calc_function = function(card)
                local current_round = G and G.GAME and G.GAME.current_round
                local hands_left = (current_round and current_round.hands_left) or 0
                local discards_left = (current_round and current_round.discards_left) or 0
                local per = (card.ability.extra and card.ability.extra.dollars) or 1
                local total = (hands_left + discards_left) * per

                card.joker_display_values.money_text = "+$" .. tostring(total)
            end
        }
    end
}