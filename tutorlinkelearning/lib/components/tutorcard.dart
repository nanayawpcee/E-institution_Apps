import 'package:flutter/material.dart';

import '../Screens/Profile/userProfileScreen.dart' show TLAvatar;
import '../Screens/TutorDetails/tutordetails.dart';
import '../theme/app_text.dart';
import '../theme/app_tokens.dart';
import '../theme/app_widgets.dart';

/// Tutor row: avatar, name, student count, availability and rating.
class TutorCard extends StatelessWidget {
  const TutorCard({
    Key? key,
    required this.tutorId,
    required this.imageUrl,
    required this.courseId,
    required this.tutorName,
    required this.students,
    required this.rating,
    required this.isOpen,
  }) : super(key: key);

  final String tutorId;
  final String imageUrl;
  final String courseId;
  final String tutorName;
  final int students;
  final int rating;
  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return TLCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TutorDetailScreen(
            tutorId: tutorId,
            courseId: courseId,
          ),
        ),
      ),
      child: Row(
        children: [
          TLAvatar(imagePath: imageUrl, size: 56),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tutorName,
                  style: TLText.cardTitle(t.text).copyWith(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '$students std(s)',
                      style: TLText.meta(t.textSub),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isOpen ? 'Open' : 'Closed',
                      style: TLText.meta(
                        isOpen ? TLTokens.success : TLTokens.danger,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          TLRating(value: rating.toDouble()),
        ],
      ),
    );
  }
}
