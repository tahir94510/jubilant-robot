import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/ads/ads_service.dart';
import '../../state/economy_controller.dart';

/// Renders an adaptive banner where allowed; collapses to nothing on web,
/// for premium owners, or before consent/load. Placed ONLY on the home and
/// puzzle-complete screens — never on the solving screen.
class BannerAdSlot extends StatelessWidget {
  const BannerAdSlot({super.key, required this.slotName});

  /// Distinguishes banner instances so each screen gets its own ad.
  final String slotName;

  @override
  Widget build(BuildContext context) {
    final ads = context.read<AdsService>();
    final premium = context.select<EconomyController, bool>((e) => e.premium);
    if (!ads.supported || premium) return const SizedBox.shrink();

    return ValueListenableBuilder<bool>(
      valueListenable: ads.canRequestAds,
      builder: (context, canAds, _) {
        if (!canAds) return const SizedBox.shrink();
        final banner = ads.buildAdaptiveBanner(
          context,
          key: ValueKey('banner-$slotName'),
        );
        if (banner == null) return const SizedBox.shrink();
        // Fade the banner in once it resolves so it settles into the footer
        // instead of snapping in and jarring the eye (honors "remove
        // animations": no fade when motion is reduced).
        final reduceMotion = MediaQuery.of(context).disableAnimations;
        // A hairline above the ad gives it breathing room from the content so
        // it reads as a distinct footer instead of crowding the last row. Only
        // shown when an ad actually renders (never a floating divider).
        return DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.08),
              ),
            ),
          ),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: reduceMotion ? 1.0 : 0.0, end: 1),
            duration: Duration(milliseconds: reduceMotion ? 0 : 300),
            curve: Curves.easeOut,
            builder: (context, t, child) => Opacity(opacity: t, child: child),
            child: banner,
          ),
        );
      },
    );
  }
}
