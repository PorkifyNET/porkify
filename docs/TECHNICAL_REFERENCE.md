# Porkify Technical Reference

This document contains behavioral details and developer notes that are useful
for debugging and compatibility work but too specific for the main README.

## Secret Poker Hands

Porkify defines 22 secret poker hands in `poker_hands.lua`: Three Pair, Four
Pair, Straighter, Straightest, Straighterest, their Flush variants, Fuller
House, Fullest House, Six/Seven/Eight of a Kind, Flush Six/Seven/Eight,
Bulwark, and Yes. Their base Chips, Mult, and per-level gains are defined there.

Flushier, Flushiest, and Flushiester require six, seven, and eight cards sharing
a suit. Two By Fours requires two groups of four matching ranks. The extended
Straight Flushes are named Straighter Flushier, Straightest Flushiest, and
Straighterest Flushiester; their existing save keys are retained.

Pairs and Three of a Kinds in composite hands must have distinct ranks.
Extended straights require six, seven, or eight ranks even with Four Fingers,
and support Shortcut and straight-wrap effects. Flush variants require the
qualifying cards to share a suit, including Wild Card behavior. Bulwark requires
at least five played cards, all without a suit or rank. Yes requires every card
in the current deck to be played together and takes priority over other hands.

Prideful debuffs all extended Straights and Straight Flushes. Plunger debuffs
the extended Flushes, Straight Flushes, and Flush Six/Seven/Eight. Twins debuffs
the extended pairs, houses, matching-rank hands, Two By Fours, and Flush
Six/Seven/Eight, as well as vanilla Flush House.

## Achievement Notes

`achievements.lua` registers 36 achievements through Steamodded's Achievement
API. Names and descriptions are visible before unlocking. Unlocks use normal
Steamodded persistence and eligibility settings, except that Unlock All profiles
may still earn Porkify achievements by meeting their conditions.

- **Built Different:** Score Bulwark with at least one Stone, Meteor, Exclaim,
  and Mimic card.
- **Man In Black:** Play at least five actual Kings of Spades together.
- **I don't want to play with you anymore:** Successfully destroy an owned
  Favorite playing card.
- **Necromancer:** Use Freezer on a target debuffed by an expired Perishable
  timer.
- **Soviet Red is the new Black:** The current deck must contain printed Hearts,
  no Kings or Queens, and at least one qualifying Heart. Rankless and suitless
  cards are ignored.
- **Monkey Kingdom:** Own any mix of at least five Gros Michels and Cavendishes.
- **Huge Fan:** Win on Pink Stake with Porkify Deck, Porky, Piggyback, a Mimic
  playing card, and a previously opened Porkify Pack.
- **Electric Boogaloo:** Own Joker 2.
- **MY PCCC-C-C-C-C!:** Produce Too Many Blanks! with more than two Blank Seals
  during hand selection.
- **Once More Unto The Breach:** Start a run above Gold Stake.
- **Better Than The Creator / Showoff:** Win with Onyx / Topaz as the selected
  Stake.
- **Grow Up!:** Play exactly two ranked cards, a 6 immediately followed by a 7
  or 9. Rankless and suitless cards may surround but not separate them; Blank
  Seals disqualify the hand.
- **Mis-input:** Requires two distinct cards.
- **No Death Coin:** Win while exactly one Encore is the only owned Joker.
- **See You Again:** Paul must die through his end-of-round effect; selling him
  does not count.

**Laaaaaame!** forbids owning Porkify Jokers, Consumables, or Tags; owning
Jokers with Porkify Editions; using Porkify Consumables; redeeming its Vouchers;
opening its Packs; using its Decks or Stakes; or playing its poker hands.
Porkify properties may exist on playing cards, but playing those cards
disqualifies the run. Merely seeing content in a shop or pack does not. The run
must begin with tracking enabled, and saved disqualifications are permanent.

Straight-containing plays are tracked in the saved run, including Straight
Flushes and hands scored as a higher poker hand. Older saves fall back to their
recorded Straight and Straight Flush counts.

## Multiplayer Compatibility

Porkify registers its compatibility data when Balatro Multiplayer is installed;
Multiplayer remains optional.

The following content is banned:

- Jokers: Rewind and Swoon
- Consumables: Emergency Exit, Time Machine, Training Wheels, and Tranquilizer
- Vouchers: Pattern and Tesselation

These Porkify bans do not apply to the Survival gamemode or the Vanilla
ruleset. Their Banned screens omit Porkify's entries as well.

The first six effects can end or disable a live PvP Blind, alter its target, or
rewind the Ante. Pattern and Tesselation depend on usage statistics from each
player's local profile rather than match state.

The following content is marked as reworked and receives Multiplayer's Balanced
sticker:

- Headstart does not apply against a Nemesis Blind.
- Casual Walk cannot roll its four Blind Size modifiers in Multiplayer.

Loading only selects Jokers allowed by the active pool, ban list, and ruleset.
Random gameplay pools are seeded and consistently ordered. Gameplay-affecting
Porkify configuration is included in Multiplayer's session hash; cosmetic
settings are excluded.

Both players should use fully unlocked profiles. Multiplayer distinguishes a
fully unlocked profile from an incomplete one, but does not hash the exact
unlock set of two partially unlocked profiles.

## Additional Boss Effects

- **Landlord:** Adds Rental to a random eligible Joker on each play.
- **Virus / Stapler:** Each play has a base 1-in-2 chance to add Perishable /
  Eternal to an eligible Joker. Probability modifiers and sticker
  incompatibilities are respected.
- **Bully:** Requires Magnet and snapshots Favorite cards when selected.
  Disabling or defeating it removes its debuffs.
- **Eco-Warrior / Scientist:** Divide final Mult by remaining Discards / the
  current level of the scored poker hand, with a minimum divisor of one.
- **Wipe:** Permanently removes enhancements from played cards before hand
  evaluation and scoring. Held cards, Seals, and Editions are preserved.
- **ERROR:** Rolls and saves its requirement and reward independently. Both are
  within 30%-130% of normal; rewards use whole dollars.
- **Tax:** Draws cards face down while money meets or exceeds the current
  interest cap. Disabling it reveals cards already in hand.

These Blinds currently reuse existing Blind sprites.

## Testing

Run the test harness against a local Balatro installation with Steamodded and a
Lovely patched source dump:

```text
python tests/run_poker_hands.py [path/to/Balatro/lua51.dll]
```

The harness covers poker-hand evaluation, registrations, achievement conditions,
runtime hooks, and selected card, sticker, and Boss Blind interactions. Focused
Multiplayer compatibility tests are stored alongside it in `tests/`.
