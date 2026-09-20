SMODS.Joker{
    key = 'kitty',
    config = { extra = { slots = 1 } },
    loc_txt = {
        name = 'Kitty',
        text = {
            '{C:dark_edition}+#1#{} Joker Slot',
            "{s:0.75}Take a cat for the journey"
        }
    },
    -- Reuse :3 artwork until Kitty has her own sprite.
    atlas = 'CustomJokers',
    pos = { x = 5, y = 9 },
    display_size = { w = 50, h = 38 },
    cost = 1,
    rarity = 1,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = false,
    pools = { ['modprefix_porkify_jokers'] = true },

    in_pool = function(self, args)
        local source = args and args.source
        return not (source == 'sho' or source == 'buf'
            or (type(source) == 'string' and source:match('^porkify_.*pack'))
            or (G and G.STATES and G.STATE and
                (G.STATE == G.STATES.BUFFOON_PACK or G.STATE == G.STATES.SMODS_BOOSTER_OPENED)))
    end,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.slots } }
    end,
    add_to_deck = function(self, card, from_debuff)
        G.jokers.config.card_limit = G.jokers.config.card_limit + card.ability.extra.slots
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.jokers.config.card_limit = G.jokers.config.card_limit - card.ability.extra.slots
    end
}
