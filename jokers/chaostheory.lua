SMODS.Joker{ -- Chaos Theory
    key = "chaostheory",
    config = {
        extra = {
            chips = 80,
            mult = 8,
            x_mult = 2,
            dollars = 2
        }
    },
    loc_txt = {
        ['name'] = 'Chaos Theory',
        ['text'] = {
            [1] = 'Each card held in hand has a',
            [2] = '{C:green}#1# in #2#{} chance to trigger',
            [3] = 'a random {C:attention}bonus{}:',
            [4] = '{C:blue}+#3#{} Chips, {C:red}+#4#{} Mult,',
            [5] = '{X:red,C:white}X#5#{} Mult, or {C:money}+$#6#{}'
        }
    },
    pos = { x = 1, y = 9 },
    display_size = { w = 71, h = 95 },
    cost = 8,
    rarity = 3,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },

    loc_vars = function(self, info_queue, card)
        local extra = (card and card.ability and card.ability.extra) or self.config.extra or {}
        local cards_played = 0
        local hand_size = 0

        if G and G.play and G.play.cards then
            cards_played = #G.play.cards
        end

        if G and G.hand then
            hand_size = (G.hand.config and G.hand.config.card_limit) or hand_size
        end

        cards_played = math.max(cards_played, 0)
        hand_size = math.max(hand_size, 1)

        return {
            vars = {
                cards_played,
                hand_size,
                extra.chips or 80,
                extra.mult or 8,
                extra.x_mult or 2,
                extra.dollars or 2
            }
        }
    end,

    calculate = function(self, card, context)
        if not (context.individual and context.cardarea == G.hand and context.other_card and not context.end_of_round and not context.blueprint) then
            return
        end

        local cards_played = 0
        local hand_size = 0

        if G and G.play and G.play.cards then
            cards_played = #G.play.cards
        end

        if G and G.hand then
            hand_size = (G.hand.config and G.hand.config.card_limit) or hand_size
        end

        cards_played = math.max(cards_played, 0)
        hand_size = math.max(hand_size, 1)

        if not SMODS.pseudorandom_probability(
            card,
            'group_chaos_theory',
            cards_played,
            hand_size,
            'j_porkify_chaos_theory',
            false
        ) then
            return
        end

        local extra = card.ability.extra or {}
        local roll = pseudorandom(pseudoseed("porkify_chaos_theory_roll"))

        if roll < 0.25 then
            return {
                chips = extra.chips or 80,
                message = "Chaos!",
                colour = G.C.CHIPS,
                card = context.other_card
            }
        elseif roll < 0.5 then
            return {
                mult = extra.mult or 8,
                message = "Chaos!",
                colour = G.C.MULT,
                card = context.other_card
            }
        elseif roll < 0.75 then
            return {
                Xmult = extra.x_mult or 2,
                message = "Chaos!",
                colour = G.C.MULT,
                card = context.other_card
            }
        else
            return {
                dollars = extra.dollars or 2,
                message = "Chaos!",
                colour = G.C.MONEY,
                card = context.other_card
            }
        end
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { ref_table = "card.joker_display_values", ref_value = "odds_text", colour = G.C.GREEN, scale = 0.3 }
            },

            calc_function = function(card)
                local cards_played = 0
                local hand_size = 0

                if G and G.play and G.play.cards then
                    cards_played = #G.play.cards
                end

                if G and G.hand then
                    hand_size = (G.hand.config and G.hand.config.card_limit) or hand_size
                end

                cards_played = math.max(cards_played, 0)
                hand_size = math.max(hand_size, 1)

                card.joker_display_values.odds_text = "(" .. tostring(cards_played) .. " in " .. tostring(hand_size) .. ")"
            end
        }
    end
}
