local netanyahu
local create_args
local rental_pool
local money_changed = false

SMODS = {
    Joker = function(definition)
        netanyahu = definition
    end,
    add_card = function(args)
        create_args = args
        local created = {
            ability = {},
            set_rental = function(self, value) self.ability.rental = value end,
            juice_up = function() end,
        }
        G.jokers.cards[#G.jokers.cards + 1] = created
        return created
    end,
}

local source = {
    ability = {},
    juice_up = function() end,
    set_rental = function(self, value) self.ability.rental = value end,
}
local other = {
    ability = {},
    juice_up = function() end,
    set_rental = function(self, value) self.ability.rental = value end,
}

G = {
    GAME = { dollars = 20, joker_buffer = 0 },
    jokers = {
        cards = { source, other },
        config = { card_limit = 3 },
    },
    C = {
        MONEY = {},
        RARITY = { [3] = {} },
    },
}

ease_dollars = function()
    money_changed = true
end
card_eval_status_text = function() end
pseudoseed = function(seed) return seed end
pseudorandom_element = function(pool)
    rental_pool = pool
    return pool[1]
end

assert(loadfile("jokers/netanyahu.lua"))()
assert(netanyahu, "Netanyahu did not register")

local result = netanyahu.calculate(netanyahu, source, {
    starting_shop = true,
    blueprint = false,
})
assert(result and result.func, "Netanyahu did not schedule its shop effect")
result.func()

assert(not money_changed and G.GAME.dollars == 20, "Netanyahu still removed money")
assert(create_args and create_args.set == "Joker", "Netanyahu did not create a Joker")
assert(create_args.rarity == "Rare", "Netanyahu did not request a Rare Joker")
assert(create_args.key_append == "porkify_netanyahu", "Netanyahu did not use its own RNG namespace")
assert(#rental_pool == 2, "Netanyahu did not build the expected Rental pool")
assert(rental_pool[1] ~= source and rental_pool[2] ~= source, "Netanyahu could target itself")
assert(other.ability.rental == true, "Netanyahu did not apply Rental")

print("Netanyahu rework tests passed")
