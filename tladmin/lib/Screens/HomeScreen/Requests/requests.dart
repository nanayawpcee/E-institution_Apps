import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../providers/admin_data.dart';
import '../../../theme/app_table.dart';
import '../../../theme/app_text.dart';
import '../../../theme/app_tokens.dart';
import '../../../theme/app_widgets.dart';

enum _RequestFilter { all, pending, resolved }

/// Tutoring session requests, filterable by state and resolvable in place.
class RequestsBody extends ConsumerStatefulWidget {
  const RequestsBody({Key? key}) : super(key: key);

  @override
  ConsumerState<RequestsBody> createState() => _RequestsBodyState();
}

class _RequestsBodyState extends ConsumerState<RequestsBody> {
  _RequestFilter _filter = _RequestFilter.all;

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(adminDataProvider);
    final requests = data.requests.where((r) {
      switch (_filter) {
        case _RequestFilter.all:
          return true;
        case _RequestFilter.pending:
          return r.isPending;
        case _RequestFilter.resolved:
          return !r.isPending;
      }
    }).toList();

    String courseName(String id) {
      final match = data.courses.where((c) => c.id == id);
      return match.isEmpty ? 'Unknown course' : match.first.name;
    }

    String tutorName(String id) {
      final match = data.tutors.where((t) => t.id == id);
      return match.isEmpty ? 'Unknown tutor' : match.first.name;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const TLPageHeader(
          title: 'Requests',
          subtitle: 'Tutoring session requests from students',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            for (final filter in _RequestFilter.values) ...[
              if (filter != _RequestFilter.values.first)
                const SizedBox(width: 8),
              _FilterChip(
                label: _label(filter),
                selected: _filter == filter,
                onTap: () => setState(() => _filter = filter),
              ),
            ],
          ],
        ),
        TLTable(
          columns: const [
            TLColumn(label: 'Course', flex: 2),
            TLColumn(label: 'Tutor', flex: 2),
            TLColumn(label: 'Date', flex: 1),
            TLColumn(label: 'Status', flex: 1),
            TLColumn(width: 100, alignment: Alignment.centerRight),
          ],
          emptyState: const TLEmptyState(
            icon: Icons.inbox_outlined,
            title: 'No requests in this view',
            message: 'Switch filters to see other requests.',
          ),
          rows: [
            for (final request in requests)
              TLTableRow(
                cells: [
                  TLCell(courseName(request.courseId), strong: true),
                  TLCell(tutorName(request.tutorId)),
                  TLCell(DateFormat('d MMM y').format(request.date)),
                  TLTag(
                    label: request.isPending ? 'Pending' : 'Resolved',
                    color: request.isPending
                        ? TLTokens.warning
                        : TLTokens.success,
                  ),
                  request.isPending
                      ? TLViewLink(
                          label: 'Resolve',
                          onTap: () {
                            ref
                                .read(adminDataProvider.notifier)
                                .setRequestPending(request.id, false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Request resolved')),
                            );
                          },
                        )
                      : const SizedBox.shrink(),
                ],
              ),
          ],
        ),
      ],
    );
  }

  String _label(_RequestFilter filter) {
    switch (filter) {
      case _RequestFilter.all:
        return 'All';
      case _RequestFilter.pending:
        return 'Pending';
      case _RequestFilter.resolved:
        return 'Resolved';
    }
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return Material(
      color: selected ? TLTokens.primary : t.cardAlt,
      borderRadius: BorderRadius.circular(TLTokens.rSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TLTokens.rSm),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: TLText.buttonSm(selected ? Colors.white : t.textSub),
          ),
        ),
      ),
    );
  }
}
