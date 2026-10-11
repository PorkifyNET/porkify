local definitions = {}
SMODS = {Tag = function(definition) definitions[definition.key] = definition end}
G = {P_CENTERS = {e_porkify_gilded = {key = 'e_porkify_gilded'}}}

local gold_call, enhanced_call
Porkify_apply_gold_shop_joker_tag = function(tag, context)
    gold_call = {tag, context}
    return 'gold'
end
Porkify_apply_enhanced_deck_tag = function(tag, context, amount)
    enhanced_call = {tag, context, amount}
    return 'enhanced'
end

dofile(TEST_ROOT .. '/tags/goldseal.lua')
dofile(TEST_ROOT .. '/tags/enhanced.lua')

local gold = assert(definitions.gold_seal)
local enhanced = assert(definitions.enhanced)
assert(gold.loc_txt.name == 'Gold Tag')
assert(gold.config.type == 'store_joker_create')
assert(gold:apply({}, {type = 'store_joker_create'}) == 'gold')
assert(gold_call[2].type == 'store_joker_create')

assert(enhanced.config.type == 'new_blind_choice')
assert(enhanced:loc_vars().vars[1] == 3)
assert(enhanced:apply({}, {type = 'new_blind_choice'}) == 'enhanced')
assert(enhanced_call[3] == 3)

print('Gold and Enhanced Tag definition checks passed')
