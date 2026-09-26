SMODS = {
    injectItems = function() return "injected" end,
    Mods = {
        porkify = {
            config = {
                content_jokers = true,
                content_consumables = true,
                content_vouchers = true,
            },
        },
    },
}

hash = function(value) return "hash:" .. value end

G = {
    GAME = { banned_keys = {} },
    UIDEF = {
        lobby_setup_tabs_definition = function()
            local snapshot = {}
            for _, category in ipairs({ "JOKERS", "CONSUMABLES", "VOUCHERS" }) do
                snapshot[category] = {}
                for _, key in ipairs(MP.DECK["BANNED_" .. category]) do
                    snapshot[category][#snapshot[category] + 1] = key
                end
            end
            return snapshot
        end,
    },
}

-- Multiplayer is intentionally absent for the first call: this is Porkify's
-- normal load order.
local compat = assert(loadfile("multiplayer_compat.lua"))()
assert(SMODS.injectItems() == "injected")

MP = {
    DECK = {
        BANNED_JOKERS = {},
        BANNED_CONSUMABLES = {},
        BANNED_VOUCHERS = {},
    },
    generate_hash = function(self)
        self.MOD_STRING = "Multiplayer-0.5.5;porkify-1.8.2"
        self.MOD_HASH = hash(self.MOD_STRING)
    end,
    Rulesets = {
        ruleset_mp_traditional = {
            key = "ruleset_mp_traditional",
            reworked_jokers = {},
            reworked_consumables = {},
        },
        ruleset_mp_vanilla = {
            key = "ruleset_mp_vanilla",
            reworked_jokers = {},
            reworked_consumables = {},
        },
    },
    ReworkCenter = function(key, opts)
        MP.registered_reworks = MP.registered_reworks or {}
        MP.registered_reworks[key] = opts
    end,
    ApplyBans = function()
        for _, category in ipairs({ "JOKERS", "CONSUMABLES", "VOUCHERS" }) do
            for _, key in ipairs(MP.DECK["BANNED_" .. category]) do
                G.GAME.banned_keys[key] = true
            end
        end
    end,
    get_active_ruleset = function()
        return MP.active_ruleset
    end,
    get_active_gamemode = function()
        return MP.active_gamemode
    end,
}

assert(SMODS.injectItems() == "injected")
assert(#MP.DECK.BANNED_JOKERS == 2)
assert(#MP.DECK.BANNED_CONSUMABLES == 4)
assert(#MP.DECK.BANNED_VOUCHERS == 2)
assert(MP.DECK.BANNED_JOKERS[1] == "j_porkify_rewind")
assert(MP.DECK.BANNED_CONSUMABLES[1] == "c_porkify_emergencyexit")
assert(MP.DECK.BANNED_VOUCHERS[1] == "v_porkify_pattern")
assert(MP.DECK.BANNED_VOUCHERS[2] == "v_porkify_tesselation")
assert(MP.Rulesets.ruleset_mp_traditional.reworked_jokers[1] == "j_porkify_headstart")
assert(MP.Rulesets.ruleset_mp_traditional.reworked_consumables[1] == "c_porkify_casualwalk")
assert(MP.Rulesets.ruleset_mp_vanilla.reworked_jokers[1] == "j_porkify_headstart")
assert(MP.registered_reworks.j_porkify_headstart.layers[1] == "traditional")
assert(MP.registered_reworks.j_porkify_headstart.layers[2] == "vanilla")
assert(MP.registered_reworks.c_porkify_casualwalk)
MP:generate_hash()
assert(MP.MOD_STRING:find(";porkify_config-", 1, true))
assert(MP.MOD_HASH == hash(MP.MOD_STRING))

local function apply_for(ruleset, gamemode)
    G.GAME.banned_keys = {}
    MP.active_ruleset = ruleset
    MP.active_gamemode = gamemode
    MP.ApplyBans()
    return G.GAME.banned_keys
end

local competitive_bans = apply_for("ruleset_mp_traditional", "gamemode_mp_attrition")
assert(competitive_bans.j_porkify_rewind)
assert(competitive_bans.c_porkify_emergencyexit)
assert(competitive_bans.v_porkify_pattern)

local survival_bans = apply_for("ruleset_mp_traditional", "gamemode_mp_survival")
assert(not survival_bans.j_porkify_rewind)
assert(not survival_bans.c_porkify_emergencyexit)
assert(not survival_bans.v_porkify_pattern)

local vanilla_bans = apply_for("ruleset_mp_vanilla", "gamemode_mp_attrition")
assert(not vanilla_bans.j_porkify_rewind)
assert(not vanilla_bans.c_porkify_emergencyexit)
assert(not vanilla_bans.v_porkify_pattern)

MP.DECK.BANNED_JOKERS[#MP.DECK.BANNED_JOKERS + 1] = "j_other_mod_ban"
local survival_screen = G.UIDEF.lobby_setup_tabs_definition(
    { key = "gamemode_mp_survival" },
    "banned"
)
assert(#survival_screen.JOKERS == 1 and survival_screen.JOKERS[1] == "j_other_mod_ban")
assert(#survival_screen.CONSUMABLES == 0)
assert(#survival_screen.VOUCHERS == 0)

-- Re-injection must not duplicate entries.
SMODS.injectItems()
assert(#MP.DECK.BANNED_JOKERS == 3)
assert(#MP.DECK.BANNED_CONSUMABLES == 4)
assert(#MP.DECK.BANNED_VOUCHERS == 2)
assert(#MP.Rulesets.ruleset_mp_traditional.reworked_jokers == 1)
assert(#MP.Rulesets.ruleset_mp_traditional.reworked_consumables == 1)
assert(compat.register() == false)

print("multiplayer compatibility tests passed")
