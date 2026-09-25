local function porkify_forge_rank_value(card)
    local rank_id = card and card.get_id and card:get_id()

    if rank_id and rank_id >= 2 and rank_id <= 10 then
        return rank_id
    end
    if rank_id == 11 or rank_id == 12 or rank_id == 13 then
        return 10
    end
    if rank_id == 14 then
        return 11
    end

    return 0
end

local function porkify_forge_held_x_score(card)
    return 1 + porkify_forge_rank_value(card) * 0.01
end

SMODS.Seal {
    key = "forge",
    atlas = "CustomSeals",
    pos = { x = 5, y = 0 },
    badge_colour = HEX("C96B2C"),
    discovered = false,
    unlocked = true,
    loc_txt = {
        name = "Forge Seal",
        label = "Forge Seal",
        text = {
            [1] = "{X:purple,C:white}X#1#{} Score when",
            [2] = "held in hand",
            [3] = "{C:inactive}(Based on rank){}"
        }
    },

    loc_vars = function(self, info_queue, card)
        local multiplier = card and card.get_id
            and string.format("%.2f", porkify_forge_held_x_score(card))
            or "1.02-1.11"
        return { vars = { multiplier } }
    end,

    calculate = function(self, card, context)
        if context.main_scoring and context.cardarea == G.hand then
            local multiplier = porkify_forge_held_x_score(card)
            if multiplier <= 1 then
                return
            end

            return {
                h_x_score = multiplier
            }
        end
    end
}
