SMODS.Tag({
    key = "enhanced",
    atlas = "CustomTags",
    pos = { x = 1, y = 0 },
    config = { type = "new_blind_choice", cards = 3 },
    loc_txt = {
        name = "Enhanced Tag",
        text = {
            [1] = "Give {C:attention}#1#{} random base cards",
            [2] = "in your deck a random",
            [3] = "{C:enhanced}Enhancement{}"
        }
    },
    loc_vars = function(self)
        return { vars = { self.config.cards or 3 } }
    end,
    apply = function(self, tag, context)
        return Porkify_apply_enhanced_deck_tag(tag, context, self.config.cards or 3)
    end,
    unlocked = true,
    discovered = true,
    min_ante = 1
})
