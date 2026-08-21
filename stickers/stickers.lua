local function apply_porkify_sticker(self, card, val)
    local previous = card.ability[self.key]
    local previous_slots = type(previous) == "table" and (previous.extra_slots_used or 0) or 0
    local previous_hand_size = type(previous) == "table" and (previous.h_size or 0) or 0

    if previous_slots ~= 0 then
        card.ability.extra_slots_used = (card.ability.extra_slots_used or 0) - previous_slots
    end
    if previous_hand_size ~= 0 then
        card.ability.h_size = (card.ability.h_size or 0) - previous_hand_size
        if card.added_to_deck and G and G.hand then
            if Porkify_safe_change_hand_size then
                Porkify_safe_change_hand_size(-previous_hand_size)
            else
                G.hand:change_size(-previous_hand_size)
            end
        end
    end

    card.ability[self.key] = val

    if val and self.config then
        card.ability[self.key] = {}
        for k, v in pairs(self.config) do
            card.ability[self.key][k] = v

            if k == "extra_slots_used" then
                card.ability.extra_slots_used = (card.ability.extra_slots_used or 0) + v
            elseif k == "h_size" then
                card.ability.h_size = (card.ability.h_size or 0) + v
                if card.added_to_deck and G and G.hand then
                    if Porkify_safe_change_hand_size then
                        Porkify_safe_change_hand_size(v)
                    else
                        G.hand:change_size(v)
                    end
                end
            end
        end
    end
end

local function porkify_is_allowed_sticker_source(area)
    return G and area and (area == G.shop_jokers or area == G.pack_cards)
end

local function porkify_strip_forbidden_stickers(card, area)
    if not card or not card.config or not card.config.center then
        return card
    end

    local card_set = card.config.center.set
    if card_set ~= "Joker" then
        return card
    end

    if porkify_is_allowed_sticker_source(area) then
        return card
    end

    if not card.remove_sticker then
        return card
    end

    if card.ability and (card.ability.porkify_bulky or card.ability.bulky) then
        pcall(function() card:remove_sticker("porkify_bulky") end)
        pcall(function() card:remove_sticker("bulky") end)
    end

    if card.ability and (card.ability.porkify_cramped or card.ability.cramped) then
        pcall(function() card:remove_sticker("porkify_cramped") end)
        pcall(function() card:remove_sticker("cramped") end)
    end

    return card
end

if create_card and not Porkify_create_card_sticker_source_guard then
    Porkify_create_card_sticker_source_guard = create_card
    function create_card(_type, area, ...)
        local card = Porkify_create_card_sticker_source_guard(_type, area, ...)
        return porkify_strip_forbidden_stickers(card, area)
    end
end

if SMODS and SMODS.create_card and not Porkify_smods_create_card_sticker_source_guard then
    Porkify_smods_create_card_sticker_source_guard = SMODS.create_card
    SMODS.create_card = function(args, ...)
        local card = Porkify_smods_create_card_sticker_source_guard(args, ...)
        local area = type(args) == "table" and args.area or nil
        return porkify_strip_forbidden_stickers(card, area)
    end
end

if SMODS and SMODS.add_card and not Porkify_smods_add_card_sticker_source_guard then
    Porkify_smods_add_card_sticker_source_guard = SMODS.add_card
    SMODS.add_card = function(args, ...)
        local card = Porkify_smods_add_card_sticker_source_guard(args, ...)
        local area = type(args) == "table" and args.area or nil
        if not area and card then
            area = card.area
        end
        return porkify_strip_forbidden_stickers(card, area)
    end
end

SMODS.Sticker{
    key = "favorite",
    atlas = "CustomStickers",
    pos = { x = 4, y = 2 },
    badge_colour = HEX("E17AA4"),
    default_compat = false,
    sets = { Base = true, Enhanced = true, Default = true },
    needs_enable_flag = false,
    loc_txt = {
        name = "Favorite",
        label = "Favorite",
        text = {
            "One of your {C:attention}most-played{}",
            "playing cards this run"
        }
    },
    apply = apply_porkify_sticker
}

SMODS.Sticker{
    key = "bulky",
    atlas = "CustomStickers",
    pos = { x = 2, y = 2 },
    badge_colour = HEX("8E6E53"),
    default_compat = true,
    needs_enable_flag = true,
    loc_txt = {
        name = "Bulky",
        label = "Bulky",
        text = {
            "Uses {C:attention}2{} Joker Slots"
        }
    },
    config = {
        extra_slots_used = 1
    },
    apply = apply_porkify_sticker
}

SMODS.Sticker{
    key = "cramped",
    atlas = "CustomStickers",
    pos = { x = 3, y = 2 },
    badge_colour = HEX("5C7C9D"),
    default_compat = true,
    needs_enable_flag = true,
    loc_txt = {
        name = "Cramped",
        label = "Cramped",
        text = {
            "{C:red}-1{} Hand Size"
        }
    },
    config = {
        h_size = -1
    },
    apply = apply_porkify_sticker
}
