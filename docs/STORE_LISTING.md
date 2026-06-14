# Store Listing — Ready-to-Paste English Texts

Copy these into Play Console → Grow → Main store listing. Character limits
are respected; do not exceed them when editing.

---

## Release notes — v1.1.4 (max 500 chars — paste into "What's new")

```
NEW in 1.1.4
• Fixed a startup crash on some devices — the app now opens reliably
• Stability and performance improvements under the hood
Thanks for your patience, and happy decoding!
```

---

## Release notes — v1.1.3 (max 500 chars — paste into "What's new")

```
NEW in 1.1.3
• Crisper, click-free sound effects and music
• Smoother, more reliable startup
• Polished layouts on tablets and large screens
• Small fixes and quality tweaks
Thanks for playing, and happy decoding!
```

---

## Release notes — v1.1.2 (max 500 chars — paste into "What's new")

```
NEW in 1.1.2
• Sharper, higher-contrast text in every theme (easier on the eyes)
• Clearer cipher letters on the board
• A polished, brand-coloured daily reminder
• Friendlier first-run Statistics screen
• Logo and web polish throughout
Happy decoding!
```

---

## Release notes — v1.1.1 (max 500 chars — paste into "What's new")

```
NEW in 1.1.1
• Volume keys now control MEDIA volume (audio fixed)
• A fully recomposed, calmer soundtrack — no more noise
• Music gently dips while you celebrate a solve
• One-tap music mute on the home screen
• Smoother tutorial start and simpler reminder time entry
• 49 new public-domain quotes (now 500+)
• Battery-friendlier solve screen
Happy decoding!
```

---

## Release notes — v1.1.0 (previous)

```
NEW in 1.1.0
• Soothing ambient soundtrack while you solve (toggle in Settings)
• Celebrations: the board lights up word by word and confetti rains on every solve
• A soft chime when you complete a word
• Smoother screen transitions and a refreshed look
• Optional daily reminder so your streak never breaks
Happy decoding!
```

---

## App name (max 30 chars — currently 29)

```
Quotecrack: Cryptogram Puzzle
```

## Short description (max 80 chars — currently 78)

```
Decode famous quotes! Daily cryptogram puzzles, offline & clean. Crack the code
```

## Full description (max 4000 chars)

```
Crack the code, reveal the quote. Quotecrack is a beautifully simple cryptogram puzzle game: every puzzle is a famous quote encrypted with a secret letter substitution. Decode it letter by letter and enjoy the "aha!" moment when the words appear.

DAILY CRYPTOGRAM
A new puzzle every day — the same quote for every player worldwide. Solve it, keep your streak alive, and share your time with friends, Wordle-style.

500+ HAND-PICKED QUOTES
Wisdom, humor, proverbs, literature, and science — from Mark Twain and Oscar Wilde to Jane Austen and old proverbs of the world. Every quote is carefully curated and attributed.

PLAY YOUR WAY
• 4 difficulty packs, from relaxed Beginner to brutal Expert
• 5 themed packs: Proverbs, Humor, Wisdom, Literature, Science
• Optional timer — or switch it off for pure zen
• Smart hints when you are stuck (earn more by solving!)
• Error checking you can toggle anytime

MADE FOR COMFORT
• Fully OFFLINE — play on a plane, on the subway, anywhere
• No account, no sign-up, no nonsense
• Light, dark, and sepia reading themes
• Adjustable text size and a colorblind-friendly palette
• Large touch targets and a custom keyboard built for puzzles
• Soothing ambient soundtrack — or switch it off for pure silence

TRACK YOUR JOURNEY
• Daily streaks with a calendar heatmap
• Statistics: solve times, fastest cracks, no-hint solves
• 16 achievements to unlock

RESPECTFUL FREE-TO-PLAY
The puzzle screen is always ad-free. A small banner and occasional interstitials keep the lights on — or go Premium once and remove every ad forever, unlock unlimited hints, and get two exclusive packs: Shakespeare and Stoic Wisdom.

WHAT IS A CRYPTOGRAM?
A cryptogram (also called a cryptoquote or cipher puzzle) is a short text encrypted by replacing each letter with a different one. Solvers use pattern recognition, letter frequency, and word shapes to break the code — the same fun as the cryptoquip in the Sunday paper, now in your pocket.

Whether you love word games, brain teasers, logic puzzles, or just beautiful quotes, Quotecrack gives your brain a satisfying daily workout. Download free and crack your first cipher in under a minute!
```

## Graphics checklist

| Asset | File | Spec |
|---|---|---|
| App icon | `store_assets/play_icon_512.png` (hazır, tam-kanama kare) | 512×512 PNG, <1MB |
| Feature graphic | `store_assets/feature_graphic.png` | 1024×500 PNG |
| Phone screenshots | take 4-6 on your device | 16:9 or 9:16, min 320px |

> Not: Tüm raster görseller (ikonlar, splash, bildirim glifi, web ikonları,
> Play ikonu, feature graphic) tek komutla üretilir:
> `python3 tool/generate_icons.py`. `dart run flutter_launcher_icons`
> ÇALIŞTIRMAYIN — araç çıktılarının üzerine düşük kaliteli ölçekleme yazar
> (pubspec'teki blok yalnız adaptif ikon bağlantısını belgelemek için durur).

Suggested screenshot order (first two matter most):
1. Puzzle screen mid-solve (the core experience)
2. Daily puzzle card on home with a streak
3. Puzzle-complete screen with the revealed quote
4. Packs screen
5. Statistics with the heatmap
6. Sepia theme puzzle (shows reading comfort)

## Keyword notes (ASO)

Primary: cryptogram, cryptoquote, cipher puzzle. Secondary: word puzzle,
quote game, daily puzzle, brain teaser, offline word game, cryptoquip.
These already appear naturally in the description above — Google Play
indexes title > short description > full description. Revisit rankings
after 4-6 weeks and consider seasonal updates (e.g. "holiday quotes" pack
in December) to refresh the listing.

## Localized listings (later, optional)

After launch, adding store listings in DE/FR/ES/PT-BR (texts only — the
game stays English) widens discovery cheaply; cryptogram fans exist in
every market and the puzzle itself is language-light. Use Play Console →
Store listings → Add language.
