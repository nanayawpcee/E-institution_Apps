import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../providers/tutor_data.dart';
import '../../../services/local_auth_service.dart';
import '../../../theme/app_text.dart';
import '../../../theme/app_tokens.dart';
import '../../../theme/app_widgets.dart';
import '../../Profile/userProfileScreen.dart' show TLAvatar;
import '../interactionpage.dart';

/// Conversation row: avatar, student name, last message preview and its time.
class StudentChatCard extends ConsumerWidget {
  const StudentChatCard({
    Key? key,
    required this.studentId,
    required this.studentName,
    required this.imageUrl,
  }) : super(key: key);

  final String studentId;
  final String studentName;
  final String imageUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tl;
    final tutorId = ref.watch(authProvider)?.id ?? '';
    final messages = ref.watch(tutorDataProvider).chats[
            TutorAppDataNotifier.chatKey(tutorId, studentId)] ??
        const [];
    final last = messages.isEmpty ? null : messages.last;

    return TLCard(
      padding: const EdgeInsets.all(12),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InteractionPage(
            name: studentName,
            studentId: studentId,
            tutorId: tutorId,
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
                        studentName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TLText.cardTitle(t.text)
                            .copyWith(fontSize: 14.5),
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
                      : '${last.senderId == tutorId ? 'You: ' : ''}'
                          '${last.message}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TLText.meta(t.textSub).copyWith(fontSize: 12.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
