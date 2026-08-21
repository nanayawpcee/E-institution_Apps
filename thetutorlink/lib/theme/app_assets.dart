/// The bundled art the redesign actually uses.
///
/// The repo ships more than this — photo banners, per-tab PNG glyphs, category
/// clip-art — but those are inconsistent in weight and style next to the new
/// design, so nav and action glyphs come from the Material set instead. Only
/// the pieces that hold up are listed here.
class TLAssets {
  const TLAssets._();

  /// Full "TUTORLINK" wordmark with the reader mark.
  static const String logo = 'assets/images/Logop.png';

  /// Onboarding illustrations, in slide order.
  static const List<String> onboarding = [
    'assets/svgs/onboard0.svg',
    'assets/svgs/onboard1.svg',
    'assets/svgs/onboard2.svg',
  ];

  /// Chat bubble with a badge dot — the messaging entry point. Two-tone by
  /// design: the bubble is drawn at half opacity so the badge reads as the
  /// emphasis.
  static const String iconChat = 'assets/svgs/chat.svg';

  /// Stand-in avatar for users with no photo.
  static const String avatar = 'assets/icons/avatar.svg';
}
