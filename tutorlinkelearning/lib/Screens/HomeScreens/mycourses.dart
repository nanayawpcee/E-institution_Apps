import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../components/coursecard.dart';
import '../../components/home.dart';
import '../../models/app_models.dart';
import '../../providers/student_data.dart';
import '../../services/local_auth_service.dart';
import '../../theme/app_text.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_widgets.dart';
import '../../utils/coursename.dart';
import '../ClassRoom/coursematerialbucket.dart';
import '../CourseDetails/reviews.dart';

enum _CourseStatus { all, active, pending, completed }

/// My Courses tab: enrolment status filters over the student's own courses.
class Mycourses extends ConsumerStatefulWidget {
  const Mycourses({Key? key}) : super(key: key);

  @override
  ConsumerState<Mycourses> createState() => _MycoursesState();
}

class _MycoursesState extends ConsumerState<Mycourses> {
  _CourseStatus _status = _CourseStatus.all;
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    final student = ref.watch(authProvider);
    ref.watch(studentDataProvider);
    final notifier = ref.read(studentDataProvider.notifier);

    final courses = student == null
        ? <CoursesType>[]
        : notifier
            .coursesByIds(_idsFor(student))
            .where((c) =>
                c.name.toLowerCase().contains(_search.toLowerCase()))
            .toList();

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, kTabBottomInset),
          children: [
            Text('My Courses', style: TLText.screenTitle(t.text)),
            const SizedBox(height: 16),
            TLSearchField(
              hint: 'Search any course',
              onChanged: (v) => setState(() => _search = v),
            ),
            const SizedBox(height: 16),
            TLChipBar(
              children: [
                for (final status in _CourseStatus.values)
                  TLChip(
                    label: _label(status),
                    selected: _status == status,
                    onTap: () => setState(() => _status = status),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (courses.isEmpty)
              const TLEmptyState(
                icon: Icons.school_outlined,
                title: 'No courses here yet',
                message: 'No courses found for this status.',
              )
            else
              for (final course in courses)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _card(student!, course),
                ),
          ],
        ),
      ),
    );
  }

  List<String> _idsFor(Student student) {
    switch (_status) {
      case _CourseStatus.active:
        return student.activeCourses;
      case _CourseStatus.pending:
        return student.pendingCourses;
      case _CourseStatus.completed:
        return student.completedCourses;
      case _CourseStatus.all:
        return student.allCourses;
    }
  }

  String _label(_CourseStatus status) {
    switch (status) {
      case _CourseStatus.all:
        return 'All';
      case _CourseStatus.active:
        return 'Active';
      case _CourseStatus.pending:
        return 'Pending';
      case _CourseStatus.completed:
        return 'Completed';
    }
  }

  Widget _card(Student student, CoursesType course) {
    final isActive = student.activeCourses.contains(course.courseId);
    final isPending = student.pendingCourses.contains(course.courseId);
    final isCompleted = student.completedCourses.contains(course.courseId);

    final alreadyReviewed = ref
        .read(studentDataProvider.notifier)
        .reviewsForCourse(course.courseId)
        .any((r) => r.postedBy == student.name);

    return EnrolledCourseCard(
      course: course,
      statusLabel: isActive
          ? 'Active'
          : isPending
              ? 'Pending approval'
              : 'Completed',
      statusColor: isActive
          ? TLTokens.primary
          : isPending
              ? TLTokens.pendingInk
              : TLTokens.success,
      statusBackground: isActive
          ? TLTokens.activeTint
          : isPending
              ? TLTokens.pendingTint
              : TLTokens.completedTint,
      // The design shows progress only while a course is running.
      progress: isActive ? _progressFor(student, course) : null,
      rateLabel:
          isCompleted && !alreadyReviewed ? 'Rate your tutor →' : null,
      onRate: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReviewScreen(courseId: course.courseId),
        ),
      ),
      onTap: isActive
          ? () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CourseMaterialPage(
                    courseId: course.courseId,
                    studentId: student.id,
                  ),
                ),
              )
          : () => openCourseDetail(context, course.courseId),
    );
  }

  /// Share of the classroom's scheduled span that has already elapsed — the
  /// only progress signal the local data model carries.
  double _progressFor(Student student, CoursesType course) {
    final classroom = ref
        .read(studentDataProvider.notifier)
        .classroomFor(course.courseId, student.id);
    if (classroom == null) return 0;

    final total = classroom.endTime.difference(classroom.startTime).inMinutes;
    if (total <= 0) return 0;
    final elapsed =
        DateTime.now().difference(classroom.startTime).inMinutes;
    return (elapsed / total).clamp(0.0, 1.0);
  }
}
