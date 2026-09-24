return function(mod)
    -- Freeze content choices for this session; UI changes apply after restarting.
    local enabled = {}
    for key, value in pairs(mod.config) do enabled[key] = value end
    local categories = {
        j = 'jokers', c = 'consumables', v = 'vouchers',
        p = 'boosters', tag = 'tags', bl = 'blinds'
    }
    local add_to_pool = SMODS.add_to_pool
    SMODS.add_to_pool = function(object, ...)
        -- This experimental option is live; content-category toggles require a restart.
        if object and object.key == 'j_porkify_cerberus' and mod.config.cerberus_slayer then
            return false, {}
        end
        local prefix = object and type(object.key) == 'string' and object.key:match('^(%w+)_porkify_')
        local category = prefix and categories[prefix]
        if category and enabled['content_' .. category] == false then
            return false, {}
        end
        return add_to_pool(object, ...)
    end
    if enabled.content_secret_hands == false then
        for key in pairs(PORKIFY_SECRET_HANDS or {}) do
            local hand = SMODS.PokerHands[key]
            if hand then
                hand.evaluate = function() return {} end
            end
        end
    end
    if enabled.content_achievements == false then
        for key, achievement in pairs(SMODS.Achievements or {}) do
            if key:match('^ach_porkify_') then
                achievement.unlock_condition = function() return false end
            end
        end
    end
end
