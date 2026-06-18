import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../engine/quote_repository.dart';
import '../../models/pack.dart';
import '../../state/game_controller.dart';
import '../../state/progress_controller.dart';
import '../theme/palette.dart';
import 'puzzle_screen.dart';

class PackDetailScreen extends StatelessWidget {
  const PackDetailScreen({super.key, required this.pack});

  final Pack pack;

  @override
  Widget build(BuildContext context) {
    final repo = context.read<QuoteRepository>();
    final progress = context.watch<ProgressController>();
    final palette = Theme.of(context).extension<GamePalette>()!;
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).languageCode;
    final quotes = repo.forPack(pack, activeLocale: locale);

    return Scaffold(
      appBar: AppBar(
        title: Text(pack.localizedTitle(AppLocalizations.of(context))),
      ),
      // SafeArea(bottom) keeps the last grid row clear of the system nav bar
      // under Android edge-to-edge.
      body: SafeArea(
        top: false,
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 76,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemCount: quotes.length,
          itemBuilder: (context, i) {
            final quote = quotes[i];
            final solved = progress.isSolved(quote.id);
            return Material(
              color: solved
                  ? palette.success.withValues(alpha: .14)
                  : Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  context.read<GameController>().start(
                    quote,
                    daily: false,
                    packId: pack.id,
                    alreadySolved: solved,
                  );
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PuzzleScreen()),
                  );
                },
                child: Center(
                  child: solved
                      ? Icon(Icons.check, color: palette.success, size: 26)
                      : FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface.withValues(alpha: .75),
                            ),
                          ),
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
