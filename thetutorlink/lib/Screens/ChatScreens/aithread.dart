import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../services/ai_assistant.dart';
import '../../services/claude_client.dart';
import '../../theme/app_text.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_widgets.dart';

/// Gradient "AI" disc that stands in for the assistant's avatar.
class AiAvatar extends StatelessWidget {
  const AiAvatar({Key? key, this.size = 48}) : super(key: key);

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        gradient: TLTokens.brandGradient,
        shape: BoxShape.circle,
      ),
      child: Text(
        'AI',
        style: TLText.cardTitle(Colors.white).copyWith(
          fontSize: size * 0.27,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Pinned row at the top of the chat list that opens the assistant.
class AiAssistantRow extends ConsumerWidget {
  const AiAssistantRow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tl;
    final assistant = ref.watch(aiAssistantProvider);
    final last = assistant.last;

    return TLCard(
      padding: const EdgeInsets.all(12),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AiThreadScreen()),
      ),
      child: Row(
        children: [
          const AiAvatar(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Teaching Assistant',
                  style: TLText.cardTitle(t.text).copyWith(fontSize: 14.5),
                ),
                const SizedBox(height: 3),
                Text(
                  last?.text ?? 'Get help planning lessons and grading',
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

/// The assistant conversation.
class AiThreadScreen extends ConsumerStatefulWidget {
  const AiThreadScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AiThreadScreen> createState() => _AiThreadScreenState();
}

class _AiThreadScreenState extends ConsumerState<AiThreadScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    final assistant = ref.watch(aiAssistantProvider);
    final available = AiConfig.isConfigured;

    // Newest first, because the list renders reversed.
    final entries = assistant.messages.reversed.toList();

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            const AiAvatar(size: 32),
            const SizedBox(width: 10),
            Text('AI Teaching Assistant', style: TLText.cardTitle(t.text)),
          ],
        ),
        actions: [
          if (assistant.messages.isNotEmpty)
            IconButton(
              tooltip: 'Clear conversation',
              onPressed: () => ref.read(aiAssistantProvider.notifier).clear(),
              icon: Icon(Icons.delete_outline_rounded, color: t.textSub),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: !available
                ? const TLEmptyState(
                    icon: Icons.auto_awesome_outlined,
                    title: 'Assistant unavailable',
                    message:
                        'This build has no assistant endpoint configured, so '
                        'replies are turned off.',
                  )
                : assistant.messages.isEmpty
                    ? const _Suggestions()
                    : ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                        // One extra leading row holds the pending placeholder.
                        itemCount: entries.length + (assistant.loading ? 1 : 0),
                        itemBuilder: (context, i) {
                          if (assistant.loading && i == 0) {
                            return const _ThinkingBubble();
                          }
                          final entry =
                              entries[assistant.loading ? i - 1 : i];
                          return _Bubble(
                            message: entry.text,
                            time: entry.time,
                            mine: entry.fromMe,
                          );
                        },
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
                        controller: _controller,
                        enabled: available,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        style: TLText.sub(t.text),
                        decoration: InputDecoration(
                          hintText: available
                              ? 'Ask about lessons or grading...'
                              : 'Assistant unavailable',
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 18),
                          border: _pill(t.border),
                          enabledBorder: _pill(t.border),
                          focusedBorder: _pill(TLTokens.primary),
                          disabledBorder: _pill(t.border),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Material(
                    color: available && !assistant.loading
                        ? TLTokens.primary
                        : TLTokens.primary.withValues(alpha: 0.4),
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: available && !assistant.loading ? _send : null,
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
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    _controller.clear();
    ref.read(aiAssistantProvider.notifier).send(text);
  }
}

/// Opening state: a short explanation and a few prompts to tap.
class _Suggestions extends ConsumerWidget {
  const _Suggestions();

  static const List<String> _prompts = [
    'Plan a 45-minute session on recursion',
    'Explain derivatives simply for a beginner',
    'How should I grade this assignment fairly?',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tl;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
      children: [
        const Center(child: AiAvatar(size: 64)),
        const SizedBox(height: 16),
        Text(
          'Get help planning lessons and grading',
          textAlign: TextAlign.center,
          style: TLText.cardTitle(t.text),
        ),
        const SizedBox(height: 6),
        Text(
          'I can explain concepts, help you revise, or talk through an '
          'assignment you are stuck on.',
          textAlign: TextAlign.center,
          style: TLText.sub(t.textSub).copyWith(height: 1.5),
        ),
        const SizedBox(height: 22),
        for (final prompt in _prompts)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: TLCard(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              onTap: () =>
                  ref.read(aiAssistantProvider.notifier).send(prompt),
              child: Row(
                children: [
                  Expanded(
                    child: Text(prompt, style: TLText.sub(t.text)),
                  ),
                  Icon(Icons.north_east_rounded, size: 16, color: t.textSub),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Placeholder shown while a reply is in flight.
class _ThinkingBubble extends StatelessWidget {
  const _ThinkingBubble();

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: t.cardAlt,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 13,
              height: 13,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: t.textSub,
              ),
            ),
            const SizedBox(width: 9),
            Text('Thinking…', style: TLText.sub(t.textSub)),
          ],
        ),
      ),
    );
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
          maxWidth: MediaQuery.of(context).size.width * 0.78,
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
            Text(message, style: TLText.sub(textColor).copyWith(height: 1.45)),
            const SizedBox(height: 3),
            Text(
              DateFormat('h:mm a').format(time),
              style: TLText.tag(mine ? Colors.white70 : t.textSub)
                  .copyWith(fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }
}

/// Floating shortcut into the assistant, shown over every tab so the tutor
/// can ask a question without first navigating to the chat list.
class AiFab extends StatelessWidget {
  const AiFab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Open the AI teaching assistant',
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: TLTokens.brandGradient,
          boxShadow: [
            BoxShadow(
              color: TLTokens.primary.withValues(alpha: 0.38),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AiThreadScreen()),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              size: 25,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
