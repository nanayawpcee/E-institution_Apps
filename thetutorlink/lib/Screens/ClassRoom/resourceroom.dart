import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Components/resourcemangement.dart';
import '../../providers/tutor_data.dart';
import '../../services/local_auth_service.dart';
import '../../theme/app_text.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_widgets.dart';
import 'models/showdialog.dart';

/// Course material the tutor shares with one student.
class ResourcePage extends ConsumerStatefulWidget {
  const ResourcePage({Key? key, required this.studentId}) : super(key: key);

  final String studentId;

  @override
  ConsumerState<ResourcePage> createState() => _ResourcePageState();
}

class _ResourcePageState extends ConsumerState<ResourcePage> {
  @override
  Widget build(BuildContext context) {
    final tutorId = ref.watch(authProvider)?.id ?? '';
    final classroom = ref
        .watch(tutorDataProvider)
        .classrooms
        .where((c) => c.studentId == widget.studentId && c.tutorId == tutorId);
    final resources = classroom.isEmpty ? const [] : classroom.first.resources;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: TLTokens.primary,
        foregroundColor: Colors.white,
        onPressed: () => showMaterialDialog(context, _shareFiles),
        child: const Icon(Icons.add_rounded),
      ),
      body: resources.isEmpty
          ? const TLEmptyState(
              icon: Icons.folder_open_rounded,
              title: 'No resources yet',
              message: 'Share course material with the button below.',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
              itemCount: resources.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) => ResourceItem(
                tutorId: tutorId,
                tutorDocumentId: classroom.first.id,
                resourceTitle: resources[i].title,
                resourceUrl: resources[i].url,
                timestamp: resources[i].time,
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
        .classroomFor(widget.studentId, tutorId);
    if (classroom == null) return;

    for (final file in files) {
      final title = await askForTitle(
        context,
        heading: 'Resource title',
        hint: 'e.g. Course Outline',
      );
      if (title != null && title.isNotEmpty) {
        ref
            .read(tutorDataProvider.notifier)
            .addResource(classroom.id, title, file.path);
      }
    }
  }
}

/// Shared title prompt for both resource and assignment uploads.
Future<String?> askForTitle(
  BuildContext context, {
  required String heading,
  required String hint,
}) async {
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
              heading,
              style: TLText.cardTitle(t.text).copyWith(fontSize: 17),
            ),
            const SizedBox(height: 14),
            TLField(hint: hint, controller: controller),
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
