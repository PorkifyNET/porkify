
local function porkify_booster_display_counts(self, card)
    local cfg = self.config or {}
    local choose = cfg.choose or 0
    local extra = cfg.extra or 0
    local modifiers = (G and G.GAME and G.GAME.modifiers) or {}

    choose = choose + (modifiers.booster_choice_mod or 0)
    extra = extra + (modifiers.booster_size_mod or 0)

    if self.kind == 'Porkify'
        and G and G.GAME and G.GAME.used_vouchers
        and G.GAME.used_vouchers.v_porkify_gluttony then
        extra = extra + 1
    end

    if choose < 1 then choose = 1 end
    if extra < 1 then extra = 1 end

    return choose, extra
end

local function porkify_apply_booster_counts(self, card)
    if not (card and card.ability) then
        return
    end

    local choose, extra = porkify_booster_display_counts(self, card)
    card.ability.choose = choose
    card.ability.extra = extra
end

local function porkify_fixed_deck_joker_pool()
    local pool = {}

    for _, center in pairs(G.P_CENTER_POOLS.Joker or {}) do
        local rarity = center and center.rarity
        local is_standard_joker_rarity = type(rarity) == "number" and rarity >= 1
        local is_ruleset = rarity == "porkify_ruleset"

        if center
            and center.set == "Joker"
            and center.key
            and center.unlocked
            and not center.no_collection
            and is_standard_joker_rarity
            and not is_ruleset
        then
            pool[#pool + 1] = center.key
        end
    end

    return pool
end

local function porkify_create_fixed_deck_pack_joker(pack_card, index)
    local full_pool = porkify_fixed_deck_joker_pool()
    if #full_pool < 1 then
        return nil
    end

    local seen_keys = pack_card.ability.porkify_fixed_deck_seen_keys or {}
    pack_card.ability.porkify_fixed_deck_seen_keys = seen_keys

    local available = {}
    for i = 1, #full_pool do
        local key = full_pool[i]
        if not seen_keys[key] then
            available[#available + 1] = key
        end
    end

    if #available < 1 then
        available = full_pool
    end

    local joker_key = pseudorandom_element(
        available,
        pseudoseed("porkify_fixed_deck_pack_" .. tostring(pack_card.sort_id or 0) .. "_" .. tostring(index or 0))
    )

    seen_keys[joker_key] = true

    local joker = SMODS.create_card({
        set = "Joker",
        key = joker_key,
        area = G.pack_cards,
        skip_materialize = true,
        soulable = true,
        no_edition = true,
        bypass_discovery_center = true
    })

    if joker then
        if joker.remove_sticker and joker.ability and joker.ability.perishable then
            joker:remove_sticker("perishable")
        end
        if joker.remove_sticker and joker.ability and (joker.ability.bulky or joker.ability.porkify_bulky) then
            joker:remove_sticker("bulky")
            joker:remove_sticker("porkify_bulky")
        end

        if joker.add_sticker and not (joker.ability and joker.ability.eternal) then
            joker:add_sticker("eternal", true)
        end
    end

    return joker
end

SMODS.Booster {
    key = 'tiny_porkify_pack',
    loc_txt = {
        name = "Tiny Porkify Pack",
        text = {
            [1] = 'Contains {C:attention}#2#{}',
            [2] = '{C:purple}Porkify{} card'
        },
        group_name = "porkify_boosters"
    },
    config = { extra = 1, choose = 1 },
    cost = 2,
    weight = 1,
    atlas = "CustomBoosters",
    pos = { x = 0, y = 0 },
    kind = 'Porkify',
    group_key = "porkify_boosters",
    porkify_pack_actions = true,
    draw_hand = true,
    select_card = "consumeables",
    discovered = false,

    credit_badges = {
        { text = "Art: burningstapler", colour = "59A487" }
     },
    
    loc_vars = function(self, info_queue, card)
        local choose, extra = porkify_booster_display_counts(self, card)
        return {
            vars = { choose, extra }
        }
    end,
    set_ability = function(self, card, initial)
        porkify_apply_booster_counts(self, card)
    end,
    create_card = function(self, card, i)
        return {
            set = "porkify",
            area = G.pack_cards,
            skip_materialize = true,
            soulable = true,
            key_append = "porkify_porkify_pack"
        }
    end,
    ease_background_colour = function(self)
        ease_colour(G.C.DYN_UI.MAIN, HEX("aa0040"))
        ease_background_colour({ new_colour = HEX('aa0040'), special_colour = HEX("ff0095"), contrast = 2 })
    end,
    particles = function(self)
        G.booster_pack_sparkles = Particles(1, 1, 0, 0, {
            timer = 0.015,
            scale = 0.2,
            initialize = true,
            lifespan = 1,
            speed = 1.1,
            padding = -1,
            attach = G.ROOM_ATTACH,
            colours = { G.C.WHITE, lighten(G.C.PURPLE, 0.4), lighten(G.C.PURPLE, 0.2), lighten(G.C.GOLD, 0.2) },
            fill = true
        })
        G.booster_pack_sparkles.fade_alpha = 1
        G.booster_pack_sparkles:fade(1, 0)
    end,
}

SMODS.Booster {
    key = 'porkify_pack',
    loc_txt = {
        name = "Porkify Pack",
        text = {
            [1] = 'Choose {C:attention}#1#{} of up to',
            [2] = '{C:attention}#2#{} {C:purple}Porkify{} cards'
        },
        group_name = "porkify_boosters"
    },
    config = { extra = 2, choose = 1 },
    cost = 4,
    weight = 0.8,
    atlas = "CustomBoosters",
    pos = { x = 0, y = 0 },
    kind = 'Porkify',
    group_key = "porkify_boosters",
    porkify_pack_actions = true,
    draw_hand = true,
    select_card = "consumeables",
    discovered = false,

    credit_badges = {
        { text = "Art: burningstapler", colour = "59A487" }
     },
    
    loc_vars = function(self, info_queue, card)
        local choose, extra = porkify_booster_display_counts(self, card)
        return {
            vars = { choose, extra }
        }
    end,
    set_ability = function(self, card, initial)
        porkify_apply_booster_counts(self, card)
    end,
    create_card = function(self, card, i)
        return {
            set = "porkify",
            area = G.pack_cards,
            skip_materialize = true,
            soulable = true,
            key_append = "porkify_porkify_pack"
        }
    end,
    ease_background_colour = function(self)
        ease_colour(G.C.DYN_UI.MAIN, HEX("aa0040"))
        ease_background_colour({ new_colour = HEX('aa0040'), special_colour = HEX("ff0095"), contrast = 2 })
    end,
    particles = function(self)
        G.booster_pack_sparkles = Particles(1, 1, 0, 0, {
            timer = 0.015,
            scale = 0.2,
            initialize = true,
            lifespan = 1,
            speed = 1.1,
            padding = -1,
            attach = G.ROOM_ATTACH,
            colours = { G.C.WHITE, lighten(G.C.PURPLE, 0.4), lighten(G.C.PURPLE, 0.2), lighten(G.C.GOLD, 0.2) },
            fill = true
        })
        G.booster_pack_sparkles.fade_alpha = 1
        G.booster_pack_sparkles:fade(1, 0)
    end,
}

SMODS.Booster {
    key = 'jumbo_porkify_pack',
    loc_txt = {
        name = "Jumbo Porkify Pack",
        text = {
            [1] = 'Choose {C:attention}#1#{} of up to',
            [2] = '{C:attention}#2#{} {C:purple}Porkify{} cards'
        },
        group_name = "porkify_boosters"
    },
    config = { extra = 3, choose = 1 },
    cost = 6,
    weight = 0.6,
    atlas = "CustomBoosters",
    pos = { x = 0, y = 0 },
    kind = 'Porkify',
    group_key = "porkify_boosters",
    porkify_pack_actions = true,
    draw_hand = true,
    select_card = "consumeables",
    discovered = false,

    credit_badges = {
        { text = "Art: burningstapler", colour = "59A487" }
     },
    
    loc_vars = function(self, info_queue, card)
        local choose, extra = porkify_booster_display_counts(self, card)
        return {
            vars = { choose, extra }
        }
    end,
    set_ability = function(self, card, initial)
        porkify_apply_booster_counts(self, card)
    end,
    create_card = function(self, card, i)
        return {
            set = "porkify",
            area = G.pack_cards,
            skip_materialize = true,
            soulable = true,
            key_append = "porkify_porkify_pack"
        }
    end,
    ease_background_colour = function(self)
        ease_colour(G.C.DYN_UI.MAIN, HEX("aa0040"))
        ease_background_colour({ new_colour = HEX('aa0040'), special_colour = HEX("ff0095"), contrast = 2 })
    end,
    particles = function(self)
        G.booster_pack_sparkles = Particles(1, 1, 0, 0, {
            timer = 0.015,
            scale = 0.2,
            initialize = true,
            lifespan = 1,
            speed = 1.1,
            padding = -1,
            attach = G.ROOM_ATTACH,
            colours = { G.C.WHITE, lighten(G.C.PURPLE, 0.4), lighten(G.C.PURPLE, 0.2), lighten(G.C.GOLD, 0.2) },
            fill = true
        })
        G.booster_pack_sparkles.fade_alpha = 1
        G.booster_pack_sparkles:fade(1, 0)
    end,
}

SMODS.Booster {
    key = 'mega_porkify_pack',
    loc_txt = {
        name = "Mega Porkify Pack",
        text = {
            [1] = 'Choose {C:attention}#1#{} of up to',
            [2] = '{C:attention}#2#{} {C:purple}Porkify{} cards'
        },
        group_name = "porkify_boosters"
    },
    config = { extra = 4, choose = 2 },
    cost = 8,
    weight = 0.4,
    atlas = "CustomBoosters",
    pos = { x = 0, y = 0 },
    kind = 'Porkify',
    group_key = "porkify_boosters",
    porkify_pack_actions = true,
    draw_hand = true,
    select_card = "consumeables",
    discovered = false,

    credit_badges = {
        { text = "Art: burningstapler", colour = "59A487" }
     },

    loc_vars = function(self, info_queue, card)
        local choose, extra = porkify_booster_display_counts(self, card)
        return {
            vars = { choose, extra }
        }
    end,
    set_ability = function(self, card, initial)
        porkify_apply_booster_counts(self, card)
    end,
    create_card = function(self, card, i)
        return {
            set = "porkify",
            area = G.pack_cards,
            skip_materialize = true,
            soulable = true,
            key_append = "porkify_porkify_pack"
        }
    end,
    ease_background_colour = function(self)
        ease_colour(G.C.DYN_UI.MAIN, HEX("aa0040"))
        ease_background_colour({ new_colour = HEX('aa0040'), special_colour = HEX("ff0095"), contrast = 2 })
    end,
    particles = function(self)
        G.booster_pack_sparkles = Particles(1, 1, 0, 0, {
            timer = 0.015,
            scale = 0.2,
            initialize = true,
            lifespan = 1,
            speed = 1.1,
            padding = -1,
            attach = G.ROOM_ATTACH,
            colours = { G.C.WHITE, lighten(G.C.PURPLE, 0.4), lighten(G.C.PURPLE, 0.2), lighten(G.C.GOLD, 0.2) },
            fill = true
        })
        G.booster_pack_sparkles.fade_alpha = 1
        G.booster_pack_sparkles:fade(1, 0)
    end,
}

SMODS.Booster {
    key = 'void_voucher_pack',
    loc_txt = {
        name = "Void Voucher Pack",
        text = {
            [1] = 'Choose {C:attention}1{} of up to {C:attention}2{}',
            [2] = '{C:attention}Vouchers{} to add to',
            [3] = 'your run'
        },
        group_name = "porkify_boosters"
    },
    config = { extra = 2, choose = 1 },
    cost = 20,
    weight = 0.05,
    atlas = "CustomBoosters",
    pos = { x = 1, y = 0 },
    group_key = "porkify_boosters",
    discovered = false,

    credit_badges = {
        { text = "Art: Cavo", colour = "59A487" }
     },
    
    loc_vars = function(self, info_queue, card)
        local choose, extra = porkify_booster_display_counts(self, card)
        return {
            vars = { choose, extra }
        }
    end,
    set_ability = function(self, card, initial)
        porkify_apply_booster_counts(self, card)
    end,
    create_card = function(self, card, i)
        return {
            set = "Voucher",
            area = G.pack_cards,
            skip_materialize = true,
            soulable = true,
            key_append = "porkify_void_voucher_pack"
        }
    end,
    particles = function(self)
        -- No particles for voucher packs
        end,
    }
    
    
SMODS.Booster {
	key = 'common_joker_pack',
	loc_txt = {
		name = "Common Joker Pack",
		text = {
			[1] = 'Choose {C:attention}1{} of up to',
			[2] = '{C:attention}4{} {C:common}Common{} Joker cards'
		},
		group_name = "porkify_boosters"
	},
	config = { extra = 4, choose = 1 },
	cost = 4,
	weight = 0.7,
	atlas = "CustomBoosters",
	pos = { x = 2, y = 0 },
	kind = 'Common Jokers',
	group_key = "porkify_boosters",
	discovered = false,

    credit_badges = {
        { text = "Art: burningstapler", colour = "59A487" }
     },
    
	loc_vars = function(self, info_queue, card)
		local choose, extra = porkify_booster_display_counts(self, card)
		return {
			vars = { choose, extra }
		}
	end,
	set_ability = function(self, card, initial)
		porkify_apply_booster_counts(self, card)
	end,
	create_card = function(self, card, i)
		return {
			set = "Joker",
			rarity = "Common",
			area = G.pack_cards,
			skip_materialize = true,
			soulable = true,
			key_append = "porkify_common_joker_pack"
		}
	end,
	ease_background_colour = function(self)
		ease_colour(G.C.DYN_UI.MAIN, HEX("4a90e2"))
		ease_background_colour({ new_colour = HEX('4a90e2'), special_colour = HEX("50e3c2"), contrast = 2 })
	end,
	particles = function(self)
		-- No particles for joker packs
		end,
	}
        
        
SMODS.Booster {
	key = 'uncommon_joker_pack',
	loc_txt = {
		name = "Uncommon Joker Pack",
		text = {
			[1] = 'Choose {C:attention}1{} of up to',
			[2] = '{C:attention}3{} {C:uncommon}Uncommon{} Joker cards'
		},
		group_name = "porkify_boosters"
	},
	config = { extra = 3, choose = 1 },
	cost = 8,
	weight = 0.25,
	atlas = "CustomBoosters",
	pos = { x = 3, y = 0 },
	group_key = "porkify_boosters",
	discovered = false,

    credit_badges = {
        { text = "Art: burningstapler", colour = "59A487" }
     },
    
	loc_vars = function(self, info_queue, card)
		local choose, extra = porkify_booster_display_counts(self, card)
		return {
			vars = { choose, extra }
		}
	end,
	set_ability = function(self, card, initial)
		porkify_apply_booster_counts(self, card)
	end,
	create_card = function(self, card, i)
		return {
			set = "Joker",
			rarity = "Uncommon",
			area = G.pack_cards,
			skip_materialize = true,
			soulable = true,
			key_append = "porkify_uncommon_joker_pack"
		}
	end,
	ease_background_colour = function(self)
		ease_colour(G.C.DYN_UI.MAIN, HEX("7ed321"))
		ease_background_colour({ new_colour = HEX('7ed321'), special_colour = HEX("417505"), contrast = 2 })
	end,
	particles = function(self)
		-- No particles for joker packs
		end,
	}
            
            
SMODS.Booster {
	key = 'rare_joker_pack',
	loc_txt = {
		name = "Rare Joker Pack",
		text = {
			[1] = 'Choose {C:attention}1{} of up to',
			[2] = '{C:attention}2{} {C:rare}Rare{} Joker cards'
		},
		group_name = "porkify_boosters"
	},
	config = { extra = 2, choose = 1 },
	cost = 16,
	weight = 0.05,
	atlas = "CustomBoosters",
	pos = { x = 4, y = 0 },
	group_key = "porkify_boosters",
	discovered = false,

	credit_badges = {
		{ text = "Art: burningstapler", colour = "59A487" }
	},

	loc_vars = function(self, info_queue, card)
		local choose, extra = porkify_booster_display_counts(self, card)
		return {
			vars = { choose, extra }
		}
	end,
	set_ability = function(self, card, initial)
		porkify_apply_booster_counts(self, card)
	end,
	create_card = function(self, card, i)
		return {
			set = "Joker",
			rarity = "Rare",
			area = G.pack_cards,
			skip_materialize = true,
			soulable = true,
			key_append = "porkify_rare_joker_pack"
		}
	end,
	ease_background_colour = function(self)
		ease_colour(G.C.DYN_UI.MAIN, HEX("d0021b"))
		ease_background_colour({ new_colour = HEX('d0021b'), special_colour = HEX("000000"), contrast = 2 })
	end,
	particles = function(self)
		-- No particles for joker packs
		end,
	}

SMODS.Booster {
    key = "giga_buffoon_pack",
    loc_txt = {
        name = "Giga Buffoon Pack",
        text = {
            [1] = "Choose {C:attention}#1#{} of up to",
            [2] = "{C:attention}#2#{} Joker cards,",
            [3] = "all {C:purple}Eternal{}"
        },
        group_name = "porkify_boosters"
    },
    config = { extra = 10, choose = 5 },
    cost = 0,
    weight = 0,
    atlas = "CustomBoosters",
    pos = { x = 2, y = 0 },
    kind = "Buffoon",
    group_key = "porkify_boosters",
    porkify_unskippable = true,
    discovered = true,
    unlocked = true,
    no_collection = true,

    credit_badges = {
        { text = "Idea: PorkyLIVE", colour = "7A2D8C" }
    },

    in_pool = function(self, args)
        return false
    end,
    loc_vars = function(self, info_queue, card)
        return {
            vars = { 5, 10 }
        }
    end,
    set_ability = function(self, card, initial)
        card.ability.choose = 5
        card.ability.extra = 10
        card.ability.porkify_fixed_deck_seen_keys = nil
    end,
    create_card = function(self, card, i)
        return porkify_create_fixed_deck_pack_joker(card, i)
    end,
    ease_background_colour = function(self)
        ease_colour(G.C.DYN_UI.MAIN, HEX("c96f00"))
        ease_background_colour({ new_colour = HEX("c96f00"), special_colour = HEX("f2c14e"), contrast = 2 })
    end,
    particles = function(self)
        end,
}
