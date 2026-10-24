
SMODS.Joker{ --N.U.
    key = "nu",
    config = {
        extra = {
            odds = 2
        }
    },
    loc_txt = {
        ['name'] = 'N.U.',
        ['text'] = {
            [1] = '{C:green}#1# in #2#{} chance to retrigger',
            [2] = 'the Joker to the {C:attention}left{}',
            [3] = '{C:green}#1# in #2#{} chance to retrigger',
            [4] = 'the Joker to the {C:attention}right{}'
        },
        ['unlock'] = {
            [1] = 'Have {C:attention}8{} {C:enhanced}enhanced{} cards in your deck'
        }
    },
    pos = {
        x = 0,
        y = 1
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 11,
    rarity = 3,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["porkify_porkify_jokers"] = true },
    unlock_condition = { type = 'modify_deck', extra = { tally = 'total', count = 8 } },
    
    loc_vars = function(self, info_queue, card)
        local extra = (card and card.ability and card.ability.extra) or self.config.extra
        local numerator, denominator = SMODS.get_probability_vars(
            card, 1, extra.odds or 2, 'j_porkify_nu')
        return { vars = { numerator, denominator } }
    end,
    
    calculate = function(self, card, context)
        if not context.retrigger_joker_check or not context.other_card then return end

        local cards = G.jokers and G.jokers.cards or {}
        local direction
        for index, joker in ipairs(cards) do
            if joker == card then
                if cards[index - 1] == context.other_card then
                    direction = 'left'
                elseif cards[index + 1] == context.other_card then
                    direction = 'right'
                end
                break
            end
        end

        if direction and SMODS.pseudorandom_probability(
            card,
            'group_nu_' .. direction,
            1,
            card.ability.extra.odds,
            'j_porkify_nu',
            false
        ) then
            return {
                repetitions = 1,
                message = localize('k_again_ex'),
            }
        end
    end,

    joker_display_def = function(JokerDisplay)
	  return {
        text = {
            { text = "2x", scale = 0.3, colour = G.C.WHITE },
            { text = "(1 in 2)", scale = 0.3, colour = G.C.GREEN }
        },
	  }
	end
}
