import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/admin_data.dart';
import '../../../theme/app_table.dart';
import '../../../theme/app_text.dart';
import '../../../theme/app_tokens.dart';
import '../../../theme/app_widgets.dart';
import '../../../utils/csv_export.dart';
import '../../../utils/image_helpers.dart';
import '../Shell/admin_nav.dart';

/// Route wrapper kept for the named-route table.
class AllCoursesScreen extends StatelessWidget {
  static String routeName = 'AllCoursesScreen';

  const AllCoursesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const AllCoursesBody();
}

class AllCoursesBody extends ConsumerStatefulWidget {
  const AllCoursesBody({Key? key}) : super(key: key);

  @override
  ConsumerState<AllCoursesBody> createState() => _AllCoursesBodyState();
}

class _AllCoursesBodyState extends ConsumerState<AllCoursesBody> {
  final _filterController = TextEditingController();
  String _filter = '';
  final Set<String> _selected = {};

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    final data = ref.watch(adminDataProvider);
    final q = _filter.trim().toLowerCase();
    final visible = data.courses
        .where((c) =>
            q.isEmpty ||
            c.name.toLowerCase().contains(q) ||
            c.department.toLowerCase().contains(q))
        .toList();
    final allSelected =
        visible.isNotEmpty && visible.every((c) => _selected.contains(c.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TLPageHeader(
          title: 'All Courses',
          subtitle: '${data.courses.length} total',
          trailing: Wrap(
            spacing: 10,
            children: [
              TLSecondaryButton(
                label: 'Export CSV',
                icon: Icons.file_download_outlined,
                onPressed: () => _export(data.courses.map((c) => c.id).toSet()),
              ),
              TLSmallButton(
                label: 'Add Course',
                icon: Icons.add_rounded,
                onPressed: () => ref
                    .read(adminNavProvider.notifier)
                    .go(AdminPageKey.addCourse),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TLTableSearch(
                hint: 'Filter by name or department',
                controller: _filterController,
                onChanged: (v) => setState(() => _filter = v),
              ),
            ),
            if (_selected.isNotEmpty) ...[
              const SizedBox(width: 10),
              TLBulkBar(
                count: _selected.length,
                actions: {
                  'Export selected': () => _export(_selected),
                  'Delete': _deleteSelected,
                },
              ),
            ],
          ],
        ),
        TLTable(
          columns: [
            TLColumn(
              width: 34,
              header: Checkbox(
                value: allSelected,
                onChanged: visible.isEmpty
                    ? null
                    : (_) => setState(() {
                          if (allSelected) {
                            _selected.removeAll(visible.map((c) => c.id));
                          } else {
                            _selected.addAll(visible.map((c) => c.id));
                          }
                        }),
                activeColor: TLTokens.primary,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const TLColumn(width: 52),
            const TLColumn(label: 'Course', flex: 2),
            const TLColumn(label: 'Department', flex: 1),
            const TLColumn(label: 'Rating', flex: 1),
            const TLColumn(label: 'Classes', flex: 1),
            const TLColumn(width: 80, alignment: Alignment.centerRight),
          ],
          emptyState: TLEmptyState(
            icon: Icons.menu_book_outlined,
            title: q.isEmpty ? 'No courses yet' : 'No matching courses',
            message: q.isEmpty
                ? 'Publish your first course to see it here.'
                : 'Try a different name or department.',
          ),
          rows: [
            for (final course in visible)
              TLTableRow(
                onTap: () =>
                    ref.read(adminNavProvider.notifier).openCourse(course.id),
                cells: [
                  Checkbox(
                    value: _selected.contains(course.id),
                    onChanged: (_) => _toggle(course.id),
                    activeColor: TLTokens.primary,
                    visualDensity: VisualDensity.compact,
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: t.cardAlt,
                      borderRadius: BorderRadius.circular(TLTokens.rSm),
                      image: DecorationImage(
                        image: appImageProvider(course.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  TLCell(course.name, strong: true),
                  TLCell(course.department),
                  TLCell('★ ${course.courseRating.toStringAsFixed(1)}'),
                  TLCell('${course.activeClassCount} active'),
                  TLViewLink(
                    onTap: () => ref
                        .read(adminNavProvider.notifier)
                        .openCourse(course.id),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  void _toggle(String id) => setState(() {
        if (!_selected.remove(id)) _selected.add(id);
      });

  void _export(Set<String> ids) {
    final courses =
        ref.read(adminDataProvider).courses.where((c) => ids.contains(c.id));
    CsvExport.copy(
      context,
      label: '${courses.length} course${courses.length == 1 ? '' : 's'}',
      headers: const [
        'Name',
        'Department',
        'Rating',
        'Duration (hrs)',
        'Active classes',
        'Pending classes',
        'Tutors',
      ],
      rows: [
        for (final c in courses)
          [
            c.name,
            c.department,
            c.courseRating.toStringAsFixed(1),
            c.duration.toStringAsFixed(0),
            '${c.activeClassCount}',
            '${c.pendingClassCount}',
            '${c.numberOfTutors}',
          ],
      ],
    );
  }

  Future<void> _deleteSelected() async {
    final count = _selected.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete $count course${count == 1 ? '' : 's'}?',
          style: TLText.cardTitle(context.tl.text),
        ),
        content: Text(
          'Their classrooms and requests are removed too. This cannot be undone.',
          style: TLText.sub(context.tl.textSub),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: TLTokens.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    ref.read(adminDataProvider.notifier).deleteCourses({..._selected});
    setState(_selected.clear);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$count course${count == 1 ? '' : 's'} deleted')),
    );
  }
}
