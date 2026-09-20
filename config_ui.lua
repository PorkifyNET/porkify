return function(mod, save, defaults)
    local outline_modes = { 'none', 'default', 'rainbow', 'protanopia', 'tritanopia', 'deuteranopia' }
    G.FUNCS.porkify_favorite_outline = function(args)
        local mode = outline_modes[args.cycle_config.current_option]
        if mode then mod.config.favorite_outline = mode; save() end
    end
    local build_previews = assert(SMODS.load_file('config_previews.lua'))()()
    local startup = {}
    for key, value in pairs(mod.config) do
        if key == 'return_of_the_serpent' or key:match('^content_') then startup[key] = value end
    end
    local function restart_pending()
        for key, value in pairs(startup) do
            if mod.config[key] ~= value then return true end
        end
        return false
    end
    local function restart_reasons()
        local settings = {
            { 'return_of_the_serpent', 'Return of the Serpent' },
            { 'content_jokers', 'Jokers' },
            { 'content_consumables', 'Consumables' },
            { 'content_vouchers', 'Vouchers' },
            { 'content_boosters', 'Booster packs' },
            { 'content_tags', 'Tags' },
            { 'content_blinds', 'Boss Blinds' },
            { 'content_secret_hands', 'Secret poker hands' },
            { 'content_achievements', 'Achievements' },
        }
        local lines = { 'These changes apply after restarting:' }
        for _, setting in ipairs(settings) do
            local key, label = setting[1], setting[2]
            if startup[key] ~= nil and mod.config[key] ~= startup[key] then
                lines[#lines + 1] = label .. ': ' .. (startup[key] and 'On' or 'Off')
                    .. ' -> ' .. (mod.config[key] and 'On' or 'Off')
            end
        end
        return lines
    end
    local selected_tab = 'General'
    G.FUNCS.porkify_restart_now = function()
        if not restart_pending() then return end
        save()
        SMODS.restart_game()
    end
    local function refresh()
        SMODS.LAST_SELECTED_MOD_TAB = 'config'
        G.FUNCS['openModUI_' .. mod.id]()
    end
    G.FUNCS.porkify_reset_config = function()
        for key, value in pairs(defaults()) do mod.config[key] = value end
        save()
        refresh()
    end
    mod.config_tab = function()
        local function heading(label)
            return { n = G.UIT.R, config = { align = 'cm', padding = 0.08 }, nodes = {
                { n = G.UIT.T, config = { text = label, scale = 0.36, colour = HEX('ff8fce') } }
            } }
        end
        local function toggle(label, key, info, reopen)
            return { n = G.UIT.R, config = { align = 'cm', padding = 0.04 }, nodes = {
                create_toggle { label = label, ref_table = mod.config, ref_value = key,
                    scale = 0.7, label_scale = 0.34, info = info, active_colour = HEX('ff0095'),
                    callback = function()
                        save()
                        if reopen or startup[key] ~= nil then refresh() end
                    end }
            } }
        end
        local function general()
        local outline_index = 1
        for i, mode in ipairs(outline_modes) do
            if mod.config.favorite_outline == mode then outline_index = i end
        end
        local settings = {
            heading('Appearance'),
            toggle('Porkify menu theme', 'porkify_theme', { 'Turn off to use standard menu colours.' }, true),
            toggle('Show credit badges', 'show_credit_badges', { 'Show art and idea credits. Food badges stay visible.' }),
            heading('Convenience'),
            toggle('Reveal secret hand descriptions', 'reveal_secret_hands', {
                'Show undiscovered Porkify hands in Run Info.', 'Does not unlock hands or change gameplay.' }),
            { n = G.UIT.R, config = { align = 'cm' }, nodes = {
                create_option_cycle { label = 'Favorite outline',
                    options = { 'None', 'Default', 'Rainbow', 'Protanopia', 'Tritanopia', 'Deuteranopia' },
                    current_option = outline_index, opt_callback = 'porkify_favorite_outline',
                    w = 4.5, h = 0.4, text_scale = 0.3, colour = HEX('8f205f') }
            } },
        }
        return { n = G.UIT.ROOT, config = { align = 'cm', padding = 0.06, colour = G.C.CLEAR }, nodes = {
            { n = G.UIT.C, config = { align = 'cm' }, nodes = settings },
            build_previews()
        } }
        end
        local function experimental()
            return { n = G.UIT.ROOT, config = { align = 'tm', padding = 0.06, colour = G.C.CLEAR }, nodes = {
                { n = G.UIT.R, config = { align = 'cm', padding = 0.1 }, nodes = {
                    { n = G.UIT.T, config = { text = 'May cause slowdowns or crashes.',
                        scale = 0.3, colour = G.C.RED } }
                } },
                toggle('Return of the Serpent', 'return_of_the_serpent', {
                    'Restore The Serpent Boss Blind.', 'Restart the game after changing this setting.' }),
                toggle('Unlimited Blanks', 'unlimited_blanks', {
                    'Allow more than 2 Blank Seals in a played hand.', 'Applies immediately; more Blanks can be very slow.' }),
                toggle('Infinipaul', 'infinipaul', {
                    'Let Paul create Eggs and Hatched Eggs with no room.',
                    'Applies immediately. Paul still occupies a Joker slot.' }),
                toggle('Bypass "Unlock All" Achievement Restrictions', 'bypass_unlock_all', {
                    'Allow Porkify achievements on Unlock All profiles.',
                    'Other achievements and unlock conditions are unchanged.' }),
            } }
        end
        local function content()
            local left, right = {}, {}
            local options = {
                { 'Jokers', 'jokers' }, { 'Consumables', 'consumables' },
                { 'Vouchers', 'vouchers' }, { 'Booster packs', 'boosters' },
                { 'Tags', 'tags' }, { 'Boss Blinds', 'blinds' },
                { 'Secret poker hands', 'secret_hands' }, { 'Achievements', 'achievements' }
            }
            for i, option in ipairs(options) do
                local column = i <= 4 and left or right
                column[#column + 1] = toggle(option[1], 'content_' .. option[2])
            end
            local function note(text)
                return { n = G.UIT.R, config = { align = 'cm', padding = 0.04 }, nodes = {
                    { n = G.UIT.T, config = { text = text, scale = 0.28, colour = G.C.UI.TEXT_LIGHT } }
                } }
            end
            return { n = G.UIT.ROOT, config = { align = 'tm', padding = 0.06, colour = G.C.CLEAR }, nodes = {
                heading('Enabled Porkify content'),
                note('Restart the game after changing these settings.'),
                { n = G.UIT.R, config = { align = 'cm', padding = 0.15 }, nodes = {
                    { n = G.UIT.C, config = { align = 'cm' }, nodes = left },
                    { n = G.UIT.C, config = { align = 'cm' }, nodes = right }
                } },
                note('Items and Boss Blinds: removed from random pools.'),
                note('Existing items and explicit card effects remain available.'),
                note('Secret hands: stop scoring. Achievements: stop unlocking.'),
            } }
        end
        local function tab(label, build)
            return { label = label, chosen = selected_tab == label,
                tab_definition_function = function()
                    selected_tab = label
                    return build()
                end }
        end
        local nodes = {
            create_tabs { snap_to_nav = true, colour = HEX('8f205f'), tabs = {
                tab('General', general), tab('Content', content), tab('Experimental', experimental)
            } }
        }
        local footer = {
            { n = G.UIT.C, config = { align = 'cm' }, nodes = {
                UIBox_button { label = { 'Reset to defaults' }, button = 'porkify_reset_config',
                    minw = 2.4, minh = 0.45, scale = 0.3, colour = HEX('8f205f') }
            } }
        }
        if restart_pending() then
            footer[#footer + 1] = { n = G.UIT.C, config = { align = 'cm', padding = 0.08 }, nodes = {
                { n = G.UIT.R, config = { align = 'cm', hover = true, force_focus = true,
                    on_demand_tooltip = { title = 'Pending restart', text = restart_reasons() } }, nodes = {
                    { n = G.UIT.T, config = { text = 'Restart required!', scale = 0.3, colour = G.C.IMPORTANT } }
                } },
                { n = G.UIT.R, config = { align = 'cm' }, nodes = {
                    { n = G.UIT.T, config = { text = 'Runs resume from last save.',
                        scale = 0.22, colour = G.C.UI.TEXT_LIGHT } }
                } }
            } }
            footer[#footer + 1] = { n = G.UIT.C, config = { align = 'cm' }, nodes = {
                UIBox_button { label = { 'Restart now' }, button = 'porkify_restart_now',
                    minw = 2.1, minh = 0.45, scale = 0.3, colour = HEX('b00067') }
            } }
        end
        nodes[#nodes + 1] = { n = G.UIT.R,
            config = { align = 'cm', padding = 0.06, r = 0.1, colour = HEX('24202e') }, nodes = footer }
        return { n = G.UIT.ROOT, config = { align = 'cm', colour = G.C.CLEAR }, nodes = nodes }
    end

    -- Limit the visibility override to hand-list construction and pagination.
    -- Gameplay also uses is_poker_hand_visible (e.g. Planet pools).
    local viewing_hands = false
    local visible = SMODS.is_poker_hand_visible
    SMODS.is_poker_hand_visible = function(name)
        if viewing_hands and mod.config.reveal_secret_hands
            and PORKIFY_SECRET_HANDS and PORKIFY_SECRET_HANDS[name] then return true end
        return visible(name)
    end
    local function wrap_view(original)
        return function(...)
            local previous = viewing_hands
            viewing_hands = true
            local ok, result = pcall(original, ...)
            viewing_hands = previous
            if not ok then error(result, 0) end
            return result
        end
    end
    create_UIBox_current_hands = wrap_view(create_UIBox_current_hands)
    G.FUNCS.your_hands_page = wrap_view(G.FUNCS.your_hands_page)

    local outline_sprite
    local outline_frame
    local outline_colours = {
        default = HEX('ff0095'), protanopia = HEX('0072b2'),
        tritanopia = HEX('d55e00'), deuteranopia = HEX('f0e442')
    }
    local function paint_outline(canvas, colour)
        love.graphics.push('all')
        love.graphics.setCanvas(canvas)
        love.graphics.origin()
        love.graphics.setShader()
        love.graphics.setScissor()
        love.graphics.clear(0, 0, 0, 0)
        -- Neutral edges preserve contrast independently of the current hue.
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.setLineWidth(6)
        love.graphics.rectangle('line', 3, 3, 136, 184, 6, 6)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setLineWidth(4)
        love.graphics.rectangle('line', 3, 3, 136, 184, 6, 6)
        love.graphics.setColor(colour)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle('line', 3, 3, 136, 184, 6, 6)
        love.graphics.pop()
    end
    local function favorite_outline_sprite(card)
        if not outline_sprite then
            -- Cache one transparent border texture; use the card shader for hover tilt.
            local canvas = love.graphics.newCanvas(142, 190)
            local atlas = { name = 'porkify_favorite_outline', image = canvas, px = 142, py = 190 }
            G.ASSET_ATLAS[atlas.name] = atlas
            outline_sprite = Sprite(0, 0, card.T.w, card.T.h, atlas, { x = 0, y = 0 })
        end
        local reduced_motion = G.SETTINGS and G.SETTINGS.reduced_motion
        local mode = mod.config.favorite_outline or 'none'
        local tick = math.floor((G.TIMERS and G.TIMERS.REAL or 0) * 30)
        local frame = mode == 'rainbow' and (reduced_motion and 'rainbow_static' or tick) or mode
        if frame ~= outline_frame then
            -- One eight-second cycle, updated at most 30 times/sec for all Favorites.
            local colour = outline_colours[mode] or outline_colours.deuteranopia
            if mode == 'rainbow' and not reduced_motion then
                local hue = (tick % 240) / 240
                local function channel(offset)
                    local k = (offset + hue * 6) % 6
                    return 1 - math.max(0, math.min(k, 4 - k, 1))
                end
                colour = { channel(5), channel(3), channel(1), 1 }
            end
            paint_outline(outline_sprite.atlas.image, colour)
            outline_frame = frame
        end
        return outline_sprite
    end
    SMODS.DrawStep {
        key = 'favorite_outline', order = 95,
        conditions = { vortex = false, facing = 'front' },
        func = function(card)
            if not mod.config.favorite_outline or mod.config.favorite_outline == 'none'
                or not (card.playing_card or card.porkify_config_preview)
                or not card.ability or not (card.ability.favorite or card.ability.porkify_favorite)
                or card.getting_sliced or card.shattered or card.destroyed then return end
            local center = card.children and card.children.center
            if not center then return end
            local sprite = favorite_outline_sprite(card)
            sprite.T, sprite.VT = center.T, center.VT
            sprite.role.draw_major = card
            sprite.layered_parallax = center.layered_parallax
            sprite:draw_shader('dissolve')
        end
    }
end
