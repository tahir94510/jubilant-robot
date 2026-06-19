import 'package:share_plus/share_plus.dart';

/// Sends the daily result share text. The text itself is composed by
/// the caller (which has a BuildContext) so it is localized to the player's
/// UI language; this service owns only time formatting and the platform
/// share sheet.
class ShareService {
  const ShareService();

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
