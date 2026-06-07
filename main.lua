SMODS.Atlas({
    key = "modicon", 
    path = "ModIcon.png", 
    px = 34,
    py = 34,
    atlas_table = "ASSET_ATLAS"
})

SMODS.Atlas({
    key = "balatro", 
    path = "balatro.png", 
    px = 333,
    py = 216,
    prefix_config = { key = false },
    atlas_table = "ASSET_ATLAS"
})


SMODS.Atlas({
    key = "CustomJokers", 
    path = "CustomJokers.png", 
    px = 71,
    py = 95, 
    atlas_table = "ASSET_ATLAS"
})

SMODS.Atlas({
    key = "CustomDecks", 
    path = "CustomDecks.png", 
    px = 71,
    py = 95, 
    atlas_table = "ASSET_ATLAS"
})

SMODS.Atlas({
    key = "CustomVouchers", 
    path = "CustomVouchers.png", 
    px = 71,
    py = 95, 
    atlas_table = "ASSET_ATLAS"
})

SMODS.Atlas({
    key = "CustomChips",
    path = "chips.png",
    px = 29,
    py = 29,
    atlas_table = "ASSET_ATLAS"
})

SMODS.Atlas({
    key = "CustomStickers", 
    path = "CustomStickers.png", 
    px = 71,
    py = 95, 
    atlas_table = "ASSET_ATLAS",
    prefix_config = {
        atlas = false
    }
})

SMODS.Atlas({
    key = "CustomSeals",
    path = "CustomSeals.png",
    px = 71,
    py = 95,
    atlas_table = "ASSET_ATLAS",
    prefix_config = {
        atlas = false
    }
})

local NFS = require("nativefs")
local PORKIFY_MOD = SMODS.current_mod
to_big = to_big or function(a) return a end
lenient_bignum = lenient_bignum or function(a) return a end

local PORKIFY_CONFIG_DEFAULTS = {
    show_credit_badges = true
}

local function porkify_copy_defaults()
    return {
        show_credit_badges = PORKIFY_CONFIG_DEFAULTS.show_credit_badges
    }
end

local function porkify_get_config_path()
    local mod_path = PORKIFY_MOD and PORKIFY_MOD.path
    return mod_path and (mod_path .. "/config.lua") or "config.lua"
end

local function porkify_normalize_config(config)
    local normalized = porkify_copy_defaults()
    if type(config) == "table" then
        if config.show_credit_badges ~= nil then
            normalized.show_credit_badges = not not config.show_credit_badges
        end
    end
    return normalized
end

local function porkify_load_config()
    local raw = NFS.read(porkify_get_config_path())
    if not raw then
        return porkify_copy_defaults()
    end

    local ok, unpacked = pcall(STR_UNPACK, raw)
    if not ok then
        return porkify_copy_defaults()
    end

    return porkify_normalize_config(unpacked)
end

local function porkify_save_config()
    local config = porkify_normalize_config(PORKIFY_MOD and PORKIFY_MOD.config)
    if PORKIFY_MOD then
        PORKIFY_MOD.config = config
    end
    NFS.write(porkify_get_config_path(), STR_PACK(config))
end

if PORKIFY_MOD then
    PORKIFY_MOD.config = porkify_load_config()
    PORKIFY_MOD.load_mod_config = function()
        PORKIFY_MOD.config = porkify_load_config()
    end
    PORKIFY_MOD.save_mod_config = porkify_save_config
    PORKIFY_MOD.config_tab = function()
        local config = PORKIFY_MOD.config or porkify_copy_defaults()
        return {
            n = G.UIT.ROOT,
            config = { align = "tm", padding = 0.2, colour = G.C.CLEAR },
            nodes = {
                {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0.1 },
                    nodes = {
                        create_toggle({
                            label = "Show credit badges",
                            ref_table = config,
                            ref_value = "show_credit_badges",
                            info = {
                                "Toggles credit badges, such as Idea and Art.",
                                "This can help with visual clutter if you have",
                                "a lot of mods that add credit badges, or if you",
                                "just prefer a cleaner look.",
                                "(Food badges are not affected)"
                            },
                            active_colour = HEX("ff0095"),
                            callback = function()
                                porkify_save_config()
                            end
                        })
                    }
                }
            }
        }
    end
end

local porkify_game_start_run_ref = Game.start_run
function Game:start_run(args)
    Porkify_fixed_deck_pending = false
    Porkify_fixed_deck_opened = false
    local is_loaded_run = not not (args and args.savetext)

    if args and args.challenge then
        args.savetext = nil
        args.deck = { name = 'Challenge Deck' }
        args.challenge.deck = args.challenge.deck or {}
        args.challenge.deck.type = 'Challenge Deck'
    end

    local result = porkify_game_start_run_ref(self, args)

    local selected_back = G and G.GAME and G.GAME.selected_back
    local back_key = selected_back and (
        selected_back.key
        or (selected_back.effect and selected_back.effect.center and selected_back.effect.center.key)
        or (selected_back.config and selected_back.config.center and selected_back.config.center.key)
    )

    if not is_loaded_run and type(back_key) == "string" and back_key:find("fixed_deck", 1, true) ~= nil then
        Porkify_fixed_deck_pending = true
        Porkify_fixed_deck_opened = false
        if G and G.GAME then
            G.GAME.modifiers = G.GAME.modifiers or {}
            G.GAME.modifiers.no_shop_jokers = true
            G.GAME.joker_rate = 0
        end
    end

    return result
end

local function porkify_is_valid_voucher_key(key)
    local center = key and (
        (G and G.P_CENTERS and G.P_CENTERS[key]) or
        (SMODS and SMODS.Centers and SMODS.Centers[key])
    )
    return center and center.set == 'Voucher'
end

local porkify_back_apply_to_run_ref = Back.apply_to_run
function Back:apply_to_run(...)
    if self and self.effect and self.effect.config then
        local config = self.effect.config

        if config.voucher and not porkify_is_valid_voucher_key(config.voucher) then
            config.voucher = nil
        end
    end

    return porkify_back_apply_to_run_ref(self, ...)
end

local function load_jokers_folder()
    local mod_path = PORKIFY_MOD.path
    local jokers_path = mod_path .. "/jokers"
    local files = NFS.getDirectoryItemsInfo(jokers_path)

    for _, info in ipairs(files) do
        local file_name = info.name
        if file_name:sub(-4) == ".lua" then
            assert(SMODS.load_file("jokers/" .. file_name))()
        end
    end
end

local function load_stakes_folder()
    local mod_path = PORKIFY_MOD.path
    local stakes_path = mod_path .. "/stakes"
    local files = NFS.getDirectoryItemsInfo(stakes_path)

    for _, info in ipairs(files or {}) do
        local file_name = info.name
        if file_name:sub(-4) == ".lua" then
            assert(SMODS.load_file("stakes/" .. file_name))()
        end
    end
end

local function load_stickers_folder()
    local mod_path = PORKIFY_MOD.path
    local stickers_path = mod_path .. "/stickers"
    local files = NFS.getDirectoryItemsInfo(stickers_path)

    for _, info in ipairs(files or {}) do
        local file_name = info.name
        if file_name:sub(-4) == ".lua" then
            assert(SMODS.load_file("stickers/" .. file_name))()
        end
    end
end

local function load_seals_folder()
    local mod_path = PORKIFY_MOD.path
    local seals_path = mod_path .. "/seals"
    local ok, files = pcall(NFS.getDirectoryItemsInfo, seals_path)
    if not ok or not files then
        return
    end

    for _, info in ipairs(files or {}) do
        local file_name = info.name
        if file_name:sub(-4) == ".lua" then
            assert(SMODS.load_file("seals/" .. file_name))()
        end
    end
end

load_jokers_folder()
load_stickers_folder()
load_stakes_folder()

PORKIFY_FOOD_JOKERS = {
    ["j_gros_michel"] = true,
    ["j_egg"] = true,
    ["j_ice_cream"] = true,
    ["j_cavendish"] = true,
    ["j_turtle_bean"] = true,
    ["j_diet_cola"] = true,
    ["j_popcorn"] = true,
    ["j_ramen"] = true,
    ["j_selzer"] = true,
    ["j_porkify_cupofcoffee"] = true,
    ["j_porkify_hotdog"] = true,
    ["j_porkify_hamburger"] = true,
    ["j_porkify_taco"] = true,
    ["j_porkify_pizza"] = true,
    ["j_porkify_leek"] = true,
    ["j_porkify_fortunecookie"] = true,
    ["j_porkify_juicebox"] = true,
}

SMODS.ObjectType({
    key = "porkify_food",
    cards = PORKIFY_FOOD_JOKERS,
})

SMODS.current_mod.optional_features = function()
    return {
        cardareas = {} 
    }
end

SMODS.current_mod.set_debuff = function(card)
    local center = card and card.config and card.config.center
    local center_key = (center and center.key) or (card and card.config and card.config.center_key)
    if center_key ~= "m_porkify_revolving" then
        return false
    end

    local blind = G and G.GAME and G.GAME.blind
    local is_boss_blind = not not (
        blind and not blind.disabled and (
            blind.boss
            or (blind.config and blind.config.blind and blind.config.blind.boss)
        )
    )

    if is_boss_blind then
        return "prevent_debuff"
    end

    return false
end

local function porkify_is_resolute_card(card)
    local center = card and card.config and card.config.center
    local center_key = (center and center.key) or (card and card.config and card.config.center_key)
    return center_key == "m_porkify_revolving"
end

local function porkify_find_non_resolute_highlight_target(area)
    if not (area and area.cards) then
        return nil
    end

    local eligible = {}
    for _, hand_card in ipairs(area.cards) do
        if hand_card and not porkify_is_resolute_card(hand_card) and not hand_card.highlighted then
            eligible[#eligible + 1] = hand_card
        end
    end

    if #eligible == 0 then
        return nil
    end

    return pseudorandom_element(eligible, pseudoseed("porkify_cerulean_bell"))
end

local function porkify_cerulean_bell_active()
    local blind = G and G.GAME and G.GAME.blind
    local blind_key = blind and (blind.original_key or blind.key)
    return type(blind_key) == "string"
        and (
            blind_key == "cerulean_bell"
            or blind_key == "bl_cerulean_bell"
            or blind_key:find("cerulean", 1, true) ~= nil
            or blind_key:find("bell", 1, true) ~= nil
        )
end

local function porkify_card_has_bell_force_flag(card)
    if not card then
        return false
    end

    local suspects = {
        "forced_selection",
        "force_selected",
        "must_select",
        "forced_selected",
        "selected_by_bell"
    }

    for _, key in ipairs(suspects) do
        if card[key] or (card.ability and card.ability[key]) then
            return true
        end
    end

    return false
end

local function porkify_clear_bell_force_flags(card)
    if not card then
        return
    end

    local suspects = {
        "forced_selection",
        "force_selected",
        "must_select",
        "forced_selected",
        "selected_by_bell"
    }

    for _, key in ipairs(suspects) do
        card[key] = nil
        if card.ability then
            card.ability[key] = nil
        end
    end
end

local function porkify_fix_cerulean_bell_resolute_pick()
    if not (porkify_cerulean_bell_active() and G and G.hand and G.hand.highlighted) then
        return
    end

    local removed_any = false
    local highlighted_count = #G.hand.highlighted

    for i = #G.hand.highlighted, 1, -1 do
        local highlighted = G.hand.highlighted[i]
        if highlighted
            and porkify_is_resolute_card(highlighted)
            and (highlighted_count == 1 or porkify_card_has_bell_force_flag(highlighted)) then
            porkify_clear_bell_force_flags(highlighted)
            highlighted.highlighted = false
            table.remove(G.hand.highlighted, i)
            removed_any = true
        end
    end

    if removed_any and #G.hand.highlighted == 0 then
        local replacement = porkify_find_non_resolute_highlight_target(G.hand)
        if replacement then
            if Porkify_cardarea_add_to_highlighted_resolute then
                Porkify_cardarea_add_to_highlighted_resolute(G.hand, replacement, true)
            else
                G.hand:add_to_highlighted(replacement, true)
            end
        end
    end
end

local porkify_blind_stay_flipped_ref = Blind.stay_flipped
function Blind:stay_flipped(to_area, card, from_area)
    if porkify_is_resolute_card(card) then
        return false
    end
    return porkify_blind_stay_flipped_ref(self, to_area, card, from_area)
end

local porkify_blind_press_play_ref = Blind.press_play
function Blind:press_play()
    if not self.disabled and self.name == "The Hook" then
        local obj = self.config and self.config.blind
        if not (obj and obj.press_play and type(obj.press_play) == "function") then
            G.E_MANAGER:add_event(Event({ func = function()
                local any_selected = nil
                local eligible_cards = {}
                for _, hand_card in ipairs(G.hand.cards) do
                    if not porkify_is_resolute_card(hand_card) then
                        eligible_cards[#eligible_cards + 1] = hand_card
                    end
                end
                for _ = 1, math.min(2, #eligible_cards) do
                    local selected_card, card_key = pseudorandom_element(eligible_cards, pseudoseed("hook"))
                    G.hand:add_to_highlighted(selected_card, true)
                    table.remove(eligible_cards, card_key)
                    any_selected = true
                    play_sound("card1", 1)
                end
                if any_selected then
                    G.FUNCS.discard_cards_from_highlighted(nil, true)
                end
                return true
            end }))
            self.triggered = true
            delay(0.7)
            return true
        end
    end

    return porkify_blind_press_play_ref(self)
end

local porkify_cardarea_emplace_ref = CardArea.emplace
function CardArea:emplace(card, location, stay_flipped)
    local result = porkify_cardarea_emplace_ref(self, card, location, stay_flipped)
    if self == G.hand and porkify_is_resolute_card(card) and card and card.facing == 'back' then
        card:flip()
        card.ability.wheel_flipped = nil
    end
    return result
end

if CardArea and type(CardArea.add_to_highlighted) == "function" and not Porkify_cardarea_add_to_highlighted_resolute then
    Porkify_cardarea_add_to_highlighted_resolute = CardArea.add_to_highlighted
    function CardArea:add_to_highlighted(card, silent)
        if self == G.hand
            and porkify_cerulean_bell_active()
            and porkify_is_resolute_card(card) then
            local replacement = porkify_find_non_resolute_highlight_target(self)
            if replacement then
                return Porkify_cardarea_add_to_highlighted_resolute(self, replacement, silent)
            end
            return
        end

        return Porkify_cardarea_add_to_highlighted_resolute(self, card, silent)
    end
end

if JokerDisplay then
    SMODS.load_file("joker_display_definitions.lua")()
end

SMODS.Atlas({
    key = "CustomConsumables", 
    path = "CustomConsumables.png", 
    px = 71,
    py = 95, 
    atlas_table = "ASSET_ATLAS"
})

SMODS.Atlas({
    key = "CustomBoosters", 
    path = "CustomBoosters.png", 
    px = 71,
    py = 95, 
    atlas_table = "ASSET_ATLAS"
})

SMODS.Atlas({
    key = "CustomBlinds",
    path = "CustomBlinds.png",
    px = 34,
    py = 34,
    atlas_table = "ANIMATION_ATLAS"
})

SMODS.Atlas({
    key = "CustomEnhancements",
    path = "CustomEnhancements.png",
    px = 71,
    py = 95,
    atlas_table = "ASSET_ATLAS"
})

if create_UIBox_blind_popup and not Porkify_create_UIBox_blind_popup then
    Porkify_create_UIBox_blind_popup = create_UIBox_blind_popup
    function create_UIBox_blind_popup(blind, discovered, vars)
        local popup = Porkify_create_UIBox_blind_popup(blind, discovered, vars)
        local blind_key = blind and (blind.original_key or blind.key)

        if blind_key == "ceiling" and discovered and popup and popup.nodes and popup.nodes[2]
            and popup.nodes[2].nodes and popup.nodes[2].nodes[1]
            and popup.nodes[2].nodes[1].nodes and popup.nodes[2].nodes[1].nodes[3] then
            popup.nodes[2].nodes[1].nodes[3].nodes = {
                {n = G.UIT.T, config = {text = "No rewards or interest", scale = 0.35, colour = G.C.UI.TEXT_DARK}}
            }
        end

        return popup
    end
end

local function porkify_resolve_badge_colour(value, fallback)
    if type(value) == "table" then
        return value
    end
    if type(value) == "string" and value ~= "" then
        local ok, colour = pcall(HEX, value)
        if ok and colour then
            return colour
        end
    end
    return fallback
end

local function porkify_show_credit_badges()
    local config = PORKIFY_MOD and PORKIFY_MOD.config
    if type(config) ~= "table" then
        return PORKIFY_CONFIG_DEFAULTS.show_credit_badges
    end
    if config.show_credit_badges == nil then
        return PORKIFY_CONFIG_DEFAULTS.show_credit_badges
    end
    return not not config.show_credit_badges
end

local function porkify_is_credit_badge_text(text)
    if type(text) ~= "string" then
        return false
    end

    local lowered = text:lower()
    return lowered:match("^idea:%s*") ~= nil
        or lowered:match("^art:%s*") ~= nil
end

local function porkify_apply_credit_badges(obj, badges)
    local credit_badges = obj and (obj.credit_badges or obj.porkify_credit_badges)
    if type(credit_badges) ~= "table" then
        return
    end

    for _, badge in ipairs(credit_badges) do
        local text, colour, text_colour, scale

        if type(badge) == "string" then
            text = badge
        elseif type(badge) == "table" then
            text = badge.text or badge.label
            colour = porkify_resolve_badge_colour(badge.colour or badge.color, HEX("5B2A86"))
            text_colour = porkify_resolve_badge_colour(badge.text_colour or badge.text_color, G.C.WHITE)
            scale = badge.scale
        end

        if text and (porkify_show_credit_badges() or not porkify_is_credit_badge_text(text)) then
            badges[#badges + 1] = create_badge(
                text,
                colour or HEX("5B2A86"),
                text_colour or G.C.WHITE,
                scale or 0.9
            )
        end
    end
end

local function porkify_apply_food_badge(obj, badges)
    if type(obj) ~= "table" or type(badges) ~= "table" then
        return
    end

    local key = obj.key
    local food_keys = PORKIFY_FOOD_JOKERS or {}
    local is_food = key and (
        food_keys[key]
        or food_keys["j_" .. key]
        or food_keys["j_porkify_" .. key]
    )

    if not is_food then
        return
    end

    badges[#badges + 1] = create_badge(
        "Food",
        HEX("C83F22"),
        G.C.WHITE,
        0.9
    )
end

function Porkify_attach_credit_badges(obj)
    if type(obj) ~= "table" or obj.porkify_badges_wrapped then
        return obj
    end

    -- Example:
    -- credit_badges = {
    --   { text = "Idea: PorkyLIVE", colour = "7A2D8C" },
    --   { text = "Art: NameHere", colour = "C65D7B", scale = 0.85 }
    -- }
    local original_set_badges = obj.set_badges
    obj.set_badges = function(self, card, badges)
        if type(original_set_badges) == "function" then
            original_set_badges(self, card, badges)
        end
        porkify_apply_food_badge(self, badges)
        porkify_apply_credit_badges(self, badges)
    end
    obj.porkify_badges_wrapped = true

    return obj
end

local function Porkify_wrap_badge_constructor(name)
    if not (SMODS and type(SMODS[name]) == "function") then
        return
    end

    local wrapped_flag = "porkify_badge_constructor_wrapped_" .. name
    if SMODS[wrapped_flag] then
        return
    end

    local original_constructor = SMODS[name]
    SMODS[name] = function(definition)
        if type(definition) == "table" then
            Porkify_attach_credit_badges(definition)
        end
        return original_constructor(definition)
    end
    SMODS[wrapped_flag] = true
end

Porkify_wrap_badge_constructor("Back")
Porkify_wrap_badge_constructor("Seal")

if generate_card_ui and not Porkify_generate_card_ui then
    Porkify_generate_card_ui = generate_card_ui
    function generate_card_ui(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end, card)
        local ability = card and card.ability
        local has_bulky = ability and (ability.porkify_bulky or ability.bulky)
        local original_extra_slots_used = has_bulky and ability.extra_slots_used or nil

        if _c then
            Porkify_attach_credit_badges(_c)
        end

        if has_bulky then
            ability.extra_slots_used = 0
        end

        local result = Porkify_generate_card_ui(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end, card)

        if has_bulky then
            ability.extra_slots_used = original_extra_slots_used
        end

        return result
    end
end

local function porkify_pack_actions_enabled(pack)
    return pack and pack.porkify_pack_actions and pack.group_key == "porkify_boosters"
end

local function porkify_pack_is_unskippable(pack)
    return not not (pack and pack.porkify_unskippable)
end

local PORKIFY_FINAL_BOSS_KEYS = {
    "bl_final_acorn",
    "bl_final_leaf",
    "bl_final_vessel",
    "bl_final_heart",
    "bl_final_bell"
}

local function porkify_is_final_boss_key(key)
    if type(key) ~= "string" then
        return false
    end

    for i = 1, #PORKIFY_FINAL_BOSS_KEYS do
        if PORKIFY_FINAL_BOSS_KEYS[i] == key then
            return true
        end
    end

    return false
end

local function porkify_choose_final_boss_key()
    return pseudorandom_element(
        PORKIFY_FINAL_BOSS_KEYS,
        pseudoseed("porkify_final_boss_" .. tostring((G and G.GAME and G.GAME.round) or 0))
    )
end

local function porkify_ensure_in_playing_cards(pc)
    if not (G and G.playing_cards and pc) then
        return
    end

    for i = 1, #G.playing_cards do
        if G.playing_cards[i] == pc then
            return
        end
    end

    table.insert(G.playing_cards, pc)
end

function Porkify_add_plain_playing_cards(count)
    if not (G and G.playing_cards and #G.playing_cards > 0 and count and count > 0) then
        return 0
    end

    local added = 0

    for i = 1, count do
        local source = pseudorandom_element(
            G.playing_cards,
            pseudoseed("porkify_plain_playing_card_" .. tostring(i))
        ) or G.playing_cards[1]

        if source then
            local copy = copy_card(source, nil, nil, nil, false)
            if copy then
                if copy.set_ability and G.P_CENTERS and G.P_CENTERS.c_base then
                    copy:set_ability(G.P_CENTERS.c_base, nil, true)
                end
                if copy.set_seal then
                    copy:set_seal(nil, nil, true)
                end
                if copy.set_edition then
                    copy:set_edition(nil, true)
                end

                copy.ability = copy.ability or {}
                copy.ability.perma_bonus = 0
                copy.ability.perma_mult = 0
                copy.ability.perma_x_mult = 0
                copy.ability.perma_p_dollars = 0

                if copy.start_materialize then
                    copy:start_materialize()
                end
                if copy.add_to_deck then
                    copy:add_to_deck()
                end
                porkify_ensure_in_playing_cards(copy)

                if G.deck and G.deck.emplace then
                    G.deck:emplace(copy)
                elseif G.hand and G.hand.emplace then
                    G.hand:emplace(copy)
                end

                added = added + 1
            end
        end
    end

    return added
end

function Porkify_zero_money()
    if not (G and G.GAME) then
        return
    end

    local current = tonumber(G.GAME.dollars) or 0
    if current > 0 then
        ease_dollars(-current, true)
    end
end

function Porkify_scale_current_blind(mult)
    if not (G and G.GAME and G.GAME.blind and type(mult) == "number" and mult > 0) then
        return
    end

    G.GAME.blind.chips = math.max(1, math.floor((G.GAME.blind.chips or 1) * mult))
    G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
    if G.HUD_blind then
        G.HUD_blind:recalculate()
    end
end

function Porkify_add_no_reward_blinds(count)
    if not (G and G.GAME and type(count) == "number" and count > 0) then
        return
    end

    G.GAME.modifiers = G.GAME.modifiers or {}
    if G.GAME.porkify_base_no_reward == nil then
        G.GAME.porkify_base_no_reward = not not G.GAME.modifiers.no_reward
    end
    G.GAME.porkify_no_reward_blinds_remaining = (G.GAME.porkify_no_reward_blinds_remaining or 0) + count
    G.GAME.modifiers.no_reward = true
end

local function porkify_consume_no_reward_blind()
    if not (G and G.GAME and (G.GAME.porkify_no_reward_blinds_remaining or 0) > 0) then
        return
    end

    G.GAME.porkify_no_reward_blinds_remaining = G.GAME.porkify_no_reward_blinds_remaining - 1
    if G.GAME.porkify_no_reward_blinds_remaining <= 0 then
        G.GAME.porkify_no_reward_blinds_remaining = 0
        G.GAME.modifiers = G.GAME.modifiers or {}
        G.GAME.modifiers.no_reward = not not G.GAME.porkify_base_no_reward
    end
end

local function porkify_apply_final_boss_choice(choice, key)
    if type(choice) == "string" then
        return key
    end

    if type(choice) ~= "table" then
        return choice
    end

    local blind_def = G and G.P_BLINDS and G.P_BLINDS[key]
    choice.key = key
    choice.original_key = key
    choice.boss = true
    choice.config = choice.config or {}
    if blind_def then
        choice.config.blind = blind_def
        choice.name = blind_def.name or choice.name
    elseif choice.config.blind then
        choice.config.blind.key = key
    end
    return choice
end

function Porkify_force_next_boss_final()
    if not (G and G.GAME) then
        return
    end

    G.GAME.porkify_force_final_boss_pending = true
    if G.GAME.blind_choices and G.GAME.blind_choices.Boss then
        local key = porkify_choose_final_boss_key()
        G.GAME.blind_choices.Boss = porkify_apply_final_boss_choice(G.GAME.blind_choices.Boss, key)
    end
end

local function porkify_apply_pending_final_boss_to_active_blind()
    if not (G and G.GAME and G.GAME.porkify_force_final_boss_pending and G.GAME.blind) then
        return
    end

    local blind = G.GAME.blind
    local active_key = blind.original_key or blind.key or (blind.config and blind.config.blind and blind.config.blind.key)
    if not blind.boss or porkify_is_final_boss_key(active_key) then
        return
    end

    local key = porkify_choose_final_boss_key()
    local blind_def = G.P_BLINDS and G.P_BLINDS[key]
    blind.key = key
    blind.original_key = key
    blind.boss = true
    blind.disabled = false
    blind.config = blind.config or {}
    if blind_def then
        blind.config.blind = blind_def
        blind.name = blind_def.name or blind.name
    elseif blind.config.blind then
        blind.config.blind.key = key
    end
    if G.HUD_blind then
        G.HUD_blind:recalculate()
    end
    G.GAME.porkify_force_final_boss_pending = nil
end

function Porkify_create_negative_mr_bones()
    if not (SMODS and SMODS.create_card and G and G.jokers) then
        return nil
    end

    local new_joker = SMODS.create_card({
        set = 'Joker',
        key = 'j_mr_bones',
        area = G.jokers,
        skip_materialize = true,
        soulable = true,
        no_edition = true,
        bypass_discovery_center = true
    })

    if not new_joker then
        return nil
    end

    if new_joker.set_edition then
        new_joker:set_edition('e_negative', true)
    end
    if new_joker.start_materialize then
        new_joker:start_materialize()
    end
    if new_joker.add_to_deck then
        new_joker:add_to_deck()
    end
    if G.jokers.emplace then
        G.jokers:emplace(new_joker)
    end

    return new_joker
end

function Porkify_pick_random_enhancement_key()
    local pool = {}
    if G and G.P_CENTER_POOLS and (G.P_CENTER_POOLS.Enhanced or G.P_CENTER_POOLS.Enhancement) then
        local p = G.P_CENTER_POOLS.Enhanced or G.P_CENTER_POOLS.Enhancement
        for _, v in pairs(p) do
            if v and v.key and v.key ~= 'c_base' then
                pool[#pool + 1] = v.key
            end
        end
    elseif G and G.P_CENTERS then
        for k, v in pairs(G.P_CENTERS) do
            if v and (v.set == 'Enhanced' or v.set == 'Enhancement') and k ~= 'c_base' then
                pool[#pool + 1] = k
            end
        end
    end
    if #pool == 0 then
        return nil
    end
    return pseudorandom_element(pool, pseudoseed("porkify_random_enhancement"))
end

local function porkify_try_open_fixed_deck_pack()
    if not (G and G.GAME and G.STATES) then
        return
    end

    if not Porkify_fixed_deck_pending or Porkify_fixed_deck_opened then
        return
    end

    local selected_back = G.GAME.selected_back
    local back_key = selected_back and (
        selected_back.key
        or (selected_back.effect and selected_back.effect.center and selected_back.effect.center.key)
        or (selected_back.config and selected_back.config.center and selected_back.config.center.key)
    )

    if type(back_key) ~= "string" or not back_key:find("fixed_deck", 1, true) then
        return
    end

    if G.STATE ~= G.STATES.BLIND_SELECT or not G.blind_select or booster_obj then
        return
    end

    local booster_key = "p_porkify_giga_buffoon_pack"
    local center = G.P_CENTERS and G.P_CENTERS[booster_key]
    if not center then
        return
    end

    local pack = SMODS.create_card({
        set = "Booster",
        key = booster_key,
        area = nil,
        no_edition = true,
        skip_materialize = true,
        bypass_discovery_center = true
    })

    if not pack then
        return
    end

    if G.blind_select and not G.blind_select.alignment.offset.py then
        G.blind_select.alignment.offset.py = G.blind_select.alignment.offset.y
        G.blind_select.alignment.offset.y = G.ROOM.T.y + 39
    end

    G.GAME.PACK_INTERRUPT = G.STATE
    Porkify_fixed_deck_opened = true
    Porkify_fixed_deck_pending = false

    pack.cost = 0
    pack.from_tag = true

    if G.ROOM and G.ROOM.T and pack.T then
        pack.T.x = G.ROOM.T.x + G.ROOM.T.w * 0.5 - pack.T.w * 0.5
        pack.T.y = G.ROOM.T.y + G.ROOM.T.h * 0.5 - pack.T.h * 0.5
    end

    if pack.open then
        pack:open()
    end
end

local function porkify_ensure_highlight_tables()
    local areas = {
        G and G.hand,
        G and G.jokers,
        G and G.consumeables,
        G and G.pack_cards
    }

    for i = 1, #areas do
        local area = areas[i]
        if area and area.highlighted == nil then
            area.highlighted = {}
        end
    end
end

local function porkify_prepare_consumable_state(card)
    if not card then
        return
    end

    porkify_ensure_highlight_tables()

    if card.eligible_strength_jokers == nil then
        card.eligible_strength_jokers = {}
    end
    if card.eligible_editionless_jokers == nil then
        card.eligible_editionless_jokers = {}
    end
end

local function porkify_normalize_consumable_highlight_bounds(card)
    local center = card and card.config and card.config.center
    local cfg = center and center.config
    if not (center and cfg) then
        return center
    end

    if center.min_highlighted == nil and cfg.min_highlighted ~= nil then
        center.min_highlighted = cfg.min_highlighted
    end
    if center.max_highlighted == nil and cfg.max_highlighted ~= nil then
        center.max_highlighted = cfg.max_highlighted
    end

    return center
end

local function porkify_can_use_pack_consumeable(card)
    if not card then
        return false
    end

    porkify_prepare_consumable_state(card)
    porkify_install_safe_can_use_consumeable_patch()

    local center = porkify_normalize_consumable_highlight_bounds(card)
    if center and type(center.can_use) == "function" then
        local ok, result = pcall(center.can_use, center, card)
        return ok and result == true
    end

    local ok, result = pcall(function()
        return card:can_use_consumeable()
    end)
    return ok and result == true
end

function porkify_install_safe_can_use_consumeable_patch()
    if not (Card and Card.can_use_consumeable) then
        return
    end

    if Porkify_safe_can_use_consumeable == nil then
        Porkify_safe_can_use_consumeable = function(self, any_state, skip_check)
            porkify_prepare_consumable_state(self)
            return Porkify_can_use_consumeable(self, any_state, skip_check)
        end
    end

    if Card.can_use_consumeable == Porkify_safe_can_use_consumeable then
        return
    end

    Porkify_can_use_consumeable = Card.can_use_consumeable
    Card.can_use_consumeable = Porkify_safe_can_use_consumeable
end

porkify_install_safe_can_use_consumeable_patch()

if love and love.update and not Porkify_love_update then
    Porkify_love_update = love.update
    love.update = function(dt)
        porkify_ensure_highlight_tables()
        porkify_fix_cerulean_bell_resolute_pick()
        if porkify_install_draw_priority_patch then
            porkify_install_draw_priority_patch()
        end
        porkify_install_safe_can_use_consumeable_patch()
        porkify_install_safe_can_buy_and_use_patch()
        porkify_install_safe_can_skip_booster_patch()
        porkify_try_open_fixed_deck_pack()
        return Porkify_love_update(dt)
    end
end

function porkify_install_safe_can_buy_and_use_patch()
    if not (G and G.FUNCS and G.FUNCS.can_buy_and_use) then
        return
    end

    if Porkify_safe_can_buy_and_use == nil then
        Porkify_safe_can_buy_and_use = function(e)
            local card = e and e.config and e.config.ref_table
            if not card or card.REMOVED then
                if e and e.UIBox and e.UIBox.states then
                    e.UIBox.states.visible = false
                end
                if e and e.config then
                    e.config.colour = G.C.UI.BACKGROUND_INACTIVE
                    e.config.button = nil
                end
                return
            end

            porkify_prepare_consumable_state(card)
            return Porkify_can_buy_and_use(e)
        end
    end

    if G.FUNCS.can_buy_and_use == Porkify_safe_can_buy_and_use then
        return
    end

    Porkify_can_buy_and_use = G.FUNCS.can_buy_and_use
    G.FUNCS.can_buy_and_use = Porkify_safe_can_buy_and_use
end

porkify_install_safe_can_buy_and_use_patch()

function porkify_install_safe_can_skip_booster_patch()
    if not (G and G.FUNCS and G.FUNCS.can_skip_booster) then
        return
    end

    if Porkify_safe_can_skip_booster == nil then
        Porkify_safe_can_skip_booster = function(e)
            if porkify_pack_is_unskippable(booster_obj) then
                if e and e.config then
                    e.config.colour = G.C.UI.BACKGROUND_INACTIVE
                    e.config.button = nil
                end
                return
            end

            return Porkify_can_skip_booster(e)
        end
    end

    if G.FUNCS.can_skip_booster == Porkify_safe_can_skip_booster then
        return
    end

    Porkify_can_skip_booster = G.FUNCS.can_skip_booster
    G.FUNCS.can_skip_booster = Porkify_safe_can_skip_booster
end

porkify_install_safe_can_skip_booster_patch()

if G and G.FUNCS and not G.FUNCS.porkify_can_store_pack_card then
    G.FUNCS.porkify_can_store_pack_card = function(e)
        G.FUNCS.can_select_from_booster(e)
        if e.config.button then
            e.config.button = 'porkify_store_pack_card'
        end
    end

    G.FUNCS.porkify_can_use_pack_card = function(e)
        local card = e.config.ref_table
        if porkify_can_use_pack_consumeable(card) then
            e.config.colour = G.C.RED
            e.config.button = 'porkify_use_pack_card'
        else
            e.config.colour = G.C.UI.BACKGROUND_INACTIVE
            e.config.button = nil
        end
    end

    G.FUNCS.porkify_store_pack_card = function(e, mute, nosave)
        return G.FUNCS.use_card(e, mute, nosave)
    end

    G.FUNCS.porkify_use_pack_card = function(e, mute, nosave)
        local pack = booster_obj
        if not porkify_pack_actions_enabled(pack) then
            return G.FUNCS.use_card(e, mute, nosave)
        end

        local original_select_card = pack.select_card
        pack.select_card = nil

        local ok, err = pcall(function()
            G.FUNCS.use_card(e, mute, nosave)
        end)

        pack.select_card = original_select_card

        if not ok then
            error(err)
        end
    end
end

if G and G.UIDEF and G.UIDEF.use_and_sell_buttons and not Porkify_use_and_sell_buttons then
    Porkify_use_and_sell_buttons = G.UIDEF.use_and_sell_buttons
    function G.UIDEF.use_and_sell_buttons(card)
        porkify_prepare_consumable_state(card)
        porkify_install_safe_can_use_consumeable_patch()
        porkify_install_safe_can_buy_and_use_patch()

        if card
            and card.ability
            and card.ability.consumeable
            and card.ability.set == 'porkify'
            and card.area == G.pack_cards
            and G.pack_cards
            and booster_obj
            and porkify_pack_actions_enabled(booster_obj) then
            return {
                n = G.UIT.ROOT,
                config = { padding = 0, colour = G.C.CLEAR },
                nodes = {
                    {
                        n = G.UIT.R,
                        config = { align = "bm", padding = 0.04 },
                        nodes = {
                            {
                                n = G.UIT.C,
                                config = {
                                    ref_table = card,
                                    r = 0.08,
                                    padding = 0.08,
                                    align = "bm",
                                    minw = 0.42 * card.T.w,
                                    maxw = 0.48 * card.T.w,
                                    minh = 0.22 * card.T.h,
                                    hover = true,
                                    shadow = true,
                                    colour = G.C.UI.BACKGROUND_INACTIVE,
                                    one_press = true,
                                    button = 'porkify_use_pack_card',
                                    func = 'porkify_can_use_pack_card'
                                },
                                nodes = {
                                    { n = G.UIT.T, config = { text = localize('b_use'), colour = G.C.UI.TEXT_LIGHT, scale = 0.42, shadow = true } }
                                }
                            },
                            {
                                n = G.UIT.B,
                                config = { w = 0.08, h = 0.1 }
                            },
                            {
                                n = G.UIT.C,
                                config = {
                                    ref_table = card,
                                    r = 0.08,
                                    padding = 0.08,
                                    align = "bm",
                                    minw = 0.42 * card.T.w,
                                    maxw = 0.48 * card.T.w,
                                    minh = 0.22 * card.T.h,
                                    hover = true,
                                    shadow = true,
                                    colour = G.C.UI.BACKGROUND_INACTIVE,
                                    one_press = true,
                                    button = 'porkify_store_pack_card',
                                    func = 'porkify_can_store_pack_card'
                                },
                                nodes = {
                                    { n = G.UIT.T, config = { text = "STORE", colour = G.C.UI.TEXT_LIGHT, scale = 0.34, shadow = true } }
                                }
                            }
                        }
                    }
                }
            }
        end

        return Porkify_use_and_sell_buttons(card)
    end
end

local function porkify_active_blind_is(key)
    local blind = G and G.GAME and G.GAME.blind
    if not blind then
        return false
    end

    local blind_key = blind.original_key or blind.key
    return blind_key == key or blind_key == ("bl_" .. key) or blind_key == ("bl_porkify_" .. key)
end

local function porkify_selected_back_key()
    local selected_back = G and G.GAME and G.GAME.selected_back
    if not selected_back then
        return nil
    end

    return selected_back.key
        or (selected_back.effect and selected_back.effect.center and selected_back.effect.center.key)
        or (selected_back.config and selected_back.config.center and selected_back.config.center.key)
end

local function porkify_selected_back_matches(key)
    local back_key = porkify_selected_back_key()
    if type(back_key) ~= "string" then
        return false
    end

    return back_key == key
        or back_key == ("b_" .. key)
        or back_key == ("b_porkify_" .. key)
        or back_key:find(key, 1, true) ~= nil
end

local porkify_get_pack_ref = get_pack
function get_pack(_key, _type)
    if porkify_selected_back_matches("fixed_deck") and _key == "shop_pack" and not _type and G and G.GAME then
        local buffoon_keys = {
            "p_buffoon_normal_1",
            "p_buffoon_normal_2",
            "p_buffoon_jumbo_1",
            "p_buffoon_mega_1",
            "p_porkify_giga_buffoon_pack"
        }

        local original_first_shop_buffoon = G.GAME.first_shop_buffoon
        local banned_keys = G.GAME.banned_keys or {}
        G.GAME.banned_keys = banned_keys

        local previous_bans = {}
        for i = 1, #buffoon_keys do
            local pack_key = buffoon_keys[i]
            previous_bans[pack_key] = banned_keys[pack_key]
            banned_keys[pack_key] = true
        end

        G.GAME.first_shop_buffoon = true

        local ok, result = pcall(porkify_get_pack_ref, _key, _type)

        G.GAME.first_shop_buffoon = original_first_shop_buffoon
        for i = 1, #buffoon_keys do
            local pack_key = buffoon_keys[i]
            banned_keys[pack_key] = previous_bans[pack_key]
        end

        if ok then
            return result
        end

        error(result)
    end

    return porkify_get_pack_ref(_key, _type)
end

local function porkify_has_deck_modifier(key)
    local modifiers = G and G.GAME and G.GAME.modifiers
    return type(modifiers) == "table" and modifiers[key] == true
end

local PORKIFY_BOSS_BLIND_GROUPS = {
    evens_odds = {
        evens = true,
        odds = true
    },
    plunger_prideful_twins = {
        plunger = true,
        prideful = true,
        twins = true
    }
}

local function porkify_get_boss_group_for_key(key)
    if type(key) ~= "string" then
        return nil
    end

    for group_key, members in pairs(PORKIFY_BOSS_BLIND_GROUPS) do
        if members[key] then
            return group_key
        end
    end
end

function Porkify_mark_boss_blind_seen(key)
    local group_key = porkify_get_boss_group_for_key(key)
    if not (group_key and G and G.GAME) then
        return
    end

    G.GAME.porkify_seen_boss_groups = G.GAME.porkify_seen_boss_groups or {}
    G.GAME.porkify_seen_boss_groups[group_key] = true
end

function Porkify_boss_blind_group_available(key)
    local group_key = porkify_get_boss_group_for_key(key)
    if not group_key then
        return true
    end

    local seen_groups = G and G.GAME and G.GAME.porkify_seen_boss_groups
    return not (type(seen_groups) == "table" and seen_groups[group_key])
end

function Porkify_ensure_serpent_safe_hand_size()
    return false
end

function Porkify_safe_change_hand_size(delta)
    if not (G and G.hand and type(delta) == "number" and delta ~= 0) then
        return
    end

    G.hand:change_size(delta)
end

local function porkify_is_serpent_key(value)
    return value == "serpent" or value == "bl_serpent"
end

local function porkify_remove_serpent_entry(root)
    if type(root) ~= "table" then
        return
    end

    root.serpent = nil
    root.bl_serpent = nil

    for k, v in pairs(root) do
        if type(v) == "table" then
            local key = rawget(v, "key") or rawget(v, "original_key")
            local config = rawget(v, "config")
            local blind_cfg = type(config) == "table" and rawget(config, "blind") or nil
            local config_key = type(blind_cfg) == "table" and rawget(blind_cfg, "key") or nil
            if porkify_is_serpent_key(key) or porkify_is_serpent_key(config_key) then
                root[k] = nil
            end
        elseif type(v) == "string" and porkify_is_serpent_key(v) then
            root[k] = nil
        end
    end
end

local function porkify_remove_serpent_from_game()
    if G then
        porkify_remove_serpent_entry(G.P_BLINDS)
        if G.GAME then
            porkify_remove_serpent_entry(G.GAME.blind_choices)
            porkify_remove_serpent_entry(G.GAME.round_resets)
        end
    end

    local active = G and G.GAME and G.GAME.blind
    local active_key = active and (active.original_key or active.key)
    if active and porkify_is_serpent_key(active_key) then
        active.disabled = true
        active.key = "bl_porkify_removed_serpent"
        active.original_key = "porkify_removed_serpent"
        if active.config and active.config.blind then
            active.config.blind.key = "bl_porkify_removed_serpent"
        end
    end
end

if SMODS and SMODS.get_probability_vars and not Porkify_get_probability_vars then
    Porkify_get_probability_vars = SMODS.get_probability_vars
    SMODS.get_probability_vars = function(card, numerator, denominator, identifier)
        local current_round = G and G.GAME and G.GAME.current_round
        if current_round
            and current_round.porkify_dice_probability_active then
            local guaranteed = math.max(tonumber(numerator) or 1, 1)
            return guaranteed, guaranteed
        end
        local n, d = Porkify_get_probability_vars(card, numerator, denominator, identifier)
        if porkify_active_blind_is("toll") and not porkify_is_resolute_card(card) then
            return 0, d
        end
        return n, d
    end
end

if SMODS and SMODS.pseudorandom_probability and not Porkify_pseudorandom_probability then
    Porkify_pseudorandom_probability = SMODS.pseudorandom_probability
    SMODS.pseudorandom_probability = function(card, seed, numerator, denominator, identifier, trigger)
        local current_round = G and G.GAME and G.GAME.current_round
        if current_round
            and current_round.porkify_dice_probability_active then
            return true
        end
        if porkify_active_blind_is("toll") and not porkify_is_resolute_card(card) then
            return false
        end
        return Porkify_pseudorandom_probability(card, seed, numerator, denominator, identifier, trigger)
    end
end

if type(get_blind_amount) == "function" and not Porkify_get_blind_amount then
    Porkify_get_blind_amount = get_blind_amount
    function get_blind_amount(ante)
        local amount = Porkify_get_blind_amount(ante)
        if porkify_selected_back_matches("speedrunner_deck") then
            local ok, scaled = pcall(function()
                return amount / 2
            end)
            if ok and scaled ~= nil then
                if type(scaled) == "number" then
                    return math.floor(scaled)
                end
                return scaled
            end
        end
        return amount
    end
end

local function porkify_safe_draw_from_deck_to_hand_impl(original, ...)
    local args = { ... }
    local hand_space = args[2]
    local cards_to_draw = args[3]

    if type(hand_space) == "number" and type(cards_to_draw) == "table" then
        local compacted = {}
        local max_index = 0
        for k, _ in pairs(cards_to_draw) do
            if type(k) == "number" and k > max_index then
                max_index = k
            end
        end
        max_index = math.max(max_index, hand_space)

        for i = 1, max_index do
            local queued = rawget(cards_to_draw, i)
            if queued then
                compacted[#compacted + 1] = queued
            end
        end

        if #compacted ~= max_index then
            args[3] = compacted
            cards_to_draw = compacted
        end

        if hand_space > 0 and #cards_to_draw > 1 then
            local gravitas_first = {}
            local normal_draws = {}

            for i = 1, #cards_to_draw do
                local queued = cards_to_draw[i]
                if queued and porkify_is_eligible_gravitas_draw(queued) then
                    gravitas_first[#gravitas_first + 1] = queued
                elseif queued then
                    normal_draws[#normal_draws + 1] = queued
                end
            end

            if #gravitas_first > 0 then
                local reordered = {}
                for i = 1, #gravitas_first do
                    reordered[#reordered + 1] = gravitas_first[i]
                end
                for i = 1, #normal_draws do
                    reordered[#reordered + 1] = normal_draws[i]
                end
                args[3] = reordered
                cards_to_draw = reordered
            end
        end

        if hand_space > #cards_to_draw then
            args[2] = #cards_to_draw
        end
    end

    return original(unpack(args))
end

local porkify_safe_draw_wrappers = setmetatable({}, { __mode = "k" })

local function porkify_make_safe_draw_wrapper(original)
    if type(original) ~= "function" then
        return original
    end
    if porkify_safe_draw_wrappers[original] then
        return original
    end
    local info = debug and debug.getinfo and debug.getinfo(original, "S")
    if info and info.short_src and not tostring(info.short_src):find("state_events.lua", 1, true) then
        return original
    end

    local wrapped = function(...)
        return porkify_safe_draw_from_deck_to_hand_impl(original, ...)
    end
    porkify_safe_draw_wrappers[wrapped] = true
    return wrapped
end

local function porkify_patch_draw_refs_in_table(root, seen, depth)
    if type(root) ~= "table" or seen[root] or depth > 4 then
        return
    end
    seen[root] = true

    for k, v in pairs(root) do
        if k == "draw_from_deck_to_hand" and type(v) == "function" and not porkify_safe_draw_wrappers[v] then
            root[k] = porkify_make_safe_draw_wrapper(v)
            v = root[k]
        end

        if type(v) == "table" then
            porkify_patch_draw_refs_in_table(v, seen, depth + 1)
        elseif type(v) == "function" and debug and debug.getupvalue and debug.setupvalue then
            local i = 1
            while true do
                local name, upvalue = debug.getupvalue(v, i)
                if not name then
                    break
                end
                if name == "draw_from_deck_to_hand" and type(upvalue) == "function" and not porkify_safe_draw_wrappers[upvalue] then
                    debug.setupvalue(v, i, porkify_make_safe_draw_wrapper(upvalue))
                end
                i = i + 1
            end
        end
    end
end

local function porkify_patch_draw_refs_in_function(fn, seen_functions)
    if type(fn) ~= "function" or seen_functions[fn] or not (debug and debug.getupvalue and debug.setupvalue) then
        return
    end
    seen_functions[fn] = true

    local i = 1
    while true do
        local name, upvalue = debug.getupvalue(fn, i)
        if not name then
            break
        end
        if name == "draw_from_deck_to_hand" and type(upvalue) == "function" and not porkify_safe_draw_wrappers[upvalue] then
            debug.setupvalue(fn, i, porkify_make_safe_draw_wrapper(upvalue))
        elseif type(upvalue) == "table" then
            porkify_patch_draw_refs_in_table(upvalue, {}, 0)
        elseif type(upvalue) == "function" then
            porkify_patch_draw_refs_in_function(upvalue, seen_functions)
        end
        i = i + 1
    end
end

local function porkify_install_safe_draw_patch()
    if type(draw_from_deck_to_hand) == "function" then
        local wrapped = porkify_make_safe_draw_wrapper(draw_from_deck_to_hand)
        draw_from_deck_to_hand = wrapped
        Porkify_draw_from_deck_to_hand = wrapped
    end

    if debug and debug.getupvalue and debug.setupvalue and debug.getregistry then
        local seen_tables = {}
        local seen_functions = {}
        porkify_patch_draw_refs_in_table(_G, seen_tables, 0)
        porkify_patch_draw_refs_in_table(package and package.loaded or {}, seen_tables, 0)
        porkify_patch_draw_refs_in_table(debug.getregistry(), seen_tables, 0)

        for _, v in pairs(debug.getregistry()) do
            if type(v) == "function" then
                porkify_patch_draw_refs_in_function(v, seen_functions)
            elseif type(v) == "table" then
                porkify_patch_draw_refs_in_table(v, seen_tables, 0)
            end
        end
    end
end

porkify_remove_serpent_from_game()
porkify_install_safe_draw_patch()

local function porkify_is_gravitas_seal(card)
    if not card then
        return false
    end
    local seal = card.seal or (card.ability and card.ability.seal)
    return seal == "porkify_gravitas" or seal == "gravitas"
end

local function porkify_is_card_debuffed_for_draw(card)
    if not card then
        return false
    end
    if card.debuff then
        return true
    end

    local blind = G and G.GAME and G.GAME.blind
    if not blind or blind.disabled or type(blind.recalc_debuff) ~= "function" then
        return false
    end

    local ok, debuffed = pcall(blind.recalc_debuff, blind, card, true)
    return ok and debuffed == true
end

function porkify_is_eligible_gravitas_draw(card)
    return card
        and porkify_is_gravitas_seal(card)
        and not porkify_is_card_debuffed_for_draw(card)
end

local function porkify_prepare_cards_to_draw(cards_to_draw, hand_space)
    if type(cards_to_draw) ~= "table" then
        return cards_to_draw
    end

    local compacted = {}
    local max_index = 0
    for k, _ in pairs(cards_to_draw) do
        if type(k) == "number" and k > max_index then
            max_index = k
        end
    end
    max_index = math.max(max_index, hand_space or 0)

    for i = 1, max_index do
        local queued = rawget(cards_to_draw, i)
        if queued then
            compacted[#compacted + 1] = queued
        end
    end

    if #compacted > 1 then
        local gravitas_first = {}
        local normal_draws = {}

        for i = 1, #compacted do
            local queued = compacted[i]
            if porkify_is_eligible_gravitas_draw(queued) then
                gravitas_first[#gravitas_first + 1] = queued
            else
                normal_draws[#normal_draws + 1] = queued
            end
        end

        if #gravitas_first > 0 then
            local reordered = {}
            for i = 1, #gravitas_first do
                reordered[#reordered + 1] = gravitas_first[i]
            end
            for i = 1, #normal_draws do
                reordered[#reordered + 1] = normal_draws[i]
            end
            return reordered
        end
    end

    return compacted
end

local function porkify_get_prioritized_deck_sequence(deck_cards)
    if type(deck_cards) ~= "table" then
        return {}
    end

    local gravitas_first = {}
    local normal_draws = {}

    for i = #deck_cards, 1, -1 do
        local queued = deck_cards[i]
        if porkify_is_eligible_gravitas_draw(queued) then
            gravitas_first[#gravitas_first + 1] = queued
        else
            normal_draws[#normal_draws + 1] = queued
        end
    end

    local prioritized = {}
    for i = 1, #gravitas_first do
        prioritized[#prioritized + 1] = gravitas_first[i]
    end
    for i = 1, #normal_draws do
        prioritized[#prioritized + 1] = normal_draws[i]
    end
    return prioritized
end

function porkify_install_draw_priority_patch()
    if not (G and G.FUNCS) then
        return
    end

    if G.FUNCS.draw_from_deck_to_hand == Porkify_draw_from_deck_to_hand_direct then
        return
    end

    Porkify_draw_from_deck_to_hand_direct = function(e)
        if not (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK or G.STATE == G.STATES.SMODS_BOOSTER_OPENED)
            and G.hand.config.card_limit <= 0 and #G.hand.cards == 0 then
            G.STATE = G.STATES.GAME_OVER
            G.STATE_COMPLETE = false
            return true
        end

        local hand_space = e
        local cards_to_draw = {}
        local limit = G.hand.config.card_limit - #G.hand.cards - (SMODS.cards_to_draw or 0)
        local flags = SMODS.calculate_context({ drawing_cards = true, amount = limit })
        limit = flags.cards_to_draw or flags.modify or limit
        local unfixed = not G.hand.config.fixed_limit
        local prioritized_deck = porkify_get_prioritized_deck_sequence(G.deck.cards)

        for i = 1, #prioritized_deck do
            if limit <= 0 then
                break
            end

            local deck_card = prioritized_deck[i]
            local mod = unfixed and (deck_card.ability.card_limit - deck_card.ability.extra_slots_used) or 0
            if limit - 1 + mod >= 0 then
                limit = limit - 1 + mod
                cards_to_draw[#cards_to_draw + 1] = deck_card
            end
        end

        cards_to_draw = porkify_prepare_cards_to_draw(cards_to_draw, hand_space)
        hand_space = #cards_to_draw

        if G.GAME.blind.name == "The Serpent"
            and G.STATE == G.STATES.DRAW_TO_HAND
            and not G.GAME.blind.disabled
            and (G.GAME.current_round.hands_played > 0 or G.GAME.current_round.discards_used > 0) then
            G.hand.config.card_limits.blind_restriction = hand_space - math.min(#G.deck.cards, 3)
            hand_space = math.min(#G.deck.cards, 3)
        end

        delay(0.3)
        SMODS.cards_to_draw = (SMODS.cards_to_draw or 0) + hand_space
        SMODS.drawn_cards = {}

        for i = 1, hand_space do
            local queued = cards_to_draw[i]
            if queued and queued.ability and queued.ability.extra_slots_used then
                SMODS.cards_to_draw = SMODS.cards_to_draw + queued.ability.extra_slots_used
                G.E_MANAGER:add_event(Event({
                    trigger = "immediate",
                    func = function()
                        SMODS.cards_to_draw = SMODS.cards_to_draw - queued.ability.extra_slots_used
                        return true
                    end
                }))
            end

            draw_card(G.deck, G.hand, i * 100 / hand_space, "up", true, queued)
        end

        G.E_MANAGER:add_event(Event({
            trigger = "immediate",
            func = function()
                SMODS.cards_to_draw = SMODS.cards_to_draw - hand_space
                return true
            end
        }))

        G.E_MANAGER:add_event(Event({
            trigger = "immediate",
            func = function()
                if #SMODS.drawn_cards > 0 then
                    SMODS.calculate_context({
                        first_hand_drawn = not G.GAME.current_round.any_hand_drawn and G.GAME.facing_blind,
                        hand_drawn = G.GAME.facing_blind and SMODS.drawn_cards,
                        other_drawn = not G.GAME.facing_blind and SMODS.drawn_cards
                    })
                    SMODS.drawn_cards = {}
                    if G.GAME.facing_blind then
                        G.GAME.current_round.any_hand_drawn = true
                    end
                end
                return true
            end
        }))
    end

    G.FUNCS.draw_from_deck_to_hand = Porkify_draw_from_deck_to_hand_direct
end

porkify_install_draw_priority_patch()

local function porkify_is_glitched_seal(card)
    if not card then
        return false
    end
    local seal = card.seal or (card.ability and card.ability.seal)
    return seal == "porkify_glitched" or seal == "glitched"
end

local function porkify_is_dice_seal(card)
    if not card then
        return false
    end
    local seal = card.seal or (card.ability and card.ability.seal)
    return seal == "porkify_dice" or seal == "dice"
end

local function porkify_is_pride_seal(card)
    if not card then
        return false
    end
    local seal = card.seal or (card.ability and card.ability.seal)
    return seal == "porkify_pride" or seal == "pride"
end

local function porkify_count_played_pride_seals()
    local scoring_hand = SMODS and SMODS.last_hand and SMODS.last_hand.scoring_hand
    if type(scoring_hand) ~= "table" then
        return 0
    end

    local count = 0
    for _, played_card in ipairs(scoring_hand) do
        if played_card and not played_card.debuff and porkify_is_pride_seal(played_card) then
            count = count + 1
        end
    end

    return count
end

local function porkify_held_pride_multiplier_count(card)
    if not (card and porkify_is_pride_seal(card) and not card.debuff and card.facing ~= "back") then
        return 0
    end

    return porkify_count_played_pride_seals()
end

local function porkify_scoring_hand_has_dice_seal(context)
    local scoring_hand = context and (context.scoring_hand or context.full_hand)
    if type(scoring_hand) ~= "table" then
        return false
    end

    for _, played_card in ipairs(scoring_hand) do
        if played_card and not played_card.debuff and porkify_is_dice_seal(played_card) then
            return true
        end
    end

    return false
end

if type(draw_card) == "function" and not Porkify_draw_card_glitched then
    Porkify_draw_card_glitched = draw_card
    function draw_card(from, to, percent, dir, sort, card, delay, mute, stay_flipped, vol)
        local current_round = G and G.GAME and G.GAME.current_round
        if from == G.play
            and to == G.discard
            and card
            and current_round
            and not card.debuff
            and porkify_is_glitched_seal(card) then
            local returned = current_round.porkify_glitched_returned_ids or {}
            local card_key = card.unique_val or card.sort_id or tostring(card)
            if not returned[card_key] then
                current_round.porkify_glitched_returned_ids = returned
                returned[card_key] = true
                to = G.hand
                sort = true
            end
        end

        return Porkify_draw_card_glitched(from, to, percent, dir, sort, card, delay, mute, stay_flipped, vol)
    end
end

if type(eval_card) == "function" and not Porkify_eval_card_pride then
    Porkify_eval_card_pride = eval_card
    function eval_card(card, context)
        if G and G.GAME then
            G.GAME.current_round = G.GAME.current_round or {}
            if context
                and context.before
                and context.cardarea == G.jokers
                and porkify_scoring_hand_has_dice_seal(context) then
                G.GAME.current_round.porkify_dice_probability_active = true
            end
            if context
                and context.before
                and context.cardarea == G.jokers then
                local resolute_count = 0
                for _, played_card in ipairs(context.full_hand or {}) do
                    if porkify_is_resolute_card(played_card) then
                        resolute_count = resolute_count + 1
                    end
                end
                G.GAME.current_round.porkify_tooth_resolute_refund = resolute_count
                G.GAME.current_round.porkify_tooth_resolute_hand_active = resolute_count > 0
            end
        end

        local eff, post = Porkify_eval_card_pride(card, context)

        if G and G.GAME then
            G.GAME.current_round = G.GAME.current_round or {}
            if context and context.setting_blind then
                porkify_consume_no_reward_blind()
                if G.GAME.porkify_force_final_boss_pending and G.GAME.blind_choices and G.GAME.blind_choices.Boss then
                    local key = porkify_choose_final_boss_key()
                    G.GAME.blind_choices.Boss = porkify_apply_final_boss_choice(G.GAME.blind_choices.Boss, key)
                end
                porkify_apply_pending_final_boss_to_active_blind()
                G.GAME.current_round.porkify_glitched_returned_ids = {}
            end
            if context and (
                (context.after and context.cardarea == G.jokers)
                or context.end_of_round
                or context.setting_blind
                or context.hand_drawn
            ) then
                if context.after
                    and context.cardarea == G.jokers
                    and porkify_active_blind_is("tooth")
                    and (G.GAME.current_round.porkify_tooth_resolute_refund or 0) > 0 then
                    local refund = G.GAME.current_round.porkify_tooth_resolute_refund
                    G.GAME.current_round.porkify_tooth_resolute_refund = 0
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0,
                        func = function()
                            ease_dollars(refund, true)
                            return true
                        end
                    }))
                end
                G.GAME.current_round.porkify_dice_probability_active = nil
                if not (context.setting_blind or context.hand_drawn) then
                    G.GAME.current_round.porkify_tooth_resolute_refund = nil
                    G.GAME.current_round.porkify_tooth_resolute_hand_active = nil
                end
            end
        end

        return eff, post
    end
end

if type(ease_dollars) == "function" and not Porkify_ease_dollars_resolute then
    Porkify_ease_dollars_resolute = ease_dollars
    function ease_dollars(mod, instant)
        local adjusted = mod
        local current_round = G and G.GAME and G.GAME.current_round
        if type(adjusted) == "number"
            and adjusted < 0
            and porkify_active_blind_is("tooth")
            and current_round
            and current_round.porkify_tooth_resolute_hand_active
            and (current_round.porkify_tooth_resolute_refund or 0) > 0 then
            local refund = math.min(-adjusted, current_round.porkify_tooth_resolute_refund)
            adjusted = adjusted + refund
            current_round.porkify_tooth_resolute_refund = current_round.porkify_tooth_resolute_refund - refund
        end
        return Porkify_ease_dollars_resolute(adjusted, instant)
    end
end

if Card and type(Card.get_chip_h_x_mult) == "function" and not Porkify_get_chip_h_x_mult_pride then
    Porkify_get_chip_h_x_mult_pride = Card.get_chip_h_x_mult
    function Card:get_chip_h_x_mult()
        local base = Porkify_get_chip_h_x_mult_pride(self)
        local pride_count = porkify_held_pride_multiplier_count(self)

        if pride_count <= 0 then
            return base
        end

        local pride_mult = 1 + pride_count

        if type(base) ~= "number" or base <= 0 then
            return pride_mult
        end

        return base * pride_mult
    end
end

local NFS = require("nativefs")
to_big = to_big or function(a) return a end
lenient_bignum = lenient_bignum or function(a) return a end

-- local consumableIndexList = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30}
-- 
-- local function load_consumables_folder()
--     local mod_path = SMODS.current_mod.path
--     local consumables_path = mod_path .. "/consumables"
--     local files = NFS.getDirectoryItemsInfo(consumables_path)
--     local set_file_number = #files + 1
--     for i = 1, #files do
--         if files[i].name == "sets.lua" then
--             assert(SMODS.load_file("consumables/sets.lua"))()
--             set_file_number = i
--         end
--     end    
--     for i = 1, #consumableIndexList do
--         local j = consumableIndexList[i]
--         if j >= set_file_number then 
--             j = j + 1
--         end
--         local file_name = files[j].name
--         if file_name:sub(-4) == ".lua" then
--             assert(SMODS.load_file("consumables/" .. file_name))()
--         end
--     end
-- end

local function load_consumables_folder()
    local mod_path = SMODS.current_mod.path
    local consumables_path = mod_path .. "/consumables"
    local files = NFS.getDirectoryItemsInfo(consumables_path)

    for _, info in ipairs(files) do
        local file_name = info.name
        if file_name:sub(-4) == ".lua" then
            assert(SMODS.load_file("consumables/" .. file_name))()
        end
    end
end

local function load_boosters_file()
    local mod_path = SMODS.current_mod.path
    assert(SMODS.load_file("boosters.lua"))()
end

local function load_challenges_folder()
    local mod_path = SMODS.current_mod.path
    local challenges_path = mod_path .. "/challenges"
    local files = NFS.getDirectoryItemsInfo(challenges_path)

    for _, info in ipairs(files) do
        local file_name = info.name
        if file_name:sub(-4) == ".lua" then
            assert(SMODS.load_file("challenges/" .. file_name))()
        end
    end
end

local function load_blinds_folder()
    local mod_path = SMODS.current_mod.path
    local blinds_path = mod_path .. "/blinds"
    local ok, files = pcall(NFS.getDirectoryItemsInfo, blinds_path)
    if not ok or not files then
        return
    end

    for _, info in ipairs(files) do
        local file_name = info.name
        if file_name:sub(-4) == ".lua" then
            assert(SMODS.load_file("blinds/" .. file_name))()
        end
    end
end

local function load_rarities_file()
    local mod_path = SMODS.current_mod.path
    assert(SMODS.load_file("rarities.lua"))()
end

local function load_decks_folder()
    local mod_path = SMODS.current_mod.path
    local decks_path = mod_path .. "/decks"
    local files = NFS.getDirectoryItemsInfo(decks_path)

    for _, info in ipairs(files) do
        local file_name = info.name
        if file_name:sub(-4) == ".lua" then
            assert(SMODS.load_file("decks/" .. file_name))()
        end
    end
end

local editionIndexList = {1,2,3,4,5}

local function load_editions_folder()
    local mod_path = SMODS.current_mod.path
    local editions_path = mod_path .. "/editions"
    local files = NFS.getDirectoryItemsInfo(editions_path)
    for i = 1, #editionIndexList do
        local file_name = files[editionIndexList[i]].name
        if file_name:sub(-4) == ".lua" then
            assert(SMODS.load_file("editions/" .. file_name))()
        end
    end
end

local enhancementIndexList = {7,3,10,9,8,1,2,5,6,4}

local function load_enhancements_folder()
    local mod_path = SMODS.current_mod.path
    local enhancements_path = mod_path .. "/enhancements"
    local files = NFS.getDirectoryItemsInfo(enhancements_path)
    for i = 1, #enhancementIndexList do
        local file_name = files[enhancementIndexList[i]].name
        if file_name:sub(-4) == ".lua" then
            assert(SMODS.load_file("enhancements/" .. file_name))()
        end
    end
end

local voucherIndexList = {1,2}

local function load_vouchers_folder()
    local mod_path = SMODS.current_mod.path
    local vouchers_path = mod_path .. "/vouchers"
    local files = NFS.getDirectoryItemsInfo(vouchers_path)
    for i = 1, #voucherIndexList do
        local file_name = files[voucherIndexList[i]].name
        if file_name:sub(-4) == ".lua" then
            assert(SMODS.load_file("vouchers/" .. file_name))()
        end
    end
end

load_rarities_file()
load_boosters_file()
load_consumables_folder()
load_challenges_folder()
load_blinds_folder()
load_decks_folder()
load_editions_folder()
load_enhancements_folder()
load_seals_folder()
load_vouchers_folder()

SMODS.current_mod.optional_features = function()
    return {
        cardareas = {} 
    }
end

SMODS.current_mod.menu_cards = function()
	return {
		{set = 'porkify'}, -- adds a random Porkify card to the menu
		{key = 'j_porkify_porky'}, -- adds Porky to the menu
        remove_original = true -- removes the original menu card(s) that this replaces, in this case the original joker card
	}
end

if Malverk and type(Malverk.set_defaults) == "function" then
    local malverk_set_defaults = Malverk.set_defaults
    Malverk.set_defaults = function(...)
        if not TexturePacks or not TexturePacks["default"] then
            return
        end
        return malverk_set_defaults(...)
    end
end
