local function porkify_samesong_last_hand()
    local hand_name = G and G.GAME and G.GAME.porkify_samesong_last_hand
    if type(hand_name) ~= "string" or hand_name == "" then
        return nil
    end
    return hand_name
end

local function porkify_samesong_last_hand_label()
    local hand_name = porkify_samesong_last_hand()
    if not hand_name then
        return "None"
    end

    local ok, label = pcall(localize, hand_name, "poker_hands")
    if ok and type(label) == "string" and label ~= "" and label ~= "ERROR" and label ~= "NULL" then
        return label
    end

    return hand_name
end

SMODS.Joker{ -- Same Song
    key = "samesong",
    config = {
        extra = {
            dollars = 3,
            matched_last_hand = false,
            pending_hand = nil
        }
    },
    loc_txt = {
        ["name"] = "Cassette",
        ["text"] = {
            [1] = "Earn {C:money}$#1#{} if played",
            [2] = "{C:attention}Poker Hand{} is the same as",
            [3] = "the last played hand",
            [4] = "{C:inactive}(Currently {}{C:attention}#2#{}{C:inactive}){}"
        }
    },
    pos = { x = 8, y = 8 },
    display_size = { w = 71, h = 95 },
    cost = 5,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = false,
    atlas = "CustomJokers",
    pools = { ["modprefix_porkify_jokers"] = true },

    credit_badges = {
        { text = "Art: maritt", colour = "FF315A" }
    },

    loc_vars = function(self, info_queue, card)
        local extra = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { extra.dollars or 2, porkify_samesong_last_hand_label() } }
    end,

    calculate = function(self, card, context)
        local extra = card.ability.extra or {}

        if context.before and context.cardarea == G.jokers and context.scoring_name then
            local last_hand = porkify_samesong_last_hand()
            extra.pending_hand = context.scoring_name
            extra.matched_last_hand = last_hand ~= nil and last_hand == context.scoring_name
            card.ability.extra = extra
            if extra.matched_last_hand then
                return {
                    dollars = extra.dollars or 3
                }
            end
        end

        if context.after and context.cardarea == G.jokers and not context.blueprint then
            if G and G.GAME and extra.pending_hand then
                G.GAME.porkify_samesong_last_hand = extra.pending_hand
            end

            extra.pending_hand = nil
            extra.matched_last_hand = false
            card.ability.extra = extra
        end

        
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { ref_table = "card.joker_display_values", ref_value = "money_text", colour = G.C.MONEY }
            },
            reminder_text = {
                { text = "(", colour = G.C.GREY },
                { ref_table = "card.joker_display_values", ref_value = "last_hand_text", colour = G.C.IMPORTANT },
                { text = ")", colour = G.C.GREY }
            },

            calc_function = function(card)
                local eval_text = "Unknown"
                local text = JokerDisplay.evaluate_hand()

                if type(text) == "table" then
                    eval_text = text[1] or "Unknown"
                elseif type(text) == "string" then
                    eval_text = text
                end

                local last_hand = porkify_samesong_last_hand()
                local amount = ((card.ability.extra and card.ability.extra.dollars) or 3)
                local active = last_hand and eval_text == last_hand

                card.joker_display_values.money_text = active and ("+$" .. tostring(amount)) or "+$0"
                card.joker_display_values.last_hand_text = porkify_samesong_last_hand_label()
            end
        }
    end
}
