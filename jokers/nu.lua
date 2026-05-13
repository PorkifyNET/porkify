
SMODS.Joker{ --N.U.
    key = "nu",
    config = {
        extra = {
            odds = 4,
            pb_bonus_a2e27cac = 8,
            pb_mult_20da8453 = 1,
            pb_p_dollars_47bc5a39 = 2
        }
    },
    loc_txt = {
        ['name'] = 'N.U.',
        ['text'] = {
            [1] = '{C:green}#1# in 4{} chance to permanently',
            [2] = 'add {C:blue}+8{} Chips, {C:red}+1{} Mult or',
            [3] = '{C:money}$2{} to card when scored'
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
        
        local new_numerator, new_denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'j_modprefix_nu')
        local new_numerator2, new_denominator2 = SMODS.get_probability_vars(card, 1, card.ability.extra.odds2, 'j_modprefix_nu')
        local new_numerator3, new_denominator3 = SMODS.get_probability_vars(card, 1, card.ability.extra.odds3, 'j_modprefix_nu')
        return {vars = {new_numerator, new_denominator, new_numerator2, new_denominator2, new_numerator3, new_denominator3}}
    end,
    
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play  then
            if true then
                if SMODS.pseudorandom_probability(card, 'group_0_5b03fb3c', 1, card.ability.extra.odds, 'j_modprefix_nu', false) then
                    context.other_card.ability.perma_bonus = context.other_card.ability.perma_bonus or 0
                    context.other_card.ability.perma_bonus = context.other_card.ability.perma_bonus + 8
                    SMODS.calculate_effect({extra = { message = localize('k_upgrade_ex'), colour = G.C.CHIPS }, card = card}, card)
                end
                if SMODS.pseudorandom_probability(card, 'group_1_e2d37a7f', 1, card.ability.extra.odds, 'j_modprefix_nu', false) then
                    context.other_card.ability.perma_mult = context.other_card.ability.perma_mult or 0
                    context.other_card.ability.perma_mult = context.other_card.ability.perma_mult + 1
                    SMODS.calculate_effect({extra = { message = localize('k_upgrade_ex'), colour = G.C.MULT }, card = card}, card)
                end
                if SMODS.pseudorandom_probability(card, 'group_2_33ed1d17', 1, card.ability.extra.odds, 'j_modprefix_nu', false) then
                    context.other_card.ability.perma_p_dollars = context.other_card.ability.perma_p_dollars or 0
                    context.other_card.ability.perma_p_dollars = context.other_card.ability.perma_p_dollars + 2
                    SMODS.calculate_effect({extra = { message = localize('k_upgrade_ex'), colour = G.C.MONEY }, card = card}, card)
                end
            end
        end
    end,

    joker_display_def = function(JokerDisplay)
	  return {
        text = {
            { text = "(1 in 4)", scale = 0.3, colour = G.C.GREEN }
        },
	  }
	end
}
