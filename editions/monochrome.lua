
SMODS.Shader({ key = 'monochrome', path = 'monochrome.fs' })

SMODS.Edition {
    key = 'monochrome',
    shader = 'monochrome',
    in_shop = true,
    weight = 4,
    extra_cost = 1,
    apply_to_float = false,
    sound = { sound = "cardFan2", per = 1.2, vol = 0.4 },
    disable_shadow = false,
    disable_base_shader = false,
    loc_txt = {
        name = 'Monochrome',
        label = 'Monochrome',
        text = {
            [1] = 'Swap {C:blue}Chips {}and {C:red}Mult{}',
            [2] = 'around when this card',
            [3] = 'is scored'
        }
    },
    unlocked = true,
    discovered = false,
    no_collection = false,
    get_weight = function(self)
        return G.GAME.edition_rate * self.weight
    end,
    
    calculate = function(self, card, context)
        if context.pre_joker or (context.main_scoring and context.cardarea == G.play) then
            return {
                swap = true,
                message = 'Swap!',
                colour = G.C.PURPLE
            }
        end
    end
}
