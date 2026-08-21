import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../components/reviewcards.dart';
import '../../providers/student_data.dart';
import '../../services/local_auth_service.dart';
import '../../theme/app_text.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_widgets.dart';
import '../../utils/image_helpers.dart';
import '../CourseDetails/allreviews.dart';

/// Tutor detail: cover portrait, key stats, bio, reviews, and the request
/// action whose label reflects the student's current standing with the course.
class TutorDetailScreen extends ConsumerStatefulWidget {
  const TutorDetailScreen({
    Key? key,
    required this.tutorId,
    required this.courseId,
  }) : super(key: key);

  final String tutorId;
  final String courseId;

  @override
  ConsumerState<TutorDetailScreen> createState() => _TutorDetailScreenState();
}

class _TutorDetailScreenState extends ConsumerState<TutorDetailScreen> {
  bool _sending = false;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    final student = ref.watch(authProvider);
    ref.watch(studentDataProvider);
    final notifier = ref.read(studentDataProvider.notifier);
    final tutor = notifier.tutorById(widget.tutorId);

    if (tutor == null) {
      return Scaffold(
        backgroundColor: t.bg,
        appBar: AppBar(),
        body: const TLEmptyState(
          icon: Icons.search_off_rounded,
          title: 'Tutor not found',
        ),
      );
    }

    final isActive = student?.activeCourses.contains(widget.courseId) ?? false;
    final isPending = (student?.pendingCourses.contains(widget.courseId) ??
            false) ||
        (student != null && notifier.hasRequest(student.id, widget.courseId));
    final reviews = notifier.reviewsForTutor(tutor.id);

    return Scaffold(
      backgroundColor: t.bg,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              children: [
                SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: tutor.userImage.isEmpty
                      ? ColoredBox(color: t.cardAlt)
                      : Image(
                          image: appImageProvider(tutor.userImage),
                          fit: BoxFit.cover,
                        ),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 16,
                  child: Material(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(TLTokens.rMd),
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(TLTokens.rMd),
                      child: const SizedBox(
                        width: 38,
                        height: 38,
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 17,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          tutor.name,
                          style: TLText.sectionTitle(t.text),
                        ),
                      ),
                      TLRating(value: tutor.rating.toDouble(), size: 13),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _Stat(
                        value: '${tutor.students.length}',
                        label: 'Student(s)',
                      ),
                      _Stat(
                        value: tutor.contact.isEmpty ? '—' : tutor.contact,
                        label: 'Contact',
                      ),
                      _Stat(
                        value: tutor.available ? 'Open' : 'Closed',
                        label: 'Availability',
                        valueColor: tutor.available
                            ? TLTokens.success
                            : TLTokens.danger,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    tutor.bio,
                    style: TLText.sub(t.textSub).copyWith(height: 1.6),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(
                        child: Text(
                          'Reviews',
                          style: TLText.sectionTitle(t.text)
                              .copyWith(fontSize: 16),
                        ),
                      ),
                      if (reviews.isNotEmpty)
                        InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AllReviewsScreen(tutorId: tutor.id),
                            ),
                          ),
                          child: Text(
                            'All reviews',
                            style: TLText.sub(TLTokens.primary)
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          if (reviews.isEmpty)
            const SliverToBoxAdapter(
              child: TLEmptyState(
                icon: Icons.rate_review_outlined,
                title: 'No reviews yet',
                message: 'Be the first to review this tutor.',
              ),
            )
          else
            SliverList.builder(
              itemCount: reviews.length,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: ReviewCard(review: reviews[i]),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: _requestButton(
            isActive: isActive,
            isPending: isPending,
            available: tutor.available,
          ),
        ),
      ),
    );
  }

  /// One action whose label depends on where the student already stands.
  Widget _requestButton({
    required bool isActive,
    required bool isPending,
    required bool available,
  }) {
    if (isActive) {
      return const TLButton(
        label: 'You have an active session',
        onPressed: null,
      );
    }
    if (isPending) {
      return const TLButton(
        label: 'You have a pending request',
        onPressed: null,
      );
    }
    if (!available) {
      return const TLButton(label: 'Unavailable', onPressed: null);
    }
    return TLButton(
      label: 'Request Tutor',
      busy: _sending,
      onPressed: _sending ? null : _sendRequest,
    );
  }

  void _sendRequest() {
    final student = ref.read(authProvider);
    if (student == null) return;

    setState(() => _sending = true);
    ref
        .read(studentDataProvider.notifier)
        .sendRequest(student.id, widget.tutorId, widget.courseId);
    ref.read(authProvider.notifier).addPendingCourse(widget.courseId);
    setState(() => _sending = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request sent to tutor')),
    );
  }
}

/// One figure in the tutor stat strip.
class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.valueColor});

  final String value;
  final String label;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TLText.cardTitle(valueColor ?? t.text),
          ),
          const SizedBox(height: 2),
          Text(label, style: TLText.meta(t.textSub)),
        ],
      ),
    );
  }
}
