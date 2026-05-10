SMODS.Consumable {
    key = 'mephiles',
    set = 'porkify',
    pos = { x = 8, y = 1 },
    config = { extra = { copy_amount = 1 } },
    loc_txt = {
        name = 'Mephiles',
        text = {
            [1] = 'Create a {C:dark_edition}Negative{}',
            [2] = '{C:spades,E:1}Perishable{} copy of a',
            [3] = 'random {C:attention}Joker{}'
        }
    },
    cost = 3,
    unlocked = true,
    discovered = false,
    hidden = false,
    can_repeat_soul = false,
    atlas = 'CustomConsumables',

	credit_badges = {
        { text = "Art: leafnado", colour = "4CAF50" }
     },

    use = function(self, card, area, copier)
		local used_card = copier or card
		if not (G.jokers and G.jokers.cards and #G.jokers.cards >= 1) then return end

		-- collect candidates
		local available = {}
		for _, j in ipairs(G.jokers.cards) do
			if j and j.ability and j.ability.set == 'Joker' then
				available[#available + 1] = j
			end
		end
		if #available == 0 then return end

		pseudoshuffle(available, 54321)

		local copies = math.min(card.ability.extra.copy_amount or 1, #available)

		-- TEMP raise joker limit so we can emplace even if "full"
		-- local old_limit = (G.jokers.config and G.jokers.config.card_limit) or #G.jokers.cards
		-- G.jokers.config.card_limit = old_limit + copies

		G.E_MANAGER:add_event(Event({
			trigger = 'after',
			delay = 0.4,
			func = function()
				play_sound('timpani')
				used_card:juice_up(0.3, 0.5)
				return true
			end
		}))

		local _first_materialize = nil

		for i = 1, copies do
			local src = available[i]
			G.E_MANAGER:add_event(Event({
				trigger = 'before',
				delay = 0.45 + 0.05 * (i - 1),
				func = function()
					local cj = copy_card(src, nil, nil, nil, false)

					if cj.ability and cj.ability.eternal then
						cj.ability.eternal = false
						if cj.remove_sticker then
							pcall(function() cj:remove_sticker('eternal') end)
						end
					end

					cj:set_edition('e_negative', true)
					cj:add_sticker('perishable', true)

					cj:start_materialize(nil, _first_materialize)
					cj:add_to_deck()
					G.jokers:emplace(cj)

					_first_materialize = true
					return true
				end
			}))
		end

		-- Restore limit ONCE after all copies are made
		-- G.E_MANAGER:add_event(Event({
		-- 	trigger = 'after',
		-- 	delay = 0.55 + 0.05 * copies,
		-- 	func = function()
		-- 		local current = #G.jokers.cards
		-- 		G.jokers.config.card_limit = math.max(old_limit, current)
		-- 		return true
		-- 	end
		-- }))
	end,

    can_use = function(self, card)
        return (G.jokers and G.jokers.cards and #G.jokers.cards >= 1)
    end
}
