local function selected_deck_is(key)
    local center = G and G.GAME and G.GAME.selected_back
        and G.GAME.selected_back.effect and G.GAME.selected_back.effect.center
    return center and center.key == 'b_porkify_' .. key
end

local function add_starting_consumables(set, count)
    G.E_MANAGER:add_event(Event({
        func = function()
            if not (G and G.consumeables) then return true end

            for _ = 1, count do
                SMODS.add_card({ set = set, area = G.consumeables })
            end
            return true
        end
    }))
end

SMODS.Back {
    key = 'arcana_deck',
    pos = { x = 2, y = 1 },
    config = {},
    loc_txt = {
        name = 'Arcana Deck',
        text = {
            'Start with {C:attention}2{} random {C:tarot}Tarot{} cards',
            '{C:green}1 in 2{} chance to create a {C:tarot}Tarot{}',
            'card when any {C:attention}Booster Pack{} is opened',
            '{C:inactive}(Must have room){}'
        }
    },
    unlocked = true,
    discovered = true,
    atlas = 'CustomDecks',

    apply = function()
        add_starting_consumables('Tarot', 2)
    end,

    calculate = function(self, back, context)
        if not (context and context.open_booster and G and G.consumeables
            and G.consumeables.cards and G.consumeables.config)
        then
            return
        end

        if #G.consumeables.cards >= (G.consumeables.config.card_limit or 0)
            or pseudorandom('porkify_arcana_deck_booster') >= 0.5
        then
            return
        end

        return {
            message = localize('k_plus_tarot'),
            colour = G.C.SECONDARY_SET.Tarot,
            func = function()
                if G.consumeables and G.consumeables.cards and G.consumeables.config
                    and #G.consumeables.cards < (G.consumeables.config.card_limit or 0)
                then
                    SMODS.add_card({ set = 'Tarot', area = G.consumeables })
                end
                return true
            end
        }
    end
}

SMODS.Back {
    key = 'celestial_deck',
    pos = { x = 3, y = 1 },
    config = {},
    loc_txt = {
        name = 'Celestial Deck',
        text = {
            'Start with {C:attention}2{} random {C:planet}Planet{} cards',
            '{C:planet}Planet{} cards may appear',
            'in {C:tarot}Arcana Packs{}'
        }
    },
    unlocked = true,
    discovered = true,
    atlas = 'CustomDecks',

    apply = function()
        add_starting_consumables('Planet', 2)
    end
}

SMODS.Back {
    key = 'spectral_deck',
    pos = { x = 0, y = 1 },
    config = {
        vouchers = { 'v_omen_globe' }
    },
    loc_txt = {
        name = 'Spectral Deck',
        text = {
            'Start with {C:attention}2{} random {C:spectral}Spectral{} cards',
            'and the {C:attention,T:v_omen_globe}Omen Globe{} Voucher'
        }
    },
    unlocked = true,
    discovered = true,
    atlas = 'CustomDecks',

    apply = function()
        add_starting_consumables('Spectral', 2)
    end
}

-- Arcana packs ask create_card for Tarot cards while they are being populated.
-- Change only those requests so other Tarot sources remain untouched.
if type(create_card) == 'function' and not Porkify_create_card_celestial_deck then
    Porkify_create_card_celestial_deck = create_card
    function create_card(_type, area, legendary, rarity, skip_materialize, soulable, forced_key, key_append)
        local opened = SMODS and SMODS.OPENED_BOOSTER
        local kind = opened and opened.config and opened.config.center and opened.config.center.kind
        if _type == 'Tarot' and area == G.pack_cards and forced_key == nil
            and kind == 'Arcana' and selected_deck_is('celestial_deck')
            and pseudorandom('porkify_celestial_deck_arcana') < 0.2
        then
            _type = 'Planet'
            key_append = 'porkify_celestial_deck'
        end

        return Porkify_create_card_celestial_deck(
            _type, area, legendary, rarity, skip_materialize, soulable, forced_key, key_append
        )
    end
end
