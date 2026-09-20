local definitions, earned, checks = {}, {}, 0
local all_unlocked_profile = false
local queue = {}
G.STAGES = { RUN = 1, MENU = 2 }
G.STAGE = G.STAGES.RUN
G.E_MANAGER = { add_event = function(self, event) queue[#queue + 1] = event end }
function Event(event) return event end
local function drain()
    while #queue > 0 do assert(table.remove(queue, 1).func()) end
end
PORKIFY_FOOD_JOKERS = { j_egg = true, j_porkify_pizza = true }
SMODS.Achievement = function(def) definitions[def.key] = def end
SMODS.PokerHands = {}
SMODS.PokerHand = function(def) SMODS.PokerHands['porkify_' .. def.key] = def end
SMODS.has_enhancement = function(card, id) return card.enhancement == id end
SMODS.is_playing_card = function(card) return card.base ~= nil end
SMODS.calculate_context = function() return { preserved = true } end
SMODS.pinch_and_remove = function(card) return not card.protected end
Card = {}
function Card:get_id() return self.no_rank and -1 or self.base.id end
function Card:is_suit(suit) return not self.no_suit and self.base.suit == suit end
function Card:start_dissolve()
    if self.protected then return false end
    self.dissolve = 0
end
Card.shatter = Card.start_dissolve
function Card:add_to_deck() self.added_to_deck = true end
function Card:set_ability(center) self.config = { center = center } end
function Card:set_seal(seal) self.seal = seal end
function Card:set_edition(edition) self.edition = edition end
function Card:use_consumeable() end
function Card:remove()
    for i, card in ipairs(G.playing_cards) do
        if card == self then table.remove(G.playing_cards, i); break end
    end
end
function add_tag() end
CardArea = {}
function CardArea:emplace(card)
    self.cards[#self.cards + 1] = card
    card.area = self
end
function CardArea:parse_highlighted() end
G.STATES = { SELECTING_HAND = 1, GAME_OVER = 2 }
Game = {
    update_game_over = function() return 'game over' end,
    start_run = function(self, args)
        G.GAME.stake = args and (args.stake_choice or args.stake) or 1
        return 'started'
    end,
}
function ease_ante(amount)
    G.E_MANAGER:add_event(Event({ func = function()
        G.GAME.round_resets.ante = G.GAME.round_resets.ante + amount
        return true
    end }))
end
function check_for_unlock(args)
    for id, def in pairs(definitions) do
        if def:unlock_condition(args) and (not all_unlocked_profile or def.bypass_all_unlocked) then
            earned[id] = true
        end
    end
end
function evaluate_poker_hand(cards)
    local results = { Straight = get_straight(cards, 5, false, false) }
    for name, def in pairs(SMODS.PokerHands) do results[name] = def.evaluate({}, cards) end
    return results
end
dofile(TEST_ROOT .. '/poker_hands.lua')
dofile(TEST_ROOT .. '/achievements.lua')
local count = 0
for _, def in pairs(definitions) do
    count = count + 1
    assert(type(def.loc_txt.description) == 'string' and def.hidden_name == false)
end
assert(count == 36)
local function reset()
    earned = {}
    G.STAGE = G.STAGES.RUN
    G.GAME = { round_resets = { ante = 1 }, used_vouchers = {}, hands = {} }
    G.jokers = { cards = {}, highlighted = {} }
    G.playing_cards = {}
    G.consumeables = { cards = {} }
    G.hand = setmetatable({ cards = {}, highlighted = {} }, { __index = CardArea })
    G.STATE = G.STATES.SELECTING_HAND
end
local function expect(id, expected)
    assert(not not earned[id] == expected, id .. ': expected ' .. tostring(expected))
    checks = checks + 1
end
local function joker(id)
    return setmetatable({ config = { center = { key = id, set = 'Joker' } },
        ability = {}, added_to_deck = true, area = G.jokers }, { __index = Card })
end
local function own(...)
    G.jokers.cards = {}
    for _, id in ipairs({ ... }) do G.jokers.cards[#G.jokers.cards + 1] = joker(id) end
    check_for_unlock { type = 'modify_jokers' }
end
local function playing(rank, enhancement, seal)
    local rankless = enhancement == 'm_stone' or enhancement == 'm_porkify_meteor' or enhancement == 'm_porkify_exclaim' or enhancement == 'm_porkify_mimic'
    return setmetatable({ base = { id = rank, suit = 'Spades' }, enhancement = enhancement,
        seal = seal, no_rank = rankless, no_suit = rankless }, { __index = Card })
end
local function play(cards)
    check_for_unlock { type = 'hand_contents', cards = cards }
end
reset()
own('j_porkify_porky')
expect('porkylive', true)
expect('farewell', false)
SMODS.calculate_context { selling_card = true, card = G.jokers.cards[1] }
expect('farewell', true)
reset()
local cat = joker('j_porkify__3')
cat.protected = true
cat:start_dissolve()
expect('angry_cat', false)
cat.protected = false
cat:start_dissolve()
expect('angry_cat', true)
reset()
cat = joker('j_porkify__3')
cat.protected = true
SMODS.pinch_and_remove(cat)
expect('angry_cat', false)
cat.protected = false
SMODS.pinch_and_remove(cat)
expect('angry_cat', true)
reset()
cat = joker('j_porkify__3')
cat:shatter()
expect('angry_cat', true)
reset()
SMODS.calculate_context { selling_card = true, card = joker('j_porkify__3') }
expect('angry_cat', true)
reset()
cat = joker('j_porkify__3')
cat.area, cat.added_to_deck = nil, false
cat:start_dissolve()
expect('angry_cat', false)
reset()
own('j_porkify_loading')
expect('bffs', false)
check_for_unlock { type = 'win' }
expect('bffs', false)
reset()
own('j_porkify_kitty')
expect('bffs', false)
G.jokers.cards[1].dissolve = 0
G.jokers.cards[1].debuff = true
check_for_unlock { type = 'win' }
expect('bffs', true)
reset()
own('j_porkify_kitty')
own('j_egg')
check_for_unlock { type = 'win' }
expect('bffs', false)
reset()
own('j_porkify_kitty')
G.jokers.cards[1].getting_sliced = true
check_for_unlock { type = 'win' }
expect('bffs', false)
print('Passed BFFs win, ownership, debuff, and removal checks.')
reset()
own('j_porkify_loading')
expect('extremely_picky', false)
check_for_unlock { type = 'win' }
expect('extremely_picky', true)
reset()
own('j_porkify_encore')
expect('no_death_coin', false)
check_for_unlock { type = 'win' }
expect('no_death_coin', true)
reset()
own('j_porkify_encore', 'j_egg')
check_for_unlock { type = 'win' }
expect('no_death_coin', false)
reset()
ease_ante(-1)
expect('big_bang', false)
drain()
expect('big_bang', true)
reset()
ease_ante(-2)
drain()
expect('big_bang', false)
reset()
play({ playing(6, 'm_glass', 'porkify_dice') })
expect('mis_input', false)
play({ playing(6, 'm_glass'), playing(8, nil, 'porkify_dice') })
expect('mis_input', true)
reset()
play({ playing(6, 'm_porkify_mirror'), playing(8, nil, 'porkify_dice') })
expect('mis_input', true)
reset()
play({ playing(6), playing(7), playing(2, 'm_stone'), playing(3, 'm_porkify_meteor'), playing(4, 'm_porkify_exclaim') })
expect('grow_up', true)
reset()
play({ playing(6), playing(9) })
expect('grow_up', true)
reset()
play({ playing(2, 'm_porkify_meteor'), playing(6), playing(9), playing(3, 'm_stone'), playing(4, 'm_porkify_meteor') })
expect('grow_up', true)
reset()
play({ playing(6), playing(2, 'm_stone'), playing(9), playing(3, 'm_porkify_exclaim') })
expect('grow_up', false)
reset()
play({ playing(2, 'm_stone'), playing(3, 'm_stone'), playing(7), playing(6) })
expect('grow_up', false)
reset()
play({ playing(6), playing(7), playing(3, 'm_porkify_meteor'), playing(8) })
expect('grow_up', false)
for _, ranks in ipairs({ {}, {6}, {7}, {7, 6}, {9, 6}, {6, 7, 9}, {6, 7, 2}, {6, 9, 2}, {6, 6, 7}, {6, 7, 7}, {6, 9, 9} }) do
    reset()
    local cards = {}
    for _, rank in ipairs(ranks) do cards[#cards + 1] = playing(rank) end
    play(cards)
    expect('grow_up', false)
end
for _, seal in ipairs({ 'porkify_blank', 'blank' }) do
    for position = 1, 3 do
        for _, debuffed in ipairs({ false, true }) do
            reset()
            local cards = { playing(6), playing(7), playing(2, 'm_stone') }
            cards[position].seal = seal
            cards[position].debuff = debuffed
            play(cards)
            expect('grow_up', false)
        end
    end
end
reset()
local blank = playing(6)
blank.ability = { seal = 'porkify_blank' }
play({ blank, playing(9) })
expect('grow_up', false)
reset()
local rankless = playing(2, 'm_stone')
rankless.no_suit = false
play({ playing(6), playing(7), rankless })
expect('grow_up', false)
for _, name in ipairs({ 'estrogen', 'testosterone' }) do
    reset()
    SMODS.calculate_context { using_consumeable = true, consumeable = joker('c_porkify_' .. name) }
    expect('hrt', true)
end
reset()
SMODS.calculate_context { using_consumeable = true, consumeable = joker('c_porkify_excalibur') }
expect('hrt', false)
expect('rules_for_thee', false)
check_for_unlock { type = 'porkify_joker_sticker_removed' }
expect('rules_for_thee', true)
reset()
own('j_egg', 'j_egg', 'j_porkify_pizza', 'j_egg')
expect('supermarket', false)
G.jokers.cards[5] = joker('j_porkify_pizza')
check_for_unlock { type = 'modify_jokers' }
expect('supermarket', true)
reset()
for i = 1, 9 do G.jokers.cards[i] = joker('j_porkify_paul') end
check_for_unlock { type = 'modify_jokers' }
expect('one_for_paul', false)
G.jokers.cards[10] = joker('j_porkify_paul')
check_for_unlock { type = 'modify_jokers' }
expect('one_for_paul', true)
expect('see_you_again', false)
reset()
SMODS.calculate_context { selling_card = true, card = joker('j_porkify_paul') }
expect('see_you_again', false)
check_for_unlock { type = 'porkify_paul_died' }
expect('see_you_again', true)
for handname in pairs(PORKIFY_SECRET_HANDS) do
    reset()
    check_for_unlock { type = 'hand', handname = handname }
    expect('into_the_unknown', true)
    expect('how', handname == 'porkify_yes')
end
reset()
check_for_unlock { type = 'hand', handname = 'Straight Flush' }
expect('into_the_unknown', false)
local deck = { playing(6), playing(7), playing(9) }
G.playing_cards = deck
SMODS.calculate_context { pre_discard = true, full_hand = { deck[1], deck[2] } }
check_for_unlock { type = 'discard_custom', cards = { deck[1], deck[2] } }
expect('why', false)
SMODS.calculate_context { pre_discard = true, full_hand = deck }
check_for_unlock { type = 'discard_custom', cards = { deck[1], deck[2] } }
expect('why', false)
SMODS.calculate_context { pre_discard = true, full_hand = deck }
G.playing_cards = {} -- destruction during discard must not invalidate the snapshot
check_for_unlock { type = 'discard_custom', cards = deck }
expect('why', true)
reset()
SMODS.calculate_context { pre_discard = true, full_hand = {} }
check_for_unlock { type = 'discard_custom', cards = {} }
expect('why', false)
reset()
check_for_unlock { type = 'porkify_glitch_created', porkify_key = 'j_egg' }
expect('the_matrix', false)
check_for_unlock { type = 'porkify_glitch_created', porkify_key = 'j_porkify_glitch' }
expect('the_matrix', true)
reset()
own('j_astronomer', 'j_porkify_cardception')
expect('fire_fest', false)
G.GAME.used_vouchers.v_liquidation = true
check_for_unlock { type = 'run_redeem' }
expect('fire_fest', true)
reset()
own('j_burglar')
expect('cops_and_robbers', false)
own('j_burglar', 'j_porkify_bobby')
expect('cops_and_robbers', true)
reset()
own('j_porkify_hatchedegg', 'j_porkify_paul')
expect('three_man_army', false)
own('j_porkify_hatchedegg', 'j_porkify_paul', 'j_porkify_mallard')
expect('three_man_army', true)
reset()
check_for_unlock { type = 'end_of_round' }
expect('gay', false)
play({ playing(6), playing(6) })
check_for_unlock { type = 'win' }
expect('gay', true)
reset()
local straight = { playing(2), playing(3), playing(4), playing(5), playing(6), playing(9) }
evaluate_poker_hand(straight) -- preview must not invalidate the run
check_for_unlock { type = 'win' }
expect('gay', true)
reset()
play(straight)
play({ playing(6), playing(6) })
assert(G.GAME.porkify_played_straight == true)
check_for_unlock { type = 'win' }
expect('gay', false)
reset()
G.GAME.hands['Straight Flush'] = { played = 1 }
check_for_unlock { type = 'win' }
expect('gay', false)
reset()
G.STAGE = G.STAGES.MENU
own('j_porkify_porky')
check_for_unlock { type = 'porkify_paul_died' }
assert(next(earned) == nil, 'Menu activity unlocked an achievement')
assert(SMODS.calculate_context({}).preserved, 'Context hook lost its return value')

-- Run the actual Joker and consumable callbacks, including their queued events.
local jokers, consumables = {}, {}
SMODS.Joker = function(def) jokers[def.key] = def end
SMODS.Consumable = function(def) consumables[def.key] = def end
SMODS.calculate_effect = function(effect) if effect.func then effect.func() end end
SMODS.pseudorandom_probability = function(card, roll)
    return roll == 'group_chicken_destroy' or roll == 'group_glitch_sell'
end
function card_eval_status_text() end
function play_sound() end
function delay() end
function to_big(value) return value end
function Card:juice_up() end
function Card:flip() end
G.C = { RED = {}, GREEN = {} }
dofile(TEST_ROOT .. '/jokers/paul.lua')
dofile(TEST_ROOT .. '/jokers/glitch.lua')
for _, protected in ipairs({ true, false }) do
    reset()
    local paul = joker('j_porkify_paul')
    paul.ability.extra = jokers.paul.config.extra
    paul.protected = protected
    jokers.paul.calculate(jokers.paul, paul, { end_of_round = true, main_eval = true }).func()
    drain()
    expect('see_you_again', not protected)
end
for _, created_key in ipairs({ 'j_egg', 'j_porkify_glitch' }) do
    reset()
    SMODS.add_card = function() return joker(created_key) end
    local glitch = joker('j_porkify_glitch')
    glitch.ability.extra = jokers.glitch.config.extra
    jokers.glitch.calculate(jokers.glitch, glitch, { selling_card = true, card = joker('j_egg') }).func()
    drain()
    expect('the_matrix', created_key == 'j_porkify_glitch')
end
for name, sticker in pairs({ excalibur = 'eternal', freezer = 'perishable', mortgage = 'rental' }) do
    dofile(TEST_ROOT .. '/consumables/' .. name .. '.lua')
    reset()
    G.jokers.unhighlight_all = function(self) self.highlighted = {} end
    local target = joker('j_egg')
    local consumable = joker('c_porkify_' .. name)
    G.jokers.highlighted = { target }
    consumables[name].use(consumables[name], consumable)
    drain()
    expect('rules_for_thee', false)
    target.ability[sticker] = true
    consumables[name].use(consumables[name], consumable)
    expect('rules_for_thee', false)
    drain()
    expect('rules_for_thee', true)
    assert(target.ability[sticker] == false)
end
-- Use shifted indices to ensure Gold is looked up rather than hardcoded as 8.
G.P_CENTER_POOLS = { Stake = {} }
G.P_STAKES = { stake_gold = { key = 'stake_gold', order = 10 } }
local stakes = {
    [1] = 'stake_white', [10] = 'stake_gold', [11] = 'stake_porkify_stake_diamond',
    [16] = 'stake_porkify_stake_onyx', [17] = 'stake_porkify_stake_ruby',
    [18] = 'stake_porkify_stake_topaz', [19] = 'stake_other_mod',
}
for order, id in pairs(stakes) do G.P_CENTER_POOLS.Stake[order] = { key = id, order = order } end
for order in pairs(stakes) do
    reset()
    assert(Game:start_run({ stake_choice = order }) == 'started')
    expect('once_more_unto_the_breach', order > 10)
    expect('better_than_the_creator', false)
    expect('showoff', false)
    check_for_unlock { type = 'win' }
    expect('better_than_the_creator', order == 16)
    expect('showoff', order == 18)
end
reset()
Game:start_run({ stake = 16, savetext = {} })
expect('once_more_unto_the_breach', false)
check_for_unlock { type = 'win' }
expect('better_than_the_creator', true)
-- Regression: Steamodded normally suppresses awards on Unlock All profiles.
all_unlocked_profile = true
reset()
Game:start_run({ stake_choice = 11 })
expect('once_more_unto_the_breach', true)
reset()
Game:start_run({ stake_choice = 10 })
expect('once_more_unto_the_breach', false)
reset()
Game:start_run({ stake = 11, savetext = {} })
expect('once_more_unto_the_breach', false)
for _, def in pairs(definitions) do assert(def.bypass_all_unlocked == true) end
all_unlocked_profile = false
reset()
Game:start_run()
expect('once_more_unto_the_breach', false)
reset()
Game:start_run({ stake = 999 })
expect('once_more_unto_the_breach', false)
reset()
Game:start_run({ stake = 1 })
own('j_joker')
check_for_unlock { type = 'win' }
expect('laaaaaame', true)
reset()
check_for_unlock { type = 'win' } -- no full-run history for an old save
expect('laaaaaame', false)

local disqualifiers = {
    function() own('j_porkify_porky'); G.jokers.cards = {} end,
    function() local c = joker('c_porkify_estrogen'); c:add_to_deck() end,
    function() local c = joker('c_porkify_testosterone'); c.added_to_deck = false; c.area = nil; c:use_consumeable() end,
    function() SMODS.calculate_context { open_booster = true, card = joker('p_porkify_pack') } end,
    function() G.GAME.used_vouchers.v_porkify_piggyback = true end,
    function() G.GAME.selected_back_key = 'b_porkify_deck' end,
    function() G.GAME.stake = 16 end,
    function() G.GAME.applied_stakes = { 16 } end,
    function() check_for_unlock { type = 'hand', handname = 'porkify_three_pair' } end,
    function() add_tag { key = 'tag_porkify_void' } end,
    function()
        local c = playing(6); G.hand:emplace(c)
        c:set_ability({ key = 'm_porkify_mimic' }); play({ c }); c:set_ability({ key = 'c_base' })
    end,
    function()
        local c = playing(6); G.hand:emplace(c)
        c:set_seal('porkify_dice'); play({ c }); c:set_seal(nil)
    end,
    function()
        local c = playing(6); G.hand:emplace(c)
        c:set_edition({ porkify_sepia = true }); play({ c }); c:set_edition(nil)
    end,
    function()
        local c = playing(6); c:set_edition({ key = 'e_porkify_sepia' }); G.hand:emplace(c); play({ c })
    end,
    function()
        local c = joker('j_joker'); c:set_edition({ porkify_sepia = true }); c:set_edition(nil)
    end,
}
for _, disqualify in ipairs(disqualifiers) do
    reset()
    Game:start_run({ stake = 1 })
    disqualify()
    check_for_unlock { type = 'win' }
    expect('laaaaaame', false)
end
for _, property in ipairs({ 'enhancement', 'seal', 'edition' }) do
    for _, action in ipairs({ 'owned', 'discarded', 'removed_before_play', 'played_debuffed' }) do
        reset()
        Game:start_run({ stake = 1 })
        local c = playing(6)
        G.hand:emplace(c)
        G.playing_cards = { c }
        if property == 'enhancement' then c:set_ability({ key = 'm_porkify_mimic' })
        elseif property == 'seal' then c:set_seal('porkify_dice')
        else c:set_edition({ porkify_sepia = true }) end
        if action == 'discarded' then
            SMODS.calculate_context { pre_discard = true, full_hand = { c } }
            SMODS.calculate_context { discard = true, other_card = c, full_hand = { c } }
            check_for_unlock { type = 'discard_custom', cards = { c } }
        elseif action == 'removed_before_play' then
            c:set_ability({ key = 'c_base' }); c:set_seal(nil); c:set_edition(nil)
            play({ c })
        elseif action == 'played_debuffed' then
            c.debuff = true
            play({ c })
        end
        check_for_unlock { type = 'win' }
        expect('laaaaaame', action ~= 'played_debuffed')
    end
end
reset()
Game:start_run({ stake = 1 })
G.GAME.blind = { config = { blind = { key = 'bl_porkify_twins' } }, get_type = function() return 'Boss' end }
SMODS.calculate_context { setting_blind = true, blind = G.GAME.blind }
check_for_unlock { type = 'win' }
expect('laaaaaame', true)
reset()
Game:start_run({ stake = 1 })
local shop_card = playing(6)
shop_card:set_ability({ key = 'm_porkify_mimic' })
shop_card:set_seal('porkify_dice')
shop_card:set_edition({ porkify_sepia = true })
local shop = setmetatable({ cards = {} }, { __index = CardArea })
shop:emplace(shop_card) -- merely seeing mod content does not count as ownership
check_for_unlock { type = 'win' }
expect('laaaaaame', true)
reset()
Game:start_run({ stake = 1 })
own('j_porkify_joker2')
expect('electric_boogaloo', true)
G.jokers.cards = {}
Game:start_run({ stake = 1, savetext = {} })
check_for_unlock { type = 'win' }
expect('laaaaaame', false) -- removing content and reloading cannot erase its use

reset()
own('j_gros_michel', 'j_gros_michel', 'j_cavendish', 'j_cavendish')
expect('monkey_kingdom', false)
own('j_gros_michel', 'j_gros_michel', 'j_gros_michel', 'j_cavendish', 'j_cavendish')
expect('monkey_kingdom', true)
for _, id in ipairs({ 'j_gros_michel', 'j_cavendish' }) do
    reset(); own(id, id, id, id, id); expect('monkey_kingdom', true)
end

G.P_CENTER_POOLS.Stake[15] = { key = 'stake_porkify_stake_pink', order = 15 }
local function fan_setup()
    reset()
    Game:start_run({ stake = 15 })
    G.GAME.selected_back_key = 'b_porkify_deck'
    G.GAME.used_vouchers.v_porkify_piggyback = true
    own('j_porkify_porky')
    G.playing_cards = { playing(6, 'm_porkify_mimic') }
end
for _, pack in ipairs({ 'p_porkify_tiny_porkify_pack', 'p_porkify_pack', 'p_porkify_jumbo_porkify_pack', 'p_porkify_mega_porkify_pack' }) do
    fan_setup()
    SMODS.calculate_context { open_booster = true, card = joker(pack) }
    expect('huge_fan', false)
    check_for_unlock { type = 'win' }
    expect('huge_fan', true)
end
for _, missing in ipairs({ 'pack', 'stake', 'deck', 'voucher', 'porky', 'mimic' }) do
    fan_setup()
    SMODS.calculate_context { open_booster = true, card = joker('p_porkify_pack') }
    if missing == 'pack' then G.GAME.porkify_pack_opened = nil
    elseif missing == 'stake' then G.GAME.stake = 16
    elseif missing == 'deck' then G.GAME.selected_back_key = 'b_red'
    elseif missing == 'voucher' then G.GAME.used_vouchers = {}
    elseif missing == 'porky' then G.jokers.cards = {}
    elseif missing == 'mimic' then G.playing_cards = {} end
    check_for_unlock { type = 'win' }
    expect('huge_fan', false)
end
fan_setup()
SMODS.calculate_context { open_booster = true, card = joker('p_porkify_giga_buffoon_pack') }
check_for_unlock { type = 'win' }
expect('huge_fan', false)

for ante = 1, 3 do
    for _, blind in ipairs({ 'Small', 'Big', 'Boss' }) do
        reset()
        G.GAME.round_resets.ante = ante
        G.GAME.blind = { get_type = function() return blind end }
        SMODS.calculate_context { end_of_round = true, game_over = true }
        expect('impressed_and_disappointed', false)
        expect('first_time', false)
        G.STATE = G.STATES.GAME_OVER
        assert(Game:update_game_over(0) == 'game over')
        expect('impressed_and_disappointed', ante == 1 and blind == 'Small')
        expect('first_time', ante == 2 and blind == 'Big')
    end
end

-- Selection should award immediately, without requiring the unplayable hand to be played.
local evaluate_ref = evaluate_poker_hand
function evaluate_poker_hand(cards)
    local result = evaluate_ref(cards)
    local blanks = 0
    for _, c in ipairs(cards) do if c.seal == 'porkify_blank' then blanks = blanks + 1 end end
    if blanks > 2 then result.porkify_too_many_blanks = { cards } end
    return result
end
reset()
G.hand.highlighted = { playing(6, nil, 'porkify_blank'), playing(7, nil, 'porkify_blank') }
G.hand:parse_highlighted()
expect('my_pc', false)
G.hand.highlighted[3] = playing(9, nil, 'porkify_blank')
G.hand:parse_highlighted()
expect('my_pc', true)
reset()
G.hand.highlighted = { playing(6, nil, 'porkify_blank'), playing(7, nil, 'porkify_blank'), playing(9, nil, 'porkify_blank') }
function porkify_blank_limit_disabled() return true end
G.hand:parse_highlighted()
expect('my_pc', false)
porkify_blank_limit_disabled = nil
G.STATE = 999 -- pack preview, not selecting a hand
G.hand:parse_highlighted()
expect('my_pc', false)
local function heart(rank)
    local card = playing(rank)
    card.base.suit = 'Hearts'
    return card
end
local deck_cases = {
    { {}, false },
    { { heart(2), heart(11), heart(14) }, true },
    { { heart(12) }, false },
    { { heart(13) }, false },
    { { heart(6), playing(7) }, false },
    { { playing(13, 'm_stone') }, false },
    { { heart(6), playing(13, 'm_stone'), playing(12, 'm_porkify_meteor'),
        playing(13, 'm_porkify_exclaim'), playing(12, 'm_porkify_mimic') }, true },
}
for _, case in ipairs(deck_cases) do
    reset()
    G.playing_cards = case[1]
    check_for_unlock { type = 'modify_deck' }
    expect('soviet_red', case[2])
end
reset()
local wild = playing(6, 'm_wild')
wild.is_suit = function() return true end
G.playing_cards = { heart(6), wild }
check_for_unlock { type = 'modify_deck' }
expect('soviet_red', false)
reset()
local queen = heart(12)
queen.seal, queen.debuff = 'porkify_blank', true
queen.get_id = function() return 6 end
G.playing_cards = { heart(6), queen }
check_for_unlock { type = 'modify_deck' }
expect('soviet_red', false)
queen:remove()
expect('soviet_red', true)
reset()
local suitless = heart(6)
suitless.no_suit = true
G.playing_cards = { heart(7), suitless }
check_for_unlock { type = 'modify_deck' }
expect('soviet_red', false)
reset()
G.playing_cards = { heart(6), playing(7) }
G.in_delete_run = true
G.playing_cards[2]:remove()
check_for_unlock { type = 'modify_deck' }
expect('soviet_red', false)
G.in_delete_run = nil
for _, case in ipairs({ {4, false}, {5, true}, {6, true} }) do
    reset()
    local cards = {}
    for i = 1, case[1] do cards[i] = playing(13) end
    play(cards)
    expect('man_in_black', case[2])
end
for _, invalid in ipairs({ 'wrong_suit', 'wrong_rank', 'stone' }) do
    reset()
    local cards = { playing(13), playing(13), playing(13), playing(13), playing(13) }
    if invalid == 'wrong_suit' then cards[5].base.suit = 'Hearts'
    elseif invalid == 'wrong_rank' then cards[5].base.id = 12
    else cards[5] = playing(13, 'm_stone') end
    play(cards)
    expect('man_in_black', false)
end
for _, method in ipairs({ 'start_dissolve', 'shatter', 'pinch' }) do
    for _, protected in ipairs({ false, true }) do
        for _, sticker in ipairs({ 'favorite', 'porkify_favorite' }) do
            reset()
            local card = playing(6)
            card.ability = { [sticker] = true }
            card.protected = protected
            G.playing_cards = { card }
            if method == 'pinch' then SMODS.pinch_and_remove(card) else card[method](card) end
            expect('unwanted_favorite', not protected)
        end
    end
end
reset()
local favorite = playing(6)
favorite.ability = { favorite = true }
favorite:start_dissolve() -- unowned shop/preview card
expect('unwanted_favorite', false)
reset()
favorite = playing(6)
favorite.ability = { favorite = true }
G.playing_cards = { favorite }
G.in_delete_run = true
favorite:start_dissolve()
G.in_delete_run = nil
expect('unwanted_favorite', false)
for _, case in ipairs({ {0, true, true}, {1, true, false}, {0, false, false} }) do
    reset()
    local target = joker('j_egg')
    target.ability.perishable, target.ability.perish_tally, target.debuff = true, case[1], case[2]
    G.jokers.highlighted = { target }
    G.jokers.unhighlight_all = function(self) self.highlighted = {} end
    consumables.freezer.use(consumables.freezer, joker('c_porkify_freezer'))
    expect('necromancer', false)
    drain()
    expect('necromancer', case[3])
end
local bulwark = {
    playing(2, 'm_stone'), playing(3, 'm_porkify_meteor'),
    playing(4, 'm_porkify_exclaim'), playing(5, 'm_porkify_mimic'), playing(6, 'm_stone'),
}
reset()
assert(#SMODS.PokerHands.porkify_bulwark.evaluate({}, bulwark)[1] == 5)
play(bulwark)
expect('built_different', false)
check_for_unlock { type = 'hand', handname = 'porkify_bulwark', full_hand = bulwark }
expect('built_different', true)
for missing = 1, 4 do
    reset()
    local cards = {}
    for i, card in ipairs(bulwark) do
        cards[i] = card
        if card.enhancement == bulwark[missing].enhancement then
            cards[i] = playing(2, missing == 1 and 'm_porkify_meteor' or 'm_stone')
        end
    end
    check_for_unlock { type = 'hand', handname = 'porkify_bulwark', full_hand = cards }
    expect('built_different', false)
end
reset()
check_for_unlock { type = 'hand', handname = 'porkify_yes', full_hand = bulwark }
expect('built_different', false)
check_for_unlock { type = 'discard_custom', cards = bulwark }
expect('built_different', false)
check_for_unlock { type = 'hand', handname = 'porkify_bulwark' }
expect('built_different', false)
print('Passed ' .. checks .. ' achievement checks and all 36 registrations.')
