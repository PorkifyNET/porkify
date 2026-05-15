SMODS.Consumable {
    key = 'sacrifice',
    set = 'porkify',
    pos = { x = 4, y = 2 },
    loc_txt = {
        name = 'Sacrifice',
        text = {
            [1] = '{C:red}Destroy{} {C:attention}4{} random cards,',
            [2] = 'then make {C:attention}2{} copies of',
            [3] = 'selected card with random',
            [4] = '{C:enhanced}Enhancement{}, {C:gold}Seal{} and',
            [5] = '{C:edition}Edition{}'
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
		if not (G.hand and #G.hand.cards > 0 and to_big(#G.hand.highlighted) == to_big(1) and to_big(G.hand.config.card_limit) >= to_big(5)) then
			return
		end

		local target = G.hand.highlighted[1]
		if not target then return end

		-- candidates to destroy (exclude selected)
		local candidates = {}
		for _, c in ipairs(G.hand.cards) do
			if c ~= target then
				candidates[#candidates + 1] = c
			end
		end
		if #candidates < 4 then return end

		pseudoshuffle(candidates, 12345)
		local destroyed_cards = { candidates[1], candidates[2], candidates[3], candidates[4] }

		-- --- deck-viewer truth is G.playing_cards, so keep it in sync ---
		local function remove_from_playing_cards(pc)
			if not (G and G.playing_cards and pc) then return end
			for i = #G.playing_cards, 1, -1 do
				if G.playing_cards[i] == pc then
					table.remove(G.playing_cards, i)
					return
				end
			end
		end

		local function ensure_in_playing_cards(pc)
			if not (G and G.playing_cards and pc) then return end
			for i = 1, #G.playing_cards do
				if G.playing_cards[i] == pc then return end
			end
			table.insert(G.playing_cards, pc)
		end

		local function pick_random_enhancement_key()
			local pool = {}
			if G.P_CENTER_POOLS and (G.P_CENTER_POOLS.Enhanced or G.P_CENTER_POOLS.Enhancement) then
				local p = G.P_CENTER_POOLS.Enhanced or G.P_CENTER_POOLS.Enhancement
				for _, v in pairs(p) do
					if v and v.key then pool[#pool+1] = v.key end
				end
			else
				for k, v in pairs(G.P_CENTERS or {}) do
					if v and (v.set == 'Enhanced' or v.set == 'Enhancement') then
						pool[#pool+1] = k
					end
				end
			end
			if #pool == 0 then return nil end
			return pseudorandom_element(pool, "porkify_sacrifice_enh")
		end

		local function pick_random_edition_key()
			local editions = { 'e_foil', 'e_holo', 'e_polychrome' }
			return pseudorandom_element(editions, "porkify_sacrifice_edition")
		end

		local function pick_random_seal_name()
			local seals = {
                'Gold', 'Red', 'Blue', 'Purple',
                'porkify_echo', 'porkify_forge',
                'porkify_ghost', 'porkify_pride', 'porkify_dice',
                'porkify_glitched', 'porkify_blank'
            }
			return pseudorandom_element(seals, "porkify_sacrifice_seal")
		end

		-- 1) Destroy 4 cards (sync deck list FIRST, then dissolve)
		G.E_MANAGER:add_event(Event({
			trigger = 'after',
			delay = 0.4,
			func = function()
				play_sound('tarot1')
				used_card:juice_up(0.3, 0.5)

				for _, dc in ipairs(destroyed_cards) do
					-- try the "official" way
					if dc and dc.remove_from_deck then dc:remove_from_deck() end
					-- and force-sync the deck viewer list
					remove_from_playing_cards(dc)
				end

				-- visuals (they're already removed logically)
				SMODS.destroy_cards(destroyed_cards)

				return true
			end
		}))

		-- 2) Create 2 copies (force-sync deck list so deck viewer sees them)
		G.E_MANAGER:add_event(Event({
			trigger = 'after',
			delay = 0.65,
			func = function()
				for i = 1, 2 do
					local copy = copy_card(target, nil, nil, nil, false)

					local enh_key = pick_random_enhancement_key()
					if enh_key and G.P_CENTERS and G.P_CENTERS[enh_key] then
						copy:set_ability(G.P_CENTERS[enh_key], true)
					end

					local seal = pick_random_seal_name()
					if seal then
						copy:set_seal(seal, nil, true)
					end

					local ed = pick_random_edition_key()
					if ed then
						copy:set_edition(ed, true)
					end

					copy:start_materialize()

					-- official add (sometimes fails to reflect in G.playing_cards in hand-context)
					if copy.add_to_deck then copy:add_to_deck() end
					-- force deck-viewer list sync
					ensure_in_playing_cards(copy)

					-- put it in hand
					G.hand:emplace(copy)
				end

				card_eval_status_text(used_card, 'extra', nil, nil, nil,
					{ message = "Sacrificed!", colour = G.C.RED })

				if G.hand then G.hand:unhighlight_all() end
				return true
			end
		}))
    end,

    can_use = function(self, card)
        if not (G.hand and #G.hand.cards > 0 and G.playing_cards) then
            return false
        end
        if not (to_big(#G.hand.highlighted) == to_big(1) and to_big(G.hand.config.card_limit) >= to_big(5)) then
            return false
        end
        return (#G.playing_cards - 2) >= 5
    end
}
