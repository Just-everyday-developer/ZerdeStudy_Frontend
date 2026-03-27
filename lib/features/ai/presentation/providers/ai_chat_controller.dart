import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../../core/config/app_environment.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/json_http_client.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../data/datasources/ai_chat_remote_data_source.dart';
import '../../domain/entities/ai_chat_message.dart';
import 'ai_chat_state.dart';

final aiHttpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final aiJsonHttpClientProvider = Provider<JsonHttpClient>((ref) {
  final client = ref.watch(aiHttpClientProvider);
  final environment = ref.watch(appEnvironmentProvider);
  return JsonHttpClient(
    client: client,
    uriResolver: environment.resolveAiService,
  );
});

final aiChatRemoteDataSourceProvider = Provider<AiChatRemoteDataSource>((ref) {
  final client = ref.watch(aiJsonHttpClientProvider);
  final environment = ref.watch(appEnvironmentProvider);
  return AiChatRemoteDataSource(
    client,
    authToken: environment.aiServiceAuthToken,
  );
});

final aiChatControllerProvider =
    NotifierProvider<AiChatController, AiChatState>(AiChatController.new);

class AiChatController extends Notifier<AiChatState> {
  static const _mentorInstruction = '''
You are the ZerdeStudy AI mentor.
Help students with programming, computer science, IT topics, backend, mobile, data, and learning strategy.
Answer in the same language as the latest user message.
Be clear, supportive, and practical.
Prefer short paragraphs and short bullet lists when useful.
If the question is ambiguous, make the most reasonable assumption and explain it briefly.
''';

  @override
  AiChatState build() => const AiChatState();

  Future<String?> sendMessage(String rawMessage) async {
    final message = rawMessage.trim();
    if (message.isEmpty || state.isSending) {
      return null;
    }

    final previousMessages = state.messages;
    final now = DateTime.now();
    final userMessage = AiChatMessage(
      id: 'user-${now.microsecondsSinceEpoch}',
      author: AiChatAuthor.user,
      text: message,
      createdAt: now,
    );
    final pendingReply = AiChatMessage(
      id: 'mentor-${now.microsecondsSinceEpoch}',
      author: AiChatAuthor.mentor,
      text: '',
      createdAt: now.add(const Duration(milliseconds: 1)),
      isPending: true,
    );

    state = state.copyWith(
      messages: <AiChatMessage>[...previousMessages, userMessage, pendingReply],
      isSending: true,
      errorMessage: null,
    );

    try {
      final authUser = ref.read(authControllerProvider).user;
      final reply = await ref
          .read(aiChatRemoteDataSourceProvider)
          .sendMessage(
            prompt: _buildPrompt(previousMessages, message),
            userId: authUser?.id,
          );

      state = state.copyWith(
        messages: _replacePendingMessage(
          pendingMessageId: pendingReply.id,
          replyText: reply.text,
        ),
        isSending: false,
        errorMessage: null,
      );
      return null;
    } on ApiException catch (error) {
      state = state.copyWith(
        messages: _removeMessageById(pendingReply.id),
        isSending: false,
        errorMessage: error.message,
      );
      return error.message;
    } catch (_) {
      const message = 'Unable to get an AI response right now.';
      state = state.copyWith(
        messages: _removeMessageById(pendingReply.id),
        isSending: false,
        errorMessage: message,
      );
      return message;
    }
  }

  String _buildPrompt(List<AiChatMessage> history, String latestMessage) {
    final transcript = <String>[
      for (final message in history.where((item) => !item.isPending))
        '${_roleLabel(message.author)}: ${message.text.trim()}',
      'User: $latestMessage',
    ];

    while (transcript.length > 2 &&
        _mentorInstruction.length + transcript.join('\n').length > 3600) {
      transcript.removeAt(0);
    }

    return '''
$_mentorInstruction

Conversation:
${transcript.join('\n')}

Mentor:
'''
        .trim();
  }

  String _roleLabel(AiChatAuthor author) {
    return switch (author) {
      AiChatAuthor.user => 'User',
      AiChatAuthor.mentor => 'Mentor',
    };
  }

  List<AiChatMessage> _replacePendingMessage({
    required String pendingMessageId,
    required String replyText,
  }) {
    return [
      for (final message in state.messages)
        if (message.id == pendingMessageId)
          message.copyWith(text: replyText.trim(), isPending: false)
        else
          message,
    ];
  }

  List<AiChatMessage> _removeMessageById(String id) {
    return state.messages
        .where((message) => message.id != id)
        .toList(growable: false);
  }
}
