
SMODS.Joker{ --Cardception
    key = "cardception",
    config = {
        extra = {
        }
    },
    loc_txt = {
        ['name'] = 'Cardception',
        ['text'] = {
            [1] = 'All {C:attention}playing cards{} and',
            [2] = '{C:attention}Standard Packs{} in the',
            [3] = 'Shop are {C:green}free{}'
        },
        ['unlock'] = {
            [1] = 'Buy {C:attention}10{} playing cards'
        }
    },
    pos = {
        x = 4,
        y = 0
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 5,
    rarity = 2,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["porkify_porkify_jokers"] = true },
    unlock_condition = { type = 'c_playing_cards_bought', extra = 10 },
    
    calculate = function(self, card, context)
    end,
    
    add_to_deck = function(self, card, from_debuff)
        G.E_MANAGER:add_event(Event({
            func = function()
                for k, v in pairs(G.I.CARD) do
                if v.set_cost then v:set_cost() end
                end
                return true
            end
        }))
    end,
    
    remove_from_deck = function(self, card, from_debuff)
        G.E_MANAGER:add_event(Event({
            func = function()
                for k, v in pairs(G.I.CARD) do
                if v.set_cost then v:set_cost() end
                end
                return true
            end
        }))
    end
}


local card_set_cost_ref = Card.set_cost
function Card:set_cost()
    card_set_cost_ref(self)

    if self.ability and self.ability.porkify_tag_free then
        self.cost = 0
    end
    
    if next(SMODS.find_card("j_porkify_cardception")) then
        if (self.ability.set == 'Enhanced' or (self.ability.set == 'Booster' and self.config.center.kind == 'Standard')) then
            self.cost = 0
        end
    end
    
    self.sell_cost = math.max(1, math.floor(self.cost / 2)) + (self.ability.extra_value or 0)
    self.sell_cost_label = self.facing == 'back' and '?' or self.sell_cost
end
