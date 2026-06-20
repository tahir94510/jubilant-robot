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
    final ads = context.read<AdsService>();

    // Wrap, not Row: on narrow screens / large system text the two buttons
    // stack instead of overflowing (seen as "overflow by N px" on device).
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: [
        const _RevealHintButton(),
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
                _cooldownUntilMs = now + 450;
              }
            }
          : null,
      icon: const Icon(Icons.lightbulb_outline, size: 20),
      label: Text(
        economy.premium
            ? l10n.hintRevealLetter
            : l10n.hintRevealLetterCount(economy.tokens),
      ),
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

  /// Timestamp gate (no Timer, so nothing dangles in tests): after a grant,
  /// taps within this window are ignored, so rapid taps can't stack "added"
  /// snackbars or farm tokens.
  int _cooldownUntilMs = 0;

  Future<void> _onTap(bool canAds) async {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    if (_busy || nowMs < _cooldownUntilMs) return;
    final ads = context.read<AdsService>();
    final economy = context.read<EconomyController>();
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    var granted = false;
    try {
      if (ads.supported && canAds && ads.rewardedReady) {
        // A real ad is loaded: the reward MUST be earned by watching it. The
        // free fallback never runs here — declining the ad grants nothing.
        final earned = await ads.showRewardedForHints();
        if (!mounted) return;
        messenger.hideCurrentSnackBar();
        if (earned) {
          economy.grantRewardedTokens();
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                l10n.hintTokensAdded(AppConfig.tokensPerRewardedAd),
              ),
            ),
          );
          granted = true;
        } else {
          messenger.showSnackBar(SnackBar(content: Text(l10n.adNoVideo)));
        }
      } else if (!ads.rewardedEverServed && AppConfig.grantHintsWithoutAd) {
        // Closed test only: AdMob has never served on this device, so allow the
        // convenience grant. The moment real ads serve once, this path closes
        // for good (rewardedEverServed sticks) — no free hints in production.
        if (!mounted) return;
        messenger.hideCurrentSnackBar();
        economy.grantRewardedTokens();
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.hintTokensAdded(AppConfig.tokensPerRewardedAd)),
          ),
        );
        granted = true;
      } else {
        // Ads are live but none is loaded this instant: ask to try again, never
        // grant for free.
        if (!mounted) return;
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(SnackBar(content: Text(l10n.adNoVideo)));
      }
      // Spam guard: open a short cooldown after a grant so rapid taps are
      // ignored (no stacked snackbars, no token farming).
      if (granted) {
        _cooldownUntilMs = DateTime.now().millisecondsSinceEpoch + 1200;
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
