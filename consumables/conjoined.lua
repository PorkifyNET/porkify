SMODS.Consumable {
    key = 'conjoined',
    set = 'porkify',
    pos = { x = 5, y = 0 },
    loc_txt = {
        name = 'Conjoined',
        text = {
            [1] = 'Permanently add {C:attention}+1{} repetition',
            [2] = 'to {C:attention}1{} selected card,',
            [3] = 'destroy a random {C:attention}Joker{}'
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
        if not (G.hand and to_big(#G.hand.highlighted) == to_big(1)) then return end

        local c = G.hand.highlighted[1]
        if not (c and c.ability) then return end

        local deletable = {}
        for _, j in pairs(G.jokers.cards) do
            if j.ability and j.ability.set == 'Joker' and not SMODS.is_eternal(j, used_card) then
                deletable[#deletable + 1] = j
            end
        end
        if #deletable < 1 then return end
        pseudoshuffle(deletable, pseudoseed('porkify_conjoined_joker'))
        local jdestroy = deletable[1]

		c.ability.perma_repetitions = (c.ability.perma_repetitions or 0) + 1

		card_eval_status_text(
			c, 'extra', nil, nil, nil,
			{ message = "+1 Retrigger", colour = G.C.IMPORTANT }
		)

        -- Visuals / sounds
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                used_card:juice_up(0.3, 0.5)
                return true
            end
        }))

        -- Dissolve the chosen joker
        G.E_MANAGER:add_event(Event({
            trigger = 'before',
            delay = 0.75,
            func = function()
                if jdestroy then jdestroy:start_dissolve(nil, true) end
                return true
            end
        }))

        -- Flip selected playing card
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.9,
            func = function()
                if c then
                    c:flip()
                    play_sound('card1', 1.0)
                    c:juice_up(0.3, 0.3)
                end
                return true
            end
        }))

        -- Flip back + cleanup
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 1.2,
            func = function()
                if c then
                    c:flip()
                    play_sound('tarot2', 1.0, 0.6)
                    c:juice_up(0.3, 0.3)
                end
                if G.hand then G.hand:unhighlight_all() end
                return true
            end
        }))
    end,

    can_use = function(self, card)
        if not (G.hand and to_big(#G.hand.highlighted) == to_big(1)) then
            return false
        end
        if not (G.jokers and G.jokers.cards) then return false end
        for _, j in pairs(G.jokers.cards) do
            if j.ability and j.ability.set == 'Joker' and not SMODS.is_eternal(j, card) then
                return true
            end
        end
        return false
    end
}
