import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/admin_data.dart';
import '../../../theme/app_text.dart';
import '../../../theme/app_tokens.dart';
import '../../../theme/app_widgets.dart';
import '../../../utils/image_helpers.dart';
import '../Course/coursedetail.dart' show DetailRow;
import '../Shell/admin_nav.dart';

/// Read-only tutor record reached from the tutors table or global search.
class TutorDetailBody extends ConsumerWidget {
  const TutorDetailBody({Key? key, required this.tutorId}) : super(key: key);

  final String tutorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tl;
    final data = ref.watch(adminDataProvider);
    final matches = data.tutors.where((tutor) => tutor.id == tutorId);

    if (matches.isEmpty) {
      return TLEmptyState(
        icon: Icons.search_off_rounded,
        title: 'Tutor not found',
        message: 'They may have been removed.',
        action: TLSmallButton(
          label: 'Back to tutors',
          onPressed: () =>
              ref.read(adminNavProvider.notifier).go(AdminPageKey.tutors),
        ),
      );
    }

    final tutor = matches.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            TLIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onPressed: () =>
                  ref.read(adminNavProvider.notifier).go(AdminPageKey.tutors),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                tutor.name,
                style: TLText.pageTitle(t.text),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TLPanel(
          padding: const EdgeInsets.all(22),
          child: Wrap(
            spacing: 22,
            runSpacing: 22,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: t.cardAlt,
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: appImageProvider(tutor.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 280, maxWidth: 640),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DetailRow(label: 'Email', value: tutor.email),
                    DetailRow(
                      label: 'Contact',
                      value: tutor.contact.isEmpty ? 'N/A' : tutor.contact,
                    ),
                    DetailRow(
                      label: 'Rating',
                      value: '★ ${tutor.tutorRating.toStringAsFixed(1)}',
                    ),
                    DetailRow(
                      label: 'Availability',
                      value: tutor.tutorAvailability ? 'Available' : 'Busy',
                    ),
                    DetailRow(
                      label: 'Active / Pending / Completed',
                      value: '${tutor.activeClassCount} / '
                          '${tutor.pendingClassCount} / '
                          '${tutor.completedClassCount}',
                    ),
                    DetailRow(
                      label: 'Courses',
                      value: tutor.courses.isEmpty
                          ? 'None assigned'
                          : tutor.courses.join(', '),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
