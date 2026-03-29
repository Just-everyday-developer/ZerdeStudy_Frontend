import 'dart:math' as math;

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/state/app_locale.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../core/common_widgets/app_notice.dart';
import '../../../../core/common_widgets/app_page_scaffold.dart';
import '../../../../core/common_widgets/glow_card.dart';
import '../../../../core/common_widgets/inline_markdown_text.dart';
import '../../../../core/layout/app_breakpoints.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../domain/entities/ai_chat_message.dart';
import '../providers/ai_chat_controller.dart';
import '../providers/ai_chat_state.dart';

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
    final colors = context.appColors;
    final compact = context.isCompactLayout;

    return AppPageScaffold(
      horizontalPadding: compact ? 0 : null,
      child: Column(
        children: [
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
                _FaqSection(
                  locale: locale,
                  onAsk: (question) {
                    _submitMessage(question);
                  },
                ),
                const SizedBox(height: 16),
                if (chatState.messages.isEmpty)
                  GlowCard(
                    accent: colors.success,
                    child: Text(
                      context.l10n.text('empty_chat'),
                      style: TextStyle(
                        color: colors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  )
                else
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
            child: _AiComposer(
              controller: _controller,
              onSubmitted: (_) => _send(),
              onSend: _send,
              isSending: chatState.isSending,
            ),
          ),
        ],
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
            child: TextField(
              controller: controller,
              enabled: !isSending,
              minLines: 1,
              maxLines: 3,
              textInputAction: TextInputAction.send,
              onSubmitted: onSubmitted,
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

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final AiChatMessage message;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final compact = context.isCompactLayout;
    final isMentor = message.author == AiChatAuthor.mentor;
    final accent = isMentor ? colors.primary : colors.accent;
    final label = isMentor
        ? context.l10n.text('mentor_label')
        : context.l10n.text('you_label');

    return LayoutBuilder(
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
                  if (message.isPending)
                    _ThinkingText(locale: context.l10n.locale)
                  else
                    InlineMarkdownText(
                      text: message.text,
                      style: TextStyle(color: colors.textPrimary, height: 1.45),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FaqSection extends StatelessWidget {
  const _FaqSection({required this.locale, required this.onAsk});

  final AppLocale locale;
  final ValueChanged<String> onAsk;

  @override
  Widget build(BuildContext context) {
    final items = _faqItemsFor(locale);
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
            child: TextButton.icon(
              onPressed: onAsk,
              icon: Icon(Icons.send_rounded, size: 16, color: colors.primary),
              label: Text(
                askLabel,
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
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
