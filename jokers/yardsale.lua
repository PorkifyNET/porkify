SMODS.Joker{ -- Yard Sale
    key = "yardsale",
    config = {
        extra = {
            sold_needed = 4,
            tag_key = "tag_juggle"
        }
    },
    loc_txt = {
        ['name'] = 'Yard Sale',
        ['text'] = {
            [1] = 'Every {C:attention}#1#{} sold cards,',
            [2] = 'create a {C:gold}Juggle Tag{}'
        },
        ['unlock'] = {
            [1] = 'Sell {C:attention}25{} cards'
        }
    },
    pos = {
        x = 0,
        y = 7
    },
    display_size = {
        w = 71,
        h = 95
    },
    cost = 4,
    rarity = 1,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },
    unlock_condition = { type = 'c_cards_sold', extra = 25 },

    credit_badges = {
        { text = "Art: Souler", colour = "D70159" }
     },

    loc_vars = function(self, info_queue, card)
        local extra = (card and card.ability and card.ability.extra) or self.config.extra
        local info_queue_0 = (G.P_TAGS and G.P_TAGS[extra.tag_key or "tag_juggle"]) or (G.P_CENTERS and G.P_CENTERS[extra.tag_key or "tag_juggle"])
        if info_queue_0 then
            info_queue[#info_queue + 1] = info_queue_0
        end
        return { vars = { extra.sold_needed or 4 } }
    end,

    calculate = function(self, card, context)
        if context.selling_card and not context.blueprint and G and G.GAME then
            G.GAME.current_round = G.GAME.current_round or {}
            G.GAME.current_round.porkify_yardsale_sold_cards =
                (G.GAME.current_round.porkify_yardsale_sold_cards or 0) + 1

            local sold_cards = G.GAME.current_round.porkify_yardsale_sold_cards or 0
            local sold_needed = card.ability.extra.sold_needed or 4
            if sold_cards >= sold_needed then
                G.GAME.current_round.porkify_yardsale_sold_cards = sold_cards - sold_needed
                return {
                    func = function()
                        local tag = Tag(card.ability.extra.tag_key or "tag_juggle")
                        tag:set_ability()
                        add_tag(tag)

                        card_eval_status_text(
                            card,
                            'extra',
                            nil,
                            nil,
                            nil,
                            { message = "Created Tag!", colour = G.C.GOLD }
                        )
                        play_sound('holo1', 1.2 + math.random() * 0.1, 0.4)
                        return true
                    end
                }
            end
        end
    end,

    joker_display_def = function(JokerDisplay)
        return {
            -- text = {
            --     { ref_table = "card.joker_display_values", ref_value = "tag_text", colour = G.C.GOLD }
            -- },
            reminder_text = {
                { ref_table = "card.joker_display_values", ref_value = "progress_text", colour = G.C.GREY }
            },

            calc_function = function(card)
                local extra = (card.ability and card.ability.extra) or {}
                local sold_needed = extra.sold_needed or 4
                local sold_cards = (G and G.GAME and G.GAME.current_round and G.GAME.current_round.porkify_yardsale_sold_cards) or 0

                card.joker_display_values.tag_text = "Juggle Tag"

                if sold_cards >= sold_needed then
                    card.joker_display_values.progress_text = "Ready"
                else
                    card.joker_display_values.progress_text =
                        tostring("(" .. math.min(sold_cards, sold_needed) .. "/" .. tostring(sold_needed) .. ")")
                end
            end
        }
    end
}
