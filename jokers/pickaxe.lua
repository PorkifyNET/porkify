SMODS.Joker {
    key = 'pickaxe',
    config = { extra = { x_mult = 1, gain = 0.2 } },
    loc_txt = { name = 'Pickaxe', text = {
        '{C:red}Destroy{} all played {C:attention}rankless{}',
        'cards before scoring',
        'Gains {X:mult,C:white}X#1#{} Mult per {C:attention}card{}',
        '{C:red}destroyed{} by this Joker',
        '{C:inactive}(Currently {X:mult,C:white}X#2#{}{C:inactive} Mult)'
    } },
    atlas = 'CustomJokers', pos = { x = 8, y = 9 }, -- Placeholder artwork.
    cost = 6, rarity = 2,
    blueprint_compat = true, eternal_compat = true, perishable_compat = false,
    unlocked = true, discovered = false,
    pools = { ['modprefix_porkify_jokers'] = true },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.gain, card.ability.extra.x_mult } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then return { x_mult = card.ability.extra.x_mult } end
        if context.before and not context.blueprint and not context.retrigger_joker then
            local played = context.full_hand or {}
            return { func = function()
                local targets = {}
                for _, target in ipairs(played) do
                    if SMODS.has_no_rank(target) and not target.getting_sliced
                        and not target.destroyed and not target.shattered and not target.removed then
                        targets[#targets + 1] = target
                    end
                end
                if #targets == 0 then return true end
                local count = 0
                SMODS.destroy_cards(targets, {
                    immediate = true,
                    destroy_func = function(target, args)
                        local mimic = SMODS.has_enhancement(target, 'm_porkify_mimic')
                        local result
                        if target.shattered then result = target:shatter(args)
                        else result = target:start_dissolve() end
                        if result == false then return false end
                        target.porkify_pickaxe_destroyed = true
                        -- Dissolving cards remain in G.play until their animation ends.
                        for i = #(context.scoring_hand or {}), 1, -1 do
                            if context.scoring_hand[i] == target then
                                table.remove(context.scoring_hand, i)
                            end
                        end
                        if mimic then check_for_unlock { type = 'porkify_pickaxe_mimic' } end
                        count = count + 1
                        return true
                    end
                })
                if count > 0 then
                    card.ability.extra.x_mult = card.ability.extra.x_mult + count * card.ability.extra.gain
                    card_eval_status_text(card, 'extra', nil, nil, nil,
                        { message = localize('k_upgrade_ex'), colour = G.C.MULT })
                end
                return true
            end }
        end
    end,
    joker_display_def = function(JokerDisplay)
        return { text = {{ border_nodes = {
            { text = 'X' }, { ref_table = 'card.ability.extra', ref_value = 'x_mult' }
        } }} }
    end
}

-- Steamodded evaluates both scoring and unscored cards still in the play area.
local score_card_ref = SMODS.score_card
function SMODS.score_card(card, ...)
    if card.porkify_pickaxe_destroyed then return end
    return score_card_ref(card, ...)
end
