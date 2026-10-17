local function porkify_sleight_visible_hands()
    local hands = {}

    for hand_name, hand in pairs(G and G.GAME and G.GAME.hands or {}) do
        if hand.visible then
            hands[#hands + 1] = hand_name
        end
    end

    table.sort(hands)
    return hands
end


local function porkify_sleight_pick_hand()
    local hands = porkify_sleight_visible_hands()
    if #hands == 0 then return 'High Card' end

    local round_resets = G.GAME.round_resets or {}
    local seed = 'porkify_sleight_of_hand_'
        .. tostring(round_resets.ante or 0)
        .. ':' .. tostring(G.GAME.round or 0)
    return pseudorandom_element(hands, pseudoseed(seed)) or hands[1]
end


local function porkify_sleight_hand_label(hand_name)
    local ok, label = pcall(localize, hand_name or 'High Card', 'poker_hands')
    if ok and type(label) == 'string' and label ~= '' and label ~= 'ERROR' then
        return label
    end
    return hand_name or 'High Card'
end


SMODS.Joker {
    key = 'sleightofhand',
    config = {
        extra = {
            target_hand = nil,
            checked_this_round = false
        }
    },
    loc_txt = {
        name = 'Sleight of Hand',
        text = {
            'The first {C:blue}hand{} of round',
            'is {C:green}free{} if it is a',
            '{C:attention}#1#{}'
        }
    },
    atlas = 'CustomJokers',
    pos = { x = 1, y = 11 }, -- Placeholder artwork.
    display_size = { w = 71, h = 95 },
    cost = 6,
    rarity = 2,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = false,
    pools = { ['modprefix_porkify_jokers'] = true },

    credit_badges = {
        { text = "Art: EverSoNitro", colour = "59A487" }
     },

    loc_vars = function(self, info_queue, card)
        local extra = card and card.ability and card.ability.extra or self.config.extra
        return { vars = { porkify_sleight_hand_label(extra.target_hand) } }
    end,

    set_ability = function(self, card, initial)
        local extra = card.ability.extra or {}
        extra.target_hand = extra.target_hand or porkify_sleight_pick_hand()
        extra.checked_this_round = extra.checked_this_round or false
        card.ability.extra = extra
    end,

    calculate = function(self, card, context)
        if context.blueprint or context.retrigger_joker then return end

        local extra = card.ability.extra
        if context.setting_blind then
            extra.target_hand = porkify_sleight_pick_hand()
            extra.checked_this_round = false
            return
        end

        if context.after and context.cardarea == G.jokers and not extra.checked_this_round then
            local round = G.GAME.current_round or {}
            extra.checked_this_round = true

            if (round.hands_played or 0) == 0
                and context.scoring_name == extra.target_hand then
                return {
                    func = function()
                        ease_hands_played(1)
                        card_eval_status_text(card, 'extra', nil, nil, nil, {
                            message = 'Free Hand!',
                            colour = G.C.BLUE
                        })
                        return true
                    end
                }
            end
        end
    end,

    joker_display_def = function(JokerDisplay)
        return {
            reminder_text = {
                { text = '(' },
                { ref_table = 'card.joker_display_values', ref_value = 'target_text', colour = G.C.IMPORTANT },
                { text = ')' }
            },
            calc_function = function(card)
                local extra = card.ability.extra or {}
                card.joker_display_values.target_text = porkify_sleight_hand_label(extra.target_hand)
            end
        }
    end
}
