local glitch
local create_args

SMODS = {
    Joker = function(definition)
        glitch = definition
    end,
    pseudorandom_probability = function()
        return true
    end,
    add_card = function(args)
        create_args = args
        return { config = { center = { key = "j_egg" } } }
    end,
}

G = {
    C = { GREEN = {} },
    E_MANAGER = {
        add_event = function(_, event)
            event.func()
        end,
    },
}

Event = function(definition)
    return definition
end

check_for_unlock = function() end
card_eval_status_text = function() end

assert(loadfile("jokers/glitch.lua"))()
assert(glitch, "Glitch did not register")

local card = {
    ability = { extra = { odds = 2 } },
    juice_up = function() end,
}
local sold_card = {
    config = { center = { set = "Joker" } },
}

local result = glitch.calculate(glitch, card, {
    selling_card = true,
    card = sold_card,
})
assert(result and result.func, "Glitch did not schedule Joker creation")
result.func()

assert(create_args and create_args.set == "Joker", "Glitch did not use the normal Joker pool")
assert(create_args.key_append == "porkify_glitch", "Glitch did not use its dedicated RNG namespace")

print("Glitch Multiplayer compatibility tests passed")
