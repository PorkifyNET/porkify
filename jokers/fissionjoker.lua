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

local function ensure_in_playing_cards(pc)
    if not (G and G.playing_cards and pc) then
        return
    end

    for i = 1, #G.playing_cards do
        if G.playing_cards[i] == pc then
            return
        end
    end

    table.insert(G.playing_cards, pc)
end

local function get_lower_rank(rank_id)
    local rank_map = {
        [14] = "King",
        [13] = "Queen",
        [12] = "Jack",
        [11] = "10",
        [10] = "9",
        [9] = "8",
        [8] = "7",
        [7] = "6",
        [6] = "5",
        [5] = "4",
        [4] = "3",
        [3] = "2"
    }

    return rank_map[rank_id]
end

local function create_lower_rank_copy(source_card, target_rank)
    if not (source_card and target_rank) then
        return nil
    end

    local copy = copy_card(source_card, nil, nil, nil, false)
    if not copy then
        return nil
    end

    assert(SMODS.change_base(copy, nil, target_rank))

    if copy.start_materialize then
        copy:start_materialize()
    end
    if copy.add_to_deck then
        copy:add_to_deck()
    end

    ensure_in_playing_cards(copy)

    if G.hand and G.hand.emplace then
        G.hand:emplace(copy)
    elseif G.deck and G.deck.emplace then
        G.deck:emplace(copy)
    end

    return copy
end

SMODS.Joker{ -- Fission Joker
    key = "fissionjoker",
    config = {
        extra = {
            triggered_this_round = false
        }
    },
    loc_txt = {
        ['name'] = 'Fission',
        ['text'] = {
            [1] = 'If {C:attention}first hand{} of round',
            [2] = 'is only {C:attention}1{} card, {C:red}destroy{} it',
            [3] = 'and create {C:attention}2{} cards',
            [4] = 'of {C:attention}1{} rank lower'
        }
    },
    pos = {
        x = 8,
        y = 7
    },
    display_size = {
        w = 71 * 1,
        h = 95 * 1
    },
    cost = 7,
    rarity = 2,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },

    credit_badges = {
        { text = "Idea: Onomis", colour = "00AA00" },
        { text = "Art: proud-icicle", colour = "F72536" }
     },

    set_ability = function(self, card, initial)
        card.ability.extra.triggered_this_round = false
    end,

    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            card.ability.extra.triggered_this_round = false
            return
        end

        if context.before and context.cardarea == G.jokers and not context.blueprint then
            if card.ability.extra.triggered_this_round then
                return
            end

            card.ability.extra.triggered_this_round = true

            local full_hand = context.full_hand or {}
            if #full_hand ~= 1 then
                return
            end

            local played_card = full_hand[1]
            local target_rank = played_card and played_card.get_id and get_lower_rank(played_card:get_id())
            if not (played_card and target_rank) then
                return
            end

            return {
                func = function()
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.8,
                        func = function()
                            local created = 0
                            for _ = 1, 2 do
                                if create_lower_rank_copy(played_card, target_rank) then
                                    created = created + 1
                                end
                            end

                            if played_card.remove_from_deck then
                                played_card:remove_from_deck()
                            end
                            remove_from_playing_cards(played_card)
                            SMODS.destroy_cards({ played_card })

                            if created > 0 then
                                play_sound('tarot1')
                                card:juice_up(0.3, 0.5)
                                card_eval_status_text(card, 'extra', nil, nil, nil, {
                                    message = "Fission!",
                                    colour = G.C.ATTENTION
                                })
                            end
                            return true
                        end
                    }))
                    return true
                end
            }
        end
    end
}
