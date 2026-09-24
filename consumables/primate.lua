local function primate_joker_key()
    local flags = G and G.GAME and G.GAME.pool_flags
    return flags and flags.gros_michel_extinct and 'j_cavendish' or 'j_gros_michel'
end

local function primate_has_room()
    return G and G.GAME and G.jokers
        and #G.jokers.cards + (G.GAME.joker_buffer or 0) < G.jokers.config.card_limit
end


SMODS.Consumable {
    key = 'primate',
    set = 'porkify',
    pos = { x = 1, y = 2 },
    loc_txt = {
        name = 'Primate',
        text = {
            [1] = '{C:gold,E:1,s:1.2}Banana{}',
            [2] = '{C:inactive}(Must have room){}'
        }
    },
    cost = 3,
    unlocked = true,
    discovered = false,
    hidden = false,
    can_repeat_soul = false,
    atlas = 'CustomConsumables',

    credit_badges = {
        { text = "Art: Littlesamu", colour = "59A487" }
     },

    loc_vars = function(self, info_queue, card)
        
        local joker = G.P_CENTERS[primate_joker_key()]
        if joker then info_queue[#info_queue + 1] = joker end
        return {vars = {}}
    end,

    use = function(self, card, area, copier)
        if not primate_has_room() then return end
        local used_card = copier or card
        local joker_key = primate_joker_key()
        G.GAME.joker_buffer = (G.GAME.joker_buffer or 0) + 1
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('timpani')
                G.GAME.joker_buffer = math.max(0, (G.GAME.joker_buffer or 0) - 1)
                if #G.jokers.cards < G.jokers.config.card_limit then
                    SMODS.add_card({ set = 'Joker', key = joker_key })
                end
                used_card:juice_up(0.3, 0.5)
                return true
            end
        }))
        delay(0.6)
    end,
    can_use = function(self, card)
        return primate_has_room()
    end
}