local definition, owned
SMODS = {Joker = function(d) definition = d end, find_card = function() return owned end}
G = {C = {MONEY = {}, GREY = {}}, E_MANAGER = {add_event = function(self, e) e.func() end}}
Event = function(e) return e end
localize = function(k) return k end
Card = {set_cost = function(c) c.cost = c.base_cost end}
dofile(TEST_ROOT .. '/jokers/yardsale.lua')
local joker = {ability = {extra = {pending_discount = 0, active_discount = 0, gain = 1}}}
owned = {joker}
local pack = setmetatable({ability = {set = 'Booster'}, base_cost = 4}, {__index = Card})
G.shop_booster = {cards = {pack}}
local sale = {selling_card = true, card = {ability = {consumeable = true}}}
for i = 1, 3 do definition:calculate(joker, sale) end
pack:set_cost()
assert(pack.cost == 4)
definition:calculate(joker, {starting_shop = true})
assert(pack.cost == 1 and joker.ability.extra.pending_discount == 0)
pack:set_cost()
assert(pack.cost == 1, 'Price recalculation must not compound the discount')
G.STATES = {SHOP = 1}
G.STATE = G.STATES.SHOP
G.shop = {}
definition:calculate(joker, sale)
assert(pack.cost == 1 and joker.ability.extra.pending_discount == 1,
    'Shop sales build the next discount without changing current prices')
definition:calculate(joker, {selling_card = true, card = {ability = {set = 'Joker'}}})
definition:calculate(joker, {selling_card = true, card = sale.card, blueprint = true})
definition:calculate(joker, {selling_card = true, card = sale.card, retrigger_joker = true})
assert(joker.ability.extra.pending_discount == 1)
assert(definition:calculate(joker, {ending_shop = true}) == nil)
assert(pack.cost == 4 and joker.ability.extra.pending_discount == 1)
definition:calculate(joker, {starting_shop = true})
assert(pack.cost == 3)
joker.debuff = true
definition:remove_from_deck(joker, true)
assert(pack.cost == 4)
joker.debuff = false
definition:add_to_deck(joker, true)
assert(pack.cost == 3)
joker.ability.extra.active_discount = 10
pack:set_cost()
assert(pack.cost == 0)
owned = {}
definition:remove_from_deck(joker)
assert(pack.cost == 4)
owned = {joker}
assert(definition:calculate(joker, {ending_shop = true}) == nil)
definition:calculate(joker, {starting_shop = true})
assert(pack.cost == 4)
-- Existing saves with the old tag configuration start with no discount.
joker.ability.extra = {sold_needed = 3, tag_key = 'tag_juggle'}
definition:calculate(joker, sale)
assert(joker.ability.extra.pending_discount == 1)
print('Yard Sale discount, shop transition, capacity floor and sale checks passed')
