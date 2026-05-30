
SMODS.Shader({ key = 'laminated', path = 'laminated.fs' })

SMODS.Edition {
    key = 'laminated',
    shader = 'laminated',
    config = {
        extra = {
            consumablesheld = 1
        }
    },
    in_shop = true,
    weight = 3,
    extra_cost = 3,
    apply_to_float = false,
    sound = { sound = "foil2", per = 1.2, vol = 0.4 },
    disable_shadow = false,
    disable_base_shader = false,
    loc_txt = {
        name = 'Laminated',
        label = 'Laminated',
        text = {
            [1] = '{X:red,C:white}X0.5{} Mult per',
            [2] = '{C:tarot}Consumable{} held',
            [3] = '{C:inactive}(Currently{} {X:red,C:white}X#1#{} {C:inactive}Mult){}'
        }
    },
    unlocked = true,
    discovered = false,
    no_collection = false,
    loc_vars = function(self, info_queue, card)
        local edition = (card and card.edition) or {}
        local base = edition.consumablesheld or (self.config.extra and self.config.extra.consumablesheld) or 1
        return {vars = {base + (#(G.consumeables and G.consumeables.cards or {}) * 0.5)}}
    end,
    get_weight = function(self)
        return G.GAME.edition_rate * self.weight
    end,
    
    calculate = function(self, card, context)
        if context.pre_joker or (context.main_scoring and context.cardarea == G.play) then
            local edition = (card and card.edition) or {}
            local base = edition.consumablesheld or (self.config.extra and self.config.extra.consumablesheld) or 1
            return {
                Xmult = base + (#(G.consumeables and G.consumeables.cards or {}) * 0.5)
            }
        end
    end
}
