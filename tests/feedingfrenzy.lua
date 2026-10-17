local challenge
local mallard

SMODS = {
    Challenge = function(def) challenge = def end,
    Joker = function(def) mallard = def end,
}

function HEX(value) return value end

dofile(TEST_ROOT .. '/challenges/feedingfrenzy.lua')
dofile(TEST_ROOT .. '/jokers/mallard.lua')

assert(challenge and challenge.key == 'feedingfrenzy')
assert(challenge.loc_txt.name == 'Feeding Frenzy')
local mallard_starter
for _, starter in ipairs(challenge.jokers or {}) do
    if starter.id == 'j_porkify_mallard' then mallard_starter = starter end
end
assert(mallard_starter and mallard_starter.omega == true,
    'Feeding Frenzy must start with an Omega Mallard')
assert(mallard and mallard.eternal_compat == true,
    'Mallard must be Eternal-compatible for Omega protection to work')

local banned = {}
for _, restriction in ipairs(challenge.restrictions.banned_cards or {}) do
    banned[restriction.id] = true
end
assert(banned.m_porkify_revolving,
    'Feeding Frenzy must ban indestructible Resolute cards')
assert(banned.c_porkify_revolver,
    'Feeding Frenzy must ban Revolver as a Resolute source')
assert(banned.c_porkify_fountainofyouth,
    'Feeding Frenzy must ban Eternal Playing Card creation')
for _, joker_key in ipairs({
    'j_dna',
    'j_certificate',
    'j_marble',
    'j_porkify_fissionjoker',
}) do
    assert(banned[joker_key],
        'Feeding Frenzy must ban deck-growth Joker ' .. joker_key)
end

print('Feeding Frenzy challenge checks passed')
