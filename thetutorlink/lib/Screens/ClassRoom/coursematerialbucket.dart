import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/tutor_data.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_widgets.dart';
import 'assignment.dart';
import 'resourceroom.dart';
import 'settingspage.dart';

enum _ClassroomTab { resources, assignments, settings }

/// The classroom the tutor runs with one student: shared resources, submitted
/// assignments and class settings, switched by the design's chip tabs.
class CourseMaterialPage extends ConsumerStatefulWidget {
  const CourseMaterialPage({
    Key? key,
    required this.studentId,
    required this.tutorId,
  }) : super(key: key);

  final String studentId;
  final String tutorId;

  @override
  ConsumerState<CourseMaterialPage> createState() =>
      _CourseMaterialPageState();
}

class _CourseMaterialPageState extends ConsumerState<CourseMaterialPage> {
  _ClassroomTab _tab = _ClassroomTab.resources;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    final student =
        ref.watch(tutorDataProvider.notifier).studentById(widget.studentId);

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(title: Text(student?.name ?? 'Classroom')),
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
        return ResourcePage(studentId: widget.studentId);
      case _ClassroomTab.assignments:
        return AssignmentsPage(studentId: widget.studentId);
      case _ClassroomTab.settings:
        return SettingsPage(
          studentId: widget.studentId,
          tutorId: widget.tutorId,
        );
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
}
