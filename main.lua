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
PORKIFY_MAX_SELECTED_BLANK_SEALS = 2
PORKIFY_TOO_MANY_BLANKS_HAND = "Too Many Blanks!"
PORKIFY_TOO_MANY_BLANKS_HAND_KEY = "porkify_too_many_blanks"

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

SMODS.PokerHand({
    key = PORKIFY_TOO_MANY_BLANKS_HAND_KEY,
    mult = 0,
    chips = 0,
    l_mult = 0,
    l_chips = 0,
    visible = false,
    no_collection = true,
    order_offset = 1000000,
    example = {
        { "H_A", true, seal = "porkify_blank" },
        { "D_3", true, seal = "porkify_blank" },
        { "S_9", true, seal = "porkify_blank" },
        { "C_A", true },
        { "H_K", false }
    },
    loc_txt = {
        name = PORKIFY_TOO_MANY_BLANKS_HAND,
        description = {
            "{C:blue}Hands{} with more than",
            "{C:attention}2{} Blank Seals {C:red}cannot be played{}"
        }
    },
    evaluate = function(parts, hand)
        if booster_obj then
            return {}
        end

        if G and G.STATES and G.STATE then
            if G.STATE == G.STATES.TAROT_PACK
                or G.STATE == G.STATES.SPECTRAL_PACK
                or G.STATE == G.STATES.SMODS_BOOSTER_OPENED then
                return {}
            end
        end

        local blank_count = 0
        for i = 1, #(hand or {}) do
            local card = hand[i]
            local seal = card and (card.seal or (card.ability and card.ability.seal))
            if seal == "porkify_blank" or seal == "blank" then
                blank_count = blank_count + 1
            end
        end

        if blank_count > PORKIFY_MAX_SELECTED_BLANK_SEALS then
            return { hand }
        end

        return {}
    end,
    modify_display_text = function(self, cards, scoring_hand)
        return self.key
    end
})

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

    porkify_register_too_many_blanks_hand()

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
    ["j_porkify_potion"] = true,
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

local function porkify_is_blank_seal_card(card)
    if not card then
        return false
    end
    if card.debuff then
        return false
    end
    local seal = card.seal or (card.ability and card.ability.seal)
    return seal == "porkify_blank" or seal == "blank"
end
_G.porkify_is_blank_seal_card = porkify_is_blank_seal_card

local function porkify_card_matches_rank(card, expected)
    if not card then
        return false
    end

    if porkify_is_blank_seal_card(card) then
        return true
    end

    if type(expected) == "table" then
        for i = 1, #expected do
            if porkify_card_matches_rank(card, expected[i]) then
                return true
            end
        end
        return false
    end

    if type(expected) == "number" then
        return card.get_id and card:get_id() == expected
    end

    if type(expected) == "string" then
        local value = card.base and card.base.value
        return value == expected
    end

    return false
end
_G.porkify_card_matches_rank = porkify_card_matches_rank

local function porkify_card_is_face_or_blank(card)
    if not card then
        return false
    end

    if porkify_is_blank_seal_card(card) then
        return true
    end

    return card.is_face and card:is_face() or false
end
_G.porkify_card_is_face_or_blank = porkify_card_is_face_or_blank

local function porkify_get_active_eval_context()
    return nil
end

local function porkify_get_card_runtime_key(card)
    if not card then
        return nil
    end

    return card.unique_val or card.sort_id or tostring(card)
end

local function porkify_get_mimic_replay_table()
    if not (G and G.GAME) then
        return nil
    end

    G.GAME.current_round = G.GAME.current_round or {}
    G.GAME.current_round.porkify_mimic_replays = G.GAME.current_round.porkify_mimic_replays or {}
    return G.GAME.current_round.porkify_mimic_replays
end

local function porkify_get_mimic_popup_proxy()
    if not (G and G.GAME and G.GAME.current_round) then
        return nil
    end

    return G.GAME.current_round.porkify_mimic_popup_proxy
end

local function porkify_set_mimic_popup_proxy(source_card, proxy_card)
    if not (G and G.GAME) then
        return
    end

    G.GAME.current_round = G.GAME.current_round or {}
    if source_card and proxy_card then
        G.GAME.current_round.porkify_mimic_popup_proxy = {
            source_card = source_card,
            proxy_card = proxy_card
        }
    else
        G.GAME.current_round.porkify_mimic_popup_proxy = nil
    end
end

local function porkify_apply_mimic_popup_proxy(effect, scored_card)
    local popup_proxy = porkify_get_mimic_popup_proxy()
    if not (popup_proxy and effect and scored_card == popup_proxy.source_card) then
        return effect
    end

    if effect.message_card == popup_proxy.proxy_card then
        return effect
    end

    local copied = {}
    for k, v in pairs(effect) do
        copied[k] = v
    end
    copied.message_card = popup_proxy.proxy_card
    return copied
end

local function porkify_get_mimic_replay_source(proxy_card)
    local replay_table = porkify_get_mimic_replay_table()
    local proxy_key = porkify_get_card_runtime_key(proxy_card)
    if not (replay_table and proxy_key) then
        return nil
    end

    local replay_state = replay_table[proxy_key]
    return replay_state and replay_state.source_card or nil
end

local function porkify_arm_mimic_replay(proxy_card, source_card)
    local replay_table = porkify_get_mimic_replay_table()
    local proxy_key = porkify_get_card_runtime_key(proxy_card)
    if not (replay_table and proxy_key and source_card) then
        return
    end

    replay_table[proxy_key] = {
        proxy_card = proxy_card,
        source_card = source_card
    }
end
_G.porkify_arm_mimic_replay = porkify_arm_mimic_replay

local function porkify_clear_mimic_replays()
    local replay_table = porkify_get_mimic_replay_table()
    if replay_table then
        for key in pairs(replay_table) do
            replay_table[key] = nil
        end
    end
end

local function porkify_build_mimic_replay_context(context, proxy_card, source_card)
    if not (context and proxy_card and source_card) then
        return nil
    end

    local replay_context = {}
    for k, v in pairs(context) do
        replay_context[k] = v
    end

    if replay_context.other_card == proxy_card then
        replay_context.other_card = source_card
    end
    if replay_context.destroy_card == proxy_card then
        replay_context.destroy_card = source_card
    end
    if replay_context.destroying_card == proxy_card then
        replay_context.destroying_card = source_card
    end

    replay_context.porkify_mimic_replay_active = true
    replay_context.porkify_mimic_proxy_card = proxy_card
    replay_context.porkify_mimic_source_card = source_card

    return replay_context
end

local function porkify_resolve_mimic_replay(card, context)
    if context and context.porkify_mimic_replay_active then
        return card, context
    end

    local proxy_card = nil
    local source_card = nil

    if card then
        source_card = porkify_get_mimic_replay_source(card)
        if source_card then
            proxy_card = card
        end
    end

    if not source_card and context and context.other_card then
        source_card = porkify_get_mimic_replay_source(context.other_card)
        if source_card then
            proxy_card = context.other_card
        end
    end

    if not (proxy_card and source_card) then
        return card, context
    end

    local replay_context = porkify_build_mimic_replay_context(context, proxy_card, source_card) or context
    local replay_card = (card == proxy_card) and source_card or card
    return replay_card, replay_context
end

local function porkify_blank_runtime_rank_override(card)
    return nil
end
_G.porkify_blank_runtime_rank_override = porkify_blank_runtime_rank_override

local function porkify_blank_joker_target_card(self, context)
    if not (self and self.ability and context) then
        return nil
    end

    if context.other_card and porkify_is_blank_seal_card(context.other_card) then
        return context.other_card
    end

    if context.destroying_card and context.full_hand and #context.full_hand == 1 and porkify_is_blank_seal_card(context.full_hand[1]) then
        return context.full_hand[1]
    end

    return nil
end

local function porkify_blank_joker_forced_rank(self, context, target_card)
    if not (self and self.ability and target_card and porkify_is_blank_seal_card(target_card)) then
        return nil
    end

    local joker_name = self.ability.name

    if joker_name == "Walkie Talkie" then return 10 end
    if joker_name == "Even Steven" then return 2 end
    if joker_name == "Odd Todd" then return 3 end
    if joker_name == "Fibonacci" then return 8 end
    if joker_name == "Scholar" then return 14 end
    if joker_name == "Triboulet" then return 12 end
    if joker_name == "8 Ball" then return 8 end
    if joker_name == "Wee Joker" then return 2 end
    if joker_name == "Hack" then return 2 end
    if joker_name == "Shoot the Moon" then return 12 end
    if joker_name == "Baron" then return 13 end
    if joker_name == "Hit the Road" then return 11 end
    if joker_name == "Sixth Sense" then return 6 end
    if joker_name == "Superposition" then return 14 end
    if joker_name == "The Idol" then
        return G and G.GAME and G.GAME.current_round and G.GAME.current_round.idol_card and G.GAME.current_round.idol_card.id or nil
    end
    if joker_name == "Mail-In Rebate" then
        return G and G.GAME and G.GAME.current_round and G.GAME.current_round.mail_card and G.GAME.current_round.mail_card.id or nil
    end

    return nil
end

local function porkify_with_blank_card_rank_override(self, context, fn)
    local target_card = porkify_blank_joker_target_card(self, context)
    local forced_rank = porkify_blank_joker_forced_rank(self, context, target_card)

    if not (target_card and forced_rank and type(fn) == "function") then
        return fn()
    end

    local original_get_id = target_card.get_id
    target_card.get_id = function(_)
        return forced_rank
    end

    local ok, r1, r2, r3, r4 = pcall(fn)
    target_card.get_id = original_get_id

    if not ok then
        error(r1)
    end

    return r1, r2, r3, r4
end

function porkify_install_blank_runtime_get_id_patch()
    return
end

local function porkify_scoring_hand_has_rank(cards, expected)
    for i = 1, #(cards or {}) do
        if porkify_card_matches_rank(cards[i], expected) then
            return true
        end
    end
    return false
end

local function porkify_blank_create_tarot(key)
    G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
    G.E_MANAGER:add_event(Event({
        trigger = "before",
        delay = 0.0,
        func = function()
            local card = create_card("Tarot", G.consumeables, nil, nil, nil, nil, nil, key)
            card:add_to_deck()
            G.consumeables:emplace(card)
            G.GAME.consumeable_buffer = 0
            return true
        end
    }))
end

local function porkify_blank_match_vanilla_joker(self, context)
    if not (self and self.ability and context) then
        return
    end

    if context.destroying_card and not context.blueprint then
        if self.ability.name == "Sixth Sense"
            and #context.full_hand == 1
            and porkify_is_blank_seal_card(context.full_hand[1])
            and not context.full_hand[1].sixth_sense
            and G.GAME.current_round.hands_played == 0 then
            context.full_hand[1].sixth_sense = true
            if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                G.E_MANAGER:add_event(Event({
                    trigger = "before",
                    delay = 0.0,
                    func = function()
                        local card = create_card("Spectral", G.consumeables, nil, nil, nil, nil, nil, "sixth")
                        card:add_to_deck()
                        G.consumeables:emplace(card)
                        G.GAME.consumeable_buffer = 0
                        return true
                    end
                }))
                card_eval_status_text(context.blueprint_card or self, "extra", nil, nil, nil, {
                    message = localize("k_plus_spectral"),
                    colour = G.C.SECONDARY_SET.Spectral
                })
            end
            return true
        end
        return
    end

    if context.discard and context.other_card and porkify_is_blank_seal_card(context.other_card) then
        if self.ability.name == "Mail-In Rebate" and not context.other_card.debuff then
            ease_dollars(self.ability.extra)
            return {
                message = localize("$") .. self.ability.extra,
                colour = G.C.MONEY,
                card = self
            }
        end
        if self.ability.name == "Hit the Road" and not context.other_card.debuff and not context.blueprint then
            SMODS.scale_card(self, {
                ref_table = self.ability,
                ref_value = "x_mult",
                scalar_value = "extra",
                message_key = "a_xmult",
                message_colour = G.C.RED,
                message_delay = 0.45,
            })
            return nil, true
        end
        return
    end

    if context.individual and context.other_card and porkify_is_blank_seal_card(context.other_card) then
        if context.cardarea == G.play then
            if self.ability.name == "Wee Joker" and not context.blueprint then
                SMODS.scale_card(self, {
                    ref_table = self.ability.extra,
                    ref_value = "chips",
                    scalar_value = "chip_mod",
                    no_message = true
                })
                return {
                    extra = { focus = self, message = localize("k_upgrade_ex") },
                    card = self
                }
            end
            if self.ability.name == "8 Ball" and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                if SMODS.pseudorandom_probability(self, "8ball", 1, self.ability.extra) then
                    G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                    return {
                        extra = {
                            focus = self,
                            message = localize("k_plus_tarot"),
                            func = function()
                                G.E_MANAGER:add_event(Event({
                                    trigger = "before",
                                    delay = 0.0,
                                    func = function()
                                        local card = create_card("Tarot", G.consumeables, nil, nil, nil, nil, nil, "8ba")
                                        card:add_to_deck()
                                        G.consumeables:emplace(card)
                                        G.GAME.consumeable_buffer = 0
                                        return true
                                    end
                                }))
                            end
                        },
                        colour = G.C.SECONDARY_SET.Tarot,
                        card = self
                    }
                end
            end
            if self.ability.name == "The Idol" and context.other_card:is_suit(G.GAME.current_round.idol_card.suit) then
                return {
                    x_mult = self.ability.extra,
                    colour = G.C.RED,
                    card = self
                }
            end
            if self.ability.name == "Scholar" then
                return {
                    chips = self.ability.extra.chips,
                    mult = self.ability.extra.mult,
                    card = self
                }
            end
            if self.ability.name == "Walkie Talkie" then
                return {
                    chips = self.ability.extra.chips,
                    mult = self.ability.extra.mult,
                    card = self
                }
            end
            if self.ability.name == "Fibonacci" then
                return {
                    mult = self.ability.extra,
                    card = self
                }
            end
            if self.ability.name == "Even Steven" then
                return {
                    mult = self.ability.extra,
                    card = self
                }
            end
            if self.ability.name == "Odd Todd" then
                return {
                    chips = self.ability.extra,
                    card = self
                }
            end
            if self.ability.name == "Triboulet" then
                return {
                    x_mult = self.ability.extra,
                    colour = G.C.RED,
                    card = self
                }
            end
        end

        if context.cardarea == G.hand then
            if self.ability.name == "Shoot the Moon" then
                if context.other_card.debuff then
                    return {
                        message = localize("k_debuffed"),
                        colour = G.C.RED,
                        card = self,
                    }
                end
                return {
                    h_mult = 13,
                    card = self
                }
            end
            if self.ability.name == "Baron" then
                if context.other_card.debuff then
                    return {
                        message = localize("k_debuffed"),
                        colour = G.C.RED,
                        card = self,
                    }
                end
                return {
                    x_mult = self.ability.extra,
                    card = self
                }
            end
        end
        return
    end

    if context.repetition and context.other_card and context.cardarea == G.play and porkify_is_blank_seal_card(context.other_card) then
        if self.ability.name == "Hack" then
            return {
                message = localize("k_again_ex"),
                repetitions = self.ability.extra,
                card = self
            }
        end
        return
    end

    if context.joker_main then
        if self.ability.name == "Superposition"
            and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit
            and porkify_scoring_hand_has_rank(context.scoring_hand, 14)
            and context.poker_hands
            and next(context.poker_hands["Straight"]) then
            porkify_blank_create_tarot("sup")
            return {
                message = localize("k_plus_tarot"),
                colour = G.C.SECONDARY_SET.Tarot,
                card = self
            }
        end
    end
end

function porkify_install_blank_vanilla_joker_patch()
    if Card and Card.is_face then
        if Porkify_blank_is_face == nil then
            Porkify_blank_is_face = function(self, from_boss)
                if self and self.debuff and not from_boss then
                    return
                end
                if porkify_is_blank_seal_card(self) then
                    return true
                end
                return Porkify_blank_is_face_ref(self, from_boss)
            end
        end

        if Card.is_face ~= Porkify_blank_is_face then
            Porkify_blank_is_face_ref = Card.is_face
            Card.is_face = Porkify_blank_is_face
        end
    end

    if Card and Card.calculate_joker then
        if Porkify_blank_calculate_joker == nil then
            Porkify_blank_calculate_joker = function(self, context)
                local _, resolved_context = porkify_resolve_mimic_replay(nil, context)
                local eff, post = porkify_with_blank_card_rank_override(self, resolved_context, function()
                    return Porkify_blank_calculate_joker_ref(self, resolved_context)
                end)

                if eff ~= nil and (type(eff) ~= "table" or next(eff) ~= nil) then
                    return eff, post
                end

                local a, b, c, d = porkify_blank_match_vanilla_joker(self, resolved_context)
                if a ~= nil or b ~= nil or c ~= nil or d ~= nil then
                    return a, b, c, d
                end

                return eff, post
            end
        end

        if Card.calculate_joker ~= Porkify_blank_calculate_joker then
            Porkify_blank_calculate_joker_ref = Card.calculate_joker
            Card.calculate_joker = Porkify_blank_calculate_joker
        end
    end

    if Card and Card.update then
        if Porkify_blank_card_update == nil then
            Porkify_blank_card_update = function(self, dt)
                local result = Porkify_blank_card_update_ref(self, dt)
                if self and self.ability and self.ability.name == "Cloud 9" and G and G.playing_cards then
                    local extra_blanks = 0
                    for _, playing_card in pairs(G.playing_cards) do
                        local real_rank = playing_card and playing_card.get_id and playing_card:get_id()
                        if porkify_is_blank_seal_card(playing_card) and real_rank ~= 9 then
                            extra_blanks = extra_blanks + 1
                        end
                    end
                    self.ability.nine_tally = (self.ability.nine_tally or 0) + extra_blanks
                end
                return result
            end
        end

        if Card.update ~= Porkify_blank_card_update then
            Porkify_blank_card_update_ref = Card.update
            Card.update = Porkify_blank_card_update
        end
    end
end

porkify_install_blank_vanilla_joker_patch()

function porkify_install_blank_eval_card_patch()
    return
end

function porkify_install_blank_calculate_card_areas_patch()
    return
end

function porkify_install_blank_score_card_patch()
    if not (SMODS and type(SMODS.score_card) == "function" and SMODS.get_enhancements) then
        return
    end

    if Porkify_score_card_mimic == nil then
        Porkify_score_card_mimic = function(card, context)
            Porkify_score_card_mimic_ref(card, context)

            if not (card and context and context.cardarea == G.play and context.scoring_hand) then
                return
            end

            local enhancements = SMODS.get_enhancements(card) or {}
            if not enhancements.m_porkify_mimic then
                return
            end

            local scoring_hand = context.scoring_hand or {}
            local my_index = nil
            for i = 1, #scoring_hand do
                if scoring_hand[i] == card then
                    my_index = i
                    break
                end
            end

            if not my_index or my_index <= 1 then
                return
            end

            local left_card = scoring_hand[my_index - 1]
            if not left_card or left_card == card then
                return
            end

            local replay_context = {}
            for k, v in pairs(context) do
                replay_context[k] = v
            end

            porkify_set_mimic_popup_proxy(left_card, card)
            local ok, err = pcall(SMODS.score_card, left_card, replay_context)
            porkify_set_mimic_popup_proxy(nil, nil)
            if not ok then
                error(err)
            end
        end
    end

    if SMODS.score_card ~= Porkify_score_card_mimic then
        Porkify_score_card_mimic_ref = SMODS.score_card
        SMODS.score_card = Porkify_score_card_mimic
    end
end

porkify_install_blank_score_card_patch()

function porkify_install_blank_calculate_effect_table_key_patch()
    if not (SMODS and type(SMODS.calculate_effect_table_key) == "function") then
        return
    end

    if Porkify_calculate_effect_table_key_mimic == nil then
        Porkify_calculate_effect_table_key_mimic = function(effect_table, key, card, ret)
            local effect = effect_table[key]
            if key ~= 'smods' and type(effect) == 'table' then
                local scored_card = effect.scored_card or card
                local calc = SMODS.calculate_effect(porkify_apply_mimic_popup_proxy(effect, scored_card), scored_card, key == 'edition')
                for k, v in pairs(calc) do
                    ret[k] = type(ret[k]) == 'number' and ret[k] + v or v
                end
                return
            end

            return Porkify_calculate_effect_table_key_mimic_ref(effect_table, key, card, ret)
        end
    end

    if SMODS.calculate_effect_table_key ~= Porkify_calculate_effect_table_key_mimic then
        Porkify_calculate_effect_table_key_mimic_ref = SMODS.calculate_effect_table_key
        SMODS.calculate_effect_table_key = Porkify_calculate_effect_table_key_mimic
    end
end

porkify_install_blank_calculate_effect_table_key_patch()

function porkify_install_blank_vanilla_center_patches()
    return
end

function Porkify_blank_center_calculate(self, card, context)
    return
end


local function porkify_count_highlighted_blank_seals(area)
    local count = 0

    if not (area and area.highlighted) then
        return count
    end

    for i = 1, #area.highlighted do
        if porkify_is_blank_seal_card(area.highlighted[i]) then
            count = count + 1
        end
    end

    return count
end

local function porkify_blank_limit_disabled()
    if not G then
        return false
    end

    if booster_obj then
        return true
    end

    if G.STATES and G.STATE then
        if G.STATE == G.STATES.TAROT_PACK
            or G.STATE == G.STATES.SPECTRAL_PACK
            or G.STATE == G.STATES.SMODS_BOOSTER_OPENED then
            return true
        end
    end

    return false
end
_G.porkify_blank_limit_disabled = porkify_blank_limit_disabled

function porkify_register_too_many_blanks_hand()
    if not (G and G.GAME and G.GAME.hands) then
        return
    end

    if not G.GAME.hands[PORKIFY_TOO_MANY_BLANKS_HAND_KEY] then
        G.GAME.hands[PORKIFY_TOO_MANY_BLANKS_HAND_KEY] = {
            visible = false,
            played = 0,
            level = to_big(1),
            mult = 0,
            chips = 0,
            l_mult = 1,
            l_chips = 0,
            order = 9999
        }
    end

    if G.localization then
        G.localization.misc = G.localization.misc or {}
        G.localization.misc.poker_hands = G.localization.misc.poker_hands or {}
        G.localization.misc.poker_hands[PORKIFY_TOO_MANY_BLANKS_HAND_KEY] = PORKIFY_TOO_MANY_BLANKS_HAND
        G.localization.misc.poker_hand_descriptions = G.localization.misc.poker_hand_descriptions or {}
        G.localization.misc.poker_hand_descriptions[PORKIFY_TOO_MANY_BLANKS_HAND_KEY] = {
            "{C:blue}Hands{} with more than",
            "{C:attention}2{} Blank Seals",
            "{C:red}cannot be played{}"
        }
    end
end

local function porkify_has_too_many_blank_seals(area)
    if porkify_blank_limit_disabled() then
        return false
    end

    return porkify_count_highlighted_blank_seals(area) > PORKIFY_MAX_SELECTED_BLANK_SEALS
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

if CardArea.add_to_highlighted and not Porkify_cardarea_add_to_highlighted then
    Porkify_cardarea_add_to_highlighted = CardArea.add_to_highlighted
    function CardArea:add_to_highlighted(card, silent)
        return Porkify_cardarea_add_to_highlighted(self, card, silent)
    end
end

function porkify_install_blank_play_lock_patch()
    if not (G and G.FUNCS and G.hand) then
        return
    end

    porkify_register_too_many_blanks_hand()

    if G.FUNCS.can_play and Porkify_blank_can_play == nil then
        Porkify_blank_can_play = function(e)
            if porkify_has_too_many_blank_seals(G.hand) then
                if e and e.config then
                    e.config.colour = G.C.UI.BACKGROUND_INACTIVE
                    e.config.button = nil
                end
                return
            end

            return Porkify_can_play(e)
        end
    end

    if G.FUNCS.can_play and G.FUNCS.can_play ~= Porkify_blank_can_play then
        Porkify_can_play = G.FUNCS.can_play
        G.FUNCS.can_play = Porkify_blank_can_play
    end

    if G.FUNCS.play_cards_from_highlighted and Porkify_blank_play_cards_from_highlighted == nil then
        Porkify_blank_play_cards_from_highlighted = function(e)
            if porkify_has_too_many_blank_seals(G.hand) then
                play_sound("cancel")
                if G.hand and G.hand.highlighted and G.hand.highlighted[1] and card_eval_status_text then
                    card_eval_status_text(G.hand.highlighted[1], "extra", nil, nil, nil, {
                        message = PORKIFY_TOO_MANY_BLANKS_HAND,
                        colour = G.C.RED
                    })
                end
                return
            end

            return Porkify_play_cards_from_highlighted(e)
        end
    end

    if G.FUNCS.play_cards_from_highlighted and G.FUNCS.play_cards_from_highlighted ~= Porkify_blank_play_cards_from_highlighted then
        Porkify_play_cards_from_highlighted = G.FUNCS.play_cards_from_highlighted
        G.FUNCS.play_cards_from_highlighted = Porkify_blank_play_cards_from_highlighted
    end
end

porkify_install_blank_play_lock_patch()

local function porkify_apply_blank_handname_colour()
    if not (G and G.hand_text_area and G.hand_text_area.handname and G.GAME and G.GAME.current_round and G.GAME.current_round.current_hand) then
        return
    end

    local handname = G.GAME.current_round.current_hand.handname
    local colour = G.C.UI.TEXT_LIGHT

    if handname == PORKIFY_TOO_MANY_BLANKS_HAND then
        colour = G.C.RED
    end

    G.hand_text_area.handname.config.colour = colour
    if G.hand_text_area.handname.config.object then
        G.hand_text_area.handname.config.object.colours = { colour }
        G.hand_text_area.handname.config.object:update_text()
    end
end

function porkify_install_blank_handname_colour_patch()
    if not update_hand_text then
        return
    end

    if Porkify_update_hand_text_with_blank_colour == nil then
        Porkify_update_hand_text_with_blank_colour = function(config, vals)
            local result = Porkify_update_hand_text_ref(config, vals)
            porkify_apply_blank_handname_colour()
            return result
        end
    end

    if update_hand_text ~= Porkify_update_hand_text_with_blank_colour then
        Porkify_update_hand_text_ref = update_hand_text
        update_hand_text = Porkify_update_hand_text_with_blank_colour
    end

    if G and G.FUNCS and G.FUNCS.hand_text_UI_set and Porkify_hand_text_UI_set_with_blank_colour == nil then
        Porkify_hand_text_UI_set_with_blank_colour = function(e)
            local result = Porkify_hand_text_UI_set_ref(e)
            porkify_apply_blank_handname_colour()
            return result
        end
    end

    if G and G.FUNCS and G.FUNCS.hand_text_UI_set and G.FUNCS.hand_text_UI_set ~= Porkify_hand_text_UI_set_with_blank_colour then
        Porkify_hand_text_UI_set_ref = G.FUNCS.hand_text_UI_set
        G.FUNCS.hand_text_UI_set = Porkify_hand_text_UI_set_with_blank_colour
    end
end

porkify_install_blank_handname_colour_patch()

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
                copy.ability.perma_x_chips = 0
                copy.ability.perma_p_dollars = 0
                copy.ability.perma_h_dollars = 0
                copy.ability.perma_h_x_mult = 0

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
        porkify_register_too_many_blanks_hand()
        if porkify_install_draw_priority_patch then
            porkify_install_draw_priority_patch()
        end
        porkify_install_safe_can_use_consumeable_patch()
        porkify_install_safe_can_buy_and_use_patch()
        porkify_install_safe_can_skip_booster_patch()
        porkify_install_blank_play_lock_patch()
        porkify_install_blank_handname_colour_patch()
        porkify_install_blank_vanilla_joker_patch()
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
        local resolved_card, resolved_context = porkify_resolve_mimic_replay(card, context)

        if G and G.GAME then
            G.GAME.current_round = G.GAME.current_round or {}
            if resolved_context
                and resolved_context.before
                and resolved_context.cardarea == G.jokers
                and porkify_scoring_hand_has_dice_seal(resolved_context) then
                G.GAME.current_round.porkify_dice_probability_active = true
            end
        end

        local eff, post = Porkify_eval_card_pride(resolved_card, resolved_context)

        if G and G.GAME then
            G.GAME.current_round = G.GAME.current_round or {}
            if resolved_context and resolved_context.setting_blind then
                porkify_consume_no_reward_blind()
                if G.GAME.porkify_force_final_boss_pending and G.GAME.blind_choices and G.GAME.blind_choices.Boss then
                    local key = porkify_choose_final_boss_key()
                    G.GAME.blind_choices.Boss = porkify_apply_final_boss_choice(G.GAME.blind_choices.Boss, key)
                end
                porkify_apply_pending_final_boss_to_active_blind()
                G.GAME.current_round.porkify_glitched_returned_ids = {}
            end
            if resolved_context and (
                (resolved_context.after and resolved_context.cardarea == G.jokers)
                or resolved_context.end_of_round
                or resolved_context.setting_blind
                or resolved_context.hand_drawn
            ) then
                G.GAME.current_round.porkify_dice_probability_active = nil
                porkify_clear_mimic_replays()
            end
        end

        return eff, post
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

        local total_mult = 1 + pride_count
        if type(base) ~= "number" or base <= 0 then
            return total_mult
        end

        return base * total_mult
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

local function load_enhancements_folder()
    local mod_path = SMODS.current_mod.path
    local enhancements_path = mod_path .. "/enhancements"
    local files = NFS.getDirectoryItemsInfo(enhancements_path)

    local preferred_order = {
        "meteor.lua",
        "crumpled.lua",
        "revolving.lua",
        "plant.lua",
        "mirror.lua",
        "ancient.lua",
        "galaxy.lua",
        "dot.lua",
        "emerald.lua",
        "diamond.lua",
        "exclaim.lua",
        "mimic.lua",
    }

    local file_lookup = {}
    for _, info in ipairs(files) do
        if info.name and info.name:sub(-4) == ".lua" then
            file_lookup[info.name] = true
        end
    end

    for _, file_name in ipairs(preferred_order) do
        if file_lookup[file_name] then
            assert(SMODS.load_file("enhancements/" .. file_name))()
            file_lookup[file_name] = nil
        end
    end

    local remaining_files = {}
    for file_name, _ in pairs(file_lookup) do
        remaining_files[#remaining_files + 1] = file_name
    end
    table.sort(remaining_files)

    for _, file_name in ipairs(remaining_files) do
        assert(SMODS.load_file("enhancements/" .. file_name))()
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
