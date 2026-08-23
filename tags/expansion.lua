SMODS.Tag({
    key = "expansion",
    atlas = "CustomTags",
    pos = { x = 6, y = 0 },
    config = { type = "shop_start", porkify_shop_reserve_amount = 2 },
    loc_txt = {
        name = "Expansion Tag",
        text = {
            [1] = "Next shop has",
            [2] = "{C:attention}2{} additional card slots"
        }
    },
    apply = function(self, tag, context)
        return Porkify_apply_shop_expansion_tag(tag, context, 2)
    end,
    in_pool = function(self, args)
        return true
    end,
    unlocked = true,
    discovered = true,
    min_ante = 1
})
