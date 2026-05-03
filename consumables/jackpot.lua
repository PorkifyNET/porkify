local function get_jackpot_targets(used_card)
    local targets = {}
    for _, c in ipairs((G.consumeables and G.consumeables.cards) or {}) do
        if c ~= used_card then
            targets[#targets + 1] = c
        end
    end
    return targets
end

SMODS.Consumable {
    key = 'jackpot',
    set = 'porkify',
    pos = { x = 6, y = 1 },
    config = {
        extra = {
            odds = 2
        }
    },
    loc_txt = {
        name = 'Jackpot',
        text = {
            [1] = '{C:green}#1# in #2#{} chance to add',
            [2] = 'a random {C:dark_edition}Edition{} to a',
            [3] = 'random owned {C:attention}Consumable{}',
            [4] = '{C:inactive}(Must have another consumable){}'
        }
    },
    cost = 3,
    unlocked = true,
    discovered = false,
    hidden = false,
    can_repeat_soul = false,
    atlas = 'CustomConsumables',

    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'c_porkify_jackpot')
        return { vars = { numerator, denominator } }
    end,

    use = function(self, card, area, copier)
        local used_card = copier or card
        local targets = get_jackpot_targets(used_card)
        if #targets == 0 then
            return
        end

        local hit = SMODS.pseudorandom_probability(
            card,
            'group_porkify_jackpot',
            1,
            card.ability.extra.odds,
            'c_porkify_jackpot',
            false
        )

        if not hit then
            card_eval_status_text(
                used_card,
                'extra',
                nil, nil, nil,
                { message = "No luck", colour = G.C.RED }
            )
            return
        end

        local target = pseudorandom_element(targets, pseudoseed('c_porkify_jackpot_target'))
        local edition_key = SMODS.poll_edition({
            key = 'c_porkify_jackpot_edition',
            guaranteed = true
        })

        if not target or not edition_key then
            card_eval_status_text(
                used_card,
                'extra',
                nil, nil, nil,
                { message = "No luck", colour = G.C.RED }
            )
            return
        end

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                target:set_edition(edition_key, true)
                target:juice_up(0.3, 0.5)
                card_eval_status_text(
                    used_card,
                    'extra',
                    nil, nil, nil,
                    { message = "Jackpot!", colour = G.C.GREEN }
                )
                return true
            end
        }))
        delay(0.6)
    end,

    can_use = function(self, card)
        return #get_jackpot_targets(card) > 0
    end
}
