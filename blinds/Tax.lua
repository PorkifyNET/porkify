SMODS.Blind{
    key = "tax",
    atlas = "CustomBlinds",
    pos = { x = 0, y = 10 },
    boss = { min = 3 },
    boss_colour = HEX("FFFF00"),
    mult = 2,
    dollars = 5,
    loc_txt = {
        name = "The Tax",
        text = {
            [1] = "Cards drawn face down",
            [2] = "while you have $#1# or more"
        }
    },

    loc_vars = function(self)
        return { vars = { G.GAME.interest_cap or 25 } }
    end,
    collection_loc_vars = function(self)
        return { vars = { 25 } }
    end,
    stay_flipped = function(self, area, card)
        return not G.GAME.blind.disabled and area == G.hand
            and to_big(G.GAME.dollars) >= to_big(G.GAME.interest_cap or 25)
    end,
    disable = function(self)
        for _, card in ipairs(G.hand.cards or {}) do
            if card.facing == 'back' then card:flip() end
        end
    end,

    in_pool = function(self)
        local ante = (G and G.GAME and G.GAME.round_resets and G.GAME.round_resets.ante) or 1
        return ante >= ((self.boss and self.boss.min) or 1)
    end
}
