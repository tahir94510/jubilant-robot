import 'package:share_plus/share_plus.dart';

import '../config/app_config.dart';

/// Builds and sends the Wordle-style daily share text.
class ShareService {
  const ShareService();

  /// e.g.  Quotecrack #162 · solved in 3:42, no hints  🔥 12 day streak
  String buildDailyShareText({
    required int puzzleNumber,
    required Duration solveTime,
    required int hintsUsed,
    required int streak,
  }) {
    final hints = hintsUsed == 0
        ? 'no hints'
        : '$hintsUsed hint${hintsUsed == 1 ? '' : 's'}';
    final streakPart = streak >= 2 ? '  \u{1F525} $streak day streak' : '';
    return '${AppConfig.appName} #$puzzleNumber \u{00B7} '
        'solved in ${formatSolveTime(solveTime)}, $hints$streakPart\n'
        '${AppConfig.listingUrl}';
  }

  /// "3:42", or "1:05:03" once a solve runs past an hour, so the minutes
  /// field never shows an out-of-range value like "72:14".
  static String formatSolveTime(Duration d) {
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    if (d.inHours > 0) {
      final m = (d.inMinutes % 60).toString().padLeft(2, '0');
      return '${d.inHours}:$m:$s';
    }
    return '${d.inMinutes}:$s';
  }

  Future<void> share(String text) =>
      SharePlus.instance.share(ShareParams(text: text));
}
