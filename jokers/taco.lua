
SMODS.Joker{ --Taco
    key = "taco",
    config = {
        extra = {
        }
    },
    loc_txt = {
        ['name'] = 'Taco',
        ['text'] = {
            [1] = 'Every {C:green}Shop{} has {C:attention}1{}',
            [2] = 'additional Booster Pack'
        },
        ['unlock'] = {
            [1] = 'Discover {C:attention}15{} Blinds'
        }
    },
    pos = {
        x = 3,
        y = 1
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 4,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = false,
    perishable_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["porkify_porkify_jokers"] = true },
    unlock_condition = { type = 'blind_discoveries', extra = 15 },
    
    calculate = function(self, card, context)
    end,
    
    add_to_deck = function(self, card, from_debuff)
        SMODS.change_booster_limit(1)
    end,
    
    remove_from_deck = function(self, card, from_debuff)
        SMODS.change_booster_limit(-1)
    end
}