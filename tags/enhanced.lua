local function porkify_joker_has_edition(joker)
    return not not (joker and joker.edition and joker.edition.key)
end

SMODS.Tag({
    key = "enhanced",
    atlas = "CustomTags",
    pos = { x = 1, y = 0 },
    config = {},
    loc_txt = {
        name = "Enhanced Tag",
        text = {
            [1] = "Adds a random {C:dark_edition}Edition{}",
            [2] = "to {C:attention}1{} random {C:attention}Joker{}"
        }
    },
    in_pool = function(self, args)
        local jokers = (G and G.jokers and G.jokers.cards) or {}
        for _, joker in ipairs(jokers) do
            if joker and joker.set_edition and not porkify_joker_has_edition(joker) then
                return true
            end
        end
        return false
    end,
    apply = function(self, tag, context)
        if context.type ~= "immediate" then
            return
        end

        local eligible_jokers = {}
        for _, joker in ipairs((G and G.jokers and G.jokers.cards) or {}) do
            if joker and joker.set_edition and not porkify_joker_has_edition(joker) then
                eligible_jokers[#eligible_jokers + 1] = joker
            end
        end

        if #eligible_jokers == 0 then
            return
        end

        local target = pseudorandom_element(eligible_jokers, pseudoseed("porkify_enhanced_tag_target"))
        local edition_key = SMODS.poll_edition({
            key = "porkify_enhanced_tag_edition",
            guaranteed = true
        })

        tag:yep("+", G.C.DARK_EDITION, function()
            if target and edition_key and target.set_edition then
                target:set_edition(edition_key, true)
                target:juice_up(0.3, 0.5)
            end
            return true
        end)
        tag.triggered = true
        return true
    end,
    unlocked = true,
    discovered = true,
    min_ante = 2
})
