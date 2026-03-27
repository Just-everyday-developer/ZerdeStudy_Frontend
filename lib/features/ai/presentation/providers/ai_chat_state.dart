import '../../domain/entities/ai_chat_message.dart';

class AiChatState {
  const AiChatState({
    this.messages = const <AiChatMessage>[],
    this.isSending = false,
    this.errorMessage,
  });

  static const Object _sentinel = Object();

  final List<AiChatMessage> messages;
  final bool isSending;
  final String? errorMessage;

  AiChatState copyWith({
    List<AiChatMessage>? messages,
    bool? isSending,
    Object? errorMessage = _sentinel,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}
