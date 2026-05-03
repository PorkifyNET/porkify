
SMODS.Joker{ --The Hospital
    key = "thehospital",
    config = {
        extra = {
        }
    },
    loc_txt = {
        ['name'] = 'The Hospital',
        ['text'] = {
            [1] = 'Disables all human',
            [2] = 'body-themed {C:purple}Boss Blinds{}',
            [3] = '{C:inactive}(The Arm, The Eye, The Mouth,{}',
            [4] = '{C:inactive}The Head, The Tooth,{}',
            [5] = '{C:inactive}The Finger, Crimson Heart){}'
        },
        ['unlock'] = {
            [1] = 'Discover {C:attention}20{} Blinds'
        }
    },
    pos = {
        x = 9,
        y = 1
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 6,
    rarity = 3,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = false,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["porkify_porkify_jokers"] = true },
    unlock_condition = { type = 'blind_discoveries', extra = 20 },
	
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            local blind = G.GAME and G.GAME.blind
            local blind_key = blind and (
                blind.original_key
                or blind.key
                or (blind.config and blind.config.blind and blind.config.blind.key)
            )
            local hospital_blinds = {
                bl_arm = true,
                bl_eye = true,
                bl_mouth = true,
                bl_head = true,
                bl_tooth = true,
                bl_finger = true,
                bl_final_heart = true,
                bl_porkify_finger = true
            }

            if blind_key and hospital_blinds[blind_key] then
                return {
                    func = function()
                        if G.GAME.blind and G.GAME.blind.boss and not G.GAME.blind.disabled then
                            G.E_MANAGER:add_event(Event({
                                func = function()
                                    G.GAME.blind:disable()
                                    play_sound('timpani')
                                    return true
                                end
                            }))
                            card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = localize('ph_boss_disabled'), colour = G.C.GREEN})
                        end
                        return true
                    end
                }
            end
        end
    end
}
