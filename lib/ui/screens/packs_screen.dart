import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../engine/quote_repository.dart';
import '../../models/pack.dart';
import '../../state/economy_controller.dart';
import '../../state/progress_controller.dart';
import '../theme/palette.dart';
import 'pack_detail_screen.dart';
import 'paywall_screen.dart';
import '../widgets/page_body.dart';
import '../widgets/scale_safe.dart';

class PacksScreen extends StatelessWidget {
  const PacksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<QuoteRepository>();
    final progress = context.watch<ProgressController>();
    final premium = context.select<EconomyController, bool>((e) => e.premium);
    final palette = Theme.of(context).extension<GamePalette>()!;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    Widget section(String title) => Padding(
      padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: palette.textSecondary,
        ),
      ),
    );

    List<Widget> tiles(PackKind kind) => [
      for (final pack in Pack.catalog.where((p) => p.kind == kind))
        if (repo.forPack(pack, activeLocale: locale).isNotEmpty)
          _PackTile(
            pack: pack,
            total: repo.forPack(pack, activeLocale: locale).length,
            solved: repo
                .forPack(pack, activeLocale: locale)
                .where((q) => progress.isSolved(q.id))
                .length,
            locked: pack.premiumOnly && !premium,
          ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.puzzlePacks)),
      body: PageBody(
        child: ScaleSafe(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              if (tiles(PackKind.difficulty).isNotEmpty) ...[
                section(l10n.packsSectionByDifficulty),
                // Players reasonably assume long = hard; in cryptograms it is
                // the opposite, so say it once where the packs are picked.
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
                  child: Text(
                    l10n.packsDifficultyHint,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontStyle: FontStyle.italic,
                      color: palette.textSecondary,
                    ),
                  ),
                ),
                ...tiles(PackKind.difficulty),
              ],
              if (tiles(PackKind.themed).isNotEmpty) ...[
                section(l10n.packsSectionThemed),
                ...tiles(PackKind.themed),
              ],
              section(l10n.packsSectionLanguages),
              ...tiles(PackKind.language),
              section(l10n.sectionPremium),
              ...tiles(PackKind.premium),
            ],
          ),
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
    final palette = Theme.of(context).extension<GamePalette>()!;
    final l10n = AppLocalizations.of(context);
    final done = total > 0 && solved == total;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        clipBehavior: Clip.antiAlias,
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
            pack.localizedTitle(l10n),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pack.localizedTagline(l10n),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: palette.textSecondary),
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
              color: palette.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
