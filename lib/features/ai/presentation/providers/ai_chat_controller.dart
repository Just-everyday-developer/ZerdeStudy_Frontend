import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

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

// Safe & standard UUID v4 Generator without external dependencies
String generateUuidV4() {
  final random = math.Random.secure();
  final hex = List<String>.generate(32, (i) {
    if (i == 12) return '4';
    if (i == 16) return (random.nextInt(4) + 8).toRadixString(16);
    return random.nextInt(16).toRadixString(16);
  });
  return '${hex.sublist(0, 8).join()}-${hex.sublist(8, 12).join()}-${hex.sublist(12, 16).join()}-${hex.sublist(16, 20).join()}-${hex.sublist(20, 32).join()}';
}

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
    // Queue asynchronous background sync to backend
    Future.microtask(_syncWithBackend);
    return _restoreState();
  }

  // Trigger background sync to load user's real chats stored in Postgres
  Future<void> _syncWithBackend() async {
    final authUser = ref.read(authControllerProvider).user;
    if (authUser == null) return;

    try {
      final remoteChats = await ref.read(aiChatRemoteDataSourceProvider).fetchChats(authUser.id);
      if (remoteChats.isEmpty) {
        // Safe check: If no chats exist on backend but we have active local history, upload it
        if (state.messages.isNotEmpty) {
          final title = state.chatTitles[state.activeChatId] ?? 'AI Assistant';
          await ref.read(aiChatRemoteDataSourceProvider).createChat(
            authUser.id,
            state.activeChatId,
            title: title,
          );
        }
        return;
      }

      final chatTitles = <String, String>{};
      final allChats = <String, List<AiChatMessage>>{};

      for (final rc in remoteChats) {
        final id = rc['chatId'] as String;
        final title = rc['title'] as String? ?? 'AI Assistant';
        chatTitles[id] = title;
        allChats[id] = <AiChatMessage>[]; // Loaded on demand/select or merged
      }

      String activeId = state.activeChatId;
      if (!chatTitles.containsKey(activeId)) {
        activeId = chatTitles.keys.first;
      }

      // Pre-load messages of active chat
      final remoteMsgs = await ref.read(aiChatRemoteDataSourceProvider).fetchChatMessages(activeId);
      final messages = remoteMsgs.map((m) {
        final role = m['role'] as String;
        return AiChatMessage(
          id: m['messageId'] as String,
          author: role == 'user' ? AiChatAuthor.user : AiChatAuthor.mentor,
          text: m['content'] as String? ?? '',
          createdAt: DateTime.tryParse(m['createdAt'] as String? ?? '') ?? DateTime.now(),
        );
      }).toList();

      allChats[activeId] = messages;

      state = state.copyWith(
        activeChatId: activeId,
        chatTitles: chatTitles,
        allChats: allChats,
        messages: messages,
      );

      _persistState();
    } catch (_) {
      // Graceful degradation: Fail silently and fallback to local cache
    }
  }

  void changeSortOrder(AiChatSortOrder newOrder) {
    state = state.copyWith(sortOrder: newOrder);
    _persistState();
  }

  void createNewChat([String? title]) async {
    final finalChatId = generateUuidV4();

    final chatTitle = title ?? 'Chat #${state.chatTitles.length + 1}';

    final updatedTitles = Map<String, String>.from(state.chatTitles)..[finalChatId] = chatTitle;
    final updatedChats = Map<String, List<AiChatMessage>>.from(state.allChats)..[finalChatId] = <AiChatMessage>[];

    state = state.copyWith(
      activeChatId: finalChatId,
      chatTitles: updatedTitles,
      allChats: updatedChats,
      messages: <AiChatMessage>[],
      errorMessage: null,
    );
    _persistState();

    final authUser = ref.read(authControllerProvider).user;
    if (authUser != null) {
      try {
        await ref.read(aiChatRemoteDataSourceProvider).createChat(
          authUser.id,
          finalChatId,
          title: chatTitle,
        );
      } catch (_) {}
    }
  }

  void selectChat(String chatId) async {
    if (!state.allChats.containsKey(chatId)) {
      return;
    }
    state = state.copyWith(
      activeChatId: chatId,
      messages: state.allChats[chatId] ?? <AiChatMessage>[],
      errorMessage: null,
    );
    _persistState();

    final authUser = ref.read(authControllerProvider).user;
    if (authUser != null) {
      try {
        final remoteMsgs = await ref.read(aiChatRemoteDataSourceProvider).fetchChatMessages(chatId);
        final messages = remoteMsgs.map((m) {
          final role = m['role'] as String;
          return AiChatMessage(
            id: m['messageId'] as String,
            author: role == 'user' ? AiChatAuthor.user : AiChatAuthor.mentor,
            text: m['content'] as String? ?? '',
            createdAt: DateTime.tryParse(m['createdAt'] as String? ?? '') ?? DateTime.now(),
          );
        }).toList();

        final updatedChats = Map<String, List<AiChatMessage>>.from(state.allChats)..[chatId] = messages;

        if (state.activeChatId == chatId) {
          state = state.copyWith(
            messages: messages,
            allChats: updatedChats,
          );
          _persistState();
        }
      } catch (_) {}
    }
  }

  void deleteChat(String chatId) async {
    final updatedTitles = Map<String, String>.from(state.chatTitles)..remove(chatId);
    final updatedChats = Map<String, List<AiChatMessage>>.from(state.allChats)..remove(chatId);

    if (updatedChats.isEmpty) {
      final newId = generateUuidV4();
      updatedTitles[newId] = 'AI Assistant';
      updatedChats[newId] = <AiChatMessage>[];

      final authUser = ref.read(authControllerProvider).user;
      if (authUser != null) {
        try {
          await ref.read(aiChatRemoteDataSourceProvider).createChat(
            authUser.id,
            newId,
            title: 'AI Assistant',
          );
        } catch (_) {}
      }
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

    // Load active chat messages from remote
    selectChat(nextActiveId);

    final authUser = ref.read(authControllerProvider).user;
    if (authUser != null) {
      try {
        await ref.read(aiChatRemoteDataSourceProvider).deleteChat(chatId);
      } catch (_) {}
    }
  }

  void renameChat(String chatId, String newTitle) async {
    if (newTitle.trim().isEmpty) return;
    final updatedTitles = Map<String, String>.from(state.chatTitles)..[chatId] = newTitle.trim();
    state = state.copyWith(
      chatTitles: updatedTitles,
    );
    _persistState();

    final authUser = ref.read(authControllerProvider).user;
    if (authUser != null) {
      try {
        await ref.read(aiChatRemoteDataSourceProvider).renameChat(chatId, newTitle.trim());
      } catch (_) {}
    }
  }

  Future<String?> sendMessage(String rawMessage) async {
    final message = rawMessage.trim();
    if (message.isEmpty || state.isSending) {
      return null;
    }

    final previousMessages = state.messages;
    final now = DateTime.now();
    final userMessage = AiChatMessage(
      id: generateUuidV4(),
      author: AiChatAuthor.user,
      text: message,
      createdAt: now,
    );
    final pendingReply = AiChatMessage(
      id: 'pending-${generateUuidV4()}',
      author: AiChatAuthor.mentor,
      text: '',
      createdAt: now.add(const Duration(milliseconds: 1)),
      isPending: true,
    );

    final updatedMessages = <AiChatMessage>[...previousMessages, userMessage, pendingReply];
    final updatedChats = Map<String, List<AiChatMessage>>.from(state.allChats)..[state.activeChatId] = updatedMessages;

    var updatedTitles = Map<String, String>.from(state.chatTitles);
    if (previousMessages.isEmpty &&
        (updatedTitles[state.activeChatId] == 'AI Assistant' ||
            updatedTitles[state.activeChatId]?.startsWith('Chat #') == true)) {
      final summary = message.length > 24 ? '${message.substring(0, 24)}...' : message;
      updatedTitles[state.activeChatId] = summary;
      renameChat(state.activeChatId, summary);
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
            chatId: state.activeChatId,
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

        final sortOrderName = decoded['sortOrder'] as String?;
        final sortOrder = AiChatSortOrder.values.firstWhere(
          (e) => e.name == sortOrderName,
          orElse: () => AiChatSortOrder.newestFirst,
        );

        if (chatTitles.isEmpty || allChats.isEmpty) {
          throw Exception('Empty database loaded');
        }

        return AiChatState(
          activeChatId: activeChatId,
          chatTitles: chatTitles,
          allChats: allChats,
          messages: allChats[activeChatId] ?? <AiChatMessage>[],
          sortOrder: sortOrder,
        );
      } catch (_) {}
    }

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
      } catch (_) {}
    }

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
      'sortOrder': state.sortOrder.name,
    });
    unawaited(_preferences.setString(_multichatStorageKey, payload));
  }
}
