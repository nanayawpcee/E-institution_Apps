import 'package:flutter/material.dart';

import 'app_text.dart';
import 'app_tokens.dart';

/// Panel wrapper every dashboard chart sits in — r16 card with a Poppins title.
class TLChartCard extends StatelessWidget {
  const TLChartCard({
    Key? key,
    required this.title,
    required this.child,
    this.footer,
  }) : super(key: key);

  final String title;
  final Widget child;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: t.card,
        border: Border.all(color: t.border),
        borderRadius: BorderRadius.circular(TLTokens.rLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: TLText.cardTitle(t.text)),
          const SizedBox(height: 10),
          child,
          if (footer != null) ...[
            const SizedBox(height: 8),
            Text(
              footer!,
              textAlign: TextAlign.center,
              style: TLText.sub(t.textSub).copyWith(fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

/// Filled line chart with a marker per point and a label strip underneath.
class TLLineChart extends StatelessWidget {
  const TLLineChart({
    Key? key,
    required this.values,
    required this.labels,
    this.height = 160,
    this.color = TLTokens.primary,
  }) : super(key: key);

  final List<num> values;
  final List<String> labels;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: height,
          child: CustomPaint(
            painter: _LinePainter(
              values: values,
              color: color,
              fill: color.withValues(alpha: dark ? 0.16 : 0.12),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final label in labels)
              Text(
                label,
                style: TLText.caption(t.textSub).copyWith(fontSize: 11),
              ),
          ],
        ),
      ],
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter({required this.values, required this.color, required this.fill});

  final List<num> values;
  final Color color;
  final Color fill;

  // Matches the design's 14px inset inside the 560x160 plotting box.
  static const double _pad = 14;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final maxValue =
        values.fold<double>(1, (m, v) => v.toDouble() > m ? v.toDouble() : m);
    final span = values.length == 1
        ? 0.0
        : (size.width - 2 * _pad) / (values.length - 1);

    final points = <Offset>[
      for (var i = 0; i < values.length; i++)
        Offset(
          _pad + i * span,
          size.height -
              _pad -
              (values[i].toDouble() / maxValue) * (size.height - 2 * _pad),
        ),
    ];

    final area = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      area.lineTo(p.dx, p.dy);
    }
    area
      ..lineTo(size.width - _pad, size.height - _pad)
      ..lineTo(_pad, size.height - _pad)
      ..close();
    canvas.drawPath(area, Paint()..color = fill);

    final stroke = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      stroke.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      stroke,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final dot = Paint()..color = color;
    for (final p in points) {
      canvas.drawCircle(p, 4, dot);
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) =>
      old.values != values || old.color != color || old.fill != fill;
}

/// One column of a [TLBarChart].
class TLBar {
  const TLBar({
    required this.label,
    required this.value,
    required this.color,
    this.caption,
  });

  final String label;
  final num value;
  final Color color;

  /// Figure printed above the bar. Falls back to nothing when omitted.
  final String? caption;
}

/// Grouped column chart. Bars are scaled against the largest value and never
/// collapse below 6px, so an empty bucket still reads as a column.
class TLBarChart extends StatelessWidget {
  const TLBarChart({
    Key? key,
    required this.bars,
    this.barWidth = 52,
    this.gap = 28,
    this.height = 150,
    this.maxBarHeight = 100,
    this.captionAbove = true,
  }) : super(key: key);

  final List<TLBar> bars;
  final double barWidth;
  final double gap;
  final double height;
  final double maxBarHeight;

  /// The design prints the count above the bar on some charts and below the
  /// axis label on others.
  final bool captionAbove;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    final max = bars.fold<double>(
        1, (m, b) => b.value.toDouble() > m ? b.value.toDouble() : m);

    return SizedBox(
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < bars.length; i++) ...[
            if (i > 0) SizedBox(width: gap),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (captionAbove && bars[i].caption != null) ...[
                  Text(bars[i].caption!, style: TLText.cardTitle(t.text)),
                  const SizedBox(height: 8),
                ] else if (bars[i].caption != null) ...[
                  Text(
                    bars[i].caption!,
                    style: TLText.caption(t.textSub).copyWith(fontSize: 11),
                  ),
                  const SizedBox(height: 6),
                ],
                Container(
                  width: barWidth,
                  height: (bars[i].value.toDouble() / max * maxBarHeight)
                      .clamp(6, maxBarHeight),
                  decoration: BoxDecoration(
                    color: bars[i].color,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  bars[i].label,
                  style: TLText.caption(t.textSub).copyWith(fontSize: 11.5),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
