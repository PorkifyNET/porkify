local definition, roll
SMODS = {Joker = function(d) definition = d end}
G = {P_CENTERS = {m_bonus = {}}, P_SEALS = {Red = {}}, C = {ORANGE = {}}}
pseudoseed = function(s) return s end
pseudorandom = function() return roll end
pseudorandom_element = function(t) return t[1] end
Porkify_pick_random_enhancement_key = function() return 'm_bonus' end
card_eval_status_text = function() end
dofile(TEST_ROOT .. '/jokers/milestone.lua')
local function playing()
    return {set_ability = function(c) c.enhanced = true end,
        set_edition = function(c) c.edition = true end,
        set_seal = function(c) c.seal = true end}
end
for _, case in ipairs({{0, 'enhanced'}, {0.5, 'edition'}, {0.9, 'seal'}}) do
    roll = case[1]
    local joker = {ability = {extra = {scored_cards = 8, cards_needed = 10}}, juice_up = function() end}
    local first, tenth, excluded = playing(), playing(), playing()
    excluded.debuff = true
    definition:calculate(joker, {before = true, scoring_hand = {first, excluded, tenth}}).func()
    assert(joker.ability.extra.scored_cards == 10)
    assert(tenth[case[2]] and not first[case[2]] and not excluded[case[2]])
    assert(definition:calculate(joker, {individual = true, other_card = tenth}) == nil)
    assert(definition:calculate(joker, {before = true, blueprint = true}) == nil)
    assert(definition:calculate(joker, {before = true, retrigger_joker = true}) == nil)
    local cards = {}
    for i = 1, 20 do cards[i] = playing() end
    definition:calculate(joker, {before = true, scoring_hand = cards}).func()
    assert(cards[10][case[2]] and cards[20][case[2]])
    assert(joker.ability.extra.scored_cards == 30)
end
print('Milestone before-scoring upgrades and counting checks passed')
