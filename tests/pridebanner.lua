local definition

SMODS = {
    Joker = function(def) definition = def end,
}

function localize(key) return key end

dofile(TEST_ROOT .. '/jokers/pridebanner.lua')

assert(definition and definition.key == 'pridebanner')
assert(definition.blueprint_compat,
    'Pride Banner must support Blueprint copies')

local main = assert(io.open(TEST_ROOT .. '/main.lua', 'r')):read('*a')
assert(main:find('retrigger_joker = true', 1, true),
    'Pride Banner requires the Joker retrigger optional feature')

local banner = {}
local function card(set, polychrome)
    return {
        ability = { set = set },
        edition = polychrome and { polychrome = true } or nil,
    }
end

local playing_card = card('Default', true)
local playing_result = definition:calculate(banner, {
    repetition = true,
    other_card = playing_card,
})
assert(playing_result and playing_result.repetitions == 1,
    'Polychrome playing cards must retrigger')

for _, set in ipairs({ 'Joker', 'Tarot' }) do
    local result = definition:calculate(banner, {
        retrigger_joker_check = true,
        other_card = card(set, true),
    })
    assert(result and result.repetitions == 1,
        'Polychrome ' .. set .. ' cards must retrigger')
end

assert(not definition:calculate(banner, {
    repetition = true,
    other_card = card('Default', false),
}), 'Cards without Polychrome must not retrigger')

assert(not definition:calculate(banner, {
    individual = true,
    other_card = playing_card,
}), 'Pride Banner must only return repetitions in retrigger checks')

print('Pride Banner Polychrome retrigger checks passed')
