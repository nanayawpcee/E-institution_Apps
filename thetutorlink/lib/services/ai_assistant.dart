import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'claude_client.dart';

/// One message in the assistant thread.
@immutable
class AiMessage {
  const AiMessage({
    required this.text,
    required this.fromMe,
    required this.time,
  });

  final String text;

  /// True for the signed-in user's own messages.
  final bool fromMe;
  final DateTime time;
}

@immutable
class AiAssistantState {
  const AiAssistantState({this.messages = const [], this.loading = false});

  final List<AiMessage> messages;

  /// A reply is in flight; the thread shows its "Thinking…" placeholder.
  final bool loading;

  AiMessage? get last => messages.isEmpty ? null : messages.last;

  AiAssistantState copyWith({List<AiMessage>? messages, bool? loading}) {
    return AiAssistantState(
      messages: messages ?? this.messages,
      loading: loading ?? this.loading,
    );
  }
}

/// Drives the assistant conversation.
///
/// The whole thread is replayed on every turn — the Messages API is stateless,
/// so prior turns are how the model keeps context.
class AiAssistantNotifier extends StateNotifier<AiAssistantState> {
  AiAssistantNotifier({required this.systemPrompt, ClaudeClient? client})
      : _client = client ?? ClaudeClient(),
        super(const AiAssistantState());

  final String systemPrompt;
  final ClaudeClient _client;

  /// Whether the feature is available in this build at all.
  bool get isAvailable => AiConfig.isConfigured;

  Future<void> send(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty || state.loading) return;

    final userMessage =
        AiMessage(text: text, fromMe: true, time: DateTime.now());
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      loading: true,
    );

    try {
      final reply = await _client.complete(
        system: systemPrompt,
        history: [
          for (final m in state.messages)
            AiTurn(role: m.fromMe ? 'user' : 'assistant', text: m.text),
        ],
      );
      _appendAssistant(reply);
    } on AiException catch (e) {
      _appendAssistant(
        e.retryable
            ? "Sorry, I couldn't respond just now. Please try again in a moment."
            : e.message,
      );
    } catch (_) {
      _appendAssistant(
        "Sorry, I couldn't respond just now. Please try again in a moment.",
      );
    }
  }

  void clear() => state = const AiAssistantState();

  void _appendAssistant(String text) {
    if (!mounted) return;
    state = state.copyWith(
      messages: [
        ...state.messages,
        AiMessage(text: text, fromMe: false, time: DateTime.now()),
      ],
      loading: false,
    );
  }

  @override
  void dispose() {
    _client.dispose();
    super.dispose();
  }
}

/// System prompt for the tutor-facing assistant, from the design doc.
const String kTutorAssistantPrompt =
    'You are an AI teaching assistant inside a tutoring app called TutorLink, '
    'helping a tutor (not a student). Help with lesson planning, explaining '
    'concepts simply, grading guidance, and structuring sessions. Be warm, '
    'concise and practical. Keep answers under 90 words, plain text, no '
    'markdown.';

final aiAssistantProvider =
    StateNotifierProvider<AiAssistantNotifier, AiAssistantState>((ref) {
  return AiAssistantNotifier(systemPrompt: kTutorAssistantPrompt);
});
