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
            target_rank = "Ace",
            mult = 0,
            mult_gain = 1
        }
    },
    loc_txt = {
        ['name'] = 'Shooting Star',
        ['text'] = {
            [1] = 'This Joker gains {C:red}+#2#{} Mult',
            [2] = 'every time a played {C:attention}#1#{}',
            [3] = 'is scored',
            [4] = '{s:0.75}Rank changes every round{}',
            [5] = '{C:inactive}(Currently{} {C:red}+#3#{} {C:inactive}Mult){}'
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
        local extra = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { porkify_shooting_star_target_rank(card), extra.mult_gain or 2, extra.mult or 0 } }
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

        if context.individual and context.cardarea == G.play and context.other_card then
            local target_rank = porkify_shooting_star_target_rank(card)
            local scored_rank = context.other_card.base and context.other_card.base.value

            if scored_rank == target_rank and not context.blueprint then
                return {
                    func = function()
                        local extra = card.ability.extra or {}
                        extra.mult = (extra.mult or 0) + (extra.mult_gain or 2)
                        card.ability.extra = extra
                        return true
                    end,
                    message = "Upgrade!",
                    colour = G.C.MULT
                }
            end
        end

        if context.cardarea == G.jokers and context.joker_main then
            local extra = card.ability.extra or {}
            if (extra.mult or 0) > 0 then
                return {
                    mult = extra.mult
                }
            end
        end
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { ref_table = "card.joker_display_values", ref_value = "mult_text", colour = G.C.RED }
            },
            reminder_text = {
                { text = "(", colour = G.C.GREY },
                { ref_table = "card.joker_display_values", ref_value = "rank_text", colour = G.C.IMPORTANT },
                { text = ")", colour = G.C.GREY },
            },

            calc_function = function(card)
                local extra = (card.ability and card.ability.extra) or {}
                card.joker_display_values.rank_text = porkify_shooting_star_target_rank(card)
                card.joker_display_values.mult_text = "+" .. tostring(extra.mult or 0)
            end
        }
    end
}
