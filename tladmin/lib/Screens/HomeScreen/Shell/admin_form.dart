import 'package:flutter/material.dart';

import '../../../theme/app_text.dart';
import '../../../theme/app_tokens.dart';

/// The two-column form panel both "Add …" pages use. Columns stack once the
/// viewport can no longer give each one its 280px minimum.
class TLFormCard extends StatelessWidget {
  const TLFormCard({Key? key, required this.columns}) : super(key: key);

  final List<List<Widget>> columns;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: t.card,
        border: Border.all(color: t.border),
        borderRadius: BorderRadius.circular(TLTokens.rLg),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const gap = 28.0;
          final available = constraints.maxWidth;
          final sideBySide =
              available >= 280 * columns.length + gap * (columns.length - 1);
          final width = sideBySide
              ? (available - gap * (columns.length - 1)) / columns.length
              : available;

          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final column in columns)
                SizedBox(
                  width: width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: column,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Field label — 12.5/700 on the muted colour, with the design's top margin.
class TLFormLabel extends StatelessWidget {
  const TLFormLabel(this.text, {Key? key}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Text(
        text,
        style: TLText.bodyStrong(t.textSub)
            .copyWith(fontSize: 12.5, fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// Select styled to match [TLField] — same height, radius and border.
class TLFormDropdown extends StatelessWidget {
  const TLFormDropdown({
    Key? key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.hint,
  }) : super(key: key);

  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      dropdownColor: t.card,
      borderRadius: BorderRadius.circular(TLTokens.rMd),
      icon: Icon(Icons.expand_more_rounded, color: t.textSub),
      style: TLText.body(t.text),
      hint: Text(hint, style: TLText.body(t.textSub)),
      items: [
        for (final item in items)
          DropdownMenuItem(value: item, child: Text(item)),
      ],
      onChanged: onChanged,
    );
  }
}

/// Dashed 150px drop target for an image.
class TLUploadZone extends StatelessWidget {
  const TLUploadZone({
    Key? key,
    required this.onTap,
    required this.emptyIcon,
    required this.emptyLabel,
    this.child,
    this.height = 150,
  }) : super(key: key);

  final VoidCallback? onTap;
  final IconData emptyIcon;
  final String emptyLabel;

  /// Preview to show once something is picked.
  final Widget? child;
  final double height;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: t.border, width: 1.5),
        ),
        child: child ??
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(emptyIcon, size: 26, color: t.textSub),
                const SizedBox(height: 6),
                Text(
                  emptyLabel,
                  style: TLText.sub(t.textSub).copyWith(fontSize: 12.5),
                ),
              ],
            ),
      ),
    );
  }
}

/// Single-line dashed picker row, used for the video and photo attachments.
class TLUploadRow extends StatelessWidget {
  const TLUploadRow({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.leading,
  }) : super(key: key);

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  /// Replaces [icon] once a preview is available (e.g. a picked avatar).
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(TLTokens.rMd),
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(TLTokens.rMd),
          border: Border.all(color: t.border, width: 1.5),
        ),
        child: Row(
          children: [
            leading ?? Icon(icon, size: 18, color: t.textSub),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TLText.sub(t.textSub).copyWith(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
