import 'package:flutter/material.dart';

import '../Screens/CourseDetails/coursesdetail.dart';
import '../theme/app_text.dart';
import '../theme/app_tokens.dart';
import '../theme/app_widgets.dart';
import '../utils/coursename.dart';
import '../utils/dateformat.dart';
import '../utils/image_helpers.dart';

/// Compact list row used on Home — 56px thumbnail, title, rating and duration.
class CourseRow extends StatelessWidget {
  const CourseRow({Key? key, required this.course, this.onTap})
      : super(key: key);

  final CoursesType course;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return TLCard(
      onTap: onTap ?? () => openCourseDetail(context, course.courseId),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: t.cardAlt,
              borderRadius: BorderRadius.circular(14),
              image: DecorationImage(
                image: appImageProvider(course.image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TLText.cardTitle(t.text),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    TLRating(value: course.rating.toDouble()),
                    const SizedBox(width: 10),
                    Text(
                      formatDuration(course.duration),
                      style: TLText.meta(t.textSub),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-bleed card used on Explore — cover image with a NEW flag and a
/// bookmark toggle, then title, department and metadata.
class CourseCoverCard extends StatelessWidget {
  const CourseCoverCard({
    Key? key,
    required this.course,
    required this.bookmarked,
    required this.onToggleBookmark,
    this.onTap,
  }) : super(key: key);

  final CoursesType course;
  final bool bookmarked;
  final VoidCallback onToggleBookmark;
  final VoidCallback? onTap;

  /// The design flags anything published in the last week.
  bool get isNew =>
      DateTime.now().difference(course.createdAt).inDays <= 7;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return Material(
      color: t.card,
      borderRadius: BorderRadius.circular(TLTokens.rXl),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap ?? () => openCourseDetail(context, course.courseId),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TLTokens.rXl),
            border: Border.all(color: t.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 130,
                    width: double.infinity,
                    child: Image(
                      image: appImageProvider(course.image),
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (isNew)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: TLTokens.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'NEW',
                          style: TLText.tag(Colors.white)
                              .copyWith(fontSize: 10, letterSpacing: 0.4),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(TLTokens.rSm),
                      child: InkWell(
                        onTap: onToggleBookmark,
                        borderRadius: BorderRadius.circular(TLTokens.rSm),
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: Icon(
                            bookmarked
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            size: 17,
                            color: bookmarked ? TLTokens.primary : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(course.name, style: TLText.cardTitle(t.text)),
                    const SizedBox(height: 4),
                    Text(course.department, style: TLText.meta(t.textSub)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        TLRating(value: course.rating.toDouble()),
                        const SizedBox(width: 12),
                        Text(
                          formatDuration(course.duration),
                          style: TLText.meta(t.textSub),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Enrolled-course card on My Courses — side thumbnail, status pill and, for
/// active courses, a progress track.
class EnrolledCourseCard extends StatelessWidget {
  const EnrolledCourseCard({
    Key? key,
    required this.course,
    required this.statusLabel,
    required this.statusColor,
    required this.statusBackground,
    this.progress,
    this.rateLabel,
    this.onRate,
    this.onTap,
  }) : super(key: key);

  final CoursesType course;
  final String statusLabel;
  final Color statusColor;
  final Color statusBackground;

  /// 0..1 for active courses; null hides the track.
  final double? progress;

  /// Shown for completed courses that have not been reviewed yet.
  final String? rateLabel;
  final VoidCallback? onRate;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return Material(
      color: t.card,
      borderRadius: BorderRadius.circular(TLTokens.rXl),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TLTokens.rXl),
            border: Border.all(color: t.border),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 96,
                  child: Image(
                    image: appImageProvider(course.image),
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(course.name, style: TLText.cardTitle(t.text)),
                        const SizedBox(height: 6),
                        TLStatusChip(
                          label: statusLabel,
                          color: statusColor,
                          background: statusBackground,
                        ),
                        if (progress != null) ...[
                          const SizedBox(height: 8),
                          TLProgressBar(value: progress!),
                          const SizedBox(height: 4),
                          Text(
                            '${(progress! * 100).round()}% complete',
                            style: TLText.tag(t.textSub)
                                .copyWith(fontWeight: FontWeight.w400),
                          ),
                        ],
                        if (rateLabel != null) ...[
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: onRate,
                            child: Text(
                              rateLabel!,
                              style: TLText.meta(TLTokens.primary)
                                  .copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void openCourseDetail(BuildContext context, String courseId) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CourseDetailScreen(courseId: courseId),
    ),
  );
}
