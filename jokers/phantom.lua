local function is_negative(card)
    return card and card.edition and (card.edition.negative or card.edition.key == 'e_negative')
        and not card.removed and not card.destroyed and not card.getting_sliced
end

local function chip_multiplier(card)
    return card.ability.extra.x_chips or 2
end

SMODS.Joker {
    key = 'phantom',
    config = { extra = { x_chips = 2 } },
    loc_txt = { name = 'Phantom', text = {
        '{C:dark_edition}Negative{} Jokers each',
        'give {X:chips,C:white}X#1#{} Chips'
    } },
    atlas = 'CustomJokers', pos = { x = 9, y = 9 },
    cost = 6, rarity = 2,
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    unlocked = true, discovered = false,
    pools = { ['modprefix_porkify_jokers'] = true },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { key = 'e_negative', set = 'Edition', config = { extra = 1 } }
        return { vars = { chip_multiplier(card) } }
    end,
    calculate = function(self, card, context)
        if context.other_joker and is_negative(context.other_joker) then
            return { x_chips = chip_multiplier(card), message_card = context.other_joker }
        end
    end,
    joker_display_def = function(JokerDisplay)
        return {
            reminder_text = {
                { text = '(' },
                { ref_table = 'card.joker_display_values', ref_value = 'count', colour = G.C.IMPORTANT },
                { text = 'x' },
                { ref_table = 'card.joker_display_values', ref_value = 'localized_text', colour = G.C.DARK_EDITION },
                { text = ')' }
            },
            calc_function = function(card)
                local count = 0
                for _, joker in ipairs(G.jokers and G.jokers.cards or {}) do
                    if is_negative(joker) then count = count + 1 end
                end
                card.joker_display_values.count = count
                card.joker_display_values.localized_text = localize({type = 'name_text', set = 'Edition', key = 'e_negative'})
            end,
            mod_function = function(card, mod_joker)
                return { x_chips = is_negative(card)
                    and chip_multiplier(mod_joker) ^ JokerDisplay.calculate_joker_triggers(mod_joker) or nil }
            end
        }
    end
}
