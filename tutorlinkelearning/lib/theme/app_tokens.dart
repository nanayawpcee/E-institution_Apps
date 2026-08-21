import 'package:flutter/material.dart';

/// Design tokens transcribed from `TutorLink.dc.html`. Every value here has a direct
/// counterpart in that document — keep the two in step when the design moves.
@immutable
class TLTokens extends ThemeExtension<TLTokens> {
  const TLTokens({
    required this.bg,
    required this.card,
    required this.cardAlt,
    required this.text,
    required this.textSub,
    required this.border,
    required this.input,
    required this.navBg,
    required this.sheet,
    required this.overlay,
  });

  /// Screen background behind every surface.
  final Color bg;

  /// Raised surface: list cards, panels, menu groups.
  final Color card;

  /// Recessed surface: chips, icon buttons, review cards, tinted wells.
  final Color cardAlt;

  final Color text;
  final Color textSub;
  final Color border;

  /// Field fill.
  final Color input;

  /// Translucent ground behind the frosted bottom navigation.
  final Color navBg;

  /// Bottom-sheet and dialog surface.
  final Color sheet;

  /// Scrim behind sheets and dialogs.
  final Color overlay;

  // ── Accents ────────────────────────────────────────────────────────────
  // The design uses the same accent hexes in light and dark, so they are
  // statics rather than instance fields.
  static const Color primary = Color(0xFF66328E);
  static const Color accent = Color(0xFF6F35A5);
  static const Color danger = Color(0xFFE5484D);
  static const Color success = Color(0xFF2FA84F);
  static const Color warning = Color(0xFFFFC933);

  /// Tinted grounds for the status pills on My Courses.
  static const Color activeTint = Color(0xFFEDE6F7);
  static const Color pendingTint = Color(0xFFFFF4D9);
  static const Color pendingInk = Color(0xFFB8860B);
  static const Color completedTint = Color(0xFFE6F7EA);

  static const Gradient brandGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomRight,
    colors: [primary, accent],
  );

  // ── Radii ──────────────────────────────────────────────────────────────
  static const double rSm = 10;
  static const double rMd = 12;
  static const double rLg = 16;
  static const double rXl = 18;
  static const double rXxl = 24;

  static const TLTokens light = TLTokens(
    bg: Color(0xFFF6F7FB),
    card: Color(0xFFFFFFFF),
    cardAlt: Color(0xFFF1E6FF),
    text: Color(0xFF25282B),
    textSub: Color(0xFF7C8189),
    border: Color(0xFFE7E9EE),
    input: Color(0xFFFFFFFF),
    navBg: Color(0xEBFFFFFF),
    sheet: Color(0xFFFFFFFF),
    overlay: Color(0x730F0F14),
  );

  static const TLTokens dark = TLTokens(
    bg: Color(0xFF0B0C0F),
    card: Color(0xFF17181C),
    cardAlt: Color(0xFF202227),
    text: Color(0xFFF2F3F5),
    textSub: Color(0x9EEBEBF5),
    border: Color(0x17FFFFFF),
    input: Color(0xFF1C1E23),
    navBg: Color(0xEB141519),
    sheet: Color(0xFF1A1B1F),
    overlay: Color(0x99000000),
  );

  @override
  TLTokens copyWith({
    Color? bg,
    Color? card,
    Color? cardAlt,
    Color? text,
    Color? textSub,
    Color? border,
    Color? input,
    Color? navBg,
    Color? sheet,
    Color? overlay,
  }) {
    return TLTokens(
      bg: bg ?? this.bg,
      card: card ?? this.card,
      cardAlt: cardAlt ?? this.cardAlt,
      text: text ?? this.text,
      textSub: textSub ?? this.textSub,
      border: border ?? this.border,
      input: input ?? this.input,
      navBg: navBg ?? this.navBg,
      sheet: sheet ?? this.sheet,
      overlay: overlay ?? this.overlay,
    );
  }

  @override
  TLTokens lerp(ThemeExtension<TLTokens>? other, double t) {
    if (other is! TLTokens) return this;
    return TLTokens(
      bg: Color.lerp(bg, other.bg, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardAlt: Color.lerp(cardAlt, other.cardAlt, t)!,
      text: Color.lerp(text, other.text, t)!,
      textSub: Color.lerp(textSub, other.textSub, t)!,
      border: Color.lerp(border, other.border, t)!,
      input: Color.lerp(input, other.input, t)!,
      navBg: Color.lerp(navBg, other.navBg, t)!,
      sheet: Color.lerp(sheet, other.sheet, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
    );
  }
}

extension TLTokensX on BuildContext {
  /// Design tokens for the active brightness.
  TLTokens get tl => Theme.of(this).extension<TLTokens>() ?? TLTokens.light;
}
