import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../Screens/ClassRoom/coursematerialbucket.dart';
import '../Screens/Profile/userProfileScreen.dart' show TLAvatar;
import '../services/local_auth_service.dart';
import '../theme/app_text.dart';
import '../theme/app_tokens.dart';
import '../theme/app_widgets.dart';

/// Student row: portrait, name, the course they're taking and their progress.
/// Tapping opens that student's classroom.
class StudentsCard extends ConsumerWidget {
  const StudentsCard({
    Key? key,
    required this.studentId,
    required this.userImage,
    required this.name,
    required this.courseLabel,
    this.progress,
  }) : super(key: key);

  final String studentId;
  final String userImage;
  final String name;
  final String courseLabel;

  /// 0..1, or null when there is no active class to measure.
  final double? progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tl;
    final tutorId = ref.watch(authProvider)?.id ?? '';

    return TLCard(
      padding: const EdgeInsets.all(12),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CourseMaterialPage(
            tutorId: tutorId,
            studentId: studentId,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(TLTokens.rLg),
            child: SizedBox(
              width: 60,
              height: 60,
              child: TLAvatar(imagePath: userImage, size: 60),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TLText.cardTitle(t.text),
                ),
                const SizedBox(height: 3),
                Text(
                  courseLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TLText.meta(t.textSub),
                ),
                if (progress != null) ...[
                  const SizedBox(height: 8),
                  TLProgressBar(value: progress!),
                  const SizedBox(height: 3),
                  Text(
                    '${(progress! * 100).round()}% of class elapsed',
                    style: TLText.tag(t.textSub)
                        .copyWith(fontWeight: FontWeight.w400),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
