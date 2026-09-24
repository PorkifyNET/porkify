local function voucher_ready(card)
    return card and card.ability.porkify_voucher_ready == true
        and not card.debuff and not card.getting_sliced and not card.destroyed
end

local function has_discount()
    for _, card in ipairs(SMODS.find_card('j_porkify_doppelganger')) do
        if voucher_ready(card) then return true end
    end
    return false
end

local function refresh_voucher_prices(except)
    for _, other in pairs(G.I and G.I.CARD or {}) do
        if other ~= except and other.ability and other.ability.set == 'Voucher' then
            other:set_cost()
        end
    end
end

local function queue_price_refresh()
    G.E_MANAGER:add_event(Event({func = function()
        refresh_voucher_prices()
        return true
    end}))
end

SMODS.Joker{
    key = 'doppelganger',
    config = {},
    loc_txt = {
        name = 'Doppelganger',
        text = {
            'Defeat the {C:attention}Boss Blind{}',
            'to make your next',
            '{C:attention}Voucher{} {C:green}free{}',
            '{C:red,E:2}self-destructs{}',
            '{C:inactive}(#1#){}'
        },
        unlock = { 'Sell {C:attention}10{} Jokers' }
    },
    pos = { x = 0, y = 5 },
    display_size = { w = 71, h = 95 },
    cost = 5,
    rarity = 2,
    blueprint_compat = false,
    eternal_compat = false,
    perishable_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { modprefix_porkify_jokers = true },
    unlock_condition = { type = 'c_jokers_sold', extra = 10 },
    credit_badges = {
        { text = 'Art: mrjames246', colour = '59A487' }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { localize(voucher_ready(card) and 'porkify_voucher_ready' or 'porkify_voucher_waiting') } }
    end,
    add_to_deck = queue_price_refresh,
    remove_from_deck = queue_price_refresh,
    calculate = function(self, card, context)
        if context.blueprint or context.retrigger_joker then return end
        if context.buying_card and context.card and context.card.ability.set == 'Voucher'
            and voucher_ready(card) then
            card.ability.porkify_voucher_ready = false
            SMODS.destroy_cards({card})
            refresh_voucher_prices(context.card)
            return
        end
        if context.end_of_round and context.main_eval and not context.game_over
            and G.GAME.blind and G.GAME.blind.boss and not voucher_ready(card) then
            card.ability.porkify_voucher_ready = true
            refresh_voucher_prices()
            return { message = localize('porkify_voucher_ready'), colour = G.C.MONEY }
        end
    end,
    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { ref_table = 'card.joker_display_values', ref_value = 'voucher_status', colour = G.C.MONEY }
            },
            calc_function = function(card)
                card.joker_display_values.voucher_status = localize(
                    voucher_ready(card) and 'porkify_voucher_ready' or 'porkify_voucher_waiting')
            end
        }
    end
}

local set_cost_ref = Card.set_cost
function Card:set_cost()
    set_cost_ref(self)
    if self.ability and self.ability.set == 'Voucher' and has_discount() then
        self.cost = 0
    end
end
