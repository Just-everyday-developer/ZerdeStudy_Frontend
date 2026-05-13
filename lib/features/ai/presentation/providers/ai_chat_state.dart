import '../../domain/entities/ai_chat_message.dart';

enum AiChatSortOrder {
  newestFirst,
  oldestFirst,
  alphabetical,
}

class AiChatState {
  const AiChatState({
    this.messages = const <AiChatMessage>[],
    this.isSending = false,
    this.errorMessage,
    this.activeChatId = 'default',
    this.chatTitles = const <String, String>{'default': 'AI Assistant'},
    this.allChats = const <String, List<AiChatMessage>>{'default': <AiChatMessage>[]},
    this.sortOrder = AiChatSortOrder.newestFirst,
  });

  static const Object _sentinel = Object();

  final List<AiChatMessage> messages;
  final bool isSending;
  final String? errorMessage;
  final String activeChatId;
  final Map<String, String> chatTitles;
  final Map<String, List<AiChatMessage>> allChats;
  final AiChatSortOrder sortOrder;

  List<String> get sortedChatIds {
    final keys = chatTitles.keys.toList();
    if (sortOrder == AiChatSortOrder.alphabetical) {
      keys.sort((a, b) {
        final titleA = chatTitles[a]?.toLowerCase() ?? '';
        final titleB = chatTitles[b]?.toLowerCase() ?? '';
        return titleA.compareTo(titleB);
      });
    } else if (sortOrder == AiChatSortOrder.oldestFirst) {
      keys.sort((a, b) {
        final timeA = _extractTimestamp(a);
        final timeB = _extractTimestamp(b);
        return timeA.compareTo(timeB);
      });
    } else {
      // newestFirst
      keys.sort((a, b) {
        final timeA = _extractTimestamp(a);
        final timeB = _extractTimestamp(b);
        return timeB.compareTo(timeA);
      });
    }
    return keys;
  }

  int _extractTimestamp(String chatId) {
    final parts = chatId.split('-');
    if (parts.length > 1) {
      final parsed = int.tryParse(parts[1]);
      if (parsed != null) return parsed;
    }
    // Fallback based on hashcode if it doesn't contain a timestamp
    return chatId.hashCode;
  }

  AiChatState copyWith({
    List<AiChatMessage>? messages,
    bool? isSending,
    Object? errorMessage = _sentinel,
    String? activeChatId,
    Map<String, String>? chatTitles,
    Map<String, List<AiChatMessage>>? allChats,
    AiChatSortOrder? sortOrder,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      activeChatId: activeChatId ?? this.activeChatId,
      chatTitles: chatTitles ?? this.chatTitles,
      allChats: allChats ?? this.allChats,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
