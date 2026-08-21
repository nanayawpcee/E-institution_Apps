import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../components/reviewcards.dart';
import '../../providers/student_data.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_widgets.dart';

/// Every review left against one course or one tutor.
class AllReviewsScreen extends ConsumerWidget {
  const AllReviewsScreen({Key? key, this.courseId, this.tutorId})
      : assert(courseId != null || tutorId != null,
            'Reviews must be scoped to a course or a tutor'),
        super(key: key);

  final String? courseId;
  final String? tutorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tl;
    ref.watch(studentDataProvider);
    final notifier = ref.read(studentDataProvider.notifier);
    final reviews = courseId != null
        ? notifier.reviewsForCourse(courseId!)
        : notifier.reviewsForTutor(tutorId!);

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(title: const Text('All reviews')),
      body: reviews.isEmpty
          ? const TLEmptyState(
              icon: Icons.rate_review_outlined,
              title: 'No reviews yet',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              itemCount: reviews.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) => ReviewCard(review: reviews[i]),
            ),
    );
  }
}
