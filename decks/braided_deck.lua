
SMODS.Back {
    key = 'braided_deck',
    pos = { x = 3, y = 0 },
    config = {},
    loc_txt = {
        name = 'Braided Deck',
        text = {
            [1] = 'Your {C:attention}all-time most played{}',
            [2] = 'Poker Hand starts at {C:attention}level 3{}'
        },
    },
    unlocked = true,
    discovered = true,
    no_collection = false,
    atlas = 'CustomDecks',
    apply = function()
        G.E_MANAGER:add_event(Event({
            func = function()
                local profile = G.PROFILES and G.SETTINGS
                    and G.PROFILES[G.SETTINGS.profile]
                local hand_usage = profile and profile.hand_usage or {}
                local most_played, highest_count

                for compact_name, usage in pairs(hand_usage) do
                    local hand_name = type(usage) == 'table' and usage.order or nil
                    if not (hand_name and G.GAME.hands[hand_name]) and G.GAME.hands[compact_name] then
                        hand_name = compact_name
                    end

                    local count = type(usage) == 'table' and tonumber(usage.count) or nil
                    if hand_name and G.GAME.hands[hand_name] and count
                        and (not highest_count or count > highest_count
                            or (count == highest_count and hand_name < most_played))
                    then
                        most_played = hand_name
                        highest_count = count
                    end
                end

                most_played = most_played or (G.GAME.hands['High Card'] and 'High Card')
                if most_played then
                    local current_level = G.GAME.hands[most_played].level or 1
                    local level_change = 3 - current_level
                    if level_change ~= 0 then
                        level_up_hand(nil, most_played, true, level_change)
                    end
                end

                return true
            end
        }))
    end
}
