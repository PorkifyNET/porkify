SMODS.Joker {
    key = "netanyahu",
    loc_txt = {
        name = "Netanyahu",
        text = {
            [1] = "When entering the {C:green}shop{},",
            [2] = "set money to {C:money}$0{} and create",
            [3] = "a {C:rare}Rare{} {C:attention}Joker{}",
            [4] = "{C:inactive}(Must have room){}",
            [5] = "{C:6FC6D2,s:0.75}Tel Aviv Impressed{}"
        }
    },
    pos = { x = 4, y = 10 }, -- Placeholder artwork.
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

    calculate = function(self, card, context)
        if not (context.starting_shop and not context.blueprint and G and G.GAME) then
            return
        end

        return {
            func = function()
                local current_dollars = tonumber(G.GAME.dollars) or 0
                if current_dollars ~= 0 then
                    ease_dollars(-current_dollars, true)
                end

                if not (G.jokers and G.jokers.cards and G.jokers.config)
                    or #G.jokers.cards + (G.GAME.joker_buffer or 0) >= (G.jokers.config.card_limit or 0) then
                    card_eval_status_text(
                        card,
                        "extra",
                        nil,
                        nil,
                        nil,
                        { message = "$0", colour = G.C.MONEY }
                    )
                    return true
                end

                G.GAME.joker_buffer = (G.GAME.joker_buffer or 0) + 1
                local created = SMODS.add_card({
                    set = "Joker",
                    rarity = "Rare"
                })
                G.GAME.joker_buffer = math.max(0, (G.GAME.joker_buffer or 1) - 1)

                if created then
                    card:juice_up(0.3, 0.5)
                    card_eval_status_text(
                        created,
                        "extra",
                        nil,
                        nil,
                        nil,
                        { message = "Rare!", colour = G.C.RARITY[3] }
                    )
                end

                return true
            end
        }
    end
}
