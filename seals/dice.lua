SMODS.Seal {
    key = "dice",
    atlas = "CustomSeals",
    pos = { x = 3, y = 0 },
    badge_colour = HEX("48B186"),
    discovered = false,
    unlocked = true,
    loc_txt = {
        name = "Green Seal",
        label = "Green Seal",
        text = {
            [1] = "Adds {C:green}+1{} to all probability",
            [2] = "numerators for this {C:blue}hand{}",
            [3] = "when scored"
        }
    },

    credit_badges = {
        { text = "Art: Jaydchw", colour = "59A487" }
    },

    calculate = function(self, card, context)
        if context.main_scoring and context.cardarea == G.play then
            return {
                message = "+1 Odds!",
                colour = G.C.CHANCE
            }
        end
    end
}
