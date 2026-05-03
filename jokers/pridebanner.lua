
SMODS.Joker{ --Pride Banner
    key = "pridebanner",
    config = {
        extra = {
        }
    },
    loc_txt = {
        ['name'] = 'Pride Banner',
        ['text'] = {
            [1] = 'If {C:attention}5{} scoring face cards',
            [2] = 'are played, make the',
            [3] = '{C:attention}first{} card {C:edition}Polychrome{}'
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
    blueprint_compat = false,
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
            if c and c.is_face and c:is_face() then
                count = count + 1
            end
        end
        return count >= 5
    end,	
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            if (to_big(#context.scoring_hand) == to_big(5) and (function()
                local count = 0
                for _, playing_card in pairs(context.scoring_hand or {}) do
                    if playing_card:is_face() then
                        count = count + 1
                    end
                end
                return count == #context.scoring_hand
            end)() and context.other_card == context.scoring_hand[1]) then
                local scored_card = context.other_card
                G.E_MANAGER:add_event(Event({
                    func = function()
                        
                        scored_card:set_edition("e_polychrome", true)
                        card_eval_status_text(scored_card, 'extra', nil, nil, nil, {message = "Pride!", colour = G.C.ORANGE})
                        return true
                    end
                }))
            end
        end
    end
}