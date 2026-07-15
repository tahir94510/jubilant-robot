import 'package:flutter/material.dart';

/// Semantic colors the widgets actually reference, resolved per theme.
///
/// Semantic state colors come in a colorblind-safe variant selected via
/// settings, built on the Okabe-Ito palette: conflict/error go orange,
/// confirmed goes blue, hint-revealed goes plum, success goes blue — four
/// hues that stay mutually distinct for deutan, protan and tritan vision
/// (the default red/green/gold axis does not).
class GamePalette extends ThemeExtension<GamePalette> {
  const GamePalette({
    required this.boardCellBg,
    required this.boardCellSelectedBg,
    required this.boardCellRelatedBg,
    required this.boardCellFilledBg,
    required this.boardCellConfirmedBg,
    required this.boardCellLastMoveBg,
    required this.boardCellRevealedBg,
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

  /// "Just locked" fill: the cells of the word a guess just completed, until
  /// the next letter is placed. Same green family as [boardCellConfirmedBg] but
  /// a gentle step stronger, so the freshest letters read calmly above the older
  /// confirmed ones. A fill with NO border, so it never mimics the cursor frame
  /// or the faint "same-letter" cue. (A just-revealed HINT uses
  /// [boardCellRevealedBg] instead — see below.)
  final Color boardCellLastMoveBg;

  /// "Just revealed" fill for the cells a HINT just uncovered, until the next
  /// letter is placed. In the GOLD [revealed] family — NOT the green just-locked
  /// tint — so a hint's gold letter sits on a matching gold wash instead of the
  /// jarring gold-on-green clash (the low-contrast pairing players reported).
  /// A border-less fill, a gentle step under the gold text so the letter stays
  /// the most prominent thing in the cell.
  final Color boardCellRevealedBg;
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
  /// blue/orange ones, [highContrast] switches to the WCAG-AAA-tuned variant.
  static GamePalette light({
    bool colorblind = false,
    bool highContrast = false,
  }) => highContrast
      ? _lightHighContrast(colorblind)
      : GamePalette(
          boardCellBg: const Color(0x00000000),
          boardCellSelectedBg: const Color(0xFF936F1F).withValues(alpha: .16),
          boardCellRelatedBg: const Color(0xFF936F1F).withValues(alpha: .07),
          boardCellFilledBg: const Color(0xFF211E1A).withValues(alpha: .055),
          // Colorblind CONFIRMED moves to the Okabe-Ito BLUE family: the old
          // green swap (009E73) was indistinguishable from the normal teal for
          // deutan/protan players — the mode looked broken in-game. Blue is
          // unmistakable against the gold/orange axis for every CVD type.
          boardCellConfirmedBg:
              (colorblind ? const Color(0xFF0072B2) : const Color(0xFF1F7A6B))
                  .withValues(alpha: .10),
          // Just-locked = the SAME confirmed family, a gentle step stronger (.20 vs
          // .10) so the freshest letters read calmly above the older confirmed ones —
          // no jarring gold, fully on the confirmed family, distinct from the neutral
          // last-typed cue.
          boardCellLastMoveBg:
              (colorblind ? const Color(0xFF0072B2) : const Color(0xFF1F7A6B))
                  .withValues(alpha: .20),
          // Just-revealed HINT wash in the [revealed] family (gold normally,
          // plum in colorblind mode), so the hint letter reads on a matching
          // tint instead of clashing.
          boardCellRevealedBg:
              (colorblind ? const Color(0xFFA05480) : const Color(0xFF856414))
                  .withValues(alpha: .15),
          boardUnderline: const Color(0xFFC9BEA8),
          guessText: const Color(0xFF211E1A),
          cipherText: const Color(0xFF6B614D),
          // Colorblind conflict/error deepened (E69F00 read only 2.05:1 on this cream
          // surface — below the large-text floor); A84B00 clears AA (5.20:1).
          conflict: colorblind
              ? const Color(0xFFA84B00)
              : const Color(0xFF9E3B34),
          error: colorblind ? const Color(0xFFA84B00) : const Color(0xFF9E3B34),
          // Deepened from 936F1F (4.21:1) so the gold hint letters clear AA (4.99:1).
          // Colorblind hints leave the gold axis entirely (gold vs the orange
          // conflict is a classic deutan confusion pair) for an Okabe-Ito plum.
          revealed: colorblind
              ? const Color(0xFFA05480)
              : const Color(0xFF856414),
          confirmed: colorblind
              ? const Color(0xFF0072B2)
              : const Color(0xFF1B6E60),
          keyBg: const Color(0xFFFFFDF8),
          keyUsedBg: const Color(0xFFECE6D9),
          keyText: const Color(0xFF211E1A),
          keyUsedText: const Color(0xFF7C7263),
          keyDisabledText: const Color(0xFF6B6150),
          keyLockedBg: const Color(0xFFDCD3BF),
          success: colorblind
              ? const Color(0xFF0072B2)
              : const Color(0xFF55714A),
          streakFlame: const Color(0xFFB8791C),
          textSecondary: const Color(0xFF5C5849),
          textFaint: const Color(0xFF74705F),
        );

  /// High-contrast light: every readable token >= 7:1 (AAA normal text) and
  /// every large-glyph/icon token >= 4.5:1 on paper AND card, verified by
  /// contrast_test. Same Ink & Gold families, deepened; selection washes are
  /// stronger so the cursor and related cells pop for low-vision players.
  static GamePalette _lightHighContrast(bool colorblind) => GamePalette(
    boardCellBg: const Color(0x00000000),
    boardCellSelectedBg: const Color(0xFF6D5217).withValues(alpha: .24),
    boardCellRelatedBg: const Color(0xFF6D5217).withValues(alpha: .12),
    boardCellFilledBg: const Color(0xFF211E1A).withValues(alpha: .10),
    boardCellConfirmedBg:
        (colorblind ? const Color(0xFF0072B2) : const Color(0xFF1F7A6B))
            .withValues(alpha: .10),
    boardCellLastMoveBg:
        (colorblind ? const Color(0xFF0072B2) : const Color(0xFF1F7A6B))
            .withValues(alpha: .20),
    // Wash keyed to the AAA gold (plum in colorblind mode) so a just-revealed
    // letter stays >= 4.5:1 on its own tint.
    boardCellRevealedBg:
        (colorblind ? const Color(0xFFA05480) : const Color(0xFF684E10))
            .withValues(alpha: .15),
    boardUnderline: const Color(0xFF9F8B64), // >= 3:1 UI-component floor
    guessText: const Color(0xFF211E1A),
    cipherText: const Color(0xFF5B5241), // small text -> full AAA
    conflict: colorblind ? const Color(0xFF873C00) : const Color(0xFF8F352F),
    error: colorblind ? const Color(0xFF873C00) : const Color(0xFF8F352F),
    revealed: colorblind ? const Color(0xFF6E3350) : const Color(0xFF684E10),
    confirmed: colorblind ? const Color(0xFF00517F) : const Color(0xFF165C50),
    keyBg: const Color(0xFFFFFDF8),
    keyUsedBg: const Color(0xFFECE6D9),
    keyText: const Color(0xFF211E1A),
    keyUsedText: const Color(0xFF6F6659),
    keyDisabledText: const Color(0xFF645A4B),
    keyLockedBg: const Color(0xFFDCD3BF),
    success: colorblind ? const Color(0xFF005687) : const Color(0xFF42583A),
    streakFlame: const Color(0xFF996517),
    textSecondary: const Color(0xFF565344),
    textFaint: const Color(0xFF74705F),
  );

  static GamePalette dark({
    bool colorblind = false,
    bool highContrast = false,
  }) => highContrast
      ? _darkHighContrast(colorblind)
      : GamePalette(
          boardCellBg: const Color(0x00000000),
          boardCellSelectedBg: const Color(0xFFD9B25A).withValues(alpha: .22),
          boardCellRelatedBg: const Color(0xFFD9B25A).withValues(alpha: .10),
          boardCellFilledBg: const Color(0xFFF2EDE2).withValues(alpha: .07),
          // Colorblind confirmed/washes on the Okabe-Ito sky-blue axis (see the
          // light palette note): the old green swap was invisible to the very
          // players the mode serves.
          boardCellConfirmedBg:
              (colorblind ? const Color(0xFF3D9BD1) : const Color(0xFF5FC3AE))
                  .withValues(alpha: .14),
          // Just-locked = the confirmed family, a gentle step stronger (.26 vs .14)
          // — calm, on the confirmed family, no jarring gold.
          boardCellLastMoveBg:
              (colorblind ? const Color(0xFF3D9BD1) : const Color(0xFF5FC3AE))
                  .withValues(alpha: .26),
          // Just-revealed HINT wash in the [revealed] family (gold / cb pink).
          boardCellRevealedBg:
              (colorblind ? const Color(0xFFB26694) : const Color(0xFFD9B25A))
                  .withValues(alpha: .24),
          boardUnderline: const Color(0xFF4A453B),
          guessText: const Color(0xFFF2EDE2),
          cipherText: const Color(0xFF968B79),
          conflict: colorblind
              ? const Color(0xFFE69F00)
              : const Color(0xFFD8836E),
          error: colorblind ? const Color(0xFFE69F00) : const Color(0xFFD8836E),
          revealed: colorblind
              ? const Color(0xFFE8A9CC)
              : const Color(0xFFD9B25A),
          confirmed: colorblind
              ? const Color(0xFF6FC1F0)
              : const Color(0xFF6FC8B3),
          keyBg: const Color(0xFF262219),
          keyUsedBg: const Color(0xFF1A1712),
          keyText: const Color(0xFFF2EDE2),
          keyUsedText: const Color(0xFF807969),
          keyDisabledText: const Color(0xFF8E8473),
          keyLockedBg: const Color(0xFF322B1D),
          success: colorblind
              ? const Color(0xFF56B4E9)
              : const Color(0xFF9CB58A),
          streakFlame: const Color(0xFFE0A84A),
          textSecondary: const Color(0xFFB0A998),
          textFaint: const Color(0xFF8F8A7B),
        );

  /// High-contrast dark. The ink theme already clears AAA for most tokens
  /// (light-on-near-black is generous), so this variant only lifts the ones
  /// that sat between AA and AAA — cipher glyphs, used/disabled key text, the
  /// salmon conflict — and strengthens the underline + selection washes.
  static GamePalette _darkHighContrast(bool colorblind) => GamePalette(
    boardCellBg: const Color(0x00000000),
    boardCellSelectedBg: const Color(0xFFD9B25A).withValues(alpha: .30),
    boardCellRelatedBg: const Color(0xFFD9B25A).withValues(alpha: .14),
    boardCellFilledBg: const Color(0xFFF2EDE2).withValues(alpha: .10),
    boardCellConfirmedBg:
        (colorblind ? const Color(0xFF3D9BD1) : const Color(0xFF5FC3AE))
            .withValues(alpha: .14),
    boardCellLastMoveBg:
        (colorblind ? const Color(0xFF3D9BD1) : const Color(0xFF5FC3AE))
            .withValues(alpha: .26),
    boardCellRevealedBg:
        (colorblind ? const Color(0xFFB26694) : const Color(0xFFD9B25A))
            .withValues(alpha: .24),
    boardUnderline: const Color(0xFF696254), // >= 3:1 UI-component floor
    guessText: const Color(0xFFF2EDE2),
    cipherText: const Color(0xFFB1A99B), // small text -> full AAA
    conflict: colorblind ? const Color(0xFFE69F00) : const Color(0xFFDE9886),
    error: colorblind ? const Color(0xFFE69F00) : const Color(0xFFDE9886),
    revealed: colorblind
        ? const Color(0xFFF0BAD8)
        : const Color(0xFFD9B25A), // 9.1:1 already
    confirmed: colorblind ? const Color(0xFF8FD0FF) : const Color(0xFF6FC8B3),
    keyBg: const Color(0xFF262219),
    keyUsedBg: const Color(0xFF1A1712),
    keyText: const Color(0xFFF2EDE2),
    keyUsedText: const Color(0xFF87806F),
    keyDisabledText: const Color(0xFF9B9283),
    keyLockedBg: const Color(0xFF322B1D),
    success: colorblind ? const Color(0xFF56B4E9) : const Color(0xFF9CB58A),
    streakFlame: const Color(0xFFE0A84A),
    textSecondary: const Color(0xFFB0A998),
    textFaint: const Color(0xFF8F8A7B),
  );

  static GamePalette sepia({
    bool colorblind = false,
    bool highContrast = false,
  }) => highContrast
      ? _sepiaHighContrast(colorblind)
      : GamePalette(
          boardCellBg: const Color(0x00000000),
          boardCellSelectedBg: const Color(0xFF9C7B33).withValues(alpha: .20),
          boardCellRelatedBg: const Color(0xFF9C7B33).withValues(alpha: .08),
          boardCellFilledBg: const Color(0xFF3A2E1C).withValues(alpha: .06),
          // Colorblind confirmed/washes on the Okabe-Ito blue axis (see the
          // light palette note).
          boardCellConfirmedBg:
              (colorblind ? const Color(0xFF0072B2) : const Color(0xFF2F7D63))
                  .withValues(alpha: .10),
          // Just-locked = the confirmed family, a gentle step stronger (.20 vs .10) —
          // calm, on the confirmed family, no jarring gold.
          boardCellLastMoveBg:
              (colorblind ? const Color(0xFF0072B2) : const Color(0xFF2F7D63))
                  .withValues(alpha: .20),
          // Just-revealed HINT wash in the [revealed] family (gold / cb plum).
          boardCellRevealedBg:
              (colorblind ? const Color(0xFF96486F) : const Color(0xFF846423))
                  .withValues(alpha: .14),
          boardUnderline: const Color(0xFFC4AE8E),
          guessText: const Color(0xFF3A2E1C),
          cipherText: const Color(0xFF755F3F),
          // Colorblind conflict/error deepened (E69F00 read only 1.91:1 on this paper
          // surface); A84B00 clears AA (4.84:1).
          conflict: colorblind
              ? const Color(0xFFA84B00)
              : const Color(0xFFA4442F),
          error: colorblind ? const Color(0xFFA84B00) : const Color(0xFFA4442F),
          // Deepened from 8A6A2A (3.92:1) so the gold hint letters clear AA (4.64:1).
          // Colorblind hints move off the gold axis to an Okabe-Ito plum (see
          // the light palette note).
          revealed: colorblind
              ? const Color(0xFF96486F)
              : const Color(0xFF846423),
          confirmed: colorblind
              ? const Color(0xFF00639B)
              : const Color(0xFF276E58),
          keyBg: const Color(0xFFFBF3E4),
          keyUsedBg: const Color(0xFFE8D8BC),
          keyText: const Color(0xFF3A2E1C),
          keyUsedText: const Color(0xFF7E6A4B),
          keyDisabledText: const Color(0xFF6F5C3E),
          keyLockedBg: const Color(0xFFD8C6A3),
          // Greens deepened so both variants clear AA on sepia (normal 4.85, cb 6.33).
          success: colorblind
              ? const Color(0xFF00598C)
              : const Color(0xFF516E45),
          streakFlame: const Color(0xFFA9650F),
          textSecondary: const Color(0xFF5E5036),
          textFaint: const Color(0xFF756347),
        );

  /// High-contrast sepia: the reading-lamp paper keeps its warmth while every
  /// readable token reaches AAA (>= 7:1) and large glyphs/icons >= 4.5:1.
  static GamePalette _sepiaHighContrast(bool colorblind) => GamePalette(
    boardCellBg: const Color(0x00000000),
    boardCellSelectedBg: const Color(0xFF6C531F).withValues(alpha: .26),
    boardCellRelatedBg: const Color(0xFF6C531F).withValues(alpha: .12),
    boardCellFilledBg: const Color(0xFF3A2E1C).withValues(alpha: .10),
    boardCellConfirmedBg:
        (colorblind ? const Color(0xFF0072B2) : const Color(0xFF2F7D63))
            .withValues(alpha: .10),
    boardCellLastMoveBg:
        (colorblind ? const Color(0xFF0072B2) : const Color(0xFF2F7D63))
            .withValues(alpha: .20),
    // Wash keyed to the AAA gold (plum in colorblind mode; 5.71 measured
    // letter-on-wash for the gold).
    boardCellRevealedBg:
        (colorblind ? const Color(0xFF96486F) : const Color(0xFF624A1A))
            .withValues(alpha: .14),
    boardUnderline: const Color(0xFFA28254), // >= 3:1 UI-component floor
    guessText: const Color(0xFF3A2E1C),
    cipherText: const Color(0xFF5C4B32), // small text -> full AAA
    conflict: colorblind ? const Color(0xFF7F3900) : const Color(0xFF823625),
    error: colorblind ? const Color(0xFF7F3900) : const Color(0xFF823625),
    revealed: colorblind ? const Color(0xFF632D47) : const Color(0xFF624A1A),
    confirmed: colorblind ? const Color(0xFF004C77) : const Color(0xFF1F5746),
    keyBg: const Color(0xFFFBF3E4),
    keyUsedBg: const Color(0xFFE8D8BC),
    keyText: const Color(0xFF3A2E1C),
    keyUsedText: const Color(0xFF6E5D41),
    keyDisabledText: const Color(0xFF625137),
    keyLockedBg: const Color(0xFFD8C6A3),
    success: colorblind ? const Color(0xFF00517F) : const Color(0xFF3D5334),
    streakFlame: const Color(0xFF995B0E),
    textSecondary: const Color(0xFF594C33),
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
    Color? boardCellRevealedBg,
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
    boardCellRevealedBg: boardCellRevealedBg ?? this.boardCellRevealedBg,
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
      boardCellRevealedBg: Color.lerp(
        boardCellRevealedBg,
        other.boardCellRevealedBg,
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
