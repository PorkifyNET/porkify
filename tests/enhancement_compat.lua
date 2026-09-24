SMODS.optional_features = {quantum_enhancements = true}
G = {hand = {}, P_CENTERS = {c_base = {}, m_lucky = {}, m_stone = {replace_base_card = true}}, P_SEALS = {}}
SMODS.Stickers = {}
copy_table = function(t) local copy = {}; for k,v in pairs(t) do copy[k] = v end; return copy end
SMODS.calculate_context = function(context, effects)
    if context.other_card.lucky then effects[1] = {jokers = {m_lucky = true}} end
end
TEST_install_enhancements()
local stake = {config = {center = {key = 'stake_white'}}, ability = {set = 'Stake'}}
local ok = pcall(SMODS.has_playing_card_property, stake, 'replace_base_card')
assert(not ok, 'Reproduce the reported Steamodded failure before applying the fix')
dofile(TEST_ROOT .. '/enhancement_compat.lua')
assert(not SMODS.has_playing_card_property(stake, 'replace_base_card'))
assert(next(SMODS.get_enhancements(stake)) == nil)
assert(SMODS.enh_cache.data[stake].stake_white, 'Do not modify the underlying cached result')
local stone = {config = {center = {key = 'm_stone'}}, ability = {set = 'Enhanced'}, lucky = true}
assert(SMODS.has_playing_card_property(stone, 'replace_base_card'))
local enhancements = SMODS.get_enhancements(stone)
assert(enhancements.m_stone and enhancements.m_lucky)
local extras = SMODS.get_enhancements(stone, true)
assert(extras.m_lucky and not extras.m_stone)
SMODS.optional_features.quantum_enhancements = false
assert(not SMODS.has_playing_card_property(stake, 'replace_base_card'))
assert(SMODS.has_playing_card_property(stone, 'replace_base_card'))
print('Stake-preview crash reproduced; compatibility and real-enhancement checks passed')
