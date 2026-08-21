import 'package:flutter/material.dart';

/// Design tokens transcribed from the TutorLink Admin design
/// (`TutorLinkAdmin.dc.html`). Every value here has a direct counterpart in
/// that document — keep the two in step when the design moves.
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
    required this.shadow,
  });

  /// Page background behind every surface.
  final Color bg;

  /// Raised surface: panels, sidebars, table shells, dropdowns.
  final Color card;

  /// Recessed surface: chips, icon buttons, search wells, active nav rows.
  final Color cardAlt;

  final Color text;
  final Color textSub;
  final Color border;

  /// Field fill. Matches [card] in light mode and sits just above [bg] in dark.
  final Color input;

  /// Elevation colour for dropdowns and dialogs.
  final Color shadow;

  // ── Accents ────────────────────────────────────────────────────────────
  // Accents are theme-independent: the design uses the same hexes in both
  // light and dark, so they live as statics rather than instance fields.
  static const Color primary = Color(0xFF66328E);
  static const Color primaryDeep = Color(0xFF52276F);
  static const Color secondary = Color(0xFF6F35A5);
  static const Color danger = Color(0xFFE5484D);
  static const Color success = Color(0xFF2FA84F);
  static const Color warning = Color(0xFFFFC933);

  /// The sign-in panel's brand wash.
  static const Gradient brandGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  // ── Radii ──────────────────────────────────────────────────────────────
  static const double rSm = 10;
  static const double rMd = 12;
  static const double rLg = 16;
  static const double rXl = 20;

  static const TLTokens light = TLTokens(
    bg: Color(0xFFF6F7FB),
    card: Color(0xFFFFFFFF),
    cardAlt: Color(0xFFF1E6FF),
    text: Color(0xFF25282B),
    textSub: Color(0xFF7C8189),
    border: Color(0xFFE7E9EE),
    input: Color(0xFFFFFFFF),
    shadow: Color(0x26000000),
  );

  static const TLTokens dark = TLTokens(
    bg: Color(0xFF0B0C0F),
    card: Color(0xFF17181C),
    cardAlt: Color(0xFF202227),
    text: Color(0xFFF2F3F5),
    textSub: Color(0x99EBEBF5),
    border: Color(0x17FFFFFF),
    input: Color(0xFF1C1E23),
    shadow: Color(0x2E000000),
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
    Color? shadow,
  }) {
    return TLTokens(
      bg: bg ?? this.bg,
      card: card ?? this.card,
      cardAlt: cardAlt ?? this.cardAlt,
      text: text ?? this.text,
      textSub: textSub ?? this.textSub,
      border: border ?? this.border,
      input: input ?? this.input,
      shadow: shadow ?? this.shadow,
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
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

extension TLTokensX on BuildContext {
  /// Design tokens for the active brightness.
  TLTokens get tl => Theme.of(this).extension<TLTokens>() ?? TLTokens.light;
}
