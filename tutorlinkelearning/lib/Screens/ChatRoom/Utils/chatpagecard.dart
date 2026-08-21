import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../providers/student_data.dart';
import '../../../services/local_auth_service.dart';
import '../../../theme/app_text.dart';
import '../../../theme/app_tokens.dart';
import '../../../theme/app_widgets.dart';
import '../../Profile/userProfileScreen.dart' show TLAvatar;
import '../chatpage.dart';

/// Conversation row: avatar, tutor name, last message preview and its time.
class TutorChatCard extends ConsumerWidget {
  const TutorChatCard({
    Key? key,
    required this.tutorId,
    required this.imageUrl,
    required this.tutorName,
    required this.isOpen,
  }) : super(key: key);

  final String tutorId;
  final String imageUrl;
  final String tutorName;
  final bool isOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tl;
    final studentId = ref.watch(authProvider)?.id ?? '';
    final messages =
        ref.watch(studentDataProvider).chats[
                StudentAppDataNotifier.chatKey(tutorId, studentId)] ??
            const [];
    final last = messages.isEmpty ? null : messages.last;

    return TLCard(
      padding: const EdgeInsets.all(12),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InteractionPage(
            tutorId: tutorId,
            studentId: studentId,
            name: tutorName,
          ),
        ),
      ),
      child: Row(
        children: [
          TLAvatar(imagePath: imageUrl, size: 48),
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TLText.cardTitle(t.text),
                      ),
                    ),
                    if (last != null)
                      Text(
                        DateFormat.jm().format(last.time),
                        style: TLText.meta(t.textSub),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  last == null
                      ? 'Say hello'
                      : '${last.senderId == studentId ? 'You: ' : ''}'
                          '${last.message}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TLText.meta(t.textSub).copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
