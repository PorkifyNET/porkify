-- Use the normal sticker setters, respecting Eternal/Perishable compatibility.
local function register_sticker_boss(key, name, sticker, colour, row, chance)
    SMODS.Blind {
        key = key, atlas = 'CustomBlinds', pos = { x = 0, y = row },
        boss = { min = 2 }, boss_colour = HEX(colour), mult = 2, dollars = 5,
        loc_txt = {
            name = name,
            text = chance and {
                'On play, #1# in #2# chance to add',
                sticker .. ' to a random Joker',
            } or { 'On play, add Rental', 'to a random Joker' },
        },
        loc_vars = function(self)
            if chance then
                local n, d = SMODS.get_probability_vars(G.GAME.blind, 1, 2, 'porkify_' .. key)
                return { vars = { n, d } }
            end
            return { vars = {} }
        end,
        collection_loc_vars = function() return { vars = { 1, 2 } } end,
        press_play = function(self)
            local blind = G.GAME.blind
            if blind.disabled then return end
            local candidates = {}
            local property = string.lower(sticker)
            for _, card in ipairs(G.jokers.cards) do
                local ability, center = card.ability, card.config.center
                local compatible = property == 'rental'
                    or (property == 'perishable' and center.perishable_compat and not ability.eternal)
                    or (property == 'eternal' and center.eternal_compat and not ability.perishable)
                -- Materialized cards keep dissolve = 0, which is truthy in Lua.
                if compatible and not ability[property] and not card.getting_sliced
                    and not card.removed and not card.destroyed and not card.shattered
                    and (card.dissolve == nil or card.dissolve == 0) then
                    candidates[#candidates + 1] = card
                end
            end
            if #candidates == 0 then return end
            if chance and not SMODS.pseudorandom_probability(blind, 'porkify_' .. key, 1, 2, 'porkify_' .. key) then return end
            local target = pseudorandom_element(candidates, pseudoseed('porkify_' .. key .. '_target'))
            target['set_' .. property](target, true)
            target:juice_up()
            blind:wiggle()
        end,
    }
end

register_sticker_boss('landlord', 'The Landlord', 'Rental', 'BAA46A', 19, false)
register_sticker_boss('virus', 'The Virus', 'Perishable', '75AB65', 20, true)
register_sticker_boss('stapler', 'The Stapler', 'Eternal', '8471B5', 21, true)
