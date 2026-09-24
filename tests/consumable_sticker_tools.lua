local definitions = {}
SMODS = {Consumable = function(def) definitions[def.key] = def end}
HEX = function(value) return value end
to_big = function(value) return value end
local unlocks = {}
check_for_unlock = function(args) unlocks[#unlocks + 1] = args.type end
play_sound = function() end
delay = function() end
card_eval_status_text = function() end
Event = function(args) return args end
local function area()
    return {
        highlighted = {}, config = {highlighted_limit = 1},
        unhighlight_all = function(self) self.highlighted = {} end,
    }
end
G = {
    hand = area(), jokers = area(), consumeables = area(),
    P_STICKERS = {}, P_CENTERS = {}, C = {GREEN = {}},
    E_MANAGER = {add_event = function(self, event) event.func() end},
}
local function object(set, key)
    local result = {
        ability = {set = set, consumeable = set == 'Tarot'},
        config = {center = {key = key}},
        juice_up = function() end, flip = function() end,
        set_edition = function(self, edition) self.edition = edition end,
        add_sticker = function(self, sticker) self.ability[sticker] = true end,
        remove_sticker = function(self, sticker) self.ability[sticker] = false end,
    }
    return result
end
dofile('consumable_sticker_tools.lua')
dofile('consumables/fountainofyouth.lua')
dofile('consumables/excalibur.lua')
dofile('consumables/freezer.lua')
dofile('consumables/mortgage.lua')
local source = object('porkify', 'c_porkify_fountainofyouth')
G.consumeables.highlighted = {source}
definitions.fountainofyouth:update(source, 0)
assert(G.consumeables.config.highlighted_limit == 2)
local consumable = object('Tarot', 'c_tarot')
G.consumeables.highlighted = {source, consumable}
assert(Porkify_get_sticker_tool_target(source) == consumable)
assert(definitions.fountainofyouth:can_use(source))
definitions.fountainofyouth:use(source)
assert(consumable.ability.eternal)
assert(#G.consumeables.highlighted == 0 and G.consumeables.config.highlighted_limit == 1)

local cases = {
    {key = 'excalibur', sticker = 'eternal'},
    {key = 'freezer', sticker = 'perishable'},
    {key = 'mortgage', sticker = 'rental'},
}
for _, case in ipairs(cases) do
    for _, target_area in ipairs({G.hand, G.jokers, G.consumeables}) do
        G.hand.highlighted, G.jokers.highlighted, G.consumeables.highlighted = {}, {}, {}
        local tool = object('porkify', 'c_porkify_' .. case.key)
        local target = object(target_area == G.hand and 'Default' or (target_area == G.jokers and 'Joker' or 'Tarot'), 'target')
        target.ability[case.sticker] = true
        G.consumeables.highlighted = {tool}
        if target_area == G.consumeables then G.consumeables.highlighted[2] = target
        else target_area.highlighted = {target} end
        assert(definitions[case.key]:can_use(tool), case.key .. ' should accept every card area')
        definitions[case.key]:use(tool)
        assert(not target.ability[case.sticker], case.key .. ' did not remove sticker')
    end
end
local joker_unlocks = 0
for _, key in ipairs(unlocks) do if key == 'porkify_joker_sticker_removed' then joker_unlocks = joker_unlocks + 1 end end
assert(joker_unlocks == 3, 'Joker-only achievement should trigger only for Joker targets')
local negative = object('Default', 'c_base')
negative.edition = {key = 'e_negative'}
G.consumeables.highlighted = {source}; G.hand.highlighted = {negative}
assert(not definitions.fountainofyouth:can_use(source))
G.jokers.highlighted = {object('Joker', 'second_target')}
assert(not definitions.fountainofyouth:can_use(source), 'Multiple targets must be rejected')
print('Sticker consumables accept Joker, playing-card and consumable targets')
