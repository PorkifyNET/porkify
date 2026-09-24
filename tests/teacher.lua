local definition
SMODS = {
    Joker = function(d) definition = d end,
    is_eternal = function(c) return c.eternal end,
    shatters = function() return false end,
    calculate_context = function() end,
    score_card = function(c) c.scored = true end,
    add_card = function(args)
        assert(args.key == 'c_fool')
        table.insert(G.consumeables.cards, args)
        return args
    end,
    destroy_cards = TEST_destroy_cards
}
local events = {}
Event = function(args) return args end
G = {GAME = {current_round = {hands_played = 0}}, C = {TAROT = {}},
    consumeables = {cards = {}, config = {card_limit = 2}},
    E_MANAGER = {add_event = function(self, event) events[#events + 1] = event end}}
function check_for_unlock() end
function localize(k) return k end
function card_eval_status_text() end
dofile(TEST_ROOT .. '/jokers/theheadmaster.lua')
local function attempt(face, count, opts)
    opts = opts or {}
    events = {}
    G.consumeables.cards = opts.full and {{}, {}} or {}
    G.GAME.consumeable_buffer = opts.buffer or 0
    G.GAME.current_round.hands_played = opts.later and 1 or 0
    local j = {ability = {extra = {}}, juice_up = function() end}
    local target = {base = {name = 'test'}, eternal = opts.eternal,
        is_face = function() return face end,
        start_dissolve = function() return not opts.protected end}
    local hand = {}
    for i = 1, count do hand[i] = target end
    local scoring = {target}
    local context = {after = true, full_hand = hand, scoring_hand = scoring,
        blueprint = opts.blueprint, retrigger_joker = opts.retrigger}
    assert(definition:calculate(j, {before = true, full_hand = hand}) == nil)
    SMODS.score_card(target, {})
    local effect = definition:calculate(j, context)
    if effect then effect.func() end
    assert(not target.destroyed, 'Teacher destroyed its target before the deferred post-score event')
    SMODS.score_card(target, {})
    for _, event in ipairs(events) do event.func() end
    return #G.consumeables.cards, target, scoring, j, context
end
local n, target, scoring, j, context = attempt(true, 1)
assert(n == 1 and target.destroyed and target.scored and #scoring == 1)
assert(definition:calculate(j, context) == nil)
for _, opts in ipairs({{later = true}, {eternal = true}, {protected = true},
    {blueprint = true}, {retrigger = true}, {buffer = 2}}) do
    n, target = attempt(true, 1, opts)
    assert(n == 0 and target.scored)
end
n, target = attempt(true, 1, {full = true})
assert(n == 2 and target.scored and not target.destroyed)
assert(attempt(false, 1) == 0)
assert(attempt(true, 2) == 0)
print('Teacher first-hand, destruction, capacity and scoring checks passed')

G.GAME.blind = {in_blind = true}
G.GAME.current_round.hands_played = 0
G.GAME.consumeable_buffer = 0
G.consumeables.cards = {}
G.hand = {highlighted = {{is_face = function() return true end}}}
G.play = {cards = {}}
local display_card = {ability = {extra = {}}, joker_display_values = {}}
local scoring_hand = G.hand.highlighted
local display = definition.joker_display_def({evaluate_hand = function() return '', {}, scoring_hand end})
G.C.SECONDARY_SET = {Tarot = {}}
G.C.UI = {TEXT_INACTIVE = {}}
local text = {children = {{config = {}}, {config = {}}}}
display.calc_function(display_card)
display.style_function(display_card, text)
assert(display_card.joker_display_values.count == 1 and display_card.joker_display_values.active)
assert(text.children[1].config.colour == G.C.SECONDARY_SET.Tarot)
G.GAME.current_round.hands_played = 1
display.calc_function(display_card)
display.style_function(display_card, text)
assert(display_card.joker_display_values.count == 1 and not display_card.joker_display_values.active)
assert(text.children[2].config.colour == G.C.UI.TEXT_INACTIVE)
scoring_hand = {}
display.calc_function(display_card)
assert(display_card.joker_display_values.count == 0)
scoring_hand = {{is_face = function() return false end}}
display.calc_function(display_card)
assert(display_card.joker_display_values.count == 0)
print('Teacher Sixth Sense-style display checks passed')
