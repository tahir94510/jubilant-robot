import 'dart:math' as math;

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
  const HintBar({super.key, this.hintNudge = 0, this.rewardedNudge = 0});

  /// Idle-nudge triggers from the puzzle screen: when one of these changes, the
  /// matching button plays a gentle "try me" pulse (see [_NudgePulse]). They are
  /// separate so a state flip (e.g. tokens hitting zero) never pulses a button
  /// the player wasn't actually nudged toward.
  final int hintNudge;
  final int rewardedNudge;

  @override
  Widget build(BuildContext context) {
    final economy = context.watch<EconomyController>();
    final ads = context.read<AdsService>();

    // Wrap, not Row: on narrow screens / large system text the hint buttons
    // (reveal-letter, reveal-word, and the rewarded +N) stack instead of
    // overflowing (seen as "overflow by N px" on device). LayoutBuilder caps
    // each reveal button (whose localized label is the long one) to the row
    // width, and its label shrinks to fit — so even a long language at the
    // largest text size can never push it past the edge.
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
              child: _NudgePulse(
                trigger: hintNudge,
                child: const _RevealHintButton(),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth),
              child: const _RevealWordButton(),
            ),
            // Shown on mobile for non-premium players. The button greys itself
            // out until a rewarded ad is actually loaded (see
            // _RewardedHintButton), so a reward is never granted without
            // watching one — and an offline player simply sees a disabled
            // button, never a free hint.
            if (!economy.premium && ads.supported)
              _NudgePulse(
                trigger: rewardedNudge,
                child: const _RewardedHintButton(),
              ),
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
              // The enabled state above comes from the LAST build; re-check at
              // tap time so a token that hit zero (or a board that filled up)
              // between that rebuild and this tap can never let revealSelected()
              // mutate the board with the spend failing right after.
              if (!(economy.canUseHint && game.canRevealMore)) return;
              // Reveal FIRST, then charge: the token is spent strictly when a
              // cell is actually uncovered (the short-circuit skips the spend on
              // a no-op reveal), making the long-standing "never waste a token"
              // promise structural rather than only enforced by the gate above.
              if (game.revealSelected() && economy.spendHintToken()) {
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

/// The whole-word reveal. Costs exactly as many tokens as the selected word
/// still needs distinct letters (a word reveal = N targeted letter reveals),
/// so it rides the same economy as the letter hint — no second currency and
/// the shown price is always the charged price (one shared computation in
/// GameController). Disables when the word is done, the cursor is off-board,
/// or the player can't afford it, so a token is never wasted.
class _RevealWordButton extends StatefulWidget {
  const _RevealWordButton();

  @override
  State<_RevealWordButton> createState() => _RevealWordButtonState();
}

class _RevealWordButtonState extends State<_RevealWordButton> {
  int _cooldownUntilMs = 0;

  @override
  Widget build(BuildContext context) {
    final economy = context.watch<EconomyController>();
    // watch: the price tracks the cursor (each word has its own cost) and the
    // button must disable the moment the word completes or tokens run short.
    final game = context.watch<GameController>();
    final l10n = AppLocalizations.of(context);

    final cost = game.wordHintCost;
    final canReveal = cost > 0 && (economy.premium || economy.tokens >= cost);

    return OutlinedButton.icon(
      onPressed: canReveal
          ? () {
              final now = DateTime.now().millisecondsSinceEpoch;
              if (now < _cooldownUntilMs) return; // brief anti-spam window
              // The enabled state comes from the LAST build; re-price and
              // re-check at tap time so a cursor move or a spend between that
              // rebuild and this tap can never mutate the board unpaid.
              final tapCost = game.wordHintCost;
              if (tapCost <= 0 ||
                  !(economy.premium || economy.tokens >= tapCost)) {
                return;
              }
              // Reveal FIRST, then charge exactly what was uncovered — the
              // same "never waste a token" contract as the letter hint.
              final revealed = game.revealSelectedWord();
              if (revealed > 0 && economy.spendHintTokens(revealed)) {
                context.read<SoundService>().hint();
                context.read<HapticsService>().wordComplete();
                _cooldownUntilMs = now + 450;
              }
            }
          : null,
      icon: const Icon(Icons.auto_fix_high, size: 20),
      label: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          economy.premium ? l10n.hintRevealWord : l10n.hintRevealWordCost(cost),
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

/// Plays two gentle scale "swells" whenever [trigger] changes — the idle-nudge
/// cue that quietly draws the eye to a button ("stuck? try this") without the
/// urgency of a shake. Honors the system "remove animations" setting by passing
/// the child straight through, and rests at exactly 1.0 so an un-nudged button
/// is pixel-identical to before.
class _NudgePulse extends StatefulWidget {
  const _NudgePulse({required this.trigger, required this.child});

  final int trigger;
  final Widget child;

  @override
  State<_NudgePulse> createState() => _NudgePulseState();
}

class _NudgePulseState extends State<_NudgePulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didUpdateWidget(_NudgePulse old) {
    super.didUpdateWidget(old);
    // trigger 0 is the "never nudged" rest value, so it never starts a pulse.
    if (widget.trigger != old.trigger && widget.trigger != 0) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return widget.child;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        // Two smooth humps (raised-cosine, always >= 0) so it swells +4% twice
        // and settles — never dips below rest, never reads as a glitch.
        final scale = 1 + ((1 - math.cos(t * 4 * math.pi)) / 2) * 0.04;
        return Transform.scale(scale: scale, child: child);
      },
      child: widget.child,
    );
  }
}
