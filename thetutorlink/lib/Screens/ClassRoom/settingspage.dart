import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/tutor_data.dart';
import '../../theme/app_text.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_widgets.dart';

/// Class settings: when the class runs and what it covers.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({
    Key? key,
    required this.studentId,
    required this.tutorId,
  }) : super(key: key);

  final String studentId;
  final String tutorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tl;
    ref.watch(tutorDataProvider);
    final notifier = ref.read(tutorDataProvider.notifier);
    final classroom = notifier.classroomFor(studentId, tutorId);

    if (classroom == null) {
      return const TLEmptyState(
        icon: Icons.settings_outlined,
        title: 'No active class',
        message: 'Accept a request to open a classroom with this student.',
      );
    }

    final course = notifier.courseById(classroom.courseId);
    final format = DateFormat('d MMM y, h:mm a');

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        Text('Class details', style: TLText.cardTitle(t.text)),
        const SizedBox(height: 12),
        TLMenuGroup(
          children: [
            TLMenuRow(
              label: 'Course',
              leading: Icons.menu_book_outlined,
              trailing: Text(
                course?.name ?? 'Unassigned',
                style: TLText.sub(t.textSub),
              ),
            ),
            TLMenuRow(
              label: 'Starts',
              leading: Icons.play_circle_outline_rounded,
              trailing: Text(
                format.format(classroom.startTime),
                style: TLText.sub(t.textSub),
              ),
            ),
            TLMenuRow(
              label: 'Ends',
              leading: Icons.stop_circle_outlined,
              trailing: Text(
                format.format(classroom.endTime),
                style: TLText.sub(t.textSub),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'The class closes automatically once the end time passes, and the '
          'student is prompted to review it.',
          style: TLText.meta(t.textSub).copyWith(height: 1.5),
        ),
      ],
    );
  }
}
