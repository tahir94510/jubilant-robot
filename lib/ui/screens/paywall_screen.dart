import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/purchases/purchase_service.dart';
import '../../state/economy_controller.dart';

/// One-time premium unlock pitch. Price comes live from the store.
class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final purchases = context.read<PurchaseService>();
    final premium = context.watch<EconomyController>().premium;
    final scheme = Theme.of(context).colorScheme;

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
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme.onSurface.withValues(alpha: .55),
                  ),
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
                    Icon(
                      Icons.workspace_premium,
                      size: 64,
                      color: scheme.primary,
                    ),
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
                        color: scheme.onSurface.withValues(alpha: .55),
                      ),
                    ),
                    const SizedBox(height: 20),
                    benefit(
                      Icons.block,
                      'No ads, ever',
                      'All banners and interstitials removed',
                    ),
                    benefit(
                      Icons.lightbulb,
                      'Unlimited hints',
                      'Reveal letters whenever you are stuck',
                    ),
                    benefit(
                      Icons.theater_comedy,
                      'Shakespeare pack',
                      '36 ciphers from the Bard himself',
                    ),
                    benefit(
                      Icons.account_balance,
                      'Stoic Wisdom pack',
                      'Marcus Aurelius, Seneca, Epictetus',
                    ),
                  ],
                ),
              ),
              if (premium)
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.check),
                  label: const Text('Premium active — enjoy!'),
                )
              else ...[
                if (!purchases.supported)
                  Text(
                    'Purchases are available in the Android app.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: scheme.onSurface.withValues(alpha: .5),
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
