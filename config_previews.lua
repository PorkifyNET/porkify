return function()
    local rng = love.math.newRandomGenerator()
    local chosen_key
    return function()
        local candidates = {}
        for key, center in pairs(G.P_CENTERS) do
            -- Avoid initialization hooks that roll gameplay randomness.
            if key:match('^j_porkify_') and not center.set_ability then
                for _, badge in ipairs(center.credit_badges or center.porkify_credit_badges or {}) do
                    local text = type(badge) == 'string' and badge or badge.text or badge.label
                    if type(text) == 'string' and (text:lower():match('^art:') or text:lower():match('^idea:')) then
                        candidates[#candidates + 1] = key
                        break
                    end
                end
            end
        end
        table.sort(candidates)
        if not chosen_key and #candidates > 0 then chosen_key = candidates[rng:random(#candidates)] end
        local function sample(center, front, favorite)
            local width, height = G.CARD_W * 0.85, G.CARD_H * 0.85
            local area = CardArea(0, 0, width + 0.15, height + 0.08,
                { card_limit = 1, type = 'title', highlight_limit = 0, collection = true })
            local card = Card(0, 0, width, height, front, center,
                { bypass_discovery_center = true, bypass_discovery_ui = true })
            card.porkify_config_preview = true
            card.states.drag.can = false
            if favorite then card.ability.porkify_favorite = true end
            area:emplace(card)
            return { n = G.UIT.R, config = { align = 'cm' }, nodes = {
                { n = G.UIT.O, config = { object = area } }
            } }
        end
        local function label(text)
            return { n = G.UIT.R, config = { align = 'cm' }, nodes = {
                { n = G.UIT.T, config = { text = text, scale = 0.24, colour = G.C.UI.TEXT_LIGHT } }
            } }
        end
        local rows = { label('Hover to preview') }
        if chosen_key then
            rows[#rows + 1] = sample(G.P_CENTERS[chosen_key], G.P_CARDS.empty)
            rows[#rows + 1] = label('Art / Idea credits')
        end
        rows[#rows + 1] = sample(G.P_CENTERS.c_base, G.P_CARDS.H_A, true)
        rows[#rows + 1] = label('Favorite indicator')
        return { n = G.UIT.C, config = { align = 'cm', padding = 0.05 }, nodes = rows }
    end
end
