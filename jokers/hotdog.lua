
SMODS.Joker{ --Hot Dog
    key = "hotdog",
    config = {
        extra = {
        }
    },
    loc_txt = {
        ['name'] = 'Hot Dog',
        ['text'] = {
            [1] = '{C:attention}+1{} Card Slot',
			[2] = 'in {C:attention}Booster Packs{}'
        },
        ['unlock'] = {
            [1] = 'Redeem {C:attention}3{} Vouchers'
        }
    },
    pos = {
        x = 5,
        y = 3
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 5,
    rarity = 2,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },
    unlock_condition = { type = 'run_redeem', extra = 3 },
    
    calculate = function(self, card, context)
    end,
    
    add_to_deck = function(self, card, from_debuff)
        G.GAME.modifiers.booster_size_mod = (G.GAME.modifiers.booster_size_mod or 0) +1
    end,
    
    remove_from_deck = function(self, card, from_debuff)
        G.GAME.modifiers.booster_size_mod = (G.GAME.modifiers.booster_size_mod or 0) -1
    end
}