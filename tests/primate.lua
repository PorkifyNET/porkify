local definition, events, created
SMODS = {
    Consumable = function(d) definition = d end,
    add_card = function(args)
        assert(args.edition == nil)
        created = args.key
        table.insert(G.jokers.cards, args)
        return {set_edition = function() error('Must not force Negative') end}
    end
}
G = {GAME = {pool_flags = {}, joker_buffer = 0}, jokers = {cards = {}, config = {card_limit = 2}},
    P_CENTERS = {j_gros_michel = {}, j_cavendish = {}},
    E_MANAGER = {add_event = function(self, e) table.insert(events, e) end}}
Event = function(e) return e end
play_sound = function() end
delay = function() end
events = {}
dofile(TEST_ROOT .. '/consumables/primate.lua')
local card = {juice_up = function() end}
assert(definition:can_use(card))
local queue = {}
definition:loc_vars(queue, card)
assert(queue[1] == G.P_CENTERS.j_gros_michel)
definition:use(card)
assert(G.GAME.joker_buffer == 1 and not created)
events[1].func()
assert(created == 'j_gros_michel' and G.GAME.joker_buffer == 0)
G.GAME.pool_flags.gros_michel_extinct = true
queue = {}
definition:loc_vars(queue, card)
assert(queue[1] == G.P_CENTERS.j_cavendish)
definition:use(card)
assert(not definition:can_use(card), 'Pending creation reserves the final slot')
events[2].func()
assert(created == 'j_cavendish' and #G.jokers.cards == 2)
assert(not definition:can_use(card))
definition:use(card)
assert(#events == 2)
G.jokers.cards = {}
G.GAME.joker_buffer = 1
definition:use(card)
events[3].func()
assert(G.GAME.joker_buffer == 1, 'Do not clear another effect reservation')
print('Primate extinction, creation and Joker-slot checks passed')
