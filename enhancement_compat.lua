-- Quantum enhancement queries also run on menu Cards representing stakes/blinds.
-- Those objects are not registered in G.P_CENTERS; Steamodded's property lookup
-- assumes every returned key is a center and otherwise crashes during removal.
local get_enhancements_ref = SMODS.get_enhancements
function SMODS.get_enhancements(card, ...)
    local enhancements = get_enhancements_ref(card, ...)
    local valid
    for key in pairs(enhancements) do
        if not G.P_CENTERS[key] then
            if not valid then
                valid = {}
                for name, value in pairs(enhancements) do valid[name] = value end
            end
            valid[key] = nil
        end
    end
    -- Leave cached/shared results untouched, and retain all registered centers.
    return valid or enhancements
end
