SMODS.Tag({
    key = "gold_seal",
    atlas = "CustomTags",
    pos = { x = 0, y = 0 },
    config = { type = "store_joker_create", porkify_shop_reserve_amount = 1 },
    loc_txt = {
        name = "Gold Seal Tag",
        text = {
            [1] = "Shop has a free",
            [2] = "{C:attention}playing card{} with a",
            [3] = "{C:gold}Gold Seal{}"
        }
    },
    apply = function(self, tag, context)
        return Porkify_apply_playing_card_shop_tag("gold_seal", tag, context)
    end,
    in_pool = function(self, args)
        return true
    end,
    unlocked = true,
    discovered = true,
    min_ante = 1
})
