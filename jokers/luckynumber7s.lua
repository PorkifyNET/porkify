SMODS.Joker{ -- Lucky Number 7s
    key = "luckynumber7s",
    config = {
        extra = {}
    },
    loc_txt = {
        ['name'] = 'Lucky Number 7s',
        ['text'] = {
            [1] = 'Every played {C:attention}7{} is',
            [2] = 'considered a {C:enhanced}Lucky Card{}'
        },
        ['unlock'] = {
            [1] = 'Play a {C:attention}Three of a Kind{}',
            [2] = 'consisting of {C:attention}3{} {C:attention}7s{}'
        }
    },
    pos = {
        x = 9,
        y = 0
    },
    display_size = {
        w = 71,
        h = 95
    },
    cost = 7,
    rarity = 1,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["porkify_porkify_jokers"] = true },
    check_for_unlock = function(self, args)
        if args.type ~= 'hand_contents' or not args.cards then
            return false
        end

        local eval = evaluate_poker_hand(args.cards)
        if not (eval and next(eval["Three of a Kind"]))
            or (eval["Four of a Kind"] and next(eval["Four of a Kind"]))
            or (eval["Full House"] and next(eval["Full House"])) then
            return false
        end

        local sevens = 0
        for _, c in ipairs(args.cards) do
            if porkify_card_matches_rank(c, 7) then
                sevens = sevens + 1
            end
        end

        return sevens >= 3
    end,
    
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_lucky
        return { vars = {} }
    end,
    calculate = function(self, card, context)
        if not context.check_enhancement or context.blueprint then return end
        local target = context.other_card
        if not target or not G.play or target.area ~= G.play then return end
        -- Do not call get_id/has_no_rank here: they query enhancements again.
        local center = target.config and target.config.center
        local blank = porkify_is_blank_seal_card and porkify_is_blank_seal_card(target)
        if blank or (target.base and target.base.id == 7 and center and not center.no_rank) then
            return { m_lucky = true }
        end
    end,
    joker_display_def = function(JokerDisplay)
        return { reminder_text = {{ text = '(7)' }} }
    end
}
