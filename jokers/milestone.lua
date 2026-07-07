local function porkify_pick_random_playing_card_edition_key()
    local editions = { "e_foil", "e_holo", "e_polychrome" }
    return pseudorandom_element(editions, pseudoseed("porkify_milestone_edition"))
end

local function porkify_pick_random_seal_name()
    local seals = {}

    if G and G.P_SEALS then
        for key, _ in pairs(G.P_SEALS) do
            seals[#seals + 1] = key
        end
    end

    if #seals == 0 then
        seals = {
            "Gold", "Red", "Blue", "Purple",
            "porkify_echo", "porkify_forge", "porkify_ghost",
            "porkify_pride", "porkify_dice", "porkify_glitched",
            "porkify_blank"
        }
    end

    return pseudorandom_element(seals, pseudoseed("porkify_milestone_seal"))
end

SMODS.Joker{ -- Milestone
    key = "milestone",
    config = {
        extra = {
            scored_cards = 0,
            cards_needed = 10
        }
    },
    loc_txt = {
        ['name'] = 'Milestone',
        ['text'] = {
            [1] = 'Every {C:attention}#2#th{} card scored',
            [2] = 'gains a random {C:enhanced}Enhancement{},',
            [3] = '{C:edition}Edition{} or {C:gold}Seal{}',
            [4] = '{C:inactive}(#1#/#2#){}'
        }
    },
    pos = { x = 7, y = 8 },
    display_size = { w = 71, h = 95 },
    cost = 7,
    rarity = 3,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["porkify_porkify_jokers"] = true },

    loc_vars = function(self, info_queue, card)
        local extra = (card and card.ability and card.ability.extra) or self.config.extra
        local needed = extra.cards_needed or 10
        local scored = extra.scored_cards or 0
        return { vars = { scored % needed, needed } }
    end,

    calculate = function(self, card, context)
        if not (context.individual and context.cardarea == G.play and context.other_card and not context.blueprint) then
            return
        end

        local extra = card.ability.extra or {}
        local needed = extra.cards_needed or 10
        extra.scored_cards = (extra.scored_cards or 0) + 1

        if extra.scored_cards % needed ~= 0 then
            return
        end

        local target = context.other_card
        return {
            func = function()
                local roll = pseudorandom(pseudoseed("porkify_milestone_roll"))

                if roll < 1 / 3 then
                    local enhancement_key = Porkify_pick_random_enhancement_key and Porkify_pick_random_enhancement_key() or nil
                    if enhancement_key and G.P_CENTERS and G.P_CENTERS[enhancement_key] and target.set_ability then
                        target:set_ability(G.P_CENTERS[enhancement_key], nil, true)
                    end
                elseif roll < 2 / 3 then
                    local edition_key = porkify_pick_random_playing_card_edition_key()
                    if edition_key and target.set_edition then
                        target:set_edition(edition_key, true)
                    end
                else
                    local seal = porkify_pick_random_seal_name()
                    if seal and target.set_seal then
                        target:set_seal(seal, nil, true)
                    end
                end

                card:juice_up(0.3, 0.5)
                card_eval_status_text(
                    target,
                    'extra',
                    nil,
                    nil,
                    nil,
                    { message = "Milestone!", colour = G.C.ORANGE }
                )
                return true
            end
        }
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { ref_table = "card.joker_display_values", ref_value = "progress_text", colour = G.C.GREY }
            },

            calc_function = function(card)
                local extra = (card and card.ability and card.ability.extra) or {}
                local needed = extra.cards_needed or 10
                local scored = extra.scored_cards or 0
                card.joker_display_values.progress_text = tostring(scored % needed) .. "/" .. tostring(needed)
            end
        }
    end
}
