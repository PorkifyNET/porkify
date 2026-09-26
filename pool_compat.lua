-- Raw G.P_* pool consumers do not automatically receive every filter applied
-- by get_current_pool. Use this before randomly selecting an object directly.
function Porkify_pool_object_is_available(object, source)
    if not (object and object.key) then return false end

    if G and G.GAME and G.GAME.banned_keys and G.GAME.banned_keys[object.key] then
        return false
    end

    if SMODS and SMODS.add_to_pool
        and not SMODS.add_to_pool(object, { source = source or "porkify_raw_pool" }) then
        return false
    end

    -- Multiplayer's mp_include/default-deny filter is injected into
    -- get_current_pool separately from SMODS.add_to_pool.
    if type(MP) == "table" and type(MP.should_exclude_from_pool) == "function"
        and MP.should_exclude_from_pool(object) then
        return false
    end

    return true
end

return Porkify_pool_object_is_available
