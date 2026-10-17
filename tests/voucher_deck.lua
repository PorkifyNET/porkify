local definition
SMODS = {
    Back = function(value) definition = value end
}

local crystal = {
    key = 'v_crystal_ball', set = 'Voucher', unlocked = true, available = true
}
local omen = {
    key = 'v_omen_globe', set = 'Voucher', unlocked = true, available = true,
    requires = { 'v_crystal_ball' }
}
local locked = {
    key = 'v_locked_upgrade', set = 'Voucher', unlocked = false, available = true
}
local unavailable = {
    key = 'v_unavailable', set = 'Voucher', unlocked = true, available = false
}

G = {
    GAME = { used_vouchers = {}, starting_voucher_count = 0 },
    P_CENTER_POOLS = { Voucher = { omen, locked, unavailable, crystal } },
    E_MANAGER = {
        add_event = function(self, event) return event.func() end
    }
}

Event = function(event) return event end
Porkify_pool_object_is_available = function() return true end
pseudoseed = function(seed) return seed end

local rolls = 0
pseudorandom_element = function(pool)
    rolls = rolls + 1
    local found = {}
    for _, center in ipairs(pool) do found[center.key] = center end

    assert(not found.v_locked_upgrade, 'Locked Vouchers must not enter the pool')
    assert(not found.v_unavailable, 'Unavailable Vouchers must not enter the pool')
    if rolls == 1 then
        assert(not found.v_omen_globe,
            'An upgrade Voucher must not enter the pool before its prerequisite')
        return assert(found.v_crystal_ball)
    end

    assert(found.v_omen_globe,
        'An unlocked upgrade Voucher may enter the pool after its prerequisite')
    return found.v_omen_globe
end

local applied = {}
Card = {
    apply_to_run = function(self, center)
        applied[#applied + 1] = center.key
    end
}

dofile(TEST_ROOT .. '/decks/voucher_deck.lua')
assert(definition, 'Voucher Deck must register')
assert(definition.loc_txt.text[1]:find('2', 1, true),
    'Voucher Deck description must state the new effect')

definition:apply()
assert(applied[1] == 'v_crystal_ball' and applied[2] == 'v_omen_globe',
    'Voucher Deck must apply both selected Vouchers in dependency order')
assert(G.GAME.used_vouchers.v_crystal_ball and G.GAME.used_vouchers.v_omen_globe,
    'Voucher Deck must record both starting Vouchers as redeemed')
assert(G.GAME.starting_voucher_count == 2,
    'Voucher Deck must record two starting Vouchers')

print('Voucher Deck unlock and prerequisite checks passed')
