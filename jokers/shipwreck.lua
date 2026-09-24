local function porkify_scrapyard_round_key()
    local ante = ((G and G.GAME and G.GAME.round_resets and G.GAME.round_resets.ante) or 0)
    local round = ((G and G.GAME and G.GAME.round) or 0)
    return tostring(ante) .. ":" .. tostring(round)
end

local function ready_to_shake(card)
    if not (G and G.GAME and G.hand and G.jokers and card.area == G.jokers
        and not card.debuff and not card.getting_sliced and not card.destroyed
        and not card.removed and G.STATE == G.STATES.SELECTING_HAND) then return false end
    local round = G.GAME.current_round or {}
    return round.discards_used == 0 and (round.discards_left or 0) > 0
        and card.ability.extra.last_round_key ~= porkify_scrapyard_round_key()
end

SMODS.Joker{ -- Shipwreck
    key = "shipwreck",
    config = {
        extra = {
            last_round_key = nil
        }
    },
    loc_txt = {
        ['name'] = 'Shipwreck',
        ['text'] = {
            [1] = 'Give random {C:enhanced}Enhancements{}',
            [2] = 'to every {C:attention}card{} in your first',
            [3] = '{C:red}discard{} of the round'
        }
    },
    pos = { x = 3, y = 8 },
    display_size = { w = 71, h = 95 },
    cost = 8,
    rarity = 3,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },

    credit_badges = {
        { text = "Art: FlyingSausage", colour = "D70159" }
     },

    update = function(self, card, dt)
        if not card.porkify_ready_juice and ready_to_shake(card) then
            card.porkify_ready_juice = true
            juice_card_until(card, function()
                if ready_to_shake(card) then return true end
                card.porkify_ready_juice = nil
                return false
            end, true)
        end
    end,
    calculate = function(self, card, context)
        if not (context.pre_discard and not context.blueprint and G and G.GAME and G.hand) then
            return
        end

        local current_round = G.GAME.current_round or {}
        if (current_round.discards_used or 0) ~= 0 then
            return
        end

        local round_key = porkify_scrapyard_round_key()
        if card.ability.extra.last_round_key == round_key then
            return
        end

        local targets = {}
        for _, playing_card in ipairs(G.hand.highlighted or {}) do
            if playing_card then
                targets[#targets + 1] = playing_card
            end
        end

        if #targets == 0 then
            return
        end

        card.ability.extra.last_round_key = round_key

        return {
            func = function()
                local changed = 0

                for _, target in ipairs(targets) do
                    local enhancement_key = Porkify_pick_random_enhancement_key and Porkify_pick_random_enhancement_key() or nil
                    if enhancement_key and G.P_CENTERS and G.P_CENTERS[enhancement_key] and target.set_ability then
                        target:set_ability(G.P_CENTERS[enhancement_key], nil, true)
                        changed = changed + 1
                    end
                end

                if changed > 0 then
                    card:juice_up(0.3, 0.5)
                    card_eval_status_text(
                        card,
                        'extra',
                        nil,
                        nil,
                        nil,
                        { message = "Scrapped!", colour = G.C.SECONDARY_SET["Enhanced"] }
                    )
                end

                return true
            end
        }
    end,
    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { text = '+' },
                { ref_table = 'card.joker_display_values', ref_value = 'count', retrigger_type = 'mult' }
            },
            calc_function = function(card)
                card.joker_display_values.count = #(G.hand and G.hand.highlighted or {})
                card.joker_display_values.active = G.GAME.current_round.discards_used == 0
            end,
            style_function = function(card, text, reminder_text, extra)
                if text and text.children[1] and text.children[2] then
                    local colour = card.joker_display_values.active and G.C.SECONDARY_SET.Enhanced
                        or G.C.UI.TEXT_INACTIVE
                    text.children[1].config.colour = colour
                    text.children[2].config.colour = colour
                end
            end
        }
    end
}
