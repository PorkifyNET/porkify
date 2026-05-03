local function get_crest_suit(self)
    if G and G.GAME then
        G.GAME.current_round = G.GAME.current_round or {}
        if G.GAME.current_round.porkify_crest_suit then
            self.required_suit = G.GAME.current_round.porkify_crest_suit
            return self.required_suit
        end
    end

    if self.required_suit then
        return self.required_suit
    end

    local suit_pool = {
        "Spades",
        "Hearts",
        "Clubs",
        "Diamonds"
    }
    self.required_suit = pseudorandom_element(suit_pool, "porkify_crest_suit") or "Spades"

    if self.config and self.config.extra then
        self.config.extra.suit = self.required_suit
    end

    if G and G.GAME then
        G.GAME.current_round = G.GAME.current_round or {}
        G.GAME.current_round.porkify_crest_suit = self.required_suit
    end

    return self.required_suit
end

SMODS.Blind{
    key = "crest",
    atlas = "CustomBlinds",
    pos = { x = 0, y = 2 },
    boss = { min = 2 },
    boss_colour = HEX("AA00AA"),
    mult = 2,
    dollars = 5,
    config = {
        extra = {
            suit = "Spades"
        }
    },
    loc_txt = {
        name = "The Crest",
        text = {
            [1] = "Hand must contain",
            [2] = "a #1# card"
        }
    },

    loc_vars = function(self)
        local suit = get_crest_suit(self)
        return {
            vars = { string.lower(localize(suit, 'suits_singular')) }
        }
    end,

    set_blind = function(self, reset, silent)
        if reset then
            return
        end
        get_crest_suit(self)
    end,

    disable = function(self, silent)
        if G and G.GAME then
            G.GAME.current_round = G.GAME.current_round or {}
            G.GAME.current_round.porkify_crest_suit = nil
        end
        self.required_suit = nil
    end,

    debuff_hand = function(self, cards, hand, handname, check)
        local suit = get_crest_suit(self)

        local sources = {
            cards,
            hand,
            G and G.hand and G.hand.highlighted
        }

        for _, source in ipairs(sources) do
            if type(source) == "table" then
                for _, card in pairs(source) do
                    if card and card.is_suit and card:is_suit(suit) then
                        return false
                    end
                end
            end
        end

        return true
    end,

    in_pool = function(self)
        local ante = (G and G.GAME and G.GAME.round_resets and G.GAME.round_resets.ante) or 1
        return ante >= ((self.boss and self.boss.min) or 1)
    end
}
