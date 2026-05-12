import '../../domain/entities/ai_chat_message.dart';

class AiChatState {
  const AiChatState({
    this.messages = const <AiChatMessage>[],
    this.isSending = false,
    this.errorMessage,
    this.activeChatId = 'default',
    this.chatTitles = const <String, String>{'default': 'AI Assistant'},
    this.allChats = const <String, List<AiChatMessage>>{'default': <AiChatMessage>[]},
  });

  static const Object _sentinel = Object();

  final List<AiChatMessage> messages;
  final bool isSending;
  final String? errorMessage;
  final String activeChatId;
  final Map<String, String> chatTitles;
  final Map<String, List<AiChatMessage>> allChats;

  AiChatState copyWith({
    List<AiChatMessage>? messages,
    bool? isSending,
    Object? errorMessage = _sentinel,
    String? activeChatId,
    Map<String, String>? chatTitles,
    Map<String, List<AiChatMessage>>? allChats,
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
    );
  }
}
