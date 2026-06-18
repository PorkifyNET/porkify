SMODS.Joker{ --67
    key = "_67",
    config = {
        extra = {
            chips = 6,
            mult = 7
        }
    },
    loc_txt = {
        ['name'] = '67',
        ['text'] = {
            [1] = 'Every played {C:attention}6{}',
            [2] = ' or {C:attention}7{} grants',
            [3] = '{C:blue}+6{} Chips and',
            [4] = '{C:red}+7{} Mult'
        },
        ['unlock'] = {
            [1] = 'Play a {C:attention}6{} and a {C:attention}7{} in the same hand'
        }
    },
    pos = {
        x = 8,
        y = 6
    },
    display_size = {
        w = 71,
        h = 95
    },
    cost = 6,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'CustomJokers',
    pools = { ["modprefix_porkify_jokers"] = true },
    credit_badges = {
        { text = "Idea: Crystal Sirens", colour = "541CBF" }
     },

    check_for_unlock = function(self, args)
        if args.type ~= 'hand_contents' or not args.cards then
            return false
        end

        local has_six = false
        local has_seven = false

        for _, c in ipairs(args.cards) do
            if c and c.get_id then
                local id = c:get_id()
                if id == 6 then
                    has_six = true
                elseif id == 7 then
                    has_seven = true
                end
            end

            if has_six and has_seven then
                return true
            end
        end

        return false
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card and context.other_card.get_id then
            local id = context.other_card:get_id()
            if id == 6 or id == 7 then
                local extra = card.ability.extra or {}
                return {
                    chips = extra.chips or 6,
                    mult = extra.mult or 7
                }
            end
        end
    end,

    joker_display_def = function(JokerDisplay)
      ---@type JDJokerDefinition
      return {
        text = {
          { ref_table = "card.joker_display_values", ref_value = "chips_text", colour = G.C.BLUE, retrigger_type = "mult" },
          { text = " " },
          { ref_table = "card.joker_display_values", ref_value = "mult_text", colour = G.C.RED, retrigger_type = "mult" }
        },
        reminder_text = {
            { text = "(6, 7)", colour = G.C.GREY }
        },

        calc_function = function(card)
          local extra = (card.ability and card.ability.extra) or {}
          local chips_per = extra.chips or 6
          local mult_per = extra.mult or 7
          local hits = 0

          local text, _, scoring_hand = JokerDisplay.evaluate_hand()

          if text ~= 'Unknown' and scoring_hand then
            for _, playing_card in pairs(scoring_hand) do
              if playing_card
                and playing_card.get_id
                and not playing_card.debuff
                and playing_card.facing ~= 'back' then
                local id = playing_card:get_id()
                if id == 6 or id == 7 then
                  hits = hits + JokerDisplay.calculate_card_triggers(playing_card, scoring_hand)
                end
              end
            end
          end

          card.joker_display_values.chips_text = "+" .. tostring(hits * chips_per)
          card.joker_display_values.mult_text = "+" .. tostring(hits * mult_per)
        end
      }
    end
}
