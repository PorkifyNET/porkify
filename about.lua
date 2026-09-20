-- Steamodded calls this when the Porkify About tab is opened.
return function(mod)
    -- Keep cosmetic randomness separate from the run's random state.
    local message_rng = love.math.newRandomGenerator()
    local closing_messages = {
        'porkify_about_bye_kitty',
        'porkify_about_bye_paul',
        'porkify_about_bye_blanks',
        'porkify_about_bye_cube',
        'porkify_about_bye_hands',
        'porkify_about_bye_porky',
        'porkify_about_bye_time',
        'porkify_about_bye_trans',
        'porkify_about_bye_drink',
        'porkify_about_bye_payment',
        'porkify_about_bye_grass',
        'porkify_about_bye_mcdonalds',
        'porkify_about_bye_monster',
        'porkify_about_bye_art_issue',
        'porkify_about_bye_job',
    }
    local pink = HEX('ff0095')
    local panel_colour = HEX('24202e')
    local backdrop = HEX('140e1c')
    backdrop[4] = 0.8
    mod.ui_config = mod.ui_config or {}
    local theme = {
        colour = HEX('191420'),
        bg_colour = backdrop,
        outline_colour = pink,
        back_colour = HEX('b00067'),
        tab_button_colour = HEX('8f205f'),
        author_colour = HEX('ff8fce'),
        author_bg_colour = panel_colour,
        author_outline_colour = pink,
        collection_colour = HEX('191420'),
        collection_bg_colour = backdrop,
        collection_back_colour = HEX('b00067'),
        collection_option_cycle_colour = HEX('8f205f'),
    }
    local previous = {}
    for key in pairs(theme) do previous[key] = mod.ui_config[key] end
    mod.apply_porkify_theme = function()
        for key, colour in pairs(theme) do
            if not mod.config or mod.config.porkify_theme ~= false then
                mod.ui_config[key] = colour
            else
                mod.ui_config[key] = previous[key]
            end
        end
    end
    mod.apply_porkify_theme()

    mod.custom_ui = function(nodes)
        -- Replace Steamodded's generic author/description rows.
        for i = #nodes, 1, -1 do nodes[i] = nil end
        local function text_row(text, scale, colour)
            return {
                n = G.UIT.R, config = { align = 'cm', padding = 0.035 },
                nodes = {{ n = G.UIT.T, config = {
                    text = text, scale = scale or 0.32,
                    colour = colour or G.C.WHITE, shadow = true
                } }}
            }
        end
        local function panel(title, lines)
            local rows = { text_row(title, 0.36, pink) }
            for _, line in ipairs(lines) do rows[#rows + 1] = text_row(line) end
            return {
                n = G.UIT.R,
                config = { align = 'cm', padding = 0.12, r = 0.12,
                    minw = 6, colour = panel_colour },
                nodes = {{ n = G.UIT.C, config = { align = 'cm' }, nodes = rows }}
            }
        end
        local function gap()
            return { n = G.UIT.R, config = { minh = 0.12 }, nodes = {} }
        end
        nodes[#nodes + 1] = {
            n = G.UIT.R, config = { align = 'cm', padding = 0.12 },
            nodes = {
                { n = G.UIT.O, config = {
                    object = SMODS.create_sprite(0, 0, 0.75, 0.75, 'porkify_modicon', { x = 0, y = 0 })
                } },
                { n = G.UIT.C, config = { align = 'cm', padding = 0.12 }, nodes = {
                    text_row(mod.name or 'Porkify', 0.65, pink),
                    text_row('v' .. tostring(mod.version or '') .. '  |  By ' .. table.concat(mod.author or {}, ', '),
                        0.28, G.C.UI.TEXT_LIGHT)
                } }
            }
        }
        nodes[#nodes + 1] = text_row(localize('porkify_about_tagline'), 0.34)
        nodes[#nodes + 1] = gap()
        nodes[#nodes + 1] = panel(localize('porkify_about_welcome'), {
            localize('porkify_about_intro_1'), localize('porkify_about_intro_2')
        })
        nodes[#nodes + 1] = gap()
        nodes[#nodes + 1] = panel(localize('porkify_about_features'), {
            localize('porkify_about_features_1'), localize('porkify_about_features_2'),
            localize('porkify_about_features_3')
        })
        nodes[#nodes + 1] = gap()
        nodes[#nodes + 1] = panel(localize('porkify_about_credits'), {
            localize('porkify_about_credits_1'), localize('porkify_about_credits_2'),
            localize('porkify_about_credits_3')
        })
        nodes[#nodes + 1] = gap()
        local message = closing_messages[message_rng:random(#closing_messages)]
        nodes[#nodes + 1] = text_row(localize('porkify_about_thanks') .. ' ' .. localize(message),
            0.28, G.C.UI.TEXT_LIGHT)
    end
end
