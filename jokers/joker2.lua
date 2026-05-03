
SMODS.Joker{ --Joker 2
    key = "joker2",
    config = {
        extra = {
            xmult0 = 4
        }
    },
    loc_txt = {
        ['name'] = 'Joker 2',
        ['text'] = {
            [1] = '{X:red,C:white}X4{} Mult'
        },
        ['unlock'] = {
            [1] = 'Win a run on {C:red}Red{} Stake'
        }
    },
    pos = {
        x = 1,
        y = 4
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 20,
    rarity = 4,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },
    unlock_condition = { type = 'win_stake', stake = 2 },
    in_pool = function(self, args)
        return (
            not args 
            or args.source ~= 'sho' 
            or args.source == 'buf' or args.source == 'jud' or args.source == 'rif' or args.source == 'rta' or args.source == 'sou' or args.source == 'uta' or args.source == 'wra'
        )
        and true
    end,
    
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.joker_main  then
            return {
                Xmult = 4
            }
        end
    end,
	
	joker_display_def = function(JokerDisplay)
	  return {
		text = {
		  {
			border_nodes = {
			  { text = "X" },
			  { ref_table = "card.ability.extra", ref_value = "xmult0" }
			}
		  }
		}
	  }
	end
}