import '../../../../core/network/api_exception.dart';

class AiChatReplyDto {
  const AiChatReplyDto({
    required this.text,
    required this.provider,
    required this.model,
    required this.latencyMs,
  });

  final String text;
  final String provider;
  final String model;
  final int latencyMs;

  factory AiChatReplyDto.fromJson(Map<String, dynamic> json) {
    final result = json['result'];
    if (result is! Map<String, dynamic>) {
      throw const ApiException(
        statusCode: 0,
        code: 'invalid_response',
        message: 'Unexpected response payload.',
      );
    }

    return AiChatReplyDto(
      text: '${result['text'] ?? ''}'.trim(),
      provider: '${result['provider'] ?? ''}',
      model: '${result['model'] ?? ''}',
      latencyMs: result['latencyMs'] as int? ?? 0,
    );
  }
}
