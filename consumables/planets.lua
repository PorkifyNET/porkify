-- One softlocked Planet for every Porkify poker hand. Keeping this table
-- explicit makes card keys, names, and atlas positions stable across updates.
PORKIFY_PLANET_HANDS = {
    { 'three_pair',              'Haumea' },
    { 'four_pair',               'Makemake' },
    { 'straighter',              'Sedna' },
    { 'flushier',                'Triton' },
    { 'straighter_flush',        'Proxima Centauri B' },
    { 'straightest',             'Orcus' },
    { 'flushiest',               'Charon' },
    { 'straightest_flush',       'Kepler-22b' },
    { 'straighterest',           'Quaoar' },
    { 'flushiester',             'Gonggong' },
    { 'straighterest_flush',     'Vesta' },
    { 'two_by_fours',            'Pallas' },
    { 'fuller_house',            'Hygiea' },
    { 'fullest_house',           'Salacia' },
    { 'double_trouble',          'Varuna' },
    { 'four_plus_two',           'Ixion' },
    { 'boarding_house',          'Chaos' },
    { 'five_plus_two',           'Arrokoth' },
    { 'apartment_block',         'Albion' },
    { 'mansion',                 'Leleakuhonua' },
    { 'six_plus_two',            'Farfarout' },
    { 'flush_three_pair',        'Phobos' },
    { 'flush_four_pair',         'Deimos' },
    { 'flush_fuller_house',      'Io' },
    { 'flush_fullest_house',     'Europa' },
    { 'flush_two_by_fours',      'Ganymede' },
    { 'six_of_a_kind',           'Callisto' },
    { 'flush_six',               'Enceladus' },
    { 'seven_of_a_kind',         'Titan' },
    { 'flush_seven',             'Rhea' },
    { 'eight_of_a_kind',         'Iapetus' },
    { 'flush_eight',             'Oberon' },
    { 'bulwark',                 'Methuselah' },
    { 'yes',                     'The Great Attractor' },
}

local planet_text = {
    '({V:1}lvl.#1#{}) Level up',
    '{C:attention}#2#{}',
    '{C:mult}+#3#{} Mult and',
    '{C:chips}+#4#{} Chips',
}

local function planet_loc_vars(self)
    local hand = G.GAME.hands[self.config.hand_type]
    local level = math.floor(type(to_number) == 'function' and to_number(hand.level) or hand.level)
    return {
        vars = {
            hand.level,
            localize(self.config.hand_type, 'poker_hands'),
            hand.l_mult,
            hand.l_chips,
            colours = {
                level == 1 and G.C.UI.TEXT_DARK
                    or G.C.HAND_LEVELS[math.min(7, level)]
            }
        }
    }
end

for index, spec in ipairs(PORKIFY_PLANET_HANDS) do
    local hand_key = 'porkify_' .. spec[1]
    SMODS.Consumable {
        key = 'planet_' .. spec[1],
        set = 'Planet',
        atlas = 'CustomPlanets',
        pos = { x = (index - 1) % 10, y = math.floor((index - 1) / 10) },
        config = { hand_type = hand_key, softlock = true },
        cost = 3,
        unlocked = true,
        discovered = false,
        effect = 'Hand Upgrade',
        loc_txt = { name = spec[2], text = planet_text },
        loc_vars = planet_loc_vars,
        ai_art_badge = true,
    }
end
