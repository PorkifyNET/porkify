local definition

SMODS = {
    Stickers = {
        eternal = { key = 'eternal' },
        rental = { key = 'rental' },
        bulky = { key = 'porkify_bulky', config = { extra_slots_used = 1 } }
    },
    Consumable = function(def) definition = def end
}

local old_center = { key = 'j_old', set = 'Joker', rarity = 2, unlocked = true }
local replacement = { key = 'j_replacement', set = 'Joker', rarity = 2, unlocked = true }
local wrong_rarity = { key = 'j_wrong', set = 'Joker', rarity = 3, unlocked = true }
local banned = { key = 'j_banned', set = 'Joker', rarity = 2, unlocked = true }

local target = {
    ability = {
        set = 'Joker',
        eternal = true,
        rental = true,
        porkify_bulky = { extra_slots_used = 1 },
        extra_slots_used = 1,
        perish_tally = 4
    },
    config = { center = old_center },
    edition = { key = 'e_foil' },
    pinned = true,
    flip = function(self) self.flips = (self.flips or 0) + 1 end,
    juice_up = function(self) self.juiced = true end,
    set_ability = function(self, center)
        self.config.center = center
        self.ability = { set = center.set }
    end
}

local source = {
    config = { center = { key = 'c_porkify_delegation' } },
    juice_up = function(self) self.juiced = true end
}
G = {
    jokers = { highlighted = { target } },
    consumeables = { highlighted = { source }, config = { highlighted_limit = 1 } },
    hand = { highlighted = {} },
    P_CENTER_POOLS = {
        Joker = { old_center, replacement, wrong_rarity, banned }
    },
    E_MANAGER = {
        add_event = function(self, event) event.config.func() end
    }
}

function Event(config) return { config = config } end
function pseudoseed(seed) return seed end
function pseudorandom_element(pool, seed) return pool[1] end
function play_sound() end
function Porkify_get_sticker_tool_target(card) return target, G.jokers end
function Porkify_update_sticker_tool_selection() end
function Porkify_clear_sticker_tool_selection() G.selection_cleared = true end
function Porkify_pool_object_is_available(center)
    return center.key ~= 'j_banned'
end

dofile(TEST_ROOT .. '/consumables/delegation.lua')

assert(definition and definition.key == 'delegation')
assert(definition:can_use(source), 'Delegation must accept a selected Joker')
definition:use(source)

assert(target.config.center == replacement,
    'Delegation must choose a different Joker of the same rarity')
assert(target.edition and target.edition.key == 'e_foil',
    'Delegation must preserve the selected Joker Edition')
assert(target.ability.eternal and target.ability.rental,
    'Delegation must preserve vanilla stickers, including Eternal')
assert(target.ability.porkify_bulky and target.ability.extra_slots_used == 1,
    'Delegation must preserve custom stickers and their slot contribution')
assert(target.pinned and target.ability.perish_tally == 4,
    'Delegation must preserve pinned and perishable state')
assert(target.flips == 2 and G.selection_cleared,
    'Delegation must finish its animation and clear selection')

G.P_CENTER_POOLS.Joker = { old_center, wrong_rarity, banned }
target.config.center = old_center
assert(not definition:can_use(source),
    'Delegation must require an eligible alternate Joker of the same rarity')

G.P_CENTER_POOLS.Joker = { old_center, replacement }
target.ability.porkify_omega = true
assert(not definition:can_use(source),
    'Delegation must reject Jokers with an Omega sticker')
definition:use(source)
assert(target.config.center == old_center,
    'Delegation must never transform an Omega Joker')

print('Delegation same-rarity transformation checks passed')
