
SMODS.Consumable {
    key = 'emergencyexit',
    set = 'porkify',
    pos = { x = 9, y = 0 },
    loc_txt = {
        name = 'Emergency Exit',
        text = {
            [1] = 'Immediately {C:green}win{} current {C:attention}Blind{}',
            [2] = '{C:inactive,s:0.75}(Cannot be used on Final Bosses){}'
        }
    },
    cost = 3,
    unlocked = true,
    discovered = false,
    hidden = false,
    can_repeat_soul = false,
    atlas = 'CustomConsumables',
    use = function(self, card, area, copier)
        local used_card = copier or card
        if not (G and G.GAME and G.GAME.blind and G.GAME.blind.in_blind) then return end

        local blind_key = G.GAME.blind.config and G.GAME.blind.config.blind and G.GAME.blind.config.blind.key
        local is_final_boss =
            blind_key == "bl_final_acorn" or
            blind_key == "bl_final_leaf" or
            blind_key == "bl_final_vessel" or
            blind_key == "bl_final_heart" or
            blind_key == "bl_final_bell"

        if not is_final_boss then
            G.E_MANAGER:add_event(Event({
                blocking = false,
                func = function()
                    if G.STATE == G.STATES.SELECTING_HAND then
                        G.GAME.chips = G.GAME.blind.chips
                        G.STATE = G.STATES.HAND_PLAYED
                        G.STATE_COMPLETE = true
                        end_round()
                        return true
                    end
                end
            }))
            return {
                message = "Exited!"
            }
        end
    end,
    can_use = function(self, card)
        if not (G and G.GAME and G.GAME.blind and G.GAME.blind.in_blind) then
            return false
        end

        local blind_key = G.GAME.blind.config and G.GAME.blind.config.blind and G.GAME.blind.config.blind.key
        return blind_key ~= "bl_final_acorn"
            and blind_key ~= "bl_final_leaf"
            and blind_key ~= "bl_final_vessel"
            and blind_key ~= "bl_final_heart"
            and blind_key ~= "bl_final_bell"
    end
}
