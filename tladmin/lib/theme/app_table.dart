import 'package:flutter/material.dart';

import 'app_text.dart';
import 'app_tokens.dart';

/// One column in a [TLTable]. Either [flex] or [width] sizes it, matching the
/// design's mix of proportional and fixed-width table columns.
class TLColumn {
  const TLColumn({
    this.label = '',
    this.header,
    this.flex,
    this.width,
    this.alignment = Alignment.centerLeft,
  }) : assert(flex != null || width != null,
            'A column needs either a flex or a fixed width');

  final String label;

  /// Replaces [label] in the header band — used for the select-all checkbox.
  final Widget? header;
  final int? flex;
  final double? width;
  final Alignment alignment;
}

/// Bordered table shell: uppercase header band on the recessed surface, then
/// hairline-separated rows.
class TLTable extends StatelessWidget {
  const TLTable({
    Key? key,
    required this.columns,
    required this.rows,
    this.emptyState,
  }) : super(key: key);

  final List<TLColumn> columns;

  /// Each row supplies exactly one cell per column.
  final List<TLTableRow> rows;
  final Widget? emptyState;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return Container(
      margin: const EdgeInsets.only(top: 14),
      decoration: BoxDecoration(
        color: t.card,
        border: Border.all(color: t.border),
        borderRadius: BorderRadius.circular(TLTokens.rLg),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            color: t.cardAlt,
            child: Row(
              children: [
                for (var i = 0; i < columns.length; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  _sized(
                    columns[i],
                    Align(
                      alignment: columns[i].alignment,
                      child: columns[i].header ??
                          Text(
                            columns[i].label.toUpperCase(),
                            style: TLText.tag(t.textSub).copyWith(
                              fontSize: 12,
                              letterSpacing: 0.4,
                            ),
                          ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (rows.isEmpty && emptyState != null)
            emptyState!
          else
            for (final row in rows) _TLTableRowView(columns: columns, row: row),
        ],
      ),
    );
  }

  static Widget _sized(TLColumn col, Widget child) {
    if (col.width != null) return SizedBox(width: col.width, child: child);
    return Expanded(flex: col.flex!, child: child);
  }
}

class TLTableRow {
  const TLTableRow({required this.cells, this.onTap});

  final List<Widget> cells;
  final VoidCallback? onTap;
}

class _TLTableRowView extends StatelessWidget {
  const _TLTableRowView({required this.columns, required this.row});

  final List<TLColumn> columns;
  final TLTableRow row;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return InkWell(
      onTap: row.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: t.border)),
        ),
        child: Row(
          children: [
            for (var i = 0; i < columns.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              TLTable._sized(
                columns[i],
                Align(
                  alignment: columns[i].alignment,
                  child: i < row.cells.length
                      ? row.cells[i]
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Plain text cell — [strong] renders the row's primary identifier.
class TLCell extends StatelessWidget {
  const TLCell(this.text, {Key? key, this.strong = false}) : super(key: key);

  final String text;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: strong
          ? TLText.bodyStrong(t.text)
          : TLText.sub(t.textSub).copyWith(fontSize: 13),
    );
  }
}

/// The right-aligned "View" affordance every table row ends with.
class TLViewLink extends StatelessWidget {
  const TLViewLink({Key? key, this.label = 'View', this.onTap})
      : super(key: key);

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        child: Text(
          label,
          style: TLText.tag(TLTokens.primary).copyWith(fontSize: 12.5),
        ),
      ),
    );
  }
}

/// Filter box that sits above a table — 42px, r12.
class TLTableSearch extends StatelessWidget {
  const TLTableSearch({
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
      height: 42,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TLText.bodyStrong(t.text).copyWith(fontWeight: FontWeight.w400),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(Icons.search_rounded, size: 18, color: t.textSub),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 40, minHeight: 40),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
        ),
      ),
    );
  }
}

/// Contextual bar that appears once rows are selected.
class TLBulkBar extends StatelessWidget {
  const TLBulkBar({
    Key? key,
    required this.count,
    required this.actions,
  }) : super(key: key);

  final int count;

  /// Label → handler. A label of `Delete` renders in the danger colour.
  final Map<String, VoidCallback> actions;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: t.cardAlt,
        borderRadius: BorderRadius.circular(TLTokens.rMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$count selected', style: TLText.bodyStrong(t.text)),
          for (final entry in actions.entries) ...[
            const SizedBox(width: 14),
            InkWell(
              onTap: entry.value,
              child: Text(
                entry.key,
                style: TLText.bodyStrong(
                  entry.key.toLowerCase() == 'delete'
                      ? TLTokens.danger
                      : TLTokens.primary,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
