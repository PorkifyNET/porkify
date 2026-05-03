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

local NFS = require("nativefs")
to_big = to_big or function(a) return a end
lenient_bignum = lenient_bignum or function(a) return a end

local function load_jokers_folder()
    local mod_path = SMODS.current_mod.path
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
    local mod_path = SMODS.current_mod.path
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
    local mod_path = SMODS.current_mod.path
    local stickers_path = mod_path .. "/stickers"
    local files = NFS.getDirectoryItemsInfo(stickers_path)

    for _, info in ipairs(files or {}) do
        local file_name = info.name
        if file_name:sub(-4) == ".lua" then
            assert(SMODS.load_file("stickers/" .. file_name))()
        end
    end
end

load_jokers_folder()
load_stickers_folder()
load_stakes_folder()
SMODS.ObjectType({
    key = "porkify_food",
    cards = {
        ["j_gros_michel"] = true,
        ["j_egg"] = true,
        ["j_ice_cream"] = true,
        ["j_cavendish"] = true,
        ["j_turtle_bean"] = true,
        ["j_diet_cola"] = true,
        ["j_popcorn"] = true,
        ["j_ramen"] = true,
        ["j_selzer"] = true,
		["j_porkify_hotdog"] = true,
		["j_porkify_hamburger"] = true,
		["j_porkify_pizza"] = true,
		["j_porkify_paul"] = true,
		["j_porkify_mallard"] = true
    },
})

SMODS.ObjectType({
    key = "porkify_porkify_jokers",
    cards = {
        ["j_porkify__9carats"] = true,
        ["j_porkify_appletree"] = true,
        ["j_porkify_bailout"] = true,
        ["j_porkify_beatingheart"] = true,
        ["j_porkify_cardception"] = true,
        ["j_porkify_cupofcoffee"] = true,
        ["j_porkify_dynamite"] = true,
        ["j_porkify_grabfour"] = true,
        ["j_porkify_loading"] = true,
        ["j_porkify_luckynumber7s"] = true,
        ["j_porkify_nu"] = true,
        ["j_porkify_omnipotentjoker"] = true,
        ["j_porkify_pencil"] = true,
        ["j_porkify_perfectloop"] = true,
        ["j_porkify_refridgerator"] = true,
        ["j_porkify_thecenterpiece"] = true,
        ["j_porkify_theheadmaster"] = true,
        ["j_porkify_thehospital"] = true,
        ["j_porkify_therectangle"] = true,
        ["j_porkify_thewindow"] = true,
        ["j_porkify_wormhole"] = true
    },
})

SMODS.current_mod.optional_features = function()
    return {
        cardareas = {} 
    }
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

if generate_card_ui and not Porkify_generate_card_ui then
    Porkify_generate_card_ui = generate_card_ui
    function generate_card_ui(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end, card)
        local ability = card and card.ability
        local has_bulky = ability and (ability.porkify_bulky or ability.bulky)
        local original_extra_slots_used = has_bulky and ability.extra_slots_used or nil

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

local function porkify_can_use_pack_consumeable(card)
    if not card then
        return false
    end

    local center = card.config and card.config.center
    if card.ability and card.ability.set == 'porkify' and center and type(center.can_use) == "function" then
        local ok, result = pcall(center.can_use, center, card)
        return ok and result == true
    end

    local ok, result = pcall(function()
        return card:can_use_consumeable()
    end)
    return ok and result == true
end

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
        local n, d = Porkify_get_probability_vars(card, numerator, denominator, identifier)
        if porkify_active_blind_is("toll") then
            return 0, d
        end
        return n, d
    end
end

if SMODS and SMODS.pseudorandom_probability and not Porkify_pseudorandom_probability then
    Porkify_pseudorandom_probability = SMODS.pseudorandom_probability
    SMODS.pseudorandom_probability = function(card, seed, numerator, denominator, identifier, trigger)
        if porkify_active_blind_is("toll") then
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

local enhancementIndexList = {4,3,7,6,5,1,2}

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
load_vouchers_folder()

SMODS.current_mod.optional_features = function()
    return {
        cardareas = {} 
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
