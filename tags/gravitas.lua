SMODS.Tag({
    key = "gravitas",
    atlas = "CustomTags",
    pos = { x = 4, y = 0 },
    config = { type = "store_joker_create", porkify_shop_reserve_amount = 1 },
    loc_txt = {
        name = "Gravitas Tag",
        text = {
            [1] = "Next shop has a free",
            [2] = "{C:attention}playing card{} with a",
            [3] = "{C:purple}Gravitas Seal{}"
        }
    },
    loc_vars = function(self, info_queue, card)
        local info_queue_0 = G.P_SEALS and (G.P_SEALS["porkify_gravitas"] or G.P_SEALS["gravitas"])
        if info_queue_0 then
            info_queue[#info_queue + 1] = info_queue_0
        end
    end,
    apply = function(self, tag, context)
        return Porkify_apply_playing_card_shop_tag("gravitas", tag, context)
    end,
    in_pool = function(self, args)
        return true
    end,
    unlocked = true,
    discovered = true,
    min_ante = 2
})
