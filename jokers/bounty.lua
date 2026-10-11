local PORKIFY_BOUNTY_RANKS = {
    2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14
}

local function porkify_bounty_rank_label(rank)
    local labels = {
        [11] = "Jack",
        [12] = "Queen",
        [13] = "King",
        [14] = "Ace"
    }

    return labels[rank] or tostring(rank or 2)
end

local function porkify_bounty_pick_rank(ante)
    local index = tonumber(ante) or 0
    return pseudorandom_element(
        PORKIFY_BOUNTY_RANKS,
        pseudoseed("porkify_bounty_" .. tostring(index))
    ) or 2
end

local function porkify_bounty_current_ante()
    return tonumber(G and G.GAME and G.GAME.round_resets and G.GAME.round_resets.ante) or 0
end

local function porkify_bounty_sync_ante(card, ante_override)
    local extra = card and card.ability and card.ability.extra
    if not extra then return false end

    local ante = tonumber(ante_override) or porkify_bounty_current_ante()
    if extra.target_ante == ante and extra.target_rank then return false end

    extra.target_ante = ante
    extra.target_rank = porkify_bounty_pick_rank(ante)
    return true
end

SMODS.Joker{ -- Bounty
    key = "bounty",
    config = {
        extra = {
            dollars = 2,
            pending_payout = 0,
            reset_after_payout = false
        }
    },
    loc_txt = {
        ["name"] = "Bounty",
        ["text"] = {
            [1] = "Earn {C:money}$#2#{} at end of round",
            [2] = "for each {C:attention}#1#{}",
            [3] = "scored this {C:attention}Ante{}",
            [4] = "{s:0.75}Rank changes each Ante{}",
            [5] = "{C:inactive}(Currently {C:money}$#3#{C:inactive})",
        }
    },
    pos = { x = 3, y = 9 },
    display_size = { w = 71, h = 95 },
    cost = 6,
    rarity = 2,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = false,
    unlocked = true,
    discovered = false,
    atlas = "CustomJokers",
    pools = { ["modprefix_porkify_jokers"] = true },

    loc_vars = function(self, info_queue, card)
        local extra = (card and card.ability and card.ability.extra) or self.config.extra
        if card and (not extra.target_rank or extra.target_ante == nil)
            and porkify_bounty_sync_ante(card) then
            extra.pending_payout = 0
        end
        return {
            vars = {
                porkify_bounty_rank_label(extra.target_rank or porkify_bounty_pick_rank(
                    porkify_bounty_current_ante()
                )),
                extra.dollars or 2,
                extra.pending_payout or 0
            }
        }
    end,

    set_ability = function(self, card, initial)
        card.ability.extra = card.ability.extra or {}
        porkify_bounty_sync_ante(card)
    end,

    calculate = function(self, card, context)
        local extra = card.ability.extra

        local changed_ante
        if context.ante_change and not context.blueprint then
            changed_ante = porkify_bounty_current_ante() + (tonumber(context.ante_change) or 0)
        end

        if changed_ante and not context.blueprint then
            if porkify_bounty_sync_ante(card, changed_ante) then
                -- Ante changes before Boss Blind round evaluation. Preserve
                -- the old Ante's bank until calc_dollar_bonus pays it out.
                extra.reset_after_payout = true
                return {
                    message = porkify_bounty_rank_label(extra.target_rank) .. "!",
                    colour = G.C.IMPORTANT
                }
            end
        elseif context.setting_blind and not context.blueprint then
            local changed = porkify_bounty_sync_ante(card)
            if changed or extra.reset_after_payout then
                -- If Bounty was debuffed during round evaluation, its dollar
                -- callback was skipped; discard the stale bank before play.
                extra.pending_payout = 0
                extra.reset_after_payout = false
            end
            if changed then
                return {
                    message = porkify_bounty_rank_label(extra.target_rank) .. "!",
                    colour = G.C.IMPORTANT
                }
            end
        end

        if context.individual and context.cardarea == G.play and not context.blueprint then
            if porkify_bounty_sync_ante(card) then
                extra.pending_payout = 0
            end
            local played_card = context.other_card
            if played_card and not played_card.debuff
                and porkify_card_matches_rank(played_card, extra.target_rank or 2) then
                extra.pending_payout = (extra.pending_payout or 0) + (extra.dollars or 2)
                return {
                    message = "+$" .. tostring(extra.dollars or 2),
                    colour = G.C.MONEY
                }
            end
        end
    end,

    calc_dollar_bonus = function(self, card)
        local extra = card.ability.extra
        local payout = tonumber(extra.pending_payout) or 0
        if extra.reset_after_payout then
            extra.pending_payout = 0
            extra.reset_after_payout = false
        end
        if payout > 0 then return payout end
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { ref_table = "card.joker_display_values", ref_value = "payout_text", colour = G.C.MONEY, retrigger_type = "mult" }
            },
            reminder_text = {
                { text = "(" },
                { ref_table = "card.joker_display_values", ref_value = "rank_text", colour = G.C.IMPORTANT },
                { text = ")" }
            },

            calc_function = function(card)
                local extra = (card.ability and card.ability.extra) or {}
                card.joker_display_values.payout_text = "+$" .. tostring(extra.pending_payout or 0)
                card.joker_display_values.rank_text = porkify_bounty_rank_label(extra.target_rank or 2)
            end
        }
    end
}
