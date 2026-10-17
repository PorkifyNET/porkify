local M = {}

local function restriction_ids(entries)
    local ids = {}
    for _, entry in ipairs(entries or {}) do
        if entry.id then ids[entry.id] = true end
        for _, id in ipairs(entry.ids or {}) do ids[id] = true end
    end
    return ids
end

local function add_restrictions(challenge, field, ids)
    if not challenge then return end
    challenge.restrictions = challenge.restrictions or {}
    local entries = challenge.restrictions[field]
    if type(entries) == 'function' then entries = entries() end
    entries = entries or {}
    challenge.restrictions[field] = entries

    local present = restriction_ids(entries)
    for _, value in ipairs(ids or {}) do
        local id = type(value) == 'table' and value.id or value
        if not present[id] then
            entries[#entries + 1] = type(value) == 'table' and value or { id = id }
            present[id] = true
        end
    end
end

local function find_challenge(id)
    for _, challenge in ipairs((G and G.CHALLENGES) or {}) do
        local challenge_id = challenge.id or challenge.key
        -- Steamodded's Challenge class prefixes vanilla IDs with `c_` and
        -- Porkify IDs with `c_porkify_`. Accept the raw form as well for
        -- compatibility with older Steamodded builds and focused tests.
        if challenge_id == id
            or challenge_id == 'c_' .. id
            or challenge_id == 'c_porkify_' .. id then
            return challenge
        end
    end
end

local function center_keys_for_sets(sets)
    local wanted, found, keys = {}, {}, {}
    for _, set in ipairs(sets) do wanted[set] = true end

    local function consider(center, set_override)
        local center_set = center and (center.set or set_override)
        if center and center.key and wanted[center_set] and not found[center.key] then
            found[center.key] = true
            keys[#keys + 1] = center.key
        end
    end

    -- P_CENTER_POOLS contains vanilla and already-injected modded cards.
    for set, pool in pairs((G and G.P_CENTER_POOLS) or {}) do
        if wanted[set] then
            for _, center in ipairs(pool or {}) do
                consider(center, set)
            end
        end
    end

    -- During mod loading, registered centers may not have reached the live
    -- pools yet. Include them so category bans also cover Porkify's Planets.
    local registered_centers = (SMODS and SMODS.Center and SMODS.Center.obj_table)
        or (SMODS and SMODS.Centers)
        or {}
    for _, center in pairs(registered_centers) do consider(center) end

    table.sort(keys)
    return keys
end

local function joker_keys_matching(predicate)
    local found, keys = {}, {}
    local function consider(joker)
        if joker and joker.key and not found[joker.key] and predicate(joker) then
            found[joker.key] = true
            keys[#keys + 1] = joker.key
        end
    end

    for _, joker in ipairs((G and G.P_CENTER_POOLS and G.P_CENTER_POOLS.Joker) or {}) do
        consider(joker)
    end
    -- Modded centers are registered before they are injected into
    -- G.P_CENTER_POOLS. Current Steamodded keeps them in Center.obj_table;
    -- SMODS.Jokers is only an old compatibility alias and may not exist.
    local registered_centers = (SMODS and SMODS.Joker and SMODS.Joker.obj_table)
        or (SMODS and SMODS.Centers)
        or {}
    for _, joker in pairs(registered_centers) do
        if joker.set == 'Joker' then consider(joker) end
    end
    table.sort(keys)
    return keys
end

local function copy_counts(counts)
    local result = {}
    for key, value in pairs(counts or {}) do result[key] = value end
    return result
end

local function use_omega_for_challenge_protection(challenge)
    if not challenge or challenge.porkify_omega_compat_applied then return end
    challenge.porkify_omega_compat_applied = true

    -- Replace challenge-wide Eternal with Omega. Omega's should_apply hook
    -- handles every Joker created while this modifier is active.
    local custom_rules = (challenge.rules and challenge.rules.custom) or {}
    for _, rule in ipairs(custom_rules) do
        if rule.id == 'all_eternal' then rule.id = 'all_omega' end
        if rule.id == 'set_eternal_ante' then
            challenge.porkify_omega_eternal_ante = rule.value
            rule.no_ui = true
        end
    end
    if challenge.porkify_omega_eternal_ante then
        custom_rules[#custom_rules + 1] = {
            id = 'porkify_set_omega_ante',
            value = challenge.porkify_omega_eternal_ante,
        }
    end

    -- Normalize both vanilla Eternal starters and Porkify's explicit `omega`
    -- starters. Lovely patches teach the run bootstrap and challenge preview
    -- how to apply this field directly.
    local starters = {}
    for _, joker in ipairs(challenge.jokers or {}) do
        if joker.eternal or joker.omega or joker.porkify_omega then
            joker.eternal = nil
            joker.porkify_omega = true
            starters[joker.id] = (starters[joker.id] or 0) + 1
        end
    end
    challenge.porkify_omega_starters = starters

    local previous_apply = challenge.apply
    challenge.apply = function(self, ...)
        local result
        if type(previous_apply) == 'function' then
            result = previous_apply(self, ...)
        end
        if G and G.GAME then
            G.GAME.porkify_omega_starters = copy_counts(self.porkify_omega_starters)
            G.GAME.porkify_omega_eternal_ante = self.porkify_omega_eternal_ante
        end
        return result
    end
end

local ARCANA_SOURCES = {
    'j_porkify_arcanaminor',
    'j_porkify_chance',
    'j_porkify_crashout',
    'j_porkify_dumbell',
    'j_porkify_firealarm',
    'j_porkify_fortunecookie',
    'j_porkify_speedrun',
    'j_porkify_summoningcircle',
    'j_porkify_theheadmaster',
    'c_porkify_spiritbox',
}

local PLANET_SOURCES = {
    'j_porkify_chance',
    'j_porkify_deaddrop',
    'j_porkify_discovery',
    'j_porkify_majora',
    'j_porkify_shootingstar',
    'c_porkify_finalfrontier',
}

local JOKER_SOURCES = {
    'j_porkify_hatchedegg',
    'j_porkify_loading',
    'j_porkify_netanyahu',
    'j_porkify_paul',
    'c_porkify_mephiles',
    'c_porkify_primate',
    'c_porkify_top_up_consumable',
    'p_porkify_common_joker_pack',
    'p_porkify_uncommon_joker_pack',
    'p_porkify_rare_joker_pack',
    'p_porkify_giga_buffoon_pack',
}

local JOKER_SOURCE_TAGS = {
    'tag_joker',
    'tag_uncommon',
    'tag_rare',
    'tag_negative',
    'tag_foil',
    'tag_holo',
    'tag_polychrome',
    'tag_topup',
    'tag_porkify_gold_seal',
}

local FIXED_HAND_SIZE_BREAKERS = {
    'j_porkify_appletree',
    'j_porkify_paint',
}

local EXTRA_HAND_SOURCES = {
    'j_porkify_aquacard',
    'j_porkify_sleightofhand',
}

local STRAIGHT_REWARD_SOURCES = {
    'j_porkify_cairn',
}

local JOKER_SLOT_SOURCES = {
    'j_porkify_kitty',
    'j_porkify_cardsleeve',
}

local MONEY_JOKERS = {
    'j_porkify_bailout',
    'j_porkify_bounty',
    'j_porkify_cairn',
    'j_porkify_chaostheory',
    'j_porkify_coupon',
    'j_porkify_deaddrop',
    'j_porkify_grandma',
    'j_porkify_luckynumber7s',
    'j_porkify_nu',
    'j_porkify_overspeed',
    'j_porkify_recycler',
    'j_porkify_samesong',
    'j_porkify_trashcan',
    'j_porkify_tungstencube',
    'j_porkify_yellowcard',
}

local MONEY_NON_JOKERS = {
    'c_porkify_carteblanche',
    'c_porkify_casualwalk',
    'c_porkify_cleptomane',
    'c_porkify_trashtreasure',
    'c_porkify_stockbroker',
    'v_porkify_silverspoon',
    'v_porkify_heirloom',
}

local ENHANCEMENT_REPLACERS = {
    'j_porkify_milestone',
    'j_porkify_shipwreck',
    'c_porkify_asteroid',
    'c_porkify_connectthedots',
    'c_porkify_diamondhands',
    'c_porkify_electron',
    'c_porkify_emeraldtablet',
    'c_porkify_life',
    'c_porkify_paperball',
    'c_porkify_pharaoh',
    'c_porkify_reflection',
    'c_porkify_revolver',
    'c_porkify_sacrifice',
    'c_porkify_universe',
}

local NON_GLASS_CARD_SOURCES = {
    'c_porkify_medusa',
    'c_porkify_sacrifice',
}

local NON_GLASS_TAG_SOURCES = {
    'tag_porkify_enhanced',
    'tag_porkify_gravitas',
    'tag_porkify_mimic',
}

local NON_LUCKY_CARD_SOURCES = {
    'c_porkify_doubleornothing',
    'c_porkify_medusa',
    'c_porkify_sacrifice',
}

local PLAYING_CARD_CREATION_SOURCES = {
    'j_porkify_fissionjoker',
    'c_porkify_doubleornothing',
    'c_porkify_medusa',
    'c_porkify_sacrifice',
}

local PLAYING_CARD_SOURCE_TAGS = {
    'tag_porkify_gravitas',
    'tag_porkify_mimic',
}

local PLAYING_CARD_DESTRUCTION_SOURCES = {
    'j_sixth_sense',
    'j_trading',
    'c_familiar',
    'c_grim',
    'c_incantation',
    'c_hanged_man',
    'c_immolate',
    'j_porkify_fissionjoker',
    'j_porkify_mallard',
    'j_porkify_pickaxe',
    'j_porkify_theheadmaster',
    'c_porkify_sacrifice',
    'c_porkify_surgery',
}

local JOKER_DESTRUCTION_SOURCES = {
    'j_ceremonial',
    'j_madness',
    'j_gros_michel',
    'j_cavendish',
    'j_ice_cream',
    'j_invisible',
    'j_mr_bones',
    'j_popcorn',
    'j_ramen',
    'j_selzer',
    'j_turtle_bean',
    'j_sixth_sense',
    'j_trading',
    'j_porkify_cupofcoffee',
    'j_porkify_doppelganger',
    'j_porkify_dynamite',
    'j_porkify_hatchedegg',
    'j_porkify_paul',
    'j_porkify_potion',
    'j_porkify_refridgerator',
    'j_porkify_rewind',
    'c_ankh',
    'c_hex',
    'c_porkify_conjoined',
    'c_porkify_timemachine',
}

local GLASS_DESTRUCTION_SOURCES = {
    'm_glass',
    'c_justice',
    'j_porkify_firealarm',
    'c_porkify_doubleornothing',
}

local GLASS_REMOVING_BLINDS = {
    { id = 'bl_porkify_wipe', type = 'blind' },
}

function M.apply()
    -- Challenge-owned protection must survive Excalibur. This migration is
    -- applied to vanilla and modded challenges alike.
    for _, challenge in ipairs((G and G.CHALLENGES) or {}) do
        use_omega_for_challenge_protection(challenge)
    end

    -- Porkify's category challenges ban the actual cards as well as every
    -- Porkify card that can create or otherwise interact with that category.
    local no_heresy = find_challenge('noheresy')
    add_restrictions(no_heresy, 'banned_cards', center_keys_for_sets({ 'Tarot', 'Spectral' }))
    add_restrictions(no_heresy, 'banned_cards', ARCANA_SOURCES)

    local no_astronomy = find_challenge('noastronomy')
    add_restrictions(no_astronomy, 'banned_cards', center_keys_for_sets({ 'Planet' }))
    add_restrictions(no_astronomy, 'banned_cards', PLANET_SOURCES)

    -- Challenges whose premise fixes the hand size must exclude positive
    -- Hand Size sources. Effects which only reduce Hand Size remain legal.
    add_restrictions(find_challenge('ragsnriches'), 'banned_cards', FIXED_HAND_SIZE_BREAKERS)
    add_restrictions(find_challenge('five_card_1'), 'banned_cards', FIXED_HAND_SIZE_BREAKERS)

    -- Both challenges are balanced around their fixed number of Hands.
    for _, id in ipairs({ 'blast_off_1', 'golden_needle_1' }) do
        add_restrictions(find_challenge(id), 'banned_cards', EXTRA_HAND_SOURCES)
    end

    -- Cover both vanilla Jokerless and Porkify's no-Joker acquisition
    -- challenges. The regular Buffoon Pack and tags are already banned by the
    -- base definitions; these are the Porkify-specific escape hatches.
    for _, id in ipairs({ 'jokerless_1', 'orchard', 'thechosenone', 'riffraffle' }) do
        local challenge = find_challenge(id)
        add_restrictions(challenge, 'banned_cards', JOKER_SOURCES)
        add_restrictions(challenge, 'banned_tags', JOKER_SOURCE_TAGS)
    end
    add_restrictions(find_challenge('jokerless_1'), 'banned_cards', JOKER_SLOT_SOURCES)

    -- A Joker that cannot accept Eternal also cannot obey Non-Perishable's
    -- defining rule. Derive this list from center metadata so new Jokers are
    -- covered without another hand-maintained update.
    add_restrictions(find_challenge('non_perishable_1'), 'banned_cards',
        joker_keys_matching(function(joker) return joker.eternal_compat == false end))

    add_restrictions(find_challenge('inflation_1'), 'banned_cards', {
        'j_porkify_yardsale',
        'j_porkify_doppelganger',
    })

    -- Fragile must not be able to replace Glass or introduce a non-Glass
    -- playing card. Double or Nothing and Fission preserve/create Glass, so
    -- they intentionally remain available here.
    local fragile = find_challenge('fragile_1')
    add_restrictions(fragile, 'banned_cards', ENHANCEMENT_REPLACERS)
    add_restrictions(fragile, 'banned_cards', NON_GLASS_CARD_SOURCES)
    add_restrictions(fragile, 'banned_tags', NON_GLASS_TAG_SOURCES)
    add_restrictions(fragile, 'banned_other', GLASS_REMOVING_BLINDS)

    -- These challenges remove alternative income routes while retaining the
    -- named, challenge-specific source of money.
    local chicken_farm = find_challenge('chickenfarm')
    add_restrictions(chicken_farm, 'banned_cards', MONEY_JOKERS)
    add_restrictions(chicken_farm, 'banned_cards', MONEY_NON_JOKERS)
    add_restrictions(chicken_farm, 'banned_tags', { 'tag_porkify_gold_seal' })

    add_restrictions(find_challenge('kingmidas'), 'banned_cards', MONEY_JOKERS)

    -- Cairn is Porkify's Straight-specific payout Joker. The vanilla
    -- Straight scorers and level cards live in Roadblocked's own ban list.
    add_restrictions(find_challenge('roadblocked'), 'banned_cards', STRAIGHT_REWARD_SOURCES)

    local gambling = find_challenge('letsgogambling')
    add_restrictions(gambling, 'banned_cards', MONEY_JOKERS)
    add_restrictions(gambling, 'banned_cards', ENHANCEMENT_REPLACERS)
    add_restrictions(gambling, 'banned_cards', NON_LUCKY_CARD_SOURCES)
    add_restrictions(gambling, 'banned_tags', NON_GLASS_TAG_SOURCES)

    local green_world = find_challenge('greenworld')
    add_restrictions(green_world, 'banned_cards', PLAYING_CARD_DESTRUCTION_SOURCES)
    add_restrictions(green_world, 'banned_cards', JOKER_DESTRUCTION_SOURCES)
    add_restrictions(green_world, 'banned_cards', GLASS_DESTRUCTION_SOURCES)

    -- Extend WYSIWYG's own restrictions with every Porkify route that changes
    -- the number of playing cards in the deck.
    local wysiwyg = find_challenge('wysiwyg')
    add_restrictions(wysiwyg, 'banned_cards', PLAYING_CARD_CREATION_SOURCES)
    add_restrictions(wysiwyg, 'banned_cards', PLAYING_CARD_DESTRUCTION_SOURCES)
    add_restrictions(wysiwyg, 'banned_cards', GLASS_DESTRUCTION_SOURCES)
    add_restrictions(wysiwyg, 'banned_tags', PLAYING_CARD_SOURCE_TAGS)
end

return M
