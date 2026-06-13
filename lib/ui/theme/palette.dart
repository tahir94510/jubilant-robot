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

  /// Standard accents; [colorblind] swaps red/green semantics for
  /// blue/orange ones.
  static GamePalette light({bool colorblind = false}) => GamePalette(
    boardCellBg: const Color(0x00000000),
    boardCellSelectedBg: const Color(0xFF3D5A80).withValues(alpha: .18),
    boardCellRelatedBg: const Color(0xFF3D5A80).withValues(alpha: .08),
    boardUnderline: const Color(0xFFB9B2A6),
    guessText: const Color(0xFF23262B),
    cipherText: const Color(0xFF726A5B),
    conflict: colorblind ? const Color(0xFFE69F00) : const Color(0xFFC25E4C),
    error: colorblind ? const Color(0xFFE69F00) : const Color(0xFFC25E4C),
    revealed: const Color(0xFF3D5A80),
    keyBg: const Color(0xFFFFFFFF),
    keyUsedBg: const Color(0xFFE9E4DA),
    keyText: const Color(0xFF23262B),
    keyUsedText: const Color(0xFF8E877A),
    success: colorblind ? const Color(0xFF0072B2) : const Color(0xFF5B8C5A),
    streakFlame: const Color(0xFFB8691C),
    textSecondary: const Color(0xFF5F6065),
    textFaint: const Color(0xFF74757A),
  );

  static GamePalette dark({bool colorblind = false}) => GamePalette(
    boardCellBg: const Color(0x00000000),
    boardCellSelectedBg: const Color(0xFF98C1D9).withValues(alpha: .26),
    boardCellRelatedBg: const Color(0xFF98C1D9).withValues(alpha: .10),
    boardUnderline: const Color(0xFF4A4F58),
    guessText: const Color(0xFFECEFF4),
    cipherText: const Color(0xFF868C97),
    conflict: colorblind ? const Color(0xFFE69F00) : const Color(0xFFE07A5F),
    error: colorblind ? const Color(0xFFE69F00) : const Color(0xFFE07A5F),
    revealed: const Color(0xFF98C1D9),
    keyBg: const Color(0xFF262B33),
    keyUsedBg: const Color(0xFF1A1E24),
    keyText: const Color(0xFFECEFF4),
    keyUsedText: const Color(0xFF6E7682),
    success: colorblind ? const Color(0xFF56B4E9) : const Color(0xFF81B29A),
    streakFlame: const Color(0xFFE8A03E),
    textSecondary: const Color(0xFFA6AAB2),
    textFaint: const Color(0xFF8A8E96),
  );

  static GamePalette sepia({bool colorblind = false}) => GamePalette(
    boardCellBg: const Color(0x00000000),
    boardCellSelectedBg: const Color(0xFF8B5E34).withValues(alpha: .20),
    boardCellRelatedBg: const Color(0xFF8B5E34).withValues(alpha: .08),
    boardUnderline: const Color(0xFFC4AE8E),
    guessText: const Color(0xFF42351F),
    cipherText: const Color(0xFF755F3F),
    conflict: colorblind ? const Color(0xFFE69F00) : const Color(0xFFB1503C),
    error: colorblind ? const Color(0xFFE69F00) : const Color(0xFFB1503C),
    revealed: const Color(0xFF6E4E23),
    keyBg: const Color(0xFFFBF3E4),
    keyUsedBg: const Color(0xFFE5D5BB),
    keyText: const Color(0xFF42351F),
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
