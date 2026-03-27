enum AiChatAuthor { user, mentor }

class AiChatMessage {
  const AiChatMessage({
    required this.id,
    required this.author,
    required this.text,
    required this.createdAt,
    this.isPending = false,
  });

  final String id;
  final AiChatAuthor author;
  final String text;
  final DateTime createdAt;
  final bool isPending;

  AiChatMessage copyWith({
    String? id,
    AiChatAuthor? author,
    String? text,
    DateTime? createdAt,
    bool? isPending,
  }) {
    return AiChatMessage(
      id: id ?? this.id,
      author: author ?? this.author,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      isPending: isPending ?? this.isPending,
    );
  }
}
