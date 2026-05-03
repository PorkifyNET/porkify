
SMODS.Joker{ --Hamburger
    key = "hamburger",
    config = {
        extra = {
        }
    },
    loc_txt = {
        ['name'] = 'Hamburger',
        ['text'] = {
            [1] = 'Choose {C:attention}1{} additional card',
            [2] = 'in {C:attention}Booster Packs{}'
        },
        ['unlock'] = {
            [1] = 'Redeem {C:attention}6{} Vouchers'
        }
    },
    pos = {
        x = 6,
        y = 3
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 10,
    rarity = 3,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },
    unlock_condition = { type = 'run_redeem', extra = 6 },
    
    calculate = function(self, card, context)
    end,
    
    add_to_deck = function(self, card, from_debuff)
        G.GAME.modifiers.booster_choice_mod = (G.GAME.modifiers.booster_choice_mod or 0) +1
    end,
    
    remove_from_deck = function(self, card, from_debuff)
        G.GAME.modifiers.booster_choice_mod = (G.GAME.modifiers.booster_choice_mod or 0) -1
    end
}