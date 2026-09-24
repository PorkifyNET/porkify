local blinds, checks = {}, 0
SMODS.Blind = function(def) blinds[def.key] = def end
for _, file in ipairs({ 'Prideful', 'Plunger', 'Twins' }) do
    dofile(TEST_ROOT .. '/blinds/' .. file .. '.lua')
end

-- Each row specifies whether the scoring hand is a straight, flush, or pair-family hand.
local cases = {
    { 'porkify_double_trouble', false, false, true },
    { 'porkify_four_plus_two', false, false, true },
    { 'porkify_boarding_house', false, false, true },
    { 'porkify_five_plus_two', false, false, true },
    { 'porkify_apartment_block', false, false, true },
    { 'porkify_mansion', false, false, true },
    { 'porkify_six_plus_two', false, false, true },
    { 'porkify_flush_three_pair', false, true, true },
    { 'porkify_flush_four_pair', false, true, true },
    { 'porkify_flush_fuller_house', false, true, true },
    { 'porkify_flush_fullest_house', false, true, true },
    { 'porkify_flush_two_by_fours', false, true, true },

    { 'High Card', false, false, false },
    { 'Pair', false, false, true },
    { 'Two Pair', false, false, true },
    { 'Three of a Kind', false, false, true },
    { 'Straight', true, false, false },
    { 'Flush', false, true, false },
    { 'Full House', false, false, true },
    { 'Four of a Kind', false, false, true },
    { 'Straight Flush', true, true, false },
    { 'Royal Flush', true, true, false },
    { 'Five of a Kind', false, false, true },
    { 'Flush House', false, true, true },
    { 'Flush Five', false, true, true },
    { 'porkify_three_pair', false, false, true },
    { 'porkify_four_pair', false, false, true },
    { 'porkify_straighter', true, false, false },
    { 'porkify_straightest', true, false, false },
    { 'porkify_straighterest', true, false, false },
    { 'porkify_straighter_flush', true, true, false },
    { 'porkify_straightest_flush', true, true, false },
    { 'porkify_straighterest_flush', true, true, false },
    { 'porkify_flushier', false, true, false },
    { 'porkify_flushiest', false, true, false },
    { 'porkify_flushiester', false, true, false },
    { 'porkify_fuller_house', false, false, true },
    { 'porkify_fullest_house', false, false, true },
    { 'porkify_two_by_fours', false, false, true },
    { 'porkify_six_of_a_kind', false, false, true },
    { 'porkify_seven_of_a_kind', false, false, true },
    { 'porkify_eight_of_a_kind', false, false, true },
    { 'porkify_flush_six', false, true, true },
    { 'porkify_flush_seven', false, true, true },
    { 'porkify_flush_eight', false, true, true },
    { 'porkify_bulwark', false, false, false },
    { 'porkify_yes', false, false, false },
    { 'porkify_too_many_blanks', false, false, false },
}
local covered = {}
for _, case in ipairs(cases) do
    covered[case[1]] = true
    for i, name in ipairs({ 'prideful', 'plunger', 'twins' }) do
        for _, preview in ipairs({ true, false }) do
            local result = blinds[name]:debuff_hand({}, {}, case[1], preview)
            assert(result == case[i + 1], name .. ': incorrect debuff for ' .. case[1])
            checks = checks + 1
        end
    end
end
for name in pairs(PORKIFY_SECRET_HANDS) do assert(covered[name], 'Untested secret hand: ' .. name) end
print('Passed ' .. checks .. ' Boss Blind hand checks (preview and scoring).')
