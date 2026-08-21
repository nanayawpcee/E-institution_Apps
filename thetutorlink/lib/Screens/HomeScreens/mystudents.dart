import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Components/home.dart';
import '../../Components/studentscard.dart';
import '../../models/app_models.dart';
import '../../providers/tutor_data.dart';
import '../../services/local_auth_service.dart';
import '../../theme/app_text.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_widgets.dart';

/// Students tab: everyone the tutor teaches, searchable and filterable by
/// course.
class MyStudents extends ConsumerStatefulWidget {
  const MyStudents({Key? key}) : super(key: key);

  @override
  ConsumerState<MyStudents> createState() => _MyStudentsState();
}

class _MyStudentsState extends ConsumerState<MyStudents> {
  String _search = '';
  String _courseFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    final tutor = ref.watch(authProvider);
    final data = ref.watch(tutorDataProvider);
    final notifier = ref.read(tutorDataProvider.notifier);

    final students = tutor == null
        ? <Student>[]
        : notifier.studentsByIds(tutor.students);

    // Course chips come from the classrooms this tutor actually runs.
    final myClassrooms =
        data.classrooms.where((c) => c.tutorId == (tutor?.id ?? '')).toList();
    final courseNames = <String>{
      for (final c in myClassrooms) notifier.courseById(c.courseId)?.name ?? '',
    }..removeWhere((n) => n.isEmpty);
    final chips = ['All', ...courseNames];

    String courseLabelFor(String studentId) {
      final names = myClassrooms
          .where((c) => c.studentId == studentId)
          .map((c) => notifier.courseById(c.courseId)?.name ?? '')
          .where((n) => n.isNotEmpty)
          .toList();
      return names.isEmpty ? 'No active class' : names.join(', ');
    }

    final visible = students.where((s) {
      final matchesSearch =
          _search.isEmpty || s.name.toLowerCase().contains(_search);
      final matchesCourse = _courseFilter == 'All' ||
          courseLabelFor(s.id).contains(_courseFilter);
      return matchesSearch && matchesCourse;
    }).toList();

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, kTabBottomInset),
          children: [
            Text('My Students', style: TLText.screenTitle(t.text)),
            const SizedBox(height: 16),
            TLSearchField(
              hint: 'Search students by name...',
              onChanged: (v) => setState(() => _search = v.toLowerCase()),
            ),
            if (chips.length > 1) ...[
              const SizedBox(height: 14),
              TLChipBar(
                children: [
                  for (final chip in chips)
                    TLChip(
                      label: chip,
                      selected: _courseFilter == chip,
                      onTap: () => setState(() => _courseFilter = chip),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            if (visible.isEmpty)
              const TLEmptyState(
                icon: Icons.people_outline,
                title: 'No students found',
                message: 'Accept a request and the student appears here.',
              )
            else
              for (final student in visible)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: StudentsCard(
                    studentId: student.id,
                    userImage: student.userImage,
                    name: student.name,
                    courseLabel: courseLabelFor(student.id),
                    progress: _progressFor(student.id, tutor?.id ?? ''),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  /// Share of the classroom's scheduled span that has already elapsed — the
  /// only progress signal the local data model carries.
  double? _progressFor(String studentId, String tutorId) {
    final classroom =
        ref.read(tutorDataProvider.notifier).classroomFor(studentId, tutorId);
    if (classroom == null) return null;

    final total = classroom.endTime.difference(classroom.startTime).inMinutes;
    if (total <= 0) return null;
    final elapsed = DateTime.now().difference(classroom.startTime).inMinutes;
    return (elapsed / total).clamp(0.0, 1.0);
  }
}
