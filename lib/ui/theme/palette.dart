import 'package:flutter/material.dart';

/// Semantic colors the widgets actually reference, resolved per theme.
///
/// Conflict/error/reveal colors come in a colorblind-safe variant
/// (blue/orange instead of red/green) selected via settings.
class GamePalette extends ThemeExtension<GamePalette> {
  const GamePalette({
    required this.boardCellBg,
    required this.boardCellSelectedBg,
    required this.boardCellRelatedBg,
    required this.boardUnderline,
    required this.guessText,
    required this.cipherText,
    required this.conflict,
    required this.error,
    required this.revealed,
    required this.keyBg,
    required this.keyUsedBg,
    required this.keyText,
    required this.keyUsedText,
    required this.success,
    required this.streakFlame,
    required this.textSecondary,
    required this.textFaint,
  });

  final Color boardCellBg;
  final Color boardCellSelectedBg;
  final Color boardCellRelatedBg;
  final Color boardUnderline;
  final Color guessText;
  final Color cipherText;
  final Color conflict;
  final Color error;
  final Color revealed;
  final Color keyBg;
  final Color keyUsedBg;
  final Color keyText;
  final Color keyUsedText;
  final Color success;
  final Color streakFlame;

  /// Readable secondary text (subtitles, captions) — tuned to clear WCAG AA
  /// (>= 4.5:1) on each theme's surface. Replaces ad-hoc
  /// `onSurface.withValues(alpha: < .6)` which failed AA, worst in sepia.
  final Color textSecondary;

  /// De-emphasised but still legible text/icons (>= 3:1) for large or
  /// decorative labels where full secondary weight would be too heavy.
  final Color textFaint;

  // "Ink & Gold" identity: warm ink/charcoal surfaces, champagne-gold accents
  // (replacing the old slate-blue), and a refined garnet for conflicts/errors
  // (replacing the garish coral). One accent family across every theme keeps
  // the brand consistent everywhere.

  /// Standard accents; [colorblind] swaps red/green semantics for
  /// blue/orange ones.
  static GamePalette light({bool colorblind = false}) => GamePalette(
    boardCellBg: const Color(0x00000000),
    boardCellSelectedBg: const Color(0xFF936F1F).withValues(alpha: .16),
    boardCellRelatedBg: const Color(0xFF936F1F).withValues(alpha: .07),
    boardUnderline: const Color(0xFFC9BEA8),
    guessText: const Color(0xFF211E1A),
    cipherText: const Color(0xFF8A7E66),
    conflict: colorblind ? const Color(0xFFE69F00) : const Color(0xFF9E3B34),
    error: colorblind ? const Color(0xFFE69F00) : const Color(0xFF9E3B34),
    revealed: const Color(0xFF936F1F),
    keyBg: const Color(0xFFFFFDF8),
    keyUsedBg: const Color(0xFFECE6D9),
    keyText: const Color(0xFF211E1A),
    keyUsedText: const Color(0xFF8E8475),
    success: colorblind ? const Color(0xFF0072B2) : const Color(0xFF5E7B52),
    streakFlame: const Color(0xFFB8791C),
    textSecondary: const Color(0xFF5C5849),
    textFaint: const Color(0xFF74705F),
  );

  static GamePalette dark({bool colorblind = false}) => GamePalette(
    boardCellBg: const Color(0x00000000),
    boardCellSelectedBg: const Color(0xFFD9B25A).withValues(alpha: .22),
    boardCellRelatedBg: const Color(0xFFD9B25A).withValues(alpha: .10),
    boardUnderline: const Color(0xFF4A453B),
    guessText: const Color(0xFFF2EDE2),
    cipherText: const Color(0xFF968B79),
    conflict: colorblind ? const Color(0xFFE69F00) : const Color(0xFFD8836E),
    error: colorblind ? const Color(0xFFE69F00) : const Color(0xFFD8836E),
    revealed: const Color(0xFFD9B25A),
    keyBg: const Color(0xFF262219),
    keyUsedBg: const Color(0xFF1A1712),
    keyText: const Color(0xFFF2EDE2),
    keyUsedText: const Color(0xFF6E6859),
    success: colorblind ? const Color(0xFF56B4E9) : const Color(0xFF9CB58A),
    streakFlame: const Color(0xFFE0A84A),
    textSecondary: const Color(0xFFB0A998),
    textFaint: const Color(0xFF8F8A7B),
  );

  static GamePalette sepia({bool colorblind = false}) => GamePalette(
    boardCellBg: const Color(0x00000000),
    boardCellSelectedBg: const Color(0xFF9C7B33).withValues(alpha: .20),
    boardCellRelatedBg: const Color(0xFF9C7B33).withValues(alpha: .08),
    boardUnderline: const Color(0xFFC4AE8E),
    guessText: const Color(0xFF3A2E1C),
    cipherText: const Color(0xFF755F3F),
    conflict: colorblind ? const Color(0xFFE69F00) : const Color(0xFFA4442F),
    error: colorblind ? const Color(0xFFE69F00) : const Color(0xFFA4442F),
    revealed: const Color(0xFF8A6A2A),
    keyBg: const Color(0xFFFBF3E4),
    keyUsedBg: const Color(0xFFE8D8BC),
    keyText: const Color(0xFF3A2E1C),
    keyUsedText: const Color(0xFF95805F),
    success: colorblind ? const Color(0xFF0072B2) : const Color(0xFF5F7E46),
    streakFlame: const Color(0xFFA9650F),
    textSecondary: const Color(0xFF5E5036),
    textFaint: const Color(0xFF756347),
  );

  @override
  GamePalette copyWith() => this;

  @override
  GamePalette lerp(ThemeExtension<GamePalette>? other, double t) =>
      other is GamePalette ? other : this;
}
