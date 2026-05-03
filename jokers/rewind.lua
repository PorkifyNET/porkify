
SMODS.Joker{ --Rewind
    key = "rewind",
    config = {
        extra = {
            ante_value0 = 1,
            no = 0,
            start_dissolve = 0
        }
    },
    loc_txt = {
        ['name'] = 'Rewind',
        ['text'] = {
            [1] = 'Prevents Death and sets you',
			[2] = 'back to the start of the {C:attention}Ante{}',
			[3] = '{C:red,E:1}Self-Destructs{}'
        },
        ['unlock'] = {
            [1] = 'Lose {C:attention}3{} runs'
        }
    },
    pos = {
        x = 3,
        y = 3
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 8,
    rarity = 3,
    blueprint_compat = false,
    eternal_compat = false,
    perishable_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },
    unlock_condition = { type = 'c_losses', extra = 3 },
    
    calculate = function(self, card, context)
        if context.end_of_round and context.game_over and context.main_eval and not context.blueprint then
            return {
                saved = true,
                extra = {
                    
                    func = function()
                        
                        local mod = -1
                        ease_ante(mod)
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante + mod
                                return true
                            end,
                        }))
                        return true
                    end,
                    extra = {
                        func = function()
                            local target_joker = card
                            
                            if target_joker then
                                target_joker.getting_sliced = true
                                G.E_MANAGER:add_event(Event({
                                    func = function()
                                        target_joker:start_dissolve({G.C.RED}, nil, 1.6)
                                        return true
                                    end
                                }))
                                card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = "Rewind!", colour = G.C.RED})
                            end
                            return true
                        end,
                        colour = G.C.RED
                    }
                }
            }
        end
    end
}