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

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'author': author.name,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'isPending': isPending,
    };
  }

  factory AiChatMessage.fromJson(Map<String, dynamic> json) {
    return AiChatMessage(
      id: json['id'] as String? ?? '',
      author: AiChatAuthor.values.firstWhere(
        (value) => value.name == json['author'],
        orElse: () => AiChatAuthor.user,
      ),
      text: json['text'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      isPending: json['isPending'] as bool? ?? false,
    );
  }
}
