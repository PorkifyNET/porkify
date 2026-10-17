local function porkify_delegation_target(source)
    if type(Porkify_get_sticker_tool_target) ~= 'function' then return nil end

    local target, target_area = Porkify_get_sticker_tool_target(source)
    if target_area ~= (G and G.jokers)
        or not (target and target.ability and target.ability.set == 'Joker')
        or target.ability.omega or target.ability.porkify_omega then
        return nil
    end
    return target
end


local function porkify_delegation_candidates(target)
    local current = target and target.config and target.config.center
    local pool = G and G.P_CENTER_POOLS and G.P_CENTER_POOLS.Joker or {}
    if not current then return {} end

    local candidates = {}
    for _, center in pairs(pool) do
        local available = type(Porkify_pool_object_is_available) ~= 'function'
            or Porkify_pool_object_is_available(center, 'porkify_delegation')
        if center and center.key and center.key ~= current.key
            and center.set == 'Joker'
            and center.rarity == current.rarity
            and center.unlocked ~= false
            and not center.no_collection
            and available then
            candidates[#candidates + 1] = center
        end
    end

    table.sort(candidates, function(a, b)
        return tostring(a.key) < tostring(b.key)
    end)
    return candidates
end


local function porkify_delegation_copy(value, seen)
    if type(value) ~= 'table' then return value end
    seen = seen or {}
    if seen[value] then return seen[value] end

    local result = {}
    seen[value] = result
    for key, child in pairs(value) do
        result[porkify_delegation_copy(key, seen)] = porkify_delegation_copy(child, seen)
    end
    return result
end


local function porkify_delegation_stickers(card)
    local result = {}
    local seen = {}
    for registry_key, sticker in pairs(SMODS.Stickers or {}) do
        local key = sticker.key or registry_key
        local value = card.ability and card.ability[key]
        if value ~= nil and value ~= false and not seen[key] then
            seen[key] = true
            result[#result + 1] = {
                key = key,
                value = porkify_delegation_copy(value),
                config = sticker.config,
                object = sticker
            }
        end
    end
    return result
end


local function porkify_delegation_restore_stickers(card, stickers, pinned, perish_tally)
    card.ability = card.ability or {}
    for _, sticker in ipairs(stickers) do
        if card.ability[sticker.key] == nil or card.ability[sticker.key] == false then
            if sticker.object and type(sticker.object.apply) == 'function' then
                sticker.object:apply(card, true)
            else
                local config = sticker.config or {}
                if config.extra_slots_used then
                    card.ability.extra_slots_used = (card.ability.extra_slots_used or 0)
                        + config.extra_slots_used
                end
                if config.h_size then
                    card.ability.h_size = (card.ability.h_size or 0) + config.h_size
                    if card.added_to_deck and G and G.hand and G.hand.change_size then
                        if Porkify_safe_change_hand_size then
                            Porkify_safe_change_hand_size(config.h_size)
                        else
                            G.hand:change_size(config.h_size)
                        end
                    end
                end
            end
            card.ability[sticker.key] = porkify_delegation_copy(sticker.value)
        end
    end
    card.pinned = pinned
    if perish_tally ~= nil then card.ability.perish_tally = perish_tally end
end


SMODS.Consumable {
    key = 'delegation',
    set = 'porkify',
    pos = { x = 6, y = 0 },
    loc_txt = {
        name = 'Delegation',
        text = {
            'Transform {C:attention}1{} selected Joker',
            'into a random Joker of the',
            '{C:attention}same rarity{}',
            '{C:inactive}(Retains Edition and stickers){}'
        }
    },
    cost = 3,
    unlocked = true,
    discovered = false,
    hidden = false,
    can_repeat_soul = false,
    atlas = 'CustomConsumables',

    update = function(self, card, dt)
        Porkify_update_sticker_tool_selection()
    end,

    use = function(self, card, area, copier)
        local used_card = copier or card
        local target = porkify_delegation_target(card)
        local candidates = porkify_delegation_candidates(target)
        if not target or #candidates == 0 then return end

        local replacement = pseudorandom_element(
            candidates,
            pseudoseed('porkify_delegation')
        )
        if not replacement then return end

        local edition = target.edition
        local stickers = porkify_delegation_stickers(target)
        local pinned = target.pinned
        local perish_tally = target.ability and target.ability.perish_tally

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.15,
            func = function()
                target:flip()
                play_sound('card1', 1.0)
                return true
            end
        }))

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.35,
            func = function()
                target:set_ability(replacement, nil, true)
                target.edition = edition
                porkify_delegation_restore_stickers(
                    target, stickers, pinned, perish_tally
                )
                return true
            end
        }))

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.55,
            func = function()
                target:flip()
                target:juice_up(0.3, 0.3)
                used_card:juice_up(0.3, 0.5)
                play_sound('tarot2', 1.0, 0.6)
                return true
            end
        }))

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.7,
            func = function()
                Porkify_clear_sticker_tool_selection()
                return true
            end
        }))
    end,

    can_use = function(self, card)
        local target = porkify_delegation_target(card)
        return target ~= nil and #porkify_delegation_candidates(target) > 0
    end
}
