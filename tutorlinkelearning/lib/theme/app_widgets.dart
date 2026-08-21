import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'app_assets.dart';
import 'app_text.dart';
import 'app_tokens.dart';

/// Full-width primary action — 52px, r16, Poppins 16/600.
class TLButton extends StatelessWidget {
  const TLButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.busy = false,
    this.color = TLTokens.primary,
    this.icon,
  }) : super(key: key);

  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !busy;
    return Material(
      color: enabled ? color : color.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(TLTokens.rLg),
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(TLTokens.rLg),
        child: Container(
          height: 52,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: busy
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 19, color: Colors.white),
                      const SizedBox(width: 8),
                    ],
                    Text(label, style: TLText.button(Colors.white)),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Rounded icon affordance on the recessed surface — 38px, r12.
class TLIconButton extends StatelessWidget {
  const TLIconButton({
    Key? key,
    required this.icon,
    this.onPressed,
    this.badge = false,
    this.iconColor,
  }) : super(key: key);

  final IconData icon;
  final VoidCallback? onPressed;

  /// Draws the unread dot in the top-right corner.
  final bool badge;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return Material(
      color: t.cardAlt,
      borderRadius: BorderRadius.circular(TLTokens.rMd),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(TLTokens.rMd),
        child: SizedBox(
          width: 38,
          height: 38,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, size: 19, color: iconColor ?? t.text),
              if (badge)
                const Positioned(
                  top: 6,
                  right: 6,
                  child: SizedBox(
                    width: 8,
                    height: 8,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: TLTokens.danger,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rounded search field — 48px, r16, trailing search glyph in the accent.
class TLSearchField extends StatelessWidget {
  const TLSearchField({
    Key? key,
    required this.hint,
    this.controller,
    this.onChanged,
  }) : super(key: key);

  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TLText.body(t.text),
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          suffixIcon: const Icon(
            Icons.search_rounded,
            size: 19,
            color: TLTokens.primary,
          ),
          border: _border(t.border),
          enabledBorder: _border(t.border),
          focusedBorder: _border(TLTokens.primary),
        ),
      ),
    );
  }

  OutlineInputBorder _border(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(TLTokens.rLg),
        borderSide: BorderSide(color: c, width: 1.5),
      );
}

/// Labelled field with an inline error slot and optional show/hide affordance.
class TLField extends StatelessWidget {
  const TLField({
    Key? key,
    required this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.errorText,
    this.suffix,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
  }) : super(key: key);

  final String hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? errorText;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: obscureText ? 1 : maxLines,
          readOnly: readOnly,
          onTap: onTap,
          onChanged: onChanged,
          style: TLText.body(t.text),
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffix,
            suffixIconConstraints:
                const BoxConstraints(minWidth: 48, minHeight: 48),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 5),
          Text(errorText!, style: TLText.error(TLTokens.danger)),
        ],
      ],
    );
  }
}

/// "Show"/"Hide" text affordance used inside password fields.
class TLRevealToggle extends StatelessWidget {
  const TLRevealToggle({
    Key? key,
    required this.revealed,
    required this.onPressed,
  }) : super(key: key);

  final bool revealed;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(revealed ? 'Hide' : 'Show'),
    );
  }
}

/// Bordered card surface every list item is built from.
class TLCard extends StatelessWidget {
  const TLCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(10),
    this.onTap,
    this.radius = TLTokens.rLg,
    this.recessed = false,
  }) : super(key: key);

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double radius;

  /// Uses the recessed surface with no border — the design's review cards.
  final bool recessed;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return Material(
      color: recessed ? t.cardAlt : t.card,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: recessed ? null : Border.all(color: t.border),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Pill filter — filled in the accent when selected, recessed otherwise.
class TLChip extends StatelessWidget {
  const TLChip({
    Key? key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.color = TLTokens.primary,
    this.compact = false,
  }) : super(key: key);

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  /// The explore screen's sort chips are a size down from the section filters.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return Material(
      color: selected ? color : t.cardAlt,
      borderRadius: BorderRadius.circular(compact ? 16 : 20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(compact ? 16 : 20),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 14 : 16,
            vertical: compact ? 7 : 8,
          ),
          child: Text(
            label,
            style: TLText.chip(selected ? Colors.white : t.textSub)
                .copyWith(fontSize: compact ? 12.5 : 13),
          ),
        ),
      ),
    );
  }
}

/// Horizontally scrolling row of [TLChip]s.
class TLChipBar extends StatelessWidget {
  const TLChipBar({Key? key, required this.children}) : super(key: key);

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Status pill — 11/700 on a tinted ground.
class TLStatusChip extends StatelessWidget {
  const TLStatusChip({
    Key? key,
    required this.label,
    required this.color,
    required this.background,
  }) : super(key: key);

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label, style: TLText.tag(color)),
    );
  }
}

/// Star + value pair used across course and tutor rows.
class TLRating extends StatelessWidget {
  const TLRating({Key? key, required this.value, this.size = 12})
      : super(key: key);

  final double value;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, size: size + 3, color: TLTokens.warning),
        const SizedBox(width: 3),
        Text(
          value.toStringAsFixed(1),
          style: TLText.meta(t.textSub).copyWith(fontSize: size),
        ),
      ],
    );
  }
}

/// Slim progress track — 6px, r4.
class TLProgressBar extends StatelessWidget {
  const TLProgressBar({Key? key, required this.value}) : super(key: key);

  /// 0..1.
  final double value;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1),
        minHeight: 6,
        backgroundColor: t.border,
        valueColor: const AlwaysStoppedAnimation(TLTokens.primary),
      ),
    );
  }
}

/// Frosted bottom navigation matching the design's translucent bar.
class TLBottomNav extends StatelessWidget {
  const TLBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  }) : super(key: key);

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<TLNavItem> items;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(6, 8, 6, 24),
          decoration: BoxDecoration(
            color: t.navBg,
            border: Border(top: BorderSide(color: t.border)),
          ),
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _NavButton(
                    item: items[i],
                    selected: i == currentIndex,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class TLNavItem {
  const TLNavItem({required this.icon, required this.activeIcon, required this.label});

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final TLNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    final color = selected ? TLTokens.primary : t.textSub;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(TLTokens.rMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(selected ? item.activeIcon : item.icon, size: 22, color: color),
            const SizedBox(height: 3),
            Text(
              item.label,
              style: TLText.tag(color).copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Grab handle at the top of a bottom sheet.
class TLSheetHandle extends StatelessWidget {
  const TLSheetHandle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return Container(
      width: 40,
      height: 5,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: t.border,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

/// Standard bottom sheet chrome: sheet surface, r24 top, grab handle.
Future<T?> showTLSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: context.tl.overlay,
    builder: (context) {
      final t = context.tl;
      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.82,
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: BoxDecoration(
          color: t.sheet,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: TLSheetHandle()),
              builder(context),
            ],
          ),
        ),
      );
    },
  );
}

/// Settings-style row group — a card with hairline-separated rows.
class TLMenuGroup extends StatelessWidget {
  const TLMenuGroup({Key? key, required this.children}) : super(key: key);

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return Container(
      decoration: BoxDecoration(
        color: t.card,
        border: Border.all(color: t.border),
        borderRadius: BorderRadius.circular(TLTokens.rLg),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++)
            DecoratedBox(
              decoration: BoxDecoration(
                border: i == children.length - 1
                    ? null
                    : Border(bottom: BorderSide(color: t.border)),
              ),
              child: children[i],
            ),
        ],
      ),
    );
  }
}

/// One row inside a [TLMenuGroup].
class TLMenuRow extends StatelessWidget {
  const TLMenuRow({
    Key? key,
    required this.label,
    this.leading,
    this.trailing,
    this.onTap,
    this.danger = false,
  }) : super(key: key);

  final String label;
  final IconData? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    final color = danger ? TLTokens.danger : t.text;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            if (leading != null) ...[
              Icon(leading, size: 19, color: color),
              const SizedBox(width: 12),
            ],
            Expanded(child: Text(label, style: TLText.body(color))),
            trailing ??
                Icon(Icons.chevron_right_rounded, size: 20, color: t.textSub),
          ],
        ),
      ),
    );
  }
}

/// Centred empty state for lists with nothing to show.
class TLEmptyState extends StatelessWidget {
  const TLEmptyState({
    Key? key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  }) : super(key: key);

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: t.cardAlt,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, size: 30, color: t.textSub),
          ),
          const SizedBox(height: 16),
          Text(title, style: TLText.cardTitle(t.text)),
          if (message != null) ...[
            const SizedBox(height: 6),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: TLText.sub(t.textSub),
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: 18),
            action!,
          ],
        ],
      ),
    );
  }
}

/// The chat bubble icon, with its badge dot turning red when a conversation
/// has messages you have not opened yet.
///
/// The artwork ships as a single asset whose bubble is drawn at half opacity;
/// tinting it preserves that, so the badge stays the emphasis. For the unread
/// state a filled dot is laid over the badge outline rather than shipping a
/// second asset — the geometry below comes straight from the SVG's own
/// 24-unit viewBox.
class TLChatIcon extends StatelessWidget {
  const TLChatIcon({
    Key? key,
    required this.color,
    this.size = 24,
    this.unread = false,
    this.unreadColor = TLTokens.danger,
  }) : super(key: key);

  final Color color;
  final double size;
  final bool unread;
  final Color unreadColor;

  // Badge centre and radius in the asset's 24x24 viewBox: the circle is
  // cx/cy/r = 3/3/3 under `matrix(-1 0 0 1 22 2)`, with a 1.5 stroke.
  static const double _badgeCx = 19;
  static const double _badgeCy = 5;
  static const double _badgeOuterR = 3.85; // 3 + half the 1.5 stroke, rounded up

  @override
  Widget build(BuildContext context) {
    final scale = size / 24;
    final diameter = _badgeOuterR * 2 * scale;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SvgPicture.asset(
            TLAssets.iconChat,
            width: size,
            height: size,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
          if (unread)
            Positioned(
              left: _badgeCx * scale - diameter / 2,
              top: _badgeCy * scale - diameter / 2,
              child: Container(
                width: diameter,
                height: diameter,
                decoration: BoxDecoration(
                  color: unreadColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
