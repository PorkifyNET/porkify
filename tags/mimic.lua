SMODS.Tag({
    key = "mimic",
    atlas = "CustomTags",
    pos = { x = 5, y = 0 },
    config = { type = "store_joker_create", porkify_shop_reserve_amount = 1 },
    loc_txt = {
        name = "Mimic Tag",
        text = {
            [1] = "Next shop has a free",
            [2] = "{C:enhanced}Mimic{} playing card"
        }
    },
    loc_vars = function(self, info_queue, card)
        local info_queue_0 = G.P_CENTERS and G.P_CENTERS["m_porkify_mimic"]
        if info_queue_0 then
            info_queue[#info_queue + 1] = info_queue_0
        end
    end,
    apply = function(self, tag, context)
        return Porkify_apply_playing_card_shop_tag("mimic", tag, context)
    end,
    in_pool = function(self, args)
        return true
    end,
    unlocked = true,
    discovered = true,
    min_ante = 1
})
