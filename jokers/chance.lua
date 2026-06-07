SMODS.Joker{ -- Chance
    key = "chance",
    config = {
        extra = {}
    },
    loc_txt = {
        ['name'] = 'Chance',
        ['text'] = {
            [1] = 'When a {C:attention}Blind{} is selected,',
            [2] = 'create a random {C:tarot}Consumable{}',
            [3] = '{C:inactive}(Must have room){}'
        }
    },
    pos = {
        x = 0,
        y = 8
    },
    display_size = {
        w = 71,
        h = 95
    },
    cost = 6,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },

    credit_badges = {
        { text = "Art: BlobbyDS", colour = "59A487" }
     },

    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            return {
                func = function()
                    if not (G.consumeables and G.consumeables.cards and G.consumeables.config) then
                        return true
                    end

                    if #G.consumeables.cards >= G.consumeables.config.card_limit then
                        return true
                    end

                    local sets = { 'Tarot', 'Planet', 'Spectral', 'porkify' }
                    local chosen_set = pseudorandom_element(sets, 'chance_card_type')
                    local created = SMODS.add_card({ set = chosen_set, area = G.consumeables })

                    if created then
                        card:juice_up(0.3, 0.5)
                        card_eval_status_text(
                            created,
                            'extra', nil, nil, nil,
                            { message = "Chance!", colour = G.C.PURPLE }
                        )
                    end

                    return true
                end
            }
        end
    end
}
