SMODS.Tag({
    key = "enhanced",
    atlas = "CustomTags",
    pos = { x = 1, y = 0 },
    config = { type = "store_joker_create", porkify_shop_reserve_amount = 1 },
    loc_txt = {
        name = "Enhanced Tag",
        text = {
            [1] = "Shop has a free",
            [2] = "{C:attention}playing card{} with a",
            [3] = "random {C:enhanced}Enhancement{}"
        }
    },
    apply = function(self, tag, context)
        return Porkify_apply_playing_card_shop_tag("enhanced", tag, context)
    end,
    unlocked = true,
    discovered = true,
    min_ante = 1
})
