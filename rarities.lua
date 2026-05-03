SMODS.Rarity {
    key = "ruleset",
    pools = {
        ["Joker"] = true
    },
    default_weight = 0,
    badge_colour = HEX('d0021b'),
    loc_txt = {
        name = "Ruleset"
    },
    get_weight = function(self, weight, object_type)
        return weight
    end,
}