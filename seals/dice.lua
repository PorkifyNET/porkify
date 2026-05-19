SMODS.Seal {
    key = "dice",
    atlas = "CustomSeals",
    pos = { x = 3, y = 0 },
    badge_colour = HEX("48B186"),
    discovered = false,
    unlocked = true,
    loc_txt = {
        name = "Dice Seal",
        label = "Dice Seal",
        text = {
            [1] = "All {C:green}probabilities{} {C:attention}succeed{}",
            [2] = "for this {C:blue}hand{} when scored"
        }
    },

    credit_badges = {
        { text = "Art: Jaydchw", colour = "59A487" }
    },

    calculate = function(self, card, context)
        if context.main_scoring and context.cardarea == G.play and G and G.GAME then
            G.GAME.current_round = G.GAME.current_round or {}
            G.GAME.current_round.porkify_dice_probability_active = true

            return {
                message = "Loaded!",
                colour = G.C.CHANCE
            }
        end
    end
}
