import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Components/resourcemangement.dart';
import '../../providers/tutor_data.dart';
import '../../services/local_auth_service.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_widgets.dart';
import 'models/showdialog.dart';
import 'resourceroom.dart' show askForTitle;

/// Assignments exchanged with one student.
class AssignmentsPage extends ConsumerStatefulWidget {
  const AssignmentsPage({Key? key, required this.studentId}) : super(key: key);

  final String studentId;

  @override
  ConsumerState<AssignmentsPage> createState() => _AssignmentsPageState();
}

class _AssignmentsPageState extends ConsumerState<AssignmentsPage> {
  @override
  Widget build(BuildContext context) {
    final tutorId = ref.watch(authProvider)?.id ?? '';
    final classroom = ref
        .watch(tutorDataProvider)
        .classrooms
        .where((c) => c.studentId == widget.studentId && c.tutorId == tutorId);
    final assignments =
        classroom.isEmpty ? const [] : classroom.first.assignments;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: TLTokens.primary,
        foregroundColor: Colors.white,
        onPressed: () => showMaterialDialog(context, _shareFiles),
        child: const Icon(Icons.add_rounded),
      ),
      body: assignments.isEmpty
          ? const TLEmptyState(
              icon: Icons.assignment_outlined,
              title: 'No assignments yet',
              message: 'Set work for this student with the button below.',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
              itemCount: assignments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) => ResourceItem(
                tutorId: tutorId,
                tutorDocumentId: classroom.first.id,
                resourceTitle: assignments[i].title,
                resourceUrl: assignments[i].url,
                timestamp: assignments[i].time,
                // Assignments are the student's submissions to keep.
                canRemove: false,
              ),
            ),
    );
  }

  /// Files stay as on-device paths; there is no Storage bucket to upload to.
  Future<void> _shareFiles(List<File> files) async {
    if (files.isEmpty) return;

    final tutorId = ref.read(authProvider)?.id;
    if (tutorId == null) return;

    final classroom = ref
        .read(tutorDataProvider.notifier)
        .getOrCreateClassroom(widget.studentId, tutorId, '');

    for (final file in files) {
      final title = await askForTitle(
        context,
        heading: 'Assignment title',
        hint: 'e.g. Assignment 1',
      );
      if (title != null && title.isNotEmpty) {
        ref
            .read(tutorDataProvider.notifier)
            .addAssignment(classroom.id, title, file.path);
      }
    }
  }
}
