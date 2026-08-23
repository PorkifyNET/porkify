SMODS.Tag({
    key = "porkify",
    atlas = "CustomTags",
    pos = { x = 2, y = 0 },
    config = { type = "new_blind_choice" },
    loc_txt = {
        name = "Porkify Tag",
        text = {
            [1] = "Gives a free",
            [2] = "{C:purple}Mega Porkify Pack{}"
        }
    },
    loc_vars = function(self, info_queue, card)
        local info_queue_0 = (G.P_CENTERS and G.P_CENTERS["p_porkify_mega_porkify_pack"])
        if info_queue_0 then
            info_queue[#info_queue + 1] = info_queue_0
        end
    end,
    apply = function(self, tag, context)
        if context.type ~= "new_blind_choice" then
            return
        end

        return Porkify_open_tag_pack("p_porkify_mega_porkify_pack", tag)
    end,
    in_pool = function(self, args)
        return true
    end,
    unlocked = true,
    discovered = true,
    min_ante = 2
})
