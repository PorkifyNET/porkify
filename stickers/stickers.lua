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

local function porkify_has_omega(card)
    return card and card.ability
        and (card.ability.porkify_omega or card.ability.omega)
end

-- Omega is challenge-safe Eternal: all of the normal sell/destruction checks
-- see it as Eternal, while effects which explicitly manipulate the vanilla
-- Eternal flag (notably Excalibur) cannot remove it.
if SMODS and type(SMODS.is_eternal) == "function" and not Porkify_smods_is_eternal_omega_ref then
    Porkify_smods_is_eternal_omega_ref = SMODS.is_eternal
    function SMODS.is_eternal(card, trigger)
        local result = Porkify_smods_is_eternal_omega_ref(card, trigger)
        if porkify_has_omega(card)
            and card.config and card.config.center
            and card.config.center.eternal_compat ~= false then
            return true
        end
        return result
    end
end

-- Eternal and Perishable are mutually exclusive. Card:set_perishable only
-- knows about the vanilla ability flag, so teach it about Omega as well.
if Card and type(Card.set_perishable) == "function" and not Porkify_card_set_perishable_omega_ref then
    Porkify_card_set_perishable_omega_ref = Card.set_perishable
    function Card:set_perishable(value, ...)
        if value and porkify_has_omega(self) then return end
        return Porkify_card_set_perishable_omega_ref(self, value, ...)
    end
end

-- Vanilla's challenge bootstrap calls set_eternal after creating each
-- starting Joker. By then Omega's creation hook has already run, so suppress
-- that redundant Eternal sticker.
if Card and type(Card.set_eternal) == "function" and not Porkify_card_set_eternal_omega_ref then
    Porkify_card_set_eternal_omega_ref = Card.set_eternal
    function Card:set_eternal(value, ...)
        if value and porkify_has_omega(self) then
            self.ability.eternal = nil
            return
        end
        local omega_ante = G and G.GAME and G.GAME.porkify_omega_eternal_ante
        if value and omega_ante
            and G.GAME.round_resets and G.GAME.round_resets.ante == omega_ante then
            local sticker = SMODS and SMODS.Stickers
                and (SMODS.Stickers.porkify_omega or SMODS.Stickers.omega)
            if sticker then
                sticker:apply(self, true)
                self.ability.eternal = nil
                return
            end
        end
        return Porkify_card_set_eternal_omega_ref(self, value, ...)
    end
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
    key = "omega",
    atlas = "CustomStickers",
    pos = { x = 0, y = 3 },
    badge_colour = HEX("7B55C7"),
    default_compat = true,
    needs_enable_flag = false,
    rate = 0,
    loc_txt = {
        name = "Omega",
        label = "Omega",
        text = {
            "Can't be sold",
            "or destroyed,",
            "Can't be removed",
            "by {C:porkify}Excalibur{}"
        }
    },
    should_apply = function(self, card, center)
        if not G or not G.GAME or not center or center.set ~= "Joker"
            or center.eternal_compat == false
            or (card.ability and card.ability.perishable) then
            return false
        end

        if G.GAME.modifiers and G.GAME.modifiers.all_omega then
            return true
        end

        local starters = G.GAME.porkify_omega_starters
        local remaining = starters and starters[center.key]
        if remaining and remaining > 0 then
            starters[center.key] = remaining - 1
            return true
        end
        return false
    end,
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
            "Uses {C:attention}2{} #1#"
        }
    },
    loc_vars = function(self, info_queue, card)
        local set = card and card.ability and card.ability.set
        return {vars = {(set == 'Default' or set == 'Enhanced') and 'Hand Size'
            or (card and card.ability and card.ability.consumeable and 'Consumable Slots') or 'Joker Slots'}}
    end,
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

-- Steamodded's built-in Pinned sticker normally points off the vanilla
-- sticker sheet because it has no artwork. Use Porkify's visible sprite while
-- retaining the built-in `card.pinned` behavior.
SMODS.Sticker:take_ownership("pinned", {
    atlas = "CustomStickers",
    pos = { x = 4, y = 1 },
    apply = function(self, card, val)
        card.pinned = val
        -- Pinned is stored directly on Card by the base game. Keeping a
        -- second ability flag makes Steamodded generate an unlocalized,
        -- duplicate `pinned` badge in addition to `pinned_left`.
        if card.ability then card.ability[self.key] = nil end
    end,
}, true)

-- Vanilla challenge setup and several effects assign `card.pinned` directly,
-- so those cards bypass Steamodded's normal ability-based sticker draw loop.
-- Running immediately before that loop also migrates the duplicate flag from
-- cards saved by older Porkify builds.
if SMODS.DrawStep then
    SMODS.DrawStep {
        key = "visible_pinned_sticker",
        order = 39,
        func = function(card)
            if card.ability then card.ability.pinned = nil end
            if not card.pinned then return end
            local sprite = G.shared_stickers and G.shared_stickers.pinned
            if not sprite then return end
            sprite.role.draw_major = card
            sprite:draw_shader("dissolve", nil, nil, nil, card.children.center)
            sprite:draw_shader("voucher", nil, card.ARGS.send_to_shader, nil, card.children.center)
        end,
        conditions = { vortex = false, facing = "front" },
    }
end
