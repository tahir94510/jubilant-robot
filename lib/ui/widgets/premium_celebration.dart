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
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: 30,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Material(
            color: scheme.surface,
            elevation: 0,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Gold-to-primary crown medallion: the visual badge of VIP.
                  Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [scheme.tertiary, scheme.primary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: scheme.tertiary.withValues(alpha: 0.45),
                          blurRadius: 24,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.workspace_premium,
                      size: 44,
                      color: scheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    l10n.premiumUnlockedTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.premiumUnlockedBody,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.4,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _Benefit(l10n.paywallNoAdsTitle),
                  _Benefit(l10n.paywallHintsTitle),
                  _Benefit(l10n.paywallPacksTitle),
                  const SizedBox(height: 22),
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
          ),
        ),
      ),
    );

    return Stack(
      children: [
        // Tap-anywhere-to-dismiss scrim that dims the paywall behind.
        Positioned.fill(
          child: GestureDetector(
            onTap: onDismiss,
            child: ColoredBox(color: Colors.black.withValues(alpha: 0.55)),
          ),
        ),
        // Confetti ignores pointers, so taps fall through to the scrim.
        const Positioned.fill(child: ConfettiBurst(particleCount: 150)),
        Center(
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
      padding: const EdgeInsets.symmetric(vertical: 4),
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
