import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/state/demo_app_controller.dart';
import '../../../../core/config/app_environment.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/json_http_client.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../data/datasources/ai_chat_remote_data_source.dart';
import '../../domain/entities/ai_chat_message.dart';
import 'ai_app_context_provider.dart';
import 'ai_chat_state.dart';
import 'ai_user_api_key_controller.dart';

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
  static const _storageKey = 'zerdestudy_ai_chat_history_v1';

  late final SharedPreferences _preferences;

  @override
  AiChatState build() {
    _preferences = ref.watch(sharedPreferencesProvider);
    return AiChatState(messages: _restoreMessages());
  }

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
    _persistMessages(state.messages);

    try {
      final authUser = ref.read(authControllerProvider).user;
      final appContext = ref.read(aiAppContextProvider);
      final userApiKey = ref.read(aiUserApiKeyProvider);
      final reply = await ref
          .read(aiChatRemoteDataSourceProvider)
          .sendMessage(
            conversation: _buildConversationTranscript(
              previousMessages,
              message,
            ),
            appContext: appContext,
            userId: authUser?.id,
            userApiKey: userApiKey,
          );

      ref
          .read(demoAppControllerProvider.notifier)
          .recordAiExchange(
            userMessage: message,
            mentorMessage: reply.text,
            xpDelta: 2,
          );

      state = state.copyWith(
        messages: _replacePendingMessage(
          pendingMessageId: pendingReply.id,
          replyText: reply.text,
        ),
        isSending: false,
        errorMessage: null,
      );
      _persistMessages(state.messages);
      return null;
    } on ApiException catch (error) {
      state = state.copyWith(
        messages: _removeMessageById(pendingReply.id),
        isSending: false,
        errorMessage: error.message,
      );
      _persistMessages(state.messages);
      return error.message;
    } catch (_) {
      const message = 'Unable to get an AI response right now.';
      state = state.copyWith(
        messages: _removeMessageById(pendingReply.id),
        isSending: false,
        errorMessage: message,
      );
      _persistMessages(state.messages);
      return message;
    }
  }

  String _buildConversationTranscript(
    List<AiChatMessage> history,
    String latestMessage,
  ) {
    final transcript = <String>[
      for (final message in history.where((item) => !item.isPending))
        '${_roleLabel(message.author)}: ${message.text.trim()}',
      'User: $latestMessage',
    ];

    while (transcript.length > 2 && transcript.join('\n').length > 2200) {
      transcript.removeAt(0);
    }

    return transcript.join('\n').trim();
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

  List<AiChatMessage> _restoreMessages() {
    final raw = _preferences.getString(_storageKey);
    if (raw == null || raw.trim().isEmpty) {
      return const <AiChatMessage>[];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const <AiChatMessage>[];
      }

      return decoded
          .whereType<Map>()
          .map(
            (message) =>
                AiChatMessage.fromJson(Map<String, dynamic>.from(message)),
          )
          .where((message) => !message.isPending)
          .toList(growable: false);
    } catch (_) {
      return const <AiChatMessage>[];
    }
  }

  void _persistMessages(List<AiChatMessage> messages) {
    final persistedMessages = messages
        .where((message) => !message.isPending)
        .toList(growable: false);
    final payload = jsonEncode(
      persistedMessages.map((message) => message.toJson()).toList(),
    );
    unawaited(_preferences.setString(_storageKey, payload));
  }
}
