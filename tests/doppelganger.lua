local definition
local jokers = {}
G = { GAME = { blind = { boss = true } }, I = { CARD = {} }, C = { MONEY = {} },
    E_MANAGER = { add_event = function(self, event) event.func() end } }
Event = function(event) return event end
SMODS = {
    Joker = function(value) definition = value end,
    find_card = function() return jokers end,
    destroy_cards = function(cards)
        for _, card in ipairs(cards) do card.destroyed = true end
    end
}
localize = function(key) return key end
Card = {}
function Card:set_cost() self.cost = self.base_cost end
dofile(TEST_ROOT .. '/jokers/doppelganger.lua')
local function voucher(price)
    local card = setmetatable({ ability = { set = 'Voucher' }, base_cost = price }, { __index = Card })
    table.insert(G.I.CARD, card)
    card:set_cost()
    return card
end
local joker = { ability = {} }
jokers = { joker }
local first, second = voucher(10), voucher(12)
local function round(extra)
    local context = { end_of_round = true, main_eval = true }
    for key, value in pairs(extra or {}) do context[key] = value end
    return definition:calculate(joker, context)
end
for _, context in ipairs({ { game_over = true }, { blueprint = true },
    { retrigger_joker = true }, { main_eval = false } }) do
    round(context)
    assert(not joker.ability.porkify_voucher_ready)
end
G.GAME.blind.boss = false
round()
assert(first.cost == 10)
-- Redeeming before activation does not destroy the Joker.
definition:calculate(joker, {buying_card = true, card = first})
assert(not joker.destroyed)
G.GAME.blind.boss = true
assert(round())
assert(first.cost == 0 and second.cost == 0)
assert(round() == nil)
local later = voucher(15)
assert(later.cost == 0)
-- Debuffing, removing and restoring the Joker refresh the prices.
joker.debuff = true
definition:remove_from_deck(joker, true)
assert(first.cost == 10)
joker.debuff = false
definition:add_to_deck(joker, true)
assert(first.cost == 0)
jokers = {}
definition:remove_from_deck(joker)
assert(first.cost == 10)
jokers = {joker}
definition:add_to_deck(joker)
assert(first.cost == 0)
-- The purchase context follows payment; the redeemed card stays at zero.
definition:calculate(joker, {buying_card = true, card = first})
assert(joker.destroyed and not joker.ability.porkify_voucher_ready)
assert(first.cost == 0 and second.cost == 12 and later.cost == 15)
-- A saved card's ability restores the discount; the old run-level flag does not.
jokers = {{ability = {porkify_voucher_ready = true}}}
assert(voucher(20).cost == 0)
jokers = {}
G.GAME.porkify_doppelganger_free_voucher = true
assert(voucher(20).cost == 20)
assert(not definition.blueprint_compat and not definition.eternal_compat)
print('Doppelganger activation, purchase, removal and debuff checks passed')
