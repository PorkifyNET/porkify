local definition

SMODS = {
    Consumable = function(def) definition = def end
}

local function area()
    return {
        highlighted = {},
        config = { highlighted_limit = 1 },
        unhighlight_all = function(self)
            self.highlighted = {}
        end
    }
end

local function object(set, key, edition)
    return {
        ability = { set = set, consumeable = set == 'Tarot' },
        config = { center = { key = key } },
        edition = edition,
        flip = function() end,
        juice_up = function() end,
        set_edition = function(self, value, immediate)
            self.edition = value
            self.edition_changed_immediately = immediate
        end
    }
end

G = {
    hand = area(),
    jokers = area(),
    consumeables = area(),
    E_MANAGER = {
        add_event = function(self, event)
            event.func()
        end
    }
}

Event = function(value) return value end
play_sound = function() end
delay = function() end

dofile(TEST_ROOT .. '/consumable_sticker_tools.lua')
dofile(TEST_ROOT .. '/consumables/cleanupcrew.lua')

for _, target_area in ipairs({ G.hand, G.jokers, G.consumeables }) do
    G.hand.highlighted, G.jokers.highlighted, G.consumeables.highlighted = {}, {}, {}
    local source = object('porkify', 'c_porkify_cleanupcrew')
    local target_set = target_area == G.hand and 'Default'
        or (target_area == G.jokers and 'Joker' or 'Tarot')
    local target = object(target_set, 'target', { foil = true })

    G.consumeables.highlighted = { source }
    definition:update(source, 0)
    assert(G.consumeables.config.highlighted_limit == 2,
        'Cleanup Crew must allow a second Consumable to be selected')

    if target_area == G.consumeables then
        G.consumeables.highlighted[2] = target
    else
        target_area.highlighted = { target }
    end

    assert(definition:can_use(source),
        'Cleanup Crew must accept editioned cards from every supported area')
    definition:use(source)
    assert(target.edition == nil and target.edition_changed_immediately,
        'Cleanup Crew must remove only the selected card Edition')
    assert(#G.hand.highlighted == 0 and #G.jokers.highlighted == 0
        and #G.consumeables.highlighted == 0,
        'Cleanup Crew must clear all selections after use')
    assert(G.consumeables.config.highlighted_limit == 1)
end

local source = object('porkify', 'c_porkify_cleanupcrew')
local uneditioned = object('Default', 'target')
G.consumeables.highlighted = { source }
G.hand.highlighted = { uneditioned }
assert(not definition:can_use(source), 'Cleanup Crew requires an Edition-bearing target')

uneditioned.edition = { holo = true }
G.jokers.highlighted = { object('Joker', 'second', { polychrome = true }) }
assert(not definition:can_use(source), 'Cleanup Crew must reject multiple selected targets')

print('Cleanup Crew Edition removal checks passed for all card areas')
