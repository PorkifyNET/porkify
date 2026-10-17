local definition
local original_calls = {}
local used = {}

SMODS = {
    Challenge = function(def) definition = def end,
    get_new_blind = function(blind_type)
        original_calls[#original_calls + 1] = blind_type
        return "bl_normal_" .. tostring(blind_type)
    end,
    add_boss_to_used_table = function(key, blind_type)
        used[#used + 1] = { key = key, blind_type = blind_type }
    end,
    is_showdown_ante = function()
        return G.GAME.round_resets.ante % G.GAME.win_ante == 0
            and G.GAME.round_resets.ante > 0
    end,
}
G = {
    GAME = {
        modifiers = {},
        round_resets = { ante = 1 },
        win_ante = 8,
    }
}
function HEX(value) return value end

dofile(TEST_ROOT .. "/challenges/pandemic.lua")

assert(definition and definition.key == "pandemic")
assert(definition.rules.custom[1].id == "porkify_pandemic")

local function restricted(field, id)
    for _, entry in ipairs(definition.restrictions[field] or {}) do
        if entry.id == id then return true end
    end
    return false
end

assert(restricted("banned_cards", "v_directors_cut"))
assert(restricted("banned_cards", "v_retcon"))
assert(restricted("banned_cards", "c_porkify_fountainofyouth"))
assert(restricted("banned_cards", "j_chicot"))
assert(restricted("banned_cards", "j_luchador"))
assert(restricted("banned_cards", "c_porkify_tranquilizer"))
assert(restricted("banned_cards", "j_porkify_swoon"))
assert(restricted("banned_cards", "j_porkify_thehospital"))
assert(restricted("banned_tags", "tag_boss"))
assert(restricted("banned_other", "bl_final_vessel"))
assert(restricted("banned_other", "bl_final_bell"))
assert(SMODS.get_new_blind("boss") == "bl_normal_boss",
    "Pandemic must not affect normal runs")

G.GAME.modifiers.porkify_pandemic = true
assert(SMODS.get_new_blind("small") == "bl_normal_small",
    "Pandemic must not replace non-Boss Blinds")
assert(SMODS.get_new_blind("boss") == "bl_porkify_virus",
    "Pandemic must replace every Boss Blind with The Virus")
assert(#used == 1 and used[1].key == "bl_porkify_virus"
    and used[1].blind_type == "boss",
    "Pandemic must register The Virus as the selected Boss")
assert(#original_calls == 2,
    "Pandemic Boss selection must bypass the normal random pool")

G.GAME.round_resets.ante = 8
assert(SMODS.get_new_blind("boss") == "bl_normal_boss",
    "Pandemic must preserve Showdown Blinds")
assert(#used == 1 and #original_calls == 3,
    "Showdown selection must use the normal Boss pool")

print("Pandemic preserves Showdowns and forces The Virus for regular Bosses")
