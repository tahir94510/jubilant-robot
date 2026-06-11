import 'package:share_plus/share_plus.dart';

import '../config/app_config.dart';

/// Builds and sends the Wordle-style daily share text.
class ShareService {
  const ShareService();

  /// e.g.  Quotecrack #162 — solved in 3:42, 0 hints  🔥 12 day streak
  String buildDailyShareText({
    required int puzzleNumber,
    required Duration solveTime,
    required int hintsUsed,
    required int streak,
  }) {
    final m = solveTime.inMinutes;
    final s = (solveTime.inSeconds % 60).toString().padLeft(2, '0');
    final hints = hintsUsed == 0
        ? 'no hints'
        : '$hintsUsed hint${hintsUsed == 1 ? '' : 's'}';
    final streakPart = streak >= 2 ? '  \u{1F525} $streak day streak' : '';
    return '${AppConfig.appName} #$puzzleNumber \u{2014} '
        'solved in $m:$s, $hints$streakPart\n'
        '${AppConfig.listingUrl}';
  }

  Future<void> share(String text) =>
      SharePlus.instance.share(ShareParams(text: text));
}
