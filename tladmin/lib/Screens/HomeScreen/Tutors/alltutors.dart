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
class AllTutorsScreen extends StatelessWidget {
  static String routeName = 'AllTutorsScreen';

  const AllTutorsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const AllTutorsBody();
}

class AllTutorsBody extends ConsumerStatefulWidget {
  const AllTutorsBody({Key? key}) : super(key: key);

  @override
  ConsumerState<AllTutorsBody> createState() => _AllTutorsBodyState();
}

class _AllTutorsBodyState extends ConsumerState<AllTutorsBody> {
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
    final visible = data.tutors
        .where((tutor) =>
            q.isEmpty ||
            tutor.name.toLowerCase().contains(q) ||
            tutor.email.toLowerCase().contains(q))
        .toList();
    final allSelected = visible.isNotEmpty &&
        visible.every((tutor) => _selected.contains(tutor.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TLPageHeader(
          title: 'All Tutors',
          subtitle: '${data.tutors.length} total',
          trailing: Wrap(
            spacing: 10,
            children: [
              TLSecondaryButton(
                label: 'Export CSV',
                icon: Icons.file_download_outlined,
                onPressed: () =>
                    _export(data.tutors.map((tutor) => tutor.id).toSet()),
              ),
              TLSmallButton(
                label: 'Add Tutor',
                icon: Icons.add_rounded,
                onPressed: () =>
                    ref.read(adminNavProvider.notifier).go(AdminPageKey.addTutor),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TLTableSearch(
                hint: 'Filter by name or email',
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
                            _selected.removeAll(visible.map((x) => x.id));
                          } else {
                            _selected.addAll(visible.map((x) => x.id));
                          }
                        }),
                activeColor: TLTokens.primary,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const TLColumn(width: 52),
            const TLColumn(label: 'Name', flex: 2),
            const TLColumn(label: 'Email', flex: 2),
            const TLColumn(label: 'Rating', flex: 1),
            const TLColumn(label: 'Status', flex: 1),
            const TLColumn(width: 80, alignment: Alignment.centerRight),
          ],
          emptyState: TLEmptyState(
            icon: Icons.people_outline,
            title: q.isEmpty ? 'No tutors yet' : 'No matching tutors',
            message: q.isEmpty
                ? 'Onboard an accepted tutor to see them here.'
                : 'Try a different name or email.',
          ),
          rows: [
            for (final tutor in visible)
              TLTableRow(
                onTap: () =>
                    ref.read(adminNavProvider.notifier).openTutor(tutor.id),
                cells: [
                  Checkbox(
                    value: _selected.contains(tutor.id),
                    onChanged: (_) => setState(() {
                      if (!_selected.remove(tutor.id)) _selected.add(tutor.id);
                    }),
                    activeColor: TLTokens.primary,
                    visualDensity: VisualDensity.compact,
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: t.cardAlt,
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: appImageProvider(tutor.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  TLCell(tutor.name, strong: true),
                  TLCell(tutor.email),
                  TLCell('★ ${tutor.tutorRating.toStringAsFixed(1)}'),
                  TLTag(
                    label: tutor.tutorAvailability ? 'Available' : 'Busy',
                    color: tutor.tutorAvailability
                        ? TLTokens.success
                        : TLTokens.warning,
                  ),
                  TLViewLink(
                    onTap: () =>
                        ref.read(adminNavProvider.notifier).openTutor(tutor.id),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  void _export(Set<String> ids) {
    final tutors =
        ref.read(adminDataProvider).tutors.where((t) => ids.contains(t.id));
    CsvExport.copy(
      context,
      label: '${tutors.length} tutor${tutors.length == 1 ? '' : 's'}',
      headers: const [
        'Name',
        'Email',
        'Contact',
        'Rating',
        'Availability',
        'Active classes',
        'Pending classes',
        'Completed classes',
        'Courses',
      ],
      rows: [
        for (final t in tutors)
          [
            t.name,
            t.email,
            t.contact.isEmpty ? 'N/A' : t.contact,
            t.tutorRating.toStringAsFixed(1),
            t.tutorAvailability ? 'Available' : 'Busy',
            '${t.activeClassCount}',
            '${t.pendingClassCount}',
            '${t.completedClassCount}',
            t.courses.join('; '),
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
          'Delete $count tutor${count == 1 ? '' : 's'}?',
          style: TLText.cardTitle(context.tl.text),
        ),
        content: Text(
          'They are detached from their courses and their reviews are removed. '
          'This cannot be undone.',
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

    ref.read(adminDataProvider.notifier).deleteTutors({..._selected});
    setState(_selected.clear);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$count tutor${count == 1 ? '' : 's'} deleted')),
    );
  }
}
