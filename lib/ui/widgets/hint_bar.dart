import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_config.dart';
import '../../l10n/app_localizations.dart';
import '../../services/ads/ads_service.dart';
import '../../services/sound_service.dart';
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
    final sounds = context.read<SoundService>();
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    // Wrap, not Row: on narrow screens / large system text the two buttons
    // stack instead of overflowing (seen as "overflow by N px" on device).
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: [
        OutlinedButton.icon(
          onPressed: economy.canUseHint
              ? () {
                  if (economy.spendHintToken()) {
                    game.revealSelected();
                    sounds.hint();
                  }
                }
              : null,
          icon: const Icon(Icons.lightbulb_outline, size: 20),
          label: Text(
            economy.premium
                ? l10n.hintRevealLetter
                : l10n.hintRevealLetterCount(economy.tokens),
          ),
        ),
        // Closed-test fallback (AppConfig.grantHintsWithoutAd) keeps the hint
        // loop usable before AdMob serves; in production (flag off) the reward
        // stays gated by a real watched ad so revenue is never undermined.
        if (!economy.premium &&
            (ads.supported || AppConfig.grantHintsWithoutAd))
          ValueListenableBuilder<bool>(
            valueListenable: ads.canRequestAds,
            builder: (context, canAds, _) {
              // Production requires consent before the button appears. With the
              // closed-test fallback on, show it regardless so testers can top
              // up even before the consent/ad pipeline is warm.
              if (!canAds && !AppConfig.grantHintsWithoutAd) {
                return const SizedBox.shrink();
              }
              return OutlinedButton.icon(
                onPressed: () async {
                  // Always try a real rewarded ad first when we can: this
                  // captures every genuine impression (and its revenue) the
                  // moment AdMob serves, so a forgotten test flag can never
                  // hand out free hints while real ads are working.
                  final earned = (ads.supported && canAds)
                      ? await ads.showRewardedForHints()
                      : false;
                  if (!context.mounted) return;
                  if (earned || AppConfig.grantHintsWithoutAd) {
                    economy.grantRewardedTokens();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n.hintTokensAdded(AppConfig.tokensPerRewardedAd),
                        ),
                      ),
                    );
                  } else {
                    // No fill yet (common on a freshly published app until
                    // AdMob warms up) or the video was closed early. Tell the
                    // player instead of leaving the tap feeling broken.
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(l10n.adNoVideo)));
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
    );
  }
}
