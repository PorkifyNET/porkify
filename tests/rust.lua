-- The runner supplies the installed Steamodded enhancement lookup and card predicate.
local rust
SMODS.Blind = function(def) rust = def end
HEX = function(value) return value end
G = {hand = {}, P_CENTERS = {
    c_base = {key = 'c_base', set = 'Default'},
    j_joker = {key = 'j_joker', set = 'Joker'},
    c_strength = {key = 'c_strength', set = 'Tarot'},
    m_stone = {key = 'm_stone', set = 'Enhanced'},
    m_lucky = {key = 'm_lucky', set = 'Enhanced'},
    m_porkify_revolving = {key = 'm_porkify_revolving', set = 'Enhanced'},
}}
SMODS.enh_cache = {
    read = function(self, card) return self[card] end,
    write = function(self, card, value) self[card] = value end,
}
local extra
SMODS.calculate_context = function(context, result)
    if extra then result[1] = {[extra] = true} end
end
local function card(key)
    local center = G.P_CENTERS[key]
    return {ability = {set = center.set}, config = {center = center}}
end
dofile('blinds/Rust.lua')
for _, quantum in ipairs({false, true}) do
    SMODS.optional_features = {quantum_enhancements = quantum}
    assert(not rust:recalc_debuff(nil))
    assert(not rust:recalc_debuff(card('j_joker')), 'Jokers must not be debuffed')
    assert(not rust:recalc_debuff(card('c_strength')), 'Consumables must not be debuffed')
    assert(not rust:recalc_debuff(card('c_base')), 'Unenhanced cards must not be debuffed')
    assert(rust:recalc_debuff(card('m_stone')), 'Enhanced playing cards must be debuffed')
    assert(not rust:recalc_debuff(card('m_porkify_revolving')), 'Preserve Revolving exemption')
end
extra = 'm_lucky'
assert(rust:recalc_debuff(card('c_base')), 'Recognize additional quantum enhancements')
extra = 'j_joker'
assert(not rust:recalc_debuff(card('c_base')), 'Non-enhancement centers do not count')
print('Rust regression checks passed (quantum enhancements on and off)')
