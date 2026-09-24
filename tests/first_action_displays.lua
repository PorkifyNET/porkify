local definitions, callbacks = {}, {}
SMODS = {Joker = function(d) definitions[d.key] = d end, is_eternal = function(c) return c.eternal end}
G = {GAME = {current_round = {hands_played = 0, discards_used = 0, discards_left = 3}, round_resets = {ante = 1}, round = 1},
 hand = {highlighted = {}}, jokers = {}, consumeables = {cards = {}, config = {card_limit = 2}},
 STATE = 1, STATES = {SELECTING_HAND = 1}, C = {GREEN = {}, CHIPS = {}, SECONDARY_SET = {Tarot = {}, Enhanced = {}}, UI = {TEXT_INACTIVE = {}}}}
localize = function(k) return k end
juice_card_until = function(card, callback) callbacks[#callbacks + 1] = callback end
for _, file in ipairs({'theheadmaster','fissionjoker','shipwreck'}) do dofile(TEST_ROOT .. '/jokers/' .. file .. '.lua') end
local target = {is_face = function() return true end, get_id = function() return 12 end}
G.hand.highlighted = {target}
for _, key in ipairs({'theheadmaster','fissionjoker','shipwreck'}) do
 local d = definitions[key]
 local c = {area = G.jokers, ability = {extra = {}}, joker_display_values = {}}
 G.hand.highlighted = {}
 local before = #callbacks
 d:update(c, 0)
 assert(#callbacks == before + 1 and callbacks[#callbacks]())
 d:update(c, 0)
 assert(#callbacks == before + 1, 'Only one shake loop per card')
 G.hand.highlighted = {}
 assert(callbacks[#callbacks](), 'No selection must keep the readiness shake')
 G.hand.highlighted = {target}
 d:update(c, 0)
 assert(#callbacks == before + 1)
 c.debuff = true
 assert(not callbacks[#callbacks]())
 c.debuff = false
 local display = d.joker_display_def({evaluate_hand = function() return '', {}, G.hand.highlighted end})
 display.calc_function(c)
 if key == 'fissionjoker' then assert(c.joker_display_values.is_active)
 else assert(c.joker_display_values.count == 1) end
 local text = {children = {{config = {}}, {config = {}}}}
 display.style_function(c, text, text)
 assert(text.children[key == 'fissionjoker' and 2 or 1].config.colour ~= G.C.UI.TEXT_INACTIVE)
 G.GAME.current_round.hands_played = 1
 G.GAME.current_round.discards_used = 1
 display.calc_function(c)
 display.style_function(c, text, text)
 assert(text.children[key == 'fissionjoker' and 2 or 1].config.colour == G.C.UI.TEXT_INACTIVE)
 d:update(c, 0)
 assert(not c.porkify_ready_juice)
 G.GAME.current_round.hands_played = 0
 G.GAME.current_round.discards_used = 0
end
print('Teacher, Fission and Shipwreck shake lifecycle and display checks passed')
