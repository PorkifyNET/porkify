SMODS.Joker{ -- Backlog
    key = "backlog",
    config = {
        extra = {
            max_retain = 10,
            stored_discards = 0
        }
    },
    loc_txt = {
        ['name'] = 'Backlog',
        ['text'] = {
            [1] = 'This Joker retains up to',
            [2] = '{C:attention}#1#{} unused {C:red}Discards{}',
            [3] = 'for the next round',
            [4] = '{C:inactive}(Currently holding{} {C:red}#2#{}{C:inactive}){}'
        }
    },
    pos = {
        x = 1,
        y = 7
    },
    display_size = {
        w = 71,
        h = 95
    },
    cost = 6,
    rarity = 2,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },

    loc_vars = function(self, info_queue, card)
        local extra = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { extra.max_retain or 10, extra.stored_discards or 0 } }
    end,

    calculate = function(self, card, context)
        if context.end_of_round and context.main_eval and not context.game_over then
            local discards_left = ((G and G.GAME and G.GAME.current_round and G.GAME.current_round.discards_left) or 0)
            card.ability.extra.stored_discards = math.min(
                card.ability.extra.max_retain or 10,
                math.max(0, discards_left)
            )

            if card.ability.extra.stored_discards > 0 then
                return {
                    message = "+" .. tostring(card.ability.extra.stored_discards) .. " Saved",
                    colour = G.C.RED
                }
            end
        end

        if context.setting_blind and not context.blueprint and G and G.GAME then
            local stored = card.ability.extra.stored_discards or 0
            if stored > 0 then
                return {
                    func = function()
                        G.GAME.current_round = G.GAME.current_round or {}
                        G.GAME.current_round.discards_left = (G.GAME.current_round.discards_left or 0) + stored
                        G.GAME.current_round.discards = (G.GAME.current_round.discards or 0) + stored

                        card_eval_status_text(
                            card,
                            'extra',
                            nil,
                            nil,
                            nil,
                            { message = "+" .. tostring(stored) .. " Discards", colour = G.C.GREEN }
                        )

                        card.ability.extra.stored_discards = 0
                        return true
                    end
                }
            end
        end
    end
}
