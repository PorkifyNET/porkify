SMODS.Tag({
    key = "gold_seal",
    atlas = "CustomTags",
    pos = { x = 0, y = 0 },
    config = {},
    loc_txt = {
        name = "Gold Seal Tag",
        text = {
            [1] = "The next played hand",
            [2] = "gains {C:gold}Gold{} Seals",
            [3] = "on all cards"
        }
    },
    apply = function(self, tag, context)
        if context.type ~= "immediate" then
            return
        end

        G.GAME.porkify_gold_seal_tag_pending = true
        G.GAME.porkify_gold_seal_tag_ref = tag
        return true
    end,
    in_pool = function(self, args)
        return true
    end,
    unlocked = true,
    discovered = true,
    min_ante = 1
})
