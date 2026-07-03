import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quotecrack/config/app_config.dart';
import 'package:quotecrack/services/review_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Locks the one-time review prompt: it fires exactly once, exactly at the
/// Nth lifetime solve, and a plugin failure can never re-arm it (the asked
/// flag is persisted BEFORE the store dialog is attempted).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('dev.britannio.in_app_review');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  var requestReviewCalls = 0;

  /// Answers the in_app_review plugin's platform channel like a device where
  /// the review dialog is available, counting actual requests.
  void mockReviewChannel() {
    messenger.setMockMethodCallHandler(channel, (call) async {
      switch (call.method) {
        case 'isAvailable':
          return true;
        case 'requestReview':
          requestReviewCalls++;
          return null;
      }
      return null;
    });
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    requestReviewCalls = 0;
    mockReviewChannel();
  });

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('does not prompt before or after the Nth solve', () async {
    final service = ReviewService();
    await service.maybeRequestReview(
      totalSolved: AppConfig.reviewPromptAfterSolves - 1,
    );
    await service.maybeRequestReview(
      totalSolved: AppConfig.reviewPromptAfterSolves + 1,
    );

    expect(requestReviewCalls, 0);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('review.asked'), isNull);
  });

  test('prompts exactly once at the Nth solve and persists the flag', () async {
    final service = ReviewService();
    await service.maybeRequestReview(
      totalSolved: AppConfig.reviewPromptAfterSolves,
    );

    expect(requestReviewCalls, 1);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('review.asked'), isTrue);
  });

  test('never re-prompts once the asked flag is set', () async {
    SharedPreferences.setMockInitialValues({'review.asked': true});
    final service = ReviewService();
    await service.maybeRequestReview(
      totalSolved: AppConfig.reviewPromptAfterSolves,
    );

    expect(requestReviewCalls, 0);
  });

  test(
    'a plugin failure is swallowed and still consumes the one shot',
    () async {
      // No channel mock: the plugin call throws MissingPluginException. The
      // gameplay flow must never see it, and because the flag is written BEFORE
      // the store dialog is attempted, the prompt is spent — a flaky plugin
      // can't turn a one-time ask into a recurring nag.
      messenger.setMockMethodCallHandler(channel, null);

      final service = ReviewService();
      await expectLater(
        service.maybeRequestReview(
          totalSolved: AppConfig.reviewPromptAfterSolves,
        ),
        completes,
      );

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('review.asked'), isTrue);
    },
  );
}
