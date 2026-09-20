# Porkify

Porkify is a large content mod for Balatro focused on adding more run-defining decisions without slowing the game down. It expands the game with a broad mix of custom Jokers, Consumables, decks, blinds, enhancements, editions, seals, stickers, vouchers, challenges, and custom stakes, alongside light balance changes and extra mechanics to make runs feel less predictable.

This mod requires [Steamodded](https://github.com/Steamodded/smods) `>= 1.0.0~BETA-1620a` to function properly.

## Included Content

Porkify adds a wide spread of new content across most of Balatro's systems, including:

- Custom Jokers and Consumables
- New Decks, Blinds, and Booster Packs
- Custom Enhancements, Editions, Seals, Stickers, and Vouchers
- Additional Stakes and Challenges
- 22 secret poker hands, revealed when first played
- 36 custom achievements
- Extra mechanics and balance tweaks layered into the base game

## Secret Poker Hands

Three Pair, Four Pair, Straighter, Straightest, Straighterest, their Flush variants,
Fuller House, Fullest House, Six/Seven/Eight of a Kind, Flush Six/Seven/Eight,
Bulwark, and Yes are defined in `poker_hands.lua`, including base Chips/Mult and
per-level gains. Flushier, Flushiest, and Flushiester require 6, 7, and 8 cards
sharing a suit. Two By Fours requires two groups of four matching ranks.
The extended Straight Flushes are named Straighter Flushier, Straightest
Flushiest, and Straighterest Flushiester; their existing save keys are retained.

Pairs and Three of a Kinds in composite hands must have distinct ranks. Extended
straights require 6/7/8 ranks even with Four Fingers, and support Shortcut and
straight wrap effects. Flush variants require the qualifying cards to share a
suit, including Wild Card suit behavior. Bulwark requires at least five played
cards, all without a suit or rank. Yes requires every card in the current deck
to be played together, including any cards otherwise left in hand, the draw
pile, or the discard pile, and takes priority over the other scoring hands.

Evaluator checks: run `python tests/run_poker_hands.py` on a local Balatro install
with Steamodded and Lovely's patched source dump. An optional first argument
specifies the path to Balatro's `lua51.dll`.

## Achievements

`achievements.lua` registers 36 achievements through
[Steamodded's Achievement API](https://docs.smods.dev/Game%20Objects/SMODS.Achievement/).
Names and descriptions are visible before unlocking; icons currently use the
standard achievement atlas. Unlocks use Steamodded's normal persistence and
achievement eligibility settings, except that Unlock All profiles may still earn
Porkify achievements by meeting their conditions. Seeded-run and challenge
restrictions continue to follow Steamodded's settings.

"Built Different" requires a played hand scored as Bulwark containing at least
one each of Stone, Meteor, Exclaim, and Mimic cards.

"Man In Black" requires at least five actual Kings of Spades played together.
"I don't want to play with you anymore" checks successful destruction of an
owned Favorite playing card. "Necromancer" requires Freezer's target to be
debuffed with an expired Perishable timer when Freezer is used.

"Soviet Red is the new Black" checks the entire current deck for printed Hearts
with no Kings or Queens. Cards with neither rank nor suit are ignored, including
Stone, Meteor, Exclaim, and Mimic cards. At least one qualifying Heart is required;
an empty deck or a deck consisting only of ignored cards does not qualify.

"Laaaaaame!" forbids owning Porkify Jokers, consumables or tags (even temporarily),
owning Jokers with Porkify editions, using Porkify consumables, redeeming its
vouchers, opening its packs, using its decks or Stakes, or playing its poker hands.
Playing cards with Porkify enhancements, editions or seals are allowed in the
deck and may be discarded, but playing them disqualifies the run, even if debuffed
or not scoring. Encountering Porkify Boss Blinds does not affect eligibility.
Merely seeing mod cards in a shop or pack does not disqualify the run. This
achievement requires a run started with the tracking feature enabled; older
saves cannot establish that no mod content was previously owned. Tracking is
saved with the run and survives selling cards or removing their properties after
a disqualifying action. Disqualifications already saved under older rules remain.

"Monkey Kingdom" accepts any mix of at least five Gros Michels and Cavendishes.
"Huge Fan" requires the selected Pink Stake, Porkify Deck, Porky and Piggyback
at victory, a Mimic in the current playing-card deck, and a Tiny, normal, Jumbo,
or Mega Porkify Pack opened earlier in the run. Other Porkify booster types do
not count as a Porkify Pack for this achievement.

The Ante 1 Small Blind and Ante 2 Big Blind loss achievements check actual game
over, after rescue effects. "Electric Boogaloo" checks ownership of Joker 2.
"MY PCCC-C-C-C-C!" unlocks during hand selection when more than two Blank Seals
produce the Too Many Blanks! hand; no attempt to play it is needed.

"Once More Unto The Breach" unlocks when starting a new run above Gold Stake.
"Better Than The Creator" and "Showoff" require winning a run with Onyx and
Topaz respectively as the selected Stake.

"Grow Up!" requires exactly two ranked cards: a 6 immediately followed by a 7
or 9 in played order. Cards with neither rank nor suit (such as Stone, Meteor,
and Exclaim) may appear before or after the pair, but never between them.
Any Blank Seal in the played hand disqualifies it. "Mis-input" requires two
distinct cards. "No Death Coin" checks that exactly one Encore is the only Joker
owned when the run is won. Paul must die through his end-of-round effect for
"See You Again"; selling him does not count.

Straight-containing plays are tracked in the saved run, including Straight
Flushes and hands that score as a higher poker hand. Runs saved before this
feature use recorded Straight/straight-flush hand counts as a fallback; those
older saves do not record straights contained in other scoring hands.

`python tests/run_poker_hands.py` also checks all achievement conditions and
the Paul, Glitch, and sticker-removal consumable callbacks, plus Boss Blind hand restrictions.

Prideful debuffs all extended Straights and Straight Flushes. Plunger debuffs
the extended Flushes, Straight Flushes, and Flush Six/Seven/Eight. Twins debuffs
the extended pairs, houses, matching-rank hands, Two By Fours, and Flush
Six/Seven/Eight (as well as vanilla Flush House). These restrictions use the
scoring hand's type in both previews and actual play.

## Additional Boss Effects

- **Landlord:** adds Rental to a random eligible Joker on each play.
- **Virus / Stapler:** each play has a base 1-in-2 chance to add Perishable /
  Eternal to an eligible Joker. Probability modifiers apply; existing stickers
  and Eternal/Perishable incompatibilities are respected.
- **Bully:** requires Magnet and snapshots the Favorite cards when selected.
  Those cards remain its targets if Favorites change, including after loading
  a save. Disabling or defeating it removes its debuffs.
- **Eco-Warrior / Scientist:** divide final Mult by remaining Discards / the
  current level of the scored poker hand, with a minimum divisor of one.
- **Wipe:** permanently removes enhancements from played cards before hand
  evaluation and scoring. Held cards, seals, and editions are preserved.
- **ERROR:** rolls requirement and reward independently when selected and saves
  the results. Both stay within 30%-130% of normal; rewards use whole dollars
  (normally $2-$6), and no-reward modifiers still produce $0.
- **Tax:** draws cards face down while money meets or exceeds the current
  interest cap ($25 normally, adjusted by interest-cap vouchers). Disabling
  it reveals cards already in hand. It no longer charges Hands for discards.

These new Blinds currently reuse existing Blind sprites. The test runner also
checks their effects, disabled behavior, and saved-state handling.
