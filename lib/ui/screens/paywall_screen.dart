import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../services/haptics_service.dart';
import '../../services/purchases/purchase_service.dart';
import '../../services/sound_service.dart';
import '../../state/economy_controller.dart';
import '../theme/palette.dart';
import '../widgets/brand_mark.dart';
import '../widgets/premium_celebration.dart';

/// One-time premium unlock pitch. Price comes live from the store.
class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  PurchaseService? _purchases;

  /// Guards the one-time VIP celebration, and whether it is currently shown.
  bool _celebrated = false;
  bool _showCelebration = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe once to the store's failure signal so a stuck/declined purchase
    // tells the user instead of leaving the button silently loading.
    final purchases = context.read<PurchaseService>();
    if (!identical(purchases, _purchases)) {
      _purchases?.purchaseErrorTick.removeListener(_onPurchaseError);
      _purchases?.premiumOwned.removeListener(_onPremiumOwned);
      _purchases = purchases;
      purchases.purchaseErrorTick.addListener(_onPurchaseError);
      purchases.premiumOwned.addListener(_onPremiumOwned);
    }
  }

  @override
  void dispose() {
    _purchases?.purchaseErrorTick.removeListener(_onPurchaseError);
    _purchases?.premiumOwned.removeListener(_onPremiumOwned);
    super.dispose();
  }

  void _onPurchaseError() {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.purchaseFailed)));
  }

  /// The store just confirmed ownership (a purchase or a restore) while the
  /// paywall is open: turn it into a VIP moment instead of a silent state flip.
  /// Fires once; an already-premium visitor never sees it (the listener only
  /// reacts to a change, so entering already-owned does not trigger it).
  void _onPremiumOwned() {
    if (!mounted || _celebrated) return;
    if (_purchases?.premiumOwned.value != true) return;
    _celebrated = true;
    context.read<HapticsService>().celebrate();
    context.read<SoundService>().achievement();
    setState(() => _showCelebration = true);
  }

  @override
  Widget build(BuildContext context) {
    final purchases = context.read<PurchaseService>();
    final premium = context.watch<EconomyController>().premium;
    final scheme = Theme.of(context).colorScheme;
    final palette = Theme.of(context).extension<GamePalette>()!;
    final l10n = AppLocalizations.of(context);

    Widget benefit(IconData icon, String title, String subtitle) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: scheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: palette.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: Text(l10n.paywallTitle)),
          body: SafeArea(
            // Cap + center on large screens so the pitch reads as a tidy column
            // on tablets/desktop/TV instead of stretching edge to edge.
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ListView(
                          children: [
                            const Center(child: BrandMark(size: 72)),
                            const SizedBox(height: 12),
                            Text(
                              l10n.paywallHeadline,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: scheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.paywallSubhead,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: palette.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            benefit(
                              Icons.block,
                              l10n.paywallNoAdsTitle,
                              l10n.paywallNoAdsBody,
                            ),
                            benefit(
                              Icons.lightbulb,
                              l10n.paywallHintsTitle,
                              l10n.paywallHintsBody,
                            ),
                            benefit(
                              Icons.workspace_premium_outlined,
                              l10n.paywallPacksTitle,
                              l10n.paywallPacksBody,
                            ),
                            benefit(
                              Icons.favorite_outline,
                              l10n.paywallSupportTitle,
                              l10n.paywallSupportBody,
                            ),
                          ],
                        ),
                      ),
                      if (premium)
                        FilledButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.check),
                          label: Text(l10n.paywallActive),
                        )
                      else ...[
                        if (!purchases.supported)
                          Text(
                            l10n.paywallUnavailable,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: palette.textSecondary,
                            ),
                          )
                        else ...[
                          // The buy button reflects both the live price and whether
                          // a purchase is in flight (spinner + disabled).
                          AnimatedBuilder(
                            animation: Listenable.merge([
                              purchases.premiumPrice,
                              purchases.purchaseInProgress,
                            ]),
                            builder: (context, _) {
                              final price = purchases.premiumPrice.value;
                              final busy = purchases.purchaseInProgress.value;
                              return FilledButton(
                                onPressed: (price == null || busy)
                                    ? null
                                    : () => purchases.buyPremium(),
                                child: busy
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.4,
                                        ),
                                      )
                                    : Text(
                                        price == null
                                            ? l10n.paywallLoadingPrice
                                            : l10n.paywallUnlock(price),
                                      ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          ValueListenableBuilder<bool>(
                            valueListenable: purchases.purchaseInProgress,
                            builder: (context, busy, _) => TextButton(
                              onPressed: busy
                                  ? null
                                  : () {
                                      ScaffoldMessenger.of(context)
                                        ..hideCurrentSnackBar()
                                        ..showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              l10n.purchaseRestoring,
                                            ),
                                          ),
                                        );
                                      purchases.restore();
                                    },
                              child: Text(l10n.paywallRestore),
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_showCelebration)
          PremiumCelebration(
            onDismiss: () {
              if (!mounted) return;
              setState(() => _showCelebration = false);
              Navigator.of(context).maybePop();
            },
          ),
      ],
    );
  }
}
