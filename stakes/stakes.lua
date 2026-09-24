local function porkify_stake_process_loc_text(self)
    if not self.loc_txt or not next(self.loc_txt) then
        return
    end

    local target = (G.SETTINGS.real_language and self.loc_txt[G.SETTINGS.real_language])
        or self.loc_txt[G.SETTINGS.language]
        or self.loc_txt["default"]
        or self.loc_txt["en-us"]
        or self.loc_txt

    local desc_target = copy_table(target)
    if self.applied_stakes and next(self.applied_stakes) then
        table.insert(desc_target.text, "{s:0.8}Applies all previous Stakes")
    end

    G.localization.descriptions[self.set][self.key] = desc_target
    SMODS.process_loc_text(G.localization.descriptions["Other"], self.key:sub(7) .. "_sticker", self.loc_txt, "sticker")
end

-- Registration order follows notes/new_stakes; keep existing keys for progress.
SMODS.Stake {
    key = 'stake_pink', atlas = 'CustomChips', sticker_atlas = 'CustomStickers',
    pos = {x = 3, y = 0}, sticker_pos = {x = 4, y = 0},
    above_stake = 'stake_gold', applied_stakes = {'stake_gold'},
    prefix_config = {key = true, above_stake = false, applied_stakes = false},
    colour = HEX('FF55AA'), process_loc_text = porkify_stake_process_loc_text,
    loc_txt = {
        name = 'Pink Stake',
        text = {'Required score scales', 'faster for each {C:attention}Ante{}'},
        sticker = {name = 'Pink Stake', text = {
            'Used this Joker to win on', '{C:attention}Pink Stake{} difficulty'
        }}
    },
    modifiers = function(self)
        G.GAME.modifiers.scaling = 4
    end
}

SMODS.Stake {
    key = 'stake_sulfur', atlas = 'CustomChips', sticker_atlas = 'CustomStickers',
    pos = {x = 0, y = 1}, sticker_pos = {x = 1, y = 2},
    above_stake = 'stake_porkify_stake_pink', applied_stakes = {'stake_porkify_stake_pink'},
    prefix_config = {key = true, above_stake = false, applied_stakes = false},
    colour = HEX('E6D44A'), process_loc_text = porkify_stake_process_loc_text,
    loc_txt = {
        name = 'Sulfur Stake',
        text = {'Joker stickers can also appear on', '{C:attention}Consumables{} and {C:attention}playing cards{}'},
        sticker = {name = 'Sulfur Stake', text = {
            'Used this Joker to win on', '{C:attention}Sulfur Stake{} difficulty'
        }}
    },
    modifiers = function(self)
        G.GAME.modifiers.porkify_sulfur = true
    end
}

SMODS.Stake {
    key = 'stake_lapis', atlas = 'CustomChips', sticker_atlas = 'CustomStickers',
    pos = {x = 1, y = 1}, sticker_pos = {x = 0, y = 2},
    above_stake = 'stake_porkify_stake_sulfur', applied_stakes = {'stake_porkify_stake_sulfur'},
    prefix_config = {key = true, above_stake = false, applied_stakes = false},
    colour = HEX('386AC5'), process_loc_text = porkify_stake_process_loc_text,
    loc_txt = {
        name = 'Lapis Stake',
        text = {'Jokers can have {C:attention}Bulky{} stickers', '{C:inactive,s:0.75}(Uses 2 slots){}'},
        sticker = {name = 'Lapis Stake', text = {
            'Used this Joker to win on', '{C:attention}Lapis Stake{} difficulty'
        }}
    },
    modifiers = function(self)
        G.GAME.modifiers.enable_porkify_bulky = true
        G.GAME.modifiers.enable_bulky = true
    end
}

SMODS.Stake {
    key = 'stake_diamond', atlas = 'CustomChips', sticker_atlas = 'CustomStickers',
    pos = {x = 0, y = 0}, sticker_pos = {x = 1, y = 0},
    above_stake = 'stake_porkify_stake_lapis', applied_stakes = {'stake_porkify_stake_lapis'},
    prefix_config = {key = true, above_stake = false, applied_stakes = false},
    colour = HEX('00FFFF'), process_loc_text = porkify_stake_process_loc_text,
    loc_txt = {
        name = 'Diamond Stake',
        text = {'Beat {C:attention}Ante 10{} to win'},
        sticker = {name = 'Diamond Stake', text = {
            'Used this Joker to win on', '{C:attention}Diamond Stake{} difficulty'
        }}
    },
    modifiers = function(self)
        G.GAME.win_ante = 10
    end
}

SMODS.Stake {
    key = 'stake_ruby', atlas = 'CustomChips', sticker_atlas = 'CustomStickers',
    pos = {x = 4, y = 0}, sticker_pos = {x = 0, y = 1},
    above_stake = 'stake_porkify_stake_diamond', applied_stakes = {'stake_porkify_stake_diamond'},
    prefix_config = {key = true, above_stake = false, applied_stakes = false},
    colour = HEX('FF5555'), process_loc_text = porkify_stake_process_loc_text,
    loc_txt = {
        name = 'Ruby Stake',
        text = {'{C:attention}Big Blind{} gives', 'no reward money'},
        sticker = {name = 'Ruby Stake', text = {
            'Used this Joker to win on', '{C:attention}Ruby Stake{} difficulty'
        }}
    },
    modifiers = function(self)
        G.GAME.modifiers.no_blind_reward = G.GAME.modifiers.no_blind_reward or {}
        G.GAME.modifiers.no_blind_reward.Big = true
    end
}

SMODS.Stake {
    key = 'stake_sapphire', atlas = 'CustomChips', sticker_atlas = 'CustomStickers',
    pos = {x = 4, y = 1}, sticker_pos = {x = 2, y = 1},
    above_stake = 'stake_porkify_stake_ruby', applied_stakes = {'stake_porkify_stake_ruby'},
    prefix_config = {key = true, above_stake = false, applied_stakes = false},
    colour = HEX('0055AA'), process_loc_text = porkify_stake_process_loc_text,
    loc_txt = {
        name = 'Sapphire Stake',
        text = {'Lose {C:attention}25%{} of {C:money}${}', 'at end of {C:attention}Ante{}'},
        sticker = {name = 'Sapphire Stake', text = {
            'Used this Joker to win on', '{C:attention}Sapphire Stake{} difficulty'
        }}
    },
    modifiers = function(self)
        G.GAME.modifiers.porkify_ante_tax = true
    end
}

SMODS.Stake {
    key = 'stake_emerald', atlas = 'CustomChips', sticker_atlas = 'CustomStickers',
    pos = {x = 2, y = 0}, sticker_pos = {x = 3, y = 0},
    above_stake = 'stake_porkify_stake_sapphire', applied_stakes = {'stake_porkify_stake_sapphire'},
    prefix_config = {key = true, above_stake = false, applied_stakes = false},
    colour = HEX('55AA00'), process_loc_text = porkify_stake_process_loc_text,
    loc_txt = {
        name = 'Emerald Stake',
        text = {'Shop items can', 'appear {C:attention}face down{}'},
        sticker = {name = 'Emerald Stake', text = {
            'Used this Joker to win on', '{C:attention}Emerald Stake{} difficulty'
        }}
    },
    modifiers = function(self)
        G.GAME.modifiers.porkify_hidden_shop = true
    end
}

SMODS.Stake {
    key = 'stake_platinum', atlas = 'CustomChips', sticker_atlas = 'CustomStickers',
    pos = {x = 1, y = 0}, sticker_pos = {x = 2, y = 0},
    above_stake = 'stake_porkify_stake_emerald', applied_stakes = {'stake_porkify_stake_emerald'},
    prefix_config = {key = true, above_stake = false, applied_stakes = false},
    colour = HEX('AAAAAA'), process_loc_text = porkify_stake_process_loc_text,
    loc_txt = {
        name = 'Platinum Stake',
        text = {'Jokers can have {C:attention}Cramped{} stickers', '{C:inactive,s:0.75}({}{C:red}-1{} {C:inactive}Hand Size){}'},
        sticker = {name = 'Platinum Stake', text = {
            'Used this Joker to win on', '{C:attention}Platinum Stake{} difficulty'
        }}
    },
    modifiers = function(self)
        G.GAME.modifiers.enable_porkify_cramped = true
        G.GAME.modifiers.enable_cramped = true
    end
}

SMODS.Stake {
    key = 'stake_onyx', atlas = 'CustomChips', sticker_atlas = 'CustomStickers',
    pos = {x = 2, y = 1}, sticker_pos = {x = 3, y = 1},
    above_stake = 'stake_porkify_stake_platinum', applied_stakes = {'stake_porkify_stake_platinum'},
    prefix_config = {key = true, above_stake = false, applied_stakes = false},
    colour = HEX('222222'), process_loc_text = porkify_stake_process_loc_text,
    loc_txt = {
        name = 'Onyx Stake',
        text = {'Required score scales', 'faster for each {C:attention}Ante{}'},
        sticker = {name = 'Onyx Stake', text = {
            'Used this Joker to win on', '{C:attention}Onyx Stake{} difficulty'
        }}
    },
    modifiers = function(self)
        G.GAME.modifiers.scaling = 5
    end
}

SMODS.Stake {
    key = 'stake_topaz', atlas = 'CustomChips', sticker_atlas = 'CustomStickers',
    pos = {x = 3, y = 1}, sticker_pos = {x = 1, y = 1},
    above_stake = 'stake_porkify_stake_onyx', applied_stakes = {'stake_porkify_stake_onyx'},
    prefix_config = {key = true, above_stake = false, applied_stakes = false},
    colour = HEX('FDA200'), process_loc_text = porkify_stake_process_loc_text,
    loc_txt = {
        name = 'Topaz Stake',
        text = {'{C:purple,E:1}Showdown Blinds{} can', 'appear in any {C:attention}Ante{}'},
        sticker = {name = 'Topaz Stake', text = {
            'Used this Joker to win on', '{C:attention}Topaz Stake{} difficulty'
        }}
    },
    modifiers = function(self)
        G.GAME.modifiers.porkify_early_showdowns = true
    end
}

assert(SMODS.load_file('stake_effects.lua'))()
