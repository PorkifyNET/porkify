return function(mod)
    local page = 1
    local links = {
        bluesky = 'https://bsky.app/profile/porky.live',
        twitter = 'https://x.com/PorkyLIVE_',
        github = 'https://github.com/PorkifyNET/porkify',
    }
    G.FUNCS.porkify_credits_bluesky = function()
        love.system.openURL(links.bluesky)
    end
    G.FUNCS.porkify_credits_twitter = function()
        if links.twitter then love.system.openURL(links.twitter) end
    end
    G.FUNCS.porkify_credits_github = function()
        if links.github then love.system.openURL(links.github) end
    end
    G.FUNCS.porkify_credits_page = function(args)
        page = args.cycle_config.current_option
        SMODS.LAST_SELECTED_MOD_TAB = 'credits'
        G.FUNCS['openModUI_' .. mod.id]()
    end
    mod.credits_tab = function()
        local function row(text, colour, scale)
            return { n = G.UIT.R, config = { align = 'cm', padding = 0.04 }, nodes = {
                { n = G.UIT.T, config = { text = text, colour = colour or G.C.UI.TEXT_LIGHT,
                    scale = scale or 0.3 } }
            } }
        end
        local credits, seen = {}, {}
        for key, center in pairs(G.P_CENTERS) do
            if key:match('^%w+_porkify_') then
                for _, badge in ipairs(center.credit_badges or center.porkify_credit_badges or {}) do
                    local text = type(badge) == 'string' and badge or badge.text or badge.label
                    if type(text) == 'string' and not seen[text]
                        and (text:lower():match('^art:') or text:lower():match('^idea:')) then
                        seen[text] = true
                        credits[#credits + 1] = text
                    end
                end
            end
        end
        table.sort(credits, function(a, b) return a:lower() < b:lower() end)
        local pages = math.max(1, math.ceil(#credits / 4))
        page = math.min(page, pages)
        local options = {}
        for i = 1, pages do options[i] = 'Contributors ' .. i .. ' / ' .. pages end
        local nodes = {
            row('Created by ' .. table.concat(mod.author or {}, ', '), HEX('ff8fce'), 0.4),
            row('Original version created with JokerForge'),
            row('Built for Balatro with Steamodded'),
            row('Art & ideas', HEX('ff8fce'), 0.34),
        }
        for i = 1, 4 do
            nodes[#nodes + 1] = row(credits[(page - 1) * 4 + i] or ' ')
        end
        nodes[#nodes + 1] = { n = G.UIT.R, config = { align = 'cm' }, nodes = {
            create_option_cycle { options = options, current_option = page, opt_callback = 'porkify_credits_page',
                w = 4.5, h = 0.45, text_scale = 0.3, colour = HEX('8f205f') }
        } }
        local buttons = {}
        for _, link in ipairs({ { 'Bluesky', 'bluesky' }, { 'Twitter / X', 'twitter' }, { 'GitHub', 'github' } }) do
            if links[link[2]] then
                buttons[#buttons + 1] = { n = G.UIT.C, config = { align = 'cm', padding = 0.05 }, nodes = {
                    UIBox_button { label = { link[1] }, button = 'porkify_credits_' .. link[2],
                        minw = 2, minh = 0.5, scale = 0.3, colour = HEX('b00067') }
                } }
            end
        end
        nodes[#nodes + 1] = { n = G.UIT.R, config = { align = 'cm', padding = 0.08 }, nodes = buttons }
        return { n = G.UIT.ROOT, config = { align = 'cm', padding = 0.08, colour = G.C.CLEAR }, nodes = nodes }
    end
end
