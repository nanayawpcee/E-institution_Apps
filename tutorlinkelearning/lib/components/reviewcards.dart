import 'package:flutter/material.dart';

import '../Screens/Profile/userProfileScreen.dart' show TLAvatar;
import '../models/app_models.dart';
import '../theme/app_text.dart';
import '../theme/app_tokens.dart';
import '../theme/app_widgets.dart';

/// Review row on the recessed surface: reviewer avatar, name, date, message.
class ReviewCard extends StatelessWidget {
  const ReviewCard({Key? key, required this.review}) : super(key: key);

  final Review review;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return TLCard(
      recessed: true,
      radius: 14,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TLAvatar(imagePath: review.userImage, size: 40),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        review.postedBy,
                        style: TLText.cardTitle(t.text).copyWith(fontSize: 14),
                      ),
                    ),
                    Text(review.timePosted, style: TLText.meta(t.textSub)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  review.message,
                  style: TLText.sub(t.textSub).copyWith(height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
