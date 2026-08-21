import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../models/tutorclass.dart' as models;
import '../../../providers/admin_data.dart';
import '../../../theme/app_table.dart';
import '../../../theme/app_text.dart';
import '../../../theme/app_tokens.dart';
import '../../../theme/app_widgets.dart';
import '../../../utils/csv_export.dart';
import '../../../utils/image_helpers.dart';

/// Route wrapper kept for the named-route table.
class TutorReviews extends StatelessWidget {
  static String routeName = 'TutorReviews';

  const TutorReviews({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const TutorReviewsBody();
}

class TutorReviewsBody extends ConsumerStatefulWidget {
  const TutorReviewsBody({Key? key}) : super(key: key);

  @override
  ConsumerState<TutorReviewsBody> createState() => _TutorReviewsBodyState();
}

class _TutorReviewsBodyState extends ConsumerState<TutorReviewsBody> {
  final _searchController = TextEditingController();
  String _search = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(adminDataProvider);
    final q = _search.trim().toLowerCase();

    String tutorName(String tutorId) {
      final match = data.tutors.where((t) => t.id == tutorId);
      return match.isEmpty ? 'Unknown Tutor' : match.first.name;
    }

    final reviews = data.tutorReviews
        .where((r) => q.isEmpty || tutorName(r.tutorId).toLowerCase().contains(q))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TLPageHeader(
          title: 'Tutor Reviews',
          subtitle: '${reviews.length} review${reviews.length == 1 ? '' : 's'}',
          trailing: TLSecondaryButton(
            label: 'Export CSV',
            icon: Icons.file_download_outlined,
            onPressed: () => CsvExport.copy(
              context,
              label: '${reviews.length} review${reviews.length == 1 ? '' : 's'}',
              headers: const ['Tutor', 'Reviewer', 'Rating', 'Date', 'Message'],
              rows: [
                for (final r in reviews)
                  [
                    tutorName(r.tutorId),
                    r.postedBy,
                    '${r.rating}',
                    DateFormat('yyyy-MM-dd').format(r.timePosted),
                    r.message,
                  ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        TLTableSearch(
          hint: 'Search by tutor name',
          controller: _searchController,
          onChanged: (v) => setState(() => _search = v),
        ),
        const SizedBox(height: 16),
        if (reviews.isEmpty)
          TLEmptyState(
            icon: Icons.star_outline_rounded,
            title: q.isEmpty ? 'No reviews yet' : 'No matching reviews',
            message: q.isEmpty
                ? 'Reviews appear here once students rate their tutors.'
                : 'Try a different tutor name.',
          )
        else
          for (final review in reviews)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ReviewCard(
                review: review,
                tutorName: tutorName(review.tutorId),
              ),
            ),
      ],
    );
  }
}

/// Review row: reviewer avatar, tutor name, date, message and star count.
class ReviewCard extends StatelessWidget {
  const ReviewCard({
    Key? key,
    required this.review,
    required this.tutorName,
  }) : super(key: key);

  final models.TutorReview review;
  final String tutorName;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return TLPanel(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: t.cardAlt,
              shape: BoxShape.circle,
              image: DecorationImage(
                image: appImageProvider(review.userImage),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        tutorName,
                        style: TLText.cardTitle(t.text),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      DateFormat('d MMM y').format(review.timePosted),
                      style: TLText.sub(t.textSub).copyWith(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  review.message,
                  style: TLText.bodyStrong(t.textSub)
                      .copyWith(fontWeight: FontWeight.w400, height: 1.5),
                ),
                const SizedBox(height: 4),
                Text(
                  '${'★' * review.rating}${'☆' * (5 - review.rating)}',
                  style: TLText.sub(TLTokens.warning).copyWith(fontSize: 12.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
