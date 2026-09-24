local definition
SMODS = {Joker = function(d) definition = d end}
G = {play = {}, hand = {}, P_CENTERS = {m_lucky = {}, m_glass = {}, c_base = {}}}
porkify_is_blank_seal_card = function(c) return c.seal == 'porkify_blank' and not c.debuff end
dofile(TEST_ROOT .. '/jokers/luckynumber7s.lua')
local joker = {}
local function card(id, center, area)
    return {base = {id = id}, config = {center = center}, area = area,
        get_id = function() error('Recursive rank lookup') end}
end
local seven = card(7, {key = 'm_glass'}, G.play)
assert(definition:calculate(joker, {check_enhancement = true, other_card = seven}).m_lucky)
assert(seven.config.center.key == 'm_glass')
assert(definition:calculate(joker, {individual = true, other_card = seven}) == nil)
assert(definition:calculate(joker, {check_enhancement = true, other_card = seven, blueprint = true}) == nil)
for _, target in ipairs({card(8, {}, G.play), card(7, {no_rank = true}, G.play), card(7, {}, G.hand)}) do
    assert(definition:calculate(joker, {check_enhancement = true, other_card = target}) == nil)
end
SMODS.optional_features = {quantum_enhancements = true}
copy_table = function(t) local c = {}; for k,v in pairs(t) do c[k] = v end; return c end
SMODS.calculate_context = function(ctx, results)
    local result = definition:calculate(joker, ctx)
    if result then results[1] = {jokers = result} end
end
-- Injected Steamodded helpers merge Lucky with existing enhancements.
TEST_install_enhancements()
local enhancements = SMODS.get_enhancements(seven)
assert(enhancements.m_glass and enhancements.m_lucky)
seven.config.center = {key = 'm_lucky'}
SMODS.enh_cache:clear()
assert(next(SMODS.get_enhancements(seven, true)) == nil, 'Already Lucky must not gain a duplicate')
seven.area = G.hand
seven.config.center = {key = 'c_base'}
SMODS.enh_cache:clear()
assert(not SMODS.get_enhancements(seven).m_lucky)
assert(not definition.blueprint_compat)
print('Lucky Number 7s enhancement, stacking and played-card checks passed')
