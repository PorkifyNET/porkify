SMODS.Joker{ --Porky
    key = "porky",
    config = {
        extra = {}
    },
    loc_txt = {
        ['name'] = 'Porky',
        ['text'] = {
            [1] = 'When a {C:attention}Blind{} is selected,',
            [2] = 'create a random {C:purple}Porkify{} card',
            [3] = '{C:inactive}(Must have room){}'
        },
        ['unlock'] = {
            [1] = 'Play {C:attention}100{} {C:blue}hands{}'
        }
    },
    pos = {
        x = 4,
        y = 3
    },
    display_size = {
        w = 71 * 1,
        h = 95 * 1
    },
    cost = 4,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },
    unlock_condition = { type = 'c_hands_played', extra = 100 },

    calculate = function(self, card, context)
        if context.setting_blind then
            return {
                func = function()
                    if G.consumeables
                        and G.consumeables.cards
                        and G.consumeables.config
                        and #G.consumeables.cards < G.consumeables.config.card_limit then
                        local created = SMODS.add_card({ set = 'porkify' })
                        if created then
                            play_sound('timpani')
                            card:juice_up(0.3, 0.5)
                            card_eval_status_text(
                                created,
                                'extra', nil, nil, nil,
                                { message = "Summoned!", colour = G.C.PURPLE }
                            )
                        end
                    end
                    return true
                end
            }
        end
    end
}
