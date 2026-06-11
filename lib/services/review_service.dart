import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

/// Asks for a Play Store rating once, after the player has demonstrably
/// enjoyed the game (N solves). Organic ratings are an ASO ranking input,
/// so this matters for discoverability.
class ReviewService {
  static const String _askedKey = 'review.asked';

  Future<void> maybeRequestReview({required int totalSolved}) async {
    if (kIsWeb) return;
    if (totalSolved != AppConfig.reviewPromptAfterSolves) return;

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_askedKey) ?? false) return;
    await prefs.setBool(_askedKey, true);

    final review = InAppReview.instance;
    if (await review.isAvailable()) {
      await review.requestReview();
    }
  }
}
