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
Crack the code, reveal the quote. Every puzzle in Quotecrack is a famous quote hidden behind a secret letter swap. You decode it one letter at a time, and there's a real little thrill the moment the words snap into place.

DAILY CRYPTOGRAM
A fresh puzzle every day, the same quote for everyone in the world. Solve it, keep your streak going, and share your time with friends, Wordle style.

500+ HAND-PICKED QUOTES
Wisdom, humor, proverbs, literature, and science, from Mark Twain and Oscar Wilde to Jane Austen and the old proverbs of the world. Every quote is chosen by hand and properly attributed.

PLAY YOUR WAY
• 4 difficulty packs, from relaxed Beginner to brutal Expert
• 5 themed packs: Proverbs, Humor, Wisdom, Literature, Science
• A timer when you want it, off when you'd rather just relax
• Smart hints for when you're stuck (solve puzzles to earn more)
• Error checking you can switch on or off

MADE FOR COMFORT
• Fully offline, so you can play on a plane, on the subway, anywhere
• No account, no sign-up, no clutter
• Light, dark, and sepia reading themes
• Adjustable text size and a colorblind-friendly palette
• Big touch targets and a keyboard built for puzzles
• A calm ambient soundtrack you can turn off anytime

TRACK YOUR JOURNEY
• Daily streaks with a calendar heatmap
• Stats for solve times, fastest cracks, and no-hint solves
• 16 achievements to unlock

FAIR AND FREE TO PLAY
The puzzle screen is always ad-free. A small banner and the occasional full-screen ad keep the lights on. Prefer a clean run? Go Premium once to remove every ad for good, unlock unlimited hints, and get the exclusive bonus packs (Shakespeare, Stoic wisdom, and more on the way).

WHAT IS A CRYPTOGRAM?
A cryptogram (also called a cryptoquote or cipher puzzle) is a short message scrambled by swapping each letter for another. You break it with pattern recognition, letter frequency, and the shapes of words. It's the same fun as the cryptoquip in the Sunday paper, now in your pocket.

If you love word games, brain teasers, logic puzzles, or just a good quote, Quotecrack gives your brain a satisfying daily workout. Download it free and crack your first cipher in about a minute.
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
