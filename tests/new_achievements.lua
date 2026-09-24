local definitions, reset, own, expect, joker, playing, drain = ...
to_big = to_big or function(value) return value end
reset()
local ghost = joker('j_porkify_phantom')
ghost.dissolve = 0 -- Finished materialization is not destruction.
ghost.protected = true
ghost:start_dissolve()
expect('ghost_busters', false)
ghost.protected = nil
ghost:start_dissolve()
expect('ghost_busters', true)
reset()
ghost = joker('j_porkify_phantom')
SMODS.calculate_context { selling_card = true, card = ghost }
ghost:start_dissolve()
expect('ghost_busters', false)
reset()
SMODS.pinch_and_remove(joker('j_porkify_kitty'))
expect('heartless', true)
reset()
SMODS.calculate_context { selling_card = true, card = joker('j_porkify_kitty') }
expect('heartless', true)
reset()
own('j_porkify_acejoker', 'j_porkify_pridebanner', 'j_porkify_prideful_joker', 'j_porkify_transjoker')
for _, id in ipairs({ 'estrogen', 'testosterone' }) do G.consumeables.cards[#G.consumeables.cards+1] = joker('c_porkify_' .. id) end
check_for_unlock { type = 'test' }
expect('the_ally', false)
G.consumeables.cards[#G.consumeables.cards+1] = joker('c_porkify_rainbow')
check_for_unlock { type = 'test' }
expect('the_ally', true)
reset()
G.GAME.selected_back_key = 'b_porkify_jimbo_deck'
G.consumeables.config = { card_limit = 0 }
check_for_unlock { type = 'test' }
expect('thats_illegal', false)
G.consumeables.config.card_limit = 1
check_for_unlock { type = 'test' }
expect('thats_illegal', true)
reset()
SMODS.calculate_context { skipping_booster = true, booster = { key = 'p_other' } }
expect('rip_off', false)
SMODS.calculate_context { skipping_booster = true, booster = { key = 'p_porkify_void_voucher_pack' } }
expect('rip_off', true)
reset()
own('j_egg','j_egg','j_egg','j_egg','j_egg')
for i=1,4 do G.jokers.cards[i].ability.porkify_cramped = true end
check_for_unlock { type = 'test' }
expect('see_a_doctor', false)
G.jokers.cards[5].ability.cramped = true
check_for_unlock { type = 'test' }
expect('see_a_doctor', true)
reset()
G.GAME.used_vouchers.v_money_tree = true
check_for_unlock { type = 'porkify_gilded_trigger', dollars = 99 }
expect('weimar_republic', false)
check_for_unlock { type = 'porkify_gilded_trigger', dollars = 100 }
expect('weimar_republic', true)
reset()
check_for_unlock { type = 'porkify_ionized_trigger', x_mult = 1 }
expect('meltdown', false)
check_for_unlock { type = 'porkify_ionized_trigger', x_mult = 0.5 }
expect('meltdown', true)
reset()
for _, id in ipairs({'m_steel','m_gold','m_porkify_emerald'}) do G.hand.cards[#G.hand.cards+1]=playing(2,id) end
check_for_unlock { type = 'test' }
expect('collector', false)
G.hand:emplace(playing(2,'m_porkify_diamond'))
expect('collector', true)
reset()
check_for_unlock { type = 'porkify_cleptomane_paid', dollars = 19 }
expect('twenty_is_twenty', false)
check_for_unlock { type = 'porkify_cleptomane_paid', dollars = 20 }
expect('twenty_is_twenty', true)
reset()
check_for_unlock { type = 'porkify_pickaxe_mimic' }
expect('through_your_teeth', true)
check_for_unlock { type = 'porkify_echo_max' }
expect('it_echoes', true)
reset()
local old_settings, old_profiles = G.SETTINGS, G.PROFILES
G.SETTINGS, G.PROFILES = { profile = 1 }, { [1] = {} }
G.STAGE = G.STAGES.MENU
local mod = { id = 'porkify' }
local old_love, old_save = love, G.save_progress
love = { system = { openURL = function() end } }
G.save_progress = function() end
G.FUNCS = G.FUNCS or {}
dofile(TEST_ROOT .. '/credits.lua')(mod)
G.FUNCS.porkify_credits_bluesky()
G.FUNCS.porkify_credits_twitter()
expect('supporter', false)
G.FUNCS.porkify_credits_github()
expect('supporter', true)
G.SETTINGS, G.PROFILES, love, G.save_progress = old_settings, old_profiles, old_love, old_save
reset()
print('Passed all 13 new achievement condition checks, including destruction and Credits callbacks.')
