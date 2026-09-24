-- Steamodded compares the completed hand score with the Blind requirement
-- without normalizing their numeric types. Talisman can make the former a
-- big-number table while a low Blind requirement is still a Lua number.
if type(evaluate_play_after) == 'function' and not Porkify_evaluate_play_after_talisman then
    Porkify_evaluate_play_after_talisman = evaluate_play_after
    function evaluate_play_after(...)
        if type(to_big) == 'function' and G and G.GAME and G.GAME.blind then
            local converted = to_big(G.GAME.blind.chips)
            if type(converted) == 'table' then
                G.GAME.blind.chips = converted
            end
        end
        return Porkify_evaluate_play_after_talisman(...)
    end
end

