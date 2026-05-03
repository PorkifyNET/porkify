
SMODS.Back {
    key = 'braided_deck',
    pos = { x = 3, y = 0 },
    config = {
    },
    loc_txt = {
        name = 'Braided Deck',
        text = {
            [1] = 'Start with {C:attention}2{} copies of',
            [2] = 'a random {C:planet}Planet{} card'
        },
    },
    unlocked = true,
    discovered = true,
    no_collection = false,
    atlas = 'CustomDecks',
    apply = function(self, back)
        local first_planet_key = nil

        G.E_MANAGER:add_event(Event({
            func = function()
                play_sound('timpani')
                local created = SMODS.add_card({ set = 'Planet' })
                if created and created.config and created.config.center then
                    first_planet_key = created.config.center.key
                end
                return true
            end
        }))

        G.E_MANAGER:add_event(Event({
            func = function()
                play_sound('timpani')
                if first_planet_key then
                    SMODS.add_card({ set = 'Planet', key = first_planet_key })
                end
                return true
            end
        }))
    end
}
