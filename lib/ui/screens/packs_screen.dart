import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../engine/quote_repository.dart';
import '../../models/pack.dart';
import '../../state/economy_controller.dart';
import '../../state/progress_controller.dart';
import 'pack_detail_screen.dart';
import 'paywall_screen.dart';
import '../widgets/scale_safe.dart';

class PacksScreen extends StatelessWidget {
  const PacksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<QuoteRepository>();
    final progress = context.watch<ProgressController>();
    final premium = context.select<EconomyController, bool>((e) => e.premium);
    final scheme = Theme.of(context).colorScheme;

    Widget section(String title) => Padding(
      padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: scheme.onSurface.withValues(alpha: .45),
        ),
      ),
    );

    List<Widget> tiles(PackKind kind) => [
      for (final pack in Pack.catalog.where((p) => p.kind == kind))
        _PackTile(
          pack: pack,
          total: repo.forPack(pack).length,
          solved: repo
              .forPack(pack)
              .where((q) => progress.isSolved(q.id))
              .length,
          locked: pack.premiumOnly && !premium,
        ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Puzzle packs')),
      body: ScaleSafe(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            section('By difficulty'),
            // Players reasonably assume long = hard; in cryptograms it is
            // the opposite, so say it once where the packs are picked.
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
              child: Text(
                'Counterintuitive but true: shorter quotes are tougher — '
                'fewer letters, fewer clues.',
                style: TextStyle(
                  fontSize: 12.5,
                  fontStyle: FontStyle.italic,
                  color: scheme.onSurface.withValues(alpha: .5),
                ),
              ),
            ),
            ...tiles(PackKind.difficulty),
            section('Themed'),
            ...tiles(PackKind.themed),
            section('Premium'),
            ...tiles(PackKind.premium),
          ],
        ),
      ),
    );
  }
}

class _PackTile extends StatelessWidget {
  const _PackTile({
    required this.pack,
    required this.total,
    required this.solved,
    required this.locked,
  });

  final Pack pack;
  final int total;
  final int solved;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final done = total > 0 && solved == total;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: ListTile(
          onTap: () {
            if (locked) {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const PaywallScreen()));
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => PackDetailScreen(pack: pack)),
              );
            }
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 8,
          ),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              locked ? Icons.lock_outline : pack.icon,
              color: scheme.primary,
            ),
          ),
          title: Text(
            pack.title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pack.tagline,
                style: TextStyle(
                  fontSize: 13,
                  color: scheme.onSurface.withValues(alpha: .55),
                ),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: total == 0 ? 0 : solved / total,
                  minHeight: 5,
                  backgroundColor: scheme.onSurface.withValues(alpha: .08),
                ),
              ),
            ],
          ),
          trailing: Text(
            locked ? '' : (done ? '\u{2713}' : '$solved/$total'),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface.withValues(alpha: .5),
            ),
          ),
        ),
      ),
    );
  }
}
