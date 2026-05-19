SMODS.Seal {
    key = "glitched",
    atlas = "CustomSeals",
    pos = { x = 4, y = 0 },
    badge_colour = HEX("74F0D4"),
    discovered = false,
    unlocked = true,
    loc_txt = {
        name = "Glitched Seal",
        label = "Glitched Seal",
        text = {
            [1] = "{C:green}Returns{} to {C:blue}hand{} after",
            [2] = "being played {C:attention}once{} per",
            [3] = "round",
            [4] = "{C:inactive}({}{V:1}#1#{}{C:inactive}){}"
        }
    },

    credit_badges = {
        { text = "Art: Astro", colour = "59A487" }
     },

    loc_vars = function(self, info_queue, card)
        local current_round = G and G.GAME and G.GAME.current_round
        local returned = current_round and current_round.porkify_glitched_returned_ids
        local card_key = card and (card.unique_val or card.sort_id or tostring(card))
        local is_returned = returned and card_key and returned[card_key]
        local status = is_returned and "Inactive" or "Active!"
        local status_colour = is_returned and G.C.RED or G.C.GREEN

        return {
            vars = {
                status,
                colours = { status_colour }
            }
        }
    end,

    calculate = function(self, card, context)
        if context.setting_blind and G and G.GAME then
            G.GAME.current_round = G.GAME.current_round or {}
            G.GAME.current_round.porkify_glitched_returned_ids = {}
        end

        if context.main_scoring and context.cardarea == G.play then
            local current_round = G and G.GAME and G.GAME.current_round
            local returned = current_round and current_round.porkify_glitched_returned_ids
            local card_key = card and (card.unique_val or card.sort_id or tostring(card))
            -- if returned and card_key and returned[card_key] then
            --     return {
            --         message = "Glitched!",
            --         colour = G.C.GREEN
            --     }
            -- end
        end
    end
}
