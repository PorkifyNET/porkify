SMODS.Seal {
    key = "echo",
    atlas = "CustomSeals",
    pos = { x = 6, y = 0 },
    config = {
        extra = {
            base_odds = 2,
            max_retriggers = 5
        }
    },
    badge_colour = HEX("4F7CAC"),
    discovered = false,
    unlocked = true,
    loc_txt = {
        name = "Echo Seal",
        label = "Echo Seal",
        text = {
            [1] = "{C:green}1 in 2{} chance to retrigger,",
            [2] = "then keep rolling until",
            [3] = "it fails",
            [4] = "{C:inactive}(Up to #1# additional triggers){}"
        }
    },

    loc_vars = function(self, info_queue, card)
        local extra = (card and card.ability and card.ability.seal and card.ability.seal.extra) or self.config.extra
        return { vars = { extra.max_retriggers or 5 } }
    end,

    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            local extra = (card.ability and card.ability.seal and card.ability.seal.extra) or self.config.extra
            local retriggers = 0
            local base_odds = extra.base_odds or 2
            local max_retriggers = extra.max_retriggers or 5

            for i = 1, max_retriggers do
                if not SMODS.pseudorandom_probability(
                    card,
                    "group_echo_seal_" .. tostring(i),
                    1,
                    base_odds,
                    "m_porkify_echo",
                    false
                ) then
                    break
                end

                retriggers = retriggers + 1
            end

            if retriggers > 0 then
                return {
                    repetitions = retriggers,
                    message = "Echo!"
                }
            end
        end
    end
}
