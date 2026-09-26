-- Porkify loads before Multiplayer, so registration is performed from the
-- final SMODS injection pass (after every mod has finished loading).
local registered = false
local reworks_registered = false
local ban_exemptions_installed = false

-- Multiplayer's built-in mod hash includes versions, but not per-mod configs.
-- Capture only settings that alter gameplay/pools; cosmetic preferences may
-- differ safely. Content settings are already frozen until restart by Porkify.
local GAMEPLAY_CONFIG_KEYS = {
    "bypass_unlock_all",
    "cerberus_slayer",
    "content_blinds",
    "content_boosters",
    "content_consumables",
    "content_jokers",
    "content_secret_hands",
    "content_tags",
    "content_vouchers",
    "infinipaul",
    "return_of_the_serpent",
    "unlimited_blanks",
}

local function build_config_signature()
    local mod = SMODS and SMODS.Mods and SMODS.Mods.porkify
    local config = (mod and mod.config) or {}
    local bits = {}
    for i, key in ipairs(GAMEPLAY_CONFIG_KEYS) do
        bits[i] = config[key] == true and "1" or "0"
    end
    return table.concat(bits)
end

local gameplay_config_signature = build_config_signature()

local BANS = {
    jokers = {
        "j_porkify_rewind", -- rewinds the ante instead of losing a life
        "j_porkify_swoon",  -- disables the PvP/Nemesis blind
    },
    consumables = {
        "c_porkify_emergencyexit", -- ends the current blind immediately
        "c_porkify_timemachine",   -- rewinds the ante
        "c_porkify_trainingwheels",-- changes the live PvP score target
        "c_porkify_tranquilizer",  -- disables the PvP/Nemesis blind
    },
    vouchers = {
        "v_porkify_pattern",      -- reads the local profile's consumable usage
        "v_porkify_tesselation",  -- reads the local profile's Joker usage
    },
}

local REWORKS = {
    jokers = {
        "j_porkify_headstart",
    },
    consumables = {
        "c_porkify_casualwalk",
    },
}

local function append_unique(list, key)
    if type(list) ~= "table" then return end
    for _, existing in ipairs(list) do
        if existing == key then return end
    end
    list[#list + 1] = key
end

local function install_config_hash()
    if type(MP.generate_hash) ~= "function" or MP.porkify_config_hash_installed then
        return
    end

    local generate_hash_ref = MP.generate_hash
    function MP:generate_hash(...)
        local result = generate_hash_ref(self, ...)
        local marker = "porkify_config-" .. gameplay_config_signature
        local wrapped = ";" .. tostring(self.MOD_STRING or "") .. ";"
        if not wrapped:find(";" .. marker .. ";", 1, true) then
            self.MOD_STRING = self.MOD_STRING == "" and marker or (self.MOD_STRING .. ";" .. marker)
            if type(hash) == "function" then
                self.MOD_HASH = hash(self.MOD_STRING) or self.MOD_HASH
            end
        end
        return result
    end
    MP.porkify_config_hash_installed = true
end

local function is_porkify_ban_exempt_key(key)
    return key == "ruleset_mp_vanilla" or key == "gamemode_mp_survival"
end

local function clear_porkify_bans_from_game()
    if not (G and G.GAME and type(G.GAME.banned_keys) == "table") then return end
    for _, keys in pairs(BANS) do
        for _, key in ipairs(keys) do
            G.GAME.banned_keys[key] = nil
        end
    end
end

local function filtered_global_bans(category)
    local source = MP.DECK["BANNED_" .. string.upper(category)] or {}
    local porkify_keys = {}
    for _, key in ipairs(BANS[category] or {}) do
        porkify_keys[key] = true
    end

    local filtered = {}
    for _, key in ipairs(source) do
        if not porkify_keys[key] then filtered[#filtered + 1] = key end
    end
    return filtered
end

local function install_ban_exemptions()
    if ban_exemptions_installed or type(MP) ~= "table" then return false end
    if type(MP.ApplyBans) ~= "function" then return false end

    local apply_bans_ref = MP.ApplyBans
    function MP.ApplyBans(...)
        local result = apply_bans_ref(...)
        local ruleset = type(MP.get_active_ruleset) == "function" and MP.get_active_ruleset() or nil
        local gamemode = type(MP.get_active_gamemode) == "function" and MP.get_active_gamemode() or nil
        if is_porkify_ban_exempt_key(ruleset) or is_porkify_ban_exempt_key(gamemode) then
            clear_porkify_bans_from_game()
        end
        return result
    end

    -- The overview reads MP.DECK directly. Temporarily substitute filtered
    -- copies so exempt modes hide Porkify's bans without hiding other mods'.
    if G and G.UIDEF and type(G.UIDEF.lobby_setup_tabs_definition) == "function" then
        local tabs_definition_ref = G.UIDEF.lobby_setup_tabs_definition
        function G.UIDEF.lobby_setup_tabs_definition(target, tab_type, ...)
            local target_key = type(target) == "table" and target.key or nil
            if tab_type ~= "banned" or not is_porkify_ban_exempt_key(target_key) then
                return tabs_definition_ref(target, tab_type, ...)
            end

            local originals = {}
            for category in pairs(BANS) do
                local field = "BANNED_" .. string.upper(category)
                originals[field] = MP.DECK[field]
                MP.DECK[field] = filtered_global_bans(category)
            end

            local results = { pcall(tabs_definition_ref, target, tab_type, ...) }
            for field, original in pairs(originals) do
                MP.DECK[field] = original
            end
            if not results[1] then error(results[2], 0) end
            return results[2]
        end
    end

    ban_exemptions_installed = true
    return true
end

local function register_multiplayer_reworks()
    if reworks_registered
        or type(MP) ~= "table"
        or type(MP.ReworkCenter) ~= "function"
        or type(MP.Rulesets) ~= "table" then
        return false
    end

    local layers = {}
    for ruleset_key, ruleset in pairs(MP.Rulesets) do
        if type(ruleset) == "table" then
            local layer = tostring(ruleset.key or ruleset_key):gsub("^ruleset_mp_", "")
            if layer ~= "" then
                layers[#layers + 1] = layer
                append_unique(ruleset.reworked_jokers, REWORKS.jokers[1])
                append_unique(ruleset.reworked_consumables, REWORKS.consumables[1])
            end
        end
    end

    if #layers == 0 then return false end
    table.sort(layers)

    -- These calls make Multiplayer apply its Balanced sticker only while a
    -- Multiplayer ruleset is active. The mechanics themselves live on the
    -- original Porkify centers because they are compatibility safeguards.
    MP.ReworkCenter(REWORKS.jokers[1], { layers = layers })
    MP.ReworkCenter(REWORKS.consumables[1], { layers = layers })
    reworks_registered = true
    return true
end

local function register_multiplayer_bans()
    if type(MP) ~= "table" or type(MP.DECK) ~= "table" then
        return false
    end

    register_multiplayer_reworks()
    install_config_hash()
    install_ban_exemptions()
    if registered then return false end

    -- Write to the category tables directly. Multiplayer 0.5.5's ban_card
    -- helper does not route c_* keys to BANNED_CONSUMABLES.
    for _, key in ipairs(BANS.jokers) do
        append_unique(MP.DECK.BANNED_JOKERS, key)
    end
    for _, key in ipairs(BANS.consumables) do
        append_unique(MP.DECK.BANNED_CONSUMABLES, key)
    end
    for _, key in ipairs(BANS.vouchers) do
        append_unique(MP.DECK.BANNED_VOUCHERS, key)
    end

    registered = true
    return true
end

-- Also handles unusual setups where Multiplayer was loaded first.
register_multiplayer_bans()

local inject_items_ref = SMODS.injectItems
function SMODS.injectItems(...)
    local result = inject_items_ref(...)
    register_multiplayer_bans()
    return result
end

return {
    register = register_multiplayer_bans,
    bans = BANS,
    reworks = REWORKS,
}
