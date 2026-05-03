
SMODS.Enhancement {
    key = 'revolving',
    pos = { x = 2, y = 0 },
    loc_txt = {
        name = 'Revolving',
        text = {
            [1] = 'Randomize {C:attention}rank {}of this',
            [2] = 'card when held at end',
            [3] = 'of round'
        }
    },
    atlas = 'CustomEnhancements',
    any_suit = false,
    replace_base_card = false,
    no_rank = false,
    no_suit = false,
    always_scores = false,
    unlocked = true,
    discovered = false,
    no_collection = false,
    weight = 5
}

local revolving_get_end_of_round_effect_ref = Card.get_end_of_round_effect
function Card:get_end_of_round_effect(context)
    local ret = revolving_get_end_of_round_effect_ref(self, context) or {}

    if self.config and self.config.center and self.config.center.key == "m_porkify_revolving" then
        ret.effect = true
        ret.func = function()
            local rank = pseudorandom_element(SMODS.Ranks, 'edit_card_rank')
            if rank and rank.key then
                assert(SMODS.change_base(self, nil, rank.key))
            end
            return true
        end
        ret.message = "Randomized!"
        ret.card = self
    end

    return ret
end
