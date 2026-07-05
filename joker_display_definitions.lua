local function has_edition(card, key)
    local edition = card and card.edition
    return not not (not (card and card.debuff) and edition and edition.key == key)
end

local function held_consumables()
    return #(G.consumeables and G.consumeables.cards or {})
end

local function get_runtime_edition(card)
    return (card and card.edition) or {}
end

local function get_gilded_interest()
    if not G.GAME or G.GAME.modifiers.no_interest then
        return 0
    end

    local dollars = G.GAME.dollars or 0
    local interest_amount = G.GAME.interest_amount or 1
    local interest_cap = G.GAME.interest_cap or 25
    return math.max(interest_amount * math.min(math.floor(dollars / 5), interest_cap / 5), 0)
end

local edition_defs = {
    e_porkify_sepia = {
        condition_function = function(card)
            return has_edition(card, "e_porkify_sepia")
        end,
        mod_function = function(card)
            local edition = get_runtime_edition(card)
            return { x_chips = edition.xchips0 or 2 }
        end
    },
    e_porkify_ionized = {
        condition_function = function(card)
            return has_edition(card, "e_porkify_ionized")
        end,
        mod_function = function(card)
            local edition = get_runtime_edition(card)
            local base = edition.base_xmult or 5
            local penalty = edition.ante_penalty or 0.5
            local ante = math.max(0, (G.GAME.round_resets.ante or 1) - 1)
            return { x_mult = base - (ante * penalty) }
        end
    },
    e_porkify_laminated = {
        condition_function = function(card)
            return has_edition(card, "e_porkify_laminated")
        end,
        mod_function = function(card)
            local edition = get_runtime_edition(card)
            local base = edition.consumablesheld or 1
            return { x_mult = base + (held_consumables() * 0.5) }
        end
    },
    e_porkify_gilded = {
        condition_function = function(card)
            return has_edition(card, "e_porkify_gilded")
        end,
        mod_function = function(card)
            return { dollars = math.floor(get_gilded_interest() / 2) }
        end
    }
}

for key, definition in pairs(edition_defs) do
    JokerDisplay.Edition_Definitions[key] = definition
end

local function jd_eval_hand()
    local text, poker_hands, scoring_hand = JokerDisplay.evaluate_hand()
    return text, poker_hands or {}, scoring_hand or {}
end

local function jd_count_rank_matches(scoring_hand, expected)
    local count = 0
    for _, scoring_card in pairs(scoring_hand or {}) do
        if porkify_card_matches_rank(scoring_card, expected) then
            count = count + JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand)
        end
    end
    return count
end

local function jd_count_held_rank_matches(expected)
    local playing_hand = next(G.play.cards)
    local count = 0
    for _, playing_card in ipairs(G.hand.cards or {}) do
        if playing_hand or not playing_card.highlighted then
            if playing_card.facing and playing_card.facing ~= "back" and not playing_card.debuff
                and porkify_card_matches_rank(playing_card, expected) then
                count = count + JokerDisplay.calculate_card_triggers(playing_card, nil, true)
            end
        end
    end
    return count
end

local vanilla_blank_overrides = {
    j_8_ball = function(def)
        def.calc_function = function(card)
            local count = 0
            local text, _, scoring_hand = jd_eval_hand()
            if text ~= "Unknown" then
                count = jd_count_rank_matches(scoring_hand, 8)
            end
            card.joker_display_values.count = count
            local numerator, denominator = 1, card.ability.extra
            if SMODS then
                numerator, denominator = SMODS.get_probability_vars(card, numerator, denominator, "8ball")
            end
            card.joker_display_values.odds = localize { type = "variable", key = "jdis_odds", vars = { numerator, denominator } }
        end
    end,
    j_fibonacci = function(def)
        def.calc_function = function(card)
            local mult = 0
            local text, _, scoring_hand = jd_eval_hand()
            if text ~= "Unknown" then
                mult = card.ability.extra * jd_count_rank_matches(scoring_hand, { 2, 3, 5, 8, 14 })
            end
            card.joker_display_values.mult = mult
            card.joker_display_values.localized_text = "(" .. localize("Ace", "ranks") .. ",2,3,5,8)"
        end
    end,
    j_even_steven = function(def)
        def.calc_function = function(card)
            local mult = 0
            local text, _, scoring_hand = jd_eval_hand()
            if text ~= "Unknown" then
                for _, scoring_card in pairs(scoring_hand) do
                    local id = scoring_card.get_id and scoring_card:get_id()
                    if (porkify_is_blank_seal_card(scoring_card) or (id and id <= 10 and id >= 0 and id % 2 == 0)) then
                        mult = mult + card.ability.extra * JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand)
                    end
                end
            end
            card.joker_display_values.mult = mult
        end
    end,
    j_odd_todd = function(def)
        def.calc_function = function(card)
            local chips = 0
            local text, _, scoring_hand = jd_eval_hand()
            if text ~= "Unknown" then
                for _, scoring_card in pairs(scoring_hand) do
                    local id = scoring_card.get_id and scoring_card:get_id()
                    if porkify_is_blank_seal_card(scoring_card)
                        or (id and ((id <= 10 and id >= 0 and id % 2 == 1) or id == 14)) then
                        chips = chips + card.ability.extra * JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand)
                    end
                end
            end
            card.joker_display_values.chips = chips
            card.joker_display_values.localized_text = "(" .. localize("Ace", "ranks") .. ",9,7,5,3)"
        end
    end,
    j_hack = function(def)
        def.retrigger_function = function(playing_card, scoring_hand, held_in_hand, joker_card)
            if held_in_hand then
                return 0
            end
            return JokerDisplay.in_scoring(playing_card, scoring_hand)
                and porkify_card_matches_rank(playing_card, { 2, 3, 4, 5 })
                and joker_card.ability.extra * JokerDisplay.calculate_joker_triggers(joker_card)
                or 0
        end
    end,
    j_scholar = function(def)
        def.calc_function = function(card)
            local chips, mult = 0, 0
            local text, _, scoring_hand = jd_eval_hand()
            if text ~= "Unknown" then
                local retriggers = jd_count_rank_matches(scoring_hand, 14)
                chips = card.ability.extra.chips * retriggers
                mult = card.ability.extra.mult * retriggers
            end
            card.joker_display_values.mult = mult
            card.joker_display_values.chips = chips
            card.joker_display_values.localized_text = "(" .. localize("k_aces") .. ")"
        end
    end,
    j_sixth_sense = function(def)
        def.calc_function = function(card)
            local _, _, scoring_hand = jd_eval_hand()
            local sixth_sense_eval = #scoring_hand == 1 and porkify_card_matches_rank(scoring_hand[1], 6)
            card.joker_display_values.active = G.GAME.current_round.hands_played == 0
            card.joker_display_values.count = sixth_sense_eval and 1 or 0
        end
    end,
    j_superposition = function(def)
        def.calc_function = function(card)
            local is_superposition = false
            local _, poker_hands, scoring_hand = jd_eval_hand()
            if poker_hands["Straight"] and next(poker_hands["Straight"]) then
                for _, scoring_card in pairs(scoring_hand) do
                    if porkify_card_matches_rank(scoring_card, 14) then
                        is_superposition = true
                        break
                    end
                end
            end
            card.joker_display_values.count = is_superposition and 1 or 0
            card.joker_display_values.localized_text_straight = localize("Straight", "poker_hands")
            card.joker_display_values.localized_text_ace = localize("Ace", "ranks")
        end
    end,
    j_baron = function(def)
        def.calc_function = function(card)
            local count = jd_count_held_rank_matches(13)
            card.joker_display_values.x_mult = card.ability.extra ^ count
        end
    end,
    j_mail = function(def)
        def.calc_function = function(card)
            local dollars = 0
            local hand = G.hand.highlighted or {}
            for _, playing_card in pairs(hand) do
                if playing_card.facing and playing_card.facing ~= "back"
                    and not playing_card.debuff
                    and porkify_card_matches_rank(playing_card, G.GAME.current_round.mail_card.id) then
                    dollars = dollars + card.ability.extra
                end
            end
            card.joker_display_values.dollars = G.GAME.current_round.discards_left > 0 and dollars or 0
            card.joker_display_values.mail_card_rank = localize(G.GAME.current_round.mail_card.rank, "ranks")
        end
    end,
    j_walkie_talkie = function(def)
        def.calc_function = function(card)
            local chips, mult = 0, 0
            local text, _, scoring_hand = jd_eval_hand()
            if text ~= "Unknown" then
                local retriggers = jd_count_rank_matches(scoring_hand, { 10, 4 })
                chips = card.ability.extra.chips * retriggers
                mult = card.ability.extra.mult * retriggers
            end
            card.joker_display_values.chips = chips
            card.joker_display_values.mult = mult
        end
    end,
    j_shoot_the_moon = function(def)
        def.calc_function = function(card)
            local mult = card.ability.extra * jd_count_held_rank_matches(12)
            card.joker_display_values.mult = mult
        end
    end,
    j_triboulet = function(def)
        def.calc_function = function(card)
            local count = 0
            local text, _, scoring_hand = jd_eval_hand()
            if text ~= "Unknown" then
                count = jd_count_rank_matches(scoring_hand, { 13, 12 })
            end
            card.joker_display_values.x_mult = card.ability.extra ^ count
            card.joker_display_values.localized_text_king = localize("King", "ranks")
            card.joker_display_values.localized_text_queen = localize("Queen", "ranks")
        end
    end,
    j_idol = function(def)
        def.calc_function = function(card)
            local count = 0
            local text, _, scoring_hand = jd_eval_hand()
            if text ~= "Unknown" then
                for _, scoring_card in pairs(scoring_hand) do
                    if scoring_card:is_suit(G.GAME.current_round.idol_card.suit)
                        and porkify_card_matches_rank(scoring_card, G.GAME.current_round.idol_card.id) then
                        count = count + JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand)
                    end
                end
            end
            card.joker_display_values.x_mult = card.ability.extra ^ count
            card.joker_display_values.idol_card = localize {
                type = "variable",
                key = "jdis_rank_of_suit",
                vars = {
                    localize(G.GAME.current_round.idol_card.rank, "ranks"),
                    localize(G.GAME.current_round.idol_card.suit, "suits_plural")
                }
            }
        end
    end
}

for key, apply_override in pairs(vanilla_blank_overrides) do
    local definition = JokerDisplay.Definitions[key]
    if definition then
        apply_override(definition)
    end
end
