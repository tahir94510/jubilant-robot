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
        return ads.buildAdaptiveBanner(
              context,
              key: ValueKey('banner-$slotName'),
            ) ??
            const SizedBox.shrink();
      },
    );
  }
}
