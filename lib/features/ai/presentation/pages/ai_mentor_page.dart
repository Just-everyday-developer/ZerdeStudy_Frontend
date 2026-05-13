import 'dart:math' as math;

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/state/app_locale.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../core/common_widgets/app_notice.dart';
import '../../../../core/common_widgets/app_page_scaffold.dart';
import '../../../../core/common_widgets/glow_card.dart';
import '../../../../core/common_widgets/inline_markdown_text.dart';
import '../../../../core/layout/app_breakpoints.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../app_guide/presentation/app_guide_controller.dart';
import '../../../app_guide/presentation/app_guide_target.dart';
import '../../domain/entities/ai_chat_message.dart';
import '../providers/ai_chat_controller.dart';
import '../providers/ai_chat_state.dart';
import '../providers/ai_user_api_key_controller.dart';

class AiMentorPage extends ConsumerStatefulWidget {
  const AiMentorPage({super.key});

  @override
  ConsumerState<AiMentorPage> createState() => _AiMentorPageState();
}

class _AiMentorPageState extends ConsumerState<AiMentorPage> {
  late final TextEditingController _controller;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _submitMessage(
    String rawMessage, {
    bool clearComposer = false,
  }) async {
    final message = rawMessage.trim();
    if (message.isEmpty) {
      return;
    }

    if (clearComposer) {
      _controller.clear();
    }

    await ref.read(aiChatControllerProvider.notifier).sendMessage(message);
  }

  Future<void> _send() {
    return _submitMessage(_controller.text, clearComposer: true);
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  bool _isTextFieldFocused() {
    final primary = FocusManager.instance.primaryFocus;
    if (primary == null || primary.context == null) return false;
    bool found = false;
    primary.context!.visitAncestorElements((element) {
      if (element.widget is EditableText || element.widget is TextField) {
        found = true;
        return false;
      }
      return true;
    });
    return found || primary.context!.widget is EditableText || primary.context!.widget is TextField;
  }

  void _showRenameDialog(BuildContext context, String chatId, String currentTitle) {
    final controller = TextEditingController(text: currentTitle);
    final colors = context.appColors;
    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Rename Chat'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Chat Title',
            ),
            autofocus: true,
            onSubmitted: (val) {
              if (val.trim().isNotEmpty) {
                ref.read(aiChatControllerProvider.notifier).renameChat(chatId, val.trim());
                Navigator.pop(dialogCtx);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text('Cancel', style: TextStyle(color: colors.textSecondary)),
            ),
            FilledButton(
              onPressed: () {
                ref.read(aiChatControllerProvider.notifier).renameChat(chatId, controller.text);
                Navigator.pop(dialogCtx);
              },
              style: FilledButton.styleFrom(backgroundColor: colors.primary),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDeleteChat(BuildContext context, String chatId) async {
    final colors = context.appColors;
    final l10n = context.l10n;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
            Navigator.pop(ctx, true);
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: AlertDialog(
          title: Text(l10n.locale == AppLocale.ru ? 'Удалить чат?' : (l10n.locale == AppLocale.kk ? 'Чатты өшіру?' : 'Delete Chat?')),
          content: Text(l10n.locale == AppLocale.ru ? 'Вы уверены, что хотите удалить этот чат? Это действие нельзя отменить.' : (l10n.locale == AppLocale.kk ? 'Бұл чатты өшіргіңіз келетініне сенімдісіз бе? Бұл әрекетті қайтару мүмкін емес.' : 'Are you sure you want to delete this chat? This action cannot be undone.')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.text('cancel'), style: TextStyle(color: colors.textSecondary)),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(backgroundColor: colors.danger),
              child: Text(l10n.locale == AppLocale.ru ? 'Удалить' : (l10n.locale == AppLocale.kk ? 'Өшіру' : 'Delete')),
            ),
          ],
        ),
      ),
    );
    if (confirm == true) {
      ref.read(aiChatControllerProvider.notifier).deleteChat(chatId);
    }
  }

  void _showChatSwitcherBottomSheet(
    BuildContext context,
    AiChatState chatState,
    AppThemeColors colors,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.backgroundElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'AI Conversations',
                        style: Theme.of(sheetCtx).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      IconButton(
                        onPressed: () {
                          ref.read(aiChatControllerProvider.notifier).createNewChat();
                          Navigator.pop(sheetCtx);
                        },
                        icon: Icon(Icons.add_circle_outline_rounded, color: colors.primary, size: 28),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: chatState.sortedChatIds.map((chatId) {
                      final title = chatState.chatTitles[chatId] ?? '';
                      final isSelected = chatId == chatState.activeChatId;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: InkWell(
                          onTap: () {
                            ref.read(aiChatControllerProvider.notifier).selectChat(chatId);
                            Navigator.pop(sheetCtx);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected ? colors.primary.withValues(alpha: 0.12) : colors.surfaceSoft,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? colors.primary.withValues(alpha: 0.3) : colors.divider,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  color: isSelected ? colors.primary : colors.textSecondary,
                                  size: 18,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? colors.textPrimary : colors.textSecondary,
                                    ),
                                  ),
                                ),
                                if (isSelected) ...[
                                  IconButton(
                                    icon: Icon(Icons.edit_outlined, size: 18, color: colors.textSecondary),
                                    onPressed: () {
                                      Navigator.pop(sheetCtx);
                                      _showRenameDialog(context, chatId, title);
                                    },
                                    constraints: const BoxConstraints(),
                                    padding: EdgeInsets.zero,
                                  ),
                                  const SizedBox(width: 12),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                                    onPressed: () {
                                      ref.read(aiChatControllerProvider.notifier).deleteChat(chatId);
                                      Navigator.pop(sheetCtx);
                                    },
                                    constraints: const BoxConstraints(),
                                    padding: EdgeInsets.zero,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSidebar(BuildContext context, AppThemeColors colors, AiChatState chatState) {
    final locale = ref.watch(
      demoAppControllerProvider.select((state) => state.locale),
    );

    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: colors.backgroundElevated.withValues(alpha: 0.6),
        border: Border(right: BorderSide(color: colors.divider)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: ElevatedButton.icon(
              onPressed: () {
                ref.read(aiChatControllerProvider.notifier).createNewChat();
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'New Chat',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    locale == AppLocale.ru 
                        ? 'Сортировка:' 
                        : locale == AppLocale.kk 
                            ? 'Сұрыптау:' 
                            : 'Sorting:',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<AiChatSortOrder>(
                      value: chatState.sortOrder,
                      dropdownColor: colors.backgroundElevated,
                      icon: Icon(Icons.sort_rounded, size: 14, color: colors.primary),
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                      onChanged: (order) {
                        if (order != null) {
                          ref.read(aiChatControllerProvider.notifier).changeSortOrder(order);
                        }
                      },
                      items: [
                        DropdownMenuItem(
                          value: AiChatSortOrder.newestFirst,
                          child: Text(
                            locale == AppLocale.ru 
                                ? 'Сначала новые' 
                                : locale == AppLocale.kk 
                                    ? 'Алдымен жаңа' 
                                    : 'Newest first',
                          ),
                        ),
                        DropdownMenuItem(
                          value: AiChatSortOrder.oldestFirst,
                          child: Text(
                            locale == AppLocale.ru 
                                ? 'Сначала старые' 
                                : locale == AppLocale.kk 
                                    ? 'Алдымен ескі' 
                                    : 'Oldest first',
                          ),
                        ),
                        DropdownMenuItem(
                          value: AiChatSortOrder.alphabetical,
                          child: Text(
                            locale == AppLocale.ru 
                                ? 'По алфавиту' 
                                : locale == AppLocale.kk 
                                    ? 'Әліпби бойынша' 
                                    : 'Alphabetical',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(color: colors.divider, height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: chatState.sortedChatIds.map((chatId) {
                final title = chatState.chatTitles[chatId] ?? '';
                final isSelected = chatId == chatState.activeChatId;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: InkWell(
                    onTap: () {
                      ref.read(aiChatControllerProvider.notifier).selectChat(chatId);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? colors.primary.withValues(alpha: 0.12) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? colors.primary.withValues(alpha: 0.24) : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 16,
                            color: isSelected ? colors.primary : colors.textSecondary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isSelected ? colors.textPrimary : colors.textSecondary,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          if (isSelected) ...[
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 14),
                              onPressed: () => _showRenameDialog(context, chatId, title),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              color: colors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 14),
                              onPressed: () {
                                ref.read(aiChatControllerProvider.notifier).deleteChat(chatId);
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              color: colors.danger,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatPane(
    BuildContext context,
    AppThemeColors colors,
    AiChatState chatState,
    bool compact,
    String? userApiKey,
    AppLocale locale,
  ) {
    return Column(
      children: [
        if (compact) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colors.backgroundElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.divider),
              ),
              child: Row(
                children: [
                  Icon(Icons.chat_bubble_outline_rounded, color: colors.primary, size: 16),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      chatState.chatTitles[chatState.activeChatId] ?? 'AI Assistant',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  InkWell(
                    onTap: () => _showChatSwitcherBottomSheet(context, chatState, colors),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Chats', style: TextStyle(color: colors.primary, fontSize: 13, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 2),
                          Icon(Icons.arrow_drop_down_rounded, color: colors.primary),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        Expanded(
          child: ListView(
            controller: _scrollController,
            padding: EdgeInsets.fromLTRB(
              compact ? 16 : 0,
              compact ? 6 : 8,
              compact ? 16 : 0,
              18,
            ),
            children: [
              (() {
                final hasCustomKey = (userApiKey ?? '').trim().isNotEmpty;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: (hasCustomKey ? colors.success : colors.primary).withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: (hasCustomKey ? colors.success : colors.primary).withValues(alpha: 0.16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        hasCustomKey ? Icons.check_circle_outline_rounded : Icons.info_outline_rounded,
                        color: hasCustomKey ? colors.success : colors.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          hasCustomKey
                              ? (locale == AppLocale.ru 
                                  ? 'Используется ваш сохраненный ключ API. Изменить его можно в настройках профиля.' 
                                  : locale == AppLocale.kk 
                                      ? 'Сіздің сақталған API кілтіңіз қолданылуда. Оны профиль баптауларында өзгертуге болады.'
                                      : 'Using your saved custom API key. You can modify it in profile settings.')
                              : (locale == AppLocale.ru 
                                  ? 'Используется стандартный ключ. Вы можете вставить свой API-ключ в настройках профиля.' 
                                  : locale == AppLocale.kk 
                                      ? 'Стандартты кілт қолданылуда. Профиль баптауларында өз жеке API кілтіңізді қоя аласыз.'
                                      : 'Using the default API key. You can insert your custom API key in profile settings.'),
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              })(),
              if (chatState.messages.isEmpty) ...[
                const SizedBox(height: 20),
                const Center(
                  child: _GlowingSparkAnimator(),
                ),
                const SizedBox(height: 30),
              ],
              _FaqSection(
                locale: locale,
                onAsk: (question) {
                  _submitMessage(question);
                },
              ),
              const SizedBox(height: 16),
              ...chatState.messages.map(
                  (message) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _MessageBubble(message: message),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            compact ? 16 : 0,
            0,
            compact ? 16 : 0,
            compact ? 16 : 20,
          ),
          child: AppGuideTarget(
            id: AppGuideTargetIds.aiComposer,
            child: _AiComposer(
              controller: _controller,
              onSubmitted: (_) => _send(),
              onSend: _send,
              isSending: chatState.isSending,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AiChatState>(aiChatControllerProvider, (previous, next) {
      if ((previous?.messages.length ?? 0) != next.messages.length) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _scrollToBottom();
          }
        });
      }

      final nextError = next.errorMessage;
      if (nextError != null &&
          nextError.isNotEmpty &&
          nextError != previous?.errorMessage &&
          mounted) {
        AppNotice.show(
          context,
          message: nextError,
          type: AppNoticeType.error,
          duration: const Duration(seconds: 3),
        );
      }
    });

    final locale = ref.watch(
      demoAppControllerProvider.select((state) => state.locale),
    );
    final chatState = ref.watch(aiChatControllerProvider);
    final userApiKey = ref.watch(aiUserApiKeyProvider);
    final colors = context.appColors;
    final compact = context.isCompactLayout;

    return AppPageScaffold(
      horizontalPadding: compact ? 0 : null,
      expandContent: !compact,
      child: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            final isControlPressed = HardwareKeyboard.instance.isControlPressed;
            
            // Ctrl + W
            if (isControlPressed && event.logicalKey == LogicalKeyboardKey.keyW) {
              _confirmDeleteChat(context, chatState.activeChatId);
              return KeyEventResult.handled;
            }
            
            // Delete
            if (event.logicalKey == LogicalKeyboardKey.delete) {
              if (!_isTextFieldFocused()) {
                _confirmDeleteChat(context, chatState.activeChatId);
                return KeyEventResult.handled;
              }
            }
            
            // Ctrl + E
            if (isControlPressed && event.logicalKey == LogicalKeyboardKey.keyE) {
              final activeId = chatState.activeChatId;
              final title = chatState.chatTitles[activeId] ?? '';
              _showRenameDialog(context, activeId, title);
              return KeyEventResult.handled;
            }
            
            // Ctrl + T
            if (isControlPressed && event.logicalKey == LogicalKeyboardKey.keyT) {
              ref.read(aiChatControllerProvider.notifier).createNewChat();
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: compact
        ? AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: KeyedSubtree(
              key: ValueKey(chatState.activeChatId),
              child: _buildChatPane(context, colors, chatState, true, userApiKey, locale),
            ),
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSidebar(context, colors, chatState),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.04, 0.0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey(chatState.activeChatId),
                      child: _buildChatPane(context, colors, chatState, false, userApiKey, locale),
                    ),
                  ),
                ),
              ),
            ],
          ),
      ),
    );
  }
}

class _AiComposer extends StatelessWidget {
  const _AiComposer({
    required this.controller,
    required this.onSubmitted,
    required this.onSend,
    required this.isSending,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final Future<void> Function() onSend;
  final bool isSending;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      decoration: BoxDecoration(
        color: colors.backgroundElevated.withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Focus(
              onKeyEvent: (node, event) {
                if (event is! KeyUpEvent && event.logicalKey == LogicalKeyboardKey.enter) {
                  final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;
                  if (isShiftPressed) {
                    // Explicitly insert a newline at the current cursor position
                    final text = controller.text;
                    final selection = controller.selection;
                    final newText = text.replaceRange(selection.start, selection.end, '\n');
                    controller.value = TextEditingValue(
                      text: newText,
                      selection: TextSelection.collapsed(offset: selection.start + 1),
                    );
                    return KeyEventResult.handled;
                  } else {
                    // Submit the message without adding a newline
                    if (!isSending) {
                      onSend();
                    }
                    return KeyEventResult.handled;
                  }
                }
                return KeyEventResult.ignored;
              },
              child: TextField(
                controller: controller,
                enabled: !isSending,
                minLines: 1,
                maxLines: 4,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: _askQuestionLabel(context.l10n.locale),
                  hintStyle: TextStyle(color: colors.textSecondary),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                style: TextStyle(color: colors.textPrimary, height: 1.25),
              ),
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: isSending ? null : () => onSend(),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.surfaceSoft,
              ),
              child: isSending
                  ? Padding(
                      padding: const EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colors.textPrimary,
                        ),
                      ),
                    )
                  : Icon(Icons.arrow_upward_rounded, color: colors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatefulWidget {
  const _MessageBubble({required this.message});

  final AiChatMessage message;

  @override
  State<_MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<_MessageBubble> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final compact = context.isCompactLayout;
    final isMentor = widget.message.author == AiChatAuthor.mentor;
    final accent = isMentor ? colors.primary : colors.accent;
    final label = isMentor
        ? context.l10n.text('mentor_label')
        : context.l10n.text('you_label');

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            final bubbleMaxWidth = compact
                ? availableWidth
                : isMentor
                ? availableWidth
                : math.min(availableWidth * 0.62, 680.0);

            return Align(
              alignment: isMentor ? Alignment.centerLeft : Alignment.centerRight,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: bubbleMaxWidth),
                child: GlowCard(
                  accent: accent,
                  child: Column(
                    crossAxisAlignment: isMentor
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.end,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (widget.message.isPending)
                        _ThinkingText(locale: context.l10n.locale)
                      else
                        InlineMarkdownText(
                          text: widget.message.text,
                          style: TextStyle(color: colors.textPrimary, height: 1.45),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FaqSection extends StatelessWidget {
  const _FaqSection({required this.locale, required this.onAsk});

  final AppLocale locale;
  final ValueChanged<String> onAsk;

  @override
  Widget build(BuildContext context) {
    final items = _faqItemsFor(locale).take(3).toList();
    final colors = context.appColors;

    return GlowCard(
      accent: colors.success,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _questionsLabel(context.l10n.locale),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 14),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _FaqCard(
                item: item,
                askLabel: context.l10n.text('ask_now'),
                onAsk: () => onAsk(item.question),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_FaqItem> _faqItemsFor(AppLocale locale) {
    return switch (locale) {
      AppLocale.ru => const <_FaqItem>[
        _FaqItem(
          question: 'В чем разница между stack и heap?',
          answer:
              'Stack хранит короткоживущие данные вызовов и локальные переменные, а heap используется для объектов с более гибким временем жизни и обычно управляется сборщиком мусора.',
        ),
        _FaqItem(
          question: 'Когда использовать List, Set и Map?',
          answer:
              'List подходит для упорядоченной последовательности, Set — для уникальных значений, а Map — когда нужно быстро получать значение по ключу.',
        ),
        _FaqItem(
          question: 'Чем synchronous код отличается от asynchronous?',
          answer:
              'Синхронный код выполняется шаг за шагом и блокирует текущий поток, а асинхронный позволяет ждать сеть, файл или таймер без остановки остальной работы.',
        ),
        _FaqItem(
          question: 'Когда лучше использовать рекурсию, а когда цикл?',
          answer:
              'Рекурсия удобна для деревьев, графов и задач с естественным разбиением на подзадачи, а цикл обычно проще и экономнее по памяти для линейных проходов.',
        ),
        _FaqItem(
          question:
              'Как подойти к отладке, если код работает не так, как ожидалось?',
          answer:
              'Сначала воспроизведите проблему стабильно, затем проверьте входные данные, промежуточные значения и граничные случаи, чтобы сузить место ошибки перед исправлением.',
        ),
      ],
      AppLocale.kk => const <_FaqItem>[
        _FaqItem(
          question: 'Stack пен heap арасындағы айырмашылық қандай?',
          answer:
              'Stack-та функция шақырулары мен жергілікті айнымалылар сияқты қысқа өмір сүретін деректер сақталады, ал heap-та өмір сүру уақыты икемдірек объектілер орналасады және оны көбіне garbage collector басқарады.',
        ),
        _FaqItem(
          question: 'List, Set және Map-ты қашан қолданған дұрыс?',
          answer:
              'List реті маңызды тізбекке ыңғайлы, Set қайталанбайтын мәндер үшін қолайлы, ал Map кілт арқылы мәнді тез табу керек болғанда пайдаланылады.',
        ),
        _FaqItem(
          question:
              'Synchronous код пен asynchronous кодтың айырмашылығы неде?',
          answer:
              'Синхронды код қадам-қадаммен орындалып, ағымдағы ағынды бөгейді, ал асинхронды код желі, файл не таймерді күткенде қалған жұмысты тоқтатпайды.',
        ),
        _FaqItem(
          question: 'Рекурсияны қашан, циклды қашан қолданған дұрыс?',
          answer:
              'Рекурсия ағаштар, графтар және ішкі есептерге табиғи бөлінетін міндеттер үшін ыңғайлы, ал цикл сызықтық өту кезінде әдетте қарапайым әрі жадты азырақ қолданады.',
        ),
        _FaqItem(
          question:
              'Код күткендей жұмыс істемесе, оны қалай жөндеп тексерген дұрыс?',
          answer:
              'Алдымен қатені тұрақты түрде қайталаңыз, содан кейін кіріс деректерін, аралық мәндерді және шеткі жағдайларды тексеріп, мәселенің нақты орнын тарылтыңыз.',
        ),
      ],
      AppLocale.en => const <_FaqItem>[
        _FaqItem(
          question: 'What is the difference between stack and heap?',
          answer:
              'The stack stores short-lived call data and local variables, while the heap is used for objects with a more flexible lifetime and is usually managed by the garbage collector.',
        ),
        _FaqItem(
          question: 'When should I use List, Set, and Map?',
          answer:
              'Use a List for ordered sequences, a Set for unique values, and a Map when you need to look up values quickly by key.',
        ),
        _FaqItem(
          question: 'How is synchronous code different from asynchronous code?',
          answer:
              'Synchronous code runs step by step and blocks the current thread, while asynchronous code can wait for network, file, or timer operations without stopping the rest of the work.',
        ),
        _FaqItem(
          question: 'When is recursion better than a loop?',
          answer:
              'Recursion works well for trees, graphs, and problems that naturally split into smaller subproblems, while loops are usually simpler and more memory-efficient for linear passes.',
        ),
        _FaqItem(
          question: 'How should I debug code that behaves unexpectedly?',
          answer:
              'First reproduce the problem reliably, then inspect inputs, intermediate values, and edge cases so you can narrow down the exact source of the bug before fixing it.',
        ),
      ],
    };
  }
}

String _questionsLabel(AppLocale locale) {
  return switch (locale) {
    AppLocale.ru => 'Вопросы',
    AppLocale.en => 'Questions',
    AppLocale.kk => 'Сұрақтар',
  };
}

String _askQuestionLabel(AppLocale locale) {
  return switch (locale) {
    AppLocale.ru => 'Задать вопрос',
    AppLocale.en => 'Ask a question',
    AppLocale.kk => 'Сұрақ қою',
  };
}

List<String> _thinkingFrames(AppLocale locale) {
  return switch (locale) {
    AppLocale.ru => <String>[
      'AI думает',
      'AI думает.',
      'AI думает..',
      'AI думает...',
    ],
    AppLocale.en => <String>[
      'AI is thinking',
      'AI is thinking.',
      'AI is thinking..',
      'AI is thinking...',
    ],
    AppLocale.kk => <String>[
      'AI ойланып жатыр',
      'AI ойланып жатыр.',
      'AI ойланып жатыр..',
      'AI ойланып жатыр...',
    ],
  };
}

class _ThinkingText extends StatelessWidget {
  const _ThinkingText({required this.locale});

  final AppLocale locale;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final frames = _thinkingFrames(locale);

    return DefaultTextStyle(
      style: TextStyle(color: colors.textPrimary, height: 1.45),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: colors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.32),
                  blurRadius: 12,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AnimatedTextKit(
              repeatForever: true,
              pause: const Duration(milliseconds: 120),
              isRepeatingAnimation: true,
              displayFullTextOnTap: false,
              stopPauseOnTap: false,
              animatedTexts: [
                for (final frame in frames)
                  FadeAnimatedText(
                    frame,
                    duration: const Duration(milliseconds: 420),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqCard extends StatelessWidget {
  const _FaqCard({
    required this.item,
    required this.askLabel,
    required this.onAsk,
  });

  final _FaqItem item;
  final String askLabel;
  final VoidCallback onAsk;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colors.surfaceSoft,
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.question,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.answer,
            style: TextStyle(color: colors.textSecondary, height: 1.45),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: onAsk,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.send_rounded, size: 16, color: colors.primary),
                    const SizedBox(width: 8),
                    Text(
                      askLabel,
                      style: TextStyle(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqItem {
  const _FaqItem({required this.question, required this.answer});

  final String question;
  final String answer;
}

class _GlowingSparkAnimator extends StatefulWidget {
  const _GlowingSparkAnimator();

  @override
  State<_GlowingSparkAnimator> createState() => _GlowingSparkAnimatorState();
}

class _GlowingSparkAnimatorState extends State<_GlowingSparkAnimator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: SvgPicture.asset(
        'assets/svgs/ai_spark.svg',
        width: 140,
        height: 140,
      ),
    );
  }
}
