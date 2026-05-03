
SMODS.Shader({ key = 'ionized', path = 'ionized.fs' })

SMODS.Edition {
    key = 'ionized',
    shader = 'ionized',
    config = {
        extra = {
            base_xmult = 5,
            ante_penalty = 0.5
        }
    },
    in_shop = true,
    weight = 6,
    extra_cost = 2,
    apply_to_float = false,
    sound = { sound = "negative", per = 1.2, vol = 0.4 },
    disable_shadow = false,
    disable_base_shader = false,
    loc_txt = {
        name = 'Ionized',
        label = 'Ionized',
        text = {
            [1] = '{X:red,C:white}X5{} Mult, loses {X:red,C:white}X0.5{} Mult',
            [2] = 'per played {C:attention}Ante{}',
            [3] = '{C:inactive}(Currently{} {X:red,C:white}X#1#{} {C:inactive}Mult){}'
        }
    },
    unlocked = true,
    discovered = false,
    no_collection = false,
    loc_vars = function(self, info_queue, card)
        local edition = (card and card.edition) or {}
        local cfg = self.config and self.config.extra or {}
        local base = edition.base_xmult or cfg.base_xmult or 5
        local penalty = edition.ante_penalty or cfg.ante_penalty or 0.5
        local ante = math.max(0, (G.GAME.round_resets.ante or 1) - 1)
        return {vars = {base - (ante * penalty)}}
    end,
    get_weight = function(self)
        return G.GAME.edition_rate * self.weight
    end,
    
    calculate = function(self, card, context)
        if context.pre_joker or (context.main_scoring and context.cardarea == G.play) then
            local edition = (card and card.edition) or {}
            local cfg = self.config and self.config.extra or {}
            local base = edition.base_xmult or cfg.base_xmult or 5
            local penalty = edition.ante_penalty or cfg.ante_penalty or 0.5
            local ante = math.max(0, (G.GAME.round_resets.ante or 1) - 1)
            return {
                x_mult = math.max(1, base - (ante * penalty))
            }
        end
    end
}
