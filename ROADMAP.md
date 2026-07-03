# Quotecrack — Roadmap

Guiding bar: **Google Play 2026 quality standards** (target API 36, edge-to-edge,
large-screen/foldable support, WCAG 2.2 contrast, minimal permissions, AAB,
no forced ads) — all already met. This file tracks only what is still open;
everything shipped lives in the code, its tests, and `docs/KALITE_KONTROL.md`.

## ✅ Shipped highlights (verify & polish, don't rebuild)

- **Gameplay**: offline play, per-language daily + streaks (DST-safe calendar
  math), difficulty packs, letter- AND word-reveal hints on one token economy,
  idle nudges, achievements, stats + heatmap, undo/redo, review-solution mode.
- **Engine**: deterministic (golden-vector locked, bit-identity proven across
  refactors), per-language alphabets/keyboards (TR i/İ correct), shared daily.
- **Performance**: 90/120Hz unlock on OEM-capped phones, memoized board (a
  keystroke rebuilds only changed cells — test-locked), isolated timer ticks.
- **Accessibility**: dynamic text 0.85–1.4×, colorblind palette, high-contrast
  mode (WCAG 2.2 AAA, 12-config CI contrast matrix), full screen-reader labels,
  reduce-motion everywhere.
- **Theming**: light/dark/sepia × colorblind × high-contrast, lerp'd switches.
- **Audio/haptics**: SoLoud (click-free), crossfading music + ducking,
  amplitude haptic ladder + strength slider.
- **Localization**: 7 languages, native content universes (510+ quotes each),
  CI parity guards (keys, keyboards, daily pools).
- **Monetization**: rewarded-only ads + UMP consent, banners off the solving
  screen, interstitial cadence caps, secure IAP premium, restore, app-ads.txt
  line ready.
- **Platform**: API 36, boot-persistent inexact reminders, in-app updates,
  notifications synced two-way with OS state.

## Open — engineering

1. ~~**Battery-saver mode**~~ — ✅ shipped: settings toggle caps the refresh
   rate via DisplayService (persist-then-apply, test-locked). The actual
   power saving still deserves a real-device sanity check.
2. **Google Play Games cloud save / cross-device sync** — Snapshots API with
   conflict resolution. Blocked on Play Console OAuth client + game ID
   provisioning (cannot be wired or verified from a sandbox).
3. **More languages + RTL** — Arabic/Hebrew need RTL layout work plus a large
   curated-translation effort; each new language must ship its full native
   content universe (the parity tests will enforce it).
4. **Customizable keyboard layouts** — alternate key orderings + settings UI.
5. **In-app privacy/data panel** — expand beyond the policy link into a data
   overview + controls.

## Open — store paperwork (owner tasks, not code)

- **IARC age rating** submission (Play Console questionnaire).
- **Data-safety form** review (declare AdMob AD_ID collection).
- **app-ads.txt at the domain root** — create the `tahir94510.github.io`
  user-site repo and copy `pages/app-ads.txt` there (see docs/MONETIZASYON.md).
- Closed-test track: 12 testers × 14 days before production
  (docs/YAYINLAMA_REHBERI.md).

## Notes

- Audio/haptic fidelity and the 120Hz feel must be confirmed on real hardware;
  the residual haptic "tick" some users hear is physical motor→speaker
  coupling, fully removable only by turning haptics off.
- Dropped from earlier drafts as not worth their complexity: a separate
  "logical-rule" hint (the word reveal covers the stuck-player case), an
  AI-driven dynamic difficulty model, and "procedural generation" (the game is
  real quotes; difficulty-targeted selection already exists via the packs).
- Each item ships as its own focused, reviewable PR with tests.
