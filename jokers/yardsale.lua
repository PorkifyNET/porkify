local function porkify_yardsale_refresh_prices()
    G.E_MANAGER:add_event(Event({func = function()
        for _, pack in ipairs(G.shop_booster and G.shop_booster.cards or {}) do
            pack:set_cost()
        end
        return true
    end}))
end

SMODS.Joker{ -- Yard Sale
    key = "yardsale",
    config = {
        extra = {
            pending_discount = 0,
            active_discount = 0,
            gain = 1
        }
    },
    loc_txt = {
        ['name'] = 'Yard Sale',
        ['text'] = {
            [1] = '{C:attention}Booster Packs{} are',
            [2] = '{C:money}$#1#{} off next {C:green}shop{}',
            [3] = 'Increases by {C:money}$#2#{} per',
            [4] = '{C:tarot}consumable{} sold'
        },
        ['unlock'] = {
            [1] = 'Sell {C:attention}25{} cards'
        }
    },
    pos = {
        x = 0,
        y = 7
    },
    display_size = {
        w = 71,
        h = 95
    },
    cost = 8,
    rarity = 2,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },
    unlock_condition = { type = 'c_cards_sold', extra = 25 },

    credit_badges = {
        { text = "Art: Souler", colour = "D70159" }
     },

    loc_vars = function(self, info_queue, card)
        local extra = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { extra.pending_discount or 0, extra.gain or 1, extra.active_discount or 0 } }
    end,
    add_to_deck = function() porkify_yardsale_refresh_prices() end,
    remove_from_deck = function() porkify_yardsale_refresh_prices() end,
    calculate = function(self, card, context)
        if context.blueprint or context.retrigger_joker then return end
        local extra = card.ability.extra
        if context.starting_shop then
            extra.active_discount = extra.pending_discount or 0
            extra.pending_discount = 0
            porkify_yardsale_refresh_prices()
            if extra.active_discount > 0 then
                return { message = localize('porkify_discount_ex'), colour = G.C.MONEY }
            end
        elseif context.ending_shop then
            extra.active_discount = 0
            porkify_yardsale_refresh_prices()
        elseif context.selling_card and context.card then
            local sold = context.card
            local center = sold.config and sold.config.center or {}
            if (sold.ability and sold.ability.consumeable) or center.consumeable then
                extra.pending_discount = (extra.pending_discount or 0) + (extra.gain or 1)
                return { message = localize('k_upgrade_ex'), colour = G.C.MONEY }
            end
        end
    end,
    joker_display_def = function(JokerDisplay)
        return {
            text = {{ ref_table = 'card.joker_display_values', ref_value = 'discount_text', colour = G.C.MONEY }},
            reminder_text = {
                { text = '(' },
                { text = 'Booster Packs', colour = G.C.IMPORTANT },
                { text = ')' }
            },
            calc_function = function(card)
                local extra = card.ability.extra
                card.joker_display_values.discount_text = '-$' .. tostring(extra.pending_discount or 0)
            end
        }
    end
}

local set_cost_ref = Card.set_cost
function Card:set_cost()
    set_cost_ref(self)
    if not (self.ability and self.ability.set == 'Booster') then return end
    local discount = 0
    for _, joker in ipairs(SMODS.find_card('j_porkify_yardsale')) do
        if not joker.debuff and not joker.getting_sliced and not joker.destroyed and not joker.removed then
            discount = discount + (joker.ability.extra.active_discount or 0)
        end
    end
    self.cost = math.max(0, self.cost - discount)
end
