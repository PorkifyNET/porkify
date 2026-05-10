
SMODS.Consumable {
    key = 'top_up_consumable',
    set = 'porkify',
    pos = { x = 3, y = 3 },
    config = { 
        extra = {
            totaljokerslots = 0,
            repetitions = 1   
        } 
    },
    loc_txt = {
        name = 'Top Up',
        text = {
            [1] = 'Fill {C:attention}empty{} Joker Slots',
            [2] = 'with {C:common}Common{} {C:attention}Jokers{}'
        }
    },
    cost = 3,
    unlocked = true,
    discovered = false,
    hidden = false,
    can_repeat_soul = false,
    atlas = 'CustomConsumables',

	credit_badges = {
        { text = "Art: blissful-summit", colour = "F72536" }
     },
	
    use = function(self, card, area, copier)
		local used_card = copier or card
		if not (G.jokers and G.jokers.cards and G.jokers.config) then return end

		local limit = G.jokers.config.card_limit or 0
		local current = #G.jokers.cards
		local empties = math.max(limit - current, 0)

		if empties <= 0 then return end

		-- SFX/juice once
		G.E_MANAGER:add_event(Event({
			trigger = 'after',
			delay = 0.4,
			func = function()
				play_sound('timpani')
				used_card:juice_up(0.3, 0.5)
				return true
			end
		}))

		-- Add one common joker per empty slot
		for n = 1, empties do
			G.E_MANAGER:add_event(Event({
				trigger = 'after',
				delay = 0.45 + (n-1) * 0.05, -- small stagger so it feels nice and avoids weird timing
				func = function()
					if #G.jokers.cards + (G.GAME.joker_buffer or 0) < (G.jokers.config.card_limit or 0) then
						G.GAME.joker_buffer = (G.GAME.joker_buffer or 0) + 1
						SMODS.add_card({ set = 'Joker', rarity = 'Common' })
						G.GAME.joker_buffer = (G.GAME.joker_buffer or 1) - 1
					end
					return true
				end
			}))
		end

		delay(0.6)
	end,
    can_use = function(self, card)
		if not (G.jokers and G.jokers.cards and G.jokers.config) then return false end
		return (#G.jokers.cards < (G.jokers.config.card_limit or 0))
	end
}