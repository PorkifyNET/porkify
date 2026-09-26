local SHOOTING_STAR_RANKS = {
    "2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen", "King", "Ace"
}

local function porkify_shooting_star_available_ranks()
    local seen = {}
    local pool = {}

    for _, playing_card in ipairs((G and G.playing_cards) or {}) do
        local rank = playing_card
            and playing_card.base
            and playing_card.base.value

        if type(rank) == "string" and not seen[rank] then
            seen[rank] = true
            pool[#pool + 1] = rank
        end
    end

    if #pool == 0 then
        return SHOOTING_STAR_RANKS
    end

    table.sort(pool)
    return pool
end

local function porkify_shooting_star_choose_rank(seed_suffix)
    return pseudorandom_element(
        porkify_shooting_star_available_ranks(),
        pseudoseed("porkify_shooting_star_" .. tostring(seed_suffix or 0))
    )
end

local function porkify_shooting_star_target_rank(card)
    return (card and card.ability and card.ability.extra and card.ability.extra.target_rank) or "Ace"
end

SMODS.Joker{ -- Shooting Star
    key = "shootingstar",
    config = {
        extra = {
            target_rank = "Ace"
        }
    },
    loc_txt = {
        ['name'] = 'Shooting Star',
        ['text'] = {
            [1] = 'Create a {C:planet}Planet{} card if',
            [2] = 'played hand contains a {C:attention}#1#{}',
            [3] = '{s:0.75}Rank changes every round{}',
            [4] = '{C:inactive}(Must have room){}'
        }
    },
    pos = { x = 2, y = 8 },
    display_size = { w = 71, h = 95 },
    cost = 5,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },

    credit_badges = {
        { text = "Art: Eclipse89", colour = "D70159" }
     },

    loc_vars = function(self, info_queue, card)
        return { vars = { porkify_shooting_star_target_rank(card) } }
    end,

    set_ability = function(self, card, initial)
        if card and card.ability and card.ability.extra then
            card.ability.extra.target_rank = porkify_shooting_star_choose_rank(
                (((G and G.GAME and G.GAME.round_resets and G.GAME.round_resets.ante)) or 0)
                .. "_"
                .. (((G and G.GAME and G.GAME.round)) or 0)
                .. "_init"
            )
        end
    end,

    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint and G and G.GAME then
            card.ability.extra.target_rank = porkify_shooting_star_choose_rank(
                (G.GAME.round_resets.ante or 0) .. "_" .. (G.GAME.round or 0)
            )
            return {
                message = porkify_shooting_star_target_rank(card) .. "!"
            }
        end

        if context.before and context.cardarea == G.jokers then
            local target_rank = porkify_shooting_star_target_rank(card)
            local has_target_rank = false

            for _, played_card in ipairs(context.full_hand or {}) do
                if porkify_card_matches_rank(played_card, target_rank) then
                    has_target_rank = true
                    break
                end
            end

            if has_target_rank
                and G.consumeables
                and G.consumeables.cards
                and G.consumeables.config
                and #G.consumeables.cards < (G.consumeables.config.card_limit or 0) then
                return {
                    func = function()
                        if not (G.consumeables
                            and G.consumeables.cards
                            and G.consumeables.config
                            and #G.consumeables.cards < (G.consumeables.config.card_limit or 0)) then
                            return true
                        end

                        local planet = SMODS.add_card({
                            set = 'Planet',
                            area = G.consumeables
                        })

                        if planet then
                            card_eval_status_text(
                                planet, 'extra', nil, nil, nil,
                                { message = localize('k_plus_planet'), colour = G.C.PLANET }
                            )
                            card:juice_up(0.3, 0.5)
                        end

                        return true
                    end
                }
            end
        end
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { ref_table = "card.joker_display_values", ref_value = "add_planet", colour = G.C.SECONDARY_SET["Planet"] }
            },
            reminder_text = {
                { text = "(" },
                { ref_table = "card.joker_display_values", ref_value = "rank_text", colour = G.C.IMPORTANT },
                { text = ")" },
            },

            calc_function = function(card)
                local has_target_rank = false
                local evaluated_cards = {}

                if G and G.hand and G.hand.highlighted and #G.hand.highlighted > 0 then
                    evaluated_cards = G.hand.highlighted
                elseif G and G.play and G.play.cards and #G.play.cards > 0 then
                    evaluated_cards = G.play.cards
                else
                    local _, _, scoring_hand = JokerDisplay.evaluate_hand()
                    evaluated_cards = scoring_hand or {}
                end

                if card and card.ability and card.ability.extra then
                    local target_rank = porkify_shooting_star_target_rank(card)
                    for _, played_card in ipairs(evaluated_cards) do
                        if porkify_card_matches_rank(played_card, target_rank) then
                            has_target_rank = true
                            break
                        end
                    end
                end

                local has_consumable_room = G
                    and G.consumeables
                    and G.consumeables.cards
                    and G.consumeables.config
                    and #G.consumeables.cards < (G.consumeables.config.card_limit or 0)

                card.joker_display_values.add_planet =
                    has_target_rank and "+1" or "+0"

                card.joker_display_values.rank_text = porkify_shooting_star_target_rank(card)
            end
        }
    end
}
