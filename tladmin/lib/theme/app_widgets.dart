import 'package:flutter/material.dart';

import 'app_text.dart';
import 'app_tokens.dart';

/// Filled primary action — 46px tall, r12, Poppins 14.5/600.
class TLPrimaryButton extends StatelessWidget {
  const TLPrimaryButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.expand = true,
    this.busy = false,
    this.icon,
    this.color = TLTokens.primary,
  }) : super(key: key);

  final String label;
  final VoidCallback? onPressed;
  final bool expand;
  final bool busy;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !busy;
    final child = Material(
      color: enabled ? color : color.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(TLTokens.rMd),
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(TLTokens.rMd),
        child: Container(
          height: 46,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 17, color: Colors.white),
                      const SizedBox(width: 8),
                    ],
                    Text(label, style: TLText.button(Colors.white)),
                  ],
                ),
        ),
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: child) : child;
  }
}

/// Compact primary action used for the "+ Add …" affordances — 38px, r10.
class TLSmallButton extends StatelessWidget {
  const TLSmallButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.icon,
    this.color = TLTokens.primary,
  }) : super(key: key);

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(TLTokens.rSm),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(TLTokens.rSm),
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 15, color: Colors.white),
                const SizedBox(width: 6),
              ],
              Text(label, style: TLText.buttonSm(Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Low-emphasis action on the recessed surface — 46px, r12.
class TLSecondaryButton extends StatelessWidget {
  const TLSecondaryButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.icon,
  }) : super(key: key);

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return Material(
      color: t.cardAlt,
      borderRadius: BorderRadius.circular(TLTokens.rMd),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(TLTokens.rMd),
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: t.text),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TLText.buttonSm(t.text).copyWith(fontSize: 13.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Square icon affordance on the recessed surface — 36px, r10.
class TLIconButton extends StatelessWidget {
  const TLIconButton({
    Key? key,
    required this.icon,
    this.onPressed,
    this.badge = false,
    this.size = 36,
    this.tooltip,
  }) : super(key: key);

  final IconData icon;
  final VoidCallback? onPressed;

  /// Draws the unread dot in the top-right corner.
  final bool badge;
  final double size;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    Widget button = Material(
      color: t.cardAlt,
      borderRadius: BorderRadius.circular(TLTokens.rSm),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(TLTokens.rSm),
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, size: 17, color: t.text),
              if (badge)
                const Positioned(
                  top: 6,
                  right: 6,
                  child: SizedBox(
                    width: 7,
                    height: 7,
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
    if (tooltip != null) button = Tooltip(message: tooltip!, child: button);
    return button;
  }
}

/// The bordered card that every dashboard surface is built from — r16, 1px
/// border, no shadow.
class TLPanel extends StatelessWidget {
  const TLPanel({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.radius = TLTokens.rLg,
  }) : super(key: key);

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return Material(
      color: t.card,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: t.border),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Dashboard metric tile: tinted glyph well, figure, label.
class TLStatCard extends StatelessWidget {
  const TLStatCard({
    Key? key,
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
  }) : super(key: key);

  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return TLPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: t.cardAlt,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(height: 12),
          Text(value, style: TLText.statValue(t.text)),
          const SizedBox(height: 2),
          Text(
            label,
            style: TLText.sub(t.textSub).copyWith(fontSize: 12.5),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Small status pill — used for request state, course tags, search kinds.
class TLTag extends StatelessWidget {
  const TLTag({
    Key? key,
    required this.label,
    required this.color,
    this.background,
  }) : super(key: key);

  final String label;
  final Color color;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background ?? color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(label, style: TLText.tag(color)),
    );
  }
}

/// Page title + subtitle, optionally trailed by an action.
class TLPageHeader extends StatelessWidget {
  const TLPageHeader({
    Key? key,
    required this.title,
    this.subtitle,
    this.trailing,
  }) : super(key: key);

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TLText.pageTitle(t.text)),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(subtitle!, style: TLText.sub(t.textSub)),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Labelled form field wrapping the themed [TextField].
class TLField extends StatelessWidget {
  const TLField({
    Key? key,
    required this.hint,
    this.label,
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
  final String? label;
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
        if (label != null) ...[
          Text(label!, style: TLText.bodyStrong(t.textSub)),
          const SizedBox(height: 7),
        ],
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
                const BoxConstraints(minWidth: 44, minHeight: 44),
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

/// Centred empty state for lists and tables that have nothing to show.
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: t.cardAlt,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, size: 27, color: t.textSub),
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
      ),
    );
  }
}
