
SMODS.Joker{ --Grab Four
    key = "grabfour",
    config = {
        extra = {
            card_draw0 = 4
        }
    },
    loc_txt = {
        ['name'] = 'Grab Four',
        ['text'] = {
            [1] = 'Draw {C:attention}4{} additional cards',
            [2] = 'in the {C:attention}first{} hand of',
            [3] = 'the round'
        },
        ['unlock'] = {
            [1] = 'Play {C:attention}25{} {C:blue}hands{}'
        }
    },
    pos = {
        x = 6,
        y = 0
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 3,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },
    unlock_condition = { type = 'c_hands_played', extra = 25 },
    
    calculate = function(self, card, context)
        if context.first_hand_drawn  then
            if G.hand and #G.hand.cards > 0 then
                SMODS.draw_cards(4)
            end
            return {
                message = "Grab Four!"
            }
        end
    end,
}
