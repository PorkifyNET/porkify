local blinds, checks = {}, 0
SMODS.Blind = function(def) blinds[def.key] = def end
for _, file in ipairs({ 'StickerBosses', 'Bully', 'EcoWarrior', 'Scientist', 'Wipe', 'Error', 'Tax' }) do
    dofile(TEST_ROOT .. '/blinds/' .. file .. '.lua')
end
local function expect(value, message)
    assert(value, message)
    checks = checks + 1
end
local rolls, probability, high_roll = 0, true, false
function pseudoseed(value) return value end
function pseudorandom_element(cards) return cards[1] end
function pseudorandom(seed, low, high)
    rolls = rolls + 1
    return high_roll and high or low
end
function number_format(n) return tostring(n) end
function localize(s) return s end
SMODS.pseudorandom_probability = function(blind, seed, n, d)
    assert(n == 1 and d == 2)
    return probability
end
SMODS.get_probability_vars = function(blind, n, d) return n, d end
local function reset(key)
    G = {
        GAME = {
            round_resets = { ante = 3 }, current_round = { discards_left = 3 },
            used_vouchers = {}, perishable_rounds = 5, interest_cap = 25, dollars = 25,
            hands = { ['Pair'] = { level = 4 }, porkify_flushier = { level = 8 } },
            blind = { effect = {}, chips = 1000, dollars = 5, wiggle = function() end },
        },
        hand = { highlighted = {}, cards = {} }, jokers = { cards = {} }, playing_cards = {},
        P_CENTERS = { c_base = { key = 'c_base', set = 'Default' } },
    }
    G.GAME.blind.config = { blind = blinds[key] }
    probability, high_roll, rolls = true, false, 0
    return G.GAME.blind
end
local function joker()
    return {
        dissolve = 0, -- Normal cards retain zero after their materialization animation.
        ability = {}, config = { center = { eternal_compat = true, perishable_compat = true } },
        juice_up = function() end,
        set_rental = function(self, val) self.ability.rental = val end,
        set_perishable = function(self, val) self.ability.perishable = val; self.ability.perish_tally = G.GAME.perishable_rounds end,
        set_eternal = function(self, val) self.ability.eternal = val end,
    }
end
for key, sticker in pairs({ landlord = 'rental', virus = 'perishable', stapler = 'eternal' }) do
    local blind = reset(key)
    blinds[key]:press_play() -- no Jokers
    local first, second = joker(), joker()
    G.jokers.cards = { first, second }
    probability = false
    blinds[key]:press_play()
    expect(not first.ability[sticker], key .. ' failed-roll behavior')
    probability = true
    blinds[key]:press_play()
    expect(first.ability[sticker] == true, key .. ' applies sticker')
    blinds[key]:press_play()
    expect(second.ability[sticker] == true, key .. ' skips existing stickers')
    if key == 'virus' then expect(first.ability.perish_tally == 5, 'Perishable timer initializes') end
    local third = joker()
    G.jokers.cards = { third }
    blind.disabled = true
    blinds[key]:press_play()
    expect(not third.ability[sticker], key .. ' disabled')
end
for key, sticker in pairs({ landlord = 'rental', virus = 'perishable', stapler = 'eternal' }) do
    for _, flag in ipairs({ 'getting_sliced', 'removed', 'destroyed', 'shattered', 'dissolve' }) do
        reset(key)
        local invalid, valid = joker(), joker()
        invalid[flag] = flag == 'dissolve' and 0.5 or true
        G.jokers.cards = { invalid, valid }
        blinds[key]:press_play()
        expect(not invalid.ability[sticker] and valid.ability[sticker], key .. ' excludes ' .. flag)
    end
    reset(key)
    local fresh = joker()
    fresh.dissolve = nil
    G.jokers.cards = { fresh }
    blinds[key]:press_play()
    expect(fresh.ability[sticker], key .. ' accepts cards without an animation value')
end
for _, key in ipairs({ 'virus', 'stapler' }) do
    reset(key)
    local a, b, c = joker(), joker(), joker()
    if key == 'virus' then a.ability.eternal = true; b.config.center.perishable_compat = false
    else a.ability.perishable = true; b.config.center.eternal_compat = false end
    G.jokers.cards = { a, b, c }
    blinds[key]:press_play()
    local sticker = key == 'virus' and 'perishable' or 'eternal'
    expect(not a.ability[sticker] and not b.ability[sticker] and c.ability[sticker], key .. ' compatibility')
end

local blind = reset('eco_warrior')
for _, remaining in ipairs({ 4, 1, 0, -1 }) do
    G.GAME.current_round.discards_left = remaining
    local effect = blinds.eco_warrior:calculate(blind, { final_scoring_step = true })
    expect(effect.x_mult == 1 / math.max(1, remaining), 'Eco-Warrior divisor')
end
expect(blinds.eco_warrior:calculate(blind, { before = true }) == nil, 'Eco-Warrior only final scoring')
blind.disabled = true
expect(blinds.eco_warrior:calculate(blind, { final_scoring_step = true }) == nil, 'Eco-Warrior disabled')
blind = reset('scientist')
for _, name in ipairs({ 'Pair', 'porkify_flushier', 'unknown' }) do
    local effect = blinds.scientist:calculate(blind, { final_scoring_step = true, scoring_name = name })
    expect(effect.x_mult == 1 / (G.GAME.hands[name] and G.GAME.hands[name].level or 1), 'Scientist levels')
end
G.GAME.hands.Pair.level = 0
expect(blinds.scientist:calculate(blind, { final_scoring_step = true, scoring_name = 'Pair' }).x_mult == 1, 'Scientist zero level')
blind.disabled = true
expect(blinds.scientist:calculate(blind, { final_scoring_step = true }) == nil, 'Scientist disabled')

blind = reset('wipe')
local function enhanced(key)
    return {
        config = { center = { key = key, set = 'Enhanced' } }, seal = 'Red', edition = { foil = true },
        set_ability = function(self, center) self.config.center = center end,
    }
end
local glass, stone, held = enhanced('m_glass'), enhanced('m_stone'), enhanced('m_porkify_mimic')
G.hand.highlighted, G.hand.cards = { glass, stone }, { glass, stone, held }
blinds.wipe:press_play()
expect(glass.config.center == G.P_CENTERS.c_base and stone.config.center == G.P_CENTERS.c_base, 'Wipe played enhancements')
expect(held.config.center.key == 'm_porkify_mimic', 'Wipe preserves held cards')
expect(glass.seal == 'Red' and glass.edition.foil, 'Wipe preserves seals and editions')
blind.disabled = true
G.hand.highlighted = { held }
blinds.wipe:press_play()
expect(held.config.center.key == 'm_porkify_mimic', 'Wipe disabled')

blind = reset('bully')
expect(not blinds.bully:in_pool(), 'Bully needs Magnet')
G.GAME.used_vouchers.v_porkify_magnet = true
expect(blinds.bully:in_pool(), 'Bully enters pool with Magnet')
local a = { playing_card = 1, ability = { favorite = true } }
local b = { playing_card = 2, ability = {} }
G.playing_cards = { a, b }
function Porkify_refresh_favorite_stickers()
    -- Model the Favorite moving to a new card when the original is debuffed.
    if a.debuff then a.ability.favorite = nil; b.ability.favorite = true end
end
SMODS.recalc_debuff = function(card) card.debuff = blinds.bully:recalc_debuff(card) end
blinds.bully:set_blind()
expect(a.debuff and not b.debuff and b.ability.favorite, 'Bully locks initial Favorite')
blinds.bully:set_blind()
expect(a.debuff and not b.debuff, 'Bully does not retarget on reset')
local saved_effect = blind.effect
G.GAME.blind = { effect = saved_effect }
expect(blinds.bully:recalc_debuff(a) and not blinds.bully:recalc_debuff(b), 'Bully snapshot persists')
G.GAME.blind.disabled = true
blinds.bully:disable()
expect(not a.debuff and not b.debuff, 'Bully disable clears debuffs')

for _, upper in ipairs({ false, true }) do
    blind = reset('error')
    high_roll = upper
    blinds.error:set_blind()
    expect(blind.chips == (upper and 10000 or 100), 'ERROR score range')
    expect(blind.dollars == (upper and 50 or 1), 'ERROR reward range')
    expect(blind.chip_text == tostring(blind.chips), 'ERROR score display')
    expect(#G.GAME.current_round.dollars_to_be_earned == blind.dollars, 'ERROR reward display')
    local old_rolls, chips, dollars = rolls, blind.chips, blind.dollars
    blinds.error:set_blind()
    expect(rolls == old_rolls and blind.chips == chips and blind.dollars == dollars, 'ERROR no reroll')
    G.GAME.blind = { effect = blind.effect, chips = chips, dollars = dollars }
    blinds.error:set_blind()
    expect(rolls == old_rolls, 'ERROR no reroll after load')
end
blind = reset('error')
blind.dollars = 0
blinds.error:set_blind()
expect(blind.dollars == 0, 'ERROR preserves no-reward modifiers')

blind = reset('tax')
for _, cap in ipairs({ 25, 50, 100 }) do
    G.GAME.interest_cap, G.GAME.dollars = cap, cap - 1
    expect(not blinds.tax:stay_flipped(G.hand, {}), 'Tax below interest cap')
    G.GAME.dollars = cap
    expect(blinds.tax:stay_flipped(G.hand, {}), 'Tax at interest cap')
    expect(blinds.tax:loc_vars().vars[1] == cap, 'Tax description follows cap')
end
expect(not blinds.tax:stay_flipped({}, {}), 'Tax only draws into hand')
expect(blinds.tax.calculate == nil, 'Tax no longer charges a hand on discard')
blind.disabled = true
expect(not blinds.tax:stay_flipped(G.hand, {}), 'Tax disabled')
local face_down = { facing = 'back', flip = function(self) self.facing = 'front' end }
G.hand.cards = { face_down }
blinds.tax:disable()
expect(face_down.facing == 'front', 'Tax disable reveals cards')
-- Lua 5.1 rejects comparisons between a number and a big-number table.
local original_to_big = to_big
local big_meta = { __le = function(a, b) return a.value <= b.value end }
to_big = function(value)
    if type(value) == 'table' then return value end
    return setmetatable({ value = value }, big_meta)
end
blind = reset('tax')
for _, cap in ipairs({ 25, 50, 100 }) do
    G.GAME.interest_cap = cap
    for _, amount in ipairs({ cap - 1, cap, cap + 1 }) do
        G.GAME.dollars = to_big(amount)
        expect(blinds.tax:stay_flipped(G.hand, {}) == (amount >= cap), 'Tax big-number money threshold')
    end
    G.GAME.interest_cap = to_big(cap)
    expect(blinds.tax:stay_flipped(G.hand, {}), 'Tax big-number interest cap')
end
G.GAME.interest_cap, G.GAME.dollars = nil, to_big(56)
expect(blinds.tax:stay_flipped(G.hand, {}), 'Tax big-number money with default cap')
to_big = original_to_big
print('Passed ' .. checks .. ' new Boss Blind effect checks.')
