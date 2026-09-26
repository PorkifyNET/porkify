SMODS = {
    add_to_pool = function(object)
        return object.in_pool_result ~= false
    end,
}

G = { GAME = { banned_keys = { banned = true } } }
MP = {
    should_exclude_from_pool = function(object)
        return object.mp_excluded == true
    end,
}

local available = assert(loadfile("pool_compat.lua"))()

assert(available({ key = "valid" }, "test"))
assert(not available({ key = "banned" }, "test"))
assert(not available({ key = "out_of_pool", in_pool_result = false }, "test"))
assert(not available({ key = "mp_disabled", mp_excluded = true }, "test"))
assert(not available(nil, "test"))

print("raw pool compatibility tests passed")
