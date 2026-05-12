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

local function get_playing_card_chip_value(playing_card)
    if not playing_card then
        return 0
    end

    local ability = playing_card.ability or {}
    local enhancements = (SMODS and SMODS.get_enhancements and SMODS.get_enhancements(playing_card)) or {}
    local total = get_rank_chip_bonus(get_card_rank_value(playing_card))

    total = total + (tonumber(ability.perma_bonus) or 0)

    if enhancements.m_bonus then
        total = total + 30
    end
    if enhancements.m_porkify_plant then
        local ante = ((G and G.GAME and G.GAME.round_resets and G.GAME.round_resets.ante) or 0)
        total = total + (ante * 10)
    end
    if enhancements.m_stone then
        total = total + 50
    end

    return total
end

local function find_random_hand_card(hand_cards)
    hand_cards = hand_cards or ((G.hand and G.hand.cards) or {})
    local valid_cards = {}
    for _, playing_card in ipairs(hand_cards) do
        local enhancements = (SMODS and SMODS.get_enhancements and SMODS.get_enhancements(playing_card)) or {}
        if playing_card and not playing_card.debuff and not enhancements.m_porkify_revolving then
            valid_cards[#valid_cards + 1] = playing_card
        end
    end

    if #valid_cards == 0 then
        return nil
    end
    local index = pseudorandom(pseudoseed("porkify_mallard_hand_draw"), 1, #valid_cards)
    return valid_cards[index]
end

local function absorb_playing_card_chips(joker, playing_card)
    local extra = joker.ability.extra or {}
    extra.chips = (extra.chips or 0) + get_playing_card_chip_value(playing_card)
    joker.ability.extra = extra
end

SMODS.Joker{ --Mallard
    key = "mallard",
    config = {
        extra = {
            chips = 0,
            last_hands_played = 0,
            last_discards_used = 0
        }
    },
    loc_txt = {
        ['name'] = 'Mallard',
        ['text'] = {
            [1] = 'Whenever a {C:attention}hand{} is drawn,',
            [2] = '{C:red}destroy{} a random playing card,',
            [3] = 'and add its {C:blue}Chips{} to this Joker',
            [4] = '{C:inactive}(Currently {}{C:blue}+#1#{} {C:inactive}Chips){}'
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
                extra.chips or 0
            }
        }
    end,

    set_ability = function(self, card, initial)
        local extra = card.ability.extra or {}
        local round = (G and G.GAME and G.GAME.current_round) or {}
        extra.last_hands_played = round.hands_played or 0
        extra.last_discards_used = round.discards_used or 0
        card.ability.extra = extra
    end,

    calculate = function(self, card, context)
        if context.hand_drawn and not context.blueprint then
            local extra = card.ability.extra or {}
            local round = (G and G.GAME and G.GAME.current_round) or {}
            local hands_played = round.hands_played or 0
            local discards_used = round.discards_used or 0
            local skip_for_discard = discards_used > (extra.last_discards_used or 0)
                and hands_played == (extra.last_hands_played or 0)

            extra.last_hands_played = hands_played
            extra.last_discards_used = discards_used
            card.ability.extra = extra

            if skip_for_discard then
                return
            end

            local drawn_cards = type(context.hand_drawn) == "table" and context.hand_drawn or nil
            local target = find_random_hand_card(drawn_cards)
            if not target then
                target = find_random_hand_card()
            end
            if not target then
                return
            end

            return {
                func = function()
                    if not target.debuff then
                        absorb_playing_card_chips(card, target)
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
            if (extra.chips or 0) > 0 then
                return {
                    chips = extra.chips
                }
            end
        end
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { ref_table = "card.joker_display_values", ref_value = "chips_text", colour = G.C.BLUE }
            },
            reminder_text = {
                { ref_table = "card.joker_display_values", ref_value = "status_text", colour = G.C.GREY }
            },

            calc_function = function(card)
                local extra = (card.ability and card.ability.extra) or {}
                local next_target = find_random_hand_card()
                local next_value = get_playing_card_chip_value(next_target)

                card.joker_display_values.chips_text = "+" .. tostring(extra.chips or 0)

                if next_target then
                    card.joker_display_values.status_text = "Next bite: +" .. tostring(next_value) .. " Chips"
                else
                    card.joker_display_values.status_text = "No hand drawn"
                end
            end
        }
    end
}
