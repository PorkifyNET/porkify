SMODS.Joker{
    key = "orchard_spirit",
    loc_txt = {
        name = "Orchard Spirit",
        text = {
            [1] = "At end of round,",
            [2] = "create a random",
            [3] = "{C:spades,E:1}Perishable{} {C:attention}Joker{}"
        }
    },
    rarity = "porkify_ruleset",
    cost = 0,
	pos = { x = 7, y = 5 },
    unlocked = true,
    discovered = false,
	no_collection = true,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = false,
    atlas = "CustomJokers",
    pools = { ["modprefix_porkify_jokers"] = false }, -- keep it out of pools/shops

    calculate = function(self, card, context)
        -- Only do this in your challenge (we'll set this custom rule in the challenge file)
        if not (G.GAME and G.GAME.modifiers and G.GAME.modifiers.porkify_orchard_challenge) then
            return
        end

        if context.end_of_round and context.main_eval then
            return {
                func = function()
                    if not (G.jokers and G.jokers.cards and G.P_CENTER_POOLS and G.P_CENTER_POOLS.Joker) then
                        return true
                    end

                    -- build a list of allowed joker keys
                    local pool = {}
                    for _, center in pairs(G.P_CENTER_POOLS.Joker) do
                        if center
                            and center.set == "Joker"
                            and center.key
                            and not (G.GAME.banned_keys and G.GAME.banned_keys[center.key])
                        then
                            pool[#pool+1] = center.key
                        end
                    end
                    if #pool == 0 then return true end

                    -- pick one
                    local joker_key = pseudorandom_element(pool, "porkify_orchard_spawn")

                    -- create + add it
                    local j = SMODS.create_card({ area = G.jokers, key = joker_key })
                    G.jokers:emplace(j)
                    j:start_materialize()

                    -- make it Perishable
                    j:add_sticker("perishable", true)

                    play_sound("timpani")
                    return true
                end
            }
        end
    end,
}
