import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../components/resourcemangement.dart';
import '../../providers/student_data.dart';
import '../../theme/app_widgets.dart';
import '../../utils/check_permission.dart';

/// Course materials the tutor has shared, inside the classroom.
class ResourcePage extends ConsumerStatefulWidget {
  const ResourcePage({
    Key? key,
    required this.studentId,
    required this.courseId,
  }) : super(key: key);

  final String studentId;
  final String courseId;

  @override
  ConsumerState<ResourcePage> createState() => _ResourcePageState();
}

class _ResourcePageState extends ConsumerState<ResourcePage> {
  final _permissions = CheckPermission();

  @override
  void initState() {
    super.initState();
    // Downloads need storage access; ask once when the tab first opens.
    _permissions.isStoragePermission();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(studentDataProvider);
    final classroom = ref
        .read(studentDataProvider.notifier)
        .classroomFor(widget.courseId, widget.studentId);
    final resources = classroom?.resources ?? [];

    if (resources.isEmpty) {
      return const TLEmptyState(
        icon: Icons.folder_open_rounded,
        title: 'No resources yet',
        message: 'Material your tutor shares will appear here.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      itemCount: resources.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) => ResourceItem(
        resourceTitle: resources[i].title,
        resourceUrl: resources[i].url,
        timestamp: resources[i].time,
      ),
    );
  }
}
