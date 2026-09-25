SMODS.Joker {
    key = "swoon",
    config = {
        extra = {
            dollars = 115
        }
    },
    loc_txt = {
        name = "Swoon",
        text = {
            [1] = "Disable every {C:attention}Boss Blind{}",
            [2] = "if you have {C:money}$#1#{} or more"
        }
    },
    pos = { x = 3, y = 10 },
    display_size = { w = 71, h = 95 },
    cost = 8,
    rarity = 3,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = false,
    atlas = "CustomJokers",
    pools = { ["porkify_porkify_jokers"] = true },

    credit_badges = {
        { text = "Idea: Crystal Sirens", colour = "541CBF" },
     },

    loc_vars = function(self, info_queue, card)
        local extra = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { extra.dollars or 115 } }
    end,

    calculate = function(self, card, context)
        if not (context.setting_blind and not context.blueprint and G and G.GAME) then
            return
        end

        local blind = G.GAME.blind
        local threshold = (card.ability.extra and card.ability.extra.dollars) or 115
        if not (blind and blind.boss and not blind.disabled)
            or to_big(G.GAME.dollars or 0) < to_big(threshold) then
            return
        end

        return {
            func = function()
                local current_blind = G and G.GAME and G.GAME.blind
                if current_blind
                    and current_blind.boss
                    and not current_blind.disabled
                    and to_big(G.GAME.dollars or 0) >= to_big(threshold) then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            current_blind:disable()
                            play_sound("timpani")
                            return true
                        end
                    }))
                    card_eval_status_text(
                        card,
                        "extra",
                        nil,
                        nil,
                        nil,
                        { message = localize("ph_boss_disabled"), colour = G.C.GREEN }
                    )
                end
                return true
            end
        }
    end,

    joker_display_def = function(JokerDisplay)
        return {
            reminder_text = {
                { text = "(" },
                { ref_table = "card.joker_display_values", ref_value = "active_text" },
                { text = ")" }
            },
            calc_function = function(card)
                local blind = G and G.GAME and G.GAME.blind
                local threshold = (card.ability.extra and card.ability.extra.dollars) or 115
                local disableable = blind
                    and blind.get_type
                    and blind:get_type() == "Boss"
                    and to_big(G.GAME.dollars or 0) >= to_big(threshold)

                card.joker_display_values.active = not not disableable
                card.joker_display_values.active_text = localize(disableable and "jdis_active" or "jdis_inactive")
            end,
            style_function = function(card, text, reminder_text, extra)
                if reminder_text and reminder_text.children and reminder_text.children[2] then
                    reminder_text.children[2].config.colour = card.joker_display_values.active
                        and G.C.GREEN
                        or G.C.UI.TEXT_INACTIVE
                end
            end
        }
    end
}
