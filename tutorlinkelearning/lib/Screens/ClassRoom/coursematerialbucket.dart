import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/student_data.dart';
import '../../services/local_auth_service.dart';
import '../../theme/app_text.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_widgets.dart';
import 'assignment.dart';
import 'resourse.dart';
import 'settingspage.dart';

enum _ClassroomTab { resources, assignments, settings }

/// The classroom for one course: resources, assignment submissions and class
/// settings, switched by the design's chip tabs rather than a drawer.
class CourseMaterialPage extends ConsumerStatefulWidget {
  const CourseMaterialPage({
    Key? key,
    required this.courseId,
    required this.studentId,
  }) : super(key: key);

  final String courseId;
  final String studentId;

  @override
  ConsumerState<CourseMaterialPage> createState() => _CourseMaterialPageState();
}

class _CourseMaterialPageState extends ConsumerState<CourseMaterialPage> {
  _ClassroomTab _tab = _ClassroomTab.resources;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _promptForReviewIfClassEnded());
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    final course =
        ref.watch(studentDataProvider.notifier).courseById(widget.courseId);

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(title: Text(course?.name ?? 'Classroom')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: TLChipBar(
              children: [
                for (final tab in _ClassroomTab.values)
                  TLChip(
                    label: _label(tab),
                    selected: _tab == tab,
                    onTap: () => setState(() => _tab = tab),
                  ),
              ],
            ),
          ),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _body() {
    switch (_tab) {
      case _ClassroomTab.resources:
        return ResourcePage(
          studentId: widget.studentId,
          courseId: widget.courseId,
        );
      case _ClassroomTab.assignments:
        return AssignmentsPage(courseId: widget.courseId);
      case _ClassroomTab.settings:
        return const SettingsPage();
    }
  }

  String _label(_ClassroomTab tab) {
    switch (tab) {
      case _ClassroomTab.resources:
        return 'Resources';
      case _ClassroomTab.assignments:
        return 'Assignments';
      case _ClassroomTab.settings:
        return 'Settings';
    }
  }

  /// When the class window has closed, collect a rating/review before tearing
  /// the classroom down.
  void _promptForReviewIfClassEnded() {
    final data = ref.read(studentDataProvider.notifier);
    final classroom = data.classroomFor(widget.courseId, widget.studentId);
    if (classroom == null) return;
    if (classroom.endTime.isAfter(DateTime.now())) return;

    final student = ref.read(authProvider);
    if (student == null) return;

    final controller = TextEditingController();
    double rating = 5;

    showTLSheet<void>(
      context: context,
      builder: (context) {
        final t = context.tl;
        return StatefulBuilder(
          builder: (context, setSheetState) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Class ended', style: TLText.cardTitle(t.text)),
              const SizedBox(height: 6),
              Text(
                'Please rate the tutor and the course.',
                style: TLText.sub(t.textSub),
              ),
              const SizedBox(height: 14),
              Center(
                child: RatingBar.builder(
                  initialRating: rating,
                  minRating: 1,
                  itemCount: 5,
                  itemSize: 34,
                  glow: false,
                  itemBuilder: (context, _) => const Icon(
                    Icons.star_rounded,
                    color: TLTokens.warning,
                  ),
                  onRatingUpdate: (v) => setSheetState(() => rating = v),
                ),
              ),
              const SizedBox(height: 16),
              TLField(
                hint: 'Write your review...',
                controller: controller,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TLButton(
                label: 'Submit',
                onPressed: () {
                  data.addTutorReview(
                    classroom.tutorId,
                    student.name,
                    controller.text.trim().isEmpty
                        ? 'Great experience overall.'
                        : controller.text.trim(),
                    DateFormat('d MMM y').format(DateTime.now()),
                    student.userImage,
                  );
                  data.closeClassroom(
                      classroom.id, classroom.tutorId, widget.studentId);
                  ref
                      .read(authProvider.notifier)
                      .completeCourse(widget.courseId);
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    ).then((_) => controller.dispose());
  }
}
