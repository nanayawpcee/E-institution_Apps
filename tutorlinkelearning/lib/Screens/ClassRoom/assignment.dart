import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../components/resourcemangement.dart';
import '../../providers/student_data.dart';
import '../../services/local_auth_service.dart';
import '../../theme/app_text.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_widgets.dart';
import 'models/dialog.dart';

/// Assignment submissions for one course, inside the classroom.
class AssignmentsPage extends ConsumerStatefulWidget {
  const AssignmentsPage({Key? key, required this.courseId}) : super(key: key);

  final String courseId;

  @override
  ConsumerState<AssignmentsPage> createState() => _AssignmentsPageState();
}

class _AssignmentsPageState extends ConsumerState<AssignmentsPage> {
  @override
  Widget build(BuildContext context) {
    final student = ref.watch(authProvider);
    ref.watch(studentDataProvider);
    final classroom = student == null
        ? null
        : ref
            .read(studentDataProvider.notifier)
            .classroomFor(widget.courseId, student.id);
    final assignments = classroom?.assignments ?? [];

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: TLTokens.primary,
        foregroundColor: Colors.white,
        onPressed: () => showMaterialDialog(context, _submitFiles),
        child: const Icon(Icons.add_rounded),
      ),
      body: assignments.isEmpty
          ? TLEmptyState(
              icon: Icons.assignment_outlined,
              title: 'No assignments yet',
              message: 'Submit your work with the button below.',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
              itemCount: assignments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) => ResourceItem(
                resourceTitle: assignments[i].title,
                resourceUrl: assignments[i].url,
                timestamp: assignments[i].time,
              ),
            ),
    );
  }

  /// Files stay as on-device paths; there is no Storage bucket to upload to.
  Future<void> _submitFiles(List<File> files) async {
    if (files.isEmpty) return;

    final student = ref.read(authProvider);
    if (student == null) return;

    final data = ref.read(studentDataProvider.notifier);
    final classroom = data.classroomFor(widget.courseId, student.id);
    if (classroom == null) return;

    for (final file in files) {
      final title = await _askForTitle();
      if (title != null && title.isNotEmpty) {
        data.addAssignment(classroom.id, title, file.path);
      }
    }
  }

  Future<String?> _askForTitle() async {
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (context) {
        final t = context.tl;
        return AlertDialog(
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Submission title',
                style: TLText.cardTitle(t.text).copyWith(fontSize: 17),
              ),
              const SizedBox(height: 14),
              TLField(
                hint: 'e.g. CSM4 Assignment submission',
                controller: controller,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TLButton(
                      label: 'Save',
                      onPressed: () =>
                          Navigator.pop(context, controller.text.trim()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
    controller.dispose();
    return title;
  }
}
