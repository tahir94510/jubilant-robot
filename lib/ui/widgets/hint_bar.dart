import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_config.dart';
import '../../l10n/app_localizations.dart';
import '../../services/ads/ads_service.dart';
import '../../services/haptics_service.dart';
import '../../services/sound_service.dart';
import '../../state/economy_controller.dart';
import '../../state/game_controller.dart';

/// Hint button + token count + (mobile, non-premium) "watch ad for +3".
class HintBar extends StatelessWidget {
  const HintBar({super.key});

  @override
  Widget build(BuildContext context) {
    final economy = context.watch<EconomyController>();
    final ads = context.read<AdsService>();

    // Wrap, not Row: on narrow screens / large system text the two buttons
    // stack instead of overflowing (seen as "overflow by N px" on device).
    // LayoutBuilder caps the reveal button (whose localized label is the long
    // one) to the row width, and its label shrinks to fit — so even a long
    // language at the largest text size can never push it past the edge.
    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth),
              child: const _RevealHintButton(),
            ),
            // Shown on mobile for non-premium players. The button greys itself
            // out until a rewarded ad is actually loaded (see
            // _RewardedHintButton), so a reward is never granted without
            // watching one — and an offline player simply sees a disabled
            // button, never a free hint.
            if (!economy.premium && ads.supported) const _RewardedHintButton(),
          ],
        );
      },
    );
  }
}

/// The per-letter reveal button. Stateful for a short timer-free cooldown so
/// rapid taps can't spend several tokens in a burst before the hint sound +
/// reveal animation have played — keeping the feedback clean without blocking
/// deliberate, paced multi-reveals.
class _RevealHintButton extends StatefulWidget {
  const _RevealHintButton();

  @override
  State<_RevealHintButton> createState() => _RevealHintButtonState();
}

class _RevealHintButtonState extends State<_RevealHintButton> {
  int _cooldownUntilMs = 0;

  @override
  Widget build(BuildContext context) {
    final economy = context.watch<EconomyController>();
    // watch: the reveal button must disable the moment the last letter is
    // revealed (canRevealMore flips false), so a token is never wasted.
    final game = context.watch<GameController>();
    final l10n = AppLocalizations.of(context);

    // Reveal is allowed only when there is something left to uncover AND a
    // token is available — filling the whole quote via hints disables it.
    final canReveal = economy.canUseHint && game.canRevealMore;

    return OutlinedButton.icon(
      onPressed: canReveal
          ? () {
              final now = DateTime.now().millisecondsSinceEpoch;
              if (now < _cooldownUntilMs) return; // brief anti-spam window
              if (economy.spendHintToken()) {
                game.revealSelected();
                context.read<SoundService>().hint();
                // A light tactile tick in sync with the hint chime, so the
                // reveal feels deliberate instead of silent under the thumb.
                context.read<HapticsService>().wordComplete();
                _cooldownUntilMs = now + 450;
              }
            }
          : null,
      icon: const Icon(Icons.lightbulb_outline, size: 20),
      // scaleDown keeps the full label but shrinks it to fit the capped button
      // width in long languages, instead of overflowing or clipping.
      label: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          economy.premium
              ? l10n.hintRevealLetter
              : l10n.hintRevealLetterCount(economy.tokens),
          maxLines: 1,
        ),
      ),
    );
  }
}

/// The "+N hints" rewarded button. Enabled ONLY while a rewarded ad is actually
/// loaded ([AdsService.rewardedAvailable]) — so it greys out when offline or
/// before AdMob fills, and a reward is impossible without watching one (no free
/// path). A single in-flight guard + short cooldown stop rapid taps from
/// stacking snackbars or farming.
class _RewardedHintButton extends StatefulWidget {
  const _RewardedHintButton();

  @override
  State<_RewardedHintButton> createState() => _RewardedHintButtonState();
}

class _RewardedHintButtonState extends State<_RewardedHintButton> {
  bool _busy = false;

  /// Timestamp gate (no Timer, so nothing dangles in tests): after a grant,
  /// taps within this window are ignored.
  int _cooldownUntilMs = 0;

  Future<void> _onTap() async {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    if (_busy || nowMs < _cooldownUntilMs) return;
    final ads = context.read<AdsService>();
    final economy = context.read<EconomyController>();
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      // The button is enabled only when a rewarded ad is loaded, so the reward
      // is always earned by genuinely watching one — declining grants nothing,
      // and there is no offline free-hint path.
      final earned = await ads.showRewardedForHints();
      if (!mounted) return;
      messenger.hideCurrentSnackBar();
      if (earned) {
        economy.grantRewardedTokens();
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.hintTokensAdded(AppConfig.tokensPerRewardedAd)),
          ),
        );
        _cooldownUntilMs = DateTime.now().millisecondsSinceEpoch + 1200;
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
      valueListenable: ads.rewardedAvailable,
      builder: (context, available, _) {
        final enabled = available && !_busy;
        return OutlinedButton.icon(
          onPressed: enabled ? _onTap : null,
          icon: Icon(
            Icons.play_circle_outline,
            size: 20,
            color: enabled ? scheme.primary : null,
          ),
          label: Text('+${AppConfig.tokensPerRewardedAd}'),
        );
      },
    );
  }
}
