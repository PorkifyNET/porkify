local definitions = {}
local added_cards = {}
local created_types = {}
local shop_rarity_modifier

SMODS = {
    Back = function(definition) definitions[definition.key] = definition end,
    add_card = function(args)
        added_cards[#added_cards + 1] = args
        return args
    end
}

G = {
    C = { SECONDARY_SET = { Tarot = {} } },
    GAME = {
        modifiers = {},
        selected_back = { effect = { center = { key = 'b_porkify_celestial_deck' } } }
    },
    consumeables = { cards = {}, config = { card_limit = 2 } },
    pack_cards = {},
    shop_jokers = {},
    E_MANAGER = { add_event = function(self, event) return event.func() end }
}

Event = function(event) return event end
localize = function(key) return key end
pseudorandom = function() return 0.1 end
create_card = function(card_type)
    created_types[#created_types + 1] = card_type
    return { set = card_type }
end
create_card_for_shop = function()
    shop_rarity_modifier = G.GAME.uncommon_mod or G.GAME.rare_mod
    return {}
end

dofile(TEST_ROOT .. '/decks/arcana_celestial_spectral_decks.lua')
dofile(TEST_ROOT .. '/decks/rarity_decks.lua')

local arcana = assert(definitions.arcana_deck)
local celestial = assert(definitions.celestial_deck)
local spectral = assert(definitions.spectral_deck)
local uncommon = assert(definitions.uncommon_deck)
local rare = assert(definitions.rare_deck)

arcana:apply()
assert(#added_cards == 2 and added_cards[1].set == 'Tarot' and added_cards[2].set == 'Tarot',
    'Arcana Deck must start with two random Tarot cards')
added_cards = {}
celestial:apply()
assert(#added_cards == 2 and added_cards[1].set == 'Planet' and added_cards[2].set == 'Planet',
    'Celestial Deck must start with two random Planet cards')
added_cards = {}
spectral:apply()
assert(#added_cards == 2 and added_cards[1].set == 'Spectral' and added_cards[2].set == 'Spectral',
    'Spectral Deck must start with two random Spectral cards')
assert(spectral.config.vouchers[1] == 'v_omen_globe',
    'Spectral Deck must start with Omen Globe')

added_cards = {}
G.consumeables.cards = {}
local effect = arcana:calculate({}, { open_booster = true })
assert(effect and type(effect.func) == 'function')
effect.func()
assert(#added_cards == 1 and added_cards[1].set == 'Tarot',
    'Arcana Deck must create a Tarot after a successful roll')
G.consumeables.cards = { {}, {} }
assert(arcana:calculate({}, { open_booster = true }) == nil,
    'Arcana Deck must respect the consumable limit')

SMODS.OPENED_BOOSTER = { config = { center = { kind = 'Arcana' } } }
create_card('Tarot', G.pack_cards, nil, nil, true, true, nil, 'arcana')
assert(created_types[#created_types] == 'Planet',
    'Celestial Deck must allow Planet cards in Arcana Packs')
SMODS.OPENED_BOOSTER.config.center.kind = 'Spectral'
create_card('Tarot', G.pack_cards, nil, nil, true, true, nil, 'other')
assert(created_types[#created_types] == 'Tarot',
    'Celestial Deck must not alter Tarot creation outside Arcana Packs')

G.GAME.modifiers = {}
uncommon:apply()
create_card_for_shop(G.shop_jokers)
assert(shop_rarity_modifier == 2 and G.GAME.uncommon_mod == nil,
    'Uncommon Deck must double shop rarity weight without leaking the modifier')
assert(Porkify_get_rarity_deck_pack_bonus('p_porkify_uncommon_joker_pack') == 2)
assert(Porkify_get_rarity_deck_pack_bonus('p_porkify_rare_joker_pack') == 0)

G.GAME.modifiers = {}
rare:apply()
create_card_for_shop(G.shop_jokers)
assert(shop_rarity_modifier == 2 and G.GAME.rare_mod == nil,
    'Rare Deck must double shop rarity weight without leaking the modifier')
assert(Porkify_get_rarity_deck_pack_bonus('p_porkify_rare_joker_pack') == 2)
assert(Porkify_get_rarity_deck_pack_bonus('p_porkify_uncommon_joker_pack') == 0)

print('Deck starting cards, pack effects, and shop rarity checks passed')
