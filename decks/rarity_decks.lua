local function set_deck_modifier(key)
    G.GAME.modifiers = G.GAME.modifiers or {}
    G.GAME.modifiers[key] = true
end

SMODS.Back {
    key = 'uncommon_deck',
    pos = { x = 4, y = 1 },
    config = {},
    loc_txt = {
        name = 'Uncommon Deck',
        text = {
            '{C:uncommon}Uncommon{} Jokers are {C:attention}2X{}',
            'as likely to appear in the {C:attention}Shop{}',
            '{C:uncommon}Uncommon Joker Packs{} have',
            '{C:attention}2{} more cards to choose from'
        }
    },
    unlocked = true,
    discovered = true,
    atlas = 'CustomDecks',

    apply = function()
        set_deck_modifier('porkify_uncommon_deck')
    end
}

SMODS.Back {
    key = 'rare_deck',
    pos = { x = 5, y = 1 },
    config = {},
    loc_txt = {
        name = 'Rare Deck',
        text = {
            '{C:rare}Rare{} Jokers are {C:attention}2X{}',
            'as likely to appear in the {C:attention}Shop{}',
            '{C:rare}Rare Joker Packs{} have',
            '{C:attention}2{} more cards to choose from'
        }
    },
    unlocked = true,
    discovered = true,
    atlas = 'CustomDecks',

    apply = function()
        set_deck_modifier('porkify_rare_deck')
    end
}

function Porkify_get_rarity_deck_pack_bonus(pack_key)
    local modifiers = G and G.GAME and G.GAME.modifiers or {}
    if pack_key == 'p_porkify_uncommon_joker_pack' and modifiers.porkify_uncommon_deck then
        return 2
    end
    if pack_key == 'p_porkify_rare_joker_pack' and modifiers.porkify_rare_deck then
        return 2
    end
    return 0
end

-- Scope the rarity multiplier to shop generation; Buffoon Packs and other
-- random Joker sources retain their normal rarity distribution.
if type(create_card_for_shop) == 'function' and not Porkify_create_card_for_shop_rarity_decks then
    Porkify_create_card_for_shop_rarity_decks = create_card_for_shop
    function create_card_for_shop(area)
        local game = G and G.GAME
        local modifiers = game and game.modifiers or {}
        local rarity_key

        if area == G.shop_jokers and modifiers.porkify_uncommon_deck then
            rarity_key = 'uncommon_mod'
        elseif area == G.shop_jokers and modifiers.porkify_rare_deck then
            rarity_key = 'rare_mod'
        end

        if not rarity_key then
            return Porkify_create_card_for_shop_rarity_decks(area)
        end

        local old_modifier = game[rarity_key]
        game[rarity_key] = (old_modifier or 1) * 2
        local ok, card = pcall(Porkify_create_card_for_shop_rarity_decks, area)
        game[rarity_key] = old_modifier

        if not ok then error(card) end
        return card
    end
end
