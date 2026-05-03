SMODS.Joker{
    key = "forced_variety",
    loc_txt = {
        name = "Forced Variety",
        text = {
            [1] = "After each hand, a",
            [2] = "random {C:attention}Poker Hand{} is forbidden.",
            [3] = "If you play it, you {C:red}lose{}.",
            [4] = "{C:inactive}(Forbidden: {C:red}#1#{C:inactive})"
        }
    },
    rarity = "porkify_ruleset",
    cost = 0,
    pos = { x = 8, y = 5 },
    unlocked = true,
    discovered = false,
    no_collection = true,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = false,
    atlas = "CustomJokers",
    pools = {},

    config = { extra = { forbidden = nil } },

    loc_vars = function(self, info_queue, card)
        
        return {vars = {localize((G.GAME.current_round.ForbiddenHand_hand or 'High Card'), 'poker_hands')}}
    end,
    
    set_ability = function(self, card, initial)
        G.GAME.current_round.ForbiddenHand_hand = 'Flush Five'
    end,
    
    calculate = function(self, card, context)
        if context.before and context.cardarea == G.jokers  then
            if context.scoring_name == G.GAME.current_round.ForbiddenHand_hand then
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
        if context.after and context.cardarea == G.jokers  then
            local ForbiddenHand_hands = {}
            for handname, _ in pairs(G.GAME.hands) do
                if G.GAME.hands[handname].visible then
                    ForbiddenHand_hands[#ForbiddenHand_hands + 1] = handname
                end
            end
            if ForbiddenHand_hands[1] then
                G.GAME.current_round.ForbiddenHand_hand = pseudorandom_element(ForbiddenHand_hands, pseudoseed('ForbiddenHand' .. G.GAME.round_resets.ante))
            end
			return {
				message = "New hand forbidden!"
			}
        end
    end
}
