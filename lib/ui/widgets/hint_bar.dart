import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_config.dart';
import '../../services/ads/ads_service.dart';
import '../../state/economy_controller.dart';
import '../../state/game_controller.dart';

/// Hint button + token count + (mobile, non-premium) "watch ad for +3".
class HintBar extends StatelessWidget {
  const HintBar({super.key});

  @override
  Widget build(BuildContext context) {
    final economy = context.watch<EconomyController>();
    final game = context.read<GameController>();
    final ads = context.read<AdsService>();
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlinedButton.icon(
          onPressed: economy.canUseHint
              ? () {
                  if (economy.spendHintToken()) game.revealSelected();
                }
              : null,
          icon: const Icon(Icons.lightbulb_outline, size: 20),
          label: Text(
            economy.premium
                ? 'Reveal letter'
                : 'Reveal letter (${economy.tokens})',
          ),
        ),
        if (!economy.premium && ads.supported) ...[
          const SizedBox(width: 10),
          ValueListenableBuilder<bool>(
            valueListenable: ads.canRequestAds,
            builder: (context, canAds, _) {
              if (!canAds) return const SizedBox.shrink();
              return OutlinedButton.icon(
                onPressed: () async {
                  final earned = await ads.showRewardedForHints();
                  if (earned) {
                    economy.grantRewardedTokens();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '+${AppConfig.tokensPerRewardedAd} hints added',
                          ),
                        ),
                      );
                    }
                  }
                },
                icon: Icon(
                  Icons.play_circle_outline,
                  size: 20,
                  color: scheme.primary,
                ),
                label: Text('+${AppConfig.tokensPerRewardedAd}'),
              );
            },
          ),
        ],
      ],
    );
  }
}
