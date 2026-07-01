import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/palette.dart';
import 'confetti_burst.dart';

/// Full-screen celebratory overlay shown the instant a premium purchase (or
/// restore) lands: a dim scrim, a confetti burst, and a "VIP" card that pops in
/// with a crown — turning "ads removed" into a moment worth remembering.
///
/// Tapping the scrim or the button calls [onDismiss]. Reduced-motion users get
/// the static card with no confetti and no scale-in.
class PremiumCelebration extends StatelessWidget {
  const PremiumCelebration({super.key, required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final palette = Theme.of(context).extension<GamePalette>()!;
    final motion = !MediaQuery.of(context).disableAnimations;

    final card = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: DecoratedBox(
          // One soft, downward drop shadow reads as a clean modern card —
          // not the heavy all-sides black halo a high Material elevation casts
          // over the dim scrim.
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.30),
                blurRadius: 34,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: ColoredBox(
              color: scheme.surface,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Champagne header band: a soft gold wash carrying the VIP
                  // crown medallion, so the unlock reads as a premium moment the
                  // instant it appears (instead of a plain dialog with an icon).
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 30, bottom: 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          scheme.primary.withValues(alpha: .20),
                          scheme.primary.withValues(alpha: .02),
                        ],
                      ),
                    ),
                    child: Center(
                      // The crown medallion is built from the app's REAL brand
                      // golds (streak flame -> primary), not Material's seed-
                      // derived `tertiary`, which resolved to an off-brand hue
                      // and made the badge look out of place.
                      child: Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [palette.streakFlame, scheme.primary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: scheme.primary.withValues(alpha: 0.45),
                              blurRadius: 26,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.workspace_premium,
                          size: 46,
                          color: scheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 22),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.premiumUnlockedTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          l10n.premiumUnlockedBody,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.5,
                            height: 1.45,
                            color: palette.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 22),
                        _Benefit(l10n.paywallNoAdsTitle),
                        _Benefit(l10n.paywallHintsTitle),
                        _Benefit(l10n.paywallPacksTitle),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: onDismiss,
                            child: Text(l10n.premiumContinue),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return Stack(
      children: [
        // Tap-anywhere-to-dismiss scrim that dims the paywall behind. Labelled
        // so a screen reader can discover the dismiss affordance (sighted users
        // also get the visible "Continue" button below).
        Positioned.fill(
          child: Semantics(
            label: l10n.a11yDismiss,
            button: true,
            onTap: onDismiss,
            child: GestureDetector(
              onTap: onDismiss,
              child: ColoredBox(color: Colors.black.withValues(alpha: 0.55)),
            ),
          ),
        ),
        // Confetti ignores pointers, so taps fall through to the scrim.
        const Positioned.fill(child: ConfettiBurst(particleCount: 150)),
        // Centered when there's room, but SCROLLS if the card is taller than the
        // viewport (short/landscape phones, large text scale) — so the VIP card
        // can never overflow off-screen or clip its "Continue" button. SafeArea
        // keeps it clear of the status/nav bars.
        Positioned.fill(
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: motion
                        ? TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.6, end: 1),
                            duration: const Duration(milliseconds: 520),
                            curve: Curves.elasticOut,
                            builder: (context, scale, child) =>
                                Transform.scale(scale: scale, child: child),
                            child: card,
                          )
                        : card,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// One "you now get this" line in the VIP card, reusing the paywall's own
/// benefit titles so the promise stays consistent.
class _Benefit extends StatelessWidget {
  const _Benefit(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = Theme.of(context).extension<GamePalette>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 20, color: palette.success),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
