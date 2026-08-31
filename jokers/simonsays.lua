local PORKIFY_SIMON_SAYS_SUITS = { "Spades", "Hearts", "Clubs", "Diamonds" }

local function porkify_simon_says_pick_suit(roll_index)
    local index = tonumber(roll_index) or 0
    return pseudorandom_element(
        PORKIFY_SIMON_SAYS_SUITS,
        pseudoseed("porkify_simon_says_" .. tostring(index))
    ) or "Spades"
end

local function porkify_simon_says_suit_label(suit)
    local ok, label = pcall(localize, suit or "Spades", "suits_singular")
    if ok and type(label) == "string" and label ~= "" and label ~= "ERROR" and label ~= "NULL" then
        return label
    end
    return suit or "Spades"
end

local function porkify_simon_says_first_scoring_card_matches(context, suit)
    local scoring_hand = context and (context.scoring_hand or context.full_hand) or {}

    for _, played_card in ipairs(scoring_hand) do
        if played_card
            and not played_card.debuff
        then
            return played_card.is_suit and played_card:is_suit(suit)
        end
    end

    return false
end

SMODS.Joker{ -- Simon Says
    key = "simonsays",
    config = {
        extra = {
            mult = 0,
            mult_gain = 1,
            target_suit = "Spades",
            roll_index = 0
        }
    },
    loc_txt = {
        ["name"] = "Simon Says",
        ["text"] = {
            [1] = "This Joker gains {C:red}+#2#{} Mult",
            [2] = "if the {C:attention}first scoring card{}",
            [3] = "is a {V:1}#1#{} card",
            [4] = "Otherwise resets to {C:red}+0{} Mult",
            [5] = "{s:0.75}Suit changes every hand{}",
            [6] = "{C:inactive}(Currently {C:red}+#3#{} {C:inactive}Mult){}"
        }
    },
    pos = { x = 4, y = 9 },
    display_size = { w = 65, h = 65 },
    cost = 6,
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
        local suit = extra.target_suit or "Spades"
        return {
            vars = {
                porkify_simon_says_suit_label(suit),
                extra.mult_gain or 1,
                extra.mult or 0,
                colours = { G.C.SUITS[suit] }
            }
        }
    end,

    set_ability = function(self, card, initial)
        local extra = card.ability.extra or {}
        extra.mult = extra.mult or 0
        extra.mult_gain = extra.mult_gain or 1
        extra.roll_index = extra.roll_index or 0
        extra.target_suit = extra.target_suit or porkify_simon_says_pick_suit(extra.roll_index)
        card.ability.extra = extra
    end,

    calculate = function(self, card, context)
        local extra = card.ability.extra or {}

        if context.before and context.cardarea == G.jokers and not context.blueprint then
            if porkify_simon_says_first_scoring_card_matches(context, extra.target_suit or "Spades") then
                extra.mult = (extra.mult or 0) + (extra.mult_gain or 1)
                card.ability.extra = extra
                return {
                    message = "Upgrade!",
                    colour = G.C.MULT
                }
            end

            if (extra.mult or 0) > 0 then
                extra.mult = 0
                card.ability.extra = extra
                return {
                    message = "Reset",
                    colour = G.C.GREY
                }
            end
        end

        if context.after and context.cardarea == G.jokers and not context.blueprint then
            extra.roll_index = (extra.roll_index or 0) + 1
            extra.target_suit = porkify_simon_says_pick_suit(extra.roll_index)
            card.ability.extra = extra
        end

        if context.cardarea == G.jokers and context.joker_main then
            local mult = extra.mult or 0
            if mult > 0 then
                return {
                    mult = mult
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
                { ref_table = "card.joker_display_values", ref_value = "suit_text", colour = G.C.IMPORTANT },
                { text = ")", colour = G.C.GREY }
            },

            style_function = function(card, text, reminder_text, extra)
                if reminder_text and reminder_text.children and reminder_text.children[2] then
                    local ability_extra = card and card.ability and card.ability.extra or {}
                    reminder_text.children[2].config.colour = lighten(G.C.SUITS[ability_extra.target_suit or "Spades"], 0.35)
                end
                return false
            end,

            calc_function = function(card)
                local extra = (card.ability and card.ability.extra) or {}

                card.joker_display_values.mult_text = "+" .. tostring(extra.mult or 0)
                card.joker_display_values.suit_text = porkify_simon_says_suit_label(extra.target_suit or "Spades")
            end
        }
    end
}
