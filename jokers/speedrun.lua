SMODS.Joker{ -- Speedrun
    key = "speedrun",
    config = {
        extra = {}
    },
    loc_txt = {
        ['name'] = 'Speedrun',
        ['text'] = {
            [1] = 'Gain a random {C:spectral}Spectral{} card',
            [2] = 'whenever a Blind is {C:attention}skipped{}'
        },
        ['unlock'] = {
            [1] = 'Win a run in {C:attention}8{} rounds'
        }
    },
    pos = {
        x = 0,
        y = 3
    },
    display_size = {
        w = 71,
        h = 95
    },
    cost = 6,
    rarity = 3,              -- Rare feels appropriate
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },
    unlock_condition = { type = 'win', n_rounds = 8 },

    calculate = function(self, card, context)
        -- Trigger when a Blind is skipped
        if context.skip_blind then
            return {
                func = function()
                    -- Create a random Spectral card (goes to consumables)
                    local spectral = SMODS.add_card({
                        set = 'Spectral'
                    })

                    if spectral then
                        card_eval_status_text(
                            spectral, 'extra', nil, nil, nil,
                            { message = "Speedrun!", colour = G.C.SPECTRAL }
                        )
                    end

                    return true
                end
            }
        end
    end
}
