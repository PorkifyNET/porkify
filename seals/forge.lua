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
            [1] = "Permanently adds {C:attention}1%{} of",
            [2] = "this card's {C:attention}rank{} as {X:blue,C:white}XChips{}",
            [3] = "when scored"
        }
    },

    calculate = function(self, card, context)
        if context.main_scoring and context.cardarea == G.play then
            local rank_id = card.get_id and card:get_id()
            local x_chips_gain = 0

            if rank_id and rank_id >= 2 and rank_id <= 10 then
                x_chips_gain = rank_id * 0.01
            elseif rank_id == 11 or rank_id == 12 or rank_id == 13 then
                x_chips_gain = 0.10
            elseif rank_id == 14 then
                x_chips_gain = 0.11
            end

            if x_chips_gain <= 0 then
                return
            end

            card.ability.perma_x_chips = (card.ability.perma_x_chips or 0) + x_chips_gain
            return {
                message = localize("k_upgrade_ex"),
                colour = G.C.CHIPS
            }
        end
    end
}
