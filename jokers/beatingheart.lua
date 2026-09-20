
SMODS.Joker{ --Beating Heart
    key = "beatingheart",
    config = {
        extra = {
            repetitions = 1
        }
    },
    loc_txt = {
        ['name'] = 'Beating Heart',
        ['text'] = {
            [1] = 'Retrigger all played',
            [2] = '{C:hearts}Heart{} cards'
        },
        ['unlock'] = {
            [1] = 'Play every {C:hearts}Heart{} card in your deck'
        }
    },
    pos = {
        x = 3,
        y = 0
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 6,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },
    unlock_condition = { type = 'play_all_hearts' },
    
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play and context.other_card
            and context.other_card:is_suit('Hearts') then
            return { repetitions = 1, message = localize('k_again_ex') }
        end
    end,
}
