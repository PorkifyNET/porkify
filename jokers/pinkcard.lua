SMODS.Joker {
    key = 'pinkcard',
    config = { extra = {} },
    loc_txt = { name = 'Pink Card', text = {
        'Create a {C:porkify}Porkify{}',
        'card when any',
        '{C:attention}Booster Pack{} is skipped',
        '{C:inactive}(Must have room)'
    } },
    atlas = 'CustomJokers', pos = { x = 5, y = 10 }, -- Placeholder artwork.
    cost = 6, rarity = 2,
    porkify_color_card = true,
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    unlocked = true, discovered = false,
    pools = { ['modprefix_porkify_jokers'] = true },
    calculate = function(self, card, context)
        if context.skipping_booster and not context.retrigger_joker then
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
                                { message = 'Created!', colour = G.C.PURPLE }
                            )
                        end
                    end
                    return true
                end
            }
        end
    end
}
