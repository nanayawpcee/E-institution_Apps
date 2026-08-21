import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../components/reviewcards.dart';
import '../../providers/student_data.dart';
import '../../services/local_auth_service.dart';
import '../../theme/app_text.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_widgets.dart';

/// Reviews for one course, with a sheet for leaving your own.
class ReviewScreen extends ConsumerWidget {
  static String routeName = 'Review Screen';

  const ReviewScreen({Key? key, required this.courseId}) : super(key: key);

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tl;
    ref.watch(studentDataProvider);
    final notifier = ref.read(studentDataProvider.notifier);
    final course = notifier.courseById(courseId);
    final reviews = notifier.reviewsForCourse(courseId);

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(title: Text(course?.name ?? 'Reviews')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: TLTokens.primary,
        foregroundColor: Colors.white,
        onPressed: () => _openRatingSheet(context, ref),
        icon: const Icon(Icons.star_rounded),
        label: Text(
          'Rate course',
          style: TLText.cardTitle(Colors.white).copyWith(fontSize: 14),
        ),
      ),
      body: reviews.isEmpty
          ? const TLEmptyState(
              icon: Icons.rate_review_outlined,
              title: 'No reviews yet',
              message: 'Be the first to review this course.',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
              itemCount: reviews.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) => ReviewCard(review: reviews[i]),
            ),
    );
  }

  Future<void> _openRatingSheet(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    double stars = 5;

    await showTLSheet<void>(
      context: context,
      builder: (context) {
        final t = context.tl;
        return StatefulBuilder(
          builder: (context, setSheetState) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Rate this course', style: TLText.cardTitle(t.text)),
              const SizedBox(height: 14),
              Center(
                child: RatingBar.builder(
                  initialRating: stars,
                  minRating: 1,
                  itemCount: 5,
                  itemSize: 34,
                  glow: false,
                  itemBuilder: (context, _) => const Icon(
                    Icons.star_rounded,
                    color: TLTokens.warning,
                  ),
                  onRatingUpdate: (v) => setSheetState(() => stars = v),
                ),
              ),
              const SizedBox(height: 16),
              TLField(
                hint: 'Share what the course was like',
                controller: controller,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TLButton(
                label: 'Rate and review',
                onPressed: () {
                  final student = ref.read(authProvider);
                  ref.read(studentDataProvider.notifier).addCourseReview(
                        courseId,
                        student?.name ?? 'Anonymous',
                        controller.text.trim().isEmpty
                            ? 'Great experience overall.'
                            : controller.text.trim(),
                        DateFormat('d MMM y').format(DateTime.now()),
                        student?.userImage ?? '',
                      );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );

    controller.dispose();
  }
}
