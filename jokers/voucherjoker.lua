
SMODS.Joker{ --Voucher Joker
    key = "voucherjoker",
    config = {
        extra = {
            voucher_slots_increase = '1'
        }
    },
    loc_txt = {
        ['name'] = 'Voucher Joker',
        ['text'] = {
            [1] = 'Adds {C:attention}1{} Voucher',
            [2] = 'to the {C:green}Shop{} per {C:attention}Ante{}'
        },
        ['unlock'] = {
            [1] = 'Redeem {C:attention}8{} Vouchers'
        }
    },
    pos = {
        x = 3,
        y = 4
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 5,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },
    unlock_condition = { type = 'run_redeem', extra = 8 },
    
    calculate = function(self, card, context)
    end,
    
    add_to_deck = function(self, card, from_debuff)
        SMODS.change_voucher_limit(1)
    end,
    
    remove_from_deck = function(self, card, from_debuff)
        SMODS.change_voucher_limit(-1)
    end
}