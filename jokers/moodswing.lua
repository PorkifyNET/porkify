local function porkify_moodswing_visible_hands()
    local pool = {}

    if not (G and G.GAME and G.GAME.hands) then
        return { "High Card" }
    end

    for hand_name, hand in pairs(G.GAME.hands) do
        if hand and hand.visible then
            pool[#pool + 1] = hand_name
        end
    end

    if #pool == 0 then
        return { "High Card" }
    end

    return pool
end

local function porkify_moodswing_choose_hand(seed_suffix)
    return pseudorandom_element(
        porkify_moodswing_visible_hands(),
        pseudoseed("porkify_moodswing_" .. tostring(seed_suffix or 0))
    )
end

local function porkify_moodswing_target_hand(card)
    local extra = card and card.ability and card.ability.extra
    return (extra and extra.target_hand) or "High Card"
end

SMODS.Joker{ -- Mood Swing
    key = "moodswing",
    config = {
        extra = {
            target_hand = "High Card",
            chips = 0,
            chip_gain = 12,
            active_this_hand = false,
            hand_rolls = 0
        }
    },
    loc_txt = {
        ["name"] = "Mood Swing",
        ["text"] = {
            [1] = "{C:blue}+#2#{} Chips if played hand",
            [2] = "contains a {C:attention}#1#{}",
            [3] = "{C:red}-#2#{} Chips if it is not",
            [4] = "{C:inactive}(Hand changes every hand){}",
            [5] = "{C:inactive}(Currently {C:blue}#3#{} {C:inactive}Chips){}"
        }
    },
    pos = { x = 9, y = 8 },
    display_size = { w = 71, h = 95 },
    cost = 4,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false,
    unlocked = true,
    discovered = false,
    atlas = "CustomJokers",
    pools = { ["modprefix_porkify_jokers"] = true },

    loc_vars = function(self, info_queue, card)
        local extra = (card and card.ability and card.ability.extra) or self.config.extra
        return {
            vars = {
                localize(porkify_moodswing_target_hand(card), "poker_hands"),
                extra.chip_gain or 12,
                ((extra.chips or 0) >= 0 and "+" or "") .. tostring(extra.chips or 0)
            }
        }
    end,

    set_ability = function(self, card, initial)
        local extra = card.ability.extra or {}
        extra.target_hand = porkify_moodswing_choose_hand("init")
        extra.active_this_hand = false
        extra.hand_rolls = extra.hand_rolls or 0
        card.ability.extra = extra
    end,

    calculate = function(self, card, context)
        local extra = card.ability.extra or {}

        if context.before and context.cardarea == G.jokers then
            local target = porkify_moodswing_target_hand(card)
            local poker_hands = context.poker_hands or {}
            extra.active_this_hand = target and poker_hands[target] and next(poker_hands[target]) ~= nil
            card.ability.extra = extra

            local chip_gain = extra.chip_gain or 12
            local upgraded = extra.active_this_hand

            if upgraded then
                extra.chips = (extra.chips or 0) + chip_gain
            else
                extra.chips = math.max(((extra.chips or 0) - chip_gain), 0)
            end

            extra.hand_rolls = (extra.hand_rolls or 0) + 1
            extra.target_hand = porkify_moodswing_choose_hand(
                ((G and G.GAME and G.GAME.round_resets and G.GAME.round_resets.ante) or 0)
                .. "_"
                .. ((G and G.GAME and G.GAME.round) or 0)
                .. "_"
                .. tostring(extra.hand_rolls)
            )
            extra.active_this_hand = false
            card.ability.extra = extra

            return {
                message = upgraded and "Upgrade!" or "Downgrade...",
                colour = upgraded and G.C.BLUE or G.C.RED
            }
        end

        if context.cardarea == G.jokers and context.joker_main then
            local chips = extra.chips or 0
            if chips ~= 0 then
                return {
                    chips = chips
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
                { text = "(", colour = G.C.GREY },
                { ref_table = "card.joker_display_values", ref_value = "hand_text", colour = G.C.IMPORTANT },
                { text = ")", colour = G.C.GREY }
            },

            calc_function = function(card)
                local target = porkify_moodswing_target_hand(card)
                local eval_text = "Unknown"
                local text = JokerDisplay.evaluate_hand()

                if type(text) == "table" then
                    eval_text = text[1] or "Unknown"
                elseif type(text) == "string" then
                    eval_text = text
                end

                local amount = ((card.ability.extra and card.ability.extra.chips) or 0)
                local active = eval_text == target

                card.joker_display_values.chips_text = ((amount >= 0) and "+" or "") .. tostring(amount)
                card.joker_display_values.hand_text = localize(target, "poker_hands")
            end
        }
    end
}
