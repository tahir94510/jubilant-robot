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
    required this.boardCellFilledBg,
    required this.boardCellConfirmedBg,
    required this.boardCellLastMoveBg,
    required this.boardUnderline,
    required this.guessText,
    required this.cipherText,
    required this.conflict,
    required this.error,
    required this.revealed,
    required this.confirmed,
    required this.keyBg,
    required this.keyUsedBg,
    required this.keyText,
    required this.keyUsedText,
    required this.keyDisabledText,
    required this.keyLockedBg,
    required this.success,
    required this.streakFlame,
    required this.textSecondary,
    required this.textFaint,
  });

  final Color boardCellBg;
  final Color boardCellSelectedBg;
  final Color boardCellRelatedBg;

  /// Faint fill behind a cell the PLAYER has filled in (not a hint), so your
  /// own entries read as present at a glance instead of blending into empty
  /// slots. Intentionally neutral — it marks "you typed here", never whether
  /// the guess is right (that would spoil the puzzle).
  final Color boardCellFilledBg;

  /// Faint tint behind a cell whose letter is part of a fully-correct word —
  /// a calm, on-brand backdrop for the [confirmed] state.
  final Color boardCellConfirmedBg;

  /// "Last move" fill (chess-style): the cell holding the most-recently-placed
  /// letter — by typing OR by a hint reveal — until the next letter is placed.
  /// Carried as a FILL with no border so it never blends into the cursor frame
  /// or the faint "same-letter" sibling cue.
  final Color boardCellLastMoveBg;
  final Color boardUnderline;
  final Color guessText;
  final Color cipherText;
  final Color conflict;
  final Color error;
  final Color revealed;

  /// Letters the player has locked in by completing a whole word correctly.
  /// Deliberately distinct from [revealed] (hint gold) and from [success] (the
  /// transient solve wave), and kept colorblind-safe in that variant, so a
  /// confirmed word never blends into surrounding guesses.
  final Color confirmed;
  final Color keyBg;
  final Color keyUsedBg;
  final Color keyText;
  final Color keyUsedText;

  /// Glyph color for a DISABLED key — a hint/confirmed answer the player can no
  /// longer place. A solid token (not a translucent [keyUsedText]) so it stays
  /// legible at ≥3:1 on [keyUsedBg] in every theme, locked by contrast_test;
  /// the earlier `keyUsedText.withValues(alpha: .4)` read ~1.6:1.
  final Color keyDisabledText;

  /// Background for a LOCKED key, distinct from [keyUsedBg] so a locked
  /// (confirmed/hint) letter never reads the same as a still-tappable USED one.
  /// Three clear tiers: unused ([keyBg]) > used ([keyUsedBg]) > locked.
  final Color keyLockedBg;
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
    boardCellFilledBg: const Color(0xFF211E1A).withValues(alpha: .055),
    boardCellConfirmedBg:
        (colorblind ? const Color(0xFF009E73) : const Color(0xFF1F7A6B))
            .withValues(alpha: .10),
    boardCellLastMoveBg: const Color(0xFF936F1F).withValues(alpha: .15),
    boardUnderline: const Color(0xFFC9BEA8),
    guessText: const Color(0xFF211E1A),
    cipherText: const Color(0xFF8A7E66),
    // Colorblind conflict/error deepened (E69F00 read only 2.05:1 on this cream
    // surface — below the large-text floor); A84B00 clears AA (5.20:1).
    conflict: colorblind ? const Color(0xFFA84B00) : const Color(0xFF9E3B34),
    error: colorblind ? const Color(0xFFA84B00) : const Color(0xFF9E3B34),
    // Deepened from 936F1F (4.21:1) so the gold hint letters clear AA (4.99:1).
    revealed: const Color(0xFF856414),
    confirmed: colorblind ? const Color(0xFF00795C) : const Color(0xFF1B6E60),
    keyBg: const Color(0xFFFFFDF8),
    keyUsedBg: const Color(0xFFECE6D9),
    keyText: const Color(0xFF211E1A),
    keyUsedText: const Color(0xFF7C7263),
    keyDisabledText: const Color(0xFF6B6150),
    keyLockedBg: const Color(0xFFDCD3BF),
    success: colorblind ? const Color(0xFF0072B2) : const Color(0xFF55714A),
    streakFlame: const Color(0xFFB8791C),
    textSecondary: const Color(0xFF5C5849),
    textFaint: const Color(0xFF74705F),
  );

  static GamePalette dark({bool colorblind = false}) => GamePalette(
    boardCellBg: const Color(0x00000000),
    boardCellSelectedBg: const Color(0xFFD9B25A).withValues(alpha: .22),
    boardCellRelatedBg: const Color(0xFFD9B25A).withValues(alpha: .10),
    boardCellFilledBg: const Color(0xFFF2EDE2).withValues(alpha: .07),
    boardCellConfirmedBg:
        (colorblind ? const Color(0xFF56C0A2) : const Color(0xFF5FC3AE))
            .withValues(alpha: .14),
    boardCellLastMoveBg: const Color(0xFFD9B25A).withValues(alpha: .17),
    boardUnderline: const Color(0xFF4A453B),
    guessText: const Color(0xFFF2EDE2),
    cipherText: const Color(0xFF968B79),
    conflict: colorblind ? const Color(0xFFE69F00) : const Color(0xFFD8836E),
    error: colorblind ? const Color(0xFFE69F00) : const Color(0xFFD8836E),
    revealed: const Color(0xFFD9B25A),
    confirmed: colorblind ? const Color(0xFF4FD6B6) : const Color(0xFF6FC8B3),
    keyBg: const Color(0xFF262219),
    keyUsedBg: const Color(0xFF1A1712),
    keyText: const Color(0xFFF2EDE2),
    keyUsedText: const Color(0xFF807969),
    keyDisabledText: const Color(0xFF8E8473),
    keyLockedBg: const Color(0xFF322B1D),
    success: colorblind ? const Color(0xFF56B4E9) : const Color(0xFF9CB58A),
    streakFlame: const Color(0xFFE0A84A),
    textSecondary: const Color(0xFFB0A998),
    textFaint: const Color(0xFF8F8A7B),
  );

  static GamePalette sepia({bool colorblind = false}) => GamePalette(
    boardCellBg: const Color(0x00000000),
    boardCellSelectedBg: const Color(0xFF9C7B33).withValues(alpha: .20),
    boardCellRelatedBg: const Color(0xFF9C7B33).withValues(alpha: .08),
    boardCellFilledBg: const Color(0xFF3A2E1C).withValues(alpha: .06),
    boardCellConfirmedBg:
        (colorblind ? const Color(0xFF009E73) : const Color(0xFF2F7D63))
            .withValues(alpha: .10),
    boardCellLastMoveBg: const Color(0xFF9C7B33).withValues(alpha: .15),
    boardUnderline: const Color(0xFFC4AE8E),
    guessText: const Color(0xFF3A2E1C),
    cipherText: const Color(0xFF755F3F),
    // Colorblind conflict/error deepened (E69F00 read only 1.91:1 on this paper
    // surface); A84B00 clears AA (4.84:1).
    conflict: colorblind ? const Color(0xFFA84B00) : const Color(0xFFA4442F),
    error: colorblind ? const Color(0xFFA84B00) : const Color(0xFFA4442F),
    // Deepened from 8A6A2A (3.92:1) so the gold hint letters clear AA (4.64:1).
    revealed: const Color(0xFF846423),
    confirmed: colorblind ? const Color(0xFF00795C) : const Color(0xFF276E58),
    keyBg: const Color(0xFFFBF3E4),
    keyUsedBg: const Color(0xFFE8D8BC),
    keyText: const Color(0xFF3A2E1C),
    keyUsedText: const Color(0xFF7E6A4B),
    keyDisabledText: const Color(0xFF6F5C3E),
    keyLockedBg: const Color(0xFFD8C6A3),
    // Greens deepened so both variants clear AA on sepia (normal 4.85, cb 6.33).
    success: colorblind ? const Color(0xFF00598C) : const Color(0xFF516E45),
    streakFlame: const Color(0xFFA9650F),
    textSecondary: const Color(0xFF5E5036),
    textFaint: const Color(0xFF756347),
  );

  @override
  GamePalette copyWith({
    Color? boardCellBg,
    Color? boardCellSelectedBg,
    Color? boardCellRelatedBg,
    Color? boardCellFilledBg,
    Color? boardCellConfirmedBg,
    Color? boardCellLastMoveBg,
    Color? boardUnderline,
    Color? guessText,
    Color? cipherText,
    Color? conflict,
    Color? error,
    Color? revealed,
    Color? confirmed,
    Color? keyBg,
    Color? keyUsedBg,
    Color? keyText,
    Color? keyUsedText,
    Color? keyDisabledText,
    Color? keyLockedBg,
    Color? success,
    Color? streakFlame,
    Color? textSecondary,
    Color? textFaint,
  }) => GamePalette(
    boardCellBg: boardCellBg ?? this.boardCellBg,
    boardCellSelectedBg: boardCellSelectedBg ?? this.boardCellSelectedBg,
    boardCellRelatedBg: boardCellRelatedBg ?? this.boardCellRelatedBg,
    boardCellFilledBg: boardCellFilledBg ?? this.boardCellFilledBg,
    boardCellConfirmedBg: boardCellConfirmedBg ?? this.boardCellConfirmedBg,
    boardCellLastMoveBg: boardCellLastMoveBg ?? this.boardCellLastMoveBg,
    boardUnderline: boardUnderline ?? this.boardUnderline,
    guessText: guessText ?? this.guessText,
    cipherText: cipherText ?? this.cipherText,
    conflict: conflict ?? this.conflict,
    error: error ?? this.error,
    revealed: revealed ?? this.revealed,
    confirmed: confirmed ?? this.confirmed,
    keyBg: keyBg ?? this.keyBg,
    keyUsedBg: keyUsedBg ?? this.keyUsedBg,
    keyText: keyText ?? this.keyText,
    keyUsedText: keyUsedText ?? this.keyUsedText,
    keyDisabledText: keyDisabledText ?? this.keyDisabledText,
    keyLockedBg: keyLockedBg ?? this.keyLockedBg,
    success: success ?? this.success,
    streakFlame: streakFlame ?? this.streakFlame,
    textSecondary: textSecondary ?? this.textSecondary,
    textFaint: textFaint ?? this.textFaint,
  );

  // Real interpolation so theme/colorblind switches cross-fade cohesively:
  // MaterialApp's AnimatedTheme drives this, and a no-op lerp snapped the board
  // and keyboard colors while the Material surfaces faded (a ~200ms mismatch).
  @override
  GamePalette lerp(ThemeExtension<GamePalette>? other, double t) {
    if (other is! GamePalette) return this;
    return GamePalette(
      boardCellBg: Color.lerp(boardCellBg, other.boardCellBg, t)!,
      boardCellSelectedBg: Color.lerp(
        boardCellSelectedBg,
        other.boardCellSelectedBg,
        t,
      )!,
      boardCellRelatedBg: Color.lerp(
        boardCellRelatedBg,
        other.boardCellRelatedBg,
        t,
      )!,
      boardCellFilledBg: Color.lerp(
        boardCellFilledBg,
        other.boardCellFilledBg,
        t,
      )!,
      boardCellConfirmedBg: Color.lerp(
        boardCellConfirmedBg,
        other.boardCellConfirmedBg,
        t,
      )!,
      boardCellLastMoveBg: Color.lerp(
        boardCellLastMoveBg,
        other.boardCellLastMoveBg,
        t,
      )!,
      boardUnderline: Color.lerp(boardUnderline, other.boardUnderline, t)!,
      guessText: Color.lerp(guessText, other.guessText, t)!,
      cipherText: Color.lerp(cipherText, other.cipherText, t)!,
      conflict: Color.lerp(conflict, other.conflict, t)!,
      error: Color.lerp(error, other.error, t)!,
      revealed: Color.lerp(revealed, other.revealed, t)!,
      confirmed: Color.lerp(confirmed, other.confirmed, t)!,
      keyBg: Color.lerp(keyBg, other.keyBg, t)!,
      keyUsedBg: Color.lerp(keyUsedBg, other.keyUsedBg, t)!,
      keyText: Color.lerp(keyText, other.keyText, t)!,
      keyUsedText: Color.lerp(keyUsedText, other.keyUsedText, t)!,
      keyDisabledText: Color.lerp(keyDisabledText, other.keyDisabledText, t)!,
      keyLockedBg: Color.lerp(keyLockedBg, other.keyLockedBg, t)!,
      success: Color.lerp(success, other.success, t)!,
      streakFlame: Color.lerp(streakFlame, other.streakFlame, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textFaint: Color.lerp(textFaint, other.textFaint, t)!,
    );
  }
}
