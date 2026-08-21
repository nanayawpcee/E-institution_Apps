import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Components/home.dart';
import '../../Components/requestcard.dart';
import '../../models/app_models.dart';
import '../../providers/tutor_data.dart';
import '../../services/local_auth_service.dart';
import '../../theme/app_text.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_widgets.dart';
import '../ClassRoom/coursematerialbucket.dart';
import '../Profile/userProfileScreen.dart' show TLAvatar;

enum _RequestFilter { all, pending, accepted, rejected }

/// Dashboard tab.
///
/// Reads top to bottom as: who you are and what needs you now (hero) → the
/// numbers (stats) → work in progress (active classes) → the inbox (requests).
class DashBoardScreen extends ConsumerStatefulWidget {
  static String routeName = 'DashBoardScreen';

  const DashBoardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends ConsumerState<DashBoardScreen> {
  _RequestFilter _filter = _RequestFilter.all;
  String _search = '';

  final _requestsKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    final tutor = ref.watch(authProvider);
    final data = ref.watch(tutorDataProvider);
    final notifier = ref.read(tutorDataProvider.notifier);

    final tutorId = tutor?.id ?? '';
    final firstName = (tutor?.name ?? '')
        .split(' ')
        .firstWhere((s) => s.isNotEmpty, orElse: () => 'there');

    final mine = data.requests.where((r) => r.tutorId == tutorId).toList();
    final pending = mine.where((r) => r.isPending).length;
    final accepted = mine.where((r) => r.isAccepted).length;
    final classrooms =
        data.classrooms.where((c) => c.tutorId == tutorId).toList();

    final requests = mine.where((r) {
      final matchesFilter = switch (_filter) {
        _RequestFilter.all => true,
        _RequestFilter.pending => r.isPending,
        _RequestFilter.accepted => r.isAccepted,
        _RequestFilter.rejected => r.isRejected,
      };
      if (!matchesFilter) return false;
      if (_search.isEmpty) return true;
      final student = notifier.studentById(r.studentId);
      return student != null &&
          student.name.toLowerCase().contains(_search.toLowerCase());
    }).toList();

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, kTabBottomInset),
          children: [
            _HeroCard(
              firstName: firstName,
              available: tutor?.available ?? true,
              pendingCount: pending,
              onToggleAvailability: () {
                final next = !(tutor?.available ?? true);
                ref.read(authProvider.notifier).updateAvailability(next);
              },
              onSeePending: () {
                setState(() => _filter = _RequestFilter.pending);
                _scrollToRequests();
              },
            ),
            const SizedBox(height: 16),
            TLSearchField(
              hint: 'Search students...',
              onChanged: (v) => setState(() => _search = v),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TLStatTile(
                    icon: Icons.people_alt_rounded,
                    value: '${tutor?.students.length ?? 0}',
                    label: 'My students',
                    accent: TLTokens.primary,
                    onTap: () => HomeTabScope.maybeOf(context)?.goToTab(1),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TLStatTile(
                    icon: Icons.inbox_rounded,
                    value: '$pending',
                    label: 'Pending requests',
                    accent: TLTokens.warning,
                    onTap: () {
                      setState(() => _filter = _RequestFilter.pending);
                      _scrollToRequests();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TLStatTile(
                    icon: Icons.check_circle_rounded,
                    value: '$accepted',
                    label: 'Accepted',
                    accent: TLTokens.success,
                    onTap: () {
                      setState(() => _filter = _RequestFilter.accepted);
                      _scrollToRequests();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TLStatTile(
                    icon: Icons.school_rounded,
                    value: '${classrooms.length}',
                    label: 'Active classes',
                    accent: TLTokens.accent,
                  ),
                ),
              ],
            ),
            if (classrooms.isNotEmpty) ...[
              const SizedBox(height: 26),
              Text('Active classes', style: TLText.sectionTitle(t.text)),
              const SizedBox(height: 12),
              for (final classroom in classrooms)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ClassCard(classroom: classroom),
                ),
            ],
            const SizedBox(height: 26),
            Row(
              key: _requestsKey,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text('Requests', style: TLText.sectionTitle(t.text)),
                ),
                Text(
                  '${requests.length} shown',
                  style: TLText.meta(t.textSub),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TLChipBar(
              children: [
                for (final filter in _RequestFilter.values)
                  TLChip(
                    label: _label(filter),
                    selected: _filter == filter,
                    onTap: () => setState(() => _filter = filter),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            if (requests.isEmpty)
              const TLEmptyState(
                icon: Icons.inbox_outlined,
                title: 'No requests in this view',
                message: 'Requests from students will appear here.',
              )
            else
              for (final request in requests)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _requestCard(request, notifier),
                ),
          ],
        ),
      ),
    );
  }

  void _scrollToRequests() {
    final context = _requestsKey.currentContext;
    if (context == null) return;
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOut,
      alignment: 0.05,
    );
  }

  Widget _requestCard(RequestRecord request, TutorAppDataNotifier notifier) {
    final student = notifier.studentById(request.studentId);
    if (student == null) return const SizedBox.shrink();
    final course = notifier.courseById(request.courseId);

    return RequestCard(
      studentId: student.id,
      requestId: request.id,
      studentName: student.name,
      studentImageUrl: student.userImage,
      courseName: course?.name ?? 'Unknown course',
      isPending: request.isPending,
      isAccepted: request.isAccepted,
      onAccept: () => notifier.resolveRequest(request.id, accepted: true),
      onReject: () => notifier.resolveRequest(request.id, accepted: false),
    );
  }

  String _label(_RequestFilter filter) {
    switch (filter) {
      case _RequestFilter.all:
        return 'All';
      case _RequestFilter.pending:
        return 'Pending';
      case _RequestFilter.accepted:
        return 'Accepted';
      case _RequestFilter.rejected:
        return 'Rejected';
    }
  }
}

/// Gradient header: greeting, availability, and whatever needs attention now.
class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.firstName,
    required this.available,
    required this.pendingCount,
    required this.onToggleAvailability,
    required this.onSeePending,
  });

  final String firstName;
  final bool available;
  final int pendingCount;
  final VoidCallback onToggleAvailability;
  final VoidCallback onSeePending;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        gradient: TLTokens.brandGradient,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, $firstName',
                      style: TLText.screenTitle(Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      available
                          ? 'You are open to new students'
                          : 'You are closed to new students',
                      style: TLText.sub(
                        Colors.white.withValues(alpha: 0.82),
                      ),
                    ),
                  ],
                ),
              ),
              _AvailabilityPill(
                available: available,
                onTap: onToggleAvailability,
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Only worth a row when there is actually something waiting.
          if (pendingCount > 0)
            Material(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: onSeePending,
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.inbox_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '$pendingCount request'
                          '${pendingCount == 1 ? '' : 's'} waiting on you',
                          style: TLText.sub(Colors.white)
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 17,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                const SizedBox(width: 8),
                Text(
                  'You are all caught up',
                  style: TLText.sub(Colors.white.withValues(alpha: 0.9)),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Availability switch, styled to sit on the gradient.
class _AvailabilityPill extends StatelessWidget {
  const _AvailabilityPill({required this.available, required this.onTap});

  final bool available;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: available ? 0.95 : 0.18),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: available ? TLTokens.success : Colors.white,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                available ? 'Open' : 'Closed',
                style: TLText.tag(
                  available ? TLTokens.primary : Colors.white,
                ).copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A running class: student, course, and how far through its window it is.
class _ClassCard extends ConsumerWidget {
  const _ClassCard({required this.classroom});

  final ClassroomRecord classroom;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tl;
    final notifier = ref.read(tutorDataProvider.notifier);
    final student = notifier.studentById(classroom.studentId);
    final course = notifier.courseById(classroom.courseId);

    final total = classroom.endTime.difference(classroom.startTime).inMinutes;
    final elapsed = DateTime.now().difference(classroom.startTime).inMinutes;
    final progress = total <= 0 ? 0.0 : (elapsed / total).clamp(0.0, 1.0);
    final daysLeft = classroom.endTime.difference(DateTime.now()).inDays;

    return TLCard(
      padding: const EdgeInsets.all(12),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CourseMaterialPage(
            studentId: classroom.studentId,
            tutorId: classroom.tutorId,
          ),
        ),
      ),
      child: Row(
        children: [
          TLAvatar(imagePath: student?.userImage ?? '', size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student?.name ?? 'Student',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TLText.cardTitle(t.text).copyWith(fontSize: 14.5),
                ),
                const SizedBox(height: 3),
                Text(
                  course?.name ?? 'Class',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TLText.meta(t.textSub),
                ),
                const SizedBox(height: 4),
                Text(
                  daysLeft <= 0
                      ? 'Ending today'
                      : 'Ends in $daysLeft day${daysLeft == 1 ? '' : 's'}',
                  style: TLText.tag(
                    daysLeft <= 1 ? TLTokens.warning : t.textSub,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          TLProgressRing(value: progress),
        ],
      ),
    );
  }
}
