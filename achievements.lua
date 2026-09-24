local starting_run = false

local function in_run()
    return G and G.GAME and G.STAGE == G.STAGES.RUN
end

local function key(card)
    return card and card.config and card.config.center and card.config.center.key
end

local function has_result(results, name)
    return results[name] and next(results[name]) ~= nil
end

local function porkify_key(id)
    return type(id) == 'string' and (id:match('^%w+_porkify_') or id:match('^porkify_')) ~= nil
end

local function track_card(card, played)
    if not in_run() or not card then return end
    local playing_card = SMODS.is_playing_card(card)
    -- Playing-card properties only matter when the card is actually played.
    if playing_card and not played then return end
    local id = key(card)
    local joker = card.config and card.config.center and card.config.center.set == 'Joker'
    local used = porkify_key(id)
    if playing_card then used = used or porkify_key(card.seal) end
    if playing_card or joker then
        used = used or porkify_key(card.edition and card.edition.key)
        for edition_key, value in pairs(card.edition or {}) do
            if value and porkify_key(edition_key) then used = true end
        end
    end
    if used then G.GAME.porkify_content_used = true end
end

local function owned_card(card)
    if card.added_to_deck then return true end
    if card.area and (card.area == G.jokers or card.area == G.consumeables
        or card.area == G.hand or card.area == G.deck or card.area == G.discard or card.area == G.play) then return true end
    for _, owned in ipairs(G.playing_cards or {}) do if owned == card then return true end end
    return false
end

local function favorite_destruction(card)
    return in_run() and not starting_run and not G.in_delete_run
        and SMODS.is_playing_card(card) and owned_card(card)
        and card.ability and (card.ability.porkify_favorite or card.ability.favorite)
end

local function deck_key()
    local back = G.GAME.selected_back
    return G.GAME.selected_back_key or (back and back.effect and back.effect.center and back.effect.center.key)
end

local function track_inventory()
    for _, area in ipairs({ G.jokers or {}, G.consumeables or {} }) do
        for _, card in ipairs(area.cards or {}) do track_card(card) end
    end
    for id, used in pairs(G.GAME.used_vouchers or {}) do
        if used and porkify_key(id) then G.GAME.porkify_content_used = true end
    end
    local stake = G.P_CENTER_POOLS and G.P_CENTER_POOLS.Stake and G.P_CENTER_POOLS.Stake[G.GAME.stake]
    if porkify_key(deck_key()) or (stake and porkify_key(stake.key)) then G.GAME.porkify_content_used = true end
    for _, index in ipairs(G.GAME.applied_stakes or {}) do
        local applied = G.P_CENTER_POOLS and G.P_CENTER_POOLS.Stake and G.P_CENTER_POOLS.Stake[index]
        if applied and porkify_key(applied.key) then G.GAME.porkify_content_used = true end
    end
    for _, tag in ipairs(G.GAME.tags or {}) do
        if porkify_key(tag.key) then G.GAME.porkify_content_used = true end
    end
end

local function entire_deck(cards)
    local yes = SMODS.PokerHands.porkify_yes
    return yes and next(yes.evaluate({}, cards)) ~= nil
end

local function inventory()
    local counts, total, food = {}, 0, 0
    for _, card in ipairs(G.jokers and G.jokers.cards or {}) do
        local id = key(card)
        if id and not card.getting_sliced and (card.dissolve == nil or card.dissolve == 0)
            and not card.shattered and not card.destroyed and not card.removed then
            counts[id] = (counts[id] or 0) + 1
            total = total + 1
            if PORKIFY_FOOD_JOKERS[id] then food = food + 1 end
        end
    end
    return { counts = counts, total = total, food = food }
end

local function owns(args, id, amount)
    return ((args.porkify_inventory or {}).counts or {})[id] ~= nil
        and args.porkify_inventory.counts[id] >= (amount or 1)
end

local straight_hands = {
    'Straight', 'Straight Flush',
    'porkify_straighter', 'porkify_straightest', 'porkify_straighterest',
    'porkify_straighter_flush', 'porkify_straightest_flush', 'porkify_straighterest_flush',
}

local function played_straight()
    if G.GAME.porkify_played_straight then return true end
    -- Also honor recorded hand history when loading a run started before this feature.
    for _, name in ipairs(straight_hands) do
        local hand = (G.GAME.hands or {})[name]
        if hand and (hand.played or 0) > 0 then return true end
    end
    return false
end

local function register(id, name, description, condition)
    SMODS.Achievement {
        key = id,
        hidden_name = false,
        hidden_text = false,
        -- Only waive Unlock All restrictions when explicitly enabled in config.
        bypass_all_unlocked = SMODS.current_mod and SMODS.current_mod.config
            and SMODS.current_mod.config.bypass_unlock_all == true or false,
        loc_txt = { name = name, description = description },
        unlock_condition = function(self, args)
            return (in_run() or id == 'supporter') and condition(args) or false
        end,
    }
end

register('angry_cat', '>:3', 'Sell or destroy a :3 Joker', function(args)
    return (args.type == 'porkify_sold' or args.type == 'porkify_destroyed') and args.porkify_key == 'j_porkify__3'
end)
register('porkylive', 'PorkyLIVE!', 'Obtain a Porky Joker', function(args)
    return owns(args, 'j_porkify_porky')
end)
register('farewell', 'Farewell', 'Sell a Porky Joker', function(args)
    return args.type == 'porkify_sold' and args.porkify_key == 'j_porkify_porky'
end)
register('extremely_picky', 'Extremely Picky', 'Win a run with a Loading... Joker', function(args)
    return args.type == 'win' and owns(args, 'j_porkify_loading')
end)
register('big_bang', 'The Big Bang', 'Reach Ante 0', function(args)
    return G.GAME.round_resets and G.GAME.round_resets.ante == 0
end)
register('mis_input', 'Mis-input', 'Play a Glass or Mirror card alongside another card with a Dice Seal', function(args)
    return args.type == 'hand_contents' and args.porkify_mis_input
end)
register('see_you_again', 'See You Again', 'Have a Paul Joker die', function(args)
    return args.type == 'porkify_paul_died'
end)
register('one_for_paul', 'One for Paul, Paul for All', 'Have 10 Paul Jokers at once', function(args)
    return owns(args, 'j_porkify_paul', 10)
end)
register('hrt', 'HRT', 'Let a card undergo Hormone Replacement Therapy', function(args)
    return args.type == 'porkify_consumable' and
        (args.porkify_key == 'c_porkify_estrogen' or args.porkify_key == 'c_porkify_testosterone')
end)
register('supermarket', 'Supermarket', 'Have 5 Food Jokers at once', function(args)
    return args.porkify_inventory and args.porkify_inventory.food >= 5
end)
register('into_the_unknown', 'Into the Unknown', 'Play any secret Porkify poker hand', function(args)
    return args.type == 'hand' and PORKIFY_SECRET_HANDS[args.handname]
end)
register('built_different', 'Built Different', 'Play a Bulwark containing Stone, Meteor, Exclaim and Mimic cards', function(args)
    if args.type ~= 'hand' or args.handname ~= 'porkify_bulwark' then return false end
    for _, enhancement in ipairs({ 'm_stone', 'm_porkify_meteor', 'm_porkify_exclaim', 'm_porkify_mimic' }) do
        local found = false
        for _, card in ipairs(args.full_hand or {}) do
            if SMODS.has_enhancement(card, enhancement) then found = true; break end
        end
        if not found then return false end
    end
    return true
end)
register('grow_up', 'Grow Up!', "You're better than this", function(args)
    return args.type == 'hand_contents' and args.porkify_grow_up
end)
register('rules_for_thee', 'Rules for Thee...', 'Use Excalibur, Freezer or Mortgage on a Joker', function(args)
    return args.type == 'porkify_joker_sticker_removed'
end)
register('how', 'How?', 'Play your entire deck in one hand', function(args)
    return args.type == 'hand' and args.handname == 'porkify_yes'
end)
register('why', 'WHY?', "My expectations were low but, c'mon, really?", function(args)
    return args.type == 'discard_custom' and args.porkify_entire_deck
end)
register('the_matrix', 'The Matrix', 'Have a Glitch Joker create another Glitch Joker', function(args)
    return args.type == 'porkify_glitch_created' and args.porkify_key == 'j_porkify_glitch'
end)
register('gay', 'Gay', 'Win a run without playing any hand containing a Straight', function(args)
    return args.type == 'win' and not played_straight()
end)
register('fire_fest', 'Fire Fest', 'Have Astronomer, Cardception and Liquidation at the same time', function(args)
    return owns(args, 'j_astronomer') and owns(args, 'j_porkify_cardception')
        and G.GAME.used_vouchers and G.GAME.used_vouchers.v_liquidation
end)
register('cops_and_robbers', "Cops 'n Robbers", 'Have both the Burglar and Bobby Jokers at once', function(args)
    return owns(args, 'j_burglar') and owns(args, 'j_porkify_bobby')
end)
register('no_death_coin', 'No Death Coin', 'Win a run with Encore as your only Joker', function(args)
    return args.type == 'win' and owns(args, 'j_porkify_encore') and args.porkify_inventory.total == 1
end)
register('three_man_army', 'Three Man Army', 'Have Hatched Egg, Paul and Mallard Jokers at once', function(args)
    return owns(args, 'j_porkify_hatchedegg') and owns(args, 'j_porkify_paul') and owns(args, 'j_porkify_mallard')
end)

local function current_stake()
    return G.P_CENTER_POOLS and G.P_CENTER_POOLS.Stake and G.P_CENTER_POOLS.Stake[G.GAME.stake]
end

register('bffs', 'BFFs!', 'Win a run with a companion by your side', function(args)
    return args.type == 'win' and owns(args, 'j_porkify_kitty')
end)
register('better_than_the_creator', 'Better Than The Creator', 'Beat Onyx Stake', function(args)
    local stake = current_stake()
    return args.type == 'win' and stake and stake.key == 'stake_porkify_stake_onyx'
end)
register('showoff', 'Showoff', 'Beat Topaz Stake', function(args)
    local stake = current_stake()
    return args.type == 'win' and stake and stake.key == 'stake_porkify_stake_topaz'
end)

local start_run_ref = Game.start_run
function Game:start_run(args)
    local is_new_run = not (args and args.savetext)
    starting_run = true
    local result = start_run_ref(self, args)
    starting_run = false
    if is_new_run then
        G.GAME.porkify_content_tracked = true
        check_for_unlock { type = 'porkify_run_started' }
    end
    return result
end

register('laaaaaame', 'Laaaaaame!', 'Win without using the mod', function(args)
    return args.type == 'win' and G.GAME.porkify_content_tracked and not G.GAME.porkify_content_used
end)
register('monkey_kingdom', 'Monkey Kingdom', 'Have 5 Gros Michel or Cavendish Jokers at once, in any combination', function(args)
    local counts = args.porkify_inventory and args.porkify_inventory.counts or {}
    return (counts.j_gros_michel or 0) + (counts.j_cavendish or 0) >= 5
end)
register('huge_fan', 'Huge Fan', 'Win Pink Stake on Porkify Deck with Porky, Piggyback, a Mimic playing card, and at least one Porkify Pack opened', function(args)
    local stake = current_stake()
    if args.type ~= 'win' or not stake or stake.key ~= 'stake_porkify_stake_pink'
        or (deck_key() ~= 'b_porkify_deck' and deck_key() ~= 'b_porkify_porkify_deck') or not owns(args, 'j_porkify_porky')
        or not (G.GAME.used_vouchers or {}).v_porkify_piggyback
        or not G.GAME.porkify_pack_opened then return false end
    for _, card in ipairs(G.playing_cards or {}) do
        if SMODS.has_enhancement(card, 'm_porkify_mimic') then return true end
    end
    return false
end)
register('impressed_and_disappointed', "I'm impressed and disappointed", 'Lose to the Ante 1 Small Blind', function(args)
    return args.type == 'porkify_lost' and args.ante == 1 and args.blind_type == 'Small'
end)
register('first_time', 'First Time?', 'Lose to the Ante 2 Big Blind', function(args)
    return args.type == 'porkify_lost' and args.ante == 2 and args.blind_type == 'Big'
end)
register('electric_boogaloo', 'Electric Boogaloo', 'Obtain Joker 2', function(args)
    return owns(args, 'j_porkify_joker2')
end)
register('my_pc', 'MY PCCC-C-C-C-C!', 'Attempt to let your PC catch fire', function(args)
    return args.type == 'porkify_too_many_blanks_selected'
end)
register('man_in_black', 'Man In Black', 'Play 5 Kings of Spades in a single hand', function(args)
    if args.type ~= 'hand_contents' then return false end
    local kings = 0
    for _, card in ipairs(args.cards or {}) do
        local base = card.base or {}
        if not SMODS.has_no_rank(card) and not SMODS.has_no_suit(card)
            and base.id == 13 and base.suit == 'Spades' then kings = kings + 1 end
    end
    return kings >= 5
end)
register('unwanted_favorite', "I don't want to play with you anymore", 'Destroy a playing card with a Favorite Sticker', function(args)
    return args.type == 'porkify_favorite_destroyed'
end)
register('necromancer', 'Necromancer', 'Use Freezer on a Joker debuffed by an expired Perishable Sticker', function(args)
    return args.type == 'porkify_freezer_revived'
end)
register('soviet_red', 'Soviet Red is the new Black', 'Have only Hearts in your deck, with no Kings or Queens', function(args)
    if starting_run or G.in_delete_run then return false end
    local has_heart = false
    for _, card in ipairs(G.playing_cards or {}) do
        local no_rank, no_suit = SMODS.has_no_rank(card), SMODS.has_no_suit(card)
        if not (no_rank and no_suit) then
            -- Check printed suit/rank: Wild Cards and Blank Seals cannot hide an ineligible card.
            local base = card.base or {}
            if no_suit or base.suit ~= 'Hearts' then return false end
            if not no_rank and (base.id == 12 or base.id == 13) then return false end
            has_heart = true
        end
    end
    return has_heart
end)

register('ghost_busters', 'Ghost Busters', 'Destroy a Phantom Joker', function(args)
    return args.type == 'porkify_destroyed' and args.porkify_key == 'j_porkify_phantom'
end)
register('through_your_teeth', "I'll put it through your teeth!", 'Technoblade Reference', function(args)
    return args.type == 'porkify_pickaxe_mimic'
end)
register('heartless', 'Heartless', 'Sell or destroy a Kitty Joker', function(args)
    return (args.type == 'porkify_sold' or args.type == 'porkify_destroyed') and args.porkify_key == 'j_porkify_kitty'
end)
register('the_ally', 'The Ally', 'Represent the LGBTQ+ community', function(args)
    for _, id in ipairs({ 'j_porkify_acejoker', 'j_porkify_pridebanner', 'j_porkify_prideful_joker', 'j_porkify_transjoker' }) do
        if not owns(args, id) then return false end
    end
    local consumables = {}
    for _, card in ipairs(G.consumeables and G.consumeables.cards or {}) do
        if key(card) and not card.getting_sliced and not card.removed then consumables[key(card)] = true end
    end
    return consumables.c_porkify_estrogen and consumables.c_porkify_testosterone and consumables.c_porkify_rainbow
end)
register('supporter', 'Supporter', 'Check out the Credits screen. Like, really check it out', function(args)
    local profile = G.PROFILES and G.SETTINGS and G.PROFILES[G.SETTINGS.profile]
    local clicks = profile and profile.porkify_credits_clicked or {}
    return args.type == 'porkify_credits_clicked' and clicks.bluesky and clicks.twitter and clicks.github
end)
register('thats_illegal', "That's Illegal", 'Have more than 0 Consumable Slots on Jimbo Deck', function(args)
    return not starting_run and deck_key() == 'b_porkify_jimbo_deck' and G.consumeables
        and to_big(G.consumeables.config.card_limit) > to_big(0)
end)
register('rip_off', 'What a Rip-off!', 'Skip a Void Voucher Pack', function(args)
    return args.type == 'porkify_skip_void'
end)
register('it_echoes', 'It Echoes in here', 'Have an Echo Seal retrigger its maximum number of times', function(args)
    return args.type == 'porkify_echo_max'
end)
register('see_a_doctor', 'Maybe see a doctor', 'Own 5 Jokers with Cramped stickers at once', function(args)
    local count = 0
    for _, card in ipairs(G.jokers and G.jokers.cards or {}) do
        if not card.getting_sliced and not card.removed and card.ability
            and (card.ability.cramped or card.ability.porkify_cramped) then count = count + 1 end
    end
    return count >= 5
end)
register('weimar_republic', 'Weimar Republic', 'Trigger a Gilded card with Money Tree and at least $100', function(args)
    return args.type == 'porkify_gilded_trigger' and G.GAME.used_vouchers.v_money_tree
        and to_big(args.dollars or 0) >= to_big(100)
end)
register('meltdown', 'Meltdown', 'Have an Ionized card give less than X1 Mult', function(args)
    return args.type == 'porkify_ionized_trigger' and to_big(args.x_mult) < to_big(1)
end)
register('collector', 'Collector', 'Hold Steel, Gold, Emerald and Diamond cards at the same time', function(args)
    for _, enhancement in ipairs({ 'm_steel', 'm_gold', 'm_porkify_emerald', 'm_porkify_diamond' }) do
        local found = false
        for _, card in ipairs(G.hand and G.hand.cards or {}) do
            if SMODS.has_enhancement(card, enhancement) then found = true; break end
        end
        if not found then return false end
    end
    return true
end)
register('twenty_is_twenty', '$20 is $20', 'Have Cleptomane pay out $20 or more', function(args)
    return args.type == 'porkify_cleptomane_paid' and to_big(args.dollars) >= to_big(20)
end)

local function is_grow_up_hand(cards)
    local ranked = {}
    for i, card in ipairs(cards) do
        local seal = card.seal or (card.ability and card.ability.seal)
        if seal == 'porkify_blank' or seal == 'blank' then return false end
        if not (SMODS.has_no_rank(card) and SMODS.has_no_suit(card)) then
            ranked[#ranked + 1] = { index = i, rank = card:get_id() }
            if #ranked > 2 then return false end
        end
    end
    return #ranked == 2
        and ranked[1].rank == 6
        and (ranked[2].rank == 7 or ranked[2].rank == 9)
        and ranked[2].index == ranked[1].index + 1
end

local function played_cards(args)
    local cards = args.cards or {}
    for _, card in ipairs(cards) do track_card(card, true) end
    local results = evaluate_poker_hand(cards)
    if has_result(results, 'Straight') or has_result(results, 'Straight Flush') then
        G.GAME.porkify_played_straight = true
    end
    local fragile, dice = {}, {}
    for _, card in ipairs(cards) do
        if SMODS.has_enhancement(card, 'm_glass') or SMODS.has_enhancement(card, 'm_porkify_mirror') then
            fragile[#fragile + 1] = card
        end
        if card.seal == 'porkify_dice' then dice[#dice + 1] = card end
    end
    args.porkify_grow_up = is_grow_up_hand(cards)
    for _, glass in ipairs(fragile) do
        for _, die in ipairs(dice) do
            if glass ~= die then args.porkify_mis_input = true end
        end
    end
end

-- Snapshot before discard effects can destroy cards or change the deck.
local pending_discard
local check_for_unlock_ref = check_for_unlock
function check_for_unlock(args)
    if in_run() then
        track_inventory()
        if args.type == 'hand' and porkify_key(args.handname) then G.GAME.porkify_content_used = true end
        if args.type == 'hand_contents' then played_cards(args) end
        if args.type == 'discard_custom' then
            local cards = args.cards or {}
            local match = pending_discard and #cards == #pending_discard
            local members = {}
            for _, card in ipairs(pending_discard or {}) do members[card] = true end
            for _, card in ipairs(cards) do
                if not members[card] then match = false end
                members[card] = nil
            end
            args.porkify_entire_deck = not not match
            pending_discard = nil
        end
        args.porkify_inventory = inventory()
    end
    return check_for_unlock_ref(args)
end

local calculate_context_ref = SMODS.calculate_context
function SMODS.calculate_context(context, ...)
    if in_run() then
        if context.skipping_booster and context.booster and context.booster.key == 'p_porkify_void_voucher_pack' then
            check_for_unlock { type = 'porkify_skip_void' }
        end
        if context.open_booster then
            local id = key(context.card)
            if porkify_key(id) then G.GAME.porkify_content_used = true end
            if id == 'p_porkify_tiny_porkify_pack' or id == 'p_porkify_pack' or id == 'p_porkify_porkify_pack'
                or id == 'p_porkify_jumbo_porkify_pack' or id == 'p_porkify_mega_porkify_pack' then
                G.GAME.porkify_pack_opened = true
            end
        end
        if context.card_added or context.buying_card or context.selling_card then track_card(context.card) end
        if context.using_consumeable then track_card(context.consumeable) end
        if context.pre_discard then
            pending_discard = nil
            local cards = context.full_hand or {}
            if entire_deck(cards) then
                pending_discard = {}
                for i, card in ipairs(cards) do pending_discard[i] = card end
            end
        elseif context.selling_card then
            if context.card then context.card.porkify_being_sold = true end
            check_for_unlock { type = 'porkify_sold', porkify_key = key(context.card) }
        elseif context.using_consumeable then
            check_for_unlock { type = 'porkify_consumable', porkify_key = key(context.consumeable) }
        end
    end
    return calculate_context_ref(context, ...)
end

-- Observe ownership and changes immediately, including content removed before the next hand.
for _, method in ipairs({ 'add_to_deck', 'set_ability', 'set_seal', 'set_edition', 'use_consumeable' }) do
    local original = Card[method]
    Card[method] = function(self, ...)
        if in_run() and (owned_card(self) or method == 'use_consumeable') then track_card(self) end
        local result = original(self, ...)
        if in_run() and (owned_card(self) or method == 'use_consumeable') then track_card(self) end
        return result
    end
end

local emplace_ref = CardArea.emplace
function CardArea:emplace(card, ...)
    local result = emplace_ref(self, card, ...)
    if in_run() and owned_card(card) then
        track_card(card)
        check_for_unlock { type = 'porkify_inventory_changed' }
    end
    return result
end

local remove_card_ref = Card.remove
function Card:remove(...)
    local check_deck = in_run() and not starting_run and not G.in_delete_run
        and not self.porkify_config_preview and SMODS.is_playing_card(self)
    local result = remove_card_ref(self, ...)
    if check_deck then check_for_unlock { type = 'modify_deck' } end
    return result
end

local add_tag_ref = add_tag
function add_tag(tag, ...)
    if in_run() and porkify_key(tag.key) then G.GAME.porkify_content_used = true end
    return add_tag_ref(tag, ...)
end

local parse_highlighted_ref = CardArea.parse_highlighted
function CardArea:parse_highlighted(...)
    local result = parse_highlighted_ref(self, ...)
    if in_run() and self == G.hand and G.STATE == G.STATES.SELECTING_HAND
        and not (porkify_blank_limit_disabled and porkify_blank_limit_disabled()) then
        local blanks = 0
        for _, card in ipairs(self.highlighted or {}) do
            local seal = card.seal or (card.ability and card.ability.seal)
            if seal == 'porkify_blank' or seal == 'blank' then blanks = blanks + 1 end
        end
        if blanks > 2 then
            local eval = evaluate_poker_hand(self.highlighted)
            if has_result(eval, PORKIFY_TOO_MANY_BLANKS_HAND_KEY or 'porkify_too_many_blanks') then
                check_for_unlock { type = 'porkify_too_many_blanks_selected' }
            end
        end
    end
    return result
end

local game_over_ref = Game.update_game_over
function Game:update_game_over(...)
    if in_run() and G.STATE == G.STATES.GAME_OVER and not G.GAME.porkify_loss_checked then
        G.GAME.porkify_loss_checked = true
        check_for_unlock {
            type = 'porkify_lost', ante = G.GAME.round_resets.ante,
            blind_type = G.GAME.blind and G.GAME.blind:get_type(),
        }
    end
    return game_over_ref(self, ...)
end

-- Destruction checks run after the method, so a prevented destruction does not count.
for _, method in ipairs({ 'start_dissolve', 'shatter' }) do
    local original = Card[method]
    Card[method] = function(self, ...)
        local id = key(self)
        local eligible = in_run() and not starting_run and not G.in_delete_run
            and (id == 'j_porkify__3' or id == 'j_porkify_phantom' or id == 'j_porkify_kitty')
            and not self.porkify_being_sold and not self.porkify_destruction_checked
            and (self.added_to_deck or self.area == G.jokers)
            and (self.dissolve == nil or self.dissolve == 0)
        local favorite = favorite_destruction(self) and self.dissolve == nil
        local result = original(self, ...)
        if favorite and result ~= false and self.dissolve ~= nil then
            check_for_unlock { type = 'porkify_favorite_destroyed' }
        end
        if eligible and result ~= false and self.dissolve ~= nil then
            self.porkify_destruction_checked = true
            check_for_unlock { type = 'porkify_destroyed', porkify_key = id }
        end
        return result
    end
end

local pinch_and_remove_ref = SMODS.pinch_and_remove
function SMODS.pinch_and_remove(card, ...)
    local id = key(card)
    local eligible = in_run() and not starting_run and not G.in_delete_run
        and (id == 'j_porkify__3' or id == 'j_porkify_phantom' or id == 'j_porkify_kitty')
        and not card.porkify_being_sold and not card.porkify_destruction_checked
        and (card.added_to_deck or card.area == G.jokers)
    local favorite = favorite_destruction(card)
    local result = pinch_and_remove_ref(card, ...)
    if favorite and result then check_for_unlock { type = 'porkify_favorite_destroyed' } end
    if eligible and result then
        card.porkify_destruction_checked = true
        check_for_unlock { type = 'porkify_destroyed', porkify_key = id }
    end
    return result
end

local ease_ante_ref = ease_ante
function ease_ante(...)
    local result = ease_ante_ref(...)
    -- ease_ante changes the actual Ante inside an immediate event.
    G.E_MANAGER:add_event(Event({ trigger = 'immediate', func = function()
        if in_run() then check_for_unlock { type = 'porkify_ante_changed' } end
        return true
    end }))
    return result
end
