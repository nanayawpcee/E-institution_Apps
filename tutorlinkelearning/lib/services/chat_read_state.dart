import 'package:flutter_riverpod/flutter_riverpod.dart';

/// When each conversation was last opened, keyed by chat key.
///
/// Held in memory alongside the conversations themselves — neither survives a
/// restart, so a fresh launch shows every incoming message as unread.
class ChatReadNotifier extends StateNotifier<Map<String, DateTime>> {
  ChatReadNotifier() : super(const {});

  /// Called when a thread is opened, which is what clears its badge.
  void markRead(String chatKey) {
    state = {...state, chatKey: DateTime.now()};
  }

  /// True when [messages] holds anything from someone other than [myId] that
  /// arrived after the thread was last opened. A thread that has never been
  /// opened counts as unread as soon as it has an incoming message.
  bool isUnread(
    String chatKey,
    Iterable<dynamic> messages, {
    required String myId,
  }) {
    final lastOpened = state[chatKey];
    for (final message in messages) {
      if (message.senderId == myId) continue;
      if (lastOpened == null || message.time.isAfter(lastOpened)) return true;
    }
    return false;
  }
}

final chatReadProvider =
    StateNotifierProvider<ChatReadNotifier, Map<String, DateTime>>(
        (ref) => ChatReadNotifier());
