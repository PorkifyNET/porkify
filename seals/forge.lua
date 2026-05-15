SMODS.Seal {
    key = "forge",
    atlas = "CustomSeals",
    pos = { x = 5, y = 0 },
    config = {
        extra = {
            chip_gain = 12
        }
    },
    badge_colour = HEX("C96B2C"),
    discovered = false,
    unlocked = true,
    loc_txt = {
        name = "Forge Seal",
        label = "Forge Seal",
        text = {
            [1] = "When scored, this card",
            [2] = "permanently gains",
            [3] = "{C:blue}+#1#{} Chips"
        }
    },

    loc_vars = function(self, info_queue, card)
        local extra = (card and card.ability and card.ability.seal and card.ability.seal.extra) or self.config.extra
        return { vars = { extra.chip_gain or 0 } }
    end,

    calculate = function(self, card, context)
        if context.main_scoring and context.cardarea == G.play then
            card.ability.perma_bonus = (card.ability.perma_bonus or 0) + card.ability.seal.extra.chip_gain
            return {
                message = localize("k_upgrade_ex"),
                colour = G.C.CHIPS
            }
        end
    end
}
