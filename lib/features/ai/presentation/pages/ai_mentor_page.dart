import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/state/app_locale.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../core/common_widgets/app_notice.dart';
import '../../../../core/common_widgets/app_page_scaffold.dart';
import '../../../../core/common_widgets/glow_card.dart';
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
    final isMentor = message.author == AiChatAuthor.mentor;
    final accent = isMentor ? colors.primary : colors.accent;
    final label = isMentor
        ? context.l10n.text('mentor_label')
        : context.l10n.text('you_label');
    final text = message.isPending
        ? _thinkingLabel(context.l10n.locale)
        : message.text;

    return Align(
      alignment: isMentor ? Alignment.centerLeft : Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: GlowCard(
          accent: accent,
          child: Column(
            crossAxisAlignment: isMentor
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.end,
            children: [
              Text(
                label,
                style: TextStyle(color: accent, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                text,
                style: TextStyle(color: colors.textPrimary, height: 1.45),
              ),
            ],
          ),
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
          question: 'С чего лучше начать в этом дереве знаний?',
          answer:
              'Начните с core-тем: математика, алгоритмы, базы данных, сети и операционные системы дают основу почти для всех инженерных направлений.',
        ),
        _FaqItem(
          question: 'Как Operating Systems помогает понять backend и mobile?',
          answer:
              'ОС объясняют процессы, память, файлы, потоки и работу с ресурсами, а это напрямую влияет на серверные приложения и мобильный runtime.',
        ),
        _FaqItem(
          question: 'Какие core-темы особенно важны для ML Engineer?',
          answer:
              'Линейная алгебра, теория вероятностей и статистика особенно важны: они помогают понимать представление данных, обучение моделей и оценку качества.',
        ),
        _FaqItem(
          question: 'Зачем в уроках есть Output Quiz и Code Memory Lab?',
          answer:
              'Output Quiz тренирует понимание выполнения кода, а Code Memory Lab закрепляет синтаксис и типичные шаблоны через короткие упражнения.',
        ),
        _FaqItem(
          question: 'Как выбрать следующую ветку после текущей?',
          answer:
              'Идите по соседним ветвям: после core-тем логично переходить в специализацию, которая использует этот фундамент на практике.',
        ),
      ],
      AppLocale.kk => const <_FaqItem>[
        _FaqItem(
          question: 'Осы білім ағашында неден бастаған дұрыс?',
          answer:
              'Алдымен core-тақырыптардан бастаған дұрыс: математика, алгоритмдер, деректер базасы, желілер мен операциялық жүйелер кейінгі бағыттарға негіз болады.',
        ),
        _FaqItem(
          question:
              'Operating Systems backend пен mobile бағытына қалай көмектеседі?',
          answer:
              'ОЖ процестерді, жадты, файлдарды, ағындарды және ресурстармен жұмысты түсіндіреді. Бұл серверлік және мобильді қосымшалардың жұмысына тікелей әсер етеді.',
        ),
        _FaqItem(
          question: 'ML Engineer үшін қай core-тақырыптар маңызды?',
          answer:
              'Сызықтық алгебра, ықтималдық теориясы және статистика модельдерді, деректерді және бағалау метрикаларын түсінуге көмектеседі.',
        ),
        _FaqItem(
          question: 'Неліктен сабақтарда Output Quiz пен Code Memory Lab бар?',
          answer:
              'Output Quiz кодтың орындалуын түсінуді дамытады, ал Code Memory Lab синтаксис пен үлгілерді қысқа тапсырмалар арқылы бекітеді.',
        ),
        _FaqItem(
          question: 'Келесі тармақты қалай таңдаған дұрыс?',
          answer:
              'Алдыңғы core-тақырыппен логикалық байланысы бар келесі бағытқа өткен дұрыс.',
        ),
      ],
      AppLocale.en => const <_FaqItem>[
        _FaqItem(
          question: 'Where should I start in this tree?',
          answer:
              'Start with the core branches because they explain the foundation behind most engineering roles.',
        ),
        _FaqItem(
          question: 'How do Operating Systems support backend and mobile?',
          answer:
              'Operating Systems explain processes, memory, files, threads, and resource access, which shape both server and mobile runtime behavior.',
        ),
        _FaqItem(
          question: 'Which core topics matter most for ML Engineer?',
          answer:
              'Linear algebra, probability, and statistics are especially important because they support model training, data representation, and evaluation.',
        ),
        _FaqItem(
          question: 'Why do lessons include Output Quiz and Code Memory Lab?',
          answer:
              'The quiz checks code execution reasoning, while the memory lab reinforces syntax and structure through short active practice.',
        ),
        _FaqItem(
          question: 'How should I choose the next branch?',
          answer:
              'Move into the specialization that naturally builds on the core topic you just studied.',
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

String _thinkingLabel(AppLocale locale) {
  return switch (locale) {
    AppLocale.ru => 'AI думает...',
    AppLocale.en => 'AI is thinking...',
    AppLocale.kk => 'AI ойланып жатыр...',
  };
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
