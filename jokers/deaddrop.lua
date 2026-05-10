local function get_planet_key_for_hand(hand_name)
    if not (G and G.P_CENTERS) then
        return nil
    end

    for key, center in pairs(G.P_CENTERS) do
        if center and center.set == "Planet" and center.config and center.config.hand_type == hand_name then
            return key
        end
    end

    return nil
end

local function get_last_played_hand()
    local current_round = G and G.GAME and G.GAME.current_round
    local hand_name = current_round and current_round.porkify_deaddrop_last_hand
    if type(hand_name) ~= "string" or hand_name == "" then
        return "High Card"
    end
    return hand_name
end

local function get_last_played_hand_label()
    local hand_name = get_last_played_hand()
    local ok, label = pcall(localize, hand_name, "poker_hands")
    if ok and type(label) == "string" and label ~= "" and label ~= "ERROR" and label ~= "NULL" then
        return label
    end
    return "High Card"
end

local function get_remaining_consumable_slots()
    if not (G and G.consumeables and G.consumeables.config) then
        return 0
    end

    local current_round = G.GAME and G.GAME.current_round
    local reserved = (current_round and current_round.porkify_deaddrop_reserved_planets) or 0
    local limit = G.consumeables.config.card_limit or 0

    return math.max(0, limit - #G.consumeables.cards - reserved)
end

SMODS.Joker{ -- Dead Drop
    key = "deaddrop",
    config = { extra = {} },
    loc_txt = {
        ["name"] = "Dead Drop",
        ["text"] = {
            [1] = "{C:gold}Gold{} and {C:blue}Blue{} Seals trigger",
            [2] = "when {C:red}discarded{}"
        }
    },
    pos = { x = 9, y = 6 },
    display_size = { w = 71, h = 95 },
    cost = 8,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = false,
    atlas = "CustomJokers",
    pools = { ["modprefix_porkify_jokers"] = true },

    loc_vars = function(self, info_queue, card)
        local xm = (card and card.ability and card.ability.extra and card.ability.extra.Xmult) or 1

        local info_queue_0 = G.P_SEALS and G.P_SEALS["Gold"]
        if info_queue_0 then
            info_queue[#info_queue + 1] = info_queue_0
        else
            error("JOKERFORGE: Invalid key in infoQueues. \"c_porkify_estrogen\" isn't a valid Object key, Did you misspell it or forgot a modprefix?")
        end

        local info_queue_1 = G.P_SEALS and G.P_SEALS["Blue"]
        if info_queue_1 then
            info_queue[#info_queue + 1] = info_queue_1
        else
            error("JOKERFORGE: Invalid key in infoQueues. \"c_porkify_testosterone\" isn't a valid Object key, Did you misspell it or forgot a modprefix?")
        end

        return { vars = { xm } }
    end,

    calculate = function(self, card, context)
        if not context.blueprint
            and context.before
            and context.cardarea == G.jokers
            and context.scoring_name
            and G and G.GAME then
            G.GAME.current_round = G.GAME.current_round or {}
            G.GAME.current_round.porkify_deaddrop_last_hand = context.scoring_name
        end

        if context.pre_discard and not context.blueprint and G and G.GAME then
            G.GAME.current_round = G.GAME.current_round or {}
            G.GAME.current_round.porkify_deaddrop_reserved_planets = 0
        end

        if context.discard and context.other_card then
            local seal = context.other_card.seal or (context.other_card.ability and context.other_card.ability.seal)

            if seal == "Gold" then
                return {
                    dollars = 3
                }
            end

            if seal == "Blue" then
                local hand_name = get_last_played_hand()
                local planet_key = get_planet_key_for_hand(hand_name)

                if not planet_key or get_remaining_consumable_slots() <= 0 then
                    return
                end

                G.GAME.current_round.porkify_deaddrop_reserved_planets =
                    (G.GAME.current_round.porkify_deaddrop_reserved_planets or 0) + 1

                return {
                    func = function()
                        local current_round = G and G.GAME and G.GAME.current_round
                        if current_round then
                            current_round.porkify_deaddrop_reserved_planets =
                                math.max(0, (current_round.porkify_deaddrop_reserved_planets or 1) - 1)
                        end

                        if not (G and G.consumeables and #G.consumeables.cards < (G.consumeables.config.card_limit or 0)) then
                            return true
                        end

                        local created = SMODS.add_card({ set = "Planet", key = planet_key })
                        if created then
                            card_eval_status_text(
                                card,
                                "extra",
                                nil,
                                nil,
                                nil,
                                { message = localize("k_plus_planet"), colour = G.C.PLANET }
                            )
                        end

                        return true
                    end
                }
            end
        end
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { ref_table = "card.joker_display_values", ref_value = "target_hand", colour = G.C.SECONDARY_SET["Planet"] }
            },

            calc_function = function(card)
                card.joker_display_values.target_hand = get_last_played_hand_label()
            end
        }
    end
}
