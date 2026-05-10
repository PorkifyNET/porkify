SMODS.Voucher {
    key = 'gluttony',
    pos = { x = 0, y = 0 },
    loc_txt = {
        name = 'Gluttony',
        text = {
            [1] = '{C:purple}Porkify{} packs contain',
            [2] = '{C:attention}+1{} extra card'
        },
        unlock = {
            [1] = 'Unlocked by default.'
        }
    },
    cost = 10,
    unlocked = true,
    discovered = false,
    no_collection = false,
    can_repeat_soul = false,
    atlas = 'CustomVouchers',

    credit_badges = {
        { text = "Art: Cebee", colour = "59A487" }
     },
    
    redeem = function(self, voucher)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0,
            func = function()
                local candidate_areas = {
                    G and G.shop_booster,
                    G and G.shop_boosters,
                    G and G.shop_jokers,
                    G and G.shop_vouchers,
                    G and G.pack_cards
                }

                for _, area in ipairs(candidate_areas) do
                    for _, shop_card in ipairs((area and area.cards) or {}) do
                        local center = shop_card and shop_card.config and shop_card.config.center
                        if center and center.group_key == "porkify_boosters" and center.set_ability then
                            center:set_ability(shop_card, false)
                        end
                    end
                end

                return true
            end
        }))
    end
}
