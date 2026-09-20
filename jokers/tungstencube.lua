SMODS.Joker{
    key = 'tungstencube',
    config = { extra = { dollars = 25 } },
    loc_txt = {
        name = 'Tungsten Cube',
        text = {
            'Earn {C:money}$#1#{} if this',
            'Joker is {C:red}destroyed{}'
        }
    },
    -- Reuse Dumbell artwork until Tungsten Cube has its own sprite.
    atlas = 'CustomJokers',
    pos = { x = 6, y = 9 },
    cost = 5,
    rarity = 1,
    blueprint_compat = false,
    eternal_compat = false,
    perishable_compat = true,
    unlocked = true,
    discovered = false,
    pools = { ['modprefix_porkify_jokers'] = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars } }
    end,
    calculate = function(self, card, context)
        if context.joker_type_destroyed and context.card == card
            and not context.blueprint and not context.retrigger_joker then
            return { dollars = card.ability.extra.dollars }
        end
    end
}
