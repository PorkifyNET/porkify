local function porkify_get_remaining_ghost_slots()
    if not (G and G.consumeables and G.consumeables.config) then
        return 0
    end

    local current_round = G.GAME and G.GAME.current_round
    local reserved = (current_round and current_round.porkify_ghost_reserved_consumables) or 0
    local limit = G.consumeables.config.card_limit or 0

    return math.max(0, limit - #G.consumeables.cards - reserved)
end

local function porkify_is_ghost_seal(card)
    local seal = card and (card.seal or (card.ability and card.ability.seal))
    return seal == "porkify_ghost" or seal == "ghost"
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
            [1] = "Create a random",
            [2] = "{C:spectral}Spectral{} card when this",
            [3] = "card is {C:red}destroyed{}",
            [4] = "{C:inactive}(Must have room){}"
        }
    },

    credit_badges = {
        { text = "Art: Astro", colour = "59A487" }
    }
}

local function porkify_queue_ghost_spectral(card)
    if not (card and not card.debuff and porkify_is_ghost_seal(card)) then
        return
    end
    if card.porkify_ghost_spectral_queued or porkify_get_remaining_ghost_slots() <= 0 then
        return
    end

    G.GAME.current_round = G.GAME.current_round or {}
    card.porkify_ghost_spectral_queued = true
    G.GAME.current_round.porkify_ghost_reserved_consumables =
        (G.GAME.current_round.porkify_ghost_reserved_consumables or 0) + 1

    G.E_MANAGER:add_event(Event({
        trigger = "after",
        delay = 0.2,
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

            local created = SMODS.add_card({ set = "Spectral", area = G.consumeables })
            if created then
                card_eval_status_text(
                    created,
                    "extra",
                    nil,
                    nil,
                    nil,
                    { message = localize("k_plus_spectral"), colour = G.C.SECONDARY_SET.Spectral }
                )
            end

            return true
        end
    }))
end

if SMODS and type(SMODS.calculate_context) == "function" and not Porkify_calculate_context_ghost_seal then
    Porkify_calculate_context_ghost_seal = SMODS.calculate_context
    SMODS.calculate_context = function(context, ...)
        local result = Porkify_calculate_context_ghost_seal(context, ...)

        if context and context.remove_playing_cards and type(context.removed) == "table" then
            for _, removed_card in ipairs(context.removed) do
                porkify_queue_ghost_spectral(removed_card)
            end
        end

        return result
    end
end
