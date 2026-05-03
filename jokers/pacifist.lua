
SMODS.Joker{ --Pacifist
    key = "pacifist",
    config = {
        extra = {
            xmult0 = 2
        }
    },
    loc_txt = {
        ['name'] = 'Pacifist',
        ['text'] = {
            [1] = '{X:red,C:white}X2{} Mult if not playing',
            [2] = 'against a {C:attention}Boss Blind{}'
        },
        ['unlock'] = {
            [1] = 'Win a run on {C:green}Green{} Stake'
        }
    },
    pos = {
        x = 2,
        y = 5
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 5,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },
    unlock_condition = { type = 'win_stake', stake = 3 },
    
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.joker_main  then
			if not (G and G.GAME and G.GAME.blind) then return end
            if not (G.GAME.blind.boss) then
                return {
                    Xmult = 2
                }
            end
        end
    end,
	
	joker_display_def = function(JokerDisplay)
	  return {
		text = {
		  {
			border_nodes = {
			  { text = "X" },
			  { ref_table = "card.joker_display_values", ref_value = "mult_text", retrigger_type = "exp" }
			}
		  },
		},
		reminder_text = {
			{ ref_table = "card.joker_display_values", ref_value = "status_text", colour = G.C.GREY }
		},

		calc_function = function(card)
		  local is_boss = (G and G.GAME and G.GAME.blind and G.GAME.blind.boss) or false
		  card.joker_display_values.mult_text = is_boss and "1" or "2"
		  card.joker_display_values.status_text = is_boss and "OFF (Boss)" or "ON"
		end
	  }
	end
}