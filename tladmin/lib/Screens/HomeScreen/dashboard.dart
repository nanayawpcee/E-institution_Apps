import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/admin_data.dart';
import '../../theme/app_charts.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_widgets.dart';

/// Route wrapper kept for the named-route table; the console renders
/// [DashboardBody] directly inside its shell.
class DashBoard extends StatelessWidget {
  static String routeName = 'DashBoard';

  const DashBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const DashboardBody();
}

class DashboardBody extends ConsumerWidget {
  const DashboardBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(adminDataProvider);
    final pending = data.requests.where((r) => r.isPending).length;
    final resolved = data.requests.length - pending;
    final activeClassrooms =
        data.courses.fold<int>(0, (sum, c) => sum + c.activeClassCount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const TLPageHeader(
          title: 'Dashboard',
          subtitle: 'Overview of platform activity',
        ),
        const SizedBox(height: 18),
        _StatGrid(
          cards: [
            TLStatCard(
              icon: Icons.menu_book_outlined,
              value: '${data.courses.length}',
              label: 'Total Courses',
              iconColor: TLTokens.primary,
            ),
            TLStatCard(
              icon: Icons.people_outline,
              value: '${data.tutors.length}',
              label: 'Total Tutors',
              iconColor: TLTokens.secondary,
            ),
            TLStatCard(
              icon: Icons.dashboard_outlined,
              value: '$activeClassrooms',
              label: 'Active Classrooms',
              iconColor: TLTokens.success,
            ),
            TLStatCard(
              icon: Icons.inbox_outlined,
              value: '${data.requests.length}',
              label: 'Total Requests',
              iconColor: TLTokens.warning,
            ),
            TLStatCard(
              icon: Icons.pending_actions_outlined,
              value: '$pending',
              label: 'Pending Requests',
              iconColor: TLTokens.danger,
            ),
            TLStatCard(
              icon: Icons.star_outline_rounded,
              value: '${data.courseReviewCount}',
              label: 'Course Reviews',
              iconColor: TLTokens.primary,
            ),
            TLStatCard(
              icon: Icons.star_outline_rounded,
              value: '${data.tutorReviews.length}',
              label: 'Tutor Reviews',
              iconColor: TLTokens.secondary,
            ),
          ],
        ),
        const SizedBox(height: 20),
        _ChartRow(
          leftFlex: 14,
          rightFlex: 10,
          left: _GrowthChart(data: data),
          right: TLChartCard(
            title: 'Requests: pending vs resolved',
            child: TLBarChart(
              bars: [
                TLBar(
                  label: 'Pending',
                  value: pending,
                  color: TLTokens.warning,
                  caption: '$pending',
                ),
                TLBar(
                  label: 'Resolved',
                  value: resolved,
                  color: TLTokens.success,
                  caption: '$resolved',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _ChartRow(
          leftFlex: 1,
          rightFlex: 1,
          left: _RatingChart(data: data),
          right: _RevenueChart(data: data),
        ),
      ],
    );
  }
}

/// Responsive stat grid — four across on desktop, narrowing with the viewport.
class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.cards});

  final List<Widget> cards;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 14.0;
        final columns = constraints.maxWidth > 1100
            ? 4
            : constraints.maxWidth > 800
                ? 3
                : constraints.maxWidth > 520
                    ? 2
                    : 1;
        final width =
            (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final card in cards) SizedBox(width: width, child: card),
          ],
        );
      },
    );
  }
}

/// Two charts side by side, stacking once there is no room for both.
class _ChartRow extends StatelessWidget {
  const _ChartRow({
    required this.left,
    required this.right,
    required this.leftFlex,
    required this.rightFlex,
  });

  final Widget left;
  final Widget right;
  final int leftFlex;
  final int rightFlex;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 760) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [left, const SizedBox(height: 16), right],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: leftFlex, child: left),
            const SizedBox(width: 16),
            Expanded(flex: rightFlex, child: right),
          ],
        );
      },
    );
  }
}

class _GrowthChart extends StatelessWidget {
  const _GrowthChart({required this.data});

  final AdminData data;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = [
      for (var i = 5; i >= 0; i--) DateTime(now.year, now.month - i, 1),
    ];
    final counts = months
        .map((m) => data.courses
            .where((c) =>
                c.createdAt.year == m.year && c.createdAt.month == m.month)
            .length)
        .toList();

    return TLChartCard(
      title: 'Course growth (last 6 months)',
      child: TLLineChart(
        values: counts,
        labels: months.map((m) => DateFormat.MMM().format(m)).toList(),
      ),
    );
  }
}

class _RatingChart extends StatelessWidget {
  const _RatingChart({required this.data});

  final AdminData data;

  @override
  Widget build(BuildContext context) {
    final buckets = [
      for (var star = 1; star <= 5; star++)
        data.tutors.where((t) => t.tutorRating.round() == star).length,
    ];

    return TLChartCard(
      title: 'Tutor rating distribution',
      child: TLBarChart(
        height: 140,
        barWidth: 30,
        gap: 14,
        captionAbove: false,
        bars: [
          for (var i = 0; i < 5; i++)
            TLBar(
              label: '${i + 1}★',
              value: buckets[i],
              color: TLTokens.secondary,
              caption: '${buckets[i]}',
            ),
        ],
      ),
    );
  }
}

class _RevenueChart extends StatelessWidget {
  const _RevenueChart({required this.data});

  final AdminData data;

  /// The design's flat per-session estimate.
  static const int _perSession = 20;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekStarts = [
      for (var i = 5; i >= 0; i--) now.subtract(Duration(days: i * 7)),
    ];

    final values = <int>[];
    for (var i = 0; i < weekStarts.length; i++) {
      final start = weekStarts[i];
      final end = i < weekStarts.length - 1 ? weekStarts[i + 1] : now;
      final resolved = data.requests
          .where((r) =>
              !r.isPending && !r.date.isBefore(start) && r.date.isBefore(end))
          .length;
      values.add(resolved * _perSession);
    }
    final total = values.fold<int>(0, (a, b) => a + b);

    return TLChartCard(
      title: 'Estimated booking revenue (6 weeks)',
      footer: 'Total: \$$total · est. \$$_perSession/session',
      child: TLBarChart(
        height: 140,
        barWidth: 26,
        gap: 10,
        bars: [
          for (var i = 0; i < values.length; i++)
            TLBar(
              label: 'W${i + 1}',
              value: values[i],
              color: TLTokens.primary,
            ),
        ],
      ),
    );
  }
}
