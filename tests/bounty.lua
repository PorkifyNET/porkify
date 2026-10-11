local definition
SMODS = {Joker = function(d) definition = d end}
G = {
    C = {MONEY = {}, IMPORTANT = {}},
    GAME = {round_resets = {ante = 1}},
    play = {}
}

pseudoseed = function(seed) return seed end
pseudorandom_element = function(pool, seed)
    local ante = tonumber(tostring(seed):match('(%d+)$')) or 0
    return pool[(ante % #pool) + 1]
end
porkify_card_matches_rank = function(card, rank)
    return card and card.get_id and card:get_id() == rank
end

dofile(TEST_ROOT .. '/jokers/bounty.lua')
local bounty = assert(definition)
local card = {
    ability = {extra = {dollars = 2, pending_payout = 0}},
    joker_display_values = {}
}

bounty:set_ability(card, true)
assert(card.ability.extra.target_ante == 1)
assert(card.ability.extra.target_rank == 3, 'Bounty must roll its initial Ante rank')
assert(bounty:loc_vars({}, card).vars[1] == '3')

local matching = {get_id = function() return 3 end}
local miss = {get_id = function() return 4 end}
local banked = bounty:calculate(card, {individual = true, cardarea = G.play, other_card = matching})
assert(banked and card.ability.extra.pending_payout == 2)
assert(bounty:calculate(card, {individual = true, cardarea = G.play, other_card = miss}) == nil)
matching.debuff = true
assert(bounty:calculate(card, {individual = true, cardarea = G.play, other_card = matching}) == nil)
matching.debuff = nil
assert(bounty:calculate(card, {individual = true, cardarea = G.play,
    other_card = matching, retrigger_joker = true}))
assert(card.ability.extra.pending_payout == 4,
    'Retriggered scoring must bank the Bounty again')
assert(bounty:calc_dollar_bonus(card) == 4, 'Bounty must pay its bank at end of round')
assert(card.ability.extra.pending_payout == 4, 'Bounty must retain its bank within the Ante')
assert(bounty:calc_dollar_bonus(card) == 4, 'Bounty must pay its bank again next round')

bounty:calculate(card, {end_of_round = true, main_eval = true})
assert(card.ability.extra.target_rank == 3, 'Bounty rank must remain fixed within the Ante')
assert(card.ability.extra.pending_payout == 4, 'Round end must not clear the Ante bank')

bounty:calculate(card, {setting_blind = true})
assert(card.ability.extra.pending_payout == 4, 'A new round in the same Ante must retain the bank')

local changed = bounty:calculate(card, {ante_change = 1})
assert(changed and card.ability.extra.target_ante == 2)
assert(card.ability.extra.target_rank == 4, 'Bounty must reroll when the Ante changes')
assert(card.ability.extra.pending_payout == 4,
    'Ante change must preserve the Boss Blind payout until round evaluation')
assert(card.ability.extra.reset_after_payout)
assert(bounty:calc_dollar_bonus(card) == 4,
    'Bounty must pay the completed Ante bank after the Boss Blind')
assert(card.ability.extra.pending_payout == 0 and not card.ability.extra.reset_after_payout,
    'Bounty must clear the completed Ante bank after paying it')
G.GAME.round_resets.ante = 2

local display = bounty.joker_display_def({
    evaluate_hand = function() error('Bounty display must not inspect the previewed hand') end,
    calculate_card_triggers = function() error('Bounty display must not predict triggers') end
})
display.calc_function(card)
assert(card.joker_display_values.rank_text == '4')
assert(card.joker_display_values.payout_text == '+$0',
    'Bounty display must not predict earnings from the previewed hand')

print('Bounty Ante target, payout and display checks passed')
