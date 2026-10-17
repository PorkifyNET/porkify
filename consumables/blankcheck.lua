if Card and Card.flip and not Porkify_blank_joker_flip_ref then
    Porkify_blank_joker_flip_ref = Card.flip
    function Card:flip(...)
        if self.ability and self.ability.porkify_blank_flipped and self.facing == 'back' then
            return
        end
        return Porkify_blank_joker_flip_ref(self, ...)
    end
end

local function shuffle_jokers(seed)
    local original_order = {}
    for i, joker in ipairs(G.jokers.cards) do
        original_order[i] = joker
    end

    G.jokers:shuffle(seed)

    if #G.jokers.cards > 1 then
        local unchanged = true
        for i, joker in ipairs(G.jokers.cards) do
            if joker ~= original_order[i] then
                unchanged = false
                break
            end
        end
        if unchanged then
            table.insert(G.jokers.cards, 1, table.remove(G.jokers.cards))
            if G.jokers.set_ranks then G.jokers:set_ranks() end
        end
    end
end

SMODS.Consumable {
    key = 'blankcheck',
    set = 'porkify',
    pos = { x = 8, y = 4 },
    loc_txt = {
        name = 'Blank',
        text = {
            [1] = 'Add a {C:attention}Blank Seal{} to',
            [2] = '{C:attention}1{} selected card,',
            [3] = 'shuffle and permanently',
            [4] = 'flip a random {C:attention}Joker{}'
        }
    },
    config = { min_highlighted = 1, max_highlighted = 1 },
    cost = 3,
    unlocked = true,
    discovered = false,
    hidden = false,
    can_repeat_soul = false,
    atlas = 'CustomConsumables',

    loc_vars = function(self, info_queue, card)
        local info_queue_0 = G.P_SEALS and (G.P_SEALS["porkify_blank"] or G.P_SEALS["blank"])
        if info_queue_0 then
            info_queue[#info_queue + 1] = info_queue_0
        end
        return { vars = {} }
    end,

    use = function(self, card, area, copier)
        local used_card = copier or card
        if not (G.hand and #G.hand.cards > 0 and to_big(#G.hand.highlighted) == to_big(1)) then return end
        if not (G.jokers and G.jokers.cards and #G.jokers.cards > 0) then return end

        local target = G.hand.highlighted[1]
        local target_joker = pseudorandom_element(
            G.jokers.cards,
            pseudoseed('porkify_blank_joker')
        )

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
            delay = 0.15,
            func = function()
                target:flip()
                play_sound('card1', 1.0)
                target:juice_up(0.3, 0.3)
                return true
            end
        }))

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.35,
            func = function()
                target:set_seal("porkify_blank", nil, true)
                return true
            end
        }))

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.55,
            func = function()
                if target_joker then
                    target_joker.ability = target_joker.ability or {}
                    target_joker.ability.porkify_blank_flipped = true
                end
                if target_joker and target_joker.facing ~= 'back' then
                    target_joker:flip()
                end
                return true
            end
        }))

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.7,
            func = function()
                shuffle_jokers('porkify_blank_jokers')
                play_sound('cardSlide1', 1)
                return true
            end
        }))

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.85,
            func = function()
                target:flip()
                play_sound('tarot2', 1.0, 0.6)
                target:juice_up(0.3, 0.3)
                G.hand:unhighlight_all()
                return true
            end
        }))
    end,

    can_use = function(self, card)
        return (G.hand and #G.hand.cards > 0
            and to_big(#G.hand.highlighted) == to_big(1)
            and G.jokers and G.jokers.cards and #G.jokers.cards > 0) == true
    end
}
