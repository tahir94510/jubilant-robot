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

  /// Standard accents; [colorblind] swaps red/green semantics for
  /// blue/orange ones.
  static GamePalette light({bool colorblind = false}) => GamePalette(
        boardCellBg: const Color(0x00000000),
        boardCellSelectedBg: const Color(0xFF3D5A80).withValues(alpha: .18),
        boardCellRelatedBg: const Color(0xFF3D5A80).withValues(alpha: .08),
        boardUnderline: const Color(0xFFB9B2A6),
        guessText: const Color(0xFF23262B),
        cipherText: const Color(0xFF8D8678),
        conflict: colorblind ? const Color(0xFFE69F00) : const Color(0xFFC25E4C),
        error: colorblind ? const Color(0xFFE69F00) : const Color(0xFFC25E4C),
        revealed: const Color(0xFF3D5A80),
        keyBg: const Color(0xFFFFFFFF),
        keyUsedBg: const Color(0xFFE9E4DA),
        keyText: const Color(0xFF23262B),
        keyUsedText: const Color(0xFFB0A899),
        success: colorblind ? const Color(0xFF0072B2) : const Color(0xFF5B8C5A),
        streakFlame: const Color(0xFFD9822B),
      );

  static GamePalette dark({bool colorblind = false}) => GamePalette(
        boardCellBg: const Color(0x00000000),
        boardCellSelectedBg: const Color(0xFF98C1D9).withValues(alpha: .26),
        boardCellRelatedBg: const Color(0xFF98C1D9).withValues(alpha: .10),
        boardUnderline: const Color(0xFF4A4F58),
        guessText: const Color(0xFFECEFF4),
        cipherText: const Color(0xFF7C828D),
        conflict: colorblind ? const Color(0xFFE69F00) : const Color(0xFFE07A5F),
        error: colorblind ? const Color(0xFFE69F00) : const Color(0xFFE07A5F),
        revealed: const Color(0xFF98C1D9),
        keyBg: const Color(0xFF262B33),
        keyUsedBg: const Color(0xFF1A1E24),
        keyText: const Color(0xFFECEFF4),
        keyUsedText: const Color(0xFF555B66),
        success: colorblind ? const Color(0xFF56B4E9) : const Color(0xFF81B29A),
        streakFlame: const Color(0xFFE8A03E),
      );

  static GamePalette sepia({bool colorblind = false}) => GamePalette(
        boardCellBg: const Color(0x00000000),
        boardCellSelectedBg: const Color(0xFF8B5E34).withValues(alpha: .20),
        boardCellRelatedBg: const Color(0xFF8B5E34).withValues(alpha: .08),
        boardUnderline: const Color(0xFFC4AE8E),
        guessText: const Color(0xFF42351F),
        cipherText: const Color(0xFFA08B6B),
        conflict: colorblind ? const Color(0xFFE69F00) : const Color(0xFFB1503C),
        error: colorblind ? const Color(0xFFE69F00) : const Color(0xFFB1503C),
        revealed: const Color(0xFF6E4E23),
        keyBg: const Color(0xFFFBF3E4),
        keyUsedBg: const Color(0xFFE5D5BB),
        keyText: const Color(0xFF42351F),
        keyUsedText: const Color(0xFFB59F7E),
        success: colorblind ? const Color(0xFF0072B2) : const Color(0xFF5F7E46),
        streakFlame: const Color(0xFFC07A22),
      );

  @override
  GamePalette copyWith() => this;

  @override
  GamePalette lerp(ThemeExtension<GamePalette>? other, double t) =>
      other is GamePalette ? other : this;
}
