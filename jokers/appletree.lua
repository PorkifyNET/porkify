SMODS.Joker{ --Apple Tree
    key = "appletree",
    config = {
        extra = { currentante = 0 }
    },
    loc_txt = {
        ['name'] = 'Apple Tree',
        ['text'] = {
            [1] = '{C:attention}+1{} Hand Size per {C:purple}Ante{}',
            [2] = '{C:inactive}(Currently{} {C:attention}+#1#{} {C:inactive}Hand Size){}'
        },
        ['unlock'] = { [1] = 'Reach {C:attention}Ante 8{}' }
    },
    pos = { x = 2, y = 0 },
    display_size = { w = 71, h = 95 },
    cost = 8,
    rarity = 3,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = false,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },
    unlock_condition = { type = 'ante_up', ante = 8 },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.currentante or 0 } }
    end,

    calculate = function(self, card, context)
        -- Passive sync: if ante changed, apply only the difference
        local new_ante = (G.GAME and G.GAME.round_resets and G.GAME.round_resets.ante) or 0
        local old_ante = card.ability.extra.currentante or 0

        if new_ante ~= old_ante then
            local delta = new_ante - old_ante
            card.ability.extra.currentante = new_ante

            -- apply via event to avoid doing it mid-eval in a weird phase
            return {
                func = function()
                    if delta ~= 0 then G.hand:change_size(delta) end
                    return true
                end
            }
        end
    end,

    add_to_deck = function(self, card, from_debuff)
        if from_debuff then
            return
        end
        local ante = (G.GAME and G.GAME.round_resets and G.GAME.round_resets.ante) or 0
        card.ability.extra.currentante = ante
        if ante ~= 0 then G.hand:change_size(ante) end
    end,

    remove_from_deck = function(self, card, from_debuff)
        if from_debuff then
            return
        end
        local applied = card.ability.extra.currentante or 0
        if applied ~= 0 then G.hand:change_size(-applied) end
        card.ability.extra.currentante = 0
    end
}
