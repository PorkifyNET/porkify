SMODS.Joker{ -- The Dumbell
    key = "dumbell",
    config = {
        extra = {}
    },
    loc_txt = {
        ['name'] = 'Dumbell',
        ['text'] = {
            [1] = 'When a {C:attention}Blind{} is selected,',
            [2] = 'create a {C:tarot}Strength{} card',
			[3] = '{C:inactive}(Must have room){}'
        },
        ['unlock'] = {
            [1] = 'Play {C:attention}75{} {C:blue}hands{}'
        }
    },
    pos = {
        x = 9,
        y = 2
    },
    display_size = {
        w = 71,
        h = 95
    },
    cost = 4,
    rarity = 1,
    blueprint_compat = true,  -- set to false if you DON'T want Blueprint to copy the effect
    eternal_compat = true,
    perishable_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },
    unlock_condition = { type = 'c_hands_played', extra = 75 },
	
	loc_vars = function(self, info_queue, card)
        
        local info_queue_0 = G.P_CENTERS["c_strength"]
        if info_queue_0 then
            info_queue[#info_queue + 1] = info_queue_0
        else
            error("JOKERFORGE: Invalid key in infoQueues. \"m_steel\" isn't a valid Object key, Did you misspell it or forgot a modprefix?")
        end
        return {vars = {}}
    end,

    -- no loc_vars needed, text is static
    calculate = function(self, card, context)
        -- Trigger when a Blind is selected (same hook you used for other jokers)
        if context.setting_blind and not context.blueprint then
            return {
                func = function()
                    -- Only add if there's space in the consumable area
                    if G.consumeables
                        and G.consumeables.cards
                        and G.consumeables.config
                        and #G.consumeables.cards < G.consumeables.config.card_limit then

                        local strength = SMODS.add_card({
                            set  = 'Tarot',
                            key  = 'c_strength',
                            area = G.consumeables
                        })

                        if strength then
                            card_eval_status_text(
                                strength, 'extra', nil, nil, nil,
                                { message = "Pumped!", colour = G.C.TAROT }
                            )
                        end
                    end
                    return true
                end
            }
        end
    end
}
