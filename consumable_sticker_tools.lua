PORKIFY_STICKER_TOOL_KEYS = {
    c_porkify_fountainofyouth = true,
    c_porkify_excalibur = true,
    c_porkify_freezer = true,
    c_porkify_mortgage = true,
}

function Porkify_get_sticker_tool_target(source)
    local target, target_area
    for _, area in ipairs({G.hand, G.jokers, G.consumeables}) do
        for _, highlighted in ipairs((area and area.highlighted) or {}) do
            if highlighted ~= source then
                if target then return nil end
                target, target_area = highlighted, area
            end
        end
    end
    return target, target_area
end

function Porkify_update_sticker_tool_selection()
    if not (G and G.consumeables and G.consumeables.config) then return end
    local area = G.consumeables
    area.config.porkify_original_highlight_limit = area.config.porkify_original_highlight_limit
        or area.config.highlighted_limit or 1
    local tool_selected = false
    for _, selected in ipairs(area.highlighted or {}) do
        local key = selected.config and selected.config.center and selected.config.center.key
        if PORKIFY_STICKER_TOOL_KEYS[key] then tool_selected = true; break end
    end
    area.config.highlighted_limit = tool_selected and 2 or area.config.porkify_original_highlight_limit
end

function Porkify_clear_sticker_tool_selection()
    for _, area in ipairs({G.hand, G.jokers, G.consumeables}) do
        if area and area.unhighlight_all then area:unhighlight_all() end
    end
    Porkify_update_sticker_tool_selection()
end

