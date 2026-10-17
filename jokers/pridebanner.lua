
local function porkify_is_polychrome(card)
    return card and card.edition and card.edition.polychrome
end

SMODS.Joker{ --Pride Banner
    key = "pridebanner",
    config = {
        extra = {
        }
    },
    loc_txt = {
        ['name'] = 'Pride Banner',
        ['text'] = {
            [1] = 'Retrigger all',
            [2] = '{C:edition}Polychrome{} cards'
        },
        ['unlock'] = {
            [1] = 'Play a scoring hand with {C:attention}5{} {C:attention}face{} {C:attention}cards{}'
        }
    },
    pos = {
        x = 8,
        y = 2
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 6,
    rarity = 3,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },
    check_for_unlock = function(self, args)
        if args.type ~= 'hand_contents' or not args.cards then
            return false
        end
        local count = 0
        for _, c in ipairs(args.cards) do
            if porkify_card_is_face_or_blank(c) then
                count = count + 1
            end
        end
        return count >= 5
    end,	

    calculate = function(self, card, context)
        if (context.repetition or context.retrigger_joker_check)
            and porkify_is_polychrome(context.other_card) then
            return {
                repetitions = 1,
                message = localize('k_again_ex'),
            }
        end
    end
}
