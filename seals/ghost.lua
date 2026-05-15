local function porkify_get_remaining_ghost_slots()
    if not (G and G.consumeables and G.consumeables.config) then
        return 0
    end

    local current_round = G.GAME and G.GAME.current_round
    local reserved = (current_round and current_round.porkify_ghost_reserved_consumables) or 0
    local limit = G.consumeables.config.card_limit or 0

    return math.max(0, limit - #G.consumeables.cards - reserved)
end

local function porkify_get_ghost_card_key(card)
    return card and (card.unique_val or card.sort_id or tostring(card))
end

local function porkify_get_random_consumable_copy_target()
    local consumeables = G and G.consumeables and G.consumeables.cards
    if not consumeables or #consumeables == 0 then
        return nil
    end

    local valid = {}
    for _, c in ipairs(consumeables) do
        local center = c and c.config and c.config.center
        local set = (c and c.ability and c.ability.set) or (center and center.set)
        if center and center.key and set then
            valid[#valid + 1] = c
        end
    end

    if #valid == 0 then
        return nil
    end

    return pseudorandom_element(valid, pseudoseed("porkify_ghost_seal"))
end

SMODS.Seal {
    key = "ghost",
    atlas = "CustomSeals",
    pos = { x = 2, y = 0 },
    badge_colour = HEX("BFA8FF"),
    discovered = false,
    unlocked = true,
    loc_txt = {
        name = "Ghost Seal",
        label = "Ghost Seal",
        text = {
            [1] = "Create a {C:attention}copy{} of a random",
            [2] = "{C:tarot}consumable{} in your possession",
            [3] = "when held at end of round",
            [4] = "{C:inactive}(Must have room){}"
        }
    },

    credit_badges = {
        { text = "Art: Astro", colour = "59A487" }
     },

    calculate = function(self, card, context)
        if context.end_of_round and context.main_eval and not context.blueprint and G and G.GAME then
            G.GAME.current_round = G.GAME.current_round or {}
            G.GAME.current_round.porkify_ghost_reserved_consumables = 0
            G.GAME.current_round.porkify_ghost_triggered_cards = {}
        end

        if context.end_of_round
            and context.cardarea == G.hand
            and not context.repetition
            and (
                context.individual
                or context.main_eval
                or (not context.individual and not context.main_eval)
            ) then
            G.GAME.current_round = G.GAME.current_round or {}
            G.GAME.current_round.porkify_ghost_triggered_cards =
                G.GAME.current_round.porkify_ghost_triggered_cards or {}

            local card_key = porkify_get_ghost_card_key(card)
            if card_key and G.GAME.current_round.porkify_ghost_triggered_cards[card_key] then
                return
            end

            if porkify_get_remaining_ghost_slots() <= 0 then
                return
            end

            local target = porkify_get_random_consumable_copy_target()
            local center = target and target.config and target.config.center
            local set = (target and target.ability and target.ability.set) or (center and center.set)
            local key = center and center.key

            if not (set and key) then
                return
            end

            if card_key then
                G.GAME.current_round.porkify_ghost_triggered_cards[card_key] = true
            end

            G.GAME.current_round.porkify_ghost_reserved_consumables =
                (G.GAME.current_round.porkify_ghost_reserved_consumables or 0) + 1

            return {
                func = function()
                    local current_round = G and G.GAME and G.GAME.current_round
                    if current_round then
                        current_round.porkify_ghost_reserved_consumables =
                            math.max(0, (current_round.porkify_ghost_reserved_consumables or 1) - 1)
                    end

                    if not (G and G.consumeables and G.consumeables.cards and G.consumeables.config) then
                        return true
                    end

                    if #G.consumeables.cards >= (G.consumeables.config.card_limit or 0) then
                        return true
                    end

                    local created = SMODS.add_card({
                        set = set,
                        key = key
                    })

                    if created then
                        card_eval_status_text(
                            card,
                            "extra",
                            nil,
                            nil,
                            nil,
                            { message = "Ghosted!", colour = G.C.SECONDARY_SET.Spectral }
                        )
                    end

                    return true
                end
            }
        end
    end
}
