SMODS.Consumable {
    key = 'timemachine',
    set = 'porkify',
    pos = { x = 2, y = 3 },
    loc_txt = {
        name = 'Time Machine',
        text = {
            [1] = '{C:red}-1{} Ante and {C:red}destroy{}',
            [2] = 'a random {C:attention}Joker{}'
        }
    },
    cost = 3,
    unlocked = true,
    discovered = false,
    hidden = false,
    can_repeat_soul = false,
    atlas = 'CustomConsumables',

    use = function(self, card, area, copier)
        local used_card = copier or card
        if not (G.jokers and G.jokers.cards and #G.jokers.cards > 0) then return end
        if not (G.GAME and G.GAME.round_resets and (G.GAME.round_resets.ante or 1) > 1) then return end

        local deletable = {}
        for _, j in ipairs(G.jokers.cards) do
            if j.ability and j.ability.set == 'Joker' and not SMODS.is_eternal(j, used_card) then
                deletable[#deletable + 1] = j
            end
        end
        if #deletable == 0 then return end

        pseudoshuffle(deletable, pseudoseed('porkify_timemachine'))
        local jdestroy = deletable[1]

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                used_card:juice_up(0.3, 0.5)
                return true
            end
        }))

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.45,
            func = function()
                local mod = -1
                ease_ante(mod)
                if G.GAME.round_resets.blind_ante then
                    G.GAME.round_resets.blind_ante = math.max(G.GAME.round_resets.blind_ante + mod, 1)
                end

                card_eval_status_text(
                    used_card, 'extra', nil, nil, nil,
                    { message = "-1 Ante", colour = G.C.YELLOW }
                )
                return true
            end
        }))

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.75,
            func = function()
                if jdestroy then
                    jdestroy:start_dissolve(nil, true)
                end
                return true
            end
        }))
    end,

    can_use = function(self, card)
        -- if not (G.GAME and G.GAME.round_resets and (G.GAME.round_resets.ante or 1) > 1) then
        --     return false
        -- end
        if not (G.jokers and G.jokers.cards and #G.jokers.cards > 0) then
            return false
        end
        for _, j in ipairs(G.jokers.cards) do
            if j.ability and j.ability.set == 'Joker' and not SMODS.is_eternal(j, card) then
                return true
            end
        end
        return false
    end
}
