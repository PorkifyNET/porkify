SMODS.Joker{ -- Glitch
    key = "glitch",
    config = {
        extra = {
            odds = 2
        }
    },
    loc_txt = {
        ['name'] = 'Glitch',
        ['text'] = {
            [1] = '{C:green}#1# in #2#{} chance to',
            [2] = 'create a random {C:attention}Joker{}',
            [3] = 'when a {C:attention}Joker{} is sold{}'
        }
    },
    pos = {
        x = 9,
        y = 7
    },
    display_size = {
        w = 71,
        h = 95
    },
    cost = 5,
    rarity = 2,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },

    credit_badges = {
        { text = "Art: cokeblock4043", colour = "59A487" }
     },

    loc_vars = function(self, info_queue, card)
        local odds = (card and card.ability and card.ability.extra and card.ability.extra.odds) or self.config.extra.odds
        local n, d = 1, odds
        if card and SMODS and SMODS.get_probability_vars then
            n, d = SMODS.get_probability_vars(card, 1, odds, 'j_porkify_glitch')
        end
        return { vars = { n, d } }
    end,

    calculate = function(self, card, context)
        if context.selling_card and not context.blueprint then
            local sold_card = context.card or context.other_card or context.sold_card
            local sold_set = sold_card and sold_card.config and sold_card.config.center and sold_card.config.center.set
            sold_set = sold_set or (sold_card and sold_card.ability and sold_card.ability.set)

            if sold_set ~= 'Joker' then
                return
            end

            if not SMODS.pseudorandom_probability(card, 'group_glitch_sell', 1, card.ability.extra.odds, 'j_porkify_glitch', false) then
                return
            end

            return {
                func = function()
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.0,
                        func = function()
                            local created = SMODS.add_card({ set = 'Joker' })
                            if created then
                                card:juice_up(0.3, 0.5)
                                card_eval_status_text(
                                    created,
                                    'extra', nil, nil, nil,
                                    { message = "Glitched!", colour = G.C.GREEN }
                                )
                            end
                            return true
                        end
                    }))
                    return true
                end
            }
        end
    end
}
