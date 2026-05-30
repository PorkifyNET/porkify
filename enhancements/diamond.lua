SMODS.Enhancement {
    key = 'diamond',
    pos = { x = 9, y = 0 },
    config = {
        extra = {
            chips_per_hand = 5,
            stored_chips = 0,
            last_hands_played = 0,
            last_end_of_round_key = nil
        }
    },
    loc_txt = {
        name = 'Diamond',
        text = {
            [1] = '{C:blue}+5{} Chips for every',
            [2] = '{C:blue}hand{} this card is not',
            [3] = '{C:attention}played{} or {C:red}discarded{}',
            [4] = '{C:inactive}(Currently {C:blue}+#1#{} {C:inactive}Chips){}'
        }
    },
    atlas = 'CustomEnhancements',
    any_suit = false,
    replace_base_card = false,
    no_rank = false,
    no_suit = false,
    always_scores = false,
    unlocked = true,
    discovered = false,
    no_collection = false,
    weight = 5,

    set_ability = function(self, card, initial)
        local extra = card.ability.extra or {}
        local round = (G and G.GAME and G.GAME.current_round) or {}
        extra.last_hands_played = round.hands_played or 0
        extra.stored_chips = extra.stored_chips or 0
        extra.last_end_of_round_key = extra.last_end_of_round_key
        card.ability.extra = extra
    end,

    loc_vars = function(self, info_queue, card)
        local extra = (card and card.ability and card.ability.extra) or (self.config and self.config.extra) or {}
        return { vars = { extra.stored_chips or 0 } }
    end,

    calculate = function(self, card, context)
        if context.hand_drawn and not context.blueprint then
            local extra = card.ability.extra or {}
            local round = (G and G.GAME and G.GAME.current_round) or {}
            local hands_played = round.hands_played or 0
            local prior_hands_played = extra.last_hands_played or 0

            extra.last_hands_played = hands_played

            if hands_played > prior_hands_played then
                extra.stored_chips = (extra.stored_chips or 0) + (extra.chips_per_hand or 5)
                card.ability.extra = extra
                return {
                    message = localize('k_upgrade_ex'),
                    colour = G.C.CHIPS
                }
            end

            card.ability.extra = extra
        end

        if context.discard and context.other_card == card then
            card.ability.extra = card.ability.extra or {}
            card.ability.extra.stored_chips = 0
            return {
                message = 'Reset!',
                colour = G.C.ATTENTION
            }
        end

        if context.end_of_round and not context.game_over and card.area == G.hand then
            local extra = card.ability.extra or {}
            local round_key = tostring((G.GAME and G.GAME.round_resets and G.GAME.round_resets.ante) or 0)
                .. "_" .. tostring((G.GAME and G.GAME.round) or 0)

            if extra.last_end_of_round_key == round_key then
                card.ability.extra = extra
                return
            end

            extra.last_end_of_round_key = round_key
            extra.stored_chips = (extra.stored_chips or 0) + (extra.chips_per_hand or 5)
            card.ability.extra = extra
            return {
                message = localize('k_upgrade_ex'),
                colour = G.C.CHIPS
            }
        end

        if context.main_scoring and context.cardarea == G.play then
            local stored = (card.ability.extra and card.ability.extra.stored_chips) or 0
            card.ability.extra.stored_chips = 0
            if stored > 0 then
                return {
                    chips = stored
                }
            end
        end
    end
}
