SMODS.Joker {
    key = "netanyahu",
    loc_txt = {
        name = "Netanyahu",
        text = {
            [1] = "When entering the {C:green}shop{},",
            [2] = "create a {C:rare}Rare{} {C:attention}Joker{} and",
            [3] = "add {C:attention}Rental{} to a random",
            [4] = "other {C:attention}Joker{}",
            [5] = "{C:inactive}(Must have room){}",
            [6] = "{C:6FC6D2,s:0.75}Tel Aviv Impressed{}"
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
                if not (G.jokers and G.jokers.cards and G.jokers.config)
                    or #G.jokers.cards + (G.GAME.joker_buffer or 0) >= (G.jokers.config.card_limit or 0) then
                    return true
                end

                G.GAME.joker_buffer = (G.GAME.joker_buffer or 0) + 1
                local created = SMODS.add_card({
                    set = "Joker",
                    rarity = "Rare",
                    key_append = "porkify_netanyahu",
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

                    local rental_candidates = {}
                    for _, owned_joker in ipairs(G.jokers.cards) do
                        local ability = owned_joker and owned_joker.ability
                        if owned_joker ~= card
                            and ability
                            and not ability.rental
                            and not owned_joker.getting_sliced
                            and not owned_joker.removed
                            and not owned_joker.destroyed
                            and not owned_joker.shattered
                            and (owned_joker.dissolve == nil or owned_joker.dissolve == 0)
                        then
                            rental_candidates[#rental_candidates + 1] = owned_joker
                        end
                    end

                    if #rental_candidates > 0 then
                        local rental_target = pseudorandom_element(
                            rental_candidates,
                            pseudoseed("porkify_netanyahu_rental")
                        )
                        if rental_target and rental_target.set_rental then
                            rental_target:set_rental(true)
                            rental_target:juice_up(0.3, 0.5)
                            card_eval_status_text(
                                rental_target,
                                "extra",
                                nil,
                                nil,
                                nil,
                                { message = "Rental!", colour = G.C.MONEY }
                            )
                        end
                    end
                end

                return true
            end
        }
    end
}
