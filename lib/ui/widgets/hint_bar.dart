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
        // Shown as soon as ads are supported (no waiting for the consent
        // pipeline, so it never "appears late"); the closed-test fallback keeps
        // it usable before AdMob serves. In production (flag off) the reward
        // stays gated by a real watched ad.
        if (!economy.premium &&
            (ads.supported || AppConfig.grantHintsWithoutAd))
          const _RewardedHintButton(),
      ],
    );
  }
}

/// The "+N hints" rewarded button. Stateful so a single in-flight guard stops
/// rapid taps from spamming snackbars (the old behaviour flickered one shut as
/// the next opened, briefly blocking input).
class _RewardedHintButton extends StatefulWidget {
  const _RewardedHintButton();

  @override
  State<_RewardedHintButton> createState() => _RewardedHintButtonState();
}

class _RewardedHintButtonState extends State<_RewardedHintButton> {
  bool _busy = false;

  Future<void> _onTap(bool canAds) async {
    if (_busy) return;
    final ads = context.read<AdsService>();
    final economy = context.read<EconomyController>();
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      // Always try a real rewarded ad first: the moment AdMob serves, the
      // reward comes from the watched ad and the fallback below never runs.
      final earned = (ads.supported && canAds)
          ? await ads.showRewardedForHints()
          : false;
      if (!mounted) return;
      // One message at a time — replace any visible snackbar instead of queuing.
      messenger.hideCurrentSnackBar();
      if (earned || AppConfig.grantHintsWithoutAd) {
        economy.grantRewardedTokens();
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.hintTokensAdded(AppConfig.tokensPerRewardedAd)),
          ),
        );
      } else {
        messenger.showSnackBar(SnackBar(content: Text(l10n.adNoVideo)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ads = context.read<AdsService>();
    final scheme = Theme.of(context).colorScheme;
    return ValueListenableBuilder<bool>(
      valueListenable: ads.canRequestAds,
      builder: (context, canAds, _) => OutlinedButton.icon(
        onPressed: _busy ? null : () => _onTap(canAds),
        icon: Icon(Icons.play_circle_outline, size: 20, color: scheme.primary),
        label: Text('+${AppConfig.tokensPerRewardedAd}'),
      ),
    );
  }
}
