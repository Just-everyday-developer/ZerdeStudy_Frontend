import '../../../../core/network/api_exception.dart';
import '../../../../core/network/json_http_client.dart';
import '../models/ai_chat_reply_dto.dart';

class AiChatRemoteDataSource {
  static const llmApiKeyHeader = 'X-LLM-API-Key';
  static const _legacyMentorInstruction = '''
You are the ZerdeStudy AI mentor.
Help students with programming, computer science, IT topics, backend, mobile, data, and learning strategy.
Answer in the same language as the latest user message.
Use the provided app context when it is relevant.
Start directly with the answer or the first useful step.
Do not start with greetings, the user's name, or generic praise.
Be human, calm, practical, and easy to follow.
Explain things in simple language without losing technical accuracy.
If the question is practical, give concrete steps or a short checklist.
Prefer short paragraphs and short bullet lists when useful.
Use **bold** only for short emphasis and `code` for commands, code identifiers, or keywords when it improves clarity.
''';

  const AiChatRemoteDataSource(this._client, {this.authToken = ''});

  final JsonHttpClient _client;
  final String authToken;

  Future<AiChatReplyDto> sendMessage({
    required String conversation,
    required String appContext,
    String? userId,
    String? userApiKey,
  }) async {
    final metadata = <String, dynamic>{
      'source': 'frontend_flutter',
      if (userId != null && userId.trim().isNotEmpty) 'userId': userId.trim(),
    };

    final headers = <String, String>{
      if (authToken.trim().isNotEmpty)
        'Authorization': 'Bearer ${authToken.trim()}',
      if ((userApiKey ?? '').trim().isNotEmpty)
        llmApiKeyHeader: userApiKey!.trim(),
    };
    final requestBody = <String, dynamic>{
      'text': conversation,
      if (appContext.trim().isNotEmpty) 'context': appContext.trim(),
      if (metadata.isNotEmpty) 'metadata': metadata,
    };

    Map<String, dynamic> json;
    try {
      json = await _client.postJson(
        '/v1/messages',
        body: requestBody,
        headers: headers,
      );
    } on ApiException catch (error) {
      if (!_isLegacyContextMismatch(error)) {
        rethrow;
      }

      json = await _client.postJson(
        '/v1/messages',
        body: <String, dynamic>{
          'text': _buildLegacyPrompt(
            conversation: conversation,
            appContext: appContext,
          ),
          if (metadata.isNotEmpty) 'metadata': metadata,
        },
        headers: headers,
      );
    }

    return AiChatReplyDto.fromJson(json);
  }

  bool _isLegacyContextMismatch(ApiException error) {
    if (error.statusCode != 400) {
      return false;
    }

    final normalizedMessage = error.message.toLowerCase();
    return normalizedMessage.contains('unknown field') &&
        normalizedMessage.contains('context');
  }

  String _buildLegacyPrompt({
    required String conversation,
    required String appContext,
  }) {
    final trimmedConversation = _truncate(conversation.trim(), 1700);
    final trimmedContext = _truncate(appContext.trim(), 900);

    return '''
$_legacyMentorInstruction

App context:
$trimmedContext

Conversation transcript:
$trimmedConversation

Reply as the mentor to the latest user message.
'''
        .trim();
  }

  String _truncate(String value, int maxLength) {
    if (value.length <= maxLength) {
      return value;
    }
    return '${value.substring(0, maxLength - 3)}...';
  }
}
