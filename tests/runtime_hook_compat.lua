Card = {}

local base_update_calls = 0
Card.update = function(self, dt)
    base_update_calls = base_update_calls + 1
end
Card.is_face = function(self, from_boss)
    return false
end
Card.calculate_joker = function(self, context)
    return nil
end

porkify_install_blank_vanilla_joker_patch()

-- Reproduce Multiplayer's nested wrappers around Porkify's Card methods.
local persistent_update_ref = Card.update
Card.update = function(self, dt)
    return persistent_update_ref(self, dt)
end
local gradient_update_ref = Card.update
Card.update = function(self, dt)
    return gradient_update_ref(self, dt)
end

local multiplayer_update = Card.update
local multiplayer_is_face = function(self, from_boss)
    return Porkify_blank_is_face(self, from_boss)
end
local multiplayer_calculate_joker = function(self, context)
    return Porkify_blank_calculate_joker(self, context)
end
Card.is_face = multiplayer_is_face
Card.calculate_joker = multiplayer_calculate_joker

-- A runtime retry must leave later wrappers in place instead of capturing
-- them and creating Porkify -> Multiplayer -> Porkify recursion cycles.
porkify_install_blank_vanilla_joker_patch()
assert(Card.update == multiplayer_update, "runtime retry displaced Multiplayer's Card.update hook")
assert(Card.is_face == multiplayer_is_face, "runtime retry displaced Multiplayer's Card.is_face hook")
assert(Card.calculate_joker == multiplayer_calculate_joker,
    "runtime retry displaced Multiplayer's Card.calculate_joker hook")

Card.update({ ability = { name = "Joker" } }, 0)
assert(base_update_calls == 1, "nested Card.update hooks did not reach the base exactly once")

print("Runtime hook compatibility checks passed")
