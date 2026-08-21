import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Components/home.dart';
import '../../models/app_models.dart';
import '../../providers/tutor_data.dart';
import '../../services/local_auth_service.dart';
import '../../theme/app_text.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_widgets.dart';
import 'aithread.dart';
import 'models/chatcard.dart';

/// Chat tab: one row per student the tutor teaches.
class ChatPage extends ConsumerWidget {
  static String routeName = 'ChatPage';

  const ChatPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tl;
    final tutor = ref.watch(authProvider);
    ref.watch(tutorDataProvider);
    final List<Student> students = tutor == null
        ? []
        : ref.read(tutorDataProvider.notifier).studentsByIds(tutor.students);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, kTabBottomInset),
        children: [
          Text('ChatRoom', style: TLText.screenTitle(t.text)),
          const SizedBox(height: 18),
          // The assistant is always available, so it is pinned above the
          // student conversations rather than being part of the list.
          const AiAssistantRow(),
          const SizedBox(height: 10),
          if (students.isEmpty)
            const TLEmptyState(
              icon: Icons.forum_outlined,
              title: 'No student conversations yet',
              message: 'Accept a request and the chat opens here.',
            )
          else
            for (final student in students)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: StudentChatCard(
                  studentId: student.id,
                  studentName: student.name,
                  imageUrl: student.userImage,
                ),
              ),
        ],
      ),
    );
  }
}
