
SMODS.Shader({ key = 'gilded', path = 'gilded.fs' })

local function calculate_gilded_interest()
    if not G.GAME or G.GAME.modifiers.no_interest then
        return 0
    end

    local dollars = G.GAME.dollars or 0
    local interest_amount = G.GAME.interest_amount or 1
    local interest_cap = G.GAME.interest_cap or 25
    local interest = interest_amount * math.min(math.floor(dollars / 5), interest_cap / 5)
    return math.max(math.floor(interest / 2), 0)
end

local function format_gilded_interest(amount)
    if number_format then
        return number_format(amount or 0)
    end
    return tostring(amount or 0)
end

SMODS.Edition {
    key = 'gilded',
    shader = 'gilded',
    config = {
        extra = {
            dollars0 = 1
        }
    },
    in_shop = true,
    weight = 2,
    extra_cost = 5,
    apply_to_float = false,
    sound = { sound = "coin1", per = 1.2, vol = 0.4 },
    disable_shadow = false,
    disable_base_shader = false,
    loc_txt = {
        name = 'Gilded',
        label = 'Gilded',
        text = {
            [1] = 'Immediately pay out half',
            [2] = 'of current {C:money}interest{} when',
            [3] = 'this card is scored',
            [4] = '{C:inactive}(Currently{} {C:money}$#1#{}{C:inactive}){}'
        }
    },
    unlocked = true,
    discovered = false,
    no_collection = false,
    loc_vars = function(self, info_queue, card)
        return {vars = {format_gilded_interest(calculate_gilded_interest())}}
    end,
    get_weight = function(self)
        return G.GAME.edition_rate * self.weight
    end,
    
    calculate = function(self, card, context)
        if context.pre_joker or (context.main_scoring and context.cardarea == G.play) then
            return {
                
                func = function()
                    local interest = calculate_gilded_interest()
                    if to_big(interest) > to_big(0) then
                        ease_dollars(interest)
                        card_eval_status_text(card, 'extra', nil, nil, nil, {message = "$" .. format_gilded_interest(interest), colour = G.C.MONEY})
                    end
                    return true
                end
            }
        end
    end
}
