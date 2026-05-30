
SMODS.Shader({ key = 'sepia', path = 'sepia.fs' })

SMODS.Edition {
    key = 'sepia',
    shader = 'sepia',
    config = {
        extra = {
            xchips0 = 2
        }
    },
    in_shop = true,
    weight = 6,
    extra_cost = 2,
    apply_to_float = false,
    sound = { sound = "chips2", per = 1.2, vol = 0.4 },
    disable_shadow = false,
    disable_base_shader = false,
    loc_txt = {
        name = 'Sepia',
        label = 'Sepia',
        text = {
            [1] = '{X:blue,C:white}X2{} Chips'
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
                x_chips = 2
            }
        end
    end
}
