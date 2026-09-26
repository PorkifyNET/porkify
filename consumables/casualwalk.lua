SMODS.Consumable {
    key = 'casualwalk',
    set = 'porkify',
    pos = { x = 3, y = 0 },
    loc_txt = {
        name = 'Casual Walk',
        text = {
            [1] = 'Permanently add a random',
            [2] = 'bonus to {C:attention}1{} selected card'
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
        if not (G.hand and #G.hand.cards > 0 and to_big(#G.hand.highlighted) == to_big(1)) then
            return
        end

        local target = G.hand.highlighted[1]
        if not (target and target.ability) then
            return
        end

        local buffs = {
            {
                apply = function(c)
                    c.ability.perma_bonus = (c.ability.perma_bonus or 0) + 30
                end,
                message = "+30 Chips",
                colour = G.C.CHIPS
            },
            {
                apply = function(c)
                    c.ability.perma_h_bonus = (c.ability.perma_h_bonus or 0) + 15
                end,
                message = "+15 Chips when Held",
                colour = G.C.CHIPS
            },
            {
                apply = function(c)
                    c.ability.perma_mult = (c.ability.perma_mult or 0) + 4
                end,
                message = "+4 Mult",
                colour = G.C.MULT
            },
            {
                apply = function(c)
                    c.ability.perma_h_mult = (c.ability.perma_h_mult or 0) + 2
                end,
                message = "+2 Mult when Held",
                colour = G.C.MULT
            },
            {
                apply = function(c)
                    c.ability.perma_x_mult = (c.ability.perma_x_mult or 0) + 0.5
                end,
                message = "X1.5 Mult",
                colour = G.C.MULT
            },
            {
                apply = function(c)
                    c.ability.perma_h_x_mult = (c.ability.perma_h_x_mult or 0) + 0.25
                end,
                message = "X1.25 Mult Held",
                colour = G.C.MULT
            },
            {
                apply = function(c)
                    c.ability.perma_bonus = (c.ability.perma_bonus or 0) + 50
                end,
                message = "+50 Chips",
                colour = G.C.CHIPS
            },
            {
                apply = function(c)
                    c.ability.perma_h_dollars = (c.ability.perma_h_dollars or 0) + 3
                end,
                message = "$3 Held",
                colour = G.C.MONEY
            },
            {
                apply = function(c)
                    c.ability.perma_p_dollars = (c.ability.perma_p_dollars or 0) + 3
                end,
                message = "+$3",
                colour = G.C.MONEY
            },
            {
                apply = function(c)
                    c.ability.perma_x_chips = (c.ability.perma_x_chips or 0) + 0.5
                end,
                message = "X1.5 Chips",
                colour = G.C.CHIPS
            },
            {
                apply = function(c)
                    c.ability.perma_h_x_chips = (c.ability.perma_h_x_chips or 0) + 0.25
                end,
                message = "X1.25 Chips when Held",
                colour = G.C.CHIPS
            },
            {
                apply = function(c)
                    c.ability.perma_score = (c.ability.perma_score or 1) + 1500
                end,
                message = "+1500 Score",
                colour = G.C.PURPLE
            },
            {
                apply = function(c)
                    c.ability.perma_x_score = (c.ability.perma_x_score or 1) + 0.1
                end,
                message = "+10% Score",
                colour = G.C.PURPLE
            },
            {
                apply = function(c)
                    c.ability.perma_h_score = (c.ability.perma_h_score or 0) + 1000
                end,
                message = "+1000 Score when Held",
                colour = G.C.PURPLE
            },
            {
                apply = function(c)
                    c.ability.perma_h_x_score = (c.ability.perma_h_x_score or 0) + 0.05
                end,
                message = "+5% Score when Held",
                colour = G.C.PURPLE
            },
            {
                apply = function(c)
                    c.ability.perma_blind_size = (c.ability.perma_blind_size or 1) - 750
                end,
                message = "-750 Blind Size",
                colour = G.C.DYN_UI.DARK,
                multiplayer_unsafe = true
            },
            {
                apply = function(c)
                    c.ability.perma_x_blind_size = (c.ability.perma_x_blind_size or 1) - 0.05
                end,
                message = "-5% Blind Size",
                colour = G.C.DYN_UI.DARK,
                multiplayer_unsafe = true
            },
            {
                apply = function(c)
                    c.ability.perma_h_blind_size = (c.ability.perma_h_blind_size or 1) - 500
                end,
                message = "-500 Blind Size when Held",
                colour = G.C.DYN_UI.DARK,
                multiplayer_unsafe = true
            },
            {
                apply = function(c)
                    c.ability.perma_h_x_blind_size = (c.ability.perma_h_x_blind_size or 1) - 0.02
                end,
                message = "-2% Blind Size when Held",
                colour = G.C.DYN_UI.DARK,
                multiplayer_unsafe = true
            },
            {
                apply = function(c)
                    c.ability.perma_repetitions = (c.ability.perma_repetitions or 0) + 1
                end,
                message = "+1 Retrigger",
                colour = G.C.IMPORTANT
            }
        }

        -- A Nemesis Blind uses the opponent's live score as its target. Card
        -- bonuses that mutate G.GAME.blind.chips corrupt that moving target,
        -- so keep Casual Walk's ordinary score/economy bonuses in MP matches.
        local in_multiplayer_match = false
        if type(MP) == "table" then
            if type(MP.is_mp_or_ghost) == "function" then
                in_multiplayer_match = not not MP.is_mp_or_ghost()
            else
                in_multiplayer_match = type(MP.LOBBY) == "table" and MP.LOBBY.code ~= nil
            end
        end
        if in_multiplayer_match then
            local safe_buffs = {}
            for _, buff in ipairs(buffs) do
                if not buff.multiplayer_unsafe then
                    safe_buffs[#safe_buffs + 1] = buff
                end
            end
            buffs = safe_buffs
        end

        local chosen_buff = pseudorandom_element(buffs, pseudoseed('porkify_casualwalk'))

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                used_card:juice_up(0.3, 0.5)
                return true
            end
        }))

        for i = 1, #G.hand.highlighted do
            local percent = 1.15 - (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('card1', percent)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end

        delay(0.2)

        for i = 1, #G.hand.highlighted do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    chosen_buff.apply(G.hand.highlighted[i])
                    card_eval_status_text(
                        G.hand.highlighted[i],
                        'extra', nil, nil, nil,
                        { message = chosen_buff.message, colour = chosen_buff.colour }
                    )
                    return true
                end
            }))
        end

        for i = 1, #G.hand.highlighted do
            local percent = 0.85 + (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('tarot2', percent, 0.6)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all()
                return true
            end
        }))

        delay(0.5)
    end,

    can_use = function(self, card)
        return (G.hand and #G.hand.cards > 0 and to_big(#G.hand.highlighted) == to_big(1))
    end
}
