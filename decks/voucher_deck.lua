SMODS.Back {
    key = 'voucher_deck',
    pos = { x = 1, y = 0 },
    config = {},
    loc_txt = {
        name = 'Voucher Deck',
        text = {
            [1] = 'Start with {C:attention}2{} random',
            [2] = '{C:attention}Vouchers{}'
        },
    },
    unlocked = true,
    discovered = true,
    no_collection = false,
    atlas = 'CustomDecks',

    credit_badges = {
        { text = "Art: christopherjacobsanderson", colour = "59A487" }
     },

    apply = function()
        G.E_MANAGER:add_event(Event({
            func = function()
                for roll = 1, 2 do
                    local eligible = {}

                    for _, center in pairs(G.P_CENTER_POOLS.Voucher or {}) do
                        local requirements_met = true
                        if center and type(center.requires) == 'string' then
                            requirements_met = not not G.GAME.used_vouchers[center.requires]
                        elseif center and type(center.requires) == 'table' then
                            for _, required_key in pairs(center.requires) do
                                if not G.GAME.used_vouchers[required_key] then
                                    requirements_met = false
                                    break
                                end
                            end
                        end

                        if center and center.key
                            and center.unlocked == true
                            and center.available ~= false
                            and not G.GAME.used_vouchers[center.key]
                            and requirements_met
                            and Porkify_pool_object_is_available(center, 'porkify_voucher_deck')
                        then
                            eligible[#eligible + 1] = center
                        end
                    end

                    table.sort(eligible, function(a, b)
                        return tostring(a.key) < tostring(b.key)
                    end)

                    if #eligible > 0 then
                        local center = pseudorandom_element(
                            eligible,
                            pseudoseed('porkify_voucher_deck_' .. tostring(roll))
                        )
                        G.GAME.used_vouchers[center.key] = true
                        G.GAME.starting_voucher_count = (G.GAME.starting_voucher_count or 0) + 1
                        Card.apply_to_run(nil, center)
                    end
                end

                return true
            end
        }))
    end
}
