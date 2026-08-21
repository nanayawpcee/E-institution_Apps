import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/student_data.dart';
import '../../services/local_auth_service.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_widgets.dart';
import 'Utils/chatpagecard.dart';
import 'aithread.dart';

/// Conversation list — one row per tutor the student is enrolled with.
class ChatPage extends ConsumerWidget {
  static String routeName = 'ChatPage';

  const ChatPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tl;
    final student = ref.watch(authProvider);
    ref.watch(studentDataProvider);
    final tutors = student == null
        ? []
        : ref.read(studentDataProvider.notifier).tutorsByIds(student.tutors);

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(title: const Text('Messages')),
      // The assistant is always available, so it is pinned above the tutor
      // conversations rather than being part of the list.
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          const AiAssistantRow(),
          const SizedBox(height: 12),
          if (tutors.isEmpty)
            const TLEmptyState(
              icon: Icons.forum_outlined,
              title: 'No tutor conversations yet',
              message: 'Request a tutor and your chat will show up here.',
            )
          else
            for (final tutor in tutors)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TutorChatCard(
                  tutorId: tutor.id,
                  imageUrl: tutor.userImage,
                  tutorName: tutor.name,
                  isOpen: tutor.available,
                ),
              ),
        ],
      ),
    );
  }
}
