import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/purchases/purchase_service.dart';
import '../../state/economy_controller.dart';
import '../theme/palette.dart';
import '../widgets/brand_mark.dart';

/// One-time premium unlock pitch. Price comes live from the store.
class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final purchases = context.read<PurchaseService>();
    final premium = context.watch<EconomyController>().premium;
    final scheme = Theme.of(context).colorScheme;
    final palette = Theme.of(context).extension<GamePalette>()!;

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
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: palette.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Quotecrack Premium')),
      body: SafeArea(
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
                      'Solve without limits',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'One purchase. Yours forever. No subscription.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: palette.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    benefit(
                      Icons.block,
                      'No ads, ever',
                      'Every banner and full-screen ad, gone',
                    ),
                    benefit(
                      Icons.lightbulb,
                      'Unlimited hints',
                      "Reveal a letter whenever you're stuck",
                    ),
                    benefit(
                      Icons.workspace_premium_outlined,
                      'Exclusive bonus packs',
                      'Shakespeare, Stoic wisdom, and more on the way',
                    ),
                    benefit(
                      Icons.favorite_outline,
                      'Support the game',
                      'One purchase helps Quotecrack keep growing',
                    ),
                  ],
                ),
              ),
              if (premium)
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.check),
                  label: const Text('Premium active. Enjoy!'),
                )
              else ...[
                if (!purchases.supported)
                  Text(
                    'Purchases are available in the Android app.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: palette.textSecondary,
                    ),
                  )
                else ...[
                  ValueListenableBuilder<String?>(
                    valueListenable: purchases.premiumPrice,
                    builder: (context, price, _) => FilledButton(
                      onPressed: price == null
                          ? null
                          : () => purchases.buyPremium(),
                      child: Text(
                        price == null
                            ? 'Loading price...'
                            : 'Unlock Premium · $price',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => purchases.restore(),
                    child: const Text('Restore previous purchase'),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
