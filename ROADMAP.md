# Quotecrack — Quality & Feature Roadmap

This roadmap captures the full "5-star, top-tier cryptogram game" vision and
phases it into shippable, reviewable work. It marks what already ships today, the
near-term quality items, and the larger features that need their own PRs (some
require Play Console / OAuth provisioning or product decisions).

The guiding bar: **Google Play 2026 quality standards** (target API 36 — already
met — edge-to-edge, large-screen/foldable support, WCAG 2.2 contrast, minimal
permissions, AAB, no forced ads).

---

## ✅ Already shipped (verify & polish, don't rebuild)

- **Edge-to-edge** display (`SystemUiMode.edgeToEdge`, transparent bars, safe-area
  insets on every screen) + predictive-back.
- **Audio**: SoLoud engine (low-latency, click-free), separate **sound-effects**
  and **music** volume sliders, perceptual volume taper, ambient crossfading
  playlist with native fades + ducking.
- **Haptics**: amplitude-based cue ladder + **vibration-strength slider**.
- **Accessibility**: dynamic text sizing (0.85–1.4×, combined with OS scale),
  colorblind-safe palette (Protanopia/Deuteranopia), screen-reader labels,
  reduce-motion support, WCAG contrast test, **high-contrast mode** (WCAG 2.2
  AAA text ratios, stronger borders/selection cues, composes with colorblind;
  12-configuration contrast matrix in CI).
- **Theming**: true dark, light, and sepia themes; theme-adaptive system bars.
- **Localization**: 7 languages (en, tr, es, de, fr, it, pt), per-language quote
  datasets, CI key-parity guard.
- **Gameplay**: offline play, daily puzzle + streaks, difficulty packs, letter-
  reveal hints, idle "stuck?" nudges, achievements, stats + heatmap.
- **Monetization**: rewarded-only ads (no forced/unskippable), banner slots off
  the solving screen, secure IAP premium (ad-free), restore purchases.
- **Platform**: target/compile SDK 36, large-screen/foldable orientation rules,
  boot-persistent daily reminder, Play-safe inexact alarms (no exact-alarm perm).
- **Notifications**: system-prompt-first flow, auto-route to OS settings when
  blocked, two-way in-app ↔ OS sync, no custom modal.

---

## Phase 1 — Near-term quality (own PRs)

User-selected priorities, each low-to-moderate risk and infra-free:

1. ~~**High-contrast mode**~~ — ✅ shipped: AAA theme variants for all three
   themes (and their colorblind combinations) + settings toggle.
2. **120 fps / high-refresh + battery saver** — opt into high refresh where the
   display supports it (✅ shipped in v2.9.0 via flutter_displaymode),
   frame-pacing audit (✅ board keystroke path memoized: unchanged cells skip
   rebuild entirely, test-locked), and an optional battery-saver mode that caps
   the frame rate to reduce power draw. Battery saver needs on-device
   verification.
3. **Broader Play 2026 compliance** — AAB size/optimization pass, full 16 KB
   page-size verification of native plugins (SoLoud, ads, etc.), IARC age-rating
   submission (Play Console process), data-safety form review.

---

## Phase 2 — Larger features (own PRs + infra / product decisions)

- **Google Play Games Services cloud save & cross-device sync** — `games_services`
  plugin + Snapshots API with conflict resolution. Requires Play Console OAuth
  client + game ID provisioning (cannot be fully wired/verified in a sandbox).
- **15+ languages + RTL** — expand beyond 7 locales, add Arabic/Hebrew with RTL
  layout and cross-language text-overflow guards; large translation + dataset
  effort.
- **Richer hint system** — beyond letter-reveal: whole-word reveal and a
  logical-rule hint (e.g. frequency/pattern nudges).
- **Customizable keyboard layouts** — alternate key orderings; settings UI.
- **Privacy / data-management panel** — expand beyond the policy link into an
  in-app data overview + controls.

---

## Phase 3 — Needs product/design definition

- **AI-assisted dynamic difficulty curve** — adapt difficulty from quote length,
  letter entropy, and live player performance. Needs a concrete model + tuning
  before implementation.
- **Procedural generation** — the game is built on *real* quotes, so this is best
  reinterpreted as difficulty-targeted *selection* from the curated quote pool
  (and daily seeding), not synthetic quote text. Requires a product decision.

---

## Notes

- Audio and haptic-coupling fidelity must be confirmed on real hardware (a
  headless CI can't listen). The residual haptic "tick" some users hear is
  physical motor→speaker coupling, fully removed only by turning haptics off.
- Each Phase item should ship as its own focused, reviewable PR with tests.
