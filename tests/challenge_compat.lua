local function center(key)
    return { key = key }
end

G = {
    P_CENTER_POOLS = {
        Tarot = { center('c_fool'), center('c_emperor') },
        Spectral = { center('c_familiar'), center('c_soul') },
        Planet = { center('c_mercury'), center('c_pluto') },
        Joker = {
            { key = 'j_eternal_ok', eternal_compat = true },
            { key = 'j_no_eternal', eternal_compat = false },
        },
    },
    CHALLENGES = {
        { id = 'c_porkify_noheresy', restrictions = { banned_cards = { { id = 'c_fool' } } } },
        { id = 'c_porkify_noastronomy', restrictions = { banned_cards = {} } },
        { id = 'c_porkify_ragsnriches', restrictions = { banned_cards = {} } },
        { id = 'c_five_card_1', restrictions = { banned_cards = {} } },
        { id = 'c_blast_off_1', restrictions = { banned_cards = {} } },
        { id = 'c_golden_needle_1', restrictions = { banned_cards = {} } },
        { id = 'c_monolith_1', restrictions = { banned_cards = {} } },
        { id = 'c_jokerless_1', restrictions = { banned_cards = {}, banned_tags = {} } },
        { id = 'c_porkify_orchard', restrictions = { banned_cards = {}, banned_tags = {} } },
        { id = 'c_porkify_thechosenone', restrictions = { banned_cards = {}, banned_tags = {} } },
        { id = 'c_porkify_riffraffle', restrictions = { banned_cards = {}, banned_tags = {} } },
        { id = 'c_non_perishable_1',
            rules = { custom = { { id = 'all_eternal', value = true } } },
            restrictions = { banned_cards = function()
                return { { id = 'j_popcorn' } }
            end } },
        { id = 'c_typecast_1',
            rules = { custom = { { id = 'set_eternal_ante', value = 4 } } },
            restrictions = { banned_cards = {} } },
        { id = 'c_inflation_1', restrictions = { banned_cards = {} } },
        { id = 'c_fragile_1', restrictions = { banned_cards = {}, banned_tags = {} } },
        { id = 'c_porkify_chickenfarm', restrictions = {
            banned_cards = {}, banned_tags = {}, banned_other = {}
        } },
        { id = 'c_porkify_flashlight', restrictions = {
            banned_cards = {}, banned_tags = {}, banned_other = {}
        } },
        { id = 'c_porkify_greenworld',
            jokers = {
                { id = 'j_green_joker', omega = true },
                { id = 'j_porkify_recycler', omega = true },
            },
            restrictions = {
                banned_cards = {}, banned_tags = {}, banned_other = {}
            } },
        { id = 'c_porkify_kingmidas', restrictions = {
            banned_cards = {}, banned_tags = {}, banned_other = {}
        } },
        { id = 'c_porkify_letsgogambling', restrictions = {
            banned_cards = {}, banned_tags = {}, banned_other = {}
        } },
        { id = 'c_porkify_roadblocked', restrictions = {
            banned_cards = { { id = 'j_porkify_cairn' } }, banned_tags = {}, banned_other = {}
        } },
        { id = 'c_porkify_wysiwyg', restrictions = {
            banned_cards = {}, banned_tags = {}, banned_other = {}
        } },
    },
}

SMODS = {
    Centers = {
        porkify_no_eternal = { key = 'j_porkify_no_eternal', eternal_compat = false, set = 'Joker' },
        porkify_eternal_ok = { key = 'j_porkify_eternal_ok', eternal_compat = true, set = 'Joker' },
        porkify_consumable = { key = 'c_porkify_not_a_joker', eternal_compat = false, set = 'porkify' },
        porkify_planet = { key = 'c_porkify_planet_three_pair', set = 'Planet' },
    },
}

local compat = assert(loadfile(TEST_ROOT .. '/challenge_compat.lua'))()
compat.apply()
compat.apply() -- The pass is safe if another loader invokes it twice.

local function challenge(id)
    for _, value in ipairs(G.CHALLENGES) do
        if value.id == id then return value end
    end
    error('missing challenge ' .. id)
end

local function count_id(id, wanted)
    local count = 0
    for _, entry in ipairs(challenge(id).restrictions.banned_cards) do
        if entry.id == wanted then count = count + 1 end
    end
    return count
end

local function count_tag(id, wanted)
    local count = 0
    for _, entry in ipairs(challenge(id).restrictions.banned_tags) do
        if entry.id == wanted then count = count + 1 end
    end
    return count
end

local function count_other(id, wanted)
    local count = 0
    for _, entry in ipairs(challenge(id).restrictions.banned_other) do
        if entry.id == wanted and entry.type == 'blind' then count = count + 1 end
    end
    return count
end

assert(count_id('c_porkify_noheresy', 'c_fool') == 1)
assert(count_id('c_porkify_noheresy', 'c_emperor') == 1)
assert(count_id('c_porkify_noheresy', 'c_soul') == 1)
assert(count_id('c_porkify_noheresy', 'j_porkify_chance') == 1)
assert(count_id('c_porkify_noastronomy', 'c_mercury') == 1)
assert(count_id('c_porkify_noastronomy', 'c_pluto') == 1)
assert(count_id('c_porkify_noastronomy', 'c_porkify_planet_three_pair') == 1)
assert(count_id('c_porkify_noastronomy', 'j_porkify_shootingstar') == 1)
assert(count_id('c_five_card_1', 'j_porkify_appletree') == 1)
assert(count_id('c_blast_off_1', 'j_porkify_aquacard') == 1)
assert(count_id('c_golden_needle_1', 'j_porkify_aquacard') == 1)
assert(count_id('c_monolith_1', 'c_porkify_finalfrontier') == 1)
assert(count_id('c_jokerless_1', 'p_porkify_common_joker_pack') == 1)
assert(count_tag('c_jokerless_1', 'tag_porkify_gold_seal') == 1)
assert(count_id('c_porkify_orchard', 'j_porkify_netanyahu') == 1)
assert(count_tag('c_porkify_thechosenone', 'tag_joker') == 1)
assert(count_tag('c_porkify_riffraffle', 'tag_topup') == 1)
assert(count_id('c_non_perishable_1', 'j_popcorn') == 1)
assert(count_id('c_non_perishable_1', 'j_no_eternal') == 1)
assert(count_id('c_non_perishable_1', 'j_porkify_no_eternal') == 1)
assert(count_id('c_non_perishable_1', 'j_eternal_ok') == 0)
assert(count_id('c_non_perishable_1', 'c_porkify_not_a_joker') == 0)
assert(count_id('c_typecast_1', 'c_porkify_excalibur') == 0)
assert(challenge('c_typecast_1').porkify_omega_eternal_ante == 4)
assert(challenge('c_typecast_1').rules.custom[1].no_ui)
assert(challenge('c_typecast_1').rules.custom[2].id == 'porkify_set_omega_ante')
assert(count_id('c_inflation_1', 'j_porkify_yardsale') == 1)
assert(count_id('c_inflation_1', 'j_porkify_greencard') == 1)
assert(count_id('c_inflation_1', 'j_porkify_doppelganger') == 1)
assert(count_id('c_fragile_1', 'j_porkify_shipwreck') == 1)
assert(count_id('c_fragile_1', 'c_porkify_medusa') == 1)
assert(count_tag('c_fragile_1', 'tag_porkify_mimic') == 1)
assert(count_id('c_porkify_chickenfarm', 'j_porkify_yellowcard') == 1)
assert(count_id('c_porkify_chickenfarm', 'v_porkify_heirloom') == 1)
assert(count_other('c_porkify_flashlight', 'bl_porkify_tax') == 1)
assert(count_id('c_porkify_greenworld', 'j_porkify_mallard') == 1)
assert(count_id('c_porkify_greenworld', 'c_hex') == 1)
assert(count_id('c_porkify_greenworld', 'm_glass') == 1)
assert(count_id('c_porkify_kingmidas', 'j_porkify_grandma') == 1)
assert(count_id('c_porkify_letsgogambling', 'c_porkify_doubleornothing') == 1)
assert(count_id('c_porkify_letsgogambling', 'j_porkify_bounty') == 1)
assert(count_tag('c_porkify_letsgogambling', 'tag_porkify_enhanced') == 1)
assert(count_id('c_porkify_roadblocked', 'j_porkify_cairn') == 1)
assert(count_id('c_porkify_wysiwyg', 'j_porkify_fissionjoker') == 1)
assert(count_id('c_porkify_wysiwyg', 'c_porkify_surgery') == 1)
assert(count_id('c_porkify_wysiwyg', 'm_glass') == 1)
assert(count_tag('c_porkify_wysiwyg', 'tag_porkify_gravitas') == 1)

assert(challenge('c_non_perishable_1').rules.custom[1].id == 'all_omega')
local green_world = challenge('c_porkify_greenworld')
assert(green_world.jokers[1].porkify_omega and not green_world.jokers[1].eternal)
assert(green_world.porkify_omega_starters.j_green_joker == 1)
G.GAME = {}
green_world:apply()
assert(G.GAME.porkify_omega_starters.j_green_joker == 1)
challenge('c_typecast_1'):apply()
assert(G.GAME.porkify_omega_eternal_ante == 4)
G.GAME.porkify_omega_starters.j_green_joker = 0
green_world:apply()
assert(G.GAME.porkify_omega_starters.j_green_joker == 1)

-- Vanilla starter definitions must lose their Eternal placeholder so both
-- the challenge preview and real run can display Omega instead.
local vanilla_starter = {
    id = 'c_city_1',
    jokers = { { id = 'j_shortcut', eternal = true } },
    restrictions = { banned_cards = {} },
}
G.CHALLENGES[#G.CHALLENGES + 1] = vanilla_starter
compat.apply()
assert(vanilla_starter.jokers[1].porkify_omega)
assert(not vanilla_starter.jokers[1].eternal)

print('Challenge compatibility checks passed')
