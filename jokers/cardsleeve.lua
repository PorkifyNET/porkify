local function porkify_card_sleeve_state()
    if not (G and G.GAME) then return nil end

    G.GAME.porkify_card_sleeve = G.GAME.porkify_card_sleeve or {
        joker_adjustment = 0,
        consumeable_adjustment = 0
    }
    return G.GAME.porkify_card_sleeve
end


local function porkify_is_active_card_sleeve(card)
    if not card or card.debuff or card.getting_sliced or card.destroyed
        or card.removed or card.porkify_card_sleeve_inactive then
        return false
    end

    local center = card.config and card.config.center
    local key = center and (center.key or center.original_key)
    return key == 'j_porkify_cardsleeve' or key == 'cardsleeve'
        or (card.ability and card.ability.name == 'Card Sleeve')
end


local function porkify_card_sleeve_is_enabled()
    for _, joker in ipairs(G and G.jokers and G.jokers.cards or {}) do
        if porkify_is_active_card_sleeve(joker) then return true end
    end
    return false
end


local function porkify_card_sleeve_native_limits()
    local state = porkify_card_sleeve_state()
    if not (state and G.jokers and G.jokers.config
        and G.consumeables and G.consumeables.config) then
        return 0, 0
    end

    local joker_limit = G.jokers.config.card_limit or 0
    local consumeable_limit = G.consumeables.config.card_limit or 0
    return joker_limit - (state.joker_adjustment or 0),
        consumeable_limit - (state.consumeable_adjustment or 0)
end


local function porkify_card_sleeve_sync()
    local state = porkify_card_sleeve_state()
    if not (state and G.jokers and G.jokers.config
        and G.consumeables and G.consumeables.config) then
        return
    end

    local native_jokers, native_consumeables = porkify_card_sleeve_native_limits()
    local joker_adjustment, consumeable_adjustment = 0, 0

    if porkify_card_sleeve_is_enabled() then
        local total_slots = math.max(0, native_jokers + native_consumeables)
        local joker_count = #(G.jokers.cards or {})
            + ((G.GAME and G.GAME.joker_buffer) or 0)
        local consumeable_count = #(G.consumeables.cards or {})
            + ((G.GAME and G.GAME.consumeable_buffer) or 0)
        local joker_limit = math.max(0, total_slots - consumeable_count)
        local consumeable_limit = math.max(0, total_slots - joker_count)

        joker_adjustment = joker_limit - native_jokers
        consumeable_adjustment = consumeable_limit - native_consumeables
    end

    local joker_change = joker_adjustment - (state.joker_adjustment or 0)
    local consumeable_change = consumeable_adjustment - (state.consumeable_adjustment or 0)

    if joker_change ~= 0 then
        if G.jokers.change_size then G.jokers:change_size(joker_change)
        else G.jokers.config.card_limit = (G.jokers.config.card_limit or 0) + joker_change end
    end
    if consumeable_change ~= 0 then
        if G.consumeables.change_size then G.consumeables:change_size(consumeable_change)
        else
            G.consumeables.config.card_limit = (G.consumeables.config.card_limit or 0)
                + consumeable_change
        end
    end

    state.joker_adjustment = joker_adjustment
    state.consumeable_adjustment = consumeable_adjustment
end


function Porkify_card_sleeve_shared_slots_active()
    return porkify_card_sleeve_is_enabled()
end


function Porkify_card_sleeve_empty_slots(card)
    if not porkify_card_sleeve_is_enabled() then return nil end

    local native_jokers, native_consumeables = porkify_card_sleeve_native_limits()
    local occupied = #(G.jokers.cards or {}) + #(G.consumeables.cards or {})
        + ((G.GAME and G.GAME.joker_buffer) or 0)
        + ((G.GAME and G.GAME.consumeable_buffer) or 0)
    local self_credit = 0

    for _, joker in ipairs(G.jokers.cards or {}) do
        if joker == card then self_credit = 1; break end
    end

    return math.max(0, native_jokers + native_consumeables - occupied + self_credit)
end


SMODS.Joker {
    key = 'cardsleeve',
    loc_txt = {
        name = 'Card Sleeve',
        text = {
            '{C:attention}Jokers{} and {C:tarot}Consumables{}',
            'use the same shared slots'
        }
    },
    atlas = 'CustomJokers',
    pos = { x = 2, y = 11 }, -- Placeholder artwork.
    display_size = { w = 71, h = 95 },
    cost = 8,
    rarity = 3,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = false,
    pools = { ['modprefix_porkify_jokers'] = true },

    credit_badges = {
        { text = "Art: cebeedrawz", colour = "59A487" }
     },

    add_to_deck = function(self, card, from_debuff)
        card.porkify_card_sleeve_inactive = nil
        porkify_card_sleeve_sync()
    end,

    remove_from_deck = function(self, card, from_debuff)
        card.porkify_card_sleeve_inactive = true
        porkify_card_sleeve_sync()
    end,

    update = function(self, card, dt)
        porkify_card_sleeve_sync()
    end
}
