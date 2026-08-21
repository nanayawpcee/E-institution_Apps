import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/admin_data.dart';
import '../../../theme/app_text.dart';
import '../../../theme/app_tokens.dart';
import '../../../theme/app_widgets.dart';
import '../../../utils/image_helpers.dart';
import '../Shell/admin_nav.dart';

/// Read-only course record reached from the courses table or global search.
class CourseDetailBody extends ConsumerWidget {
  const CourseDetailBody({Key? key, required this.courseId}) : super(key: key);

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tl;
    final data = ref.watch(adminDataProvider);
    final matches = data.courses.where((c) => c.id == courseId);

    if (matches.isEmpty) {
      return TLEmptyState(
        icon: Icons.search_off_rounded,
        title: 'Course not found',
        message: 'It may have been deleted.',
        action: TLSmallButton(
          label: 'Back to courses',
          onPressed: () =>
              ref.read(adminNavProvider.notifier).go(AdminPageKey.courses),
        ),
      );
    }

    final course = matches.first;
    final tutorNames = data.tutors
        .where((tutor) => course.tutors.contains(tutor.id))
        .map((tutor) => tutor.name)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            TLIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onPressed: () =>
                  ref.read(adminNavProvider.notifier).go(AdminPageKey.courses),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                course.name,
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
                  borderRadius: BorderRadius.circular(14),
                  image: DecorationImage(
                    image: appImageProvider(course.imageUrl),
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
                    DetailRow(
                      label: 'Department',
                      value: course.department,
                    ),
                    DetailRow(
                      label: 'Rating',
                      value: '★ ${course.courseRating.toStringAsFixed(1)}',
                    ),
                    DetailRow(
                      label: 'Duration',
                      value: '${course.duration.toStringAsFixed(0)} hrs',
                    ),
                    DetailRow(
                      label: 'Active / Pending classes',
                      value:
                          '${course.activeClassCount} / ${course.pendingClassCount}',
                    ),
                    DetailRow(
                      label: 'Tutors',
                      value: tutorNames.isEmpty
                          ? 'None assigned'
                          : tutorNames.join(', '),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      course.info,
                      style: TLText.bodyStrong(t.textSub).copyWith(
                        fontWeight: FontWeight.w400,
                        height: 1.6,
                      ),
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

/// Label/value pair separated by a hairline, as used on both detail pages.
class DetailRow extends StatelessWidget {
  const DetailRow({Key? key, required this.label, required this.value})
      : super(key: key);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return Container(
      padding: const EdgeInsets.only(bottom: 6, top: 6),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: t.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TLText.bodyStrong(t.text).copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TLText.bodyStrong(t.text)
                  .copyWith(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }
}
