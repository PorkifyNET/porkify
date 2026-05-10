local function remove_from_playing_cards(pc)
    if not (G and G.playing_cards and pc) then
        return
    end
    for i = #G.playing_cards, 1, -1 do
        if G.playing_cards[i] == pc then
            table.remove(G.playing_cards, i)
            return
        end
    end
end

local function get_card_rank_value(playing_card)
    if not (playing_card and playing_card.get_id) then
        return math.huge
    end
    return playing_card:get_id() or math.huge
end

local function get_rank_chip_bonus(rank_id)
    if not rank_id then
        return 0
    end
    if rank_id >= 2 and rank_id <= 10 then
        return rank_id
    end
    if rank_id == 11 or rank_id == 12 or rank_id == 13 then
        return 10
    end
    if rank_id == 14 then
        return 11
    end
    return 0
end

local function get_rank_label(rank_id)
    if rank_id == 11 then
        return "J"
    end
    if rank_id == 12 then
        return "Q"
    end
    if rank_id == 13 then
        return "K"
    end
    if rank_id == 14 then
        return "A"
    end
    return tostring(rank_id or "?")
end

local function find_random_hand_card()
    local hand_cards = (G.hand and G.hand.cards) or {}
    if #hand_cards == 0 then
        return nil
    end
    local index = pseudorandom(pseudoseed("porkify_mallard_first_hand"), 1, #hand_cards)
    return hand_cards[index]
end

local function absorb_playing_card_effects(joker, playing_card)
    local extra = joker.ability.extra or {}
    local ability = (playing_card and playing_card.ability) or {}
    local enhancements = (SMODS and SMODS.get_enhancements and SMODS.get_enhancements(playing_card)) or {}
    local seal = (playing_card and (playing_card.seal or ability.seal)) or nil
    local rank_id = get_card_rank_value(playing_card)

    extra.chips = (extra.chips or 0) + get_rank_chip_bonus(rank_id)
    extra.chips = (extra.chips or 0) + (tonumber(ability.perma_bonus) or 0)
    extra.mult = (extra.mult or 0) + (tonumber(ability.perma_mult) or 0)
    extra.scored_dollars = (extra.scored_dollars or 0) + (tonumber(ability.perma_p_dollars) or 0)

    if enhancements.m_bonus then
        extra.chips = (extra.chips or 0) + 30
    end
    if enhancements.m_mult then
        extra.mult = (extra.mult or 0) + 4
    end
    if enhancements.m_stone then
        extra.chips = (extra.chips or 0) + 50
    end
    if enhancements.m_gold then
        extra.scored_dollars = (extra.scored_dollars or 0) + 3
    end

    if seal == "Gold" then
        extra.scored_dollars = (extra.scored_dollars or 0) + 3
    end

    joker.ability.extra = extra
end

SMODS.Joker{ --Mallard
    key = "mallard",
    config = {
        extra = {
            chips = 0,
            mult = 0,
            scored_dollars = 0
        }
    },
    loc_txt = {
        ['name'] = 'Mallard',
        ['text'] = {
            [1] = 'When the {C:attention}first hand{} is drawn,',
            [2] = '{C:red}destroy{} a random playing card,',
            [3] = 'and absorb its effects',
            [4] = '{C:inactive}(Currently {}{C:blue}+#1#{} {C:inactive}Chips, {}{C:red}+#2#{} {C:inactive}Mult,{}',
            [5] = '{C:money}$#3#{} {C:inactive}at end of round{C:inactive}){}'
        },
        ['unlock'] = {
            [1] = 'Sell {C:attention}20{} cards'
        }
    },
    pos = {
        x = 2,
        y = 3
    },
    display_size = {
        w = 71 * 1,
        h = 95 * 1
    },
    cost = 5,
    rarity = 2,
    blueprint_compat = false,
    eternal_compat = false,
    perishable_compat = false,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },
    unlock_condition = { type = 'c_cards_sold', extra = 20 },

    credit_badges = {
        { text = "Art: pit_xel", colour = "D70159" }
     },

    loc_vars = function(self, info_queue, card)
        local extra = (card and card.ability and card.ability.extra) or self.config.extra
        return {
            vars = {
                extra.chips or 0,
                extra.mult or 0,
                extra.scored_dollars or 0
            }
        }
    end,

    calc_dollar_bonus = function(self, card)
        local extra = (card and card.ability and card.ability.extra) or self.config.extra
        local payout = tonumber(extra.scored_dollars) or 0
        if payout > 0 then
            return payout
        end
    end,

    calculate = function(self, card, context)
        if context.first_hand_drawn and not context.blueprint then
            local target = find_random_hand_card()
            if not target then
                return
            end

            return {
                func = function()
                    if not target.debuff then
                        absorb_playing_card_effects(card, target)
                    end

                    if target.remove_from_deck then
                        target:remove_from_deck()
                    end
                    remove_from_playing_cards(target)
                    SMODS.destroy_cards({ target })

                    card:juice_up(0.3, 0.5)
                    card_eval_status_text(card, 'extra', nil, nil, nil,
                        { message = "Peck!", colour = G.C.GREEN })
                    return true
                end
            }
        end

        if context.cardarea == G.jokers and context.joker_main then
            local extra = card.ability.extra or {}
            local result = {}

            if (extra.chips or 0) > 0 then
                result.chips = extra.chips
            end
            if (extra.mult or 0) > 0 then
                result.mult = extra.mult
            end

            if next(result) then
                return result
            end
        end
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { ref_table = "card.joker_display_values", ref_value = "chips_text", colour = G.C.BLUE },
                { text = " " },
                { ref_table = "card.joker_display_values", ref_value = "mult_text", colour = G.C.RED },
                { text = " " },
                { ref_table = "card.joker_display_values", ref_value = "money_text", colour = G.C.MONEY }
            },
            reminder_text = {
                { ref_table = "card.joker_display_values", ref_value = "status_text", colour = G.C.GREY }
            },

            calc_function = function(card)
                local extra = (card.ability and card.ability.extra) or {}
                local next_target = find_random_hand_card()
                local next_rank = next_target and get_card_rank_value(next_target) or nil

                card.joker_display_values.chips_text = "+" .. tostring(extra.chips or 0)
                card.joker_display_values.mult_text = "+" .. tostring(extra.mult or 0)
                card.joker_display_values.money_text = "+$" .. tostring(extra.scored_dollars or 0)

                if next_rank then
                    card.joker_display_values.status_text = "Next target: " .. get_rank_label(next_rank)
                else
                    card.joker_display_values.status_text = "No hand drawn"
                end
            end
        }
    end
}
