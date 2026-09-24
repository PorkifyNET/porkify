local definitions = {}
SMODS = {
    Joker = function(def) definitions[def.key] = def end,
    has_no_rank = function(card) return card.rankless end,
    has_enhancement = function(card, key) return card.enhancement == key end,
    is_eternal = function(card) return card.eternal end,
    shatters = function(card) return card.glass end,
    calculate_context = function() end,
    score_card = function(card) card.scored = true; return true end,
}
G = { hand = { config = { card_limit = 8 } }, C = { MULT = {} } }
function localize(key) return key end
function card_eval_status_text() end
function check_for_unlock() end
-- Use Steamodded's real destruction helper, injected by the Python runner.
SMODS.destroy_cards = TEST_destroy_cards
dofile(TEST_ROOT .. '/jokers/jester.lua')
dofile(TEST_ROOT .. '/jokers/pickaxe.lua')
local jester, pickaxe = definitions.jester, definitions.pickaxe
local j = { ability = { extra = { per_size = 0.25 } } }
for _, size in ipairs({ 0, 4, 8, 12 }) do
    G.hand.cards = {}
    for i = 1, size do G.hand.cards[i] = {} end
    assert(jester:calculate(j, { joker_main = true }).x_chips == 1 + size * 0.25)
    assert(jester:loc_vars({}, j).vars[2] == 1 + size * 0.25)
end
assert(jester:calculate(j, { before = true }) == nil)
local function miner()
    return { ability = { extra = { x_mult = 1, gain = 0.2 } } }
end
local function playing(rankless, eternal, protected)
    return { rankless = rankless, eternal = eternal, base = { name = 'test' },
        start_dissolve = function(self)
            if protected then return false end
            self.dissolve = 0
        end }
end
local p = miner()
local stone, meteor, exclaim, mimic = playing(true), playing(true), playing(true), playing(true)
local ranked, eternal, protected = playing(false), playing(true, true), playing(true, false, true)
local already_destroyed = playing(true)
already_destroyed.destroyed = true
local hand = { stone, meteor, exclaim, mimic, ranked, eternal, protected, already_destroyed }
local scoring = { stone, meteor, exclaim, mimic, ranked, eternal, protected }
assert(pickaxe:calculate(p, { after = true, full_hand = hand }) == nil)
assert(pickaxe:calculate(p, { joker_main = true }).x_mult == 1)
pickaxe:calculate(p, { before = true, scoring_hand = scoring, full_hand = hand }).func()
assert(math.abs(p.ability.extra.x_mult - 1.8) < 1e-9)
assert(stone.dissolve == 0 and meteor.dissolve == 0 and exclaim.dissolve == 0 and mimic.dissolve == 0)
assert(not ranked.destroyed and not eternal.destroyed and protected.dissolve == nil)
assert(#scoring == 3 and scoring[1] == ranked and scoring[2] == eternal and scoring[3] == protected)
for _, target in ipairs(hand) do SMODS.score_card(target, {}) end
assert(not stone.scored and not meteor.scored and not exclaim.scored and not mimic.scored)
assert(ranked.scored and eternal.scored and protected.scored)
local second = miner()
pickaxe:calculate(second, { before = true, scoring_hand = scoring, full_hand = hand }).func()
assert(second.ability.extra.x_mult == 1, 'Do not claim another Pickaxe destruction')
assert(pickaxe:calculate(p, { before = true, scoring_hand = scoring, full_hand = hand, blueprint = true }) == nil)
assert(pickaxe:calculate(p, { before = true, scoring_hand = scoring, full_hand = hand, retrigger_joker = true }) == nil)
assert(pickaxe:calculate(p, { joker_main = true, blueprint = true }).x_mult == p.ability.extra.x_mult)
print('Jester held-card scaling and Pickaxe destruction/ownership checks passed.')
