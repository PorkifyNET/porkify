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

-- =========================================================
--  Platinum Stake (Earn no Interest)
-- =========================================================
local platinum_stake = SMODS.Stake{
    key = "stake_platinum",
    atlas = "CustomChips",
    sticker_atlas = "CustomStickers",
    pos = { x = 1, y = 0 },
    loc_txt = {
        name = "Platinum Stake",
        text = {
            "Earn no {C:attention}Interest{}"
        },
        sticker = {
            name = "Platinum Stake",
            text = {
                "Used this Joker",
                "to win on {C:attention}Platinum{}",
                "{C:attention}Stake{} difficulty"
            }
        }
    },
    sticker_pos = { x = 2, y = 0 },

    above_stake = "stake_diamond",
    applied_stakes = {"stake_diamond"},

    prefix_config = {
        key = true,
        applied_stakes = true,
        above_stake = true,
    },

    colour = G.C.GREY,
    process_loc_text = porkify_stake_process_loc_text
}

function platinum_stake:modifiers()
    if G and G.GAME and G.GAME.modifiers then
		G.GAME.modifiers.no_interest = true
	end
end

-- =========================================================
--  Diamond Stake (start with $0)
-- =========================================================
local diamond_stake = SMODS.Stake{
    key = "stake_diamond",
    atlas = "CustomChips",
    sticker_atlas = "CustomStickers",
    pos = { x = 0, y = 0 },
    loc_txt = {
        name = "Diamond Stake",
        text = {
            "Start the run with {C:money}$0{}"
        },
        sticker = {
            name = "Diamond Stake",
            text = {
                "Used this Joker",
                "to win on {C:attention}Diamond{}",
                "{C:attention}Stake{} difficulty"
            }
        }
    },
    sticker_pos = { x = 1, y = 0 },

    above_stake = "stake_gold",
    applied_stakes = {"stake_gold"},

    prefix_config = {
        key = true,
        applied_stakes = false,
        above_stake = false,
    },

    colour = G.C.PERISHABLE,
    process_loc_text = porkify_stake_process_loc_text
}

function diamond_stake:modifiers()
    if G and G.GAME and G.GAME.starting_params then
		G.GAME.starting_params.dollars = 0
	end
end

-- =========================================================
--  Emerald Stake (-1 Hand Size)
-- =========================================================
local emerald_stake = SMODS.Stake{
    key = "stake_emerald",
    atlas = "CustomChips",
    sticker_atlas = "CustomStickers",
    pos = { x = 2, y = 0 },
    sticker_atlas = "CustomStickers",
    loc_txt = {
        name = "Emerald Stake",
        text = {
            "Jokers can have {C:attention}Bulky{} stickers",
            "{C:inactive,s:0.9}(Takes up{} {C:attention,s:0.9}2{} {C:inactive,s:0.9}Joker Slots){}"
        },
        sticker = {
            name = "Emerald Stake",
            text = {
                "Used this Joker",
                "to win on {C:attention}Emerald{}",
                "{C:attention}Stake{} difficulty"
            }
        }
    },
    sticker_pos = { x = 3, y = 0 },

    above_stake = "stake_platinum",
    applied_stakes = {"stake_platinum"},

    prefix_config = {
        key = true,
        applied_stakes = true,
        above_stake = true,
    },

    colour = G.C.PALE_GREEN,
    sticker_pos = { x = 2, y = 2 },
    process_loc_text = porkify_stake_process_loc_text
}

function emerald_stake:modifiers()
    if G and G.GAME and G.GAME.modifiers then
        G.GAME.modifiers.enable_bulky = true
        G.GAME.modifiers.enable_porkify_bulky = true
	end
end

-- =========================================================
--  Topaz Stake (-1 Joker Slot)
-- =========================================================
local topaz_stake = SMODS.Stake{
    key = "stake_topaz",
    atlas = "CustomChips",
    sticker_atlas = "CustomStickers",
    pos = { x = 3, y = 1 },
    loc_txt = {
        name = "Topaz Stake",
        text = {
            "{C:red}-1{} Joker Slot"
        },
        sticker = {
            name = "Topaz Stake",
            text = {
                "Used this Joker",
                "to win on {C:attention}Topaz{}",
                "{C:attention}Stake{} difficulty"
            }
        }
    },
    sticker_pos = { x = 1, y = 1 },

    above_stake = "stake_ruby",
    applied_stakes = {"stake_ruby"},

    prefix_config = {
        key = true,
        applied_stakes = true,
        above_stake = true,
    },

    colour = G.C.RENTAL,
    process_loc_text = porkify_stake_process_loc_text
}

function topaz_stake:modifiers()
    if G and G.GAME and G.GAME.starting_params then
		G.GAME.starting_params.joker_slots = (G.GAME.starting_params.joker_slots or 5) - 1
	end
end

-- =========================================================
--  Pink Stake (-1 Consumable Slot)
-- =========================================================
local pink_stake = SMODS.Stake{
    key = "stake_pink",
    atlas = "CustomChips",
    pos = { x = 3, y = 0 },
    sticker_atlas = "CustomStickers",
    loc_txt = {
        name = "Pink Stake",
        text = {
            "Shop can have {C:attention}Cramped{} Jokers",
            "{C:inactive,s:0.9}({}{C:red,s:0.9}-1{} {C:inactive,s:0.9}Hand Size){}"
        },
        sticker = {
            name = "Pink Stake",
            text = {
                "Used this Joker",
                "to win on {C:attention}Pink{}",
                "{C:attention}Stake{} difficulty"
            }
        }
    },
    sticker_pos = { x = 3, y = 2 },

    above_stake = "stake_emerald",
    applied_stakes = {"stake_emerald"},

    prefix_config = {
        key = true,
        applied_stakes = true,
        above_stake = true,
    },

    colour = G.C.ETERNAL,
    process_loc_text = porkify_stake_process_loc_text
}

function pink_stake:modifiers()
    if G and G.GAME and G.GAME.modifiers then
        G.GAME.modifiers.enable_cramped = true
        G.GAME.modifiers.enable_porkify_cramped = true
	end
end

-- =========================================================
--  Ruby Stake (-1 Hand)
-- =========================================================
local ruby_stake = SMODS.Stake{
    key = "stake_ruby",
    atlas = "CustomChips",
    sticker_atlas = "CustomStickers",
    pos = { x = 4, y = 0 },
    loc_txt = {
        name = "Ruby Stake",
        text = {
            "{C:red}-1{} Hand"
        },
        sticker = {
            name = "Ruby Stake",
            text = {
                "Used this Joker",
                "to win on {C:attention}Ruby{}",
                "{C:attention}Stake{} difficulty"
            }
        }
    },
    sticker_pos = { x = 0, y = 1 },

    above_stake = "stake_pink",
    applied_stakes = {"stake_pink"},

    prefix_config = {
        key = true,
        applied_stakes = true,
        above_stake = true,
    },

    colour = HEX("D13B54"),
    process_loc_text = porkify_stake_process_loc_text
}

function ruby_stake:modifiers()
    if G and G.GAME and G.GAME.starting_params then
        G.GAME.starting_params.hands = math.max(1, (G.GAME.starting_params.hands or 4) - 1)
    end
end
