local function has_edition(card, key)
    local edition = card and card.edition
    return not not (not (card and card.debuff) and edition and edition.key == key)
end

local function held_consumables()
    return #(G.consumeables and G.consumeables.cards or {})
end

local function get_runtime_edition(card)
    return (card and card.edition) or {}
end

local function get_gilded_interest()
    if not G.GAME or G.GAME.modifiers.no_interest then
        return 0
    end

    local dollars = G.GAME.dollars or 0
    local interest_amount = G.GAME.interest_amount or 1
    local interest_cap = G.GAME.interest_cap or 25
    return math.max(interest_amount * math.min(math.floor(dollars / 5), interest_cap / 5), 0)
end

local edition_defs = {
    e_porkify_sepia = {
        condition_function = function(card)
            return has_edition(card, "e_porkify_sepia")
        end,
        mod_function = function(card)
            local edition = get_runtime_edition(card)
            return { x_chips = edition.xchips0 or 2 }
        end
    },
    e_porkify_ionized = {
        condition_function = function(card)
            return has_edition(card, "e_porkify_ionized")
        end,
        mod_function = function(card)
            local edition = get_runtime_edition(card)
            local base = edition.base_xmult or 5
            local penalty = edition.ante_penalty or 0.5
            local ante = math.max(0, (G.GAME.round_resets.ante or 1) - 1)
            return { x_mult = base - (ante * penalty) }
        end
    },
    e_porkify_laminated = {
        condition_function = function(card)
            return has_edition(card, "e_porkify_laminated")
        end,
        mod_function = function(card)
            local edition = get_runtime_edition(card)
            local base = edition.consumablesheld or 1
            return { x_mult = base + (held_consumables() * 0.5) }
        end
    },
    e_porkify_gilded = {
        condition_function = function(card)
            return has_edition(card, "e_porkify_gilded")
        end,
        mod_function = function(card)
            return { dollars = math.floor(get_gilded_interest() / 2) }
        end
    }
}

for key, definition in pairs(edition_defs) do
    JokerDisplay.Edition_Definitions[key] = definition
end
