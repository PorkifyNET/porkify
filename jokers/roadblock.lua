
SMODS.Joker{ --Roadblock
    key = "roadblock",
    config = {
        extra = {
        }
    },
    loc_txt = {
        ['name'] = 'Roadblock',
        ['text'] = {
            [1] = '{C:red}Lose the game{} if played',
            [2] = 'hand is a {C:attention}Straight{}'
        },
        ['unlock'] = {
            [1] = 'Win a run without playing a Straight.'
        }
    },
    pos = {
        x = 9,
        y = 5
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 5,
    rarity = "porkify_ruleset",
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = false,
    unlocked = false,
    discovered = false,
	no_collection = true,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },
    unlock_condition = { type = 'win_no_hand', extra = 'Straight' },
    
    calculate = function(self, card, context)
        if context.before and context.cardarea == G.jokers  then
            if next(context.poker_hands["Straight"]) then
                return {
                    func = function()
                        card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = "Forbidden!", colour = G.C.RED})
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            delay = 0.5,
                            func = function()
                                if G.STAGE == G.STAGES.RUN then 
                                    G.STATE = G.STATES.GAME_OVER
                                    G.STATE_COMPLETE = false
                                end
                            end
                        }))
                        
                        return true
                    end
                }
            end
        end
    end
}