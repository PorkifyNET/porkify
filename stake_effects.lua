local function playing(card)
    return card and card.ability and (card.playing_card or card.ability.set == 'Default' or card.ability.set == 'Enhanced')
end

local function consumable(card)
    return card and card.ability and card.ability.consumeable
end

local function enabled(key)
    return G and G.GAME and G.GAME.modifiers and G.GAME.modifiers[key]
end

local function source(area)
    return area and (area == G.shop_jokers or area == G.pack_cards)
end

local perish_vars = SMODS.Stickers.perishable.loc_vars
SMODS.Stickers.perishable.loc_vars = function(self, queue, card)
    if consumable(card) then return {key = 'porkify_perishable_consumable'} end
    return perish_vars(self, queue, card)
end
local rental_vars = SMODS.Stickers.rental.loc_vars
SMODS.Stickers.rental.loc_vars = function(self, queue, card)
    if playing(card) then return {key = 'porkify_rental_playing'} end
    if consumable(card) then return {vars = {3}} end
    return rental_vars(self, queue, card)
end

-- Preserve sticker compatibility, enable flags and rolls when extending their sets.
local should_apply = SMODS.Sticker.should_apply
function SMODS.Sticker:should_apply(card, center, area, bypass_roll)
    if enabled('porkify_sulfur') and source(area) and (playing(card) or consumable(card))
        and self.sets and self.sets.Joker then
        local proxy = setmetatable({sets = {[center.set] = true}}, {__index = self})
        local result = should_apply(proxy, card, center, area, bypass_roll)
        self.last_roll = proxy.last_roll
        return result
    end
    return should_apply(self, card, center, area, bypass_roll)
end

-- Vanilla stickers use a separate, shared roll instead of Sticker.should_apply.
local create = create_card
function create_card(kind, area, ...)
    local card = create(kind, area, ...)
    if enabled('porkify_sulfur') and source(area) and (playing(card) or consumable(card)) then
        local center = card.config.center
        local roll = pseudorandom('porkify_sulfur_stickers')
        if roll > 0.7 and center.eternal_compat ~= false and not card.ability.perishable then
            card.ability.eternal = true
        elseif roll > 0.4 and roll <= 0.7 and center.perishable_compat ~= false and not card.ability.eternal then
            card.ability.perishable = true
            card.ability.perish_tally = playing(card) and 5 or 1
        end
        if pseudorandom('porkify_sulfur_rental') > 0.7 and center.rental_compat ~= false then
            card.ability.rental = true
        end
        card:set_cost()
    end
    return card
end

local add = Card.add_to_deck
function Card:add_to_deck(...)
    local apply = not self.added_to_deck and playing(self)
    local result = add(self, ...)
    -- Vanilla returns early for playing cards on addition, but removes h_size normally.
    if apply and self.added_to_deck and G.hand and (self.ability.h_size or 0) ~= 0 then
        G.hand:change_size(self.ability.h_size)
    end
    return result
end

local can_use = Card.can_use_consumeable
function Card:can_use_consumeable(...)
    if self.debuff then return false end
    return can_use(self, ...)
end

for _, method in ipairs({'start_dissolve', 'shatter'}) do
    local original = Card[method]
    Card[method] = function(self, ...)
        if playing(self) and self.ability.eternal then return end
        return original(self, ...)
    end
end

local perishable = Card.calculate_perishable
function Card:calculate_perishable(...)
    if playing(self) or consumable(self) then
        if not self.ability.perishable or self.ability.porkify_perish_round == G.GAME.round then return end
        self.ability.porkify_perish_round = G.GAME.round
        self.ability.perish_tally = self.ability.perish_tally or (playing(self) and 5 or 1)
        if consumable(self) then self.ability.perish_tally = math.min(1, self.ability.perish_tally) end
    end
    return perishable(self, ...)
end

local rental = Card.calculate_rental
function Card:calculate_rental(...)
    if playing(self) or consumable(self) then
        if not self.ability.rental or self.ability.porkify_rental_round == G.GAME.round then return end
        if playing(self) and self.area ~= G.hand then return end
        self.ability.porkify_rental_round = G.GAME.round
        ease_dollars(-3)
        card_eval_status_text(self, 'dollars', -3)
        return
    end
    return rental(self, ...)
end

local function reveal(card)
    if card and card.ability and card.ability.porkify_shop_hidden then
        card.ability.porkify_shop_hidden = nil
        card.facing = 'front'
        card.sprite_facing = 'front'
    end
end

local emplace = CardArea.emplace
function CardArea:emplace(card, ...)
    local result = emplace(self, card, ...)
    if enabled('porkify_hidden_shop') and (self == G.shop_jokers or self == G.shop_vouchers or self == G.shop_booster)
        and card and card.ability then
        if not card.ability.porkify_shop_hidden_rolled then
            card.ability.porkify_shop_hidden_rolled = true
            card.ability.porkify_shop_hidden = pseudorandom('porkify_hidden_shop') < 0.3 or nil
        end
        if card.ability.porkify_shop_hidden then
            card.facing = 'back'
            card.sprite_facing = 'back'
        end
    end
    return result
end

for _, method in ipairs({'open', 'redeem', 'use_consumeable'}) do
    local original = Card[method]
    Card[method] = function(self, ...)
        reveal(self)
        return original(self, ...)
    end
end

local calculate = SMODS.calculate_context
function SMODS.calculate_context(context, ...)
    if context.buying_card then reveal(context.card) end
    local result = calculate(context, ...)
    if context.end_of_round and not context.individual and not context.repetition and not context.game_over then
        for _, cards in ipairs({G.playing_cards or {}, G.consumeables and G.consumeables.cards or {}}) do
            for _, card in ipairs(cards) do
                if not card.removed and not card.getting_sliced then
                    card:calculate_perishable()
                    card:calculate_rental()
                end
            end
        end
        if enabled('porkify_ante_tax') and G.GAME.blind and G.GAME.blind.boss
            and G.GAME.porkify_tax_round ~= G.GAME.round then
            local dollars = to_big and to_big(G.GAME.dollars) or G.GAME.dollars
            local zero = to_big and to_big(0) or 0
            if dollars > zero then
                ease_dollars(-math.floor(dollars * 0.25))
            end
            G.GAME.porkify_tax_round = G.GAME.round
        end
    end
    return result
end

local showdowns = {bl_final_heart = true, bl_final_vessel = true, bl_final_leaf = true,
    bl_final_bell = true, bl_final_acorn = true}
local in_pool = SMODS.add_to_pool
function SMODS.add_to_pool(obj, ...)
    local allowed, options = in_pool(obj, ...)
    if allowed and enabled('porkify_early_showdowns') and showdowns[obj.key] then
        options = copy_table(options or {})
        options.ignore_showdown_check = true
    end
    return allowed, options
end
