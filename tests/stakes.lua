local function noop() end
function copy_table(t) local r = {}; for k,v in pairs(t) do r[k] = v end; return r end
function HEX(s) return s end
local definitions = {}
SMODS = {Sticker = {}, Stickers = {perishable = {loc_vars = noop}, rental = {loc_vars = noop}}}
SMODS.Stake = function(t) definitions[#definitions + 1] = t end
SMODS.load_file = loadfile
SMODS.add_to_pool = function() return true end
SMODS.calculate_context = noop
function SMODS.Sticker:should_apply(card, center)
    return self.sets[center.set] and (not self.needs_enable_flag or G.GAME.modifiers['enable_' .. self.key])
end
G = {GAME = {modifiers = {}, round = 1, dollars = 100, blind = {boss = false}},
    playing_cards = {}, consumeables = {cards = {}}, hand = {size = 8}, shop_jokers = {},
    pack_cards = {}, shop_vouchers = {}, shop_booster = {}}
function G.hand:change_size(n) self.size = self.size + n end
Card = {set_cost = noop, open = noop, redeem = noop, use_consumeable = noop}
function Card:add_to_deck() self.added_to_deck = true end
function Card:can_use_consumeable() return true end
function Card:start_dissolve() self.destroyed = true end
Card.shatter = Card.start_dissolve
function Card:calculate_perishable()
    if self.ability.perishable and self.ability.perish_tally > 0 then
        self.ability.perish_tally = self.ability.perish_tally - 1
        if self.ability.perish_tally == 0 then self.debuff = true end
    end
end
function Card:calculate_rental() if self.ability.rental then ease_dollars(-3) end end
CardArea = {emplace = function(self, card) card.area = self end}
local roll = 0
function pseudorandom() return roll end
function ease_dollars(n) G.GAME.dollars = G.GAME.dollars + n end
card_eval_status_text = noop
function create_card(kind, area)
    return setmetatable({ability = {set = kind, consumeable = kind == 'Tarot', h_size = 0},
        config = {center = {set = kind}}, area = area}, {__index = Card})
end
dofile('stakes/stakes.lua')
local names = {'pink','sulfur','lapis','diamond','ruby','sapphire','emerald','platinum','onyx','topaz'}
assert(#definitions == #names)
G.GAME.modifiers.scaling = 3
for i, def in ipairs(definitions) do
    assert(def.key == 'stake_' .. names[i])
    assert(def.above_stake == (i == 1 and 'stake_gold' or 'stake_porkify_stake_' .. names[i-1]))
    assert(def.applied_stakes[1] == def.above_stake)
    def.modifiers(def)
end
assert(G.GAME.modifiers.scaling == 5 and G.GAME.win_ante == 10)
assert(G.GAME.modifiers.no_blind_reward.Big)
roll = 0.8
local eternal = create_card('Default', G.shop_jokers)
assert(eternal.ability.eternal and eternal.ability.rental)
eternal:start_dissolve(); eternal:shatter(); assert(not eternal.destroyed)
local ordinary = create_card('Default', G.hand)
assert(not ordinary.ability.eternal)
ordinary:start_dissolve(); assert(ordinary.destroyed)
roll = 0.5
local decay = create_card('Default', G.pack_cards)
local tarot = create_card('Tarot', G.shop_jokers)
assert(decay.ability.perish_tally == 5 and tarot.ability.perish_tally == 1)
G.playing_cards = {decay, eternal}
G.consumeables.cards = {tarot}
eternal.area = G.hand
tarot.ability.rental = true
SMODS.calculate_context({end_of_round = true})
assert(decay.ability.perish_tally == 4 and tarot.debuff)
assert(not tarot:can_use_consumeable())
assert(G.GAME.dollars == 94)
SMODS.calculate_context({end_of_round = true})
assert(G.GAME.dollars == 94 and decay.ability.perish_tally == 4)
eternal.area = {} -- rentals outside the hand do not charge
G.GAME.round = 2
SMODS.calculate_context({end_of_round = true})
assert(G.GAME.dollars == 91)
for n = 3,5 do G.GAME.round = n; SMODS.calculate_context({end_of_round = true}) end
assert(decay.debuff)
G.playing_cards = {}; G.consumeables.cards = {}
G.GAME.round = 6; G.GAME.dollars = 103; G.GAME.blind.boss = true
SMODS.calculate_context({end_of_round = true})
assert(G.GAME.dollars == 78)
SMODS.calculate_context({end_of_round = true})
assert(G.GAME.dollars == 78)
G.GAME.round = 7; G.GAME.dollars = -5
SMODS.calculate_context({end_of_round = true})
assert(G.GAME.dollars == -5)
local bulky = setmetatable({sets = {Joker = true}, key = 'porkify_bulky', needs_enable_flag = true}, {__index = SMODS.Sticker})
assert(bulky:should_apply(tarot, tarot.config.center, G.shop_jokers))
G.GAME.modifiers.enable_porkify_bulky = nil
assert(not bulky:should_apply(tarot, tarot.config.center, G.shop_jokers))
G.GAME.modifiers.porkify_sulfur = false
assert(not bulky:should_apply(tarot, tarot.config.center, G.shop_jokers))
roll = 0.2
local hidden = create_card('Tarot', G.shop_jokers)
CardArea.emplace(G.shop_jokers, hidden)
assert(hidden.facing == 'back')
roll = 0.9
CardArea.emplace(G.shop_jokers, hidden)
assert(hidden.facing == 'back')
SMODS.calculate_context({buying_card = true, card = hidden})
assert(hidden.facing == 'front')
for _, key in ipairs({'bl_final_heart','bl_final_vessel','bl_final_leaf','bl_final_bell','bl_final_acorn'}) do
    local ok, opt = SMODS.add_to_pool({key = key}); assert(ok and opt.ignore_showdown_check)
end
local _, opt = SMODS.add_to_pool({key = 'bl_hook'}); assert(not opt)
G.GAME.modifiers.porkify_early_showdowns = false
local _, disabled_opt = SMODS.add_to_pool({key = 'bl_final_heart'}); assert(not disabled_opt)
local cramped = create_card('Default', G.hand)
cramped.ability.h_size = -1
cramped:add_to_deck(); assert(G.hand.size == 7)
cramped:add_to_deck(); assert(G.hand.size == 7)
setmetatable(SMODS.Sticker, {__call = function(_, def) SMODS.Stickers[def.key] = def end})
dofile('stickers/stickers.lua')
local bulky_def = SMODS.Stickers.bulky
bulky_def:apply(cramped, true)
assert(cramped.ability.extra_slots_used == 1)
bulky_def:apply(cramped, true)
assert(cramped.ability.extra_slots_used == 1)
assert(bulky_def:loc_vars({}, cramped).vars[1] == 'Hand Size')
assert(bulky_def:loc_vars({}, tarot).vars[1] == 'Consumable Slots')
bulky_def:apply(cramped, false)
assert(cramped.ability.extra_slots_used == 0)
local cramped_def = SMODS.Stickers.cramped
cramped_def:apply(cramped, true)
assert(G.hand.size == 6)
cramped_def:apply(cramped, false)
assert(G.hand.size == 7)
print('Stake inheritance, sticker lifecycle, tax, hidden shop and Showdown checks passed')
