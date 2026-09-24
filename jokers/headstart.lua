SMODS.Joker{ --Headstart
    key = "headstart",
    config = {
        extra = {
            score_percent = 0.1
        }
    },
    loc_txt = {
        ['name'] = 'Headstart',
        ['text'] = {
            [1] = 'Start {C:attention}Boss Blind{} with',
            [2] = '{C:attention}#1#%{} of {B:blind,C:white}Blind Size{}',
            [3] = 'already scored'
        }
    },
    pos = {
        x = 2,
        y = 7
    },
    display_size = {
        w = 71,
        h = 95
    },
    cost = 5,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'CustomJokers',
    pools = { ["porkify_porkify_jokers"] = true },

    loc_vars = function(self, info_queue, card)
        local chips = (card and card.ability and card.ability.extra and (card.ability.extra.score_percent * 100)) or 10
        return { vars = { chips } }
    end,

    calculate = function(self, card, context)
        if context.setting_blind
            and not card.ability.extra.triggered
            and G
            and G.GAME
            and G.GAME.blind
            and G.GAME.blind.boss
        then
            local score_percent = card.ability.extra.score_percent or 0.1
            local headstart_score = to_number(
                G.GAME.blind.chips * score_percent
            )

            return {
                score = headstart_score
            }
        end
    end
}
