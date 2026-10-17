local function porkify_paint_contains(area, target)
    if not (area and area.cards and target) then return false end

    for _, card in ipairs(area.cards) do
        if card == target then return true end
    end

    return false
end

local function porkify_paint_empty_slots(card)
    if type(Porkify_card_sleeve_empty_slots) == 'function' then
        local shared_slots = Porkify_card_sleeve_empty_slots(card)
        if shared_slots ~= nil then return shared_slots end
    end

    local joker_slots = 0
    if G and G.jokers and G.jokers.config then
        local limit = G.jokers.config.card_limit or 0
        local occupied = #(G.jokers.cards or {})
            + ((G.GAME and G.GAME.joker_buffer) or 0)
        local self_credit = porkify_paint_contains(G.jokers, card) and 1 or 0
        joker_slots = math.max(0, limit - occupied + self_credit)
    end

    local consumable_slots = 0
    if G and G.consumeables and G.consumeables.config then
        local limit = G.consumeables.config.card_limit or 0
        local occupied = #(G.consumeables.cards or {})
            + ((G.GAME and G.GAME.consumeable_buffer) or 0)
        consumable_slots = math.max(0, limit - occupied)
    end

    return joker_slots + consumable_slots
end


local function porkify_paint_sync_hand_size(card, desired)
    desired = math.max(0, desired or 0)
    local applied = card.porkify_paint_hand_size or 0
    local change = desired - applied

    if change ~= 0 and G and G.hand and G.hand.change_size then
        G.hand:change_size(change)
        card.porkify_paint_hand_size = desired
    end
end


SMODS.Joker{
    key = 'paint',
    config = { extra = { hand_size_per_slot = 1 } },
    loc_txt = {
        name = 'Paint',
        text = {
            '{C:attention}+#1#{} Hand Size for each',
            'empty {C:attention}Joker{} and',
            '{C:tarot}Consumable{} slot',
            '{s:0.8}Paint included{}',
            '{C:inactive}(Currently {C:attention}+#2#{} {C:inactive}Hand Size){}'
        }
    },
    atlas = 'CustomJokers',
    pos = { x = 9, y = 10 }, -- Placeholder artwork.
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
        { text = "Art: Half a Dima", colour = "59A487" }
     },

    loc_vars = function(self, info_queue, card)
        local per_slot = card and card.ability and card.ability.extra
            and card.ability.extra.hand_size_per_slot or 1
        return { vars = { per_slot, porkify_paint_empty_slots(card) * per_slot } }
    end,

    add_to_deck = function(self, card, from_debuff)
        local per_slot = card.ability.extra.hand_size_per_slot or 1
        porkify_paint_sync_hand_size(card, porkify_paint_empty_slots(card) * per_slot)
    end,

    remove_from_deck = function(self, card, from_debuff)
        porkify_paint_sync_hand_size(card, 0)
        card.porkify_paint_hand_size = nil
    end,

    update = function(self, card, dt)
        local active = G and G.jokers and card.area == G.jokers
            and not card.debuff and not card.getting_sliced
            and not card.destroyed and not card.removed
        local per_slot = card.ability.extra.hand_size_per_slot or 1
        local desired = active and porkify_paint_empty_slots(card) * per_slot or 0
        porkify_paint_sync_hand_size(card, desired)
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { ref_table = 'card.joker_display_values', ref_value = 'hand_size_text', colour = G.C.IMPORTANT }
            },
            calc_function = function(card)
                local per_slot = card.ability.extra.hand_size_per_slot or 1
                local hand_size = porkify_paint_empty_slots(card) * per_slot
                card.joker_display_values.hand_size_text = '+' .. tostring(hand_size)
            end
        }
    end
}
