SMODS.Tag({
    key = "gold_seal",
    atlas = "CustomTags",
    pos = { x = 0, y = 0 },
    config = { type = "store_joker_create" },
    loc_txt = {
        name = "Gold Tag",
        text = {
            [1] = "Next base edition shop",
            [2] = "{C:attention}Joker{} is free and",
            [3] = "becomes {C:money}Gilded{}"
        }
    },
    loc_vars = function(self, info_queue, card)
        local gilded = G.P_CENTERS and G.P_CENTERS["e_porkify_gilded"]
        if gilded then info_queue[#info_queue + 1] = gilded end
    end,
    apply = function(self, tag, context)
        return Porkify_apply_gold_shop_joker_tag(tag, context)
    end,
    in_pool = function(self, args)
        return true
    end,
    unlocked = true,
    discovered = true,
    min_ante = 1
})
