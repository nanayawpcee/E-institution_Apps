import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/tutor_data.dart';
import '../../services/chat_read_state.dart';
import '../../services/local_auth_service.dart';
import '../../theme/app_text.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_widgets.dart';

/// One conversation with a student. The tutor's own messages sit right in the
/// accent, the student's left on the recessed surface.
class InteractionPage extends ConsumerStatefulWidget {
  const InteractionPage({
    Key? key,
    required this.name,
    required this.tutorId,
    required this.studentId,
  }) : super(key: key);

  final String name;
  final String tutorId;
  final String studentId;

  @override
  ConsumerState<InteractionPage> createState() => _InteractionPageState();
}

class _InteractionPageState extends ConsumerState<InteractionPage> {
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Opening the thread is what clears its unread badge.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatReadProvider.notifier).markRead(
            TutorAppDataNotifier.chatKey(widget.tutorId, widget.studentId),
          );
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    final key = TutorAppDataNotifier.chatKey(widget.tutorId, widget.studentId);
    final messages = [...?ref.watch(tutorDataProvider).chats[key]]
      ..sort((a, b) => b.time.compareTo(a.time));

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(title: Text(widget.name)),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const TLEmptyState(
                    icon: Icons.forum_outlined,
                    title: 'No messages yet',
                    message: 'Say hello to get the conversation started.',
                  )
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    itemCount: messages.length,
                    itemBuilder: (context, i) => _Bubble(
                      message: messages[i].message,
                      time: messages[i].time,
                      mine: messages[i].senderId == widget.tutorId,
                    ),
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: TextField(
                        controller: _messageController,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        style: TLText.sub(t.text),
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 18),
                          border: _pill(t.border),
                          enabledBorder: _pill(t.border),
                          focusedBorder: _pill(TLTokens.primary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Material(
                    color: TLTokens.primary,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: _send,
                      customBorder: const CircleBorder(),
                      child: const SizedBox(
                        width: 46,
                        height: 46,
                        child: Icon(
                          Icons.send_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _pill(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(23),
        borderSide: BorderSide(color: c, width: 1.5),
      );

  void _send() {
    final message = _messageController.text.trim();
    final senderId = ref.read(authProvider)?.id;
    if (message.isEmpty || senderId == null) return;

    ref.read(tutorDataProvider.notifier).sendChatMessage(
          widget.tutorId,
          widget.studentId,
          senderId,
          message,
        );
    _messageController.clear();
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.message,
    required this.time,
    required this.mine,
  });

  final String message;
  final DateTime time;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    final textColor = mine ? Colors.white : t.text;

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color: mine ? TLTokens.primary : t.cardAlt,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(mine ? 16 : 4),
            bottomRight: Radius.circular(mine ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(message, style: TLText.sub(textColor).copyWith(height: 1.4)),
            const SizedBox(height: 3),
            Text(
              DateFormat('EEE, h:mm a').format(time),
              style: TLText.tag(mine ? Colors.white70 : t.textSub)
                  .copyWith(fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }
}
