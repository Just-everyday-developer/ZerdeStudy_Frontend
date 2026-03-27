import '../../../../core/network/json_http_client.dart';
import '../models/ai_chat_reply_dto.dart';

class AiChatRemoteDataSource {
  const AiChatRemoteDataSource(this._client, {this.authToken = ''});

  final JsonHttpClient _client;
  final String authToken;

  Future<AiChatReplyDto> sendMessage({
    required String prompt,
    String? userId,
  }) async {
    final metadata = <String, dynamic>{
      'source': 'frontend_flutter',
      if (userId != null && userId.trim().isNotEmpty) 'userId': userId.trim(),
    };

    final json = await _client.postJson(
      '/v1/messages',
      body: <String, dynamic>{
        'text': prompt,
        if (metadata.isNotEmpty) 'metadata': metadata,
      },
      headers: <String, String>{
        if (authToken.trim().isNotEmpty)
          'Authorization': 'Bearer ${authToken.trim()}',
      },
    );

    return AiChatReplyDto.fromJson(json);
  }
}
