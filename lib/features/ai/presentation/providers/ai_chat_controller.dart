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
  static const _multichatStorageKey = 'zerdestudy_ai_multichat_history_v2';

  late final SharedPreferences _preferences;

  @override
  AiChatState build() {
    _preferences = ref.watch(sharedPreferencesProvider);
    return _restoreState();
  }

  void createNewChat([String? title]) {
    final chatId = 'chat-${DateTime.now().microsecondsSinceEpoch}';
    final chatTitle = title ?? 'Chat #${state.chatTitles.length + 1}';

    final updatedTitles = Map<String, String>.from(state.chatTitles)..[chatId] = chatTitle;
    final updatedChats = Map<String, List<AiChatMessage>>.from(state.allChats)..[chatId] = <AiChatMessage>[];

    state = state.copyWith(
      activeChatId: chatId,
      chatTitles: updatedTitles,
      allChats: updatedChats,
      messages: <AiChatMessage>[],
      errorMessage: null,
    );
    _persistState();
  }

  void selectChat(String chatId) {
    if (!state.allChats.containsKey(chatId)) {
      return;
    }
    state = state.copyWith(
      activeChatId: chatId,
      messages: state.allChats[chatId] ?? <AiChatMessage>[],
      errorMessage: null,
    );
    _persistState();
  }

  void deleteChat(String chatId) {
    final updatedTitles = Map<String, String>.from(state.chatTitles)..remove(chatId);
    final updatedChats = Map<String, List<AiChatMessage>>.from(state.allChats)..remove(chatId);

    if (updatedChats.isEmpty) {
      // Always keep at least one chat
      final newId = 'chat-${DateTime.now().microsecondsSinceEpoch}';
      updatedTitles[newId] = 'AI Assistant';
      updatedChats[newId] = <AiChatMessage>[];
    }

    String nextActiveId = state.activeChatId;
    if (chatId == state.activeChatId) {
      nextActiveId = updatedChats.keys.first;
    }

    state = state.copyWith(
      activeChatId: nextActiveId,
      chatTitles: updatedTitles,
      allChats: updatedChats,
      messages: updatedChats[nextActiveId] ?? <AiChatMessage>[],
      errorMessage: null,
    );
    _persistState();
  }

  void renameChat(String chatId, String newTitle) {
    if (newTitle.trim().isEmpty) return;
    final updatedTitles = Map<String, String>.from(state.chatTitles)..[chatId] = newTitle.trim();
    state = state.copyWith(
      chatTitles: updatedTitles,
    );
    _persistState();
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

    final updatedMessages = <AiChatMessage>[...previousMessages, userMessage, pendingReply];
    final updatedChats = Map<String, List<AiChatMessage>>.from(state.allChats)..[state.activeChatId] = updatedMessages;

    // Auto-rename chat if it is the default title and this is the first message
    var updatedTitles = Map<String, String>.from(state.chatTitles);
    if (previousMessages.isEmpty &&
        (updatedTitles[state.activeChatId] == 'AI Assistant' ||
            updatedTitles[state.activeChatId]?.startsWith('Chat #') == true)) {
      final summary = message.length > 24 ? '${message.substring(0, 24)}...' : message;
      updatedTitles[state.activeChatId] = summary;
    }

    state = state.copyWith(
      messages: updatedMessages,
      allChats: updatedChats,
      chatTitles: updatedTitles,
      isSending: true,
      errorMessage: null,
    );
    _persistState();

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

      final finalMessages = _replacePendingMessage(
        pendingMessageId: pendingReply.id,
        replyText: reply.text,
      );
      final finalChats = Map<String, List<AiChatMessage>>.from(state.allChats)..[state.activeChatId] = finalMessages;

      state = state.copyWith(
        messages: finalMessages,
        allChats: finalChats,
        isSending: false,
        errorMessage: null,
      );
      _persistState();
      return null;
    } on ApiException catch (error) {
      final finalMessages = _removeMessageById(pendingReply.id);
      final finalChats = Map<String, List<AiChatMessage>>.from(state.allChats)..[state.activeChatId] = finalMessages;
      state = state.copyWith(
        messages: finalMessages,
        allChats: finalChats,
        isSending: false,
        errorMessage: error.message,
      );
      _persistState();
      return error.message;
    } catch (_) {
      const errorMsg = 'Unable to get an AI response right now.';
      final finalMessages = _removeMessageById(pendingReply.id);
      final finalChats = Map<String, List<AiChatMessage>>.from(state.allChats)..[state.activeChatId] = finalMessages;
      state = state.copyWith(
        messages: finalMessages,
        allChats: finalChats,
        isSending: false,
        errorMessage: errorMsg,
      );
      _persistState();
      return errorMsg;
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

  AiChatState _restoreState() {
    // 1. Try restoring multi-chat history (v2)
    final rawMultichat = _preferences.getString(_multichatStorageKey);
    if (rawMultichat != null && rawMultichat.trim().isNotEmpty) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(rawMultichat);
        final activeChatId = decoded['activeChatId'] as String? ?? 'default';
        final rawTitles = decoded['chatTitles'] as Map<String, dynamic>? ?? {};
        final rawChats = decoded['allChats'] as Map<String, dynamic>? ?? {};

        final chatTitles = <String, String>{};
        rawTitles.forEach((key, value) {
          chatTitles[key] = value.toString();
        });

        final allChats = <String, List<AiChatMessage>>{};
        rawChats.forEach((key, value) {
          if (value is List) {
            allChats[key] = value
                .whereType<Map>()
                .map((msg) => AiChatMessage.fromJson(Map<String, dynamic>.from(msg)))
                .where((msg) => !msg.isPending)
                .toList();
          }
        });

        if (chatTitles.isEmpty || allChats.isEmpty) {
          throw Exception('Empty database loaded');
        }

        return AiChatState(
          activeChatId: activeChatId,
          chatTitles: chatTitles,
          allChats: allChats,
          messages: allChats[activeChatId] ?? <AiChatMessage>[],
        );
      } catch (_) {
        // Fall through to v1 restore or default
      }
    }

    // 2. Try restoring old single chat history (v1) and convert to v2
    final rawV1 = _preferences.getString(_storageKey);
    if (rawV1 != null && rawV1.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(rawV1);
        if (decoded is List) {
          final messages = decoded
              .whereType<Map>()
              .map((message) => AiChatMessage.fromJson(Map<String, dynamic>.from(message)))
              .where((message) => !message.isPending)
              .toList();

          return AiChatState(
            activeChatId: 'default',
            chatTitles: const <String, String>{'default': 'AI Assistant'},
            allChats: <String, List<AiChatMessage>>{'default': messages},
            messages: messages,
          );
        }
      } catch (_) {
        // Fall through to default
      }
    }

    // 3. Fallback to default empty chat
    return const AiChatState();
  }

  void _persistState() {
    final Map<String, dynamic> serializedChats = {};
    state.allChats.forEach((chatId, list) {
      final persistedMessages = list
          .where((message) => !message.isPending)
          .map((message) => message.toJson())
          .toList();
      serializedChats[chatId] = persistedMessages;
    });

    final payload = jsonEncode({
      'activeChatId': state.activeChatId,
      'chatTitles': state.chatTitles,
      'allChats': serializedChats,
    });
    unawaited(_preferences.setString(_multichatStorageKey, payload));
  }
}
